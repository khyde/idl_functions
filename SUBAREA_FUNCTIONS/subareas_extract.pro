; $ID:	SUBAREAS_EXTRACT.PRO,	2023-09-21-13,	USER-KJWH	$
;+
;#############################################################################################################
	PRO SUBAREAS_EXTRACT,FILES, SHP_NAME=SHP_NAME,$
	                     EXTRACT_STAT=EXTRACT_STAT, EXTRACT_ANOM=EXTRACT_ANOM,OUTPUT_STATS=OUTPUT_STATS,SUBAREAS=SUBAREAS,DIR_SHP=DIR_SHP,$
	                     AROUND=AROUND,NC_PROD=NC_PROD,SV_PROD=SV_PROD,SHP_TAG=SHP_TAG,SAVEFILE=SAVEFILE,DIR_OUT=DIR_OUT,DATERANGE=DATERANGE,$
	                     ADD_DIR=ADD_DIR,BATHY=BATHY,INIT=INIT,SKIP_BAD=SKIP_BAD, VERBOSE=VERBOSE, $
	                     STRUCT=STRUCT, BAD_FILES=BAD_FILES

;
; PURPOSE: Extracts portions [subareas] of data from satellite data files         
;
; CATEGORY:	
;   SUBAREAS
;
; CALLING SEQUENCE: 
;   SUBAREAS_EXTRACT,FILES,SHP_NAME=SHP_NAME
;
; REQUIRED INPUTS: 
;   FILES.......... List of complete satellite data file names 
;   SHP_NAME_...... Name of the shapefile to use for the data extraction 
;		
; OPTIONAL INPUTS: 
;   EXTRACT_STAT... Indicate the "stat" to be extracted from input STATS files
;   EXTRACT_ANOM. Indicate the "anomaly" type (DIF/RATIO) from the input ANOM files
;   OUTPUT_STATS... A text array of STATS variables to return
;   SUBAREAS....... Optional input of subareas within the shpfile to use for the data extraction (e.g. only extract GOM from the EPU shpfile)
;   DIR_SHP........ Input directory for the shapefiles  [DEFAULT = !S.IDL_SHAPEFILES+'SHAPES']
;   AROUND......... Input to BOX_AROUND for when the extraction is point (lon/lat) based [DEFAULT = 1]
;   NC_PROD........ Input product name for NC files that contain more than one product
;   SV_PROD........ Input product name for SAV files that contain more than one product
;   SHP_TAG........ Input as ATT_TAG to READ_SHAPEFILE to select the tagname from the attributes in the shapefile dbf (see READ_SHAPEFILE)
;   SAVEFILE....... Optional name for the output savefile
;   DIR_OUT........ Output directory [DEFAULT = !S.EXTRACTS]
;   DATERANGE... Subset the input data based on the daterange (only works with "stacked" files)
;		
; KEYWORD PARAMETERS:
;   ADD_DIR........ Use to add the input file directory to the output structure
;   BATHY.......... Use when the input files are BATHY files
;   INIT........... Initializes memory variables:
;                   1) SHPS,  
;                   2) DB_BINS
;                   3) DB 
;   SKIP_BAD....... Skip any "bad" files (files that can't be properly read)
;   VERBOSE........ Print program progress
;
; OUTPUTS: 
;   SAV and CSV files containing the stats structure for each file by subarea
;   
; OPTIONAL OUTPUTS
;   STRUCT........ The output structure saved in the SAV and CSV files  
;   BAD_FILES..... The array of "bad" files that were not able to be read
;   
;	PROCEDURE:
;	1) Any or all the NC [OR SAV] files are provided each time the program is called
;	2) Read the shapefile
;	3) If a database [DB] from a previous run exists then the SAV file is read and updated as needed 
;	4) during subsequent calls, if the file name_ext, region and subarea are already in the DB and the input file is not newer than the one used in the DB, then the file is skipped >>>>>
;	5) If an updated file [NAME_EXT] with a mtime ['MTIME_FILE'] exceeding its MTIME in the db ['MTIME_SUBAREA'] then these records are deleted from the DB 
;	   and the new record is added to the DB
;	6) The db is sorted by period and written to the SAV file each time the program is called 
;
; NOTES:
;  
; COPYRIGHT:
; Copyright (C) 2019, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI 
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI.  Questions should be directed to kimberly.hyde@noaa.gov.
;
;  
; MODIFICATION HISTORY:
;     FEB 09, 2017 - REWRITTEN BY J.E.O'REILLY 	
;     FEB 12, 2017 - JEOR: REVISED TO DEAL WITH L3B NC FILES
;     FEB 13, 2017 - JEOR: ADDED DB TO COMMON
;     FEB 13, 2017 - JEOR: ADDED STRUCT_SUBAREA_BINS TO COMMON BLOCK;                          
;                          OK = WHERE(DB.NAME_EXT EQ F.NAME_EXT AND MTIME_FILE GT DB.MTIME_FILE ,COUNT_DB)
;                          TESTED AND ADDED PROCEDURE NOTES
;     FEB 17, 2017 - JEOR: ADDED UPDATE = 0   
;     FEB 19, 2017 - JEOR: REVISED TO USE BINS [SUBS] FROM THE OUTPUT STRUCT 
;                          FROM THE REVISED PLT_SHP [WITH LOOP ON SHAPEFILES IN A REGION]  
;     FEB 20, 2017 - JEOR: REVISED TO GET SHP_BINS FROM EACH SUBAREA'S LONS & LATS 
;                          VIA MAPS_SHP_2BINS & MAPS_L3B_LONLAT_2BIN
;                          EXTENDED COMMON TO INCLUDR DB_BINS
;     FEB 23, 2017 - KJWH: Added REGIONS and SHP_FILES keywords so that the user can specify which regions and/or shapefiles to use      
;                          Removed VERBOSE = 1 and added several IF VERBOSE THEN... statements
;                          Removed MAPP keyword - now deriving the MAP from the file names   
;                          All input files must have the sam MAP
;                          Now deriving the default DIR_OUT from the input file names
;                          Saving the file as a SAVEFILE instead of a CSV_FILE - There is no need to make it a CSV at this stage 
;                          Added SAVEFILE keyword and if not provided, deriving the name from the file names using INAME_MAKE
;                          Removed OK = WHERE(FINITE(ARR),COUNT) & IF COUNT GE 1 THEN ARR = ARR[OK] because this step is done in STATS()
;                          Removed the COMMON block because there are several instances where you do not want to retain the DB and the SHP structure is very quick to create
;                          Removed the steps to get the L3B subscripts.  This is now done in PLT_SHP
;                          Added MAPS_L3B_2ARR to convert the incomplete L3B array into a full L3B array
;			FEB 24, 2017 - KJWH: Added steps to compare the MTIMES before running the file loop and to subset the files with only those that need to be added or updated in the DB
;			                     *** THIS STEP STILL NEEDS TO BE FULL TESTED ***
;			MAR 01, 2017 - KJWH: Added MATH to the output structure to distinguish between DATA, STATS and ANOMS data         
;			                     Added SAVE_2CSV, SAVEFILE    
;			MAR 03, 2017 - KJWH: Updated the subset of files to be updated.  Now deriving the name from FP.FULLNAME instead of relying on FILES, which could be inaccurate.
;			MAR 08, 2017 - KJWH: Added keyword PROD and steps to get the desired product from the L3B netcdf files.        
;			MAR 15, 2017 - KJWH: Added IF IDLTYPE(SHP) NE 'STRUCT' THEN CONTINUE to accomodate additional non-struct tags in the shapefile sav's.     
;			MAR 20, 2017 - KJWH: Updated the section that does the preliminary check to see if the files already exist in the DB for the matching input subareas.   
;			                     No longer using PARSE_IT(FILES,/ALL) at the beginning - it was very slow when there were L3B.nc files (SENSOR_INFO is the bottleneck)
;			                     Now, using FILE_PARSE on all of the files and just PARSE_IT(/ALL) on the first file     
;			                     Added a second MAP check in the FILELOOP section - IF FP.MAP NE MP THEN MESSAGE, 'ERROR: Map in file (' + FILE + ') does not match MP - ' + MP
;			APR 24, 2017 - KJWH: Added TAG=APROD to ARRAY = STRUCT_READ(FILE,TAG=APROD,STRUCT=STRUCT,BINS=ARR_BINS) for input files with a group of products        
;			JUN 16, 2017 - KJWH: Changed PLT_SHP to READ_SHPFILE  
;			NOV 21, 2017 - KJWH: Changed the parameter name REGIONS to SUBREGIONS to avoid conflicts with the John Hopkins function REGIONS   
;			DEC 05, 2017 - KJWH: Changed MAPP to MP in ARRAY = MAPS_L3B_2ARR(ARRAY,MP=MP,BINS=ARR_BINS)  
;			DEC 15, 2017 - KJWH: Added PFILE, SAVEFILE      
;			                     Removed IF VERBOSE THEN ST, DB
;			MAR 21, 2017 - KJWH: Added IF HAS(STR,'UNITS') THEN UNIT = STR.UNITS ELSE UNIT = UNITS(STR.PROD)
;			MAR 23, 2017 - KJWH: Added IF NONE(PROD) THEN PROD = STR.PROD
;			MAR 24, 2018 - KJHW: Removed obsolete lines IF NONE(SUBREGIONS) THEN SUBREGIONS = (FILE_PARSE(FILE_SEARCH(DIR_SHP + SL + '*', /TEST_DIRECTORY,/MARK_DIRECTORY))).SUB ; IF NONE PROVIDED, LOOK FOR THE SUBFOLDERS IN DIR_SHP
;                                             and DIR_REGIONS = DIR_SHP + SUBREGIONS
;                          Changed keyword PROD to NC_PROD so that it is only for the L3B nc files
;                          Updated the code associated with PROD: NOTE - THERE COULD STILL BE ISSUES WITH THE PROD DEPENDING ON THE TYPE OF FILE (L3B.nc, FRONTS, etc.) 
;                          Changed keyword SUBREGIONS to SUBAREAS so that the keyword is consistent with the paramter name      
;                          Added IF NONE(SUBAREAS) THEN BEGIN to determine the SUBAREA names if not provided as a keyword     
;                          Added IF N_ELEMENTS(SUBAREAS) GT 1 AND ANY(SUBAREAS) THEN MESSAGE, 'ERROR: SUBAREAS are region specific, can only provide 1 input SHP_FILE if you want to specify the SUBAREAS'
;                          Updated the SUBREGIONS and SUBAREAS info when finding the SUBAREAS (if none provided), when checking the orignial DB and when looping through the files
;                                FOR T=0, N_ELEMENTS(SUBREGIONS)-1 DO BEGIN
;                                  REGION = SUBREGIONS(T)
;                                  RPOS = WHERE_TAGS(SHPS,REGION)  ; Note, using WHERE_TAGS is much faster than STRUCT_GET when there are a large number of tags
;                                  RSHP = SHPS.(RPOS)
;                                  FOR S=0, N_ELEMENTS(SUBAREAS)-1 DO BEGIN
;                                    SUBAREA = SUBAREAS(S)
;                                    SPOS = WHERE_TAGS(RSHP,SUBAREA)  ; Note, using WHERE_TAGS is much faster than STRUCT_GET when there are a large number of tags
;                                    SHP = RSHP.(SPOS)   
;     APR 02, 2018 - KJWH: Added IF STRMID(SUBAREA,0,1) EQ '_' THEN SUBAREA = STRMID(SUBAREA,1) to fix any subarea names that start with '_' before writing them into the output structure                                
;     APR 03, 2018 - KJWH: Added ALL_SUBAREAS = REPLACE(ALL_SUBAREAS,'__','_') prior to checking the existing database to fix any subarea names that may start with '_' (see APR 2, 2018 modification)
;                          Added SHP_TAG as an input to READ_SHPFILE (ATT_TAG)
;     JUL 25, 2018 - KJWH: Tested and updated the PRODS information associated with the L3B nc files  
;     AUG 15, 2018 - KJWH: Still having issues with the PRDS
;                            Added SV_PROD for the SAV files (this is necessary for files with multiple products per file)   
;     OCT 16, 2018 - KJWH: MP = FA.MAP ; Rename MP variable in case it is overwritten in READ_SHPFILE    
;     NOV 02, 2018 - KJWH: Added NC to the replacement directory names DIR_OUT = REPLACE(FA.DIR,['NC','SAVE','STATS','ANOMS'],['SUBAREAS','SUBAREAS','SUBAREAS','SUBAREAS'])   
;                          Added IF NONE(NC_PROD) THEN NC_PROD = FP.PROD when there is only one prod in FP.PROD   
;     NOV 05, 2018 - KJWH: Added CALL_ROUTINE = CALLER()
;                          Changed default DIR_OUT to !S.EXTRACTS (/nadata/PROJECTS/SUBAREAS_EXTRACTS/
;                          Added the calling routine name to the default output savefile name     
;     FEB 12, 2019 - KJWH: Added steps to look for and remove "old" duplicate climatology files (e.g. remove ANNUAL_2003_2017 if ANNUAL_2003_2018 is present).  Adapted from STATS_CLEANUP                                                                    
;     OCT 15, 2019 - KJWH: Updated introduction comments and keywords
;                          Added Copyright information
;                          Updated documentation throughout
;     JAN 17, 2020 - KJWH: Updated the find "old files" code so that it now works with anomaly periods (e.g. A_2018-ANNUAL_1998_2018 is replaced with A_2018-ANNUAL_1998_2019)                     
;     JUN 30, 2020 - KJWH: Added COMPILE_OPT IDL2
;                          Changed subscripts from () to []
;                          Added OUTPUT_STATS keyword option to specify which stat variables to return from STATS
;                          Changed SAME(VALIDS('MAPS',REPLACE(FP.NAME_EXT,['_','.'],['-','-']))) to SAME(VALIDS('MAPS',FP.DIR))
;     AUG 10, 2020 - KJWH: Now using the variable NEW_DB to hold any new extract information.  
;                            The NEW_DB is then combined with the original DB after all files have been read.
;                            The goal is to hopefully speed up the process by reducing the size of the NEW_DB when adding new information to an existing DB
;     JAN 28, 2021 - KJWH: Added steps to look for duplicates that may only have different methods and remove the older (based on MTIME) files)
;                          Changed the default output location to include subdirectories for the SHP_FILE, SENSOR and PROD-ALG
;     DEC 06, 2022 - KJWH: Now can read and extract data from STACKED (save and stat) files - still need to update the stacked anom files
;                          Added EXTRACT_STAT to the output structure                     
;    DEC 14, 2022 - KJWH: Added EXTRACT_ANOM as an optional input parameter
;                                        Changed EXTRACT_STAT in the output structure to EXTRACT_TAG
;    JAN 13, 2023 - KJWH: Added DATERANGE keyword to subset dates within "stacked" files 
;    NOV 09, 2023 - KJWH: Fixed a WHERE matching bug when trying to update existing data
;-
; ####################################################################################################################################
  
  ROUTINE_NAME = 'SUBAREAS_EXTRACT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  CALL_ROUTINE = CALLER()
  DB = []
  BAD_FILES=[]

; ===> Check inputs
  IF ~N_ELEMENTS(SHP_NAME)      THEN MESSAGE,'ERROR: Must provide the name of the SHAPEFILE(S)'
  IF ~N_ELEMENTS(FILES)         THEN MESSAGE,'ERROR: Must provide input FILES'

; ===> Set up defaults
  IF ~N_ELEMENTS(VERBOSE)      THEN VERBOSE  = 0
  IF ~N_ELEMENTS(DIR_SHP)      THEN DIR_SHP  = !S.IDL_SHAPEFILES + 'SHAPES' + SL
  IF ~N_ELEMENTS(AROUND)       THEN AROUND   = 1
  IF ~N_ELEMENTS(EXTRACT_STAT) THEN EXTRACT_STAT = 'MEAN'
  
; ===> Get file information  
  FP = PARSE_IT(FILES)                                                                                    ; Parse the file name of all files 
  FP = SORTED(FP,TAG='PERIOD',SUBS=SUBS) & FILES = FILES[SUBS]                                            ; Sort the files based on the period 
  FA = PARSE_IT(FILES[0],/ALL)                                                                            ; Parse the first file to establish the MP, DIR_OUT, SAVEFILE, etc.
  IF ~N_ELEMENTS(EXTRACT_ANOM) THEN BEGIN
    PSTR = PRODS_READ(FA.PROD)
    CASE PSTR.LOG OF
      '0': EXTRACT_ANOM='DIF'
      '1': EXTRACT_ANOM='RATIO'
    ENDCASE
  ENDIF
  
