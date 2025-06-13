; $ID:	READ_HDF.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION READ_HDF, FILE, PRODS=PRODS, BINS=bins, LOOK=look, ATTRIBUTES=attributes, DATA=data, NAMES=names, STRUCT=struct, INFO=info, VERBOSE=verbose

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
;       PRODS: 	  The PRODUCTS in the HDF that you want (e.g. PRODUCTS = 'CHLOR_A' OR PRODUCTS = 'GLOBAL', OR PRODUCTS='SD')
;										PRODS = 'SD'    		To extract all Scientific Datasets
;										PRODS = 'GLOBAL' 	to extract the Global Attributes
;										PRODS = ['GLOBAL','SD'] To extract both GLOBAL AND SD into an IDL structure
;
;								  If PRODUCTS are not provided then ALL GLOBAL and SD Scientific Data products in the HDF file are returned in a STRUCTURE
;
;				LOOK:		  Returns information on the size and data types of the SD image data arrays but not the actual data.
;								  This is useful for exploring HDFs with large image arrays.
;
;	      DATA:     Return the data array instead of the complete structure
;       NAMES:    Return the names of all prods in the nc file
;       STRUCT:   Return the entire structure 
;       VERBOSE:  Print info
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
;       Modified Dec 29,1998 JOR.
;         Apr  9, 1999 - JOR:  Added MAX_ATTR
;         Jun  1, 2000 - JOR:  Modifed PRODUCTS from integer to Seadas Product names (e.g. NLW443, CHLOR_A, ETC).
;				  Apr 25, 2002 - JOR:  Changed MAX_ATTR FROM 15 TO THE determined number of attr in the hdf file
;				  Aug 10, 2003 - JOR:  Added capability to read NASA JPL pathfinder files
;				  Sep 19, 2006 - JOR:  Removed Rotate image (flip)
;				  Nov 23, 2015 - KJWH: Renamed to READ_HDF to be consistent with other READ programs (i.e. READ_NC)
;				                       Changed PRODUCTS keyword to PRODS
;				                       Removed MAX_ATTR keyword because it is never used
;				                       
;-

;	===> Initialize
	ROUTINE_NAME = 'READ_HDF'
	
;===> IF SPECIFIC PRODS ARE NOT REQUESTED THEN RETURN GLOBAL AND SD INFO
  IF NONE(PRODS) THEN TARGETS = ['GLOBAL','SD'] ELSE TARGETS = PRODS
  IF NONE(FILE)  THEN FILE = DIALOG_PICKFILE(FILTER = '*.HDF')

; ===> ERROR HANDLING
	CATCH, ERROR_STATUS
	IF ERROR_STATUS NE 0 THEN BEGIN
 		ERROR_STATUS=0
 		PRINT, !ERROR_STATE.MSG 
    IF KEY(FILE_ID) THEN HDF_CLOSE, FILE_ID ;   ===> Close the HDF file
		CATCH, /CANCEL
 		RETURN, !ERROR_STATE.MSG 
	ENDIF
;	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;	===> Ensure that the file is an HDF file
;	IF HDF_ISHDF(FILE) NE 1 THEN RETURN, FILE + ' is not an HDF File'
	
;	===> Open the HDF file for reading only
  FILE_ID = HDF_OPEN(STRCOMPRESS(FILE,/REMOVE_ALL),/READ)

; ===> Get the Scientific Dataset ID from the HDF file
	SD_ID = HDF_SD_START(FILE)

; ===> Get Number of Scientific Data Sets and Number of GLOBAL Attributes
  HDF_SD_FILEINFO, SD_ID, NUMSDS, N_GLOBAL_ATTRIBUTES


