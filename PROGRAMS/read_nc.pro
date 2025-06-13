; $ID:	READ_NC.PRO,	2021-11-08-17,	USER-KJWH	$
;#################################################################################################################
FUNCTION READ_NC, FILE, PRODS=PRODS, HDF5=HDF5, BINS=BINS, LOOK=LOOK, DATA=DATA, STRUCT=STRUCT, NAMES=NAMES, GLOBAL=GLOBAL, INFO=INFO, VERBOSE=VERBOSE

;+
; NAME: READ_NC
;
; PURPOSE:	READ A SEADAS NETCDF FILE AND RETURNS THE INFORMATION IN A STRUCTURE

; EXAMPLES:
;
;
; PARAMETERS:
;						FILE (INPUT: AN NETCDF FILE CONTAINING GLOBAL AND/OR SD SCIENTIFIC DATA SETS)
;
; KEYWORDS:
;     PRODS: 	THE PRODS IN THE NETCDF THAT YOU WANT (E.G. PRODS = 'CHLOR_A' OR PRODS = 'GLOBAL', OR PRODS='SD')
;						  PRODS = 'SD'    		TO EXTRACT ALL SCIENTIFIC DATASETS
;							PRODS = 'GLOBAL' 	TO EXTRACT THE GLOBAL ATTRIBUTES
;							PRODS = ['GLOBAL','SD'] TO EXTRACT BOTH GLOBAL AND SD INTO AN IDL STRUCTURE
;             IF PRODS ARE NOT PROVIDED THEN ALL GLOBAL AND SD SCIENTIFIC DATA PRODS 
;             IN THE NETCDF FILE ARE RETURNED IN A STRUCTURE
;     HDF5:   USE THIS KEYWORD TO FORCE IT TO READ THE FILE USING H5xxx ROUTINES
;			LOOK:		RETURNS INFORMATION ON THE SIZE AND DATA TYPES OF THE SD IMAGE DATA ARRAYS BUT NOT THE ACTUAL DATA.
;							THIS IS USEFUL FOR EXPLORING NETCDFS WITH LARGE IMAGE ARRAYS.
;
;     DATA:     RETURN THE DATA ARRAY INSTEAD OF THE COMPLETE STRUCTURE
;     NAMES:    RETURN THE NAMES OF ALL SD PRODS IN THE NC FILE
;     VERBOSE:  PRINT INFO
;
; OUTPUTS:
;       A NESTED STRUCTURE, USUALLY WITH THE IMAGE ARRAY AND RELATED INFORMATION
;       GLOBAL: Optional output structure of the global data
;
; EXAMPLE: [COPY FOLLOWING BLOCK INTO NEW FILE,HIGHLIGHT,TOGGLE TO UNCOMMENT,  AND RUN]
;          FILE_NC = FIRST(FLS(!S.DATASETS +'OC_OCTS\L3','*.NC'))
;          D = READ_NC(FILE_NC,PRODS = 'CHLOR_A',/DATA) & ST,D
;          FILE = !S.IDL_TEMP + (FILE_PARSE(FILE_NC)).NAME + '.SAV'
;          STRUCT_WRITE,D,FILE = FILE
;          S = STRUCT_READ(FILE)& P,MM(S);
;          L3B EXAMPLE >       
;          FILE = !S.DATASETS+ 'OC_OCTS\L3\' + "O1997003.L3b_DAY_CHL.nc"
;          DATA = READ_NC(FILE,PRODS= ['chlor_a','GLOBAL','SD'],/DATA,STRUCT=STRUCT)
;          ST,STRUCT & P,MM(DATA)
;          
;	RESTRICTIONS:
;				MEMORY LIMITATIONS MAY PREVENT THE READING OF ALL DATA IN THE NETCDF FILE 
;				AND RETURNING A LARGE STRUCTURE
;				IF SO ... THEN MAKE SEVERAL CALLS, EACH TIME	REQUESTING JUST SOME OF THE PRODS
;
;			  THIS PROGRAM WILL RENAME THE ORIGINAL NETCDF TAG NAMES TO 
;				VALID IDL TAG NAMES WHEN THE NETCDF NAMES CONTAIN CHARACTERS SUCH AS DASHES '-' 
;				OR SPACES, ETC. WHICH ARE NOT COMPATIBLE WITH IDL'S NAMING SCHEME FOR VARIABLES.
;				
;				THIS PROGRAM READS THE GLOBAL ATTRIBUTES AND THE SCIENTIFIC DATA (SD) 
;				IN THE NETCDF FILE BUT NOT OTHER NETCDF TYPES
;				SUCH AS VGROUPS AND VDATA (E.G. AS IN SEAWIFS L3B FILES 
;				WHICH ARE READ USING A SEPARATE IDL NETCDF PROGRAM DESIGNED FOR L3BIN NETCDF FILES).
;

;MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, JAN, 1997.
;       MODIFIED: 
;       APR 09, 1999 - JOR:  ADDED MAX_ATTR
;       JUN 01, 2000 - JOR:  MODIFED PRODS FROM INTEGER TO SEADAS PRODUCT NAMES (E.G. NLW443, CHLOR_A, ETC).
;				APR 25, 2002 - JOR:  CHANGED MAX_ATTR FROM 15 TO THE DETERMINED NUMBER OF ATTR IN THE NETCDF FILE
;				AUG 10, 2003 - JOR:  ADDED CAPABILITY TO READ NASA JPL PATHFINDER FILES
;				SEP 19, 2006 - JOR:  REMOVED ROTATE IMAGE (FLIP)
;				MAY 29, 2014 - JOR:  PICKFILE(FILTER = '*.NC')
;				JAN 04, 2015 - JOR:  NO LONGER CHANGING DIRECTORY TO THE NCDF FILE DIR[NOT NEEDED]
;				                     PRODUCTS CHANGED TO PRODS
;				                     DIALOG_PICKFILE NOW USED
;				                     REMOVED ERROR,ERR_MSG [NOT NEEDED SINCE THE ERROR STRING IS NOW RETURNED:
;				                     RETURN,!ERROR_STATE.MSG
;                            IF N_ELEMENTS(STRUCT) EQ 0 THEN RETURN,'ERROR: NONE OF THE REQUESTED PRODS WERE FOUND IN THE NC FILE'
;                            ADDED KEYS DATA,NAMES, AUTOMATICALLY CHANGE _FILLVALUE [USUALLY -32767] TO MISSINGS
;                            IF HAS(STRUPCASE((FILE_PARSE(FILE)).NAME),STRUPCASE('L3M')) THEN  BEGIN [FLIP IMAGE]
;                            RENAMED TO READ_NC FOR BREVITY
;       FEB 03, 2015 - JOR:  ADDED CAPABILITY TO READL3-BINNED NC FILES 
;       FEB 04, 2015 - KJWH: FIXED PROBLEMS IN THE L3BIN SECTION
;                            ADDED BINS OUTPUT KEYWORD
;       JUN 03, 2015 - KJWH: FIXED BUG IN L3BIN SECTION - CHANGED PRODS TO TARGETS
;       JUN 03, 2015 -  JOR: FIXED ERROR IN L3BIN SECTION ANDSIMPLIFIED LOGIC:
;                            TARGETS = REPLACE(TARGETS,['GLOBAL','SD'],['',''])
;                            OK = WHERE(TARGETS EQ '',COUNT) & IF COUNT GE 1 THEN TARGET = REMOVE(TARGETS,OK)
;                            IF STRUPCASE(TARGET) NE VALIDS('PRODS',TARGET) THEN MESSAGE,'ERROR:TARGET NOT A VALID PROD'
;       JUN 08, 2015 - KJWH: ADDED STEPS TO READ L2 FILES USING READ_HDF_L2
;       JUL 16, 2015 - KJWH: IF ONLY THE 'GLOBAL' DATA IS REQUESTED, SKIP READING THE DATASETS IN THE READ_HDF5_L2 STEP
;       AUG 06, 2015 -  JOR: IF ISA(ARR.IMAGE,/ARRAY)THEN ARR.IMAGE = ROTATE(ARR.IMAGE,7)
;                            IF NOT KEY(LOOK) THEN OK_FILL = WHERE(ARR.IMAGE EQ FILLVALUE,COUNT_FILL)
;       AUG 06, 2015 - KJWH: ADDED CHECKS TO LOOK FOR THE PROCESSING LEVEL (STRUCT.GLOBAL.PROCESSING_LEVEL) BEFORE STEPPING INTO THE L2 AND L3BINNED PROCESSING BLOCKS
;       AUG 06, 2015 - JOR:  ADDED THE KEYWORD INFO TO LOOK AT THE DATASETS AND VARIABLES IN THE FILE
;       AUG 07, 2015 - KJWH: FIXED THE BUG IN THE "IF KEY(INFO) THEN BEGIN" BLOCK AND ADDED NCDF_LIST FOR ACTUAL NETCDF (VS HDF5) FILES.
;                            ADDED "IF HAS(STRUCT.GLOBAL,'PROCESSING_LEVEL') EQ 0 THEN GOTO, DONE" FOR NON-SEADAS GENERATED FILES.
;                            FIXED BUGS IN THE _FILLVALUE BLOCK.
;                            MOVED "IF KEY(NAMES) THEN BEGIN" BLOCK UP AND NOW NOT EXTRACTING THE .IMAGE DATA IF /NAMES IS SET
;       AUG 08, 2015 - JOR:  CHANGED INFO= NCDF_INQUIRE(FILE_ID) TO INF= NCDF_INQUIRE(FILE_ID) TO AVOID CONFUSION WITH KEYWORD INFO
;       AUG 11, 2015 - KJWH: UPDATED L3BIN BLOCK SO THAT IT WILL SKIP THE READL3BIN_NC STEP IF ONLY REQUESTING THE GLOBAL PRODUCT
;                            AFTER CLOSING THE NC FILE, REMOVE THE FILE_ID (GONE, FILE_ID) TO PREVENT ERRORS IN THE CATCH BLOCK WHEN IT TRIES TO CLOSE A FILE THAT IS ALREADY CLOSED
;                            ALWAYS READ THE GLOBAL INFO IF AVAILABLE BECAUSE THE ATTRIBUTES ARE USED LATER TO DETERMINE HOW TO READ THE OTHER DATA
;       AUG 12, 2015 - KJWH: ADDED KEY(LOOK) BLOCK TO THE L3 BINNED BLOCK
;                            REMOVED - IF STRUPCASE(TARGETS) NE VALIDS('PRODS',TARGETS) THEN MESSAGE,'ERROR:TARGET NOT A VALID PROD' BECAUSE THE .NC TARGET MAY NOT EXACTLY MATCH OUR VALID PRODS
;       AUG 16,2015  -  JOR: IMAGE(OK_FILL) = MISSINGS(IMAGE)
;                            ARR.IMAGE = TEMPORARY(IMAGE) 
;                            REPLACED DATATYPE ROUTINE WITH IDLTYPE[FASTER] 
;       OCT 01,2015  -  JOR: GONE,STRUCT_GLOBAL & GONE,LON & GONE,LAT & GONE,BINS & GONE,NOBS & GONE,WTS
;                            STRUCT = CREATE_STRUCT(TARGETS,TEMPORARY(DT))
;       OCT 02, 2015 - KJWH: ADDED H5_CLOSE TO COMPLETELY CLOSE ANY OPEN HDF5 FILES
;       NOV 23, 2015 - KJWH: REMOVED MAX_ATTR KEYWORD BECAUSE IT IS NEVER USED
;                            NOW LOOPING THROUGH PRODS FOR THE L3BINNED FILES TO CREATE A SD STRUCTURE  
;                            CHANGED HAS_TAG TO STRUCT_HAS   
;       NOV 30, 2015 - KJWH: MOVED [IF STRUCT EQ [] THEN STRUCT = CREATE_STRUCT('SD', STRUCT_SD) ELSE STRUCT = CREATE_STRUCT(STRUCT, 'SD', STRUCT_SD)]
;                              TO BE WITHIN THE 'L3B' BLOCK  
;       DEC 03, 2015 - KJWH: ADDED THE KEYWORD LOOK TO THE READ_HDF5_L2() CALL         
;       APR 19, 2016 - KWJH: CHANGED "IMAGE" TO "IMG"  
;       JUL 27, 2016 - KJWH: NOW GETTING THE FILE PRODUCTS IN THE L3B FILES TO MATCH WITH THE PRODUCT TARGETS 
;                            (PREVIOUSLY THE PROGRAM WOULD RETURN AN ERROR IF ONE OF THE TARGET PRODUCTS WAS NOT IN THE FILE)        
;       AUG 09, 2016 - KJWH: ADDED THE "GLOBAL" KEYWORD AS AN OPTIONAL OUTPUT STRUCTURE   
;       AUG 23, 2016 - KJWH: ADDED THE ABILITY TO READ ADDITIONAL "GLOBAL" INFORMATION FROM THE HDF5 FILES 
;       AUG 24, 2016 - KJWH: Changed H5_LIST to H5_PARSE to get the attribute information in the file       
;       AUG 25, 2016 - KJWH: Now distinguishing between NETCDF and HDF5 files and running separate blocks of code to derive the GLOBAL and SD products [MAJOR OVERHAUL]
;                            NEED TO DO MORE TESTING WITH THE NETCDF FILES   
;                            Removed FLIP=0     
;       AUG 26, 2016 - KJWH: Updated some documentation and functionalities        
;       AUG 28, 2016 - KJWH: Added GONE, FILE_ID after closing the netcdf      
;                            Added GONE, H5ID after closing the hdf5    
;                            Added H5F_CLOSE to the CATCH error block   
;                            Fixed the case of the TARGETS      
;       AUG 29, 2016 - KJWH: Updated the KEY(NAMES) block for the netcdf files (using NCDF_LIST, VNAME=VNAME)    
;       AUG 30, 2016 - KJWH: Fixed the /DATA return for L3B HDF5 files   
;       OCT 03, 2016 - KJHW: In the N_SD gt 0 block: if no targets are given as an input, will now return all prods in the SD    
;       NOV 15, 2016 - KJHW: Added a step to make sure STRUCT_GLOBAL was not [] before adding it to the output structure
;       NOV 23, 2017 - JEOR: Fixed severe memory leak due to returning data before closing using NCDF_CLOSE
;                            Moved NCDF_CLOSE before RETURN,STRUCT.SD.(0).(OK_TAG)  
;                            NCDF_CLOSE, FILE_ID &   ; ===> CLOSE THE NC FILE AND REMOVE THE FILE_ID
;                            Kim, I dont know if other NCDF_CLOSE are needed [for  returns when using HDF5]?
;       NOV 28, 2017 - KJWH: Moved the ENDIF statement JEOR added to be immediately following the NCDF_CLOSE and RETURN, 'ERROR...' statement
;       FEB 22, 2018 - KJWH: Added IF ANY(FILE_ID) THEN NCDF_CLOSE, FILE_ID at the end of the program as a check to make sure the netcdf file was closed.
;       MAR 07, 2018 - KJWH: Added IF NONE(PRODS) AND KEY(GLOBAL) THEN PRODS = 'GLOBAL' to just return the GLOBAL structure if the GLOBAL keyword is set and not PRODS are given
;                            Now including the INPUT_PARAMETERS (from L2 SeaDAS produced files) as part of the GLOBAL structure
;                              IP = H5_GET_INPUT_PARAMETERS(FILE, LOOK=LOOK)
;                              IF IP NE [] THEN STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,'INPUT_PARAMETERS',IP))
;       MAR 15, 2018 - KJWH: Added 'qualityDim' to the list of TARGETS to remove when reading L3 Binned data   
;       OCT 05, 2018 - KJWH: Added: IF ANY(H5ID)    THEN H5F_CLOSE,  H5ID    & GONE, H5ID
;                                   IF ANY(GID)     THEN H5G_CLOSE,  GID     & GONE, GID   
;                            *** There is still a possible memory leak with a file not being properly closed       
;       APR 23, 2020 - KJWH: Added a FILE_TEST step to make sure the file exists.  If not, print error message and return a null [] variable
;                            If more than one file is provided, now print the error and return a null [] variable     
;       APR 27, 2021 - KJWH: Discovered a bug when using the /NAMES keyword with NASA L2BIN files
;                              Now if NCDF_LIST does not provide "name" information, then the program will read the file and return the tagnames of the SD structure                                        
;       NOV 08, 2021 - KJWH: Added a step to look for duplicate tagnames in the global structure (e.g. 'history' and 'History' in the OC-CCI 1KM files) and rename by adding a '_1' to the second tag name
;##############################################################################################################
;-

