; $Id:	JD_2MONTH.pro,	March 03 2006, 15:02	$


FUNCTION JD_2MONTH, JD
;+
; NAME:
;       JD_2MONTH
;
; PURPOSE:
;       Compute the Month from a Julian Day
;
;
; CALLING SEQUENCE:
;       Result = JD_2MONTH(JD)
;
; INPUTS:
;       Julian Day
;
; OUTPUTS:
;       Month
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 29, 2003
;-

	ROUTINE_NAME='JD_2MONTH'

	RETURN,STRING(JD,FORMAT='(C(CMOi02))')


  END; #####################  End of Routine ################################
