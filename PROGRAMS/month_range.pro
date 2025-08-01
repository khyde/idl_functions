; $ID:	MONTH_RANGE.PRO,	2014-03-21 14	$

	FUNCTION MONTH_RANGE, START_MONTH, END_MONTH, STRING=string, ERROR = error

;+
; NAME:
;		MONTH_RANGE
;
; PURPOSE:
;		This procedure will create a list of months
;
; CATEGORY:
;		Dates
;
; CALLING SEQUENCE:
;
; INPUTS:
;		START_MONTH - Beginning Month (01)
;		END_MONTH   - End Month (12)
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;   STRING     - Set to return the number list in STRING format
;
; OUTPUTS:
;		This function returns a list of montns (01,02,...12)
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;	PROCEDURE:
;
; EXAMPLE:
;   R = MONTH_RANGE()
;   R = MONTH_RANGE(1,6)
;   R = MONTH_RANGE(/STRING)
;
;	NOTES:
;
; MODIFICATION HISTORY:
;			Written March 21, 2014 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MONTH_RANGE'

  MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']
  IF N_ELEMENTS(START_MONTH) EQ 0 AND N_ELEMENTS(END_MONTH) EQ 0 AND     KEYWORD_SET(STRING) THEN RETURN, MONTHS
  IF N_ELEMENTS(START_MONTH) EQ 0 AND N_ELEMENTS(END_MONTH) EQ 0 AND NOT KEYWORD_SET(STRING) THEN RETURN, FIX(MONTHS)
  
  IF START_MONTH LE 0 OR START_MONTH GT 12 THEN START_MONTH = 1
  IF N_ELEMENTS(END_MONTH) EQ 1 THEN IF END_MONTH GT 12 THEN MONTH_END = 12
  IF N_ELEMENTS(END_MONTH) EQ 0 THEN END_MONTH = START_MONTH
  
  MONTHS = START_MONTH
  WHILE (MAX(MONTHS) LT END_MONTH) DO MONTHS = [MONTHS,MAX(MONTHS)+1]
  
  IF KEYWORD_SET(STRING) THEN MONTHS=STR_PAD(NUM2STR(MONTHS),2)
  
  RETURN, MONTHS 



END; #####################  End of Routine ################################
                                                               