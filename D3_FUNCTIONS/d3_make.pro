; $ID:	D3_MAKE.PRO,	2023-09-21-13,	USER-KJWH	$
;+
;;#############################################################################################################
PRO D3_MAKE, INPUT_FILES, D3_PROD=D3_PROD, OUT_PROD=OUT_PROD, STAT_TYPES=STAT_TYPES, PERIOD_OUT=PERIOD_OUT, DIR_OUT=DIR_OUT,L3BMAP=L3BMAP, MAP_OUT=MAP_OUT, FILE_LABEL=FILE_LABEL, $
  DATERANGE=DATERANGE, INIT=INIT, MED_FILL=MED_FILL, FIXNOISE=FIXNOISE, OUTFILE=OUTFILE, LOGLUN=LOGLUN, VERBOSE=VERBOSE, TESTING=TESTING, OVERWRITE=OVERWRITE
;
; PURPOSE: 
;   Makes a stacked array database file and a stacked array data file from data array files 
;
; CATEGORY:	
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:  
;   D3_MAKE, INPUT_FILES
;
; REQUIRED INPUTS: 
;   INPUT_FILES.. Either 1D (L3B) or 2D .SAV or .NC files 
;   
; OPTIONAL INPUTS  
;   D3_PROD....... The product name to extract from the files (needed with the L3B*.nc files) 
;   OUT_PROD...... Product name if different from the input (D3) prod
;   STAT_TYPES.... The stat types (e.g. MEAN, STD) to be included in the D3 file when the inputs are "STATS" files
;		PERIOD_OUT.... The output period code
;		DIR_OUT....... Output directory for the output files
;		L3BMAP........ A "subset" map to reduce the size of the L3B files (e.g. if L3BMAP = 'NEC', all data outside of the NEC area are masked and removed)
;   MAP_OUT....... Map name for the output data if different from the input files
;   FILE_LABEL.... The label for the output d3_file (output-for subsequent processing)
;   DATERANGE..... Use a specified daterange to subset the data
;   LOGLUN........ If provided, then lun for the log file
;   
; KEYWORDS:  
;   INIT.......... Initializes/rewrites both the D3_FILE and the D3_DB database file
;   TESTING....... Set if testing the D3_MAKE PROGRAM - will turn on VERBOSE and write out a csv
;   VERBOSE....... Prints program progress
;   OVERWRITE..... Overwrite d3_files if they exist
;   FIXNOISE...... Use FIX_NOISE to remove salt and pepper noise [default = 0]
;   MED_FILL...... Use MEDIAN_FILL to fill in missing data in ocean with good data from surrounding pixels [default = 0]
;
; OUTPUTS:
;   OUTFILE....... The name of the saved D3_FILE
;   A data file populated with the data from the input files
;   A database file with information about the data in the data file
;
; EXAMPLES:  
;   See D3_MAIN
;
; PROCEDURE:
; 0) All files must have the same input sensor, version/method, period code, product, algorithm, map, px and py
;
; 1) The sensor, method, map, product, algorith, px, and py are parsed from the first file name
;
; 2) A blank image is dimensioned based on the size and type of the first data image [PX,PY] and ; 2) 
;      and subscripts are determined from the landmask for the map
;
; 3) The largest date range is determined based on the range of dates from the input files
;
; 4) The program D3_DB is used to make a database info structure [DB] from the date_range
;    This DB includes all possible daily periods during the date_range;
;    The sequence (SEQ] along with period in this db are used to write[insert] each data image into the proper location in the D3_FILE
;      and for updating the D3_FILE based on mtimes, and images from new sav files
;
; 5) The D3_FILE is named as follows:
;    D3_FILE = DIR_OUT +'D3-PXY_'+ROUNDS(PX)+'_'+ ROUNDS(PY)+'-'+MAPP+'-'+ PROD +'-'+ ALG +'-DAT.FLT'
;
; 6) The D3_FILE is sequentially filled with the blank data, then closed
;
; 7) After reading each input file,
;      WHERE_NOISE is used to remove salt & pepper noise and
;      MEDIAN_FILL is used to fill in small areas of missing data with the median of surrounding good data (if the keyword is set)
;    
; 8) By using the period info in each sav file, along with the DB info, data are inserted into the associated D3_FILE
;      at the proper location-sequence based on the matching daily period_code in the DB
;
; 9) The filled D3_FILE and updated D3_DB are saved
;
; 10) Subsequent calls to D3_MAKE should provide all the files, both old and new
;
; 11) Any files missing from the D3 info database are inserted into the correct sequence in the d3_file based on their period [and associated seq].
;
; 12) New data files are appended to the D3_FILE after additional blank records are added and the D3_DB is updated
;
; 13) Additionaly, old data in the D3_FILE are replaced by updated data in files having a later mtime
;
; 14) Therefore, by constantly providing all the file names every time d3_make is called, (those already processed, those missing, 
;       and the latest files) the size of the D3_FILE will grow as needed (and does not have to be recreated).
;
; 15) If any of the files are earlier than the earliest in the DB then these files will be prepended to the old D3_FILE,
;     and the D3_DB will be recreated to reflect the new extended date_range of the D3_FILE
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written on Feb 18, 2015 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     with assistance from Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;
;  MODIFICATION HISTORY:
;			FEB 18, 2015 - JEOR: Initial code written,  Adapted from older PSERIES programs
;		  MAR 29, 2015 - JEOR: Rewritten
;		  APR 04, 2015 - JEOR: Using FILE_IT to store the D3_FILE name in !F
;		  SEP 10, 2016 - JEOR: Added more comments and documentation
;     SEP 11, 2016 - JEOR: Tested update [APPRND = 1] 
;     SEP 18, 2016 - JEOR: Streamlined 
;                          Added CASE FOR ACTION
;     SEP 27, 2016 - JEOR: Tested INIT, APPEND, UPDATE AND PREPEND [INIT] ACTIONS
;     OCT 04, 2016 - JEOR: Added CASE [1] OF
;     OCT 05, 2016 - JEOR: Final testing using 
;                          Removed FILE_IT
;     OCT 20, 2016 - JEOR: Added SENSOR_INFO AND CODE TO DEAL WITH THE L3B FILES
;     OCT 21, 2016 - KJWH: Changed D3_FILE to FILE_LABEL
;                          Determine the file type by looking at the .ext then set up the file information based on .sav or presumably .nc files
;                          Added D3_PROD as a required keyword for the L3B*.NC files to determine the product to extract from the .nc files
;                          Formatting
;                          Major overhaul to reduce redundant code
;     NOV 09, 2016 - JEOR: Added prepend action [IF JD_START LT DB_JD_START  THEN ACTION = 'PREPEND'    ; WHEN THERE ARE NEW FILES EARLIER THE BEGINNING OF THE DATE RANGE]
;     NOV 10, 2016 - JEOR: Final testing of prepend action
;     JAN 17, 2017 - KJWH: Added SENSOR_INFO(FILES) for the netcdf files
;                          **** Need to work out PROD info if D3_PROD is not provided for the netcdf files
;     JAN 20, 2017 - KJWH: Added D3_FILE keyword back to hold the name of the output file
;     JAN 23. 2017 - KJWH: Updated the PROD info for when working with L3B files
;                          Updates to the READ_NC section
;                          ***** Need to work out issues associated with finding the files that need to be UPDATED - added a stop and notes in the program
;     JAN 27, 2017 - KJWH: Fixed issues associated with finding files that needed to be added to the DATABASE
;     FEB 01, 2017 - JEOR: Added documentation on PREPENDING
;     FEB 01, 2017 - KJWH: Added L3BMAP to reduce the size of the large L3B files to a subset based on an input map (i.e. L3BMAP='NEC')
;                          ***** L3BMAP procedures still need sufficient testing *****
;     FEB 02, 2017 - KJWH: Changed the NAME written to the DB file for L3B files to be an INAME with the PROD-ALG - required upates throughout the program
;                          Removed PROD_INFO and STAT_TRANSFORMATION block
;                          Now saving the MOBINS info to a file to be used in D3_SAVES
;                          Removed the default PERIOD_CODE = 'D' and now checkig to make sure the FP.PERIOD_CODEs are 'D'
;                          Changed -DATA.FLT to -DAT.FLT to avoid errors when looking for VALID products (DATA is considered a valid product and -DATA.FLT interferes with finding the actual product)
;     FEB 06, 2017 - KJWH: Removed all CASE - ACTION statements.  Now should be able to PREPEND, APPEND and UPDATE all at the same time
;                          Fixed bug regarding N_BINS with .SAV files
;     FEB 07, 2017 - KJWH: Fixed bug when prepending the DB.  Now uses the mininum date from the original DB as the end date, then removes the last row before adding it to the original DB
;                          Fixed bug when appending the DB.  Now uses the maximum date from the original DB as the start date, then removes the first row before adding it to the original DB
;                          Updated documentaiton within the program
;     FEB 10, 2017 - KJWH: Fixed problems when subsetting a full array L3B .SAV file (e.g. AVHRR-L3B2)
;     APR 23, 2017 - JEOR: ADDED KEYS FIXNOISE, MED_FILL, AND COPIED RELEVANT CODE FROM D3_MED_FILL
;                          D3_MED_FILL IS NO LONGER NEEDED AS A SEPARATE STEP
;                          BLANK = MAPS_BLANK(AMAP)
;     APR 24, 2017 - JEOR: TEMP WORK AROUND FOR RI_SOUND
;     APR 27, 2017 - JEOR: REMOVED LAND_CODE [NOT NEEDED]
;                          REMOVED TEMP WORK AROUND FOR RI_SOUND
;     AUG 03, 3017 - KJWH: Formatting 
;                          Added: 
;                            IF LEVEL EQ 'L3' THEN FIXNOISE = 0
;                            IF LEVEL EQ 'L3' THEN MED_FILL = 0
;                            IF KEY(MED_FILL) THEN 
;     AUG 04, 2017 - KJWH: Added DATERANGE keyword                     
;                            IF NONE(DATERANGE) THEN DATERANGE = [] 
;                            IF KEY(DATERANGE) THEN FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT) ELSE COUNT = N_ELEMENTS(FILES)                        
;                            IF COUNT EQ 0 THEN MESSAGE,'ERROR: FILES ARE REQUIRED'
;                            IF KEY(DATERANGE) THEN D3_FILE = REPLACE(D3_FILE,'D3-','D3_'+STRJOIN(DATERANGE,'_')+'-')           
;                          Added OVERWRITE keyword to be consistent with other programs and SWITCHES   
;                            IF KEY(OVERWRITE)  THEN INIT      = 1  ; REINITIALIZE FILES IF OVERWRITE IS SET 
;    AUG 29, 2017 - KJWH: Now writing out a complete BINS file for any L3Bx map
;                           IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)
;    DEC 11, 2017 - KJWH: Changed the output from LL = MAPS_2LONLAT(L3BMAP) from LON/LAT to LONS/LATS    
;    DEC 14, 2017 - KJWH: Added BLANK = BLANK(MOBINS) to subset the BLANK array when using L3BMAP subsets      
;    APR 26, 2018 - KJWH: Changed LL.LONS and LL.LATS to LL.LON and LL.LAT     
;    NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                         Added LOGFILE keyword  
;    FEB 22, 2019 - KJWH: Updated the MAP_PXY label so that it works when "mapped" (not L3B) files are used  
;    Mar 01, 2019 - KJWH: Added COPYRIGHT info
;    Sep 09, 2019 - KJWH: Removed LOGFILE and now using an input LOGLUN to record the log information 
;    Jan 29, 2021 - KJWH: Updated documentation
;                         Moved to D3_FUNCTIONS
;                         Removed the requirement to only work with daily (D) files - now all input files must have the same period
;                         Added COMILE_OPT IDL2
;                         Changed all subscript () to []    
;    Jun 03, 2021 - KJWH: Added STAT_TYPES keyword to create multiple D3_FILES from STATS files.  The STAT_TYPE (e.g. MEAN, NUM, STD) indicate which data to extract from the STATS.SAV file
;                         Now looping on STAT_TYPES/D3_FILES - Would be good to figure out how to not have to read the file multiple times.
;                         Changed the FILES input to INPUT_FILES so that FILES can be reinitialized when looping through the STATS D3_FILES                       
;-
; ****************************************************************************************************

  ROUTINE_NAME  = 'D3_MAKE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

