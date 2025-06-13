; $ID:	JD_DAYS_MONTH.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION JD_DAYS_MONTH,JD
;+
; NAME:
;       JD_DAYS_MONTH
;
; PURPOSE:
;       Compute the number of days for the month of the Julian Day
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = JD_DAYS_MONTH(JD)
;
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       The number of days per Month of the JD
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 30, 2004

;-
	ROUTINE_NAME= 'JD_DAYS_MONTH'

  DAYS_PER_MONTH = [0, 31,28,31,30,31,30,31,31,30,31,30,31]

	MONTH	= FIX(STRING(JD,FORMAT='(C(CMoi2.2))'))

	DAYS_PER_YEAR  = JD_DAYS_YEAR(JD)

	DPM = DAYS_PER_MONTH(MONTH) + 1*(MONTH EQ 2 AND DAYS_PER_YEAR EQ 366)

  IF N_ELEMENTS(DPM) EQ 1 THEN DPM = DPM[0]
  RETURN,DPM

  END; #####################  End of Routine ################################
