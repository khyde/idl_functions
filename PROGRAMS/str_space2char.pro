; $ID:	STR_SPACE2CHAR.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program Replaces SPACES with Character
;	EXAMPLE:
;   PRINT, STR_SPACE2CHAR(' 1')
;   PRINT, STR_SPACE2CHAR([' 9:45',' 1:55'])

; HISTORY:
;			Jan 18,2005	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STR_SPACE2CHAR,TEXT,CHAR
	IF N_ELEMENTS(CHAR) NE 1 THEN _CHAR = BYTE(STRTRIM(0,2)) ELSE _CHAR = BYTE(STRTRIM(CHAR,2))
  ROUTINE_NAME='STR_SPACE2CHAR'
  B=BYTE(TEXT)
  OK=WHERE(B EQ 32,COUNT)
  IF COUNT GE 1 THEN BEGIN
  	B[OK] = _CHAR
  	TXT = STRING(B)
  	RETURN, TXT
  ENDIF ELSE RETURN, TEXT
END; #####################  End of Routine ################################
