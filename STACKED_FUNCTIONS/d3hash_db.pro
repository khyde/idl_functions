; $ID:	D3HASH_DB.PRO,	2023-09-21-13,	USER-KJWH	$
;+
	FUNCTION D3HASH_DB, FILENAME, ADD_INFILES=ADD_INFILES, ADD_ORIGINAL=ADD_ORIGINAL, _EXTRA=_EXTRA
;
; PURPOSE: 
;   Return a standard D3HASH database structure
;
; CATEGORY:	
;   D3_FUNCTIONS
;
; REQUIRED INPUTS: 
;   FILENAME.......... Name of the "stacked" file
;		
; OPTIONAL INPUTS:
;		None
;		
; KEYWORD PARAMETERS: 
;   ADD_INFILES.... Keyword to add "input" files to the structure
;   ADD_ORIGINAL... Keyword to add "original" files to the structure
;     
; OUTPUTS: 
;   A standard D3 database from the date range of all input files
;		
; OPTIONAL OUTPUTS:
;
;
; PROCEDURE:
;
;
; EXAMPLES: 
;   ST,D3HASH_DB(['20160101','20161231'])
;   ST,D3HASH_DB(['20160101','20161231'],PERIOD_CODE='W')
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
; AUTHOR INFORMATION
;   This program was written July 07, 2021 by Kimberly Hyde Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about the program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;		Jul 07, 2021 - KJWH: Initial code written (adapted from D3_DB)
;		Oct 17, 2022 - KJWH: Changed from inputing the daterange and output period code to now just using the output file name
;		Mar 06, 2024 - KJWH: Changed how the climatological WEEK and MONTH period ranges are calculated.  Now based on the daterange of the input file and not the sensor daterange
;-		
;************************************************************************************************

  ROUTINE_NAME  = 'D3HASH_DB'
  COMPILE_OPT IDL2
  
; ===> Set up defaults
  
  IF N_ELEMENTS(FILENAME) NE 1 THEN MESSAGE, 'ERROR: Must input a single filename'
  FP = PARSE_IT(FILENAME,/ALL)
  
  IF FP.PERIOD_CODE EQ '' THEN MESSAGE, 'ERROR: No period code found in file ' + FILENAME
  IF FP.SENSOR EQ '' THEN MESSAGE, 'ERROR: No sensor information found in file ' + FILENAME
  
  PSTR = VALID_PERIOD_CODES(FP.PERIOD_CODE,/STRUCT)
  SD = SENSOR_DATES(FP.SENSOR) & DS = DATE_PARSE(SD[0]) & DE = DATE_PARSE(SD[1])
  DP = PERIOD_2STRUCT(FP.PERIOD)
  DR = GET_DATERANGE([DP.DATE_START,DP.DATE_END])
  JD_START = DATE_2JD(DR[0])>DATE_2JD(SD[0]) & JD_END = DATE_2JD(DR[1])                                                   ; Get the julian dates for the first and last dates

  IF N_ELEMENTS(DR) NE 2 THEN MESSAGE,'ERROR: Date range is required'
  IF HAS_TAG(_EXTRA,'D8STEP') THEN D8STEP = _EXTRA.D8STEP ELSE D8STEP = 0
  IF HAS_TAG(_EXTRA,'D3STEP') THEN D3STEP = _EXTRA.D8STEP ELSE D3STEP = 0
  
