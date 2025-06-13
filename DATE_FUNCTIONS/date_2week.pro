; $ID:	DATE_2WEEK.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION DATE_2WEEK,DATE, DEC=dec
;+
; NAME:
;       DATE_2WEEK
;
; PURPOSE:
;				Generate a Decimal Week number (beginning at 1.00)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;       Result = DATE_2WEEK('19770319')
;
; INPUTS:
;  	Program assumes date is a string 8 characters long
; 	Example '19770317'

;
;	KEYWORDS:
;				DEC   OUTPUT DECIMAL WEEKS
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 17,2006
;-

	ROUTINE_NAME = 'DATE_2WEEK'

 	WEEK= JD_2WEEK(DATE_2JD(STRTRIM(DATE,2)),DEC=DEC)  ;
 	IF N_ELEMENTS(WEEK) EQ 1 THEN RETURN, WEEK[0] ELSE RETURN, WEEK

 END; #####################  End of Routine ################################