; ===> DEFAULTS
  IF KEY(TESTING)     THEN VERBOSE    = 1
  IF NONE(FIXNOISE)   THEN FIXNOISE   = 0        ; Default is to not remove the salt and pepper noise
  IF NONE(MED_FILL)   THEN MED_FILL   = 0        ; Default is to use median _fill
  IF NONE(DATERANGE)  THEN DATERANGE  = []       ; Make DATERANGE null if not provided
  IF KEY(OVERWRITE)   THEN INIT       = 1        ; Reinitialize files if OVERWRITE is set
  IF NONE(STAT_TYPES) THEN STAT_TYPES = ['MEAN'] ; Default stat to extract from "STATS" files
  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
    
; ===> FILE INFORMATION
  IF N_ELEMENTS(INPUT_FILES) EQ 0 THEN MESSAGE, 'ERROR: Input files are required.'
  IF KEY(DATERANGE) THEN INPUT_FILES = DATE_SELECT(INPUT_FILES,DATERANGE,COUNT=COUNT) ELSE COUNT = N_ELEMENTS(INPUT_FILES)      ; Subset the files based on the daterange (if provided)
  IF COUNT EQ 0 THEN MESSAGE,'ERROR: There are no files with the date range ' + STRJOIN(NUM2STR(DATERANGE,'-'))                 ; Make sure files are provided
  FP = PARSE_IT(INPUT_FILES,/ALL)                                                                                               ; Parse the file names
  S = SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD))) & FP = FP[S] & INPUT_FILES = INPUT_FILES[S]                                       ; Make sure files & fp in ascending order
  MTIMES = GET_MTIME(INPUT_FILES)                                                                                               ; Get the mtimes of the files
  IF SAME(FP.EXT) EQ 0 THEN MESSAGE, 'All input files must have the same EXTENSION'                                             ; Make sure all files have the same extension
 
