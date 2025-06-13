; $ID:	STR_TAB2SPACE.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program Replaces TABS with SPACES
; HISTORY:
;			Jan 11,2004	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STR_TAB2SPACE,TEXT
  ROUTINE_NAME='STR_TAB2SPACE'
  B=BYTE(TEXT)
  OK=WHERE(B EQ 9,COUNT)
  IF COUNT GE 1 THEN BEGIN
  	B[OK] = 32B
  	TXT = STRING(B)
  	RETURN, TXT
  ENDIF ELSE RETURN, TEXT
END; #####################  End of Routine ################################
