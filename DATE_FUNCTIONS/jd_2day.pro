; $Id:	jd_2day.pro,	March 03 2006, 15:15	$

FUNCTION JD_2DAY, JD
;+
; NAME:
;       JD_2DAY
;
; PURPOSE:
;       Compute the DAY from a Julian Day
;
;
; CALLING SEQUENCE:
;       Result = JD_2DAY(JD)
;
; INPUTS:
;       Julian Day
;
; OUTPUTS:
;       DAY
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 29, 2003
;-

	ROUTINE_NAME='JD_2DAY'

	RETURN,STRING(JD,FORMAT='(C(CDi02))')


  END; #####################  End of Routine ################################
