; $ID:	MONTH_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$

	FUNCTION MONTH_RANGE, START_MONTH, END_MONTH, STRING=string

;+
; NAME:
;		MONTH_RANGE
;
; PURPOSE:
;		This function will create an array of month numbers
;
; CATEGORY:
;		DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MONTH_RANGE()
;
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUTS:
;		START_MONTH...... The start month in the range
;		END_MONTH........ The end month in the range
;
; KEYWORD PARAMETERS:
;   STRING........... Set to return the numbered array as a "string"
;
; OUTPUTS:
;		This function returns a list of months (01,02,...12)
;
; OPTIONAL OUTPUTS:
;		None
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
;   R = MONTH_RANGE()
;   R = MONTH_RANGE(1,6)
;   R = MONTH_RANGE(/STRING)
;
;	NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 21, 2014 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;		Mar 21, 2014 - KJWH: Initial code written
;		Oct 18, 2022 - KJWH: Updated documentation and formatting
;		                     Moved to DATE_FUNCTIONS
;		                     Added COMPILE_OPT ID2
;		                     Changed all subscripts from () to []	
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MONTH_RANGE'
	COMPILE_OPT IDL2

  MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']
  IF N_ELEMENTS(START_MONTH) EQ 0 AND N_ELEMENTS(END_MONTH) EQ 0 AND     KEYWORD_SET(STRING) THEN RETURN, MONTHS
  IF N_ELEMENTS(START_MONTH) EQ 0 AND N_ELEMENTS(END_MONTH) EQ 0 AND NOT KEYWORD_SET(STRING) THEN RETURN, FIX(MONTHS)
  
  IF START_MONTH LE 0 OR START_MONTH GT 12 THEN START_MONTH = 1
  IF N_ELEMENTS(END_MONTH) EQ 1 THEN IF END_MONTH GT 12 THEN MONTH_END = 12
  IF N_ELEMENTS(END_MONTH) EQ 0 THEN END_MONTH = START_MONTH

  IF WHERE(FLOAT([START_MONTH,END_MONTH]) GT 12,/NULL) NE [] THEN MESSAGE, 'ERROR: Input values must be 12 or less'  
  MONTHS = START_MONTH
  WHILE (MAX(MONTHS) LT END_MONTH) DO MONTHS = [MONTHS,MAX(MONTHS)+1]
  
  IF KEYWORD_SET(STRING) THEN MONTHS=STR_PAD(NUM2STR(MONTHS),2)
  
  RETURN, MONTHS 



END; #####################  End of Routine ################################