; ===> Check the input MAP information  
  MP = FA.MAP                                                                                             ; MAP variable
  IF SAME(VALIDS('MAPS',FP.DIR)) NE 1 THEN MESSAGE, 'ERROR: All input files must have the same MAP'       ; Use VALIDS to verify the MAPS (much quicker than using FILE_PARSE & SENSOR_INFO)
  
; ===> Set up the OUTPUT_DIRECTORY
  IF NONE(DIR_OUT) THEN DIR = !S.SUBAREA_EXTRACTS + SHP_NAME + SL + FA.SENSOR + SL + FA.PROD + '-' + FA.ALG + SL ELSE DIR=DIR_OUT
  IF STRMID(FA.METHOD,0,1) EQ 'V' THEN DIR = REPLACE(DIR,FA.SENSOR+SL+FA.PROD,FA.SENSOR+'-'+FA.METHOD+SL+FA.PROD) 
; ===> Create output file name    
  IF NONE(SAVEFILE) THEN SAVEFILE = DIR + INAME_MAKE(SENSOR=FA.SENSOR, METHOD=FA.METHOD, COVERAGE=FA.COVERAGE, MAP=FA.MAP) + '-'+CALL_ROUTINE+'.SAV' 
  FPS = PARSE_IT(SAVEFILE,/ALL)
  IF FPS.PROD_ALG NE FA.PROD_ALG THEN DIR = REPLACE(DIR,FA.PROD_ALG,FPS.PROD_ALG)
  IF FPS.DIR EQ '' THEN SAVEFILE = DIR + SAVEFILE
  DIR_TEST, (FILE_PARSE(SAVEFILE)).DIR                                                                    ; Check to make sure the output directory exists

; ===> Read the shapefiles for the input map 
  SHP_FILES = DIR_SHP + SHP_NAME + SL + SHP_NAME + '.shp'                                                 ; Default naming scheme for all shapefiles
  IF WHERE(FILE_TEST(SHP_FILES) EQ 0) GE 0  THEN MESSAGE, 'ERROR: ' + SHP_FILES + ' do not exist.'
  SHPS = []
  FOR S=0, N_ELEMENTS(SHP_NAME)-1 DO BEGIN
    SHP = READ_SHPFILE(SHP_NAME[S], MAPP=MP, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND, ATT_TAG=SHP_TAG)
    SHPS = CREATE_STRUCT(SHPS,SHP_NAME[S],SHP)
  ENDFOR  

