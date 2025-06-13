; $ID:	JD_DAYS_WEEK.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION JD_DAYS_WEEK, JD
;+
; NAME:
;       JD_DAYS_WEEK
;
; PURPOSE:
;       Compute the number of days for the WEEK of the Julian Day, where it is 7 days except
;				for the last week of the year when it is 8 days (or 9 days during leap years).
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = JD_DAYS_WEEK(JD)
;
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       The number of days per WEEK of the JD
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 17, 2006

;-
	ROUTINE_NAME= 'JD_DAYS_WEEK'

;	===> Week 1 to 52
  WEEK = 1 > FIX((((JD_2DOY(JD)-1)/7D) +1)) < 52 ;;;
  DPW = 7 + (WEEK EQ 52) + (WEEK EQ 52 AND JD_DAYS_YEAR(JD)	 EQ 366)

  IF N_ELEMENTS(DPW) EQ 1 THEN DPW = DPW[0]
  RETURN,DPW

  END; #####################  End of Routine ################################