; ===> Get the JD RANGE for the interpolation to standard days
  JDS = JD_GEN(DR) 
  YRS = YEAR_RANGE(DR[0],DR[1],/STRING)
  CASE PSTR.PERIOD_CODE OF
    '': MESSAGE, 'ERROR: Unknown input period'
    'SS': PERIOD = PSTR.STACKED_PERIOD_INPUT + '_' + STRMID(JD_2DATE(JDS),0,14)
    'DD': PERIOD = PSTR.STACKED_PERIOD_INPUT + '_' + STRMID(JD_2DATE(JDS),0,8)
    'WW': BEGIN
      PERIOD = PSTR.STACKED_PERIOD_INPUT + '_' + JD_2YEAR(JDS)+JD_2WEEK(JDS)
      PERIOD = PERIOD[UNIQ(PERIOD,SORT(PERIOD))]
    END  
    'WEEK': BEGIN
      WKS = PERIOD_SETS(JD_GEN([SD[0],DP.DATE_END]),PERIOD_CODE='W',JD_START=JD_START,JD_END=JD_END) 
      SETS=PERIOD_SETS(PERIOD_2JD(WKS.PERIOD),PERIOD_CODE='WEEK',/NESTED,JD_START=JD_START,JD_END=JD_END)
      PERIOD = TAG_NAMES(SETS)
    END  
    'MM': BEGIN
      PERIOD = PSTR.STACKED_PERIOD_INPUT + '_' + JD_2YEAR(JDS)+JD_2MONTH(JDS)
      PERIOD = PERIOD[UNIQ(PERIOD,SORT(PERIOD))]
    END
    'SEA': BEGIN
      SETS=PERIOD_SETS(JDS,PERIOD_CODE=PSTR.STACKED_PERIOD_OUTPUT,JD_START=JD_START,JD_END=JD_END,/NESTED) ; GET THE SETS FOR THIS PERIOD_CODE_OUT
      PERIOD = TAG_NAMES(SETS)
    END  
    'MONTH': BEGIN
      MTS = PERIOD_SETS(JD_GEN([SD[0],DP.DATE_END]),PERIOD_CODE='M',JD_START=JD_START,JD_END=JD_END)
      SETS = PERIOD_SETS(PERIOD_2JD(MTS.PERIOD),PERIOD_CODE='MONTH',/NESTED,JD_START=JD_START,JD_END=JD_END)
      PERIOD = TAG_NAMES(SETS)
    END  
    'AA': PERIOD = PSTR.STACKED_PERIOD_INPUT + '_' + YRS
    'ANNUAL': PERIOD = PSTR.STACKED_PERIOD_OUTPUT + '_' + STRMID(DR[0],0,4) + '_' + STRMID(DR[1],0,4)
    'DOY': BEGIN
      DP = DATE_PARSE(DR)
      IF STRMID(FP.PERIOD,0,7) EQ 'DOY_000' THEN BEGIN
        SETS = PERIOD_SETS(JD_GEN(SD),PERIOD_CODE='DOY',/NESTED)
        PERIOD = TAG_NAMES(SETS)
      ENDIF ELSE BEGIN
        IF DP[0].IDOY NE DP[1].IDOY THEN MESSAGE,'ERROR: The DOY in the date range are not the same'
        DOYS = JD_2DOY(JDS,/NO_LEAP)
        OK = WHERE(FIX(DOYS) EQ DP[0].IDOY,COUNT)
        IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Not able to find the DOY ' + DP.IDOY + ' within the date range'
        PERIOD = PSTR.STAT_INPUT_PERIOD + '_' + STRMID(JD_2DATE(JDS[OK]),0,8)
      ENDELSE  
    END  
    ELSE: BEGIN
      SETS=PERIOD_SETS(JDS,PERIOD_CODE=PSTR.STACKED_PERIOD_INPUT,JD_START=JDS[0],JD_END=JDS[-1],/NESTED, D8STEP=D8STEP, D3STEP=D3STEP) ; GET THE SETS FOR THIS PERIOD_CODE_OUT
      PERIOD = TAG_NAMES(SETS)
    END  
  ENDCASE
    
; ===> Create structure for the database information
  D = CREATE_STRUCT('DATE_RANGE','','SEQ',-1L,'PERIOD','','FULLNAME','','NAME','','MTIME',ULONG64(0))
  IF KEYWORD_SET(ADD_INFILES) THEN D = CREATE_STRUCT(D,'INPUT_FILES','')
  IF KEYWORD_SET(ADD_ORIGINAL) THEN D = CREATE_STRUCT(D,'ORIGINAL_FILES','')
  DB = REPLICATE(D,N_ELEMENTS(PERIOD))
  DB.PERIOD = PERIOD
  DB.SEQ = INDGEN(N_ELEMENTS(DB)) 
  
  RETURN, DB

END; #####################  END OF ROUTINE ################################
