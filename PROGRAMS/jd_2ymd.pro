; $ID:	JD_2YMD.PRO,	2004 02 03 17:35	$

FUNCTION  JD_2YMD ,JD
;+
; NAME:
;        JD_2YMD
; INPUTS:
;       Julian Day
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 29,2000
;				April 8, 2003 REPLACES STRING_FORMAT WITH STRING, JOR
;-
; ===================>
  IF N_ELEMENTS(JD) EQ 0 THEN RETURN,-1
  RETURN, STRING(JD,FORMAT='(C(CYi4.4,CMoi2.2,CDi2.2))')
END; #####################  End of Routine ################################