;	===> INITIALIZE
;*************************
  ROUTINE_NAME = 'READ_NC'
;*************************
  
  STRUCT = [] ; Create a NULL structure for the output  

;===> IF SPECIFIC PRODS ARE NOT REQUESTED THEN RETURN GLOBAL AND SD INFO
  IF NONE(PRODS) AND KEY(GLOBAL) THEN PRODS = 'GLOBAL'
  IF NONE(PRODS) THEN TARGETS = ['GLOBAL','SD'] ELSE TARGETS = PRODS
  IF NONE(FILE)  THEN FILE = DIALOG_PICKFILE(FILTER='*.*')
  IF N_ELEMENTS(FILE) NE 1 THEN BEGIN
    PRINT, 'ERROR: Only 1 file can be read at a time.'
    RETURN, []
  ENDIF
  IF FILE_TEST(FILE) EQ 0 THEN BEGIN
    PRINT, 'ERROR: ' + FILE + ' does not exist'
    RETURN, []
  ENDIF
  

; ***********************************
; ***** N E T C D F   F I L E S *****
; ***********************************
; ===> READ AND EXTRACT THE GLOBAL AND SD INFO FROM THE NETCDF FILES
  IF ~KEY(HDF5) THEN BEGIN
	  IF KEY(NAMES) THEN BEGIN
	   NCDF_LIST, FILE, OUT=INFO,/QUIET
	   VARS = STRMID(INFO[3],STRPOS(INFO[3],' ',/REVERSE_SEARCH))
	   IF VARS GT 0 THEN NCDF_LIST, FILE, OUT=INFO,/QUIET,/VARIABLES,VNAME=VNAME ELSE BEGIN
	     DV = READ_NC(FILE)
	     VNAME = TAG_NAMES(DV.SD)
	   ENDELSE
	   RETURN, VNAME
	  ENDIF
	  ;===> RETURN INFO FROM THE NC (HDF5) FILE
	  IF KEY(INFO) THEN BEGIN
	    NCDF_LIST, FILE, OUT=INFO, /QUIET, /VARIABLES, /DIMENSIONS   ; Lists the variables and attributes in a NetCDF file
	    RETURN, STRTRIM(STRCOMPRESS(INFO),2)
	  ENDIF;IF KEY(INFO) THEN BEGIN
	  
	  FILE_ID = NCDF_OPEN(STRCOMPRESS(FILE,/REMOVE_ALL),/NOWRITE)                             ; ===> Open the netcdf file for reading
    INF= NCDF_INQUIRE(FILE_ID)                                                              ; ===> Get number of scientific data sets and global attributes
    N_GLOBAL_ATTRIBUTES = INF.NGATTS                                                        ; ===> Number of global attributes at the top level
    N_SDS =INF.NVARS                                                                        ; ===> Number of datasets
    
