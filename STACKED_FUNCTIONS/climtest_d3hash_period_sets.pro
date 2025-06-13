; $ID:	D3HASH_PERIOD_SETS.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION CLIMTEST_D3HASH_PERIOD_SETS, FILES, OUTPERIOD=OUTPERIOD, BY_YEAR=BY_YEAR

;+
; NAME:
;   D3HASH_PERIOD_SETS
;
; PURPOSE:
;   Determine the output periods for a set of files
;
; CATEGORY:
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:
;   PERIOD_SET = D3HASH_PERIOD_SETS(FILES, OUTPERIOD=OUTPERIOD)
;   
; REQUIRED INPUTS:
;   PERIODS......... The array of input periods
;
; OPTIONAL INPUTS:
;   OUTPERIOD....... The output period.  if not provided, then assume the files will be grouped by the input period.
;
; KEYWORD PARAMETERS:
;   BY_YEAR......... Use this keyword to overwrite the default "BY_YEAR" variable from the PERIODS_MAIN.csv file
;
; OUTPUTS:
;   The "period sets" for the output periods
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 21, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 21, 2021 - KJWH: Initial code written
;   Oct 13, 2022 - KJWH: Added DOY specific steps
;   Oct 31, 2022 - KJWH: Fixed an error with the subscripts and filenames for the DOY files
;   Nov 02, 2022 - KJWH: Now using the SENSOR_DATERANGE to set the min and max years for the DOY stacked period
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'D3HASH_PERIOD_SETS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(FILES) THEN MESSAGE, 'ERROR: Must input at least one file.'                                              ; Check for input files
  FP = PARSE_IT(FILES,/ALL)                                                                                               ; Parse the file names
  FP = FP[SORT(DATE_2JD(PERIOD_2DATE(FP.PERIOD)))]                                                                        ; Sort based on period
  
; ===> Set up the input period information  
  PSTR = PERIOD_2STRUCT(FP.PERIOD)                                                                                        ; Get the period/date information
  IF ~SAME(PSTR.PERIOD_CODE) THEN MESSAGE, 'ERROR: All input period codes must be the same'                               ; Check to make sure all of the input period codes are the same
  PERCODE = PSTR[0].PERIOD_CODE                                                                                           ; Get the input period code
  CSTR = PERIODS_READ(PERCODE)                                                                                            ; Get information about the input period code
  IF CSTR EQ [] THEN MESSAGE, 'ERROR: ' + PERCODE + ' is not a valid period code.'                                        ; Make sure the period code is valid

; ===> Get the date information for the input periods
  DATE_RANGE = STRMID([PSTR[0].DATE_START,PSTR[-1].DATE_END],0,8)                                                         ; Get the date_range for all the files based on the first and last period code
  JD_START = DATE_2JD(DATE_RANGE[0]) & JD_END = DATE_2JD(DATE_RANGE[1])                                                   ; Get the julian dates for the first and last dates
  IF ~SAME(FP.SENSOR) THEN MESSAGE, 'ERROR: All input files must be from the same sensor'                                 ; Check to make sure all files have the same "sensor"
  SENSOR_DATERANGE = SENSOR_DATES(FP[0].SENSOR)                                                                           ; Get the full date range of the sensor
 ; IF STRMID(SENSOR_DATERANGE[1],0,8) EQ DATE_NOW(/GMT,/DATE_ONLY) THEN SENSOR_DATERANGE[1] = DATE_NOW(/YEAR) + '1231'     ; Adjust the end date to the end of the year for active sensors 

; ===> Look for the output period
  IF N_ELEMENTS(OUTPERIOD) NE 1 THEN OUTPER = CSTR.STACKED_PERIOD_OUTPUT ELSE OUTPER = OUTPERIOD                          ; Use the default output period if not provided
  OSTR = PERIODS_READ(OUTPER)                                                                                             ; Get information about the output period code
  IF OSTR EQ [] THEN MESSAGE, 'ERROR: ' + OUTPER + ' is not a valid period code.'                                         ; Check to make sure it is a valid period code
  IF CSTR.STACKED_PERIOD_INPUT NE '' THEN INPUTCODE = CSTR.STACKED_PERIOD_INPUT ELSE INPUTCODE = PERCODE                  ; Get the exact input period code
  IF INPUTCODE NE OSTR.STAT_INPUT_PERIOD THEN MESSAGE, 'ERROR: ' + INPUTCODE + ' is not the correct input period code for ' + OUTPER +'. Input period code should be ' + OSTR.STAT_INPUT_PERIOD + '.'
  