; ===> Set up the PERIOD, DATERANGE and STAT information 
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                         ; Make sure all files have the same period_code
  PERIOD_CODE = FP[0].PERIOD_CODE                                                                                               ; Period code for the files
  PSTRUCT = PERIOD_2STRUCT(FP.PERIOD)
  DATE_RANGE = STRMID([PSTRUCT[0].DATE_START,PSTRUCT[-1].DATE_END],0,8)                                                         ; Get the date_range for all the files based on the first and last period code
  JD_START = DATE_2JD(FIRST(DATE_RANGE)) & JD_END = DATE_2JD(LAST(DATE_RANGE))                                                  ; Get the julian days of the date range
  IF NONE(PERIOD_OUT) THEN BEGIN
    IF STRLEN(PERIOD_CODE) EQ 1 THEN PERIOD_OUT = PERIOD_CODE+PERIOD_CODE ELSE MESSAGE, 'ERROR: Need to figure out how to work with other period codes'
  ENDIF
  SETS = PERIOD_SETS(PERIOD_2JD(FP.PERIOD),PERIOD_CODE=PERIOD_OUT)
  IF N_ELEMENTS(SETS) GT 1 THEN MESSAGE, 'ERROR: Check PERIOD_SETS output.'
  PERIOD_NAME = SETS.PERIOD
  IF ANY(DATERANGE) THEN PERIOD_NAME = PERIOD_OUT + '_' + DATERANGE[0] + '_' + DATERANGE[1]
  IF ~SAME(FP.MATH) THEN MESSAGE, 'All input files must have the same "MATH".'
  IF FP[0].MATH EQ 'STATS' THEN DO_STATS = 1 ELSE DO_STATS = 0