;	********************************************
;	*** G L O B A L    A T T R I B U T E S   ***
;	********************************************
	
	IF N_GLOBAL_ATTRIBUTES GE 1 AND HAS(TARGETS,'GLOBAL') EQ 1 THEN BEGIN
	;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	 	FOR NTH=0L, N_GLOBAL_ATTRIBUTES-1L DO BEGIN
	 		HDF_SD_ATTRINFO, SD_ID,NTH,NAME=ATTRINFO_NAME,TYPE=ATTRINFO_TYPE,COUNT=ATTRINFO_COUNT,DATA=ATTRINFO_DATA,HDF_TYPE=ATTRINFO_HDF_TYPE
	;		===> Convert any invalid HDF attribute names (with dashes or spaces, etc) into valid IDL variable names
			ATTRINFO_NAME =  IDL_VALIDNAME(ATTRINFO_NAME,/CONVERT_ALL)
			IF N_ELEMENTS(STRUCT_GLOBAL) EQ 0 THEN BEGIN
	    	STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(ATTRINFO_NAME,ATTRINFO_DATA))
	    ENDIF ELSE BEGIN
	      STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,ATTRINFO_NAME,ATTRINFO_DATA))
	    ENDELSE
		ENDFOR ; FOR nth=0L,n_global_attributes-1L DO BEGIN
		STRUCT = CREATE_STRUCT('GLOBAL',STRUCT_GLOBAL)
		GONE, STRUCT_GLOBAL
 	ENDIF



;	**************************************************************
;	*** S C I E N T I F I C   D A T A    A T T R I B U T E S   ***
;	**************************************************************
 	IF NUMSDS GE 1 THEN BEGIN

  	FOR _NUMSDS=0, NUMSDS-1L DO BEGIN
    	ABAND = _NUMSDS
			SDS_ID=HDF_SD_SELECT(SD_ID,ABAND) ; ===> Select a Band
    	HDF_SD_GETINFO,SDS_ID,NATTS=NATTS,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE,NAME=NAME ; ===>  Get band information

			TARGET = NAME
			OK_PRODUCT 	= WHERE(STRUPCASE(TARGETS) EQ STRUPCASE(NAME),COUNT_PRODUCT)
			OK_SD 			= WHERE(STRUPCASE(TARGETS) EQ STRUPCASE('SD'),COUNT_SD)

    	IF COUNT_PRODUCT GE 1 OR COUNT_SD GE 1 THEN BEGIN 
;       ===> Fill in the band details
	      FOR NTH = 0, NATTS-1L  DO BEGIN
	        HDF_SD_ATTRINFO, SDS_ID,NTH,NAME=ATTRINFO_NAME,TYPE=ATTRINFO_TYPE,COUNT=ATTRINFO_COUNT,DATA=ATTRINFO_DATA,HDF_TYPE=ATTRINFO_HDF_TYPE
	        IF STRMID(!ERR_STRING,0,31) EQ 'HDF_SD_ATTRINFO: UNABLE TO READ' THEN BEGIN
	        	PRINT, !ERR_STRING
	         	CONTINUE
	        ENDIF
;         ===> Convert any invalid HDF attribute names (with dashes or spaces, etc) into valid IDL variable names
					ATTRINFO_NAME =  IDL_VALIDNAME(ATTRINFO_NAME,/CONVERT_ALL) 
          IF  IDLTYPE(ATTRINFO_DATA) EQ 'BYTE' THEN ATTRINFO_DATA=STRING(ATTRINFO_DATA)
	        IF NTH EQ 0 THEN _ATTRINFO = TEMPORARY(CREATE_STRUCT(ATTRINFO_NAME,ATTRINFO_DATA)) $
	                    ELSE _ATTRINFO = TEMPORARY(CREATE_STRUCT(_ATTRINFO,ATTRINFO_NAME,ATTRINFO_DATA))
	        
	      ENDFOR ; FOR nth = 0, NATTS-1L  DO BEGIN
	       
;     	===> Get the image data
      	HDF_SD_GETDATA,SDS_ID,IMAGE

;				===> Get dimensions of the IMAGE
				SZ=SIZE(IMAGE,/STRUCT)

;				===> Convert any invalid HDF names (with dashes or spaces, etc) into valid IDL variable names
				NAME =  IDL_VALIDNAME(NAME,/CONVERT_ALL)

