; $ID:	PERIOD_SETS.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION PERIOD_SETS, JD, PERIOD_CODE=PERIOD_CODE, DATA=DATA, WIDTH=WIDTH, JD_START=JD_START, JD_END=JD_END, DELIM = DELIM,$
                      DATE=DATE, PERIODS=PERIODS, NOLEAP=NOLEAP, D3STEP=D3STEP, D8STEP=D8STEP, EVEN_PERIOD=EVEN_PERIOD, NESTED=NESTED
;+
; NAME:
;   PERIOD_SETS
;
; PURPOSE:
;   Group JD dates based on an 'official' period code 
; 
; CATEGORY:
;   DATE_FUNCTIONS
; 
; REQUIRED INPUTS:
;   JD............. The IDL julian date
;   PERIOD_CODE.... A valid period code
;
; OPTIONAL INPUTS:
;   DATA........... Optional array of data paired with the JD array. If DATA are provided then the output are data sets grouped by time period
;   WIDTH.......... The interval to be used with some periods (e.g. a width of 3 and period code MM will return 3 month intervals)
;   JD_START....... The first date (in julian dates) for the sets. JD_START is also useful when initializing and standardizing groups to a common start when PERIOD_CODE ='DD' or 'MM'
;   JD_END......... The last date (in julian dates) for the sets.
;   DELIM.......... The delimiter to use when joining all subscripts for a set (default is ; )
;    
; KEYWORD PARAMETERS:
;   DATE........... If this is set then the input data (JD) is assumed to be date and will be conveted into julian
;   PERIODS........ If set then the input data is period
;   NOLEAP......... Limits day of year to 365 (lumps DOY 366 in the 365 bin)
;   EVEN_PERIOD.... Used in the MM period option
;   NESTED......... Structure will be nested
;
; OUTPUTS:
;   An array of subscript numbers for those array elements belonging to each TIME PERIOD 
;     or if DATA are provided then output are data sets grouped by the specified time period
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
;   This routines makes several of assumptions:
;     1) The code assumes that jd_start and jd_end will be based on the input period_type, e.g. D FOR DD, meaning that
;          the jd of the input is already rounded to the nearest day.
;     2) Arrays are added together in different ways depending on the input and output formats.
;     3) Sets, jd_sets, and name are crucial
;
; EXAMPLE:
;
; NOTES:
;   Period format examples
;     YYYY = Year
;     YMIN = Minimum of years in range
;     YMAX = Maximum of years in range
;     MM   = Month
;     MN   = Minimum of months in range
;     MA   = Maximum of months in range
;     WW   = Week
;     DD   = Day
;     DDD  = DOY
;     SS   = Seconds
;
;   Example of a processing series 
;     INPUT PERIOD ==> OUTPUT PERIOD(S)
;       S     ===> D; SS; ALL
;       D     ===> D3; D8; W; M; Y; DOY; STUDY; DD; ALL
;       W     ===> WEEK; WW
;       M     ===> M3; A; MONTH; MM
;       M3    ===> MONTH3
;       A     ===> ANNUAL
;       MONTH ===> MANNUAL
;       Y     ===> YY; YEAR
;
; COPYRIGHT:
; Copyright (C) 1998, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 28, 1998 by John E O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
; 
; MODIFICATION HISTORY:
;   DEC 28, 1998 - JEOR: Initial code written
;   FEB 19, 1999 - JEOR: Changed logic
;   OCT 07, 1999 - JEOR: Added LABEL keyword
;   DEC 27, 1999 - JEOR: Added DOY and YDOY
;   OCT 22, 2000 - JEOR: Revised to follow IDL calendar date format and julian input
;   MAY 07, 2002 - TD:   Added DT_RANGE
;   JUN 25, 2002 - JEOR: Changed 'D_' TO 'DT_' for 1D
;		JUN   , 2003 - JEOR: Extensive modifications to use new standard period_codes
;				                 Credit for the double histogram approach to: J.D. Smith as reported by D.FANNING
;		MAR 14, 2004 - JEOR: Added JD_START and JD_END keywords
;		AUG 16, 2005 - JEOR: Now using WHERE_SETS
;		FEB 14, 2011 - DWM:  Changed period_code blocks to CASE statements
;		                     Modified period_codes and output names using new 2011 standards
;		                     Removed the usage of '!' in period codes.
;		MAY 20, 2011 - DWM:  Fixed WEEK/DOY/MONTH algorithms to only include years when the WEEK/DOY/MONTH is available
;		FEB 12, 2014 - JEOR: Updated formatting
;		                     Added message for error
;		                     Made error an informative error string
;		                     Removed old comments
;		FEB 26, 2014 - JEOR: Added FUTURE_YEAR='2100'
;		MAR 04, 2014 - JEOR: Added example of period_codes_in/ out 
;		JUN 26, 2014 - JEOR: Added new month code  e.g. MONTH_01_1997_2014
;		                     NAME(I) = 'MONTH' + UL + MONN + UL + YEAR(OK(0))  + UL + YEAR(OK(NOK-1))
;   MAR 07, 2017 - KJWH: In DOY block, changed  DT = FIX(JD_2DOY(JD,NOLEAP=1)) to  DT = FIX(JD_2DOY(JD,NO_LEAP=1)) (fixed NO_LEAP)
;                        Changed the DOY period output to DOY_YYYY_YYYY - NAME(I-1) = 'DOY' + UL + DOYN + UL + YEAR(OK(0)) + UL + YEAR(OK(NOK-1))
;   MAR 22, 2017 - KJWH: In WEEK block, changed the output to be WEEK_WW_YYYY_YYYY    
;   MAR 28, 2017 - KJWH: In WEEK block, added IF NOK EQ 0 THEN CONTINUE            
;   JUL 21, 2017 - KJWH: In D8 block, changed SETS=SETS(3:N_ELEMENTS(SETS)-4) to -5 (BUG FIX) 
;   DEC 04, 2017 - KJWH: Changed the M3 so that it is now returning sets for a running 3-month mean  
;   FEB 01, 2018 - KJWH: Excluding the current year in the ANNUAL calculation
;                        Checking the SENSOR_DATES and excluding the first year if the first date was after January 31st
;                        Added SETS = SETS[WHERE(SETS.N EQ 12)] in the 'A' block to exclude years that have less than 12 months of input data in the A_yyyy calculation
;   FEB 14, 2018 - KJWH: Fixed bugs in the D3, D8 and M3 blocks for when no files were found within the date interval range
;                          S = S[WHERE(S NE -1,/NULL)]
;                          IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
;                          IF SUBS_TXT NE '' THEN SETS(N).SUBS=SUBS_TXT     
;   FEB 16, 2018 - KJWH: Removed IF SUBS_TXT NE '' THEN from the D3, D8 and M3 blocks.  Now SETS with no valid data will have '' for the SUB_TXT   
;                        Added OK = WHERE(SETS.SUBS NE MISSINGS(SETS.SUBS),/NULL,COUNT_SETS) in the "CHECK" section to remove periods with no SUBS   
;                                IF COUNT_SETS GE 1 THEN BEGIN ; ;   ======> STRUCTURE WILL HAVE A SEPARATE TAG FOR EACH SET
;                                  SETS = SETS[OK]
;                                  NAME = NAME[OK]    
;   JUL 17, 2018 - KJWH: Added MONTH3 block     
;   NOV 13, 2018 - KJWH: Added /NULL to SETS = SETS[WHERE(SETS.N EQ 12,/NULL)] in the 'A' block to exclude years that have less than 12 months of input data
;                        Then return [] if no valid sets are found - IF SETS EQ [] THEN RETURN, []                                                      
;   AUG 11, 2021 - KJWH: Updated documentation & formatting
;                        Removed LABEL and DEC inputs because it is no longer used
;                        Removed the FORMAT default because it is no longer an optional input
;                        Added D3STEP and D8STEP keywords to indicate that the D3 and D8 subscripts should be every 3/8 days instead of a "running" 3/8 day array
;                        Updated how the D3 and D8 subscripts are determined (now using a FOR loop)
;                        Removed GOTO_CHECK because it is not needed with the CASE block
;                        Moved to DATE_FUNCTIONS
;
;-
; **********************************************************************************************************************
  ROUTINE_NAME = 'PERIOD_SETS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  UL = '_'
  FUTURE_YEAR='2100'