; ===> Set up the MAP and PRODUCT information based on the the input files   
  IF HAS(FP[0].EXT,'SAV') THEN BEGIN
    NAMES = FP.NAME                                                                                                             ; Extract the "names" of the files
    MAPS = VALIDS('MAPS',NAMES)                                                                                                 ; Look for valid maps
    TP = STRUCT_READ(INPUT_FILES[0],STRUCT=TMP)                                                                                 ; Read the first file
    TAGS = TAG_NAMES(TMP)                                                                                                       ; Get the tag names from the structure
    OKTAGS = WHERE(STRPOS(TAGS,'INDATA_') GE 0, COUNT)                                                                          ; Look for the INDATA tag (found in FRONTS files)
    IF COUNT GT 0 THEN INDATA = STRUCT_COPY(TMP,TAGS[OKTAGS]) ELSE INDATA = []                                                  ; Create a copy of the INDATA
    IF COUNT GT 0 THEN INTAGS = TAG_NAMES(INDATA) ELSE INTAGS = []                                                              ; Get the tags of the INDATA
    IF HAS(MAPS[0],'L3B') THEN BEGIN                                                                                            ; Determine if the files are L3B to look for bins in the structure
      IF HAS(TMP,'N_BINS') THEN N_BINS = TMP.N_BINS ELSE TS = MAPS_SIZE(TMP.MAP,PX=PX,PY=N_BINS)                                ; Get the number of bins in the file
      LEVEL = 'L3'                                                                                                              ; Set the level
    ENDIF ELSE LEVEL = ''
    IF SAME(VALIDS('PRODS',NAMES)+VALIDS('ALGS',NAMES)) EQ 0 THEN  MESSAGE, 'ERROR: PROD-ALG NAME NOT CONSISTENT IN ALL FILES'  ; Make sure the prod-alg combo are the same in all files
    IF NONE(D3_PROD) THEN APROD = VALIDS('PRODS',NAMES[0]) ELSE APROD = VALIDS('PRODS',D3_PROD) 
    IF NONE(D3_PROD) THEN D3_PROD = APROD
    IF APROD EQ '' THEN MESSAGE, 'MUST PROVIDE VALID D3 PRODUCT NAME'                                                           ; GET THE PRODUCT FOR THE SAV FILES
    IF NONE(FILE_LABEL) THEN _FILE_LABEL=FILE_LABEL_MAKE(INPUT_FILES[0]) ELSE _FILE_LABEL=FILE_LABEL                            ; CREATE THE FILE LABEL
    IF D3_PROD NE FP[0].PROD AND D3_PROD NE FP[0].PROD_ALG THEN _FILE_LABEL = REPLACE(_FILE_LABEL,FP[0].PROD_ALG,D3_PROD)
    NC_PROD = []
  ENDIF ELSE BEGIN ; IF NOT A .SAV FILE THEN ASSUME .NC FILE (NOTE, NOT ALL NETCDF FILES HAVE THE EXT .NC)
    IF NONE(D3_PROD) THEN APROD = VALIDS('PRODS',FP.NAME) ELSE APROD = VALIDS('PRODS',D3_PROD)                                  ; GET THE PRODUCT NAME FOR THE D3 SERIES
    IF APROD EQ '' THEN MESSAGE, 'Must provide valid d3 product name'                                                           ; ERROR IF NO VALID PRODUCT NAME                                                                                         
    SI = SENSOR_INFO(INPUT_FILES,PROD=D3_PROD)                                                                                  ; PARSE THE FILE NAMES BASED ON SENSOR INFO (NEEDED FOR L3B AND NC FILES)
    IF SAME(SI.PRODS) EQ 0 THEN MESSAGE, 'ERROR: PROD-ALG name not consistent in all files'                                     ; MAKE THE PRODUCT NAMES ARE THE SAME FOR ALL FILES
    IF SI[0].LEVEL EQ 'L3' THEN BEGIN                                                                                           ; GET L3 BINS INFO
      IF SAME(SI.N_BINS) NE 1 THEN MESSAGE, 'The bin numbers for all files must be the same'                                    ; ALL FILES MUST HAVE THE SAME NUMBER OF BINS
      N_BINS = SI[0].N_BINS                                                                                                     ; GET THE NUMBER OF BINS IN THE MAP (E.G. L3B4)
      LEVEL = 'L3'                                                                                                              ; ADD LEVEL
    ENDIF ELSE LEVEL = ''
    NC_PROD = SI[0].NC_PROD                                                                                                     ; NC_PROD IS USED TO READ THE PRODUCT FROM THE FILE LATER IN THE PROGRAM
    TEST_PROD = READ_NC(INPUT_FILES[0],/NAMES,/HDF5)                                                                            ; TEST THE PRODUCT NAME
    IF HAS(TEST_PROD,NC_PROD) EQ 0 THEN MESSAGE, 'The first file does not contain the requested product.'
    MAPS = SI[0].MAP                                                                                                            ; GET THE MAP                 
    IF NONE(FILE_LABEL) THEN _FILE_LABEL = SI[0].FILELABEL + '-' + D3_PROD ELSE _FILE_LABEL=FILE_LABEL                          ; CREATE THE FILE LABEL
    NAMES = SI.INAME + '-' + D3_PROD
  ENDELSE
  IF LEVEL EQ 'L3' THEN FIXNOISE = 0
  IF LEVEL EQ 'L3' THEN MED_FILL = 0
  
; ===> Get map info and make blank array
  IF SAME(MAPS) NE 1 THEN MESSAGE, 'ERROR: All files must be the same map'                                                      ; Make sure the files all have the same map
  AMAP = MAPS[0]                                                                                                                ; Map name                                                                                                                                
  IF N_ELEMENTS(MAP_OUT) EQ 1 THEN AMAP = MAP_OUT                                                                               ; If provided use the output map
  
  BLANK = MAPS_BLANK(AMAP)                                                                                                      ; Create blank array based on the map size
  LAND  = READ_LANDMASK(AMAP,/STRUCT)                                                                                           ; Read the landmask for the output map
  MASK  = READ_LANDMASK(AMAP,/LAND)                                                                                             ; Create a land only mask for median_fill                                                                                       
  IF IDLTYPE(LAND) EQ 'STRUCT' THEN LAND = LAND.LAND ELSE LAND = []                                                             ; If there is valid landmask, get the land subscripts from the structure
  MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                            ; Get the map size
  IF LEVEL EQ 'L3' THEN IF N_BINS NE PY THEN MESSAGE, 'ERROR: N_BINS does not match the expected PY for map ' + AMAP            ; If it is a level 3 file, then the number of bins must equal py

  ; ===> Get the bin numbers of the subset map
  MOBINS = []   
  IF N_ELEMENTS(L3BMAP) EQ 1 THEN BLANK = MAPS_L3B_SUBSET(MAPS_BLANK(AMAP),INPUT_MAP=AMAP,SUBSET_MAP=L3BMAP,OCEAN_BINS=MOBINS)$ ; Get the BIN values for the subset map
                                ELSE IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)                                         ; Get the BIN values of the input map if it is an L3B map and no subset map is provided
  IF MOBINS NE [] THEN BEGIN & PX = 1  & PY = N_ELEMENTS(MOBINS) & ENDIF                                                   ; Get the array sizes of the subset bins
                   

