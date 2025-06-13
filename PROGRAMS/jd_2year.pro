; $Id:	jd_2year.pro,	September 11 2006, 08:28	$


FUNCTION JD_2YEAR, JD
;+
; NAME:
;       JD_2YEAR
;
; PURPOSE:
;       Compute the Year from a Julian Day
;
;
; CALLING SEQUENCE:
;       Result = JD_2YEAR(JD)
;
; INPUTS:
;       JD
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       Year
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 29, 2003
;-

	ROUTINE_NAME='JD_2YEAR'

	RETURN,STRING(JD,FORMAT='(C(CYi04))')


  END; #####################  End of Routine ################################
