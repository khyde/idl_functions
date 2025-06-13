; $ID:	YEAR_MONTH_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION YEAR_MONTH_RANGE, START_DATE, END_DATE, PERIOD=PERIOD, FULL_DATE=FULL_DATE, SHORT_DATE=SHORT_DATE

;+
; NAME:
;   YEAR_MONTH_RANGE
;
; PURPOSE:
;   Function to create a range of YYYYMM dates
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = YEAR_MONTH_RANGE(START_DATE,END_DATE)
;
; REQUIRED INPUTS:
;   START_DATE..... The starting date of the range
;   END_DATE....... The ending date of the range
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   PERIOD......... Return the array as month periods (M_yyyymm)
;   FULL_DATE...... Return the array as a full date (yyyymmddhhmmss)
;   SHORT_DATE..... Return the array as a short date (yyyymmdd)
;
; OUTPUTS:
;   A array of YYYYMM dates
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
;   PRINT, YEAR_MONTH_RANGE() ; Returns a NULL array
;   PRINT, YEAR_MONTH_RANGE('2000') ; Returns the 12 month array for 2000
;   PRINT, YEAR_MONTH_RANGE('2000','2002') ; Returns the 36 month array between 200001 and 200212
;   PRINT, YEAR_MONTH_RANGE('200003','200205') ; Returns the 27 month array between 200003 and 2000205
;   PRINT, YEAR_MONTH_RANGE('20000305','20020504') ; Returns the 27 month array between 200003 and 200205 - NOTE: this will include the first month even if it doesn't start at day 01
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
;   This program was written on October 07, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 07, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'YEAR_MONTH_RANGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF STRLEN(START_DATE) GT 6 THEN SDATE = STRMID(START_DATE,0,6) ELSE SDATE = START_DATE                    ; Reduce the start date to just the YYYYMM if a full date is provided
  IF STRLEN(END_DATE)   GT 6 THEN EDATE = STRMID(END_DATE,  0,6) ELSE EDATE = END_DATE                      ; Reduce the start date to just the YYYYMM if a full date is provided
  DR = GET_DATERANGE(SDATE,EDATE)                                                                           ; Create a "daterange" from the input dates (this will turn the year to a complete date)
  IF DR EQ [] THEN RETURN, []
  
  SYEAR = DATE_2YEAR(DR[0]) & EYEAR = DATE_2YEAR(DR[1])                                                     ; Get the starting and ending years
  YEARS = YEAR_RANGE(SYEAR,EYEAR,/STRING)                                                                   ; Create an array of years
  MONTHS = MONTH_RANGE(/STRING)                                                                             ; Get an array of all 12 months
  
  YM = []                                                                                                   ; Create a blank array
  FOR Y=0, N_ELEMENTS(YEARS)-1 DO YM = [YM,YEARS[Y]+MONTHS]                                                 ; Loop through each year and create a full array of months per year
  PERS = 'M_' + YM                                                                                          ; Create a "MONTH" period
  
  OK = WHERE(PERIOD_2JD(PERS) GE DATE_2JD(DR[0]) AND PERIOD_2JD(PERS) LE DATE_2JD(DR[1]))                   ; Find the periods between in the start and end dates
  
  IF KEYWORD_SET(PERIOD) THEN RETURN, PERS[OK]                                                              ; Return the "periods"
  IF KEYWORD_SET(FULL_DATE) THEN RETURN, YM[OK]+'01000000'                                                  ; Return a full date (YYYYMMDDHHMMSS)
  IF KEYWORD_SET(SHORT_DATE) THEN RETURN, YM[OK]+'01'                                                       ; Return a short date (YYYYMMDD)
  RETURN, YM[OK]                                                                                            ; Return just the year + month (YYYYMM)


END ; ***************** End of YEAR_MONTH_RANGE *****************