; ===> GLOBAL ATTRIBUTES
    STRUCT_GLOBAL = []                                                                      ; ===> Create a null variable for the structure
    FOR NTH=0L,N_GLOBAL_ATTRIBUTES-1L DO BEGIN                                              ; ===> Loop through the attributes and add the information to the GLOBAL structure
      ATTRINFO_NAME = NCDF_ATTNAME(FILE_ID, /GLOBAL, NTH)                                   ; ===> Get the attribute name
    	INQ = NCDF_ATTINQ(FILE_ID,ATTRINFO_NAME, /GLOBAL)                                     ; ===> Get info about the attribute
    	NCDF_ATTGET,FILE_ID, ATTRINFO_NAME, ATTRINFO_DATA,/GLOBAL                             ; ===> Get the data in the attribute
    	IF INQ.DATATYPE EQ 'CHAR' THEN  ATTRINFO_DATA = STRING(ATTRINFO_DATA)                 ; ===> Make sure the data is a STRING	    
    	ATTRINFO_NAME =  IDL_VALIDNAME(ATTRINFO_NAME,/CONVERT_ALL)                            ; ===> Convert any invalid ncdf attribute names into valid idl variable names
    	IF NTH GT 0 THEN IF HAS(TAG_NAMES(STRUCT_GLOBAL),ATTRINFO_NAME) THEN ATTRINFO_NAME = ATTRINFO_NAME + '_1'  ; ===> Check to see if there are duplicate tag names and if so, add '_1' to the tagname in the global structure
    	STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,ATTRINFO_NAME,ATTRINFO_DATA))   ; ===> Add attributes to the GLOBAL structure
    ENDFOR ; FOR NTH=0L,N_GLOBAL_ATTRIBUTES-1L DO BEGIN
    IF N_SDS EQ 0 THEN BEGIN
      IP = H5_GET_INPUT_PARAMETERS(FILE, LOOK=LOOK)
      IF IP NE [] THEN STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,'INPUT_PARAMETERS',IP))       
    ENDIF
    
    GLOBAL = STRUCT_GLOBAL                                                                  ; ===> GLOBAL variable to be returned as a separate structure
    IF HAS(TARGETS,'GLOBAL') AND STRUCT_GLOBAL NE [] THEN STRUCT = CREATE_STRUCT('GLOBAL',STRUCT_GLOBAL)            ; ===> If requested, add the GLOBAL info to the output structure 
    IF N_ELEMENTS(TARGETS) EQ 1 AND TARGETS[0] EQ 'GLOBAL' THEN GOTO, DONE                  ; ===> Skip if only requesting global
  