; ===> Check input data and set defaults
  IF N_ELEMENTS(JD)     EQ 0 OR N_ELEMENTS(PERIOD_CODE) NE 1 THEN MESSAGE, 'ERROR: Must provide JD and PERIOD_CODE' 
  IF N_ELEMENTS(JD) 		EQ N_ELEMENTS(DATA) THEN USE_DATA = 1 ELSE USE_DATA = 0    ; If DATA is provided, then the arrays returned are to be the data instead of the subscripts
  IF N_ELEMENTS(WIDTH) 	NE 1 								THEN _WIDTH = 1   ELSE _WIDTH = WIDTH
  IF N_ELEMENTS(DELIM) 	NE 1 								THEN DELIM = ';'

  
  PERIOD_CODE = STRTRIM(STRUPCASE(PERIOD_CODE),2) ; Convert period code to upper case

  ; ===> Copy the original inputs so they are not altered
  IF KEYWORD_SET(DATE) 		THEN JD = DATE_2JD(JD)
  IF KEYWORD_SET(PERIODS) THEN JD = PERIOD_2JD(JD)
  IF USE_DATA EQ 1 THEN _DATA = DATA

  ;	===> Subset data based on JD_START
  IF N_ELEMENTS(JD_START) EQ 1 THEN BEGIN
    OK=WHERE(JD GE JD_START, COUNT)
    IF COUNT GE 1 THEN BEGIN
      JD=JD[OK]
      IF KEYWORD_SET(USE_DATA) THEN _DATA=_DATA[OK]
    ENDIF ELSE BEGIN
      PRINT, 'ERROR: All JD are less than JD_START'
      RETURN,[]
    ENDELSE
  ENDIF

  ;	===> Subset data based on JD_END
  IF N_ELEMENTS(JD_END) EQ 1 THEN BEGIN
    OK=WHERE(JD LE JD_END,COUNT)
    IF COUNT GE 1 THEN BEGIN
      JD=JD[OK]
      IF USE_DATA EQ 1 THEN _DATA=_DATA[OK]
    ENDIF ELSE BEGIN
      PRINT, 'ERROR: All JD are greater than JD_END'
      RETURN,[]
    ENDELSE
  ENDIF;IF N_ELEMENTS(JD_END) EQ 1 THEN BEGIN

