; $Id: SIGN.pro $  VERSION: March 26,2002
;+
;	This Function returns DATE FROM A VALID PERIOD

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;								FROM JHUAPL SIGN.PRO
;-
; *************************************************************************

FUNCTION SIGN, NUM, SYMBOL=symbol
  ROUTINE_NAME='SIGN'
	RETURN, FIX(NUM gt 0.) - FIX(NUM lt 0.)
END; #####################  End of Routine ################################
