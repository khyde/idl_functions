; $ID:	READ_HDF_2STRUCT.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION READ_HDF_2STRUCT, FILE, PRODUCTS=PRODUCTS,  LOOK=look,  ATTRIBUTES=attributes, MAX_ATTR=max_attr, ERROR=error, ERR_MSG=err_msg

;+
; NAME: READ_HDF_2STRUCT
;
; PURPOSE:	Read a SEADAS HDF file and returns the information in an IDL structure;
;						Also reads NASA JPL HDF (SST Pathfinder, MODIS SST, etc) and NOAA CoastWatch HDF files

; EXAMPLES:
;
;				In addition to the following examples see READ_HDF_2STRUCT_DEMO.PRO
;
;				To determine the type of information in the HDF file try using the /LOOK option.
;				To conserve memory, the LOOK keyword will returns the sizes and data types of the images but not the image data arrays.
;				Result = READ_HDF_2STRUCT(FILE,/LOOK )												;
;
;				Result = READ_HDF_2STRUCT(FILE) 															; Returns structure with all (GLOBAL and Scientific Data Sets)
;				Result = READ_HDF_2STRUCT(FILE,PRODUCTS='CHLOR_A') 						; Returns just the CHLOR_A layer
;				Result = READ_HDF_2STRUCT(FILE,PRODUCTS=['CHLOR_A','GLOBAL']) ; Returns GLOBAL attributes and the CHLOR_A Layer
;				Result = READ_HDF_2STRUCT(FILE,PRODUCTS=['CHLOR_A','NLW_443') ; Returns CHLOR_A and NLW_443 Layers
;
;
; PARAMETERS:
;						File (Input: An HDF FILE containing GLOBAL and/or SD Scientific Data Sets)
;
; KEYWORDS:
;       PRODUCTS: 	The PRODUCTS in the HDF that you want (e.g. PRODUCTS = 'CHLOR_A' OR PRODUCTS = 'GLOBAL', OR PRODUCTS='SD')
;										products = 'SD'    		To extract all Scientific Datasets
;										products = 'GLOBAL' 	to extract the Global Attributes
;										products = ['GLOBAL','SD'] To extract both GLOBAL AND SD into an IDL structure
;
;										If PRODUCTS are not provided then ALL GLOBAL and SD Scientific Data products in the HDF file are returned in a STRUCTURE

;				LOOK:				Returns information on the size and data types of the SD image data arrays but not the actual data.
;										This is useful for exploring HDFs with large image arrays.
;
;       MAX_ATTR:  	The maximum number of attributes to read from each PRODUCT layer in the hdf file (Normally not needed)
;
;				ERROR:			Program error code (ok=0; error = 1)
;				ERR_MSG:		Error message (ok='', if error then ERR_MSG containes !ERROR_STATE.MSG
;										or an error message defined by this routine).
;
; OUTPUTS:
;       A Nested STRUCTURE, usually with the image array and related information such as scaling,data units, etc.
;
;	RESTRICTIONS:
;				Memory limitations may prevent the reading of all data in the HDF file and returning a large structure
;				If so ... then make several calls to READ_HDF_2STRUCT, each time requesting just some of the PRODUCTS
;
;				Note that this program will rename the original HDF tag names to Valid IDL tag names when the HDF names contain
;				characters such as dashes '-' or spaces, etc. which are not compatible with IDL's naming scheme for Variables.
;				The IDL routine: IDL_VALIDNAME is used to convert any invalid HDF names into valid IDL tag names, substituting
;				underscores for invalid characters.
;
;				This program changes the working directory to the directory where the HDF file resides, then changes directory
;				back to the current directory used before calling this routine.
;				Reading the HDF file this way, directly from its folder location and without any path information, works best.
;
;				This program reads the GLOBAL attributes and the Scientific Data (SD) in the HDF file but not other HDF types
;				!! Does not yet read VGROUPS and VDATA (e.g. as in SeaWiFS L3b files which are read using a separate
;				IDL HDF program designed for L3bin HDF files).
;
;	NOTES:
;				This code will display better in the IDL EDITOR if you set the
;				number of spaces to indent for each tab to  2 (see IDL Preferences menu)
;				Program works with IDL 6.1, 6.2, 6.3
;
;	OTHER LOCAL ROUTINES CALLED:
;				FILE_PARSE 	Parses file name components
;				GONE 				Removes variable from memory
;
;MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 1997.
;       modified Dec 29,1998 JOR.
;       April 9,1999 added max_attr
;       June 1,2000  JOR modifed PRODUCTS from integer to Seadas Product names (e.g. NLW443, CHLOR_A, ETC).
;				April 25, 2002 JOR, changed MAX_ATTR FROM 15 TO THE determined number of attr in the hdf file
;				Aug 10, 2003 JOR added capability to read NASA JPL pathfinder files
;				Sept 19, 2006 JOR Removed Rotate image (flip)
;-

;	===> Initialize
	ROUTINE_NAME = 'READ_HDF_2STRUCT'
	ERROR=0
	ERR_MSG = ''



;	===> If specific products are not requested then read GLOBAL and SD information from the HDF
	IF N_ELEMENTS(PRODUCTS) EQ 0 THEN TARGETS = ['GLOBAL','SD'] ELSE TARGETS = PRODUCTS

; ===> If file names are not provided then use IDL PICKFILE to prompt for a file
  IF N_ELEMENTS(FILE) EQ 0 THEN _FILE = PICKFILE() ELSE _FILE = FILE

;	===> Parse the file name into its components (Directory, Name, Ext)
  FN=FILE_PARSE(_FILE)
  AFILE = FN.NAME + FN.EXT_DELIM + FN.EXT


;	===> Change directory to the directory containing the HDF file
;			 and store current directory (DIR_OLD) so that it may be restored at the end of this routine
	CD,CURR=DIR_OLD
	CD,FN.DIR


;	**********************************************************
;	*** E R R O R   H A N D L I N G    P R O C E D U R E   ***
;	**********************************************************
;	1)	This program will jump into the next block (CATCH) if any errors are encountered;
;	2) 	The Error Code and Error Message are returned in keywords ERROR AND ERROR_MSG
;	3) 	This program will return -1 to the calling routine (and ERROR and ERR_MSG if requested)
;	4) 	This program will attempt to close the HDF file
;	5)	The directory will be changed back to the original directory (DIR_OLD)
;	6)	The routine will return a -1 instead of a data structure

	CATCH, ERROR_STATUS
	IF ERROR_STATUS NE 0 THEN BEGIN
 		ERROR_STATUS=0
 		ERROR=1
 		PRINT, ERR_MSG
 		ERR_MSG = !ERROR_STATE.MSG
    IF FILE_ID EQ -1 THEN STOP