; ===> Get period specific information for the period  
  CLIMATOLOGY = OSTR.CLIMATOLOGY                                                                                          ; Determine if the period code is a "climaotlogy" period
  IF BY_YEAR EQ [] THEN BY_YEAR = OSTR.D3_BYYEAR                                                                          ; Determine if the period code should be subset by year
  RANGE_PERIOD = CSTR.RANGE_PERIOD                                                                                        ; Get the range of the period
  RANGE_OVER_YEAR = OSTR.RANGE_OVER_YEARS                                                                                  ; Determine if the period code extends into the next year (e.g. D3, M3) 
  
; ===> Set up output structure by year  
  IF KEYWORD_SET(BY_YEAR) THEN BEGIN
    SETS = []
    YEAR = WHERE_SETS(PSTR.YEAR_START)                                                                                    ; Determine the number of years represented by the input periods
    
    FOR Y=0, N_ELEMENTS(YEAR)-1 DO BEGIN                                                                                  ; Loop on years
      YSTR = PSTR[WHERE_SETS_SUBS(YEAR[Y])]                                                                               ; Get the period information for the specified year
      FILE = FP[WHERE(FP.PERIOD EQ YSTR.PERIOD,/NULL)].FULLNAME                                                           ; Find the input file that has the same period
      IF KEYWORD_SET(RANGE_OVER_YEAR) THEN $                                                                              ; For period codes than span more than one year (e.g. D3), get the next file for the next year as well (if available)
        FILE = [FILE, FP[WHERE(FP.PERIOD EQ REPLACE(YSTR.PERIOD,YSTR.YEAR_START,NUM2STR(YSTR.YEAR_START+1)),/NULL)].FULLNAME]
      IF OUTPER EQ 'DD' THEN FILE = FP[WHERE_MATCH(FP.PERIOD,YSTR.PERIOD)].FULLNAME
      IF FILE EQ [] THEN MESSAGE, 'ERROR: Not able to match the file name to the period.'                                 ; Check that the file was found
      
      YR = YEAR[Y].VALUE                                                                                                  ; Year value
      DATE_START = YR + '0101000000'                                                                                      ; Assume the start date is the first day of the year
      CASE OUTPER OF                                                                                                      ; Determine the end date
        'D3': DATE_END = NUM2STR(YR+1) + '0102235959'                                                                     ; If D3, then extend the end date 2 days into the next year
        'D8': DATE_END = NUM2STR(YR+1) + '0107235959'                                                                     ; If D8, then extend the end date 7 days into the next year
        'M3': DATE_END = NUM2STR(YR+1) + '02' + DAYS_MONTH('02',YEAR=YR+1,/STRING)                                        ; If M3, then extend the date to the end of February
        'SEA': DATE_END = NUM2STR(YR+1) + '02' + DAYS_MONTH('02',YEAR=YR+1,/STRING)                                       ; If SEA, then extend the date to the end of February
        ELSE: DATE_END = YR + '1231235959'                                                                                ; Assume the end date is the last day of the year
      ENDCASE

      ; ===> Get the input dates for PERIOD_SETS
      IF KEYWORD_SET(RANGE_PERIOD) THEN BEGIN
        DATES = CREATE_DATE(DATE_START,DATE_END)                                                                          ; Get the DATES based on the start and end dates 
        OK_START = WHERE(PSTR.DATE_START LE DATE_START AND PSTR.DATE_END GE DATE_START,/NULL)                             ; Find files that include the start date
        OK_END   = WHERE(PSTR.DATE_START LE DATE_END   AND PSTR.DATE_END GE DATE_END,/NULL)                               ; Find files that include the end date
        OK_ALL = WHERE(PSTR.DATE_START GE DATE_START AND PSTR.DATE_END LE DATE_END,/NULL)                                     ; Find the input periods between the start and end dates        
        SUBS = [OK_START,OK_ALL,OK_END] & SUBS = SUBS[UNIQ(SUBS, SORT(SUBS))]                                                    ; Sort the subscripts
      ENDIF ELSE BEGIN
        OK = WHERE(PSTR.DATE_START GE DATE_START AND PSTR.DATE_END LE DATE_END,/NULL)                                     ; Find the input periods between the start and end dates
        IF OK EQ [] THEN MESSAGE, 'ERROR: Files not found within the daterange'                                           ; Check to make sure periods were found
        YR_PERIODS = FP[OK].PERIOD                                                                                        ; Get the periods for the "year"
        DATES = PERIOD_2DATE(YR_PERIODS)                                                                                  ; Get the DATES based on the file periods
        SUBS = WHERE_MATCH(FP.PERIOD,YR_PERIODS,COUNT)                                                                    ; Subscripts of the periods
      ENDELSE
      
      SET = PERIOD_SETS(DATE_2JD(DATES),PERIOD_CODE=OUTPER)                                                               ; Group the output periods based on the input periods and output period code
      PERS = STR_BREAK(SET.PERIOD,'_')                                                                                    ; Break up the output periods
      CASE N_ELEMENTS(PERS[0,*]) OF                                                                                       ; Create the "stacked" period code
        '2': STACKED_PERIOD = STRJOIN([OSTR.STACKED_PERIOD_OUTPUT,PERS[0,1],PERS[-1,1]],'_')                              ; If period only uses one date then use first and last date
        '3': STACKED_PERIOD = STRJOIN([OSTR.STACKED_PERIOD_OUTPUT,PERS[0,1],PERS[-1,2]],'_')                              ; If the period has two dates, use the first date and the last value of the second date
        'ELSE': STOP ; Need to determine the correct output period code
      ENDCASE
      
      IF OUTPER EQ 'DD' THEN STACKED_PERIOD = STRJOIN([OSTR.STACKED_PERIOD_OUTPUT,STRMID(DATE_START,0,STRLEN(PERS[1])),STRMID(DATE_END,0,STRLEN(PERS[2]))],'_') ; Make sure the DD output period covers the entire year range
      
      ; ===> Create the output structure
      YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD',STACKED_PERIOD, 'FILENAME',FILE[0]),N_ELEMENTS(SET))
      SET = STRUCT_MERGE(YRPER,SET)                                                                                       ; Merge the new structure with the output from PERIOD_SETS
            
      IF KEYWORD_SET(RANGE_OVER_YEAR) THEN BEGIN
        OUTPERSTR = PERIOD_2STRUCT(SET.PERIOD)
        OK = WHERE(OUTPERSTR.YEAR_START NE OUTPERSTR.YEAR_END,COUNT, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
        IF NCOMP GT 0 THEN BEGIN
          SET[COMP].SUBS = NUM2STR(OK_START)
        ENDIF
        IF COUNT GT 0 THEN BEGIN
          SET[OK].SUBS = STRJOIN(NUM2STR(SUBS),';')
          SET[OK].FILENAME = STRJOIN(FILE,';')
          SET[OK].N = 2
        ENDIF
      ENDIF ELSE BEGIN
        SET.SUBS = STRJOIN(NUM2STR(SUBS),';')
        SET.FILENAME = STRJOIN(FILE,';')
      ENDELSE
      SETS = [SETS,SET]
    ENDFOR
    RETURN, SETS
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(CLIMATOLOGY) THEN BEGIN
      CASE OSTR.PERIOD_CODE OF
        'ANNUAL': BEGIN
          IF N_ELEMENTS(FILES) NE 1 THEN MESSAGE, 'ERROR: Only one input file allowed for "ANNUAL" output files'
          STACKED_PERIOD = REPLACE(PSTR.PERIOD,PSTR.PERIOD_CODE,OSTR.PERIOD_CODE)
          SETS = CREATE_STRUCT('PERIOD',STACKED_PERIOD,'JD',0.0,'N',1,'SUBS','0','STACKED_PERIOD',STACKED_PERIOD,'FILENAME',FILES)
        END  
        'MONTH': BEGIN
          IF CSTR.PERIOD_CODE EQ 'MM' THEN BEGIN
            MTHRNG = YEAR_MONTH_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],/PERIOD)
            SET = PERIOD_SETS(PERIOD_2JD(MTHRNG),PERIOD_CODE=OUTPER)
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = SET.PERIOD
            SETS = STRUCT_MERGE(YRPER,SET)
            ;FPMTH = DATE_2MONTH(PERIOD_2DATE(FP.PERIOD))
            ;SETMTH = DATE_2MONTH(PERIOD_2DATE(SETS.PERIOD))
            FPSTR = PERIOD_2STRUCT(FP.PERIOD)
            SETSTR = PERIOD_2STRUCT(SETS.PERIOD)
            FOR D=0, N_ELEMENTS(SETS)-1 DO BEGIN
              ;OK = WHERE(FPMTH EQ SETMTH[D],COUNT)                                                                                        ; Find where the input file period DOY matches the output period DOY
              OK = WHERE(FPSTR.YEAR_START GE SETSTR[D].YEAR_START AND FPSTR.YEAR_END LE SETSTR[D].YEAR_END,COUNT)

              IF COUNT GT 0 THEN BEGIN
                SETS[D].N = COUNT
                SETS[D].SUBS = STRJOIN(NUM2STR(OK),';')                                                                                  ; Add the subscripts of the matching files
                SETS[D].FILENAME = STRJOIN(FP[OK].FULLNAME,';')                                                                          ; Add the matching file name
              ENDIF ELSE SETS[D].SUBS = MISSINGS(SETS.SUBS)
            ENDFOR
          ENDIF ELSE BEGIN
            STOP ; NEED TO UPDATE TO WORK WITH NEW MONTH INPUT FILES
            IF N_ELEMENTS(FILES) NE 1 THEN MESSAGE, 'ERROR: Only a single merged MM input file allowed for "MONTH" output files'
            SET = PERIOD_SETS(JD_GEN(SENSOR_DATERANGE),PERIOD_CODE='M')  ; Create the weekly periods as an input to the WEEK period
            SET = PERIOD_SETS(PERIOD_2JD(SET.PERIOD), PERIOD_CODE='MONTH') ; 
            STACKED_PERIOD = 'MONTH' + '_00_' + MIN(PSTR.YEAR_START) + '_' + MAX(PSTR.YEAR_END)
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = STACKED_PERIOD
            YRPER.FILENAME = FILES
            SETS = STRUCT_MERGE(YRPER,SET) 
          ENDELSE   
        END  
        'WEEK': BEGIN
          IF CSTR.PERIOD_CODE EQ 'WW' THEN BEGIN
            SET = PERIOD_SETS(PERIOD_2JD(YEAR_WEEK_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],/PERIOD)),PERIOD_CODE=OUTPER)
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = SET.PERIOD
            SETS = STRUCT_MERGE(YRPER,SET)
            ;FPWKS = DATE_2WEEK(PERIOD_2DATE(FP.PERIOD))
            ;SETWKS = DATE_2WEEK(PERIOD_2DATE(SETS.PERIOD))
            FPSTR = PERIOD_2STRUCT(FP.PERIOD)
            SETSTR = PERIOD_2STRUCT(SETS.PERIOD)
            FOR D=0, N_ELEMENTS(SETS)-1 DO BEGIN
              ;OK = WHERE(FPWKS EQ SETWKS[D],COUNT)                                                                                        ; Find where the input file period DOY matches the output period DOY
              OK = WHERE(FPSTR.YEAR_START GE SETSTR[D].YEAR_START AND FPSTR.YEAR_END LE SETSTR[D].YEAR_END,COUNT)
              IF COUNT GT 0 THEN BEGIN
                SETS[D].N = COUNT
                SETS[D].SUBS = STRJOIN(NUM2STR(OK),';')                                                                                  ; Add the subscripts of the matching files
                SETS[D].FILENAME = STRJOIN(FP[OK].FULLNAME,';')                                                                          ; Add the matching file name
              ENDIF ELSE SETS[D].SUBS = MISSINGS(SETS.SUBS)
            ENDFOR
          ENDIF ELSE BEGIN
            STOP ; NEED TO UPDATE TO WORK WITH NEW WEEK INPUT FILES
            IF N_ELEMENTS(FILES) NE 1 THEN MESSAGE, 'ERROR: Only a single merged WW input file allowed for "WEEK" output files'
            SET = PERIOD_SETS(JD_GEN(SENSOR_DATERANGE),PERIOD_CODE='W')  ; Create the weekly periods as an input to the WEEK period
            SET = PERIOD_SETS(PERIOD_2JD(SET.PERIOD), PERIOD_CODE='WEEK') ; 
            STACKED_PERIOD = 'WEEK_00_' + MIN(PSTR.YEAR_START) + '_' + MAX(PSTR.YEAR_END)
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = STACKED_PERIOD
            YRPER.FILENAME = FILES
            SETS = STRUCT_MERGE(YRPER,SET)   
          ENDELSE         
        END  
        'DOY': BEGIN
          IF CSTR.PERIOD_CODE EQ 'D' OR CSTR.PERIOD_CODE EQ 'DD' THEN BEGIN
            SET = PERIOD_SETS(PERIOD_2JD(CREATE_DATE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],/PERIOD)),PERIOD_CODE=OUTPER)
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = SET.PERIOD
            SETS = STRUCT_MERGE(YRPER,SET)
            ;FPDOYS = DATE_2DOY(PERIOD_2DATE(FP.PERIOD))
            FPSTR = PERIOD_2STRUCT(FP.PERIOD)
            ;SETDOYS = DATE_2DOY(PERIOD_2DATE(SETS.PERIOD))
            SETSTR = PERIOD_2STRUCT(SETS.PERIOD)
            FOR D=0, N_ELEMENTS(SETS)-1 DO BEGIN
              ;OK = WHERE(FPDOYS EQ SETDOYS[D],COUNT)                                                                                        ; Find where the input file period DOY matches the output period DOY
              OK = WHERE(FPSTR.YEAR_START GE SETSTR[D].YEAR_START AND FPSTR.YEAR_END LE SETSTR[D].YEAR_END,COUNT)
              IF COUNT GT 0 THEN BEGIN
                SETS[D].N = COUNT
                SETS[D].SUBS = STRJOIN(NUM2STR(OK),';')                                                                                  ; Add the subscripts of the matching files
                SETS[D].FILENAME = STRJOIN(FP[OK].FULLNAME,';')                                                                          ; Add the matching file name
              ENDIF ELSE SETS[D].SUBS = MISSINGS(SETS.SUBS)
            ENDFOR
          ENDIF ELSE BEGIN
            SET = PERIOD_SETS(JD_GEN(SENSOR_DATERANGE),PERIOD_CODE='D')  ; Create the daily periods as an input to the DOY period
            SET = PERIOD_SETS(PERIOD_2JD(SET.PERIOD), PERIOD_CODE='DOY') ; 
            STACKED_PERIOD =  'DOY_000_' + MIN(DATE_2YEAR(SENSOR_DATERANGE)) + '_' + MAX(DATE_2YEAR(SENSOR_DATERANGE))
            YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
            YRPER.STACKED_PERIOD = STACKED_PERIOD
            SETS = STRUCT_MERGE(YRPER,SET)
            OK = WHERE_MATCH(FP.PERIOD,SETS.PERIOD,COUNT,VALID=VALID)
            IF COUNT GT 0 THEN BEGIN
              SETS[VALID].FILENAME = FILES[OK]
              SETS = SETS[VALID]
            ENDIF
          ENDELSE
        END
      ENDCASE      
    ENDIF ELSE BEGIN
      DATE_START = MIN(PSTR.DATE_START) & DATE_END = MAX(PSTR.DATE_END)
      CASE CSTR.STAT_INPUT_PERIOD OF
        'D': SPERS = PSTR.PERIOD
        'W': SPERS = YEAR_WEEK_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],/PERIOD)
        'M': SPERS = YEAR_MONTH_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],/PERIOD) ; DATE_START,DATE_END
        'A': SPERS = YEAR_RANGE(SENSOR_DATERANGE[0],SENSOR_DATERANGE[1],PERIOD='A')
      ENDCASE
      
      SET = PERIOD_SETS(PERIOD_2JD(SPERS),PERIOD_CODE=OUTPER)                                                             ; Group the output periods based on the input periods and output period code
      IF OUTPER NE 'DOY' THEN SET.SUBS = STRJOIN(NUM2STR(INDGEN(N_ELEMENTS(FILES))),';')                                  ; Change the subsript so that it refers to the input files
      PERS = STR_BREAK(SET.PERIOD,'_')                                                                                    ; Break up the output periods
      CASE N_ELEMENTS(PERS[0,*]) OF                                                                                       ; Create the "stacked" period code
        '2': STACKED_PERIOD = STRJOIN([OSTR.STACKED_PERIOD_OUTPUT,PERS[0,1],PERS[-1,1]],'_')                              ; If period only uses one date then use first and last date
        '3': STACKED_PERIOD = STRJOIN([OSTR.STACKED_PERIOD_OUTPUT,PERS[0,1],PERS[-1,2]],'_')                              ; If the period has two dates, use the first date and the last value of the second date
        '4': STACKED_PERIOD = SET.PERIOD
        'ELSE': STOP ; Need to determine the correct output period code
      ENDCASE

      ; ===> Create the output structure
      YRPER = REPLICATE(CREATE_STRUCT('STACKED_PERIOD','', 'FILENAME',''),N_ELEMENTS(SET))
      YRPER.STACKED_PERIOD = STACKED_PERIOD
      SETS = STRUCT_MERGE(YRPER,SET)
      CASE OUTPER OF 
        'WW': BEGIN
          OK = WHERE_MATCH((PERIOD_2STRUCT(SETS.PERIOD)).YEAR_START,FP.YEAR_START,COUNT,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP) ; Find where the input file period years match the output period years
          IF NCOMP GT 0 THEN SETS[COMP].SUBS = MISSINGS(SETS.SUBS)                                                                     ; If some periods do not have matching files, make those subscripts missing
          IF COUNT GT 0 THEN BEGIN
            SETS[OK].SUBS = NUM2STR(VALID)                                                                                             ; Add the subscripts of the matching files
            SETS[OK].FILENAME = FILES[VALID]                                                                                           ; Add the matching file name
          ENDIF
        END  
        'MM': BEGIN
          OK = WHERE_MATCH((PERIOD_2STRUCT(SETS.PERIOD)).YEAR_START,FP.YEAR_START,COUNT,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP) ; Find where the input file period years match the output period years
          IF NCOMP GT 0 THEN SETS[COMP].SUBS = MISSINGS(SETS.SUBS)                                                                     ; If some periods do not have matching files, make those subscripts missing
          IF COUNT GT 0 THEN BEGIN
            SETS[OK].SUBS = NUM2STR(VALID)                                                                                             ; Add the subscripts of the matching files
            SETS[OK].FILENAME = FILES[VALID]                                                                                           ; Add the matching file name
          ENDIF
        END
        'A': BEGIN
          OK = WHERE_MATCH((PERIOD_2STRUCT(SETS.PERIOD)).YEAR_START,FP.YEAR_START,COUNT,VALID=VALID,COMPLEMENT=COMP,NCOMPLEMENT=NCOMP) ; Find where the input file period years match the output period years
          IF NCOMP GT 0 THEN SETS[COMP].SUBS = MISSINGS(SETS.SUBS)                                                                     ; If some periods do not have matching files, make those subscripts missing
          IF COUNT GT 0 THEN BEGIN
            SETS[OK].SUBS = NUM2STR(VALID)                                                                                             ; Add the subscripts of the matching files
            SETS[OK].FILENAME = FILES[VALID]                                                                                           ; Add the matching file name
          ENDIF  
        END 
        ELSE: SETS.FILENAME = FILES   
      ENDCASE
    ENDELSE ; CLIMATOLOGY
    RETURN, SETS
  ENDELSE ; BY_YEAR
  


END ; ***************** End of D3HASH_PERIOD_SETS *****************
