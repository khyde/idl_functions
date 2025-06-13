; $ID:	JD_DAYS_YEAR.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION JD_DAYS_YEAR,JD
;+
; NAME:
;       JD_DAYS_YEAR
;
; PURPOSE:
;       Compute the number of days in any year
;
; CATEGORY:
;       Date Time
;
; CALLING SEQUENCE:
;       Result = JD_DAYS_YEAR(JD)
;
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       The number of days per year
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 30, 2004

;-
	ROUTINE_NAME= 'JD_DAYS_YEAR'

  YEAR =   FIX(STRING(JD,FORMAT='(C(CYi4.4))'))

  DPY= JULDAY(12,31,YEAR) - JULDAY(1,1,YEAR) + 1 ;

  IF N_ELEMENTS(DPY) EQ 1 THEN DPY = DPY[0]
  RETURN,DPY

  END; #####################  End of Routine ################################
