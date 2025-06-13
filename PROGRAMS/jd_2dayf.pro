; $ID:	JD_2DAYF.PRO,	FEBRUARY 20 2005, 07:05	$

FUNCTION JD_2DAYF, JD
;+
; NAME:
;       JD_2DAYF
;
; PURPOSE: Convert input Julian Day into a day fraction (0.0 TO 0.999999)

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 7, 2002
;-
; ===> Get DOY then fraction of Day
	RETURN, JD_2DOY(JD) MOD 1;

  END ; END OF PROGRAM
