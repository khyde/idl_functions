; $ID:	WEEK_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION WEEK_RANGE, START_WEEK, END_WEEK, STRING=STRING

;+
; NAME:
;   WEEK_RANGE
;
; PURPOSE:
;   This function will create an array of week numbers
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = WEEK_RANGE($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   START_WEEK..... The first week in the range
;   WEND_WEEK...... The last week in the range
;
; KEYWORD PARAMETERS:
;   STRING.......... Set to return the numbered array as a "string"
;
; OUTPUTS:
;   This function returns a list of weeks (01,02,...52)
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
;   R = WEEK_RANGE()
;   R = WEEK_RANGE(1,6)
;   R = WEEK_RANGE(/STRING)
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
;   This program was written on October 18, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 18, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'WEEK_RANGE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  WEEKS = ADD_STR_ZERO(INDGEN(52)+1)
  IF ~N_ELEMENTS(START_WEEK) AND ~N_ELEMENTS(END_WEEK) AND  KEYWORD_SET(STRING) THEN RETURN, WEEKS
  IF ~N_ELEMENTS(START_WEEK) AND ~N_ELEMENTS(END_WEEK) AND ~KEYWORD_SET(STRING) THEN RETURN, FIX(WEEKS)

  IF START_WEEK LE 0 OR START_WEEK GT 52 THEN START_WEEK = 1
  IF N_ELEMENTS(END_WEEK) EQ 1 THEN IF END_WEEK GT 52 THEN END_WEEK = 52
  IF N_ELEMENTS(END_WEEK) EQ 0 THEN END_WEEK = START_WEEK

  WEEKS = START_WEEK
  WHILE (MAX(WEEKS) LT END_WEEK) DO WEEKS = [WEEKS,MAX(WEEKS)+1]

  IF KEYWORD_SET(STRING) THEN WEEKS=STR_PAD(NUM2STR(WEEKS),2)

  RETURN, WEEKS



END ; ***************** End of WEEK_RANGE *****************