; ===> Set up the output directory
  IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FP[0].DIR,['NC','SAVE','STATS','ANOMS',FP[0].SUB],[REPLICATE('STACKED_FILES'+SL+PERIOD_OUT+'_D3',4),D3_PROD]) ; Set up the output directory
 ; IF NC_PROD NE [] THEN DIR_OUT = REPLACE(DIR_OUT,STRUPCASE(NC_PROD),D3_PROD)
  DIR_OUT = REPLACE(DIR_OUT,MAPS[0],AMAP)                                                                                       ; Change the map in the output directory
  IF ~HAS(DIR_OUT,AMAP) THEN MESSAGE, 'ERROR: Check the output directory MAP information'                                       ; Check the output directory is correct
  DIR_TEST, DIR_OUT                                                                                                             ; Make the output directory if it does not already exist

; ===> Define the D3 file names                                                                                                    
  IF MOBINS EQ [] THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) ELSE BEGIN                                      ; Create a MAP, PX, PY label
    IF N_ELEMENTS(MOBINS) EQ PY THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) $                                 ; Create a L3B MAP label             
                                ELSE MAP_PXY = AMAP + '-' + L3BMAP +'_SUBSET' + '-PXY_1_' + ROUNDS(N_ELEMENTS(MOBINS))          ; Create a L3BMAP specific MAP label              
  ENDELSE
  IF HAS(_FILE_LABEL,'PXY') EQ 0 THEN _FILE_LABEL = REPLACE(_FILE_LABEL, AMAP, MAP_PXY)                                         ; Add PXY_(PX)_(PY) to the file label
  
  IF NONE(D3_FILE) THEN BEGIN  
    D3_FILE      = DIR_OUT +  PERIOD_NAME + '-' + _FILE_LABEL + '-D3_DAT.FLT'                                                   ; Create the complete D3_FILE name if not provided
    D3_FILE      = REPLACE(D3_FILE,'--','-')                                                                                    ; Clean up the file name
  ENDIF ELSE IF (FILE_PARSE(D3_FILE)).DIR EQ '' THEN D3_FILE = DIR_OUT + STRUPCASE(D3_FILE)                                     ; Check that the D3_FILE has an output directory
  OUTFILE = D3_FILE                                                                                                             ; Create the output file variable
  
  D3_FILES = []
  IF KEYWORD_SET(DO_STATS) THEN BEGIN
    FOR D=0, N_ELEMENTS(STAT_TYPES)-1 DO D3_FILES = [D3_FILES,REPLACE(D3_FILE,'-D3_DAT.FLT','-' + STAT_TYPES[D] + '-D3_DAT.FLT')]; Create D3 file names with the STATS labels
    FOR D=0, N_ELEMENTS(D3_FILES)-1   DO IF KEY(INIT) AND EXISTS(D3_FILES[D]) THEN FILE_DELETE, D3_FILES[D], VERBOSE=VERBOSE    ; Delete D3 files if reinitializing the file
  ENDIF ELSE D3_FILES = D3_FILE
  
; ===> Loop through the D3_FILES (i.e. STAT_TYPES)  
  FOR D=0, N_ELEMENTS(D3_FILES)-1 DO BEGIN
    FILES = INPUT_FILES                                                                                                           ; Create a new FILES array from the INPUT_FILES
    D3_FILE = D3_FILES[D]
    STAT_TYPE = STAT_TYPES[D]
    D3_DB_FILE   = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_DB.SAV')                                                                    ; Create the D3_DB file name
    D3_META_FILE = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_METADATA.SAV')                                                              ; Create the D3_METADATA file name
    D3_BINS_FILE = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_BINS.SAV')
    CSV_MED_FILL = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_MED_FILL.CSV')
    
    IF KEY(INIT) AND EXISTS(D3_FILE)      THEN FILE_DELETE, D3_FILE, VERBOSE=VERBOSE                                              ; Delete D3 files if reinitializing the file
    IF KEY(INIT) AND EXISTS(D3_DB_FILE)   THEN FILE_DELETE, D3_DB_FILE, VERBOSE=VERBOSE                                           ; Delete D3 files if reinitializing the file
    IF KEY(INIT) AND EXISTS(D3_BINS_FILE) THEN FILE_DELETE, D3_BINS_FILE, VERBOSE=VERBOSE                                         ; Delete the D3_BIN file if reinitializing the file
      