; 	===> Close the HDF file
 		IF N_ELEMENTS(FILE_ID) 	EQ 1 THEN HDF_CLOSE, FILE_ID
;		===> Change directory to DIR_OLD and ABORT and RETURN, -1
		CD,DIR_OLD
		CATCH, /CANCEL
 		RETURN, -1
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;	===> Ensure that the file is an HDF file
	IF HDF_ISHDF(AFILE) NE 1 THEN BEGIN
		ERROR=1 & ERR_MSG = AFILE+ ' is not an HDF File'
		CD,DIR_OLD & RETURN, -1
	ENDIF

;	===> Open the HDF file for reading only
  file_id=HDF_OPEN(AFILE,/READ)

; ===> Get the Scientific Dataset ID from the HDF file
	sd_id=HDF_SD_START(AFILE)

; ===> Get Number of Scientific Data Sets and Number of GLOBAL Attributes
  HDF_SD_FILEINFO,sd_id,NumSDS,n_global_attributes


;	********************************************
;	*** G L O B A L    A T T R I B U T E S   ***
;	********************************************
	OK = WHERE(STRUPCASE(TARGETS) EQ 'GLOBAL',COUNT)
	IF n_global_attributes GE 1 AND COUNT GE 1 THEN BEGIN
	;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	 	FOR nth=0L,n_global_attributes-1L DO BEGIN
	 		HDF_SD_ATTRINFO, sd_id,nth,name=attrinfo_name,type=attrinfo_type,count=attrinfo_count,data=attrinfo_data,hdf_type=attrinfo_hdf_type
	;		===> Convert any invalid HDF attribute names (with dashes or spaces, etc) into valid IDL variable names
			attrinfo_name =  IDL_VALIDNAME(attrinfo_name,/CONVERT_ALL)
			IF N_ELEMENTS(STRUCT_GLOBAL) EQ 0 THEN BEGIN
	    	STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(attrinfo_name,attrinfo_data))
	    ENDIF ELSE BEGIN
	      STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,attrinfo_name,attrinfo_data))
	    ENDELSE
		ENDFOR ; FOR nth=0L,n_global_attributes-1L DO BEGIN
		STRUCT = CREATE_STRUCT('GLOBAL',STRUCT_GLOBAL)
		GONE, STRUCT_GLOBAL
 	ENDIF



