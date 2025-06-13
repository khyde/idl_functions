; $ID:	FILE_CHMOD.PRO,	2014-04-29	$

 FUNCTION STR_KEY, STRUCT
;+
; NAME:
; 	STR_KEY

;		This Program Makes a string key from tagnames

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='STR_KEY'

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0L,N_KEYS-1L DO BEGIN
		STR 	= STRTRIM(STRUCT.(POS_TAG(nth)),2)
;		===> Determine maximum length of strings so they may padded with leading zeros
;				 This ensures that the final returned structure will be properly sorted by values
		LEN 	= STRTRIM(MAX(STRLEN(STR)), 2)
		FMT   = '(A'+LEN+')'
		STR   = STR_SPACE2ZERO(STRING(STR,FORMAT=FMT))
		KEY = KEY + STR + '$'
	ENDFOR



END; #####################  End of Routine ################################