; ===> Read or make necessary accessory files
    IF MOBINS NE [] AND EXISTS(D3_BINS_FILE) EQ 0 THEN SAVE, MOBINS, FILENAME=D3_BINS_FILE, /COMPRESS                             ; Write out the bin numbers for the L3B map subset
    DB = [] & IF FILE_TEST(D3_DB_FILE) EQ 1 THEN DB = STRUCT_READ(D3_DB_FILE) ELSE DB = D3_DB(DATE_RANGE,PERIOD_CODE=PERIOD_CODE) ; Read the D3_DB if it exists
   
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ***********************************************************************************************
;   DETERMINE THE ACTION TO TAKE WITH THE FILES BASED ON THE DATE RANGE AND MTIME OF THE FILES
; ***********************************************************************************************
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ===> Initialize the database if it does not exist
    IF FILE_TEST(D3_FILE) EQ 0 THEN BEGIN
      IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'Initializing: ' + D3_FILE & IF KEY(TESTING) THEN WAIT,1
      OPENW, D3_LUN, D3_FILE, /GET_LUN                                                                                            ; Create a new D3_FILE
      FOR NTH = 0L, NOF(DB)-1  DO WRITEU,D3_LUN,BLANK                                                                             ; Loop through the number of the files in the databaes and create a large blank array
      FREE_LUN, D3_LUN                                                                                                            ; Free and close the blank D3_FILE
      CLOSE,D3_LUN
      IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'Inserting data into: ' + D3_FILE & IF KEY(TESTING) THEN WAIT,5
      IF EXISTS(D3_DB_FILE) THEN FILE_DELETE, D3_DB_FILE                                                                          ; Remove the D3 database file if it exists
      DB = D3_DB(DATE_RANGE,PERIOD_CODE=PERIOD_CODE)                            ; Create the DB database
      DB.SEQ = INDGEN(N_TAGS(PERIOD_SETS(JD_GEN(DATE_RANGE),PERIOD_CODE=PERIOD_CODE,JD_START=JD_START,JD_END=JD_END,/NESTED)))                                                                        
    ENDIF ; INITITALIZING D3 AND DB DATABASES

; ===> Get the date_range of the files in the database
    DB_DATE_RANGE = STR_SEP(FIRST(DB.DATE_RANGE),';')
    DB_JD_START   = DATE_2JD(DB_DATE_RANGE[0]) & DB_JD_END = DATE_2JD(DB_DATE_RANGE[1])

; ===> Prepend the database if there are files that sequentially occur before the first file in the database
    IF JD_START LT DB_JD_START THEN BEGIN
      OK_PREPEND = WHERE(PERIOD_2JD(FP.PERIOD) LT DB_JD_START, COUNT_PREPEND)                                                     ; Look for all files that need to be prepended
      IF COUNT_PREPEND GE 1 THEN BEGIN
        FN = FP[OK_PREPEND]                                                                                                       ; Subset the parsed file info
        PFILES = FILES[OK_PREPEND]
        D = D3_DB([MIN(STRMID(PERIOD_2DATE(FN.PERIOD),0,8)),DB_DATE_RANGE[0]],PERIOD_CODE=PERIOD_CODE)                            ; Get the minimum date from the new files and the first date from the current DB
        DB = [D[0:-2],DB]                                                                                                         ; Prepend the DB (removing the last row since it will be the same as the first row in the original DB) to the DB
        DB.DATE_RANGE = STRJOIN(MINMAX(STRMID(PERIOD_2DATE(DB.PERIOD),0,8)),';')                                                  ; Get the daterange on all files
        DB[*].SEQ = UINDGEN(NOF(DB))                                                                                              ; Update the SEQ in the DB file 
        D3_TEMP = REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_TEMP.FLT')                                                                         ; Create TEMP file name
        OPENW, TEMP_LUN, D3_TEMP, /GET_LUN                                                                                        ; Open the TEMP file
        FOR NTH=0, NOF(PFILES)-1 DO WRITEU, TEMP_LUN, BLANK                                                                       ; Loop through the number of new files in the database and add blank arrays to the D3 file
        CLOSE,TEMP_LUN & FREE_LUN,TEMP_LUN                                                                                        ; Close the TEMP file
      ENDIF ELSE MESSAGE, 'ERROR: There should be files up PREPEND to the DATABASE'                                               ; IF COUNT_PREPEND GE 1 THEN BEGIN
      
      SIZE_D3   = (FILE_INFO(D3_FILE)).SIZE                                                                                       ; Size of the original D3 FILE
      SIZE_TEMP = (FILE_INFO(D3_TEMP)).SIZE                                                                                       ; Size of the TEMP D3 FILE
      SIZE_BOTH = SIZE_D3 + SIZE_TEMP                                                                                             ; Combined size of the D3 and TEMP files
      OPENU,TEMP_LUN,/GET_LUN,D3_TEMP,/APPEND                                                                                     ; Open the TEMP D3 FILE
      OPENU,D3_LUN,/GET_LUN,D3_FILE                                                                                               ; Open the original D3 FILE
      COPY_LUN,D3_LUN,TEMP_LUN,/EOF,TRANSFER_COUNT=TRANSFER_COUNT                                                                 ; Copy the original file into the TEMP file 
      IF KEY(VERBOSE) THEN PLUN, LOG_LUN, TRANSFER_COUNT
      IF TRANSFER_COUNT NE SIZE_D3 THEN MESSAGE,'ERROR: TRANSFER_COUNT DOES NOT EQUAL SIZE_D3'                                    ; Ensure the transfer_count is the same size as the original D3
      CLOSE,TEMP_LUN                                                                                                              ; Close the TEMP file
      FREE_LUN,TEMP_LUN                                                                                                           ; Free the TEMP LUN
      CLOSE,D3_LUN                                                                                                                ; Close the D3 FILE
      SIZE_TEMP = (FILE_INFO(D3_TEMP)).SIZE                                                                                       ; Size of the merged d3 and temp file
      IF SIZE_TEMP EQ SIZE_BOTH THEN BEGIN                                                                                        ; If the sizes match:
        FILE_DELETE,D3_FILE,/VERBOSE                                                                                              ;   delete the original d3 file
        FILE_MOVE,D3_TEMP,D3_FILE,/VERBOSE                                                                                        ;   rename the temp file to d3_file
      ENDIF ELSE MESSAGE, 'ERROR: The size of the new file is not correct'                                                        ; IF SIZE_TEMP EQ SIZE_BOTH THEN BEGIN
    ENDIF ; JD_START LT DB_JD_START
    