; ===> Establish the subareas for the data extraction
  IF N_ELEMENTS(SHP_NAME) GT 1 AND ANY(SUBAREAS) THEN MESSAGE, 'ERROR: SUBAREAS are region specific, can only provide 1 input SHP_FILE if you want to specify the SUBAREAS'
  SUBREGIONS = TAG_NAMES(SHPS)
  IF NONE(SUBAREAS) THEN BEGIN                                                                            ; If no SUBAREAS are provided, get them from the shapefile 
    ALL_SUBAREAS = []   
    SUBTAGS = []
    FOR N=0, N_TAGS(SHPS)-1 DO BEGIN
      REG = SUBREGIONS[N]
      STAGS = TAG_NAMES(SHPS.(N)) 
      FOR S=0, N_TAGS(SHPS.(N))-1 DO BEGIN
        IF IDLTYPE(SHPS.(N).(S)) NE 'STRUCT' THEN CONTINUE                                                ; Be sure to only get the subarea structures and not the outlines or colors
        IF STRPOS(STAGS[S],'_') EQ 0 THEN STAGS[S] = STRMID(STAGS[S],1)
        SUBTAGS = [SUBTAGS,STAGS[S]]
        ALL_SUBAREAS = [ALL_SUBAREAS,REG+'_'+STAGS[S]]                                                    ; NOTE - Subareas are region specific
      ENDFOR
    ENDFOR  
  ENDIF ELSE ALL_SUBAREAS=SUBREGIONS+'_'+SUBAREAS   
  ALL_SUBAREAS = REPLACE(ALL_SUBAREAS,'__','_')

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ===> Check to see if the files and subareas already exist in the database
  IF FILE_TEST(SAVEFILE) AND ~KEYWORD_SET(INIT) THEN BEGIN
    IF VERBOSE THEN PF,SAVEFILE,/O
    DB = IDL_RESTORE(SAVEFILE)                                                                            ; Read the subarea savefile
    CDB = DB.REGION+'_'+DB.SUBAREA                                                                        ; Combine subregion and subarea name to subset on
    ASETS = WHERE_SETS(CDB)                                                                               ; Subset the DB based on the region + subarea 
    AOK = WHERE_MATCH(ALL_SUBAREAS, ASETS.VALUE,COUNTA,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP)     ; Find where the subareas in the DB match the input subareas
    IF COUNTA EQ 0 THEN GOTO, FILELOOP                                                                    ; If there are no matching subareas in the DB, go to the file loop 
    ASETS = ASETS[VALID]                                                                                  ; Just look at the matching subareas
    SUBS = [] & FOR A=0, N_ELEMENTS(ASETS)-1 DO SUBS = [SUBS,WHERE_SETS_SUBS(ASETS[A])]                   ; Get the subscripts for the matching subareas
    ADB = DB[SUBS]                                                                                        ; Subset the DB to contain just the subareas that match the input subareas
    
    FSETS = WHERE_SETS(ADB.NAME)                                                                          ; Group the subsetted ADB based on the filename
    FSETS = SORTED(FSETS,TAG='VALUE')                                                                     ; Sort based on  DB.NAME
    DB_MTIMES = ADB[FSETS.FIRST].MTIME_FILE                                                               ; Get the MTIMES for the files in the subsetted ADB 
    OKN = WHERE(FSETS.N LT N_ELEMENTS(ALL_SUBAREAS),COMPLEMENT=COMP,COUNT_N,NCOMPLEMENT=NCOMP)            ; Determine if the number of subareas in the subsetted ADB match the number of subareas to be extracted
    IF COUNT_N GT 0 THEN BEGIN    
      IF NCOMP GT 0 THEN BEGIN                                                                            ; Look for files that have all subareas
        DSETS = FSETS[COMP]                                                                               ; Just get the sets for the "completed" files
        DSUBS = [] & FOR D=0, N_ELEMENTS(DSETS)-1 DO DSUBS = [DSUBS,WHERE_SETS_SUBS(DSETS[D])]            ; Get the subscripts for the "completed" files
        
        IF STRUCT_HAS(DB,'STACKED_FILE') THEN BEGIN
          DFILES = ADB[DSUBS].STACKED_FILE & DFILES = DFILES[UNIQ(DFILES,SORT(DFILES))]                   ; Get the names of the "completed" files and sort the files and just get the unique names
          DFILES = DFILES[UNIQ(DFILES,SORT(DFILES))]                                                      ; Sort and find the unique files 
          OK = WHERE_MATCH(FILES,DFILES,COUNT,VALID=VALID,COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)             ; Find the files that match the "completed" files
          IF NCOMP GT 0 THEN FILES = FILES[COMP] $                                                        ; Removed the "completed" files from the list
                        ELSE MESSAGE, 'ERROR: Double check code that looks for files that have all subareas'  
          
          OK = WHERE_MATCH(FILES,DB.STACKED_FILE,COUNT,VALID=VALID)                                       ; Find the "incomplete" files in the structure 
          IF COUNT GE 1 THEN DB[VALID].NAME = '' ELSE MESSAGE, 'ERROR: Need to double check code'         ; Make the "incomplete" files missing
          OK = WHERE(DB.NAME NE '',COUNT)                                                                 ; Find the "missing" files
          IF COUNT GE 1 THEN DB = DB[OK] ELSE MESSAGE, 'ERROR: Need to double check code'                 ; Removed the "missing" files from the DB structure
          
        ENDIF ELSE BEGIN
          DFILES = ADB[DSUBS].NAME                                                                        ; Get the names of the "completed" files
          DFILES = DFILES[UNIQ(DFILES,SORT(DFILES))]                                                      ; Sort the files and just get the unique names
          OK = WHERE_MATCH(FILES,DFILES,COUNT,VALID=VALID,COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)             ; Find the files that match the "completed" files
          IF NCOMP GT 0 THEN FILES = FILES[COMP] $
                        ELSE MESSAGE, 'ERROR: Double check code that looks all subareas per file'         ; Subset files to only the "incomplete" or "missing" files (i.e. remove the "completed" files
        ENDELSE
      ENDIF
      GOTO, FILELOOP                                                                                      ; If subareas are missing, loop through all files with missing subareas
    ENDIF
    
    IF STRUCT_HAS(DB,'STACKED_FILE') THEN BEGIN
      SETS = WHERE_SETS(ADB.STACKED_FILE)
      SFILES = SETS.VALUE
      DB_MTIMES = ADB[SETS.FIRST].MTIME_FILE                                                              ; Get the MTIMES for the files in the subsetted ADB 
      OK = WHERE_MATCH(FP.FULLNAME,SFILES,COUNT,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMPLEMENT)      ; Find the matching files
      IF NCOMPLEMENT GT 0 THEN BEGIN                                                                        ; If not all of the files are matching...
        IF COUNT GT 0 THEN OKT = WHERE(GET_MTIME(FP[OK].FULLNAME) GT DB_MTIMES[VALID],COUNTT) ELSE COUNTT=0 ; Look for files with more recent MTIMES
        IF COUNTT GT 0 THEN FILES = [FP[OK[OKT]].FULLNAME,FP[COMP].FULLNAME] ELSE FILES = FP[COMP].FULLNAME ; Subset the files to be just those that are missing and are newer than what is in the DB
        GOTO, FILELOOP                                                                                      ; GOTO the file loop
      ENDIF
    ENDIF ELSE BEGIN
      OK = WHERE_MATCH(FP.NAME,FSETS.VALUE,COUNT,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMPLEMENT)       ; Find the matching files   
      IF NCOMPLEMENT GT 0 THEN BEGIN                                                                        ; If not all of the files are matching...
        IF COUNT GT 0 THEN OKT = WHERE(GET_MTIME(FP[OK].FULLNAME) GT DB_MTIMES[VALID],COUNTT) ELSE COUNTT=0 ; Look for files with more recent MTIMES
        IF COUNTT GT 0 THEN FILES = [FP[OK[OKT]].FULLNAME,FP[COMP].FULLNAME] ELSE FILES = FP[COMP].FULLNAME ; Subset the files to be just those that are missing and are newer than what is in the DB
        GOTO, FILELOOP                                                                                      ; GOTO the file loop
      ENDIF 
    ENDELSE  
;STOP ; NEED TO CONFIRM THIS STEP WITH THE STACKED FILES

    OKT = WHERE(GET_MTIME(FP[OK].FULLNAME) GT DB_MTIMES[VALID],COUNTT)                                    ; Look for files with more recent MTIMES
    IF COUNTT EQ 0 THEN BEGIN
      FILES = []
      UPDATE = 0
      GOTO, CHECK_OLD                                                                                     ; If no new files then skip the file loop
    ENDIF
    FILES = FILES[OK[OKT]]                                                                                ; Subset the files with only those that are new   
    STRUCT = DB                                                                                           ; Create a copy of the DB to return as the output structure
  ENDIF;IF NONE(DB) AND EXISTS(SAVEFILE) AND NOT KEY(INIT) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ===> Loop through all files  
  FILELOOP:
  MTIME_SUBAREA = MTIME_NOW()                                                                            ; Get the current MTIME
  FOR FL = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    FILE = FILES[FL] 
    POF, FL, FILES, OUTTXT=OUTTXT,/QUIET
    FP = PARSE_IT(FILE,/ALL)                                                                             ; Parse the file
    IF FP.MAP NE MP THEN MESSAGE, 'ERROR: Map in file (' + FILE + ') does not match MP - ' + MP          ; Check the map in the file

; ===> Get the product information from the file    
    IF IS_L3B(FP.MAP) AND STRUPCASE(FP.EXT) NE 'SAV' THEN BEGIN                                              
      IF NONE(NC_PROD) AND N_ELEMENTS(STR_BREAK(FP.PROD,';')) GT 1 THEN MESSAGE, 'ERROR: Must provide an accurate PROD to extract from the L3B nc file'
      IF NONE(NC_PROD) THEN NC_PROD = FP.PROD
      IF HAS(FP.PROD,';') THEN BEGIN
        SI = SENSOR_INFO(FILE)
        PRODS = STR_BREAK(SI.PRODS,';')
        NPRODS = STR_BREAK(SI.NC_PROD,';')
        OK = WHERE_MATCH(PRODS,NC_PROD,COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Must provide an accurate PROD to extract from the L3B nc file'
        APROD = NPRODS[OK]
        SPROD = PRODS[OK]
        FP.PROD = VALIDS('PRODS',SPROD)
        FP.ALG  = VALIDS('ALGS', SPROD)
      ENDIF 
    ENDIF ELSE BEGIN
      IF NONE(SV_PROD) THEN APROD = FP.PROD ELSE APROD = SV_PROD
      SPROD = FP.PROD_ALG
    ENDELSE
        
    MTIME_FILE = GET_MTIME(FILE)                                                                         ; Get the MTIME of the file
    NAME       = STRUPCASE(FP.NAME_EXT)     
    TXT_COMBO  = STRUPCASE(STR_WELD(NAME,MP,REG,SUBTAGS)) 

; ===> Check if updates to the DB are needed for the file 
    UPDATE = 0                                                                                           ; Initialize UPDATE to 0
    IF IDLTYPE(DB) EQ 'STRUCT' THEN BEGIN
      OK = WHERE(DB.NAME EQ FP.NAME_EXT AND MTIME_FILE GT DB.MTIME_FILE, COUNT_DB)                           ; Find if the MTIME of the file is later than the MTIME in the DB
      TXT_DB = STRCOMPRESS(STRUPCASE(STR_JOIN(DB.NAME,DB.MAP,DB.REGION,DB.SUBAREA,DELIM=';')))           ; Create a text string with the DB NAME_EXT, MAPP, REGION and SUBAREA
      IF COUNT_DB GE 1 THEN BEGIN
        UPDATE = 1      
        DB = STRUCT_DELETE(DB,OK)                                                                        ; If the file is more recent, remove all instances of this file from the DB
        IF VERBOSE THEN PFILE,TXT_DB[OK],/D          
        GOTO,READ_FILE                                                                                   ; Skip to READ_FILE
      ENDIF ELSE UPDATE = 0 ; IF COUNT_DB GE 1 THEN BEGIN
      
      OK_SUBS = WHERE_IN(TXT_COMBO, TXT_DB, COUNT_SUBS, NCOMPLEMENT=NCOMPLEMENT, COMPLEMENT=COMPLEMENT)  ; Find if the text string is in the DB
      IF COUNT_SUBS EQ NOF(ALL_SUBAREAS) AND NCOMPLEMENT EQ 0 THEN BEGIN                                     ; If all text strings are in the DB and don't need to be updated, loop to next file
        IF VERBOSE THEN MESSAGE,/INFORM, NAME + '  SUBAREAS ARE IN THE DB'
        CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      ENDIF;IF COUNT_SUBS EQ NOF(SUBAREAS) AND NCOMPLEMENT EQ 0 THEN BEGIN
    ENDIF ; IF IDLTYPE(DB) EQ 'STRUCT' THEN BEGIN   

; ===> Read the input file    
    READ_FILE:
    UPDATE = 1
    PFILE,FP.NAME,/R,_POFTXT=OUTTXT
    GARRAY   = []                                                                                        ; Initialize the GMEAN array (GARRAY)
    ARR_BINS = []                                                                                        ; Initialize the ARR_BINS variable   
    STACKED  = 0                                                                                         ; Initialize the STACKED keyword
    IF KEY(BATHY) THEN BEGIN                                                                             ; Check to see if the file contains BATHY data
      ARRAY = READ_BATHY(FP.MAP,STRUCT=STR)
      SPROD = 'BATHY'
      FP.PROD = 'BATHY'
    ENDIF ELSE BEGIN
      IF HAS(FP.EXT,'SAV') THEN BEGIN
        IF HAS(FP.L2SUB,'STACKED') THEN BEGIN
          STACKED = 1
          STR = STACKED_READ(FILE, PRODS=PRODS, DB=STACKED_DB, KEYS=KEYS, INFO=INFO, BINS=ARR_BINS)
          STACKED_DB = STRUCT_RENAME(STACKED_DB,['STATFILE','STATNAME','ANOMFILE','ANOMNAME'],['FULLNAME','NAME','FULLNAME','NAME']);,/STRUCT_ARRAYS) 
          CASE FP.L2SUB OF
            'STACKED_STATS': BEGIN & ARRAY = STRUCT_GET(STR,FP.PROD+'_'+EXTRACT_STAT) & EXTRACT_LABEL=EXTRACT_STAT & END
            'STACKED_ANOMS': BEGIN & ARRAY = STRUCT_GET(STR,FP.PROD+'_'+EXTRACT_ANOM) & EXTRACT_LABEL=EXTRACT_ANOM & END
            'STACKED_SAVE':  BEGIN & ARRAY = STRUCT_GET(STR,VALIDS('PRODS',APROD)) & EXTRACT_LABEL='DATA' & END
            'STACKED_INTERP':  BEGIN & ARRAY = STRUCT_GET(STR,VALIDS('PRODS',APROD)) & EXTRACT_LABEL='INTERP_DATA' & END
          END
          IF KEYWORD_SET(DATERANGE) THEN BEGIN
            DR = DATE_2JD(GET_DATERANGE(DATERANGE))
            DBJDS = PERIOD_2JD(STACKED_DB.PERIOD)
            ASZ = SIZEXYZ(ARRAY,PX=PX,PY=PY,PZ=PZ)
            IF N_ELEMENTS(DBJDS) NE PZ THEN MESSAGE, 'ERROR: Number of periods in the stacked database (DB) do not match the time dimension in the array'
            OK = WHERE(DBJDS GE MIN(DR) AND DBJDS LE MAX(DBJDS),COUNT,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP)
            IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Need to check the date range and dates within the stacked file'
            IF NCOMP GT 0 THEN STACKED_DB[COMP].NAME = ''
          ENDIF  
        ENDIF ELSE BEGIN
          ARRAY = STRUCT_READ(FILE,STRUCT=STR,BINS=ARR_BINS) 
          IF IDLTYPE(ARRAY) EQ 'STRUCT' THEN ARRAY = GET_TAG(ARRAY,VALIDS('PRODS',APROD))
          IF HAS(FILE,'STATS') THEN IF STRUCT_HAS(STR,'GMEAN') THEN GARRAY = STR.GMEAN
        ENDELSE  
      ENDIF ELSE ARRAY = READ_NC(FILE,PROD=APROD,STRUCT=STR,BINS=ARR_BINS,/DATA)
    ENDELSE
    
    IF IDLTYPE(ARRAY) EQ 'STRING' THEN BEGIN
      BAD_FILES = [BAD_FILES,FILE]
      IF KEYWORD_SET(SKIP_BAD) THEN BEGIN
        PRINT, ARRAY
        CONTINUE
      ENDIF
      
      IF DB EQ [] THEN DB = NEW_DB ELSE IF ANY(NEW_DB) AND DB NE [] THEN DB = [DB,NEW_DB]               ; Create the output DB
      DB = NAN_2INFINITY(DB)                                                                            ; Convert any nans to infinity
      DB = SORTED(DB,TAG = 'PERIOD')                                                                    ; Sort by period
      STRUCT = DB                                                                                       ; Output structure
      SAVE,DB, FILENAME=SAVEFILE                                                                        ; Save the DB
      SAVE_2CSV, SAVEFILE
      MESSAGE, ARRAY   
      FILE_DELETE, FILE                                                                                 ; Delete the bad file
    ENDIF  
    IF IDLTYPE(ARRAY) EQ 'STRUCT' THEN MESSAGE, 'ERROR, PRODUCT NOT PROPERLY READ FROM FILE'
      
; ===> Process each tag [SUBAREA] in the nested structure       
    FOR T=0, N_ELEMENTS(SUBREGIONS)-1 DO BEGIN
      REGION = SUBREGIONS[T]
      RPOS = WHERE_TAGS(SHPS,REGION)                                                                     ; Note, using WHERE_TAGS is much faster than STRUCT_GET when there are a large number of tags
      RSHP = SHPS.(RPOS)
      IF NONE(SUBAREAS) THEN _SUBAREAS = TAG_NAMES(RSHP) ELSE _SUBAREAS=SUBAREAS
      FOR S=0, N_ELEMENTS(_SUBAREAS)-1 DO BEGIN
        SUBAREA = _SUBAREAS[S]
        SPOS = WHERE_TAGS(RSHP,SUBAREA)                                                                  ; Note, using WHERE_TAGS is much faster than STRUCT_GET when there are a large number of tags
        SHP = RSHP.(SPOS)
        IF IDLTYPE(SHP) NE 'STRUCT' THEN CONTINUE                                                        ; Skip if the extracted information is not a structure (i.e. the outline or colors)
        SHP_BINS = SHP.SUBS
        IF VERBOSE THEN PFILE,SUBAREA,/G
                  
        IF STRMID(SUBAREA,0,1) EQ '_' THEN SUBAREA = STRMID(SUBAREA,1)
        IF IDLTYPE(DB) EQ 'STRUCT' THEN BEGIN   
          OK_DB = WHERE(DB.NAME EQ FP.NAME_EXT AND DB.REGION EQ REGION AND DB.SUBAREA EQ SUBAREA,COUNT_DB)
          IF COUNT_DB GE 1 AND UPDATE EQ 0 THEN BEGIN 
             IF VERBOSE THEN PFILE,/K , REGION + ' ' + SUBAREA                                           ; Skip if the NAME_EXT, REGION and SUBAREA are already in the DB
             CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ENDIF;IF COUNT_DB GE 1 AND UPDATE EQ 0 THEN BEGIN
        ENDIF;IF ANY(DB) AND IDLTYPE(DB) EQ 'STRUCT' THEN BEGIN
        
; ===> MAKE THE OUTPUT RECORD D FOR THE NEW_DB STRUCTURE     

        IF KEYWORD_SET(STACKED) THEN BEGIN
          ASZ = SIZE(ARRAY)
          CASE ASZ[0] OF
            2: IF N_ELEMENTS(STACKED_DB.NAME) NE 1 THEN MESSAGE, 'ERROR: Check the input data array size'
            3: IF ASZ[3] NE N_ELEMENTS(STACKED_DB.NAME) THEN MESSAGE, 'ERROR: The number of files in the data array do not match the number of elements in the "STACKED" database'
            ELSE: MESSAGE, 'ERROR: Expecting a 2 or 3 dimensional array.'
          ENDCASE
            
          FOR N=0, N_ELEMENTS(STACKED_DB.NAME)-1 DO BEGIN
            IF STACKED_DB[N].NAME EQ '' THEN CONTINUE
            D = CREATE_STRUCT('NAME',STACKED_DB[N].NAME,'FILE',STACKED_DB[N].FULLNAME,'STACKED_FILE',FILE,'DIR',FP.DIR,'EXTRACT_TAG',EXTRACT_LABEL)
            TAGNAMES =['MAP','SENSOR','PROD','ALG','PERIOD','PERIOD_CODE','MATH','L2SUB']
            FOR G=0, N_ELEMENTS(TAGNAMES)-1 DO D = CREATE_STRUCT(D,STRUCT_COPY(FP,TAGNAMES[G]))
            D = STRUCT_RENAME(D,'L2SUB','FILE_TYPE')
            D.PROD = APROD
            ;IF D.PROD NE VALIDS('PRODS',APROD) THEN MESSAGE,  'ERROR: Need to check that the "PROD" code is correct.'
          
            PSTR = PERIODS_READ(FP.PERIOD_CODE)
            D.PERIOD = STACKED_DB[N].PERIOD
            D.PERIOD_CODE = PSTR.STACKED_PERIOD_INPUT
            IF D.MATH EQ '' THEN D.MATH = INFO.DATATYPE
            D = CREATE_STRUCT(D,'UNITS',INFO.(WHERE(TAG_NAMES(INFO) EQ D[0].PROD,/NULL)).UNITS,'MTIME_FILE',GET_MTIME(FILE),'MTIME_SUBAREA',MTIME_SUBAREA)
            D = CREATE_STRUCT(D,'REGION',REGION,'SUBAREA',SUBAREA,'N_SUBAREA',NOF(SHP_BINS))                 ; Add subarea specific info to the structure

            ARR = MAPS_L3B_2ARR(ARRAY[*,*,N],MP=MP,BINS=ARR_BINS)
            ARR = ARR[SHP_BINS] 
            D = CREATE_STRUCT(D,STATS(ARR,/BASIC, STATS_OUT=OUTPUT_STATS))
            IF ~N_ELEMENTS(NEW_DB) THEN NEW_DB = D ELSE NEW_DB = [NEW_DB,D]                                              ; Concatenate the structure
            GONE,D
          ENDFOR ; STACKED_DB.NAME
          
          IF GARRAY NE [] THEN STOP ; NEED TO WORK OUT THE "GEO ARRAY" STATS
          
           ; Need to get the add the "stats" to the structure
          
        ENDIF ELSE BEGIN
          
          D = CREATE_STRUCT(STRUCT_COPY(FP,['NAME','FILENAME','L2SUB']))                  ; Set up the structure with the FILENAME and NAME
          TAGNAMES =['MAP','SENSOR','PROD','ALG','PERIOD','PERIOD_CODE','MATH']
          D = STRUCT_RENAME(D,'L2SUB','FILE_TYPE')
          
          FOR G=0, N_ELEMENTS(TAGNAMES)-1 DO $
            IF WHERE_TAGS(STR,TAGNAMES[G]) NE [] THEN D = CREATE_STRUCT(D,STRUCT_COPY(STR,TAGNAMES[G])) ELSE D = CREATE_STRUCT(D,STRUCT_COPY(FP,TAGNAMES[G]))
          D.PROD = APROD
          ;IF VALIDS('PRODS',D.PROD) NE VALIDS('PRODS',SPROD) THEN MESSAGE, 'ERROR: Need to check that the "PROD" code is correct.'
          IF WHERE_TAGS(STR,'DATA_UNITS') NE [] THEN UNIT = STR.DATA_UNITS ELSE UNIT = UNITS(D.PROD, /SI)
          
          D = CREATE_STRUCT(D,'UNITS',UNIT,'MTIME_FILE',MTIME_FILE,'MTIME_SUBAREA',MTIME_SUBAREA)          ; Add UNITS, MTIME_SUBAREA and MTIME_FILE to the strucgture
          IF D.MATH EQ '' THEN MATH = 'DATA'                                                               ; If math not 'STATS' or 'ANOMS' assume it is 'DATA'
           
          IF STRMID(SUBAREA,0,1) EQ '_' THEN SUBAREA = STRMID(SUBAREA,1)           
          D = CREATE_STRUCT(D,'REGION',REGION,'SUBAREA',SUBAREA,'N_SUBAREA',NOF(SHP_BINS))                 ; Add subarea specific info to the structure      
          
          IF ANY(ARR_BINS) THEN ARRAY = MAPS_L3B_2ARR(ARRAY,MP=MP,BINS=ARR_BINS)                           ; Convert the subset L3B array into a full L3B array
          ARR = ARRAY[SHP_BINS]                                                                            ; Subset the array with subarea subs
          D = CREATE_STRUCT(D,STATS(ARR,/BASIC, STATS_OUT=OUTPUT_STATS))                                   ; Add the stats data to the structure  
          IF GARRAY NE [] THEN BEGIN
            IF ANY(ARR_BINS) THEN GARRAY = MAPS_L3B_2ARR(GARRAY,MP=MP,BINS=ARR_BINS)  
            GARR = GARRAY[SHP_BINS]
            G = STATS(GARR,/BASIC, STATS_OUT=OUTPUT_STATS)
            G = STRUCT_RENAME(G, TAG_NAMES(G), 'GSTATS_'+TAG_NAMES(G))
            D = STRUCT_MERGE(D,G)
          ENDIF ELSE BEGIN
            G = STRUCT_2MISSINGS(STATS(0,/BASIC, STATS_OUT=OUTPUT_STATS))
            G = STRUCT_RENAME(G, TAG_NAMES(G), 'GSTATS_'+TAG_NAMES(G))
            G.GSTATS_N = 0
            IF ANY(NEW_DB) THEN IF STRUCT_HAS(NEW_DB,'GSTATS_N') THEN D = STRUCT_MERGE(D,G)
          ENDELSE    
          IF ~N_ELEMENTS(NEW_DB) THEN NEW_DB = D ELSE NEW_DB = [NEW_DB,D]                                              ; Concatenate the structure
          GONE,D
        ENDELSE ; NE "STACKED"            
      ENDFOR ; SUBAREAS LOOP
    ENDFOR ; REGIONS LOOP
  ENDFOR ; FILES LOOP
     
; ===> Merge any existing extracted data with current extracted data
  IF NEW_DB EQ [] THEN GOTO, DONE ; No new data added
  IF DB EQ [] THEN DB = NEW_DB ELSE IF ANY(NEW_DB) AND DB NE [] THEN DB = [DB,NEW_DB]  
  ;if has(file,'MONTH') then stop
    
; ===> Clean up the file and remove any duplicate stats (e.g. CLIMATOLOGICAL STATS)
  CHECK_OLD:
  OLD_FILES = []
  BS = WHERE_SETS(DB.SENSOR+'-'+DB.PROD+'-'+DB.MATH)
  FOR S=0, N_ELEMENTS(BS)-1 DO BEGIN ; LOOP THROUGH SENSORS
    SENSOR = VALIDS('SENSORS',BS[S].VALUE)
    IF N_ELEMENTS(SENSOR) NE 1 THEN MESSAGE, 'ERROR: Valid SENSOR not found'
    SDATES = SENSOR_DATES(SENSOR[0])
    SS = DB[WHERE_SETS_SUBS(BS[S])]
    
    PERIODS = ['DOY','WEEK','MONTH','MONTH3','ANNUAL','MANNUAL']
    FOR NTH = 0L, N_ELEMENTS(PERIODS)-1 DO BEGIN
      SUBS = WHERE_STRING(SS.NAME, PERIODS[NTH]+'_',COUNT)
      IF COUNT EQ 0 THEN CONTINUE
      FA = SS[SUBS]
      IF HAS(FA[0].MATH,'STATS') THEN BEGIN
        CASE PERIODS[NTH] OF
          'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(FA.PERIOD))
          'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(FA.PERIOD))
          'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
          'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(FA.PERIOD))
          'ANNUAL' : DATE_COMPARE = FA.PERIOD_CODE ;Previously DATE_2YEAR(PERIOD_2DATE(FA.PERIOD))
          'MANNUAL': DATE_COMPARE = FA.PERIOD_CODE
        ENDCASE
      ENDIF ELSE BEGIN
        FP = PARSE_IT(FA.NAME)
        SUBFILES = [] ; Rename files so only looking at the long-term mean period information
        FOR I=0, COUNT-1 DO SUBFILES = [SUBFILES,STRMID(FP[I].NAME_EXT,STRLEN(FP[I].PERIOD)+1)]
        SF = PARSE_IT(SUBFILES)
        OK = WHERE(SF.PERIOD EQ '',COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
        CASE PERIODS[NTH] OF
          'DOY'    : DATE_COMPARE = DATE_2DOY(PERIOD_2DATE(SF.PERIOD))
          'WEEK'   : DATE_COMPARE = DATE_2WEEK(PERIOD_2DATE(SF.PERIOD))
          'MONTH'  : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(SF.PERIOD))
          'MONTH3' : DATE_COMPARE = DATE_2MONTH(PERIOD_2DATE(SF.PERIOD))
          'ANNUAL' : DATE_COMPARE = SF.PERIOD_CODE ;Previously DATE_2YEAR(PERIOD_2DATE(FA.PERIOD))
          'MANNUAL': DATE_COMPARE = SF.PERIOD_CODE
        ENDCASE
      ENDELSE
            
      SETS = WHERE_SETS(DATE_COMPARE)
      FOR STH = 0L, N_ELEMENTS(SETS)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(SETS[STH])
        IF HAS(FA[0].MATH,'STATS') THEN FSUBS = PARSE_IT(FA[SUBS].NAME) ELSE FSUBS = PARSE_IT(SUBFILES[SUBS])
        OK = WHERE(FSUBS.YEAR_END LT MAX(FSUBS.YEAR_END),COUNT)
        IF COUNT GE 1 THEN BEGIN
          PRINT, '"OLD" climatology detected: Removing ' + FSUBS[OK].NAME + ' from the structure.'
          OLD_FILES = [OLD_FILES,FA[SUBS[OK]].NAME]
        ENDIF
        OK = WHERE(FSUBS.YEAR_START GT MIN(FSUBS.YEAR_START),COUNT)
        IF COUNT GE 1 THEN BEGIN
          PRINT, '"OLD" climatology detected: Removing ' + FSUBS[OK].NAME + ' from the structure.'
          OLD_FILES = [OLD_FILES,FA[SUBS[OK]].NAME]
        ENDIF

      ENDFOR ; SETS  
    ENDFOR ; PERIODS
  ENDFOR ; SENSORS
  
  IF OLD_FILES NE [] THEN BEGIN
    OLD_FILES = OLD_FILES[SORT(OLD_FILES)]
    OLD_FILES = OLD_FILES[UNIQ(OLD_FILES)]
    OK = WHERE_MATCH(OLD_FILES,DB.NAME,COUNT,INVALID=INVALID,NINVALID=NINVALID)
    IF COUNT EQ 0 OR NINVALID EQ 0 THEN MESSAGE, 'ERROR: Unable to find the "OLD" files in the structure'
    DB = DB[INVALID]
  ENDIF
  
  ; ===> Look for multiple files with the same period (e.g. two M_200202 files that have slightly differet names) and keep the most recent
  DUP_FILES = []
  B = WHERE_SETS(DB.PERIOD+'_'+DB.MAP+'_'+DB.SENSOR+'_'+DB.PROD+'_'+DB.ALG+'_'+DB.MATH+'_'+DB.SUBAREA+'_'+DB.REGION)
  OK = WHERE(B.N GT 1, COUNT)
  IF COUNT GT 0 THEN BEGIN
    B = B[OK]
    FOR NTH=0, N_ELEMENTS(B)-1 DO BEGIN
      SUBS = WHERE_SETS_SUBS(B[NTH])
      FSET = DB[SUBS]
      MTIMES = FSET.MTIME_FILE
      OK = WHERE(MTIMES EQ MAX(MTIMES),COUNT,COMPLEMENT=COMP)
      IF COUNT EQ N_ELEMENTS(FSET) THEN MESSAGE, 'ERROR: All files have the same MTIME.'
      DUP_FILES = [DUP_FILES,FSET[COMP].NAME]
    ENDFOR
  ENDIF
  
  IF DUP_FILES NE [] THEN BEGIN
    DUP_FILES = DUP_FILES[UNIQ(DUP_FILES,SORT(DUP_FILES))]
    OK = WHERE_MATCH(DUP_FILES,DB.NAME,COUNT,INVALID=INVALID,NINVALID=NINVALID)
    IF COUNT EQ 0 OR NINVALID EQ 0 THEN MESSAGE, 'ERROR: Unable to find the "DUPLICATE" files in the structure'
    DB = DB[INVALID]
  ENDIF
  
  STRUCT = DB                                                                                       ; Output structure
  IF UPDATE EQ 0 AND OLD_FILES EQ [] AND DUP_FILES EQ [] THEN GOTO, DONE                            ; Don't need to rewrite the savefile if no new files were added or old files removed
  
  DB = NAN_2INFINITY(DB)                                                                            ; Convert any nans to infinity
  DB = SORTED(DB,TAG = 'PERIOD')                                                                    ; Sort by period 
  STRUCT = DB                                                                                       ; Output structure
  SAVE,DB, FILENAME=SAVEFILE                                                                        ; Save the db
  SAVE_2CSV, SAVEFILE
  PFILE, SAVEFILE
  
  DONE:
  GONE, DB
  
  
END; #####################  END OF ROUTINE ################################