; ===> SCIENTIFIC DATA
    STRUCT_SD = []
    IF N_SDS EQ 0 THEN GOTO, READ_AS_HDF5                                                   ; ===> If no SD variables found, then read the file using HDF5 programs (which are slower than the netcdf programs)
    NCDF_LIST, FILE, OUT=INFO,/QUIET,/VARIABLES,VNAME=SDS_NAMES                             ; ===> Get the list of SD variables in the file
    TARGETS = REPLACE(TARGETS,['GLOBAL','SD'],['',''])                                      ; ===> Remove global and sd from prods [if present, leaving target as the complement [eg. chlor_a]
    TARGETS = REMOVE(TARGETS,WHERE(TARGETS EQ ''))                                          ; ===> Remove any blank ('') targets
    IF N_ELEMENTS(TARGETS) EQ 0 THEN TARGETS = SDS_NAMES                                    ; ===> If no targets provided, get all SD prods
    OK = WHERE_MATCH(STRUPCASE(SDS_NAMES),STRUPCASE(TARGETS),COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)
    IF COUNT EQ 0 THEN BEGIN
      NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                                                  ; ===> Close the NCDF file
      RETURN, 'ERROR: Products (' + TARGETS + ') not found in FILE - ' + FILE
    ENDIF;IF COUNT EQ 0 THEN BEGIN
    TARGETS = SDS_NAMES[OK]
      
    FILE_ID = NCDF_OPEN(STRCOMPRESS(FILE,/REMOVE_ALL),/NOWRITE)                             ; ===> Open the netcdf file for reading
    FOR NSDS=0, N_SDS-1L DO BEGIN
      INQ = NCDF_VARINQ(FILE_ID, NSDS)
      NAME=INQ.NAME
      NATTS=INQ.NATTS
      VAR_ID = NCDF_VARID(FILE_ID, NAME)
      
      OK_PROD = WHERE(STRUPCASE(TARGETS) EQ STRUPCASE(NAME),COUNT_PROD)     
      IF COUNT_PROD GE 1 THEN BEGIN
        _ATTRINFO = []
        FOR NTH=0, NATTS-1L  DO BEGIN ;       ===> FILL IN THE BAND DETAILS
          ATTRINFO_NAME = NCDF_ATTNAME(FILE_ID,NSDS,NTH)
          IF STRMID(!ERR_STRING,0,31) EQ 'NC_SD_ATTRINFO: UNABLE TO READ' THEN BEGIN
            PRINT, !ERR_STRING
            CONTINUE
          ENDIF
          NCDF_ATTGET, FILE_ID, VAR_ID, ATTRINFO_NAME, ATTRINFO_DATA                       ; ===> Get the attribute name and data
          ATTRINFO_NAME = IDL_VALIDNAME(ATTRINFO_NAME,/CONVERT_ALL)                        ; ===> Convert any invalid nc attribute names (with dashes or spaces, etc) into valid idl variable names
          IF IDLTYPE(ATTRINFO_DATA) EQ 'BYTE' THEN ATTRINFO_DATA=STRING(ATTRINFO_DATA)
          _ATTRINFO = TEMPORARY(CREATE_STRUCT(_ATTRINFO,ATTRINFO_NAME,ATTRINFO_DATA))
        ENDFOR ; FOR NTH = 0, NATTS-1L  DO BEGIN
          
        NCDF_VARGET, FILE_ID, NSDS, IMG           ; ===> GET THE IMAGE DATA
        SZ=SIZE(IMG,/STRUCT)                      ; ===> GET DIMENSIONS OF THE IMAGE
        NAME =  IDL_VALIDNAME(NAME,/CONVERT_ALL)  ; ===> CONVERT ANY INVALID NC NAMES (WITH DASHES OR SPACES, ETC) INTO VALID IDL VARIABLE NAMES

        IF KEY(LOOK) OR KEY(NAMES) THEN BEGIN ; ===> FILL THE STRUCTURE WITH INFORMATION ON THE SIZE OF THE IMAGE ARRAY INSTEAD OF THE ACTUAL IMAGE ARRAY
          TXT = 'ARRAY SIZE IS ' + STRTRIM(SZ.DIMENSIONS[0],2)
          FOR SZN=1, SZ.N_DIMENSIONS-1 DO TXT = TXT + ' X ' + ROUNDS(SZ.DIMENSIONS(SZN))
          ARR = CREATE_STRUCT(NAME,NAME,'IMAGE',TXT,_ATTRINFO)
        ENDIF ELSE ARR = CREATE_STRUCT(NAME,NAME,'IMAGE',IMG,_ATTRINFO)

;       ===> REPLACE ANY _FILLVALUES WITH MISSINGS
        IF STRUCT_HAS(ARR,'_FILLVALUE') AND NOT KEY(LOOK) AND NOT KEY(NAMES) THEN BEGIN
          IF IDLTYPE(ARR.IMAGE) EQ IDLTYPE(ARR._FILLVALUE) THEN OK_FILL = WHERE(ARR.IMAGE EQ ARR._FILLVALUE,COUNT_FILL) ELSE COUNT_FILL = 0
          IF COUNT_FILL GE 1 THEN BEGIN
            IMG[OK_FILL] = MISSINGS(IMG)
            ARR.IMAGE = TEMPORARY(IMG)
            ; ARR.IMAGE[OK_FILL] = MISSINGS(ARR.IMAGE[OK_FILL])
          ENDIF;IF COUNT_FILL GE 1 THEN BEGIN
        ENDIF;IF COUNT_FILL EQ 1 THEN BEGIN
  
        GONE,IMG                                                    ; ===> FREE MEMORY BY ELIMINATING IMAGE
        STRUCT_SD = TEMPORARY(CREATE_STRUCT(STRUCT_SD,NAME,ARR))    ; ===> ADD EACH BAND TO THE STRUCTURE
        GONE,ARR  & GONE,_ATTRINFO                                  ; ===> FREE MEMORY
      ENDIF ;   IF COUNT EQ 1 THEN BEGIN
    ENDFOR ; FOR NSDS = 0,N_SDS-1L DO BEGIN
  
    STRUCT = CREATE_STRUCT(STRUCT,'SD',STRUCT_SD) 
    IF KEY(DATA) AND HAS(STRUCT,'SD') THEN BEGIN                    ; ===> CAN ONLY HAVE ONE PROD BECAUSE DATA ARRAYS ARE DIFFERENT SIZES
      SD_PRODS = TAG_NAMES(STRUCT.SD)
      IF N_ELEMENTS(SD_PRODS) GT 1 THEN BEGIN
        NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                        ; ===> Close the NCDF file
        RETURN, 'ERROR: CAN ONLY PROVIDE 1 PROD IF KEYWORD DATA IS SET'
      ENDIF;IF N_ELEMENTS(SD_PRODS) GT 1 THEN BEGIN
      OK_TAG = WHERE(TAG_NAMES(STRUCT.SD.(0)) EQ 'IMAGE',COUNT_TAG) ; ===> MUST HAVE IMAGE IN THE STRUCT.SD
      IF COUNT_TAG EQ 1 THEN BEGIN
        NCDF_CLOSE, FILE_ID &  & GONE, FILE_ID                      ; ===> CLOSE THE NC FILE AND REMOVE THE FILE_ID [TO PREVENT SYSTEM MEMORY LEAK/LOSS]
        RETURN,STRUCT.SD.(0).(OK_TAG) 
      ENDIF ELSE BEGIN
        NCDF_CLOSE, FILE_ID &  & GONE, FILE_ID                      ; ===> CLOSE THE NC FILE AND REMOVE THE FILE_ID [TO PREVENT SYSTEM MEMORY LEAK/LOSS]
        RETURN, 'ERROR: IMAGE DATA NOT FOUND FOR PRODUCT' + NAME + ' IN FILE ' + FILE
      ENDELSE;IF COUNT_TAG EQ 1 THEN BEGIN
    ENDIF ; IF KEY(DATA) THEN BEGIN
    
        
  ENDIF ; NCDF_IS_NCDF(FILE)
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  


; ***********************************
; ***** H D F 5    F I L E S *****
; ***********************************  
  IF STRUCT_SD EQ [] OR KEY(HDF5) THEN BEGIN
    IF H5F_IS_HDF5(FILE) EQ 1 THEN BEGIN 
      IF KEY(NAMES) THEN BEGIN
        RETURN, H5_GET_DATA(FILE,/LOOK)                                                         ; ===> Return the dataset names in the nc (hdf5) file
      ENDIF
      IF KEY(INFO)  THEN BEGIN
        NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                                                    ; ===> Close the NCDF file
        RETURN, H5_PARSE(FILE)                                                                  ; ===> Return the list the attributes and datasets in a HDF5 file
      ENDIF  
      IF KEY(LOOK)  THEN BEGIN                                                                  ; ===> Return the info on the geophysical data
        H5P = H5_PARSE(FILE)
        IF HAS(H5P,'GEOPHYSICAL_DATA') EQ 0 AND HAS(H5P, 'LEVEL_3_BINNED_DATA') EQ 0 THEN BEGIN
          NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                                                  ; ===> Close the NCDF file
          RETURN, 'ERROR: No geophyscial data found in FILE - ' + FILE
        ENDIF  
        IF HAS(H5P, 'GEOPHYSICAL_DATA') THEN GD = H5P.GEOPHYSICAL_DATA ELSE GD = H5P.LEVEL_3_BINNED_DATA
        TARGETS = REPLACE(TARGETS,['GLOBAL','SD'],['',''])                                      ; ===> Remove global and sd from prods [if present, leaving target as the complement [eg. chlor_a]
        TARGETS = REMOVE(TARGETS,WHERE(TARGETS EQ ''))                                          ; ===> Remove any blank ('') targets
        IF TARGETS EQ [] THEN TARGETS = 'SD'                                                    ; ===> If no targets provided, get all prods
        OK = WHERE_MATCH(STRUPCASE(TAG_NAMES(GD)),STRUPCASE(TARGETS),COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)
        IF COUNT GE 1 THEN GD = STRUCT_COPY(GD,TAGS=OK)
        NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                                                    ; ===> Close the NCDF file
        RETURN, GD
      ENDIF
      
  ; ===> GET GLOBAL ATTRIBUTES FOR THE HDF5 FILES      
      STRUCT_GLOBAL = []                                                                      ; ===> Create a null variable for the structure
      H5ID = H5F_OPEN(STRCOMPRESS(FILE,/REMOVE_ALL))                                          ; ===> Get the HDF5 id
      NATT = H5A_GET_NUM_ATTRS(H5ID)                                                          ; ===> Look for ATTRIBUTES within top level of the HDF5 file
      FOR ATH=0, NATT-1 DO BEGIN                                                              ; ===> Loop through ATTRIBUTES
        ATTID = H5A_OPEN_IDX(H5ID,ATH)                                                        ; ===> Get the ATTRIBUTE id
        ATTRINFO_NAME = IDL_VALIDNAME(H5A_GET_NAME(ATTID))                                    ; ===> Get the ATTRIBUTE name
        ATTRINFO_DATA = H5A_READ(ATTID)                                                       ; ===> Read the information in the ATTRIBUTE
        H5A_CLOSE, ATTID                                                                      ; ===> Close the ATTRIBUTE
        STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,ATTRINFO_NAME,ATTRINFO_DATA))   ; ===> Add attributes to the GLOBAL structure
      ENDFOR ; NATT
      H5_LIST, FILE, FILTER='group', OUTPUT=GRP                                               ; ===> Look for "group" tags that may have additional attributes
      FOR NTH=0L, N_ELEMENTS(GRP(0,*))-1 DO BEGIN                                             ; ===> Loop through the "groups"
        IF GRP(0,NTH) NE 'group' THEN CONTINUE                                                ; ===> The first element is often the "file"
        GNAME = REPLACE(GRP(1,NTH),'/','')                                                    ; ===> Get the name of the group
        GSTRUCT = []                                                                          ; ===> Create a null variable for the group structure
        GID = H5G_OPEN(H5ID,GRP(1,NTH))                                                       ; ===> Get the GROUP id
        NATT = H5A_GET_NUM_ATTRS(GID)                                                         ; ===> Look for ATTRIBUTES within top level of the HDF5 file
        FOR ATH=0, NATT-1 DO BEGIN                                                            ; ===> Loop through ATTRIBUTES
          ATTID = H5A_OPEN_IDX(GID,ATH)                                                       ; ===> Get the ATTRIBUTE id
          ATTRINFO_NAME = IDL_VALIDNAME(H5A_GET_NAME(ATTID))                                  ; ===> Get the ATTRIBUTE name
          ATTRINFO_DATA = H5A_READ(ATTID)                                                     ; ===> Read the information in the ATTRIBUTE
          H5A_CLOSE, ATTID                                                                    ; ===> Close the ATTRIBUTE
          GSTRUCT = TEMPORARY(CREATE_STRUCT(GSTRUCT,ATTRINFO_NAME,ATTRINFO_DATA))             ; ===> Add attributes to the group structure
        ENDFOR ; NATT    
        H5G_CLOSE, GID & GONE, GID                                                            ; ===> Close the GROUP 
        IF GSTRUCT NE []THEN STRUCT_GLOBAL = TEMPORARY(CREATE_STRUCT(STRUCT_GLOBAL,GNAME,GSTRUCT)) ; ===> Adde the group structure to the GLOBAL structure 
      ENDFOR ; GRP
      H5F_CLOSE, H5ID & GONE, H5ID 
      
      GLOBAL = STRUCT_GLOBAL                                                                  ; ===> Create a GLOBAL variable to be returned as a separate structure
      STRUCT = []                                                                             ; ===> Create null struct variable
      IF HAS(TARGETS,'GLOBAL') THEN STRUCT = CREATE_STRUCT('GLOBAL',STRUCT_GLOBAL)            ; ===> Add the GLOBAL structure if requested
      IF N_ELEMENTS(TARGETS) EQ 1 AND TARGETS[0] EQ 'GLOBAL' THEN GOTO, DONE                  ; ===> Skip if only requesting global
      
      
      READ_AS_HDF5:
      TARGETS = REPLACE(TARGETS,['GLOBAL','SD'],['',''])                                      ; ===> Remove global and sd from prods [if present, leaving target as the complement [eg. chlor_a]
      TARGETS = REMOVE(TARGETS,WHERE(TARGETS EQ ''))                                          ; ===> Remove any blank ('') targets
      H5NAMES = H5_GET_DATA(FILE,/LOOK)                                                       ; ===> Generate a list of PROD names
 
 ; Work around for when there are duplicate H5NAMES in the netcdf file (note, the duplicates are likely in separate nested structures)
 bb = where_sets(h5names)         ; look for sets of names
 ok = where(bb.n gt 1, count_bb)  ; check to see if there are any replicates
 if count_bb gt 0 then begin
   dup = bb[where(bb.n gt 1)]     ; create a temporary duplicate set
   ok = where(dup.value ne 'number_of_lines' and dup.value ne 'pixels_per_line',count_dup)    ; check the duplicate values for unknown duplicates.  
   if count_dup gt 0 then message, 'error: unrecognized duplicate name in the file structure' ; as of 3/13/20 only two duplicates have been observed in the NOAA VIIRS msl12 data files
   h5names = bb.value             ; create a new list of h5names without the duplicates
 endif      
      
      IF N_ELEMENTS(TARGETS) EQ 0 THEN TARGETS = H5NAMES                                      ; ===> If no targets provided, get all SD prods
      OK = WHERE_MATCH(STRUPCASE(H5NAMES),STRUPCASE(TARGETS),COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)
      IF COUNT EQ 0 THEN BEGIN
        NCDF_CLOSE, FILE_ID  & GONE, FILE_ID                                                  ; ===> Close the NCDF file
        IF ANY(H5ID)    THEN H5F_CLOSE,  H5ID    & GONE, H5ID
        IF ANY(GID)     THEN H5G_CLOSE,  GID     & GONE, GID                                                
        RETURN, 'ERROR: Products (' + TARGETS + ') not found in FILE - ' + FILE
      ENDIF;IF COUNT EQ 0 THEN BEGIN
      TARGETS = H5NAMES[OK]                                                                   ; ===> Use the case sensitive H5 name
      SD = []    
      DATA_TAG = 'IMAGE'
      
      ;##############  L3B BINNED DATA  #################################
      IF HAS(STRUCT_GLOBAL,'PROCESSING_LEVEL') EQ 1 THEN IF STRUCT_GLOBAL.PROCESSING_LEVEL EQ 'L3 Binned' THEN BEGIN
        DATA_TAG = 'DATA' 
        OK_REM = WHERE_MATCH(TARGETS,['BinIndex', 'BinList', 'binDataDim', 'binIndexDim', 'binListDim','qual_l3','qualityDIM','qualityDim'],COUNT_RM)
        IF COUNT_RM GE 1 THEN TARGETS = REMOVE(TARGETS,OK_REM) ; ===> Remove non-SD targets
        FOR T=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
          DT = H5_READ_L3B(FILE, TARGETS(T),BINS=BINS,NROWS=NROWS)                           ; ===> Read the L3 bin file and extract target data
          SD = CREATE_STRUCT(SD, CREATE_STRUCT(TARGETS(T),CREATE_STRUCT('DATA',TEMPORARY(DT),'BINS',BINS,'NROWS',NROWS)))
          GONE, DT
        ENDFOR
        IF KEY(LOOK) THEN BEGIN
          NCDF_CLOSE, FILE_ID  & GONE, FILE_ID
          IF ANY(H5ID)    THEN H5F_CLOSE,  H5ID    & GONE, H5ID
          IF ANY(GID)     THEN H5G_CLOSE,  GID     & GONE, GID                                                ; ===> Close the NCDF file
          RETURN, LSTR
        ENDIF; IF KEY(LOOK) THEN BEGIN
        STRUCT = CREATE_STRUCT(STRUCT, 'SD', SD)
      ENDIF ELSE BEGIN ; IF STRPOS(STRUPCASE((FILE_PARSE(FILE)).NAME),'L3B') GE 0 THEN BEGIN
        SD = H5_GET_DATA(FILE,PRODS=TARGETS,LOOK=LOOK)                                        ; ===> Get the SD products from the HDF5 file
        STRUCT = CREATE_STRUCT(STRUCT,'SD',SD)                                                ; ===> Add SD product to the structure
      ENDELSE
      
      IF KEY(DATA) THEN BEGIN  ; CAN ONLY HAVE ONE PROD BECAUSE DATA ARRAYS ARE DIFFERENT SIZES
        SD_PRODS = TAG_NAMES(STRUCT.SD)
        IF N_ELEMENTS(SD_PRODS) GT 1 THEN RETURN, 'ERROR: Can only provide 1 PROD if keyword DATA is set'
        OK_TAG = WHERE(TAG_NAMES(STRUCT.SD.(0)) EQ DATA_TAG,COUNT_TAG) ;===> MUST HAVE IMAGE IN THE STRUCT.SD
        IF COUNT_TAG EQ 1 THEN RETURN,STRUCT.SD.(0).(OK_TAG) ELSE RETURN, 'ERROR: IMAGE/DATA not found for product' + NAME + ' in file ' + FILE
      ENDIF ; IF KEY(DATA) THEN BEGIN    
    ENDIF ; H5F_IS_HDF5
  ENDIF ; STRUCT=[] OR KEY(HDF5)  
 
  DONE:
  
  GONE,STRUCT_GLOBAL
  GONE,STRUCT_SD
  GONE,BINS
  GONE,NROWS
  
  IF ANY(FILE_ID) THEN NCDF_CLOSE, FILE_ID & GONE, FILE_ID
  IF ANY(H5ID)    THEN H5F_CLOSE,  H5ID    & GONE, H5ID 
  IF ANY(GID)     THEN H5G_CLOSE,  GID     & GONE, GID
  
  IF N_ELEMENTS(STRUCT) EQ 0 THEN RETURN,'ERROR: Reading the FILE - ' + FILE
  RETURN, STRUCT

END; #####################  END OF ROUTINE ################################