; ===> Append the database if there are files that sequentially occur after the first file in the database                          
    IF JD_END GT DB_JD_END THEN BEGIN                                                                                             ; Look for new dates/files to add to the DB  
      OK_APPEND = WHERE(PERIOD_2JD(FP.PERIOD) GT DB_JD_END, COUNT_APPEND)                                                         ; Look for all files that need to be appended to the original file         
      IF COUNT_APPEND GE 1 THEN BEGIN                                                                                             ; Find where the period of the files does not match the period of the database
        FN = FP[OK_APPEND]                                                                                                        ; Subset the parsed file info
        NFILES = FILES[OK_APPEND]                                                                                                 ; Subset the files to append
        D = D3_DB([DB_DATE_RANGE[1],MAX(STRMID(PERIOD_2DATE(FN.PERIOD),0,8))],START=MAX(DB.SEQ),PERIOD_CODE=PERIOD_CODE)          ; Get the date_range for the new files
        DB = [DB,D[1:*]]                                                                                                          ; Append DB (minus the first row that is a repeat of the last row of the orignial DB) to the DB
        DB.DATE_RANGE = STRJOIN(MINMAX(STRMID(PERIOD_2DATE(DB.PERIOD),0,8)),';')                                                  ; Get date range on all files
        DB[*].SEQ = UINDGEN(NOF(DB))  
        OPENU, D3_LUN, D3_FILE, /GET_LUN,/APPEND                                                                                  ; Open D3_FILE for appending
      ENDIF ELSE FILES = []             ; IF N_NEW GE 1 THEN BEGIN
      FOR NTH=0, NOF(NFILES)-1 DO WRITEU, D3_LUN, BLANK                                                                           ; Loop through the number of new files in the database and add blank arrays to the D3 FILE
      CLOSE, D3_LUN                                                                                                               ; Close the D3 DB
    ENDIF ; JD_END GT DB_JD_END
  
; ===> Find files that are missing in the db or need to be updated based on mtime    
    IF ANY(SI) THEN NAME = SI.INAME + '-' + D3_PROD ELSE NAME = FP.NAME                                                           ; Create the file names to search for in the D3 DB
    OK_MATCH  = WHERE_MATCH(DB.NAME, NAME, COUNT, VALID=VALID, COMPLEMENT=COMPLEMENT, INVALID=INVALID, NCOMPLEMENT=NCOMPLEMENT, NINVALID=NINVALID)
    IF COUNT GE 1 THEN BEGIN                                                                                                      ; If any of the files match the names in the DB, then look for more recent files
      DMATCH    = DB[OK_MATCH]                                                                                                    ; Matching files from the DB
      FMATCH    = FILES[VALID]                                                                                                    ; Matching files from the input files
      OK_UPDATE = WHERE(GET_MTIME(FMATCH)-DMATCH.MTIME GE 60, COUNT_UPDATE,/NULL)                                                 ; Find where the file MTIME is more than 60 seconds greater than the MTIME in the DB
      IF COUNT_UPDATE GT 0 THEN FMATCH = FMATCH[OK_UPDATE]                                                                        ; Create a subset of files to be updated
    ENDIF ELSE COUNT_UPDATE = 0 ; COUNT GE 1                                                                                      ; If there are 0 matching files, then make count_update = 0
    IF NINVALID GT 0 THEN FMISSING = FILES[INVALID]                                                                               ; Look for files that are not in the DB
    FILES = []                                                                                                                    ; Create null array of file names
    IF COUNT_UPDATE GT 0 THEN FILES = FMATCH                                                                                      ; Add list of files that need to be updated
    IF NINVALID     GT 0 THEN FILES = [FILES,FMISSING]                                                                            ; Add list of files that are missing in the DB
    IF FILES EQ [] THEN GOTO, SKIP_UPDATE                                                                                         ; If no files to update then skip to the END >>>>>>>>>>>>>>>>>>>
    FP = PARSE_IT(FILES)                                                                                                          ; Parse the files to be updated
    IF ANY(SI) THEN SI = SENSOR_INFO(FILES)                                                                                       ; Get the sensor info for files to be updated
    
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ***********************************************************************************************
;   READ THE FILES AND ADD THEM TO THE D3 DATABASE
; ***********************************************************************************************
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ===> Add data to the D3_FILE via association
    OPENU, D3_LUN, D3_FILE,/GET_LUN                                                                                               ; Open the D3_FILE
    A = ASSOC(D3_LUN, BLANK)                                                                                                      ; Make an associated variable
  
    FOR NTH = 0,N_ELEMENTS(FILES) - 1 DO BEGIN                                                                                    ; Loop through the files
      FILE = FILES[NTH]
      APERIOD = FP[NTH].PERIOD                                                                                                    ; Get the period
      POF, NTH, FILES, OUTTXT=OUTTXT,/QUIET
      PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LOG_LUN
      BINS = []                                                                                                                   ; Create a null array of bins
      IF HAS(FP[NTH].EXT,'SAV') THEN BEGIN                                                                                        ; Look at the file extension
        IF INDATA NE [] THEN BEGIN 
          N = STRUCT_READ(FILE, TAG=APROD, BINS=BINS, STRUCT=S)                                                                   ; Read the .SAV file with the structure 
          FOR I=0, N_ELEMENTS(INTAGS)-1 DO BEGIN                                                                                  ; Loop through the INDATA tags
            INDAT = STRUCT_GET(S,INTAGS[I])                                                                                       ; Get the INDATA value 
            IF INDAT NE INDATA.(I) THEN MESSAGE, 'ERROR: Input data metadata do not match.'                                       ; Confirm that the INDATA are the same
          ENDFOR
        ENDIF ELSE N = STRUCT_READ(FILE, BINS=BINS)                                                                               ; Read the .SAV without the structure
        IF IDLTYPE(N) EQ 'STRUCT' THEN BEGIN
          IF ~KEYWORD_SET(DO_STATS) THEN MESSAGE, 'ERROR: Data returned as a structure instead of an array'                       ; Check to make sure N is a data array and not a structure
          N = GET_TAG(N, STAT_TYPE)
        ENDIF
      ENDIF ELSE BEGIN
        N = READ_NC(FILE,PROD=NC_PROD,BINS=BINS,/DATA)                                                                            ; IF .NC, get the ncprod data and the bins from the netcdf file
        IF IDLTYPE(N) EQ 'STRING' THEN MESSAGE, N                                                                                 ; Check to make sure the file was read properly
      ENDELSE
    