; ############################################################################################################
  ; ===> Determine the outputs based on the input period code
  CASE PERIOD_CODE OF
    ; ===> INPUT=S_YYYYMMDDHHMMSS; OUTPUT=SS_YYYYMMDDHHMMSS_YYYYMMDDHHMMSS
    'SS': BEGIN
      SETS=WHERE_SETS(JD)
      NAME=PERIOD_CODE+UL+JD_2DATE(MIN(JD))+UL+JD_2DATE(MAX(JD))
      ARR=CREATE_STRUCT(NAME[0],  _DATA(SETS.SUBS))
    END;'SS'
    
    ; ===> INPUT=S_YYYYMMDDHHMMSS; OUTPUT=D_YYYYMMDD
    'D': BEGIN 
      DT = LONG(ROUND(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+ JD_2YMD(SETS.VALUE)                                                              
      JD_SETS=DOUBLE(SETS.VALUE)
    END ;'D'

    ; ===> INPUT=D_YYYYMMDD; OUTPUT=D3_YMINMMDD_YMAXMMDD
    'D3': BEGIN 
      DT   = LONG64(ROUND(JD))
      IF KEYWORD_SET(D3STEP) THEN D3INT = 3 ELSE D3INT = 1
      DTS  = INTERVAL([MIN(DT),MAX(DT)],D3INT) ; Fill in for missing dates
      SETS = WHERE_SETS(DTS)
      IF D3INT EQ 1 THEN BEGIN
        SUBSCRIPTS = INDGEN(3)-1
        SETS = SETS[1:N_ELEMENTS(SETS)-2]
        NAME = PERIOD_CODE+UL+ JD_2YMD(SETS.VALUE-1)+UL+JD_2YMD(SETS.VALUE+1)
        FOR N=0,N_ELEMENTS(SETS)-1 DO BEGIN
          S = []
          FOR D=0, N_ELEMENTS(SUBSCRIPTS)-1 DO S = [S,NUM2STR(WHERE(DT EQ SETS[N].VALUE+SUBSCRIPTS[D]))]
          S = S[WHERE(S NE '-1',/NULL)]
          IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
          SETS[N].SUBS=SUBS_TXT
        ENDFOR
      ENDIF ELSE NAME = PERIOD_CODE+UL+ JD_2YMD(SETS.VALUE)+UL+JD_2YMD(SETS.VALUE+2)   
      JD_SETS = JD_ADD(SETS.VALUE,1,/DAY)                     
    END ;'D3'

    ; ===> INPUT=D_YYYYMMDD; OUTPUT=D8_YYYYMMDD_YYYYMMDD
    'D8': BEGIN 
      DT = LONG64(ROUND(JD))
      IF KEYWORD_SET(D8STEP) THEN D8INT = 8 ELSE D8INT = 1
      DTS = INTERVAL([MIN(DT),MAX(DT)],D8INT) ; Fill in for missing dates
      SETS=WHERE_SETS(DTS)
      IF D8INT EQ 1 THEN BEGIN
        SUBSCRIPTS = INDGEN(8)-3
        SETS=SETS[3:N_ELEMENTS(SETS)-5] ; Remove the beginning and end files since they won't have 8 days to go into the file
        NAME=PERIOD_CODE+UL+ JD_2YMD(JD_ADD(SETS.VALUE,-3,/DAY))+UL+JD_2YMD(JD_ADD(SETS.VALUE,4,/DAY))
        FOR N=0,N_ELEMENTS(SETS)-1 DO BEGIN
          S = []
          FOR D=0, N_ELEMENTS(SUBSCRIPTS)-1 DO S = [S,NUM2STR(WHERE(DT EQ SETS[N].VALUE+SUBSCRIPTS[D]))]
          S = S[WHERE(S NE '-1',/NULL)]
          IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
          SETS[N].SUBS=SUBS_TXT
        ENDFOR
      ENDIF ELSE NAME=PERIOD_CODE+UL+ JD_2YMD(JD_ADD(SETS.VALUE,/DAY))+UL+JD_2YMD(JD_ADD(SETS.VALUE,7,/DAY))
      JD_SETS = JD_ADD(SETS.VALUE,4,/DAY)
    END;'D8'

    ; ===> INPUT=D_YYYYMMDD; OUTPUT=DD_YYYYMMDD_YYYYMMDD
    'DD': BEGIN
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+JD_2YMD(MIN(JD))+UL+JD_2YMD(MAX(JD))
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END;'DD'
    
    ; ===> INPUT='D_YYYYMMDD'; OUTPUT='DOY_YYYYDOY_YYYYDOY'
    'DOY': BEGIN ; Mean of the daily files in the climatological year range
      DT = FIX(JD_2DOY(JD,NO_LEAP=1))
      YEAR = JD_2YEAR(JD)
      SETS=WHERE_SETS(DT)
      MINDOY = MIN(DT)
      MAXDOY = MAX(DT)
      D = STRING(SETS.VALUE,FORMAT='(I03)')
      DS = STRING(DT,FORMAT='(I03)')
      ;NAME =  PERIOD_CODE + UL + MIN(Y) + D + UL + MAX(Y) + D
      NAME = STRING(INDGEN(N_ELEMENTS(SETS)))
      FOR I=0, N_ELEMENTS(SETS)-1 DO BEGIN
        DOYN = STRING(SETS[I].VALUE,FORMAT='(I03)')
        OK = WHERE(DS EQ DOYN,NOK) ; OK = WHERE_IN(DS,DOYN) ; Changed from using WHERE_IN to WHERE on 11/8/2022 by KJWH in an effort to speed up the program
        NAME[I] = 'DOY' + UL + DOYN + UL + YEAR[OK[0]] + UL + YEAR[OK[NOK-1]]
      ENDFOR
      JD_SETS= JULDAY(1,SETS.VALUE,FUTURE_YEAR)
    END
      
    ; ===> INPUT = D_YYYYMMDD; OUTPUT=W_YYYYWW
    'W': BEGIN
      YEAR = JD_2YEAR(JD)
      WEEK = JD_2WEEK(JD)
      DT  = JD_2YEAR(JD)+WEEK
      SETS = WHERE_SETS(DT)
      NAME = PERIOD_CODE+UL+STRTRIM(SETS.VALUE,2)
      JD = PERIOD_2JD(NAME)
      DPW = JD_DAYS_WEEK(JD)
      JD_SETS = JD+DOUBLE(DPW)/2D
    END;'W'

    ; ===> INPUT=W_YYYYWW; OUTPUT=WW_YYYYWW_YYYYWW
    'WW': BEGIN 
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+JD_2YEAR(MIN(JD))+JD_2WEEK(MIN(JD))+UL+JD_2YEAR(MAX(JD))+JD_2WEEK(MAX(JD))
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END;'WW'  
             
    ; ===> INPUT=W_YYYYWW; OUTPUT=WEEK_YMINWW_YMAXWW)
    'WEEK' : BEGIN ; Mean for each week for all years in the climatological range
      WEEK = JD_2WEEK(JD)
      DT   = WEEK
      SETS = WHERE_SETS(DT)
      YEAR = JD_2YEAR(JD)
      WN1 = STRTRIM(SETS.VALUE,2)
      NAME = PERIOD_CODE+UL+WN1+UL+MIN(YEAR)+UL+MAX(YEAR) ; Set the NAMES to make sure PERIOD_2JD works correctly
      JD  = PERIOD_2JD(NAME)
      NAME = WN1 ; Build temporary name array with n_elements of WN1
      FOR I = 1, 52 DO BEGIN ; Check week array for all weeks
        WEEKN = STRING(I,FORMAT='(I02)')
        OK = WHERE_IN(WEEK,WEEKN)
        NOK = N_ELEMENTS(OK)
        IF NOK EQ 0 THEN CONTINUE
        NAME[WHERE(NAME EQ WEEKN,/NULL)] = 'WEEK' + UL + WEEKN + UL + YEAR[OK[0]] + UL + YEAR[OK[NOK-1]]
      ENDFOR
      DPW  = JD_DAYS_WEEK(JD)
      JD_SETS = JD+DOUBLE(DPW)/2D
    END ; WEEK

    ; ===> INPUT=D_YYYYMMDD; OUTPUT=M_YYYYMM
    'M'    : BEGIN
      DT  = LONG(STRING(JD, FORMAT='(C(CYI4.4,CMOI2.2))'))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+STRTRIM(SETS.VALUE,2)
      JD_SETS= JD_2JD(DATE_2JD(STRTRIM(SETS.VALUE,2)),/MONTH,/MID)
    END ; M

    ; ===> INPUT=M_YYYYMM; OUTPUT = MM_YYYYMM_YYYYMM
    'MM': BEGIN ; Mean of the months in the input range
      MIN_JD=ROUND(MIN(JD)) ; IF N_ELEMENTS(JD_START) EQ 1 THEN MIN_JD = ROUND(JD_START) ELSE 
      MAX_JD=ROUND(MAX(JD)) ; IF N_ELEMENTS(JD_END)   EQ 1 THEN MAX_JD = ROUND(JD_END) ELSE
      IF KEYWORD_SET(EVEN_PERIOD)  THEN MIN_JD = JD_2JD(MIN_JD,/YEAR,/START)

      MIN_DATE = JD_2DATE(JD_2JD(MIN_JD,/MONTH,/START))
      MIN_YYYY = LONG(STRMID(MIN_DATE,0,4))
      MIN_MM   = LONG(STRMID(MIN_DATE,4,2))

      YEAR= LONG(STRING(JD, FORMAT='(C(CYI4.4))'))
      MIN_YYYY = MIN(YEAR)

      MONTH=LONG(STRING(JD, FORMAT='(C(CMOI2.2))'))
      DMONTHS = _WIDTH*((LONG(MONTH)+((LONG(YEAR)-LONG(MIN_YYYY))*12)-MIN_MM)/_WIDTH)
      MM=MIN_MM+DMONTHS
      
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME =PERIOD_CODE + UL + STRMID(JD_2DATE(MIN_JD),0,6)+UL+STRMID(JD_2DATE(MAX_JD),0,6)
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ; MM

    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M3_YYYYMM_YYYYMM
    'M3': BEGIN ; Creates a running 3 month mean
      _WIDTH=3    
      DT   = LONG64(ROUND(JD))
      MDT  = STRMID(JD_2DATE(JD),0,6)
      DTS  = DATE_GEN(JD_2DATE([MIN(DT),MAX(DT)]),UNITS = 'MONTH') ; Fill in any missing dates
      SETS = WHERE_SETS(DTS)
      NAME = []
      FOR N=1,N_ELEMENTS(SETS)-2 DO BEGIN
        NAME = [NAME,PERIOD_CODE+UL+ SETS[N-1].VALUE+UL+SETS[N+1].VALUE]
        SUB1=WHERE(MDT EQ SETS[N-1].VALUE, C1)
        SUB2=WHERE(MDT EQ SETS[N].VALUE,   C2)
        SUB3=WHERE(MDT EQ SETS[N+1].VALUE, C3)
        S = [NUM2STR(SUB1), NUM2STR(SUB2), NUM2STR(SUB3)]
        S = S[WHERE(S NE -1,/NULL)]
        IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
        SETS[N].SUBS=SUBS_TXT
      ENDFOR
      SETS = SETS[1:-2]
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ;'M3'
    
    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M3_YYYYMM_YYYYMM
    'MM3': BEGIN ; Creates a running 3 month mean
     IF N_ELEMENTS(JD_START) EQ 1 THEN MIN_JD = ROUND(JD_START) ELSE MIN_JD=ROUND(MIN(JD))
     IF N_ELEMENTS(JD_END)   EQ 1 THEN MAX_JD = ROUND(JD_END) ELSE MAX_JD=ROUND(JD_ADD(MAX(JD),-1,/MONTH))
     IF KEYWORD_SET(EVEN_PERIOD)  THEN MIN_JD = JD_2JD(MIN_JD,/YEAR,/START)

     MIN_DATE = JD_2DATE(JD_2JD(MIN_JD,/MONTH,/START))
     MIN_YYYY = LONG(STRMID(MIN_DATE,0,4))
     MIN_MM   = LONG(STRMID(MIN_DATE,4,2))

     YEAR= LONG(STRING(JD, FORMAT='(C(CYI4.4))'))
     MIN_YYYY = MIN(YEAR)

     MONTH=LONG(STRING(JD, FORMAT='(C(CMOI2.2))'))
     DMONTHS = _WIDTH*((LONG(MONTH)+((LONG(YEAR)-LONG(MIN_YYYY))*12)-MIN_MM)/_WIDTH)
     MM=MIN_MM+DMONTHS

     DT = REPLICATE(1,N_ELEMENTS(JD))
     SETS=WHERE_SETS(DT)
     NAME =PERIOD_CODE + UL + STRMID(JD_2DATE(MIN_JD),0,6)+UL+STRMID(JD_2DATE(MAX_JD),0,6)
     JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
      
    END ;'MM3'
    
    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M4_YYYYMM_YYYYMM
    'M4': BEGIN ; Creates a running 4 month mean
      _WIDTH=3
      DT   = LONG64(ROUND(JD))
      MDT  = STRMID(JD_2DATE(JD),0,6)
      DTS  = DATE_GEN(JD_2DATE([MIN(DT),MAX(DT)]),UNITS = 'MONTH') ; Fill in any missing dates
      SETS = WHERE_SETS(DTS)
      NAME = []
      FOR N=1,N_ELEMENTS(SETS)-3 DO BEGIN
        NAME = [NAME,PERIOD_CODE+UL+ SETS[N-1].VALUE+UL+SETS[N+2].VALUE]
        SUB1=WHERE(MDT EQ SETS[N-2].VALUE, C1)
        SUB2=WHERE(MDT EQ SETS[N-1].VALUE,   C2)
        SUB3=WHERE(MDT EQ SETS[N].VALUE, C3)
        SUB4=WHERE(MDT EQ SETS[N+1].VALUE, C4)
        S = [NUM2STR(SUB1), NUM2STR(SUB2), NUM2STR(SUB3), NUM2STR(SUB4)]
        S = S[WHERE(S NE -1,/NULL)]
        IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
        SETS[N].SUBS=SUBS_TXT
      ENDFOR
      SETS = SETS[1:-3]
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ;'M4'
    
    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M5_YYYYMM_YYYYMM
    'M5': BEGIN ; Creates a running 5 month mean
      _WIDTH=3
      DT   = LONG64(ROUND(JD))
      MDT  = STRMID(JD_2DATE(JD),0,6)
      DTS  = DATE_GEN(JD_2DATE([MIN(DT),MAX(DT)]),UNITS = 'MONTH') ; Fill in any missing dates
      SETS = WHERE_SETS(DTS)
      NAME = []
      FOR N=1,N_ELEMENTS(SETS)-2 DO BEGIN
        NAME = [NAME,PERIOD_CODE+UL+ SETS[N-1].VALUE+UL+SETS[N+1].VALUE]
        SUB1=WHERE(MDT EQ SETS[N-1].VALUE, C1)
        SUB2=WHERE(MDT EQ SETS[N].VALUE,   C2)
        SUB3=WHERE(MDT EQ SETS[N+1].VALUE, C3)
        S = [NUM2STR(SUB1), NUM2STR(SUB2), NUM2STR(SUB3)]
        S = S[WHERE(S NE -1,/NULL)]
        IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
        SETS[N].SUBS=SUBS_TXT
      ENDFOR
      SETS = SETS[1:-2]
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ;'M5'
    
    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M6_YYYYMM_YYYYMM
    'M6': BEGIN ; Creates a running 6 month mean
      _WIDTH=3
      DT   = LONG64(ROUND(JD))
      MDT  = STRMID(JD_2DATE(JD),0,6)
      DTS  = DATE_GEN(JD_2DATE([MIN(DT),MAX(DT)]),UNITS = 'MONTH') ; Fill in any missing dates
      SETS = WHERE_SETS(DTS)
      NAME = []
      FOR N=1,N_ELEMENTS(SETS)-2 DO BEGIN
        NAME = [NAME,PERIOD_CODE+UL+ SETS[N-1].VALUE+UL+SETS[N+1].VALUE]
        SUB1=WHERE(MDT EQ SETS[N-1].VALUE, C1)
        SUB2=WHERE(MDT EQ SETS[N].VALUE,   C2)
        SUB3=WHERE(MDT EQ SETS[N+1].VALUE, C3)
        S = [NUM2STR(SUB1), NUM2STR(SUB2), NUM2STR(SUB3)]
        S = S[WHERE(S NE -1,/NULL)]
        IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
        SETS[N].SUBS=SUBS_TXT
      ENDFOR
      SETS = SETS[1:-2]
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ;'M6'
    
    ; ===> INPUT=D_YYYYMMDD; OUTPUT = M3_YYYYMM_YYYYMM
    'SEA': BEGIN ; Creates a running 3 month mean
      _WIDTH=3
      DT   = LONG64(ROUND(JD))
      MDT  = STRMID(JD_2DATE(JD),0,6)
      DTS  = DATE_GEN(JD_2DATE([MIN(DT),MAX(DT)]),UNITS = 'MONTH') ; Fill in any missing dates
      SETS = WHERE_SETS(DTS)
      NAME = []
      FOR N=1,N_ELEMENTS(SETS)-2 DO BEGIN
        NAME = [NAME,PERIOD_CODE+UL+ SETS[N-1].VALUE+UL+SETS[N+1].VALUE]
        SUB1=WHERE(MDT EQ SETS[N-1].VALUE, C1)
        SUB2=WHERE(MDT EQ SETS[N].VALUE,   C2)
        SUB3=WHERE(MDT EQ SETS[N+1].VALUE, C3)
        S = [NUM2STR(SUB1), NUM2STR(SUB2), NUM2STR(SUB3)]
        S = S[WHERE(S NE -1,/NULL)]
        IF S NE [] THEN SUBS_TXT = STRJOIN(S,';') ELSE SUBS_TXT = ''
        SETS[N].SUBS=SUBS_TXT
      ENDFOR
      SETS = SETS[1:-2]
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ;'SEA'

    ; ===> INPUT=M_YYYYMM; OUTPUT=A_YYYY
    'A': BEGIN
      Y = JD_2YEAR(JD)
      SETS = WHERE_SETS(Y)
      SETS = SETS[WHERE(SETS.N EQ 12,/NULL)] ; Exclude years that have less than 12 months of input data
      IF SETS EQ [] THEN RETURN, []
      N1 = STRTRIM(SETS.VALUE,2)
      NAME = PERIOD_CODE+UL+N1
      JD_SETS  = PERIOD_2JD(NAME) 
    END ; 'A'
    
    ; ===> INPUT=M_YYYYMM; OUTPUT=A_YYYY
    'AA': BEGIN
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+JD_2YEAR(MIN(JD))+UL+JD_2YEAR(MAX(JD))
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ; 'AA'

    ; ===> INPUT='D_YYYYMMDD'; OUTPUT= 'Y_YEAR'
    'Y': BEGIN
      DT = LONG(STRING(JD, FORMAT='(C(CYI4.4))'))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE[0]+UL+ STRTRIM(SETS.VALUE,2)
      JD_SETS= JD_2JD(DATE_2JD(STRTRIM(SETS.VALUE,2)),/YEAR,/MID)
    END; 'Y'

    ; ===> INPUT='M_YYYYMM'; OUTPUT='MONTH_YYYYMM_YYYYMM'
    'MONTH' :BEGIN ; Mean of the months in the climatological year range
      DTS = STRING(JD, FORMAT='(C(CMOI2.2))')
      DT = LONG(DTS)
      MINMON = MIN(DT)
      MAXMON = MAX(DT)
      YEAR = STRING(JD, FORMAT='(C(CYI4.4))')
      SETS=WHERE_SETS(DT)
      JD_SETS= JD_2JD(JULDAY(SETS.VALUE,1,FUTURE_YEAR,0,0,0),/MONTH,/MID)
      ;JD_NAME= STRING(JD_SETS, FORMAT='(C(CMOI2.2))')
      MOS =  + STRING(JD_SETS, FORMAT='(C(CMOI2.2))')
      ;JD_NAME= MIN(YEAR) + MOS + UL + MAX(YEAR) + MOS
      NAME = MOS
      FOR I = 0, N_ELEMENTS(NAME)-1 DO BEGIN
        MONN = MOS[I]
        OK = WHERE_IN(DTS,MONN)
        NOK = N_ELEMENTS(OK)
        NAME[WHERE(NAME EQ MONN,/NULL)] = 'MONTH' + UL + MONN + UL + YEAR[OK[0]]  + UL + YEAR[OK[NOK-1]]
      ENDFOR
    END ; 'MONTH'
    
    ; ====> INPUT='M3_YYYYMM_YYYYMM'; OUTPUT='MONTH3_YYYYMM_YYYYMM'
    'MONTH3' :BEGIN ; Mean of the M3 months in the climatological year range (or long-term seasonal means)
      DTS = STRING(JD, FORMAT='(C(CMOI2.2))')
      DT = LONG(DTS)
      MINMON = MIN(DT)
      MAXMON = MAX(DT)
      YEAR = STRING(JD, FORMAT='(C(CYI4.4))')
      SETS=WHERE_SETS(DT)
      JD_SETS= JD_2JD(JULDAY(SETS.VALUE,1,FUTURE_YEAR,0,0,0),/MONTH,/MID)
      ;JD_NAME= STRING(JD_SETS, FORMAT='(C(CMOI2.2))')
      MOS = STRING(JD_SETS, FORMAT='(C(CMOI2.2))')
      MOE = STRING(SHIFT(JD_SETS,-2), FORMAT='(C(CMOI2.2))')
      ;JD_NAME= MIN(YEAR) + MOS + UL + MAX(YEAR) + MOS
      NAME = MOS
      FOR I = 0, N_ELEMENTS(NAME)-1 DO BEGIN
        MONN = MOS[I]
        OK = WHERE_IN(DTS,MONN)
        NOK = N_ELEMENTS(OK)
        NAME[WHERE(NAME EQ MONN,/NULL)] = 'MONTH3' + UL + MOS[I] + UL + MOE[I] + UL + YEAR[OK[0]]  + UL + YEAR[OK[NOK-1]]
      ENDFOR
    END ; 'MONTH3'

    ; INPUT='S_YYYYMMDDHHSSMMSS' or 'D_YYYYMMDD'; OUTPUT='ALL_YYYYMMDD_YYYYMMDD'
    'ALL': BEGIN
      MESSAGE,'Check that the "ALL" period code is working correctly'
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SD = JD_2DATE(MIN(JD))
      ED = JD_2DATE(MAX(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE + UL + SD + UL + ED
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END; 'ALL'

    ; INPUT='S_YYYYMMDDHHSSMMSS' or 'D_YYYYMMDD'; OUTPUT='STUDY_YYYYMMDD_YYYYMMDD'
    'STUDY': BEGIN
      MESSAGE,'Check that the "STUDY" period code is working correctly'
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+JD_2YMD(MIN(JD))+UL+JD_2YMD(MAX(JD))
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ; 'STUDY'

    ; ===> INPUT='A_YYYY'; OUTPUT='ANNUAL_YYYY_YYYY'
    'ANNUAL' : BEGIN ; Mean of the annual in the climatologial range
      DT = REPLICATE(0,N_ELEMENTS(JD))
      YEAR = JD_2YEAR(JD)
      YR_NOW=DATE_NOW(/YEAR) ; GET THE CURRENT YEAR
      IF DATE_NOW(/JD) LT DATE_2JD(YR_NOW+'1215') THEN OKY = WHERE(YEAR NE YR_NOW,/NULL)
 ;     SD = SENSOR_DATES(VALIDS('SENSORS',DATA[0]))
 ;     IF YEAR[0] EQ STRMID(SD[0],0,4) AND DATE_2JD(SD[0]) GT DATE_2JD(YEAR[0]+'0131') THEN OKY = WHERE(YEAR NE YR_NOW AND YEAR NE YEAR[0] ,COUNT) $
 ;                                                                                     ELSE OKY = WHERE(YEAR NE YR_NOW,COUNT) & IF COUNT EQ 0 THEN STOP
      ;MESSAGE, 'Check the "ANNUAL" removal of the current year'
 
 ;     YEAR = YEAR[OKY] & JD = JD[OKY] & DT = DT[OKY]                                   ; Remove the current year from the list of files to calculate the annual 
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE + UL + MIN(YEAR) + UL + MAX(YEAR)
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END ; 'ANNUAL' 
    
    ; ===> INPUT='MONTH_YYYYMM_YYYYMM'; OUTPUT='MANNUAL_YYYY_YYYY'
    'MANNUAL' : BEGIN ; Mean of the MONTH in the climatological year range 
      MANFP = PARSE_IT(DATA) ; For MANNUAL, need the end year of each file
      YEAR = JD_2YEAR(JD)
      DT = REPLICATE(1,N_ELEMENTS(JD))
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE + UL + MIN(MANFP.YEAR_START) + UL + MAX(MANFP.YEAR_END)
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END

    ; ===> INPUT='Y_YYYY'; OUTPUT='YEAR_YYYY_YYYY'
    'YEAR' : BEGIN ; Mean of the Y in the climatological year range
      DT = REPLICATE(1,N_ELEMENTS(JD))
      Y1 = JD_2YEAR(JD)
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE + UL + MIN(Y1) + UL + MAX(Y1)
      JD_SETS= JD_2JD(JULDAY(1,1,FUTURE_YEAR),/YEAR,/MID)
    END
    
    ; ===> INPUT='Y_YYYY'; OUTPUT='YY_YYYY_YYYY'
    'YY': BEGIN ; Mean of the Y in the specified year range
      MIN_DATE = JD_2DATE(JD_2JD(ROUND(MIN(JD)),/MONTH,/START))
      MAX_DATE = JD_2DATE(JD_2JD(ROUND(MAX(JD)),/MONTH,/START))
      MIN_YYYY = LONG(STRMID(MIN_DATE,0,4))
      MAX_YYYY = LONG(STRMID(MAX_DATE,0,4))
      MIN_MM   = LONG(STRMID(MIN_DATE,4,2))
      YEAR= LONG(STRING(JD, FORMAT='(C(CYI4.4))'))
      MONTH=LONG(STRING(JD, FORMAT='(C(CMOI2.2))'))
      DMONTHS = _WIDTH*((LONG(MONTH)+((LONG(YEAR)-LONG(MIN_YYYY))*12)-MIN_MM)/_WIDTH)
      MM=MIN_MM+DMONTHS
      DT = STRMID(JD_2DATE(JULDAY(MM,1,MIN_YYYY)),0,6)
      SETS=WHERE_SETS(DT)
      NAME=PERIOD_CODE+UL+NUM2STR(MIN_YYYY)+UL+NUM2STR(MAX_YYYY)
      ARR=CREATE_STRUCT(NAME[0],  _DATA(SETS.SUBS))
    END
  ENDCASE ; CASE PERIOD_CODE OF
; ############################################################################################################
 

  ; ===> Check to make sure the sets are correct
  OK = WHERE(SETS.SUBS NE MISSINGS(SETS.SUBS),/NULL,COUNT_SETS)
  
  IF COUNT_SETS GE 1 THEN BEGIN ; ==> Structure will have a separate tag for each set
    SETS = SETS[OK]
    NAME = NAME[OK]
    N_SETS = N_ELEMENTS(SETS)
    IF KEYWORD_SET(NESTED) THEN BEGIN ; Structure will be nested tags
      IF USE_DATA THEN BEGIN
        ARR=CREATE_STRUCT(NAME[0],  _DATA[STRSPLIT(SETS[0].SUBS,';',/EXTRACT)])
        FOR NTH = 1L,N_SETS-1L DO ARR=CREATE_STRUCT(TEMPORARY(ARR),NAME[NTH], _DATA[STRSPLIT(SETS[NTH].SUBS,';',/EXTRACT)])
      ENDIF ELSE BEGIN
        ARR=CREATE_STRUCT(NAME[0],  LONG(STRSPLIT(SETS[0].SUBS,';',/EXTRACT)))
        FOR NTH = 1L,N_SETS-1L DO ARR=CREATE_STRUCT(TEMPORARY(ARR),NAME[NTH], LONG(STRSPLIT(SETS[NTH].SUBS,';',/EXTRACT)))
      ENDELSE ; IF USE_DATA THEN BEGIN
    ENDIF ELSE BEGIN ; NOT NESTED

      IF USE_DATA THEN BEGIN ; STRUCTURE WILL BE MATRIX (SPREADSHEET TYPE OUTPUT STRUCTURE
        ARR = REPLICATE(CREATE_STRUCT('PERIOD','','JD',0D,'N',0L,'DATA',''),N_SETS)
        STRUCT_ASSIGN,SETS,ARR
        DATA_TXT = STRTRIM(STRING(_DATA),2)+DELIM
        FOR NTH=0L,N_SETS-1L DO ARR[NTH].DATA = STRJOIN(DATA_TXT( STRSPLIT(SETS[NTH].SUBS,';',/EXTRACT)))
      ENDIF ELSE BEGIN
        ARR = REPLICATE(CREATE_STRUCT('PERIOD','','JD',0D,'N',0L,'SUBS',''),N_SETS)
        STRUCT_ASSIGN,SETS,ARR
      ENDELSE
      ARR.PERIOD = NAME
      ARR.JD = JD_SETS
    ENDELSE ;IF NOT KEYWORD_SET(MATRIX) THEN BEGIN

    RETURN, ARR ;   ===> RETURN THE ARRAY

  ENDIF ELSE BEGIN
    PRINT,'ERROR: PERIOD_CODE was not found'
    RETURN, []
  ENDELSE  ; IF N_SETS GE 1 THEN BEGIN

  DONE:

END; #####################  END OF ROUTINE ################################

