; $ID:	DATE_2DAYF.PRO,	FEBRUARY 20 2005, 07:05	$

FUNCTION DATE_2DAYF, DATE
;+
; NAME:
;       DATE_2DAYF
;
; PURPOSE: Convert input DATE-TIME (YYYYMMDDHHMMSS) into a day fraction (0.0 TO 0.999999)

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 7, 2002
;-
; ===> Convert to JD, get DOY then fraction of Day
	RETURN, JD_2DOY(DATE_2JD(DATE)) MOD 1;

  END ; END OF PROGRAM
