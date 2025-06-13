; $ID:	SEASCAPES_2D3HASH.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO SEASCAPES_2D3HASH, FILES, L3BMAP=L3BMAP, SUBMAP=SUBMAP, DIR_OUT=DIR_OUT, FILE_LABEL=FILE_LABEL, LOGLUN=LOGLUN,$
      VERBOSE=VERBOSE, TESTING=TESTING, OVERWRITE=OVERWRITE

;+
; NAME:
;   SEASCAPES_2D3HASH
;
; PURPOSE:
;   Convert the SEASCAPES data to a D3HASH
;
; CATEGORY:
;   SEASCAPES_FUNCTIONS
;
; CALLING SEQUENCE:
;   SEASCAPES_2D3HASH,FILES
;
; REQUIRED INPUTS:
;   FILES.......... Input seascape netcdf(s)
;
; OPTIONAL INPUTS:
;   L3BMAP......... The name of the L3B map to use to remap the global data (default=L3B5)
;   SUBMAP......... The name of the map used to subset the global map  
;   DIR_OUT........ The location of the output directory
;   FILE_LABEL..... The label in the output file
;   LOGLUN......... The lun for the log file
;
; KEYWORD PARAMETERS:
;   VERBOSE......... Print processing steps
;   TESTING......... To test the generation of the D3FILE
;   OVERWRITE....... Delete and rewrite the D3FILE if it exists
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 09, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 09, 2021 - KJWH: Initial code written
;   Nov 16, 2022 - KJWH: Now using MAPS_L3B_SUBSET to get the bin numbers for the subset map
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SEASCAPES_2D3HASH'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Set up defaults for optional inputs and keywords
  IF N_ELEMENTS(L3BMAP)     NE 1 THEN L3BMAP = 'L3B5' 
  IF N_ELEMENTS(DATERANGE)  EQ 0 THEN DATERANGE  = []                                                                           ; Make DATERANGE null if not provided
  IF N_ELEMENTS(LOGLUN)     NE 1 THEN LUN = [] ELSE LUN = LOGLUN                                                                ; Set up the LUN to record in the log file
  IF N_ELEMENTS(NCPRODS)    EQ 0 THEN NCPRODS = ['CLASS','P']
  
  ; ===> Get general information from the file names
  IF N_ELEMENTS(FILES) EQ 0 THEN MESSAGE, 'ERROR: Input files are required.'
  FP = PARSE_IT(FILES,/ALL)                                                                                                     ; Parse the file names
  IF SAME(FP.EXT) EQ 0 THEN MESSAGE, 'All input files must have the same EXTENSION'                                             ; Make sure all files have the same extension
  NAME = FP[0].NAME
  IF N_ELEMENTS(FILE_LABEL) NE 1 THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0]) ELSE _FILE_LABEL=FILE_LABEL                         ; Create the file label

  ; ===> Get additional file information
  INFOTAGS = ['SENSOR','SATELLITE','METHOD']
  OK = WHERE_MATCH(TAG_NAMES(FP),INFOTAGS,COUNT)
  IF COUNT GT 0 THEN INFO = STRUCT_COPY(FP,OK) ELSE MESSAGE, 'ERROR: Information not found in the file name'   ; Copy the "metadata" to a separate structure
  INFO = CREATE_STRUCT(INFO,'MAP','L3B5','ROUTINE',ROUTINE_NAME)
  
  ; ===> Get D3_PROD specific information
  D3PROD = []
  FOR D=0, N_ELEMENTS(NCPRODS)-1 DO BEGIN
    NPROD = NCPRODS[D]
    CASE NPROD OF
      'CLASS': PROD_NAME = 'WATER_CLASS'
      'P':     PROD_NAME = 'WATER_PROB' 
    ENDCASE
    D3PROD = [D3PROD,PROD_NAME]
    CR = STRSPLIT(VALIDS('PROD_CRITERIA',PROD_NAME),'_',/EXTRACT)
    DSTR = CREATE_STRUCT('PROD',PROD_NAME,'ALG',FP[0].ALG,'UNITS',UNITS(NPROD,/SI),'VALID_MIN',CR[0],'VALID_MAX',CR[1])
    INFO = CREATE_STRUCT(INFO,PROD_NAME,DSTR)
  ENDFOR
  
  ; ===> Get PERIOD and DATERANGE information
  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'All input files are not from the same PERIOD'                                         ; Make sure all files have the same period_code
  S = SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD))) & FP = FP[S] & FILES = FILES[S]                                                   ; Make sure files & fp in ascending order
  MTIMES = GET_MTIME(FILES)  
  PERIOD_CODE = FP[0].PERIOD_CODE                                                                                               ; Period code for the files
  PERSTR = PERIOD_2STRUCT(FP.PERIOD)
  DATE_RANGE = [STRMID(MIN(PERSTR.DATE_START),0,8), STRMID(MAX(PERSTR.DATE_END),0,8)]
  PERIOD = 'DD8_' + STRJOIN(DATE_RANGE,'_')                                                                                            ; Get the MTIME of the files
  ;PERIOD_SET  = D3_PERIODS(FP.PERIOD,SENSOR=SENSOR)  
    
  ; ===> Get the input map info and map size
  AMAP = FP[0].MAP                                                                                                             ; Map name
  MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)                                                                                           ; Get the size of the map
  
  ; ===> Get the bin numbers of the subset map
  MOBINS = []   
  IF N_ELEMENTS(L3BSUBMAP) EQ 1 THEN BLANK = MAPS_L3B_SUBSET(MAPS_BLANK(AMAP),INPUT_MAP=AMAP,SUBSET_MAP=L3BSUBMAP,OCEAN_BINS=MOBINS)$ ; Get the BIN values for the subset map
                                ELSE IF IS_L3B(AMAP) THEN MOBINS = MAPS_L3B_BINS(AMAP)                                         ; Get the BIN values of the input map if it is an L3B map and no subset map is provided
  IF MOBINS NE [] THEN BEGIN & BX = 1  & BY = N_ELEMENTS(MOBINS) & ENDIF $                                                     ; Get the array sizes of the subset bins
                  ELSE BEGIN & BX = PX & BY = PY & ENDELSE   
  
  ; ===> Set up the output directory
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = REPLACE(FP.DIR,'NC','STACKED_FILES'+SL+'SEASCAPES')  
  IF ~HAS(DIR_OUT,AMAP) THEN MESSAGE, 'ERROR: Check the output directory MAP information'                                         ; Check the output directory is correct
  DIR_TEST, DIR_OUT
  
  ; ===> Create the output file name                                                                                                  ; Make the output directory if it does not already exist
  D3_FILE = DIR_OUT +  PERIOD + '-' + _FILE_LABEL + '-D3_DAT.SAV'                                                ; Create the complete D3_FILE name if not provided
  D3_FILE = REPLACE(D3_FILE,'--','-')                                                                                             ; Clean up the file name
  
  ; ===> Search for existing files
  EFILE = FILE_SEARCH(DIR_OUT + '*' + _FILE_LABEL + '-D3_DAT.SAV',COUNT=COUNT)
  IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than one output file found in ' + DIR_OUT
  IF COUNT EQ 1 THEN IF EFILE NE D3_FILE THEN MESSAGE, 'ERROR: Check the current file in ' + DIR_OUT             ; Should convert to a widget to ask if the file should be deleted
  IF KEYWORD_SET(OVERWRITE) AND FILE_TEST(D3_FILE) THEN FILE_DELETE, D3_FILE, /VERBOSE                                            ; Delete the D3_FILE if it exists

  ; ===> Create the D3HASH file

