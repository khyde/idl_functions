; $ID:	STR_SPACE2ZERO.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program Replaces SPACES with ZEROS
;	EXAMPLE:
;   PRINT, STR_SPACE2ZERO(' 1')
;   PRINT, STR_SPACE2ZERO([' 9:45',' 1:55'])

; HISTORY:
;			Jan 11,2004	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STR_SPACE2ZERO,TEXT
  ROUTINE_NAME='STR_SPACE2ZERO'
  B=BYTE(TEXT)
  OK=WHERE(B EQ 32,COUNT)
  IF COUNT GE 1 THEN BEGIN
  	B[OK] = 48B
  	TXT = STRING(B)
  	RETURN, TXT
  ENDIF ELSE RETURN, TEXT
END; #####################  End of Routine ################################
