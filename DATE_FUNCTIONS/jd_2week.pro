; $ID:	JD_2WEEK.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION JD_2WEEK ,JD, DEC=DEC
;+
; NAME:
;       JD_2WEEK
;
; PURPOSE:
;				Convert Julian Day into WEEK (1 TO 52) or Decimal Week (1.00-52.9999) if keyword DEC is provided
;
;
; CATEGORY:
;		Date
;
;
; CALLING SEQUENCE:
;       Result = JD_2WEEK(2451908.5)
;
; INPUTS:
;       JD:  JULIAN DATE
;
; KEYWORD PARAMETERS:
;			DEC   OUTPUT DECIMAL WEEKS
;
;
; OUTPUTS:
;			WEEK  1-52)
;
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 20, 2006

;-

; ======================>
	ROUTINE_NAME = 'JD_2WEEK'

;	===> Compute the Decimal Week
	DEC_WEEK = (((JD_2DOY(JD)-1)/7D) +1)

;	===> Week 1 to 52
  WEEK = 1 > FIX(DEC_WEEK) < 52 ;

	IF NOT KEYWORD_SET(DEC) THEN BEGIN
		WEEK = STRING(WEEK,FORMAT='(I02)')
	ENDIF ELSE BEGIN
;		===> Adjust the decimal fractions for the last week
  	WEEK = WEEK + (7D/JD_DAYS_WEEK(JD))* (DEC_WEEK MOD WEEK)
	ENDELSE

	IF N_ELEMENTS(WEEK) EQ 1 THEN RETURN, WEEK[0] ELSE RETURN, WEEK

 END; #####################  End of Routine ################################