;	**************************************************************
;	*** S C I E N T I F I C   D A T A    A T T R I B U T E S   ***
;	**************************************************************
 	IF NumSDS GE 1 THEN BEGIN

; 	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  	FOR _NUMSDS = 0,NUMSDS-1L DO BEGIN
    	aband = _NUMSDS
;      print,_numsds
;      if _NUMSDS eq xxx then begin
;        print, _NUMSDS ; get a breakpoint
;      end
;   	===> Select a Band
			sds_id=HDF_SD_SELECT(sd_id,aband)

;   	===>  Get band information
    	HDF_SD_GETINFO,sds_id,NATTS=natts,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE,NAME=name

;PRINT, NAME

;			===> If MAX_ATTR not specified then get all NATTS
; FIXME: THis is a bug.  If a previously read maximum # of attributes was less than (this) subsequent
;   max_attr, then the previously (lower) max_attr defines the max_attr.  EG MAX_ATTR was 3 in the
;   previous call, but NATTS is read and is 6, so MAX_ATTR will stay at 3.  -DWM
;   Happens if MAX_ATTR wasn't specified as a keyword/param.
;			IF N_ELEMENTS(MAX_ATTR) NE 1 THEN MAX_ATTR= natts ELSE MAX_ATTR = MAX_ATTR < NATTS ;
; Temporary fix:
     IF KEYWORD_SET(MAX_ATTR) THEN BEGIN
      if MAX_ATTR lt NATTS then $
        GET_ATTR = MAX_ATTR $
      else $
        GET_ATTR = NATTS
     ENDIF ELSE $
      GET_ATTR = NATTS

			TARGET = NAME

			OK_PRODUCT 	= WHERE(STRUPCASE(TARGETS) EQ STRUPCASE(NAME),COUNT_PRODUCT)
			OK_SD 			= WHERE(STRUPCASE(TARGETS) EQ STRUPCASE('SD'),COUNT_SD)

    	IF COUNT_PRODUCT GE 1 OR COUNT_SD GE 1 THEN BEGIN
;     	===> Fill in the band details
;				LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	      FOR nth = 0, GET_ATTR-1L  DO BEGIN

	        HDF_SD_ATTRINFO, sds_id,nth,name=attrinfo_name,type=attrinfo_type,count=attrinfo_count,data=attrinfo_data,hdf_type=attrinfo_hdf_type

	        IF STRMID(!ERR_STRING,0,31) EQ 'HDF_SD_ATTRINFO: Unable to read' THEN BEGIN
	        	PRINT, !ERR_STRING
	         	CONTINUE
	        ENDIF

