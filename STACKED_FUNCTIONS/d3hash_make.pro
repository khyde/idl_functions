; $ID:	D3HASH_MAKE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION D3HASH_MAKE, OUTPUT_FILE, INPUT_FILES=INPUT_FILES, PRODS=PRODS, $
    MAIN_PROD=MAIN_PROD, BINS=BINS, PX=PX, PY=PY, STAT_TYPES=STAT_TYPES, ANOM_TYPES=ANOM_TYPES, ADD_INFO=ADD_INFO,INFO_CONTENT=INFO_CONTENT,$
    DO_STATS=DO_STATS, DO_ANOMS=DO_ANOMS

;+
; NAME:
;   D3HASH_MAKE
;
; PURPOSE:
;   Program to create the HASH object for the "stacked" files
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = D3HASH_MAKE(FILE)
;
; REQUIRED INPUTS:
;   OUTPUT_FILE... The name of the output "stacked" file
;   INPUT_FILES... The name(s) of the input files to be added to the "stacked" file
;   PRODS......... The name(s) of the products to be added to the "stacked" file
;
; OPTIONAL INPUTS:
;   MAIN_PROD..... The name for the "main" product in the file (e.g. CHLOR_A) 
;   BINS.......... The L3B map bins to be stored in the HASH obj
;   PX............ The X dimension array size of the output data
;   PY............ The Y dimension array size of the output data
;   STAT_TYPES.... The type of "stats" to add to the HASH obj
;   ANOM_TYPES.... The type of "anoms" to add to the HASH obj
;   ADD_INFO...... The name of the tag for the "additional info" to include in the INFO structure
;   INFO_CONTENT.. The "additional info" content to include in the INFO structure  
;
; KEYWORD PARAMETERS:
;   DO_STATS...... Create "stat" products in the HASH obj
;   DO_ANOMS...... Create "anom" products in the HASH obj
;
; OUTPUTS:
;   Returns a standardized HASH object that will be filled in with data
;
; OPTIONAL OUTPUTS:
;   None
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
;   The metadata will need to be added to the HASH after the blank file database is filled in 
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 14, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 14, 2022 - KJWH: Initial code written
;   Nov 15, 2022 - KJWH: Added steps to work with the "stacked" input files (note, it may not be necessary to read the stacked files to make the HASH)
;   Nov 22, 2022 - KJWH: Moved the PROD specific info so that it is added for all file types (not just .SAV files)
;   Dec 13, 2022 - KJWH: Added ANOMALY specific information
;   Jan 04, 2023 - KJWH: Added ADD_INFO and INFO_CONTENT inputs to include additional information in the INFO structure
;   Feb 10, 2023 - KJWH: Fixed the determination of the DO_GRAD_STATS keyword
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3HASH_MAKE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  CALL_ROUTINE = CALLER()
   
  IF ~N_ELEMENTS(PRODS) THEN RETURN, []
  IF ~N_ELEMENTS(INPUT_FILES) THEN RETURN, []
  IF ~N_ELEMENTS(OUTPUT_FILE) THEN RETURN, []
  IF N_ELEMENTS(OUTPUT_FILE) GT 1 THEN MESSAGE, 'ERROR: Only one input file allowed'
  
  ; ===> Get file information
  FP = PARSE_IT(OUTPUT_FILE,/ALL)                                                                                               ; Parse the output file name
  DATE_RANGE = STRJOIN(STRMID([FP.DATE_START,FP.DATE_END],0,8),'_')                                                             ; Create the date range based on the period derived from the file name
  IF ~N_ELEMENTS(MAIN_PROD) THEN MAINPROD = VALIDS('PRODS',FP.NAME) ELSE MAINPROD = VALIDS('PRODS',MAIN_PROD)             ; Get the name of the "main" product
  IF FP.MATH EQ 'STATS' OR FP.MATH EQ 'STACKED_STATS' THEN DO_STATS = 1 ELSE DO_STATS = 0
  IF FP.MATH EQ 'ANOM'  OR FP.MATH EQ 'STACKED_ANOM'  THEN DO_ANOMS = 1 ELSE DO_ANOMS = 0
  IF HAS(FP[0].PROD, 'GRAD_') THEN BEGIN
    DO_STATS=0
    IF FP.MATH EQ 'STATS' OR FP.MATH EQ 'STACKED_STATS' THEN DO_GRAD_STATS=1 ELSE DO_GRAD_STATS=0
  ENDIF  
  IF N_ELEMENTS(MAINPROD) GT 1 AND KEYWORD_SET(DO_STATS) THEN MESSAGE, 'ERROR: More than one product found in the stats file - need to update code to work with stats of multiple products'
    
  ; ===> Initiate the INFO structure
  INFO = STRUCT_COPY(FP[0],['SENSOR','SATELLITE','METHOD','MAP','DAYNIGHT','MATH'])                                             ; Copy information from the parsed file name
  IF INFO.MATH EQ '' THEN INFO.MATH = 'DATA'                                                                                    ; Fill in the MATH field if empty
  INFO = CREATE_STRUCT('PERIOD',FP.PERIOD,'DATE_RANGE',DATE_RANGE, 'DATATYPE','DATA', INFO,'ROUTINE', CALL_ROUTINE)             ; Add more details to the INFO structure
  IF HAS(INFO.MATH,'STACKED') THEN INFO.DATATYPE='STACKED'
  IF HAS(INFO.MATH,'STATS') THEN INFO.DATATYPE='STATS'

  ; ===> Read a file to get the input metadata and set specific keywords
  FA = PARSE_IT(INPUT_FILES[0],/ALL)                                                                                          ; Parse the first input file name
  IF STRPOS(FA.L2SUB,'STACKED') GE 0 THEN STACKED_INFILE = 1 ELSE STACKED_INFILE = 0                                                                                                          ; Make the INDATA variable null

  INDATA_PROD = []  
  IF KEYWORD_SET(STACKED_INFILE) THEN BEGIN
    ; ===> Read the input file and extract the database and extract the basic info