;   		===> Make an Structure
    		IF KEY(LOOK) OR KEY(NAMES) THEN BEGIN ; ===> Fill the structure with information on the size of the image array INSTEAD of the actual image array
					TXT = 'Size is ' + STRTRIM(SZ.DIMENSIONS[0],2)
					IF SZ.N_DIMENSIONS GE 2 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS[1],2)
					IF SZ.N_DIMENSIONS EQ 3 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS(2),2)
	    		IF SZ.N_DIMENSIONS EQ 4 THEN txt = txt + ' x ' + STRTRIM(SZ.DIMENSIONS(3),2)
	    		ARR = CREATE_STRUCT(NAME,NAME,'IMAGE',TXT,_ATTRINFO)
    		ENDIF ELSE ARR = CREATE_STRUCT(NAME,NAME,'IMAGE',IMAGE,_ATTRINFO)

;       ===> REPLACE ANY _FILLVALUES WITH MISSINGS
    		IF STRUCT_HAS(ARR,'_FILLVALUE') AND NOT KEY(LOOK) AND NOT KEY(NAMES) THEN BEGIN
    		  IF IDLTYPE(ARR.IMAGE) EQ IDLTYPE(ARR._FILLVALUE) THEN OK_FILL = WHERE(ARR.IMAGE EQ ARR._FILLVALUE,COUNT_FILL) ELSE COUNT_FILL = 0
    		  IF COUNT_FILL GE 1 THEN BEGIN
    		    IMAGE[OK_FILL] = MISSINGS(IMAGE)
    		    ARR.IMAGE = TEMPORARY(IMAGE)
    		  ENDIF;IF COUNT_FILL GE 1 THEN BEGIN
    		ENDIF;IF COUNT_FILL EQ 1 THEN BEGIN

;				===> Free memory by eliminating IMAGE
				GONE,IMAGE

;   		===> Add each band to the structure
	    	IF N_ELEMENTS(STRUCT_SD) EQ 0 THEN STRUCT_SD = TEMPORARY(CREATE_STRUCT(NAME,ARR)) $
	    	                              ELSE STRUCT_SD = TEMPORARY(CREATE_STRUCT(STRUCT_SD,NAME,ARR))
	    	
;				===> Free memory by eliminating ARR
				GONE,ARR
   		ENDIF ;  	IF COUNT EQ 1 THEN BEGIN
   	ENDFOR ;   FOR _NUMSDS = 0,NUMSDS-1L DO BEGIN
;		|||||||||||||||||||||||||||||||||||||||||||||

   	IF N_ELEMENTS(STRUCT_SD) GE 1 THEN BEGIN
   		IF N_ELEMENTS(STRUCT) GE 1 THEN STRUCT = CREATE_STRUCT(STRUCT,'SD',STRUCT_SD) ELSE STRUCT = CREATE_STRUCT('SD',STRUCT_SD)
   	ENDIF

 		IF N_ELEMENTS(SDS_ID) EQ 1 THEN BEGIN
 			HDF_SD_ENDACCESS,SDS_ID
 			HDF_SD_END, SD_ID
 		ENDIF

  	ENDIF ELSE HDF_SD_END, SD_ID; IF NumSDS GE 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||

; ===> Close the HDF file
  IF N_ELEMENTS(FILE_ID) 	EQ 1 THEN HDF_CLOSE, FILE_ID
  IF N_ELEMENTS(FILE_ID)  EQ 0 THEN STOP

  ; ===> GET TAG NAMES
  IF KEY(NAMES)  THEN BEGIN
    FOR NTH = 0, N_TAGS(STRUCT) -1 DO BEGIN
      IF NONE(ALL) THEN ALL = TAG_NAMES(STRUCT.(NTH)) ELSE ALL = [ALL,TAG_NAMES(STRUCT.(NTH))]
    ENDFOR ; FOR NTH = 0, N_TAGS(STRUCT) -1 DO BEGIN
    RETURN, ALL
  ENDIF

  IF KEY(DATA) AND HAS(STRUCT,'SD') THEN BEGIN  ; CAN ONLY HAVE ONE PROD BECAUSE DATA ARRAYS ARE DIFFERENT SIZES
    OK_TAG = WHERE(TAG_NAMES(STRUCT.SD.(0)) EQ 'IMAGE',COUNT_TAG) ;===> MUST HAVE IMAGE IN THE STRUCT.SD
    IF COUNT_TAG EQ 1 THEN RETURN,STRUCT.SD.(0).(OK_TAG)
  ENDIF ; IF KEY(DATA) THEN BEGIN

  IF HAS(STRUCT_GLOBAL,'PROCESSING_LEVEL') EQ 0 THEN GOTO, DONE
  