; Need to check if D3HASH_DB and PERIOD_SEtS will work with "DD8" periods

  DB = D3HASH_DB(DATE_RANGE,PERIOD_CODE=PERIOD_CODE,/D8STEP)                          ; Create the D3 database
  PSTR = PERIOD_2STRUCT([DB[0].PERIOD,DB[-1].PERIOD])                                                                           ; Get the period information from the first and last period
  INFO = CREATE_STRUCT(INFO,'DATE_RANGE',STRJOIN(STRMID([PSTR[0].DATE_START,PSTR[1].DATE_END],0,8),'_'))                        ; Add the full daterange to the INFO structure
  D3HASH = ORDEREDHASH('D3_DB',DB,/EXTRACT,/FOLD_CASE)                                                                          ; Create the D3HASH with the D3_DB (the EXTRACT keyword creates a "nested" hash for the structure so that it is easy to update
  D3HASH['INFO'] = INFO                                                                                                         ; Add the file information structure
  IF MOBINS NE [] THEN D3HASH['BINS'] = MOBINS                                                                                  ; Add the BINS information to the HASH

  ; ===> Add the blank data arrays
  IF BY GT 0 THEN D3 = FLTARR(BX,BY,N_ELEMENTS(DB)) ELSE D3 = FLTARR(BX, N_ELEMENTS(DB))                                        ; Create a blank D3 array
  D3[*] = MISSINGS(D3)
  FOR S=0, N_ELEMENTS(D3PROD)-1 DO D3HASH['D3_' + D3_PROD[S]] = D3                               ; If not then just add a D3 array for each D3 product
  D3 = []


  
  
stop

END ; ***************** End of SEASCAPES_2D3HASH *****************