;    SHASH = STACKED_READ(INPUT_FILES[0],KEYS=D3_KEYS,BINS=BINS,DB=DBSTACKED,METADATA=META,INFO=INFO,PRODS=INPRODS)                    ; Read the first input stacked file
;    INFO = STRUCT_COPY(INFO,'DATE_RANGE',/REMOVE)                                                                                ; Remove the DATE_RANGE tag that will be updated with the new date range later
;    ADD_INFILES = 1

; Not sure if the stacked file needs to be read to set up the D3HASH


  ENDIF ELSE BEGIN ; If not a "stacked" file then...
    IF STRUPCASE(FA.EXT) EQ 'SAV' THEN BEGIN   
      TP = STRUCT_READ(INPUT_FILES[0],STRUCT=STR)                                                                                 ; Read the first file to extract specific information
      TAGS = TAG_NAMES(STR)                                                                                                       ; Get the variable names
  
      ; ===> SPECIAL CASE - look for the INDATA tag
      OKTAGS = WHERE(STRPOS(TAGS,'INDATA_') GE 0, COUNT)                                                                          ; Look for the INDATA tag (found in FRONTS files)
      IF COUNT GT 0 THEN BEGIN                                                  
        STOP ; Need to confirm these steps are correct
        INDATA = STRUCT_COPY(STR,TAGS[OKTAGS])                                                                                    ; Create a copy of the INDATA
        OK = WHERE(D3_PROD EQ STR.INDATA_PROD,COUNT)                                                                              ; Look to see if the INDATA_PROD was requested in the D3_PROD
        IF COUNT EQ 1 THEN BEGIN
          INDATA_PROD = STR.INDATA_PROD                                                                                           ; Add the INDATA product name
          INDATA = STRUCT_COPY(INDATA,OK,/REMOVE)                                                                                 ; Copy the indata
          INDATA = STRUCT_RENAME(INDATA,TAG_NAMES(INDATA),REPLACE(TAG_NAMES(INDATA),'INDATA_',''))                                ; Rename the variables in the structure
        ENDIF
      ENDIF
  
    ENDIF ELSE BEGIN ; If not a .SAV file then assume .NC file (note, not all netcdf files have the ext .nc)
      
      ; ===> Get the PRODUCT information
      SI = SENSOR_INFO(FA.FULLNAME)
      NPRODS = STRSPLIT(SI.NC_PROD,SI.DELIM,/EXTRACT)
      OPRODS = STRSPLIT(SI.PRODS,SI.DELIM,/EXTRACT)
      OK = WHERE_MATCH(OPRODS, PRODS, VALID=VALID,COUNT)
      IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + NPRODS + ' not found in file.'
      NPRODS = NPRODS[OK]
      PRODS = PRODS[VALID]
      IF VALIDS('PRODS',MAINPROD) EQ '' THEN MAINPROD = VALIDS('PRODS',SI.PROD_LABEL)
      IF MAINPROD EQ '' THEN MESSAGE, 'ERROR: ' + SI.PROD_LABEL + ' is not a "valid" product'
      
      SD = READ_NC(FA.FULLNAME,PRODS=['GLOBAL',NPRODS],/LOOK)                                                                      ; Read the NC file
      IF IDLTYPE(SD) EQ 'STRING' THEN MESSAGE,'ERROR: Unable to read '+SFILE                                                      ; Check that the file was read correctly
      STR = SD.SD                                                                                                                 ; Extract the main data structure
      TAGS = TAG_NAMES(STR)                                                                                                       ; Get the tag names
      INFO = CREATE_STRUCT(INFO,'GLOBAL',SD.GLOBAL)                                                                               ; Add the GLOBAL structure from the netcdf file to the INFO structure
      ADD_INFILES = 1                                                                                                             ; Set the keyword to add the "input" files to the D3 database
    ENDELSE ; NC read step 
  ENDELSE ; End if not "stacked" steps
  
  ; ===> Get PROD specific information
  FOR D=0, N_ELEMENTS(PRODS)-1 DO BEGIN                                                                                         ; Loop through the products
    IF PRODS[D] EQ INDATA_PROD THEN INFO = CREATE_STRUCT(INFO,PRODS[D],INDATA) $                                                ; Add the INDATA information to the INFO structure???
    ELSE BEGIN
      PR = PRODS_READ(PRODS[D])                                                                                                 ; Get product specific information
      IF PR EQ [] THEN MESSAGE, 'ERROR: ' + PRODS[D] + ' not found in PRODS_MAIN.CSV'
      DSTR = CREATE_STRUCT('PROD',PR.PROD,'ALG',FP[0].ALG,'UNITS',PR.UNITS,'LONG_NAME',PR.CF_LONG_NAME, $                      ; Extract product specific information
        'STANDARD_NAME',PR.CF_STANDARD_NAME,'VALID_MIN',FLOAT(PR.PROD_MIN),'VALID_MAX',FLOAT(PR.PROD_MAX))
      INFO = CREATE_STRUCT(INFO,PR.PROD,DSTR)                                                                                  ; Add product specific information to the structure
    ENDELSE
  ENDFOR  
  
  IF KEYWORD_SET(ADD_INFO) THEN BEGIN
    IF IDLTYPE(ADD_INFO) NE 'STRING' THEN MESSAGE, 'ERROR: The ADD_INFO variable should be the tag name for the "additional information"'
    INFO = CREATE_STRUCT(INFO, ADD_INFO, INFO_CONTENT)
  ENDIF

  ; ===> Make the DB and use it to initiate the HASH
  DB = D3HASH_DB(OUTPUT_FILE,/ADD_INFILES,/ADD_ORIGINAL)                                                ; Create the D3 database to hold the input file information
  IF KEYWORD_SET(DO_STATS) OR KEYWORD_SET(DO_GRAD_STATS) THEN DB = STRUCT_RENAME(DB, ['FULLNAME','NAME'],['STATFILE','STATNAME'])
  IF KEYWORD_SET(DO_ANOMS) THEN DB = STRUCT_RENAME(DB, ['FULLNAME','NAME'],['ANOMFILE','ANOMNAME'])
  D3HASH = ORDEREDHASH('FILE_DB',DB,/EXTRACT,/FOLD_CASE)                                                                        ; Create the D3HASH with the FILE_DB (the EXTRACT keyword creates a "nested" hash for the structure so that it is easy to update

  ; ===> Add the map bins to the HASH
  IF BINS NE [] THEN D3HASH['BINS'] = BINS                                                                                      ; Add the BINS information to the HASH
  IF ~N_ELEMENTS(PX) OR ~N_ELEMENTS(PY) THEN BEGIN                                                                              ; Check for the data array dimensions
    IF ~N_ELEMENTS(BINS) THEN MESSAGE,'ERROR: Must provide either the L3B bins or PX and PY'                                    ; Check for the bins dimensions
    PX = 1 & PY = N_ELEMENTS(BINS)                                                                                              ; Use the BINS to establish the array dimensions
  ENDIF
  IF PX GT 0 THEN D3 = FLTARR(PX,PY,N_ELEMENTS(DB)) ELSE D3 = FLTARR(PY, N_ELEMENTS(DB))                                        ; Create a blank D3 array
  D3[*] = MISSINGS(D3[0])                                                                                                       ; Make the array missings

  ; ===> Add the INFO and product information to the HASH
  D3HASH['INFO'] = INFO                                                                                                         ; Add the INFO structure to the HASH
  D3HASH['PRODS'] = PRODS                                                                                                       ; Add the product name array to the HASH
  
  ; ===> Add the blank data arrays to the HASH
  CASE 1 OF
    KEYWORD_SET(DO_STATS): FOR S=0, N_ELEMENTS(STAT_TYPES)-1 DO D3HASH[MAINPROD + '_' + STAT_TYPES[S]] = D3                   ; If adding STATS create D3 arrays for each stat
    KEYWORD_SET(DO_GRAD_STATS): FOR S=0, N_ELEMENTS(STAT_TYPES)-1 DO D3HASH[MAINPROD + '_' + STAT_TYPES[S]] = D3                   ; If adding STATS create D3 arrays for each stat
    KEYWORD_SET(DO_ANOMS): FOR S=0, N_ELEMENTS(ANOM_TYPES)-1 DO D3HASH[MAINPROD + '_' + ANOM_TYPES[S]] = D3                   ; If adding ANOMS create D3 arrays for each anom
    ELSE: FOR S=0, N_ELEMENTS(PRODS)-1 DO D3HASH[VALIDS('PRODS',PRODS[S])] = D3                                                                 ; If not STATS or ANOMS then just add a D3 array for each D3 product
  ENDCASE
  
  RETURN, D3HASH


END ; ***************** End of D3HASH_MAKE *****************