; ===> Clean up and fill in the data    
      IF KEY(FIXNOISE) THEN N = FIX_NOISE(N)                                                                                      ; Use FIX_NOISE to remove the salt & pepper noise
      IF KEY(MED_FILL) THEN N = MEDIAN_FILL(N, BOX=[3,5], FRACT_GOOD=FRACT_GOOD,MASK=MASK,COUNT_FILLED) ELSE COUNT_FILLED = 0     ; Use a MEDIAN FILL to smooth out the data
      S = CREATE_STRUCT('SEQ',NTH,'NAME',FP[NTH].NAME,'COUNT_FILLED',TOTAL(COUNT_FILLED))                                         ; Create a structure with output information
      IF NONE(OUT) THEN OUT = S ELSE OUT = [OUT,S]                                                                                ; Add the structure to the output structure

; ===> Subset the data by the BINS if provided  
      IF MOBINS EQ [] THEN BEGIN                                                                                                  ; If no subset map bins
        IF BINS NE [] THEN BEGIN                                                                                                  ; If no bins
          _DATA = BLANK                                                                                                           ; Make a blank array
          _DATA[BINS] = N                                                                                                         ; Fill in the blank array associated with the specified bin info with valid data
        ENDIF ELSE _DATA = N  ; BINS NE []                                                                                        ; If no bins or mobins, then _DATA = N
      ENDIF ELSE BEGIN  ; MOBINS = []
        IF BINS NE [] THEN BEGIN
          _DAT = FLTARR(N_BINS) & _DAT[*,*] = MISSINGS(_DAT)                                                                      ; Make a blank array for the full l3b array
          _DAT[BINS] = N                                                                                                          ; Fill in the full l3b array with data
          _DATA = BLANK                                                                                                           ; Create a blank array the size of MOBINS
          _DATA = _DAT[MOBINS]                                                                                                    ; Fill in the blank array with just the MOBINS data
          GONE, _DAT
        ENDIF ELSE _DATA = N[MOBINS] ; BINS NE []                                                                                 ; Subset the full array (n) with MOBINS
      ENDELSE
      GONE, N
  
      SEQ = WHERE(DB.PERIOD EQ APERIOD,COUNT)                                                                                     ; Find the sequence in the associated file by finding the period in the D3 database
      IF COUNT NE 1 THEN MESSAGE,'ERROR: Matching period not found in the DB'                                                     ; Write out error if the period was not found in the database
      A[SEQ] = _DATA                                                                                                              ; Write the data in the D3_FILE at the appropriate sequence
  
      IF ANY(SI) THEN NAME=SI[NTH].INAME+'-'+D3_PROD ELSE NAME=FP[NTH].NAME                                                       ; Create the file names to add to the D3 DB
      DB[SEQ].FULLNAME = FILE
      DB[SEQ].NAME = NAME                                                                                                         ; Add the file name to the D3_DATABASE
      DB[SEQ].MTIME = GET_MTIME(FILE)                                                                                             ; Add the MTIME to the D3_DATABASE
      DB[SEQ].JD = DATE_2JD(PERIOD_2DATE((FP[NTH]).PERIOD))                                                                       ; Add the PERIOD to the D3_DATABASE
    ENDFOR;FOR NTH = 0,N_ELEMENTS(FILES) - 1 DO BEGIN
  
; ===> Write out the MEDIAN fill structure
    IF KEY(MED_FILL) THEN CSV_WRITE,CSV_MED_FILL,OUT
    
    SKIP_UPDATE:

; ===> Close the D3_FILE and save the D3 database
    IF ANY(D3_LUN) THEN BEGIN
      FREE_LUN, D3_LUN
      CLOSE,D3_LUN
      STRUCT_WRITE, DB, FILE=D3_DB_FILE
      IF KEY(VERBOSE) THEN PFILE, D3_FILE, LOGLUN=LOG_LUN
    ENDIF;IF ANY(D3_LUN) THEN BEGIN
    
; ===> Create the metadata for the D3 database
    D3_METADATA, D3_DB_FILE, INPUT_DATA=INDATA
  ENDFOR ; D3_FILES (STAT_TYPES) loop  

; ===> Write out a TEMP csv file for troubleshooting
  IF KEY(TESTING) THEN BEGIN
    CSV = REPLACE(D3_DB_FILE,'.SAV','.CSV')
    CSV_WRITE,CSV,DB
    IF KEY(VERBOSE) THEN PFILE, CSV, LOGLUN=LOG_LUN
  ENDIF ; KEY(TESTING)
 
  DONE:
END; #####################  END OF ROUTINE ################################
