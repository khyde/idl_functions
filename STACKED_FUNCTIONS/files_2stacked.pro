; $ID:	FILES_2STACKED.PRO,	2023-09-21-13,	USER-KJWH	$
PRO FILES_2STACKED, FILES, PRODS=PRODS, STAT_TYPES=STAT_TYPES, D3_FILES=D3_FILES, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, L3BSUBMAP=L3BSUBMAP, FILE_LABEL=FILE_LABEL, $
  MAINPROD=MAINPROD, DATERANGE=DATERANGE, OUTFILE=OUTFILE, LOGLUN=LOGLUN, DOY=DOY, VERBOSE=VERBOSE, TESTING=TESTING, OVERWRITE=OVERWRITE

;+
; NAME:
;   FILES_2STACKED
;
; PURPOSE:
;   Make stacked data file as an "ORDERED HASH" that contains the DB database, metadata and stacked data files in a single file
;
; CATEGORY:
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:
;   FILES_2STACKED, FILES
;
; REQUIRED INPUTS:
;   FILES......... An array of file(s) to be added to the D3 file
;
; OPTIONAL INPUTS:
;   PRODS.......... The product name(s) to add to the stacked file
;   STAT_TYPES..... The name of the "stats" to extract from the files
;   D3_FILES....... The name of the output D3 file(s)
;   MAP_OUT........ The name of the output map if not the default for the input file
;   L3BSUBMAP...... The subset map for the L3B file (e.g. NWA)
;   FILE_LABEL..... The label for the file name
;   DIR_OUT........ The output directory
;   MAINPROD..... The "main" product name for the output name if the file contains more than one product (e.g. RRS)
;   DATERANGE...... The daterange for the stacked files
;   LOGLUN......... The lun for the log file
;
; KEYWORD PARAMETERS:
;   DOY............. If set, will create 365 DOY files that will be used when calculating the climatological DOY stats
;   VERBOSE......... Print processing steps
;   TESTING......... To test the generation of the D3FILE
;   OVERWRITE....... Delete and rewrite the D3FILE if it exists
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   OUTFILE......... The name(s) of the output file
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 25, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Jun 25, 2021 - KJWH: Initial code written (adapted from D3_MAKE)
;   Jul 07, 2021 - KJWH: Updated the metadata information
;                        Changed the original "metadata" to INFO and now using the information from NETCDF_INFO to generate the metadata
;                        Added INFILES and ORGFILES to the D3 database
;   Nov 05, 2021 - KJWH: Added LOGLUN keyword and PLUN statements to add information to the log file
;   Oct 06, 2022 - KJWH: Can now get the data from both the IMAGE and DATA tags in a .SAV structure
;   Oct 13, 2022 - KJWH: Replaced D3_PERIODS(FP.PERIOD,SENSOR=SENSOR) with D3HASH_PERIOD_SETS(FILES, OUTPERIOD='DD')
;   Oct 17, 2022 - KJWH: Now using the D3_FILE as input to D3HASH_DB
;   Oct 27, 2022 - KJWH: Can now use stacked files as input (e.g. make a WW_timeseries stacked file using annual WW stacked files as input)
;                        Now saving the DOY stacked files in the STACKED_TEMP directory
;   Nov 07, 2022 - KJWH: Now only doing the METADATA steps if the file is being saved
;   Nov 14, 2022 - KJWH: Changed name from D3HASH_MAKE to SAVE_2STACKED (D3HASH_MAKE will now be used to create the HASH objects)
;   Nov 16, 2022 - KJWH: Now using MAPS_L3B_SUBSET to get the bin numbers for the subset map
;                        Changed input parameter L3BMAP to L3BSUBMAP
;                        Added code to work with input NC files
;  Nov 22, 2022 - KJWH: Now looking for the subset map name in the file name
;  Nov 23, 2022 - KJWH: Fixed a bug with STATNAME vs NAME and STATFILE vs FULLNAME - now looking at the tags in the DB first
;  Dec 01, 2022 - KJWH: Changed the name from SAVE_2STACKED to FILES_2STACKED since it works with both SAVE and NC files
;  Dec 05, 2022 - KJWH: Added sensor specific information so that it now works with OCCCI, GLOBCOLOUR, MUR and AVHRR .nc files
;  Apr 28, 2023 - KJWH: Now renaming DOY files to the current year even if new data was not added (need to confirm it will update when new data are available)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FILES_2STACKED'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  ; ===> Set up defaults for optional inputs and keywords
  IF N_ELEMENTS(DATERANGE)  EQ 0 THEN DATERANGE  = []                                                                           ; Make DATERANGE null if not provided
  IF N_ELEMENTS(LOGLUN)     NE 1 THEN LUN = [] ELSE LUN = LOGLUN                                                                ; Set up the LUN to record in the log file
  IF N_ELEMENTS(STAT_TYPES) EQ 0 THEN STAT_TYPES = ['MEAN']  & IF STAT_TYPES[0] EQ '' THEN STAT_TYPES=[]  ; Default stat to extract from "STATS" files
  IF N_ELEMENTS(ANOM_TYPES) EQ 0 THEN ANOM_TYPES = ['ANOMALY']

  ; ===> Check the files
  IF N_ELEMENTS(FILES) EQ 0 THEN MESSAGE, 'ERROR: Input files are required.'
  IF DATERANGE NE [] THEN FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT) ELSE COUNT = N_ELEMENTS(FILES)                       ; Subset the files based on the daterange (if provided)
  IF COUNT EQ 0 THEN MESSAGE,'ERROR: There are no files with the date range ' + STRJOIN(NUM2STR(DATERANGE,'-'))                 ; Make sure files are provided

  ; ===> Get general information from the file names
  FP = PARSE_IT(FILES,/ALL)                                                                                                     ; Parse the file names
  IF ~SAME(FP.EXT) THEN MESSAGE, 'ERROR: All input files must have the same EXTENSION'                                          ; Make sure all files have the same extension
  IF ~SAME(FP.SENSOR) THEN MESSAGE, 'ERROR: All input files must have the same SENSOR'                                          ; Make sure all files are from the same dataset
  NAME = FP[0].NAME

  ; ===> Get PERIOD and DATERANGE information
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                         ; Make sure all files have the same period_code
  S = SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD))) & FP = FP[S] & FILES = FILES[S]                                                   ; Make sure files & fp in ascending order
  MTIMES = GET_MTIME(FILES)                                                                                                     ; Get the MTIME of the files
  PERIOD_CODE = FP[0].PERIOD_CODE                                                                                               ; Period code for the files
  OUTPERIOD = (PERIODS_READ(PERIOD_CODE)).STACKED_PERIOD_OUTPUT                                                                 ; Get the output period code
  IF KEYWORD_SET(DOY) THEN OUTPERIOD = 'DOY'                                                                                    ; Change the output period to DOY
  IF PERIOD_CODE EQ OUTPERIOD AND OUTPERIOD NE 'DD' THEN BY_YEAR = 0 ELSE BY_YEAR = []                                                                ; Set the BY_YEAR keyword to 0 if the input and output period codes are the same
  PERIOD_SET = D3HASH_PERIOD_SETS(FILES, OUTPERIOD=OUTPERIOD, BY_YEAR=BY_YEAR)                                                  ; Get the "sets" of input files for each output file based on the period
  IF STRPOS(FP[0].L2SUB,'STACKED') GE 0 THEN STACKED_INFILE = 1 ELSE STACKED_INFILE = 0                                         ; Determine if the input files are "stacked" files
  IF STRPOS(FP[0].L2SUB,'SOURCE')  GE 0 THEN NC_INFILE = 1      ELSE NC_INFILE = 0                                              ; Determine if the input files are netcdf files
  STACKED_NC = 0 ; Used for specific input files such as the OCCCI Monthly files

  ; ===> Check the MAP and PRODUCT information based on the the input files
  IF ~SAME(FP.MAP)        THEN MESSAGE, 'All input files must have the same "MAP".'                                             ; Make sure all files have the same MAP
  IF ~SAME(FP.MAP_SUBSET) THEN MESSAGE, 'All input files must have the same "Subset MAP".'                                      ; Make sure all files have the same subset MAP
  IF ~SAME(FP.PROD_ALG)   THEN MESSAGE, 'All input files must have the same "PROD" and "ALG".'                                  ; Make sure all files have the same product and algorithm
  IF N_ELEMENTS(PRODS) EQ 0 THEN HPRODS = VALIDS('PRODS',NAME) ELSE HPRODS = VALIDS('PRODS',PRODS)                              ; Get the "product" name

  ; ===> Check the data type (e.g. STATS, ANOMS, "data") of the files
  IF ~SAME(FP.MATH) THEN MESSAGE, 'All input files must have the same "MATH".'                                                  ; Check the type of input data
  IF FP[0].MATH EQ 'STATS' OR FP[0].MATH EQ 'STACKED_STATS' THEN DO_STATS = 1 ELSE DO_STATS = 0                                 ; Look for STATS files
  IF FP[0].MATH EQ 'ANOM'  OR FP[0].MATH EQ 'STACKED_ANOM'  THEN DO_ANOMS = 1 ELSE DO_ANOMS = 0                                 ; Look for ANOM files
  IF HAS(FP[0].PROD, 'GRAD_') THEN BEGIN
    DO_STATS=0 & DO_GRAD_STATS=1
  ENDIF ELSE DO_GRAD_STATS=0
  IF N_ELEMENTS(HPRODS) GT 1 AND KEYWORD_SET(DO_STATS) THEN MESSAGE, 'ERROR: More than one product found in the stats file - need to update code to work with stats of multiple products'
  IF KEYWORD_SET(DO_STATS) AND KEYWORD_SET(DO_ANOMS) THEN MESSAGE, 'ERROR: Keywords DO_STATS and DO_ANOMS can not both be set. Check the input files'

  ; ===> Get netcdf specific map and product information
  OCCCI_1KM = 0     ; Keyword to indicate the special OCCCI 1KM input data
  STACKED_NN = 0    ; Keyword to indicate the special OCCCI Monthly input data
  IF KEYWORD_SET(NC_INFILE) THEN BEGIN                                                                                          ; Check to see if NC files                          
    SI = SENSOR_INFO(FILES[0])                                                                                                  ; Get SENSOR specific information
    CASE SI.COVERAGE OF                                                                                                         ; Convert the COVERAGE to a L3B MAP
      '1KM': MAPS = 'L3B1'  
      '2KM': MAPS = 'L3B2'                      
      '4KM': MAPS = 'L3B4'
      '9KM': MAPS = 'L3B9'
    ENDCASE    
    IF SI.SENSOR EQ 'OCCCI' AND SI.COVERAGE EQ '1KM' THEN OCCCI_1KM = 1
    IF SI.SENSOR EQ 'OCCCI' AND SI.PERIOD_CODE EQ 'MM' THEN STACKED_NC = 1
    NPRODS = STRSPLIT(SI.NC_PROD,SI.DELIM,/EXTRACT)                                                                             ; Get the NC file product names
    OPRODS = STRSPLIT(SI.PRODS,SI.DELIM,/EXTRACT)                                                                               ; Get the equivalent valid PROD names
    OK = WHERE_MATCH(OPRODS, PRODS, VALID=VALID,COUNT)                                                                          ; Find the nc file products that match the requested products
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + PRODS + ' not found in file.'
    NPRODS = NPRODS[OK]                                                                                                         ; Subset the NC file products
    VPRODS = PRODS[VALID]                                                                                                       ; Subset the requested products based on the products found in the NC file                                                                                                   
    IF ~N_ELEMENTS(MAINPROD) THEN PROD_LABEL=SI.PROD_LABEL ELSE PROD_LABEL=STRUPCASE(MAINPROD)+'-'+VALIDS('ALGS',SI.PROD_LABEL)                                                                                                       ; Get the main product lable (e.g. CHLOR_A or SST) 
    IF STRPOS(PROD_LABEL,'-') EQ STRLEN(PROD_LABEL)-1 THEN PROD_LABEL = STRMID(PROD_LABEL,0,STRLEN(PROD_LABEL)-1)
    MAIN_PROD = VALIDS('PRODS',PROD_LABEL)                                                                                 ; Make sure the main product is a valid PROD
    IF MAIN_PROD EQ '' THEN MESSAGE, 'ERROR: ' + PROD_LABEL + ' is not a "valid" product'

    IF FP[0].SENSOR EQ '' AND N_ELEMENTS(FILE_LABEL) EQ 0 THEN FILE_LABEL = STRJOIN([SI.SENSOR, SI.METHOD,SI.COVERAGE,SI.MAP,MAIN_PROD],'-')
    IF FP[0].SENSOR EQ '' THEN FP.SENSOR = SI.SENSOR
    IF FP[0].MAP EQ '' THEN FP.MAP = SI.MAP
    
  ENDIF ELSE BEGIN
    MAPS = FP[0].MAP                                                                                                            ; Get the map name from the file name
    SI = []                                                                                                                     ; Make SI (used for SENSOR_INFO for the NC files) null
    MAIN_PROD=[]                                                                                                                ; Make the MAIN_PROD (used for the NC files) null
    IF PRODS EQ [] THEN PROD_LABEL=FP[0].PROD_ALG ELSE PROD_LABEL = PRODS      ; Make the PROD_LABEL (used for NC files) null
  ENDELSE
  IF N_ELEMENTS(MAP_OUT) GT 0 THEN MAPS = MAP_OUT                                                                                    ; Set the output map if provided
  
  FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
    AMAP = MAPS[M]
    MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                            ; Get the size of the map
  
    ; ===> Check the SUBSET map
    IF FP[0].MAP_SUBSET NE '' AND ~KEYWORD_SET(OCCCI_1KM) THEN BEGIN                                                                                          ; Check to see if the input file name already has a SUBSET map
      SUBSET = REPLACE(FP[0].MAP_SUBSET,'_SUBSET','')                                                                             ; Get the subset map name
      IF ~N_ELEMENTS(L3BSUBMAP) THEN L3BSUBMAP = SUBSET                                                                           ; Set the L3BSUBMAP based on this input subset map
      IF L3BSUBMAP NE SUBSET THEN MESSAGE, 'ERROR: The input subset map (' + L3BSUBMAP + ') does not match the file subset map (' + SUBSET + ')' ; NOTE - there may be a work around that is needed for different submaps
    ENDIF
  
    ; ===> Make the FILE LABEL
    IF N_ELEMENTS(FILE_LABEL) NE 1 THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0],LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP','PROD','ALG','DAYNIGHT','MATH']) ELSE _FILE_LABEL=FILE_LABEL                            ; Create the file label
    IF N_ELEMENTS(HPRODS) EQ 1 THEN IF HPRODS NE FP[0].PROD AND HPRODS NE FP[0].PROD_ALG THEN _FILE_LABEL = REPLACE(_FILE_LABEL,FP[0].PROD_ALG,PRODS)  ; Update the PRODs in the label
    IF MAIN_PROD NE [] THEN _FILE_LABEL = REPLACE(_FILE_LABEL,FP[0].PROD_ALG,PROD_LABEL)                                          ; Update the MAIN_PROD in the label
    IF FP[0].MAP NE AMAP THEN _FILE_LABEL = REPLACE(_FILE_LABEL,FP[0].MAP,AMAP)                                                   ; Update the MAP in the label
  
    ; ===> Get the bin numbers of the subset map
    MOBINS = []                                                                                                                   ; Create a null array for the MAP_OUT BINS
    IF N_ELEMENTS(L3BSUBMAP) EQ 1 THEN BLANK = MAPS_L3B_SUBSET(MAPS_BLANK(AMAP),INPUT_MAP=AMAP,SUBSET_MAP=L3BSUBMAP,OCEAN_BINS=MOBINS)$ ; Get the BIN values for the subset map
                                  ELSE IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)                                          ; Get the BIN values of the input map if it is an L3B map and no subset map is provided
  
    IF MOBINS NE [] THEN BEGIN & BX = 1  & BY = N_ELEMENTS(MOBINS) & ENDIF $                                                      ; Get the array sizes of the subset bins
                    ELSE BEGIN & BX = PX & BY = PY & ENDELSE
    BLANK = FLTARR(BX,BY) & BLANK[*] = MISSINGS(BLANK)                                                                            ; Create a blank array based on the subset bins dimensions
  
    ; ===> Update the FILE LABEL based on the map information
    IF MOBINS EQ [] THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) ELSE BEGIN                                      ; Create a MAP, PX, PY label
      IF N_ELEMENTS(MOBINS) EQ PY THEN MAP_PXY = AMAP + '-PXY_' + ROUNDS(PX) + '_' + ROUNDS(PY) $                                 ; Create a L3B MAP label
      ELSE MAP_PXY = AMAP + '-' + L3BSUBMAP +'_SUBSET' + '-PXY_1_' + ROUNDS(N_ELEMENTS(MOBINS))                                   ; Create a L3BSUBMAP specific MAP label
    ENDELSE
     _FILE_LABEL = REPLACE(_FILE_LABEL, AMAP, MAP_PXY)                                                                            ; Add PXY_(PX)_(PY) to the file label
  
    ; ===> Set up the output directory
    IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIROUT = REPLACE(FP[0].DIR,[!S.DATASETS_SOURCE,'/SAVE','/NC','/STATS','/ANOMS',FP[0].SUB],[!S.DATASETS,REPLICATE('/STACKED_SAVE/'+PROD_LABEL,5)])  $        ; Set up the output directory
                                ELSE DIROUT = DIR_OUT
    DIROUT = REPLACE(DIROUT,[SL+['SOURCE','SOURCE_MONTHLY','SOURCE_1KM',FP[0].MAP]+SL],[REPLICATE(SL+AMAP+SL,4)])                                                                                     ; Change the map in the output directory
    IF SI NE [] THEN DIROUT = REPLACE(DIROUT,SI.COVERAGE,AMAP)                                                                                     ; Change the map/coverage in the output directory
    DIROUT = REPLACE(DIROUT,'//','/')
    IF KEYWORD_SET(DOY) THEN DIROUT = REPLACE(DIROUT,'STACKED_SAVE','STACKED_TEMP')                                             ; If DOY files, then save in the TEMP directory
    IF ~HAS(DIROUT,AMAP) THEN MESSAGE, 'ERROR: Check the output directory MAP information'                                       ; Check the output directory is correct
    DIR_TEST, DIROUT                                                                                                             ; Create the output directory
  
    ; ===> Loop through output files (PERIOD_SET(s))
    OUTFILE = []
    FOR N=0, N_ELEMENTS(PERIOD_SET)-1 DO BEGIN
      PERIOD_NAME = PERIOD_SET[N].STACKED_PERIOD                                                                                  ; Get the period name
      PERIOD_STR = PERIOD_2STRUCT(PERIOD_NAME)                                                                                    ; Get the date details of the period
      DATE_RANGE = STRMID([PERIOD_STR.DATE_START,PERIOD_STR.DATE_END],0,8)                                                        ; Get the date_range for all the files based on the first and last period code
      SUBS = STRSPLIT(PERIOD_SET[N].SUBS,';',/EXTRACT)                                                                            ; Get the subscripts for the files
      IFILES = FILES[SUBS]                                                                                                        ; Subset the files
  
      ; ===> Create the output file name                                                                                          ; Make the output directory if it does not already exist
      IF N_ELEMENTS(D3_FILES) NE N_ELEMENTS(PERIOD_SET) $
        THEN D3_FILE = DIROUT +  PERIOD_NAME + '-' + _FILE_LABEL + '-STACKED.SAV' $                                              ; Create the complete D3_FILE name if not provided
      ELSE D3_FILE = D3_FILES[N]
      D3_FILE = REPLACE(D3_FILE,['--','-.'],['-',''])                                                                             ; Clean up the file name
      IF (FILE_PARSE(D3_FILE)).DIR EQ '' THEN D3_FILE = DIROUT + STRUPCASE(D3_FILE)                                              ; Check that the D3_FILE has an output directory
      OUTFILE = [OUTFILE,D3_FILE]                                                                                                 ; Create an array of output file names
      IF KEYWORD_SET(OVERWRITE) AND FILE_TEST(D3_FILE) THEN FILE_DELETE, D3_FILE, /VERBOSE                                        ; Delete the D3_FILE if it exists
  
      ; ===> Create or read the D3HASH file
      IF ~FILE_TEST(D3_FILE) THEN D3HASH = D3HASH_MAKE(D3_FILE, INPUT_FILES=FILES, BINS=MOBINS, PRODS=PRODS, MAIN_PROD=MAINPROD,$                    ; Make the HASH file
                                                       PX=BX, PY=BY, STAT_TYPES=STAT_TYPES, ANOM_TYPES=ANOM_TYPES, DO_STATS=DO_STATS, DO_ANOMS=DO_ANOMS) $                       ; or  
      ELSE D3HASH = IDL_RESTORE(D3_FILE)    ; Read the D3HASH file if it already exists and extract the D3 dabase                 ; Read the existing HASH file
  
      ; ===> Extract variables from the HASH obj
      D3_KEYS = D3HASH.KEYS() & D3_KEYS = D3_KEYS.TOARRAY()                                                                       ; Get the D3HASH key names and convert the LIST to an array
      D3_VARS = REMOVE(D3_KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA'])                                               ; Keep just the D3 variable names
      DB      = D3HASH['FILE_DB'].TOSTRUCT()                                                                                      ; Extract the file database
  
      ; ===> If previous DOY files exists, fill in the D3HASH with existing data to avoid needing to read the input file again
      IF KEYWORD_SET(DOY) THEN BEGIN
        DOYFILES = FILE_SEARCH(DIROUT + STRMID(PERIOD_NAME,0,7) + '*-' + _FILE_LABEL+'-STACKED.SAV',COUNT=COUNTDOY)
        IF COUNTDOY GT 0 THEN BEGIN
          IF COUNTDOY GT 1 THEN MESSAGE, 'ERROR: Need to figure out how to work with more than one DOY file'
          DOYHASH = STACKED_READ(DOYFILES,BINS=BINS, DB=DOYDB,KEYS=DOYKEYS)
          OKDOY = WHERE_MATCH(DOYDB.PERIOD,D3HASH['FILE_DB','PERIOD'], COUNT,VALID=VALID,INVALID=INVALID,COMPLEMENT=COMP)
          FOR V=0, N_ELEMENTS(D3_VARS)-1 DO BEGIN
            DVAR = D3_VARS[V]
            DOYPOS = WHERE(TAG_NAMES(DOYHASH) EQ DVAR,COUNT)
            IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + DVAR + ' not found in the existing DOYHASH file'
            D3HASH[DVAR,*,*,OKDOY] = DOYHASH.(DOYPOS)[*,*,VALID]
  
            ; ===> Add the file information to the D3 database in the D3HASH
            D3HASH['FILE_DB','MTIME',OKDOY] = DOYDB.MTIME[VALID]                                                                             ; Add the file MTIME to the D3 database
            D3HASH['FILE_DB','FULLNAME',OKDOY] = DOYDB.FULLNAME[VALID]                                                                                        ; Add the full file name to the D3 database
            D3HASH['FILE_DB','NAME',OKDOY] = DOYDB.NAME[VALID]                                                                                       ; Add the file name to the D3 database
            D3HASH['FILE_DB','DATE_RANGE',OKDOY] = DOYDB.DATE_RANGE[VALID] 
            D3HASH['FILE_DB','INPUT_FILES',OKDOY] = DOYDB.INPUT_FILES[VALID]           ; Add the "input" files to the D3 database (if present)
            D3HASH['FILE_DB','ORIGINAL_FILES',OKDOY] = DOYDB.ORIGINAL_FILES[VALID]                              ; Add the "original" files to the D3 database (if present)
  
            DB      = D3HASH['FILE_DB'].TOSTRUCT()                                                                                      ; Extract the file database
           
          ENDFOR ; D3_VARS
        ENDIF ;COUNTDOY
      ENDIF ; DOY
      
      ; ===> Read the input files and add them to the D3HASH file
      WRITEFILE = 0
      IF KEYWORD_SET(STACKED_INFILE) OR KEYWORD_SET(OCCCI_1KM) OR KEYWORD_SET(STACKED_NC) THEN BEGIN
        DBPERIODS = DB.PERIOD                                                                                                     ; Get the PERIODS from the file database
        DBDATE = PERIOD_2DATE(DBPERIODS)                                                                                          ; Convert the DB periods to a date
        PERIODS = []
   ;     FOR NTH=0, N_ELEMENTS(FP)-1 DO BEGIN                                                                                      ; Loop through the files to find the PERIODS of the input files
   ;       OK = WHERE(DBDATE GE MIN(FP[NTH].DATE_START) AND DBDATE LE MAX(FP[NTH].DATE_END),COUNT)                                 ; Find the periods within the input period range
          OK = WHERE(DBDATE GE MIN(FP.DATE_START) AND DBDATE LE MAX(FP.DATE_END),COUNT)                                 ; Find the periods within the input period range
          IF KEYWORD_SET(DOY) AND COUNT EQ 0 THEN CONTINUE
          IF COUNT GT 0 THEN PERIODS = [PERIODS,DBPERIODS[OK]] ELSE MESSAGE, 'ERROR: Unable to find matching periods.'            ; Subset the DB periods by those within the range of the input files
   ;     ENDFOR
        PREVIOUS_FILE = []
      ENDIF ELSE PERIODS = (PARSE_IT(IFILES)).PERIOD                                                                              ; If the input is not a stacked file, then get the periods from the IFILES
  
      FOR NTH=0, N_ELEMENTS(PERIODS)-1 DO BEGIN                                                                                   ; Loop through the periods
        APERIOD = PERIODS[NTH]
        ADATE = PERIOD_2DATE(APERIOD)
        PERSTR = PERIOD_2STRUCT(APERIOD)                                                                                     ; Get the date information from the period
        IF STRMID(PERSTR.DATE_START,0,8) NE STRMID(PERSTR.DATE_END,0,8) THEN $                                                    ; Check the start and end dates
          DTRNG = STRJOIN(STRMID([PERSTR.DATE_START,PERSTR.DATE_END],0,8),'_') ELSE $                                             ; Set the DATERANGE
          DTRNG = STRMID(PERSTR.DATE_START,0,8)                                                                                   ; Create the PERIOD_RANGE variable
        
        SEQ = WHERE(D3HASH['FILE_DB','PERIOD'] EQ PERIODS[NTH],COUNT)                                                                  ; Find the period in the DB database
        IF COUNT NE 1 THEN MESSAGE, 'ERROR: ' + APERIOD + ' not found in the DB database.'                                        ; Check the database for the period
        IF KEYWORD_SET([STACKED_INFILE,OCCCI_1KM,STACKED_NC]) THEN FILE = FILES[WHERE(ADATE GE FP.DATE_START AND ADATE LE FP.DATE_END,/NULL,COUNT)] $    ; Get the file based on the input file
                                                              ELSE FILE = FILES[WHERE(APERIOD EQ FP.PERIOD,/NULL,COUNT)]          ; Get the file based on the input period
        IF KEYWORD_SET(STACKED_INFILE) AND PERSTR.PERIOD_CODE EQ 'M3' THEN FILE = FILES[WHERE(ADATE GE FP.DATE_START AND PERSTR.DATE_END LE FP.DATE_END,/NULL,COUNT)]
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: No file found containing the period ' + APERIOD                                       ; Check that a file was found
        IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than one file found containing the period ' + APERIOD                            ; Check that only one file was found
        FA = PARSE_IT(FILE,/ALL)                                                                                                       ; Parse the file name
        IF D3HASH['FILE_DB','MTIME',SEQ] GE GET_MTIME(FILE) THEN CONTINUE                                                         ; Skip if the file is already in the database and does not need to be updated
        IF WRITEFILE EQ 0 THEN PLUN, LUN, PERIOD_NAME                                                                             
        WRITEFILE = 1                                                                                                             ; Set the keyword to write the completed HASH as a file
        POF, NTH, IFILES, OUTTXT=OUTTXT,/QUIET
  
        BINS = []                                                                                                                 ; Create a null array of bins
        IF KEYWORD_SET(STACKED_INFILE) THEN BEGIN                                                                                 ; Check to see if the input file is a STACKED file
          IF FILE NE PREVIOUS_FILE THEN BEGIN                                                                                         ; If this a different file than the previous one, read the new file
            PFILE, FILE, /R
            STR = STACKED_READ(FILE, BINS=BINS, DB=DBSTACKED)                                                                     ; Read the stacked file if not already read
        ;    IF HAS(FILE,'STACKED_STATS') AND HAS(PRODS,'GRAD_SST') THEN STR = STRUCT_RENAME(STR,'GRAD_SST','GRAD_SST_MEAN')
        ;    IF HAS(FILE,'STACKED_STATS') AND HAS(PRODS,'GRAD_CHL') THEN STR = STRUCT_RENAME(STR,'GRAD_CHL','GRAD_CHL_MEAN')
            PREVIOUS_FILE = FILE                                                                                                  ; Set the PREVIOUS_FILE to the new file that was just read
          ENDIF
        ENDIF ELSE BEGIN
          
          IF HAS(FA.EXT,'SAV') THEN BEGIN                                                                                         ; Look at the file extension
            PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
            DAT = STRUCT_READ(FILE, BINS=BINS, STRUCT=STR)                                                                        ; Read the SAV file
            IF INDATA_PROD NE [] THEN STR = STRUCT_RENAME(STR,'INDATA',INDATA_PROD,/STRUCT_ARRAYS)                                ; Rename the data in the structure
          ENDIF ELSE BEGIN                                                                                                        ; If file extension is .nc, get the ncprod data and the bins from the netcdf file
            CASE FP[0].SENSOR OF                                                                                                  ; Read the NC files using SENSOR specific information
              'AVHRR': BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=[NPRODS,'PATHFINDER_QUALITY_LEVEL','L2P_FLAGS'],/GLOBAL)
                QUALITY_LEVEL = 3
                DTAGS = TAG_NAMES(D.SD)
                
                MIMG = D.SD.PATHFINDER_QUALITY_LEVEL.IMAGE
                FIMG = D.SD.L2P_FLAGS.IMAGE
                SST  = D.SD.SEA_SURFACE_TEMPERATURE
                SST_IMG = SST.IMAGE
                
                OK_MISSINGS = WHERE(SST_IMG GT SST.VALID_MAX OR SST_IMG LT SST.VALID_MIN OR SST_IMG EQ MISSINGS(SST_IMG) OR SST_IMG EQ SST._FILLVALUE[0],COMPLEMENT=COMPLEMENT); Find any MISSING values or temperatures that are out of range
                SST_IMG = SST_IMG * FLOAT(SST.SCALE_FACTOR[0])
                SST_IMG[OK_MISSINGS] = MISSINGS(0.0)
  
                OK_MASK = WHERE(MIMG LT 0 OR MIMG GT 7, COUNT_MASK)               ; Valid quality values are from 0 (worst) to 7 (best)
                IF COUNT_MASK GE 1 THEN MIMG[OK_MASK] = 0                         ; Change any 255 values to 0
                OK_LAND = WHERE(BITS(FIMG,1) EQ 1, COUNT_LAND)                    ; Find the land pixels (BIT 1)
                IF COUNT_LAND GE 1 THEN MIMG[OK_LAND] = -1
                OK_QUAL = WHERE(MIMG LE QUALITY_LEVEL,COUNT_QUAL)                 ; Find the mask values that are less than or equal to the QUALITY_LEVEL (default = 3, low quality data)
                SST_IMG[OK_QUAL] = MISSINGS(0.0)
                
                SST_IMG = MAPS_AVHRR_2BIN(SST_IMG, AMAP, INIT=INIT)
                FA.MAP = AMAP
              END  
              
              'CORAL': BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=[NPRODS,'LAT','LON'],GLOBAL=GBL)
                FA.MAP = AMAP
                DTAGS = TAG_NAMES(D.SD) 
                ; Convert the SST image from Kelvin to Celcius
                SST_IMAGE   = D.SD.ANALYSED_SST.IMAGE
                OK_MISSINGS = WHERE(SST_IMAGE EQ D.SD.ANALYSED_SST._FILLVALUE[0] OR SST_IMAGE EQ MISSINGS(SST_IMAGE),COUNT_BAD)
                SST_IMAGE   = (FLOAT(SST_IMAGE) * FLOAT(D.SD.ANALYSED_SST.SCALE_FACTOR[0])) ;+ FLOAT(D.SD.ANALYSED_SST.ADD_OFFSET[0]) - 273.15
                SST_IMAGE[WHERE(SST_IMAGE GT 45.0,/NULL)] = MISSINGS(0.0)  ; Remove any temperature values greater than 45
                SST_IMAGE[OK_MISSINGS] = MISSINGS(0.0)
                SST_IMG = MAPS_NOAA5KM_2BIN(SST_IMAGE, AMAP, BINS_OUT=BINS, INIT=INIT)
              END
              
              'GLOBCOLOUR': BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=[NPRODS,'ROW','COL','CENTER_LAT','CENTER_LON','LON_STEP'],GLOBAL=GBL)
                ROW = D.SD.ROW.IMAGE
                INDEX = ROW - GBL.FIRST_ROW
                LAT = D.SD.CENTER_LAT.IMAGE[INDEX]
                LON = D.SD.CENTER_LON.IMAGE[INDEX]+D.SD.COL.IMAGE*D.SD.LON_STEP.IMAGE[INDEX]
                BLK = FINDGEN(N_ELEMENTS(ROW))+1
                BINS = MAPS_L3B_LONLAT_2BIN('L3B4',LON,LAT)
                FA.MAP = 'L3B4'
                DTAGS = TAG_NAMES(D.SD) 
              END
              
              'OCCCI': BEGIN
                IF KEYWORD_SET(OCCCI_1KM) THEN BEGIN
                  IF FILE NE PREVIOUS_FILE THEN BEGIN
                    PFILE, FILE, /R,  LOGLUN=LUN
                    D = READ_NC(FILE, PROD=[NPRODS,'LAT','LON','TIME'],/GLOBAL)
                    DTAGS = TAG_NAMES(D.SD)
                    IMGPOS = WHERE(DTAGS EQ NPRODS, COUNT)
                    ODAT = D.SD.(IMGPOS)
                    PREVIOUS_FILE=FILE
                    LATS = D.SD.LAT.IMAGE & PY = N_ELEMENTS(LATS)
                    LONS = D.SD.LON.IMAGE & PX = N_ELEMENTS(LONS)
                    TIME = D.SD.TIME.IMAGE
                    DATES = []
                    FOR T=0, N_ELEMENTS(TIME)-1 DO DATES = [DATES,JD_2DATE(DAYS1970_2JD(TIME[T]))]
                  ENDIF  
                  OKDATE = WHERE(DATES EQ PERIOD_2DATE(APERIOD),COUNT)
                  IF COUNT EQ 0 THEN BEGIN
                    PLUN, LUN,  'ERROR: Period ' + APERIOD + ' not found in ' + FILE, 0
                    OCIMG = []
                  ENDIF ELSE OCIMG = ODAT.IMAGE[*,*,OKDATE]
                ENDIF ELSE BEGIN    
                  IF KEYWORD_SET(STACKED_NC) THEN BEGIN
                    IF FILE NE PREVIOUS_FILE THEN BEGIN
                      PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                      D = READ_NC(FILE,PROD=[NPRODS,'LAT','LON','TIME'])
                      DTAGS = TAG_NAMES(D.SD) 
                      LATS = D.SD.LAT.IMAGE & PY = N_ELEMENTS(LATS)
                      LONS = D.SD.LON.IMAGE & PX = N_ELEMENTS(LONS)
                      TIME = JD_2DATE(DAYS1970_2JD(D.SD.TIME.IMAGE))
                      INPERS = DATE_2PERIOD(STRMID(TIME,0,6))
                      PREVIOUS_FILE=FILE
                    ENDIF
                    OKPER = WHERE(INPERS EQ APERIOD, /NULL)  
                    PLUN, LUN, 'Working on period ' + APERIOD, 0
                  ENDIF ELSE BEGIN
                    D = READ_NC(FILE,PROD=NPRODS,/GLOBAL)
                    DTAGS = TAG_NAMES(D.SD)
                  ENDELSE
                   
                  CASE 1 OF
                    FA.MAP EQ 'SIN': BEGIN & FA.MAP = 'L3B4' & BINS = MAPS_L3B_BINS('L3B4') & END
                    KEYWORD_SET(STACKED_NC): FA.MAP='L3B4'
                  ENDCASE  
                ENDELSE  
              END        
              
              'MUR': BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=[NPRODS,'MASK'],/GLOBAL)
                DTAGS = TAG_NAMES(D.SD) 
                FA.MAP = AMAP 
                ; Convert the SST image from Kelvin to Celcius
                SST_IMAGE   = D.SD.ANALYSED_SST.IMAGE
                OK_MISSINGS = WHERE(SST_IMAGE EQ D.SD.ANALYSED_SST._FILLVALUE[0] OR SST_IMAGE EQ MISSINGS(SST_IMAGE),COUNT_BAD)
                SST_IMAGE   = (FLOAT(SST_IMAGE) * FLOAT(D.SD.ANALYSED_SST.SCALE_FACTOR[0])) + FLOAT(D.SD.ANALYSED_SST.ADD_OFFSET[0]) - 273.15
                SST_IMAGE[WHERE(SST_IMAGE GT 45.0,/NULL)] = MISSINGS(0.0)  ; Remove any temperature values greater than 45
                SST_IMAGE[OK_MISSINGS] = MISSINGS(0.0)
  
                ; Convert the SST ERROR image to floating 
                STD_IMAGE   = D.SD.ANALYSIS_ERROR.IMAGE
                OK_MISSINGS = WHERE(STD_IMAGE EQ D.SD.ANALYSIS_ERROR._FILLVALUE[0] OR STD_IMAGE EQ MISSINGS(STD_IMAGE),COUNT_BAD)
                STD_IMAGE   = (FLOAT(STD_IMAGE) *  FLOAT(D.SD.ANALYSIS_ERROR.SCALE_FACTOR[0])) + FLOAT(D.SD.ANALYSIS_ERROR.ADD_OFFSET[0])
                STD_IMAGE[OK_MISSINGS] = MISSINGS(0.0)
  
                ; Find the land in the mask and make the SST and STD data missing
                MSK_IMAGE = D.SD.MASK.IMAGE
                MASK_CODE = [1,2,5,9,13]
                MASK_NAME = ['OPEN_SEA','LAND','OPEN_LAKE','SEA_WITH_ICE','LAKE_WITH_ICE']
                OK_MASK = WHERE(MSK_IMAGE EQ 2, COUNT_MASK)
                IF COUNT_MASK GE 1 THEN BEGIN
                  SST_IMAGE[OK_MASK] = MISSINGS(SST_IMAGE)
                  STD_IMAGE[OK_MASK] = MISSINGS(STD_IMAGE)
                ENDIF
                SSTIMG = MAPS_MUR_2BIN(SST_IMAGE, AMAP, MAP_SUBSET=L3BSUBMAP,BINS_OUT=BINS, INIT=INIT)
                STDIMG = MAPS_MUR_2BIN(STD_IMAGE, AMAP, MAP_SUBSET=L3BSUBMAP,BINS_OUT=BINS, INIT=INIT)
              END
              
              'ACSPO': BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=[NPRODS],/GLOBAL)
                DTAGS = TAG_NAMES(D.SD)
                FA.MAP = AMAP              
                APRODS = REVERSE(NPRODS[SORT(NPRODS)])
                IF HAS(APRODS,'SST_FRONT_POSITION') AND ~HAS(APRODS,'SST_GRADIENT_MAGNITUDE') THEN APRODS = ['SST_GRADIENT_MAGNITUDE',APRODS]
                FOR A=0, N_ELEMENTS(APRODS)-1 DO BEGIN
                  CASE APRODS[A] OF
                    'SEA_SURFACE_TEMPERATURE': BEGIN
                      ; Convert the SST image from Kelvin to Celcius
                      SST_IMAGE   = D.SD.SEA_SURFACE_TEMPERATURE.IMAGE
                      OK_MISSINGS = WHERE(SST_IMAGE EQ D.SD.SEA_SURFACE_TEMPERATURE._FILLVALUE[0] OR SST_IMAGE EQ MISSINGS(SST_IMAGE),COUNT_BAD)
                      SST_IMAGE   = (FLOAT(SST_IMAGE) * FLOAT(D.SD.SEA_SURFACE_TEMPERATURE.SCALE_FACTOR[0])) + FLOAT(D.SD.SEA_SURFACE_TEMPERATURE.ADD_OFFSET[0]) - 273.15
                      SST_IMAGE[WHERE(SST_IMAGE GT 45.0,/NULL)] = MISSINGS(0.0)  ; Remove any temperature values greater than 45
                      SST_IMAGE[OK_MISSINGS] = MISSINGS(0.0)
                      SST_IMG = MAPS_ACSPO_2BIN(SST_IMAGE, AMAP, BINS_OUT=BINS, INIT=INIT)
                    END  
                    'SST_GRADIENT_MAGNITUDE': BEGIN
                      MAP_GDM_IMG:
                      GDM_IMG   = D.SD.SST_GRADIENT_MAGNITUDE.IMAGE
                      OK_MISSINGS = WHERE(GDM_IMG EQ D.SD.SST_GRADIENT_MAGNITUDE._FILLVALUE[0] OR GDM_IMG EQ MISSINGS(GDM_IMG),COUNT_BAD)
                      GDM_IMG   = (FLOAT(GDM_IMG) * FLOAT(D.SD.SST_GRADIENT_MAGNITUDE.SCALE_FACTOR[0])) + FLOAT(D.SD.SST_GRADIENT_MAGNITUDE.ADD_OFFSET[0])
                      GDM_IMG[WHERE(GDM_IMG GT 45.0,/NULL)] = MISSINGS(0.0)  ; Remove any temperature values greater than 45
                      GDM_IMG[OK_MISSINGS] = MISSINGS(0.0)
                      GDM_IMG = MAPS_ACSPO_2BIN(GDM_IMG, AMAP, BINS_OUT=BINS, INIT=INIT)
                      IF HAS(NPRODS,'SST_FRONT_POSITION') THEN BEGIN
                        ; Use the GRAD_MAG data to get the frontal positions (if you convert the SST_FRONT_POSITION data, it will create errors because it averages data when adding it to the approproiate bins)
                        FRT_IMG= BYTARR(N_ELEMENTS(GDM_IMG))
                        FRT_IMG[WHERE(GDM_IMG NE MISSINGS(GDM_IMG),/NULL)] = 1
                      ENDIF
                    END
                    'SST_FRONT_POSITION': BEGIN      
                      IF FRT_IMG EQ [] THEN MESSAGE, 'ERROR: FRT_IMG should be calculated with the GDM_IMG'              
                    END  ; ASCPO
                    'OISST': BEGIN
                      STOP
                    END ; OISST
                  ENDCASE  
                ENDFOR ; APRODS
                
              END
                           
              ELSE: BEGIN
                PFILE, FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
                D = READ_NC(FILE,PROD=NPRODS,/GLOBAL)
                DTAGS = TAG_NAMES(D.SD) 
              END  
            ENDCASE
                                                                                    
            IF IDLTYPE(D) EQ 'STRING' THEN MESSAGE, D                                                                             ; Check to make sure the file was read properly
            STR = []
            FOR R=0, N_ELEMENTS(NPRODS)-1 DO BEGIN
              POS = WHERE(DTAGS EQ STRUPCASE(NPRODS[R]),COUNT)
              IF COUNT EQ 0 THEN MESSAGE,'ERROR: ' + NPRODS[R] + ' not found in ' + FILE
              
              CASE FP[0].SENSOR OF
                'MUR': BEGIN
                  CASE NPRODS[R] OF
                    'ANALYSED_SST': IMG = SSTIMG
                    'ANALYSIS_ERROR': IMG = STDIMG
                  ENDCASE  
                END
                'AVHRR': IMG = SST_IMG  
                'CORAL': IMG = SST_IMG
                'ACSPO': BEGIN
                  CASE NPRODS[R] OF
                    'SEA_SURFACE_TEMPERATURE': IMG = SST_IMG
                    'SST_GRADIENT_MAGNITUDE': IMG = GDM_IMG
                    'SST_FRONT_POSITION': IMG = FRT_IMG
                  ENDCASE  
                END  
                ELSE: BEGIN
                  IF D NE [] THEN BEGIN
                    IF HAS_TAG(D.SD.(POS),'DATA') THEN IMG = D.SD.(POS).DATA
                    IF HAS_TAG(D.SD.(POS),'IMAGE') THEN IMG = D.SD.(POS).IMAGE
                    IF HAS_TAG(D.SD.(POS),'DATA') + HAS_TAG(D.SD.(POS),'IMAGE') NE 1 THEN MESSAGE, 'ERROR: Need to check netcdf tags'
                  ENDIF
                  IF KEYWORD_SET(OCCCI_1KM) THEN IF OCIMG EQ [] THEN IMG=[] ELSE IMG = OCIMG
                END  
              ENDCASE
              
              IF IMG EQ [] THEN CONTINUE
              IF KEYWORD_SET([OCCCI_1KM,STACKED_NC]) THEN BEGIN
                IF KEYWORD_SET(OCCCI_1KM) THEN BEGIN
                  PLUN, LUN,  'Adding: ' + APERIOD, 0
                  IMG = MAPS_OCCCI_LONLAT_2BIN(IMG, AMAP, MAP_IN='1KM', LATS=LATS, LONS=LONS)
                ENDIF
                IF KEYWORD_SET(STACKED_NC) AND OKPER NE [] THEN IMG = MAPS_OCCCI_LONLAT_2BIN(IMG[*,*,OKPER], AMAP, MAP_IN='4KM', LATS=LATS, LONS=LONS)  
              ENDIF ELSE IF AMAP NE FA.MAP THEN IMG = MAPS_REMAP(IMG, MAP_IN=FA.MAP, MAP_OUT=AMAP,BINS=D.SD.(POS).BINS)
                       
              IF SIZE(IMG,/N_DIMENSIONS) EQ 1 THEN BEGIN
                TMP = FLTARR(1,N_ELEMENTS(IMG))
                TMP[0,*] = IMG
              ENDIF ELSE TMP = IMG
              STR = CREATE_STRUCT(STR,VALIDS('PRODS',VPRODS[R]),TMP)
              GONE, TMP
              GONE, IMG
              SKIP_PERIOD:
            ENDFOR ; NPRODS
            IF ~KEYWORD_SET(STACKED_NC) THEN GONE, D
          ENDELSE
        ENDELSE
        
        IF STR EQ [] THEN CONTINUE
  
        ; ===> Add the file information to the D3 database in the D3HASH
        D3HASH['FILE_DB','MTIME',SEQ] = GET_MTIME(FILE)                                                                               ; Add the file MTIME to the D3 database
        IF HAS(DB,'STATFILE') THEN D3HASH['FILE_DB','STATFILE',SEQ] = FILE ELSE D3HASH['FILE_DB','FULLNAME',SEQ] = FILE                                                                                       ; Add the full file name to the D3 database
        IF HAS(DB,'STATNAME') THEN D3HASH['FILE_DB','STATNAME',SEQ] = FA.NAME ELSE D3HASH['FILE_DB','NAME',SEQ] = FA.NAME                                                                                        ; Add the file name to the D3 database
        D3HASH['FILE_DB','DATE_RANGE',SEQ] = DTRNG
        IF HAS(STR,'INFILES') THEN D3HASH['FILE_DB','INPUT_FILES',SEQ] = STRJOIN(STR.INFILES,'; ') ELSE D3HASH['FILE_DB','INPUT_FILES',SEQ] = FILE          ; Add the "input" files to the D3 database (if present)
        IF HAS(STR,'ORGFILES') THEN D3HASH['FILE_DB','ORIGINAL_FILES',SEQ] = STRJOIN(STR.ORGFILES,'; ')                               ; Add the "original" files to the D3 database (if present)
  
        ; ===> Loop through the variables and add to the D3HASH
        FOR S=0, N_ELEMENTS(D3_VARS)-1 DO BEGIN
          CASE 1 OF
            DO_STATS EQ 1: BEGIN
              IF KEYWORD_SET(STACKED_INFILE) THEN DATA_TAG = D3_VARS[S] $
              ELSE DATA_TAG = REPLACE(D3_VARS[S],PRODS+'_','')                                       ; Remove the tag prefix in order to search for it in the data structure
            END
            DO_ANOMS EQ 1: DATA_TAG = REPLACE(D3_VARS[S],PRODS+'_','')                                                     ; Remove the tag prefix in order to search for it in the data structure          
            ELSE: DATA_TAG = D3_VARS[S]
          ENDCASE
          
          CASE DATA_TAG OF
            'PSC_NANOPICO': DAT = STR.PSC_NANO + STR.PSC_PICO
            'PSC_FMICRO': DAT = STR.PSC_MICRO/STR.CHLOR_A
            'PSC_FNANO': DAT = STR.PSC_NANO/STR.CHLOR_A
            'PSC_FPICO': DAT = STR.PSC_PICO/STR.CHLOR_A
            'PSC_FDIATOM': DAT = STR.PSC_DIATOM/STR.CHLOR_A
            'PSC_FDINOFLAGELLATE': DAT = STR.PSC_DINOFLAGELLATE/STR.CHLOR_A
            'PSC_FNANOPICO': DAT = (STR.PSC_NANO + STR.PSC_PICO)/STR.CHLOR_A
            ELSE: DAT = GET_TAG(STR, DATA_TAG)                                                                                                ; Extract the specified data from the structure
          ENDCASE
  
          IF DAT EQ [] THEN BEGIN                                                                                                     ; Check to make sure DAT is not !NULL
            IF VALIDS('PRODS',STR.PROD) EQ DATA_TAG THEN BEGIN
              IF WHERE(TAG_NAMES(STR) EQ 'IMAGE') GE 0 THEN DAT = STR.IMAGE ; DAT = GET_TAG(STR,'IMAGE')                                                                                              ; Use the "IMAGE" data tag to extract the data from the structure
              IF DAT EQ [] AND WHERE(TAG_NAMES(STR) EQ 'DATA') GE 0 THEN DAT = STR.DATA ; DAT = GET_TAG(STR,'DATA')                                                                             ; If "IMAGE" tag is not found, then try the "DATA" tag to extract the data from the structure
              IF DAT EQ [] THEN MESSAGE, 'ERROR: IMAGE and DATA tags not found in the structure'                                      ; Write an error if unable to extract the data
            ENDIF ELSE  MESSAGE, 'ERROR: Unable to find the data tag ' + DATA_TAG + ' in the structure'                               ; Write an error if the data aren't found in the structure
          ENDIF
  
          ; ===> Add the data to the D3HASH structure
          IF KEYWORD_SET(STACKED_INFILE) THEN BEGIN
            DSEQ = WHERE(DBSTACKED.PERIOD EQ APERIOD[0],COUNT)                                                                      ; Find the period in the stacked DB database
            IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Unable to find the matching period'
            _DATA = DAT[*,*,DSEQ]
          ENDIF ELSE BEGIN
            IF MOBINS EQ [] THEN BEGIN                                                                                                  ; If no subset map bins provided
              IF BINS NE [] THEN BEGIN                                                                                                  ; If no bins
                _DATA = BLANK                                                                                                           ; Make a blank array
                _DATA[0,BINS-1] = DAT                                                                                                       ; Fill in the blank array associated with the specified bin info with valid data
              ENDIF ELSE _DATA = DAT  ; BINS NE []                                                                                      ; If no bins or mobins, then _DATA = DAT
            ENDIF ELSE BEGIN  ; MOBINS = []
              IF BINS NE [] THEN BEGIN
                _DAT = FLTARR(PY) & _DAT[*,*] = MISSINGS(_DAT)                                                                          ; Make a blank array for the full l3b array
                _DAT[BINS-1] = DAT                                                                                                        ; Fill in the full l3b array with data
                _DATA = BLANK                                                                                                           ; Create a blank array the size of MOBINS
                _DATA[0,*] = _DAT[MOBINS-1]                                                                                               ; Fill in the blank array with just the MOBINS data
                GONE, _DAT
              ENDIF ELSE _DATA = DAT[*,MOBINS-1] ; BINS NE []                                                                             ; Subset the full array (n) with MOBINS
            ENDELSE
          ENDELSE
          IF SIZE(_DATA,/N_DIMENSIONS) EQ 1 THEN D3HASH[D3_VARS[S],*,SEQ] = _DATA ELSE D3HASH[D3_VARS[S],*,*,SEQ] = _DATA                                                                                           ; Add the data to the D3HASH
        ENDFOR ; D3_VARS
        GONE, DAT
      ENDFOR ; PERIODS
  
      ; ===> Save the D3HASH file
      IF KEYWORD_SET(WRITEFILE) THEN BEGIN                                                                                           ; Only need to save the file if new data were added
        D3META = D3HASH_METADATA(D3_FILE, DB=D3HASH['FILE_DB'])
        D3HASH['METADATA'] = D3META
        PLUN, LUN, 'Writing ' + D3_FILE,0
        SAVE, D3HASH, FILENAME=D3_FILE, /COMPRESS
      ENDIF ELSE BEGIN
        IF KEYWORD_SET(DOY) AND ~FILE_TEST(D3_FILE) THEN BEGIN
          IF N_ELEMENTS(DOYFILES) GT 1 THEN MESSAGE, 'ERROR: Need to figure out how to work with more than one DOY file.'
          D3META = D3HASH_METADATA(D3_FILE, DB=D3HASH['FILE_DB'])
          D3HASH['METADATA'] = D3META
          SAVE, D3HASH, FILENAME=D3_FILE, /COMPRESS
          FILE_DELETE, DOYFILES[0], /VERBOSE
        ENDIF
      ENDELSE
      D3HASH = []
    ENDFOR ; PERIOD_SETS
  ENDFOR ; MAPS  


END ; ***************** End of FILES_2STACKED *****************
