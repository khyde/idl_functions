; $ID:	DOY_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DOY_RANGE, START_DATE, END_DATE, LEAP=LEAP, STRING=STRING

;+
; NAME:
;   DOY_RANGE
;
; PURPOSE:
;   This function will create an array of day-of-year numbers
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DOY_RANGE()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   START_DATE........ The start date in the range (either a full date or day-of-year)
;   END_DATE.......... The end date in the range (either a full date or day-of-year)
;
; KEYWORD PARAMETERS:
;   LEAP.............. Will return 366 days per year 
;   STRING............ Set to return the numbered array as a "string"
;
; OUTPUTS:
;   Returns a list of days of the year (001, 002,....365)
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   If specific dates are used for inputs, the output will return 366 days for leap years
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
;   R = DOY_RANGE()
;   R = DOY_RANGE(3,15)
;   R = DOY_RANGE(LEAP)
;   R = DOY_RANGE(/STRING)
;   R = DOY_RANGE(2002)
;   R = DOY_RANGE(2004) ; Note, the output includes the 366th day
;   R = DOY_RANGE(2002,2003)
;   R = DOY_RANGE(2002,2008)
;   R = DOY_RANGE(20021215,20030615)
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 01, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 01, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DOY_RANGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF KEYWORD_SET(LEAP) THEN LDOY = 366 ELSE LDOY = 365
  DOYS = INDGEN(LDOY)+1 
  
  IF ~N_ELEMENTS(START_DATE) AND ~N_ELEMENTS(END_DATE) AND KEYWORD_SET(STRING) THEN RETURN, ADD_STR_ZERO(DOYS)
  IF ~N_ELEMENTS(START_DATE) AND ~N_ELEMENTS(END_DATE) THEN RETURN, DOYS
  
  SD = [] & ED = []
  IF STRLEN(NUM2STR(START_DATE)) GT 3 THEN BEGIN
    DR = GET_DATERANGE(START_DATE)
    SD = DR[0]
    IF N_ELEMENTS(END_DATE) THEN BEGIN
      DR = GET_DATERANGE(START_DATE,END_DATE)
      ED = DR[1]
    ENDIF ELSE ED = DR[1]
    OUTDOYS = DATE_2DOY(CREATE_DATE(SD,ED))  ; Note this will add the 366th day for leap years
    IF KEYWORD_SET(STRING) THEN OUTDOYS = ADD_STR_ZERO(OUTDOYS,DIGITS=3)
    RETURN, OUTDOYS
  ENDIF ELSE SDOY = START_DATE
  
  IF ~N_ELEMENTS(END_DATE) THEN EDOY = LDOY ELSE EDOY = END_DATE
  DIF = EDOY - SDOY
  
  OUTDOYS = INDGEN(DIF+1)+SDOY
  IF KEYWORD_SET(STRING) THEN OUTDOYS = ADD_STR_ZERO(OUTDOYS,DIGITS=3)
  RETURN, OUTDOYS
  


END ; ***************** End of DOY_RANGE *****************
