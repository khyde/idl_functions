; $ID:	STACKED_STATS_TEST.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_STATS_TEST

;+
; NAME:
;   STACKED_STATS_TEST
;
; PURPOSE:
;   Temporary program to test the "stacked stats" steps
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_STATS_TEST,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 30, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 30, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_STATS_TEST'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  DO_MAKE_DATA = ''
  DO_MAKE_STACKED = ''
  DO_PSC = 'Y'
  DO_STACKED_NC = ''
  DO_STATS  = ''
  DO_EXTRACTS = ''
  DO_COMPARE_STATS = ''
  
  
  
  SUBMAP = 'RI_SOUND' & L3BMAP = 'L3B4'
  
  IF KEYWORD_SET(DO_MAKE_DATA) THEN BEGIN
    YEARS = YEAR_RANGE(['1997','1998'],/STRING)
    BLK = MAPS_BLANK(SUBMAP,FILL=MISSINGS(0.0)) 
    MASK = READ_LANDMASK(SUBMAP,/STRUCT) & OC = MASK.OCEAN
    BINS = MAPS_L3B_BINS(L3BMAP)
    
    FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
      YEAR = YEARS[Y]
      IF YEAR EQ '1997' THEN MONTHS = ['09','10','11','12'] ELSE MONTHS = MONTH_NUMBERS()
      FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
        DAYS = STRMID(CREATE_DATE(YEAR+MONTHS[M]+'01',YEAR+MONTHS[M]+DAYS_MONTH(MONTHS[M],YEAR=YEAR,/STRING)),0,8)
        FOR D=0, N_ELEMENTS(DAYS)-1 DO BEGIN
          INFILE = !S.GLOBCOLOUR + 'L3' + SL + 'L3b_' + DAYS[D] + '__GLOB_4_GSM-MODVIR_CHL1_DAY_00.nc
          FILENAME = !S.GLOBCOLOUR + L3BMAP + SL + 'SAVE' + SL + 'CHLOR_A-GSM' + SL + 'D_'+ DAYS[D] + '-GLOBCOLOUR-R2019-4KM-L3B4-CHLOR_A-GSM.SAV'
          IF FILE_TEST(FILENAME) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
          DAY = BLK
          CASE MONTHS[M] OF
            '01': DAY[OC] = 1.0
            '02': DAY[OC] = D+1.0
            '03': DAY[OC] = FINDGEN(N_ELEMENTS(OC)) * 0.1
            '04': DAY[OC] = RANDOMU(SEED,N_ELEMENTS(OC))
            '05': DAY[OC] = 30*RANDOMU(SEED,N_ELEMENTS(OC))
            ELSE: BEGIN
              DAY[OC] = D+1
              RAN = FIX(30*RANDOMU(SEED,N_ELEMENTS(OC)/2))
              SUBS = WHERE(ODD(RAN) EQ 1, COUNT)
              IF COUNT GT 0 THEN DAY[OC[SUBS]] = MISSINGS(DAY)
            END
            ENDCASE
          L3B = MAPS_REMAP(DAY,MAP_IN=SUBMAP,MAP_OUT='L3B4')
          OK = WHERE(L3B NE MISSINGS(0.0),COUNT)
          L3B = L3B[OK]
          OUTBINS = BINS[OK]
          STRUCT_WRITE, L3B, FILE=FILENAME, PROD='CHLOR_A', DATA=L3B, DATA_UNITS=UNITS('CHLOR_A',/SI), BINS=OUTBINS, NOTES='Test dataset' ; INFILES=INFILE,
        ENDFOR ; Days
      ENDFOR ; Months
    ENDFOR ; Years  
  ENDIF
  
  
  
  DSET = 'GLOBCOLOUR' & PRODS = 'CHLOR_A-GSM' & DATERANGE=GET_DATERANGE('1997','2022') & L3BMAP=SUBMAP & SHPFILE = 'NES_EPU_NOESTUARIES'
  
  IF KEYWORD_SET(DO_MAKE_STACKED) THEN STACKED_MAKE_WRAPPER, DSET, PRODS=PRODS, DATERANGE=DATERANGE, L3BSUBMAP=SUBMAP, OVERWRITE=OVERWRITE
  
  
  IF KEYWORD_SET(DO_PSC) THEN BEGIN
    STACKED_MAKE_WRAPPER, 'OCCCI', PRODS='PSC', PERIODS='M'
  ENDIF
  
  
  
  IF KEYWORD_SET(DO_STACKED_NC) THEN STACKED_MAKE_WRAPPER, 'OCCCI', PRODS='CHL', L3BMAP=SUBMAP, /NC, OVERWRITE=OVERWRITE
  IF KEYWORD_SET(DO_STATS) THEN STACKED_STATS_WRAPPER, 'GLOBCOLOUR', PRODS=PRODS, PERIODS=['DOY','M','MONTH','A','ANNUAL','W','WEEK','D8','DOY'], L3BSUBSET=SUBMAP ;BEGIN
  
  IF KEYWORD_SET(DO_EXTRACTS) THEN BEGIN
    PERIODS=['MM','MONTH','AA','ANNUAL','WW','WEEK','DOY']
    FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      FILES = GET_FILES(DSET,PRODS=PRODS,FILE_TYPE='STACKED',PERIODS=PERIODS[R],COUNT=COUNT)
      IF COUNT GT 0 THEN SUBAREAS_EXTRACT, FILES, SHP_NAME=SHPFILE, VERBOSE=VERBOSE, DIR_OUT=DIR_OUT, STRUCT=STR, SAVEFILE=SAV, OUTPUT_STATS=OUTSTATS, /ADD_DIR $
        ELSE STOP
    ENDFOR
  ENDIF
  
  IF KEYWORD_SET(DO_COMPARE_STATS) THEN BEGIN
    STACKED_FILES = GET_FILES(DSET,PRODS=PRODS, PERIODS='MM', FILE_TYPE='STACKED')   
    
    FOR S=0, N_ELEMENTS(STACKED_FILES)-1 DO BEGIN
      SF = STACKED_READ(STACKED_FILES[S],KEYS=KEYS,BINS=SBINS)
      PERIODS = SF.DB.PERIOD
      FOR N=2, N_ELEMENTS(PERIODS)-1 DO BEGIN
        APER = PERIODS[N]
        SPER = PERIOD_2STRUCT(APER)
        ORG_FILES = GET_FILES(DSET, PRODS=PRODS, PERIODS='D', DATERANGE=[SPER.DATE_START,SPER.DATE_END])
        FP = PARSE_IT(ORG_FILES,/ALL)
        STATS_ARRAYS_PERIODS, ORG_FILES, PERIOD_CODE_OUT='D8', DATERANGE=[SPER.DATE_START,SPER.DATE_END], DO_STATS=['NUM','MIN','MAX','SPAN','SUM','MEAN','STD','CV','GMEAN'],$
          OVERWRITE=1, VERBOSE=1, OUTSTRUCT=OUTSTRUCT,SKIP_SAVE=1
   
        STAGS = ['NUM','MIN','MAX','SPAN','SUM','MEAN','STD','CV','GMEAN']
        FOR T=0, N_ELEMENTS(STAGS)-1 DO BEGIN
          OK = WHERE(TAG_NAMES(OUTSTRUCT) EQ STAGS[T])
          OD = OUTSTRUCT.(OK) & OD = MAPS_REMAP(OD, MAP_IN='L3B4', MAP_OUT=SUBMAP, BINS=OUTSTRUCT.BINS)
          SD = SF.(WHERE(TAG_NAMES(SF) EQ FP[0].PROD+ '_' + STAGS[T])) & SD = SD[*,N] & SD = MAPS_REMAP(SD, MAP_IN='L3B4', MAP_OUT=SUBMAP, BINS=SBINS)          
          DD = SD-OD
          PRINT, STAGS[T]
          PMM, DD
          PRINT, MAX(ABS(DD),/nan)
        ;  IF MIN(DD) NE 0.0 OR MAX(DD) NE 0.0 THEN IMGR, DD, DELAY=2, PROD='NUM_-1_1'
          ; TAKE THE DIFFERENCE BETWEEN DT AND DS AND PRINT THE MINMAX - FIND WHERE IT DOESN'T EQUAL 0
        if n_elements(where(max(abs(dd),/nan) gt 0.0,/null)) then stop
        ENDFOR
      
      ENDFOR
      stop
    ENDFOR

    
    
  ENDIF
  


END ; ***************** End of STACKED_STATS_TEST *****************