;					===> Convert any invalid HDF attribute names (with dashes or spaces, etc) into valid IDL variable names
					attrinfo_name =  IDL_VALIDNAME(attrinfo_name,/CONVERT_ALL)

	        IF NTH EQ 0 THEN BEGIN
	          _attrinfo = TEMPORARY(CREATE_STRUCT(attrinfo_name,attrinfo_data))
	        ENDIF ELSE BEGIN
	          _attrinfo = TEMPORARY(CREATE_STRUCT(_attrinfo,attrinfo_name,attrinfo_data))
	        ENDELSE
	      ENDFOR ; FOR nth = 0, MAX_ATTR-1L  DO BEGIN
;				|||||||||||||||||||||||||||||||||||||||||||
;     	===> Get the image data
      	HDF_SD_GETDATA,sds_id,image

;				===> Get dimensions of Image
				sz=SIZE(IMAGE,/STRUCT)

;				===> Convert any invalid HDF names (with dashes or spaces, etc) into valid IDL variable names
				NAME =  IDL_VALIDNAME(NAME,/CONVERT_ALL)

;   		===> Make an Structure
    		IF KEYWORD_SET(LOOK) THEN BEGIN
;					===> Fill the structure with information on the size of the image array INSTEAD of the actual image array
					txt = 'Size is ' + STRTRIM(SZ.DIMENSIONS[0],2)
					IF SZ.N_DIMENSIONS GE 2 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS[1],2)
					IF SZ.N_DIMENSIONS EQ 3 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS(2),2)
	    		IF SZ.N_DIMENSIONS EQ 4 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS(3),2)
	    		arr = CREATE_STRUCT(name,name,'image',txt,_ATTRINFO)
    		ENDIF ELSE BEGIN

       	ARR = CREATE_STRUCT(name,name,'IMAGE',IMAGE,_ATTRINFO)

    		ENDELSE

;				===> Free memory by eliminating IMAGE
				GONE,IMAGE

;   		===> Add each band to the structure
	    	IF N_ELEMENTS(STRUCT_SD) EQ 0 THEN BEGIN
	      	STRUCT_SD = TEMPORARY(CREATE_STRUCT(NAME,ARR))
	    	ENDIF ELSE BEGIN
	      	STRUCT_SD = TEMPORARY(CREATE_STRUCT(STRUCT_SD,NAME,ARR))
	    	ENDELSE

;				===> Free memory by eliminating ARR
				GONE,ARR
   		ENDIF ;  	IF COUNT EQ 1 THEN BEGIN
   	ENDFOR ;   FOR _NUMSDS = 0,NUMSDS-1L DO BEGIN
;		|||||||||||||||||||||||||||||||||||||||||||||



   	IF N_ELEMENTS(STRUCT_SD) GE 1 THEN BEGIN
   		IF N_ELEMENTS(STRUCT) GE 1 THEN STRUCT = CREATE_STRUCT(STRUCT,'SD',STRUCT_SD) ELSE STRUCT = CREATE_STRUCT('SD',STRUCT_SD)
   	ENDIF

 		IF N_ELEMENTS(sds_id) EQ 1 THEN BEGIN
 			HDF_SD_ENDACCESS,sds_id
 			HDF_SD_END, sd_id
 		ENDIF

  	ENDIF ELSE HDF_SD_END, SD_ID; IF NumSDS GE 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||


; ===> Close the HDF file
  IF N_ELEMENTS(FILE_ID) 	EQ 1 THEN HDF_CLOSE, FILE_ID
  IF N_ELEMENTS(FILE_ID)  EQ 0 THEN STOP

	CD,DIR_OLD

	IF N_ELEMENTS(STRUCT) EQ 0 THEN BEGIN
		ERROR = 1
		ERR_MSG = 'NONE OF THE REQUESTED PRODUCTS WERE FOUND IN THE HDF FILE'
		RETURN, -1
;		STRUCT = -1
	ENDIF
  IF N_ELEMENTS(_ATTRINFO) NE 0 THEN ATTRIBUTES=_ATTRINFO
  RETURN, STRUCT

END; #####################  End of Routine ################################


