; $ID:	YEAR_WEEK_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION YEAR_WEEK_RANGE, START_DATE, END_DATE, PERIOD=PERIOD

;+
; NAME:
;   YEAR_WEEK_RANGE
;
; PURPOSE:
;   Function to create a range of YYYYWW dates
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = YEAR_WEEK_RANGE(START_DATE, END_DATE)
;
; REQUIRED INPUTS:
;   START_DATE..... The starting date of the range
;   END_DATE....... The ending date of the range
;   
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   PERIOD......... Return the array as week periods (W_yyyyww)
;
; OUTPUTS:
;   An array of YYYYWW dates
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
;   PRINT, YEAR_WEEK_RANGE(200202,200424,/PERIOD)
;   PRINT, YEAR_WEEK_RANGE(20020101,20041231,/PERIOD)
;
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 18, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 18, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'YEAR_WEEK_RANGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF STRLEN(NUM2STR(START_DATE)) EQ 6 THEN SDATE = YWEEK_2JD(START_DATE,/DATE) ELSE SDATE = START_DATE           ; Convert any YYYYWW dates to the full YYYYMMDDHHMMSS date
  IF STRLEN(NUM2STR(END_DATE))   EQ 6 THEN EDATE = YWEEK_2JD(END_DATE,/DATE)   ELSE EDATE = END_DATE             ; Convert any YYYYWW dates to the full YYYYMMDDHHMMSS date
  
  DR = GET_DATERANGE(SDATE,EDATE)                                                                           ; Create a "daterange" from the input dates (this will turn the year to a complete date)
  IF DR EQ [] THEN RETURN, []

  SYEAR = DATE_2YEAR(DR[0]) & EYEAR = DATE_2YEAR(DR[1])                                                     ; Get the starting and ending years
  YEARS = YEAR_RANGE(SYEAR,EYEAR,/STRING)
  WEEKS = WEEK_RANGE(/STRING)
  
  DRWK = DATE_2WEEK(DR)                                                                                         ; Get the week of the date range
  SDR = JD_2DATE(YWEEK_2JD(SYEAR+DRWK[0]))                                                    ; Convert the date to the first day of the week
  EDR = JD_2DATE(JD_ADD(YWEEK_2JD(EYEAR+DRWK[1]),6,/DAY))                        ; Convert the date to the last day of the week
  DR = [SDR,EDR]
  
  YW = []
  FOR Y=0, N_ELEMENTS(YEARS)-1 DO YW = [YW,YEARS[Y]+WEEKS]
  PERS = 'W_' + YW
  
  OK = WHERE(PERIOD_2JD(PERS) GE DATE_2JD(DR[0]) AND PERIOD_2JD(PERS) LE DATE_2JD(DR[1]))                   ; Find the periods between in the start and end dates

  IF KEYWORD_SET(PERIOD) THEN RETURN, PERS[OK]                                                              ; Return the "periods"
  RETURN, YW[OK]                                                                                            ; Return just the year + month (YYYYMM)



END ; ***************** End of YEAR_WEEK_RANGE *****************