;##############  L3B BINNED DATA  #################################
  IF N_ELEMENTS(SDS_ID) EQ 0 AND STRUCT_GLOBAL.PROCESSING_LEVEL EQ 'L3 Binned' THEN BEGIN                                             
    
    IF KEY(LOOK) THEN BEGIN
      H5_LIST, FILE, OUTPUT=OUT                      ; List the paths to the datasets contained in an HDF5 file.
      SZ = SIZE(OUT,/DIMENSIONS)                     ; Get dimensions of the output
      FOR N=0, SZ[1]-1 DO BEGIN                      ; Loop through DATASETS to get the PROD name
        S = OUT(*,N)
        IF S[0] EQ 'dataset' THEN BEGIN            
          POS = STRPOS(S[1],'/',/REVERSE_SEARCH)     ; Find the position of the PROD name
          NAME = STRMID(S[1],POS+1)
          STRUCT = CREATE_STRUCT(STRUCT,NAME,NAME)   ; Add name to the structure
        ENDIF
      ENDFOR
      H5_CLOSE
      RETURN, STRUCT
    ENDIF

    TARGETS = REPLACE(TARGETS,['GLOBAL','SD'],['',''])                                                            ; ===> REMOVE GLOBAL AND SD FROM PRODS [IF PRESENT, LEAVING TARGET AS THE COMPLEMENT [EG. CHLOR_A]
    OK = WHERE(TARGETS EQ '',COUNT)
    IF COUNT EQ N_ELEMENTS(TARGETS) THEN GOTO, DONE                                                               ; ===> SKIP READING THE L3 BINNED DATA IF ONLY REQUESTING THE GLOBAL INFORMATION
    IF COUNT GE 1 THEN TARGETS = REMOVE(TARGETS,OK)        
                                                                   
    FOR T=0, N_ELEMENTS(TARGETS)-1 DO BEGIN                                                                     
      DT = READ_L3BIN_NC(FILE, TARGETS(T),BINS=BINS,NROWS=NROWS)                           ; ===> READ THE L3 BIN FILE AND EXTRACT TARGET DATA
      IF KEY(DATA) THEN RETURN,DT
      IF NONE(STRUCT_SD) THEN STRUCT_SD = CREATE_STRUCT(TARGETS(T),CREATE_STRUCT('DATA',TEMPORARY(DT),'BINS',BINS,'NROWS',NROWS)) $
                         ELSE STRUCT_SD = CREATE_STRUCT(STRUCT_SD, CREATE_STRUCT(TARGETS(T),CREATE_STRUCT('DATA',TEMPORARY(DT),'BINS',BINS,'NROWS',NROWS)))      
      GONE, DT
    ENDFOR
  ENDIF ; IF STRPOS(STRUPCASE((FILE_PARSE(FILE)).NAME),'L3B') GE 0 THEN BEGIN
  IF STRUCT EQ [] THEN STRUCT = CREATE_STRUCT('SD', STRUCT_SD) ELSE STRUCT = CREATE_STRUCT(STRUCT, 'SD', STRUCT_SD)

  DONE:
  GONE,STRUCT_GLOBAL
  GONE,STRUCT_SD
  GONE,BINS
  GONE,NROWS
  
  IF N_ELEMENTS(STRUCT) EQ 0 THEN RETURN,'ERROR: NONE OF THE REQUESTED PRODS WERE FOUND IN THE NC FILE'
  RETURN, STRUCT

END; #####################  End of Routine ################################


