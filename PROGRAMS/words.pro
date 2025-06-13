; $ID:	WORDS.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program Extracts WORDS from a TXT (string array) using STANDARD DASH ('-') OR Supplied Delimiter
;	Program also parses words separated by a dot '.'
; HISTORY:
;	Jun 21, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;
;-
; *************************************************************************
FUNCTION WORDS, TXT, LINE=line, DELIM=delim, NO_NULL=NO_NULL
  ROUTINE_NAME='WORDS'
; ===> Dash separates WORDS in sentence
	IF N_ELEMENTS(DELIM) EQ 0 THEN _DELIM = '-' ELSE _DELIM = DELIM
	N=N_ELEMENTS(TXT)
	BDELIM=BYTE(_DELIM) & BDELIM=BDELIM[0]
;	===> Determine how many LINES have _delim and can be split into words
;;	OK=WHERE(BYTE(TXT) EQ bdelim OR BYTE(TXT) EQ bdot ,COUNT)
	OK=WHERE(BYTE(TXT) EQ BDELIM ,COUNT)


; ===> IF ANY of the TXT lines have _DELIM then ...
	IF COUNT GE 1 THEN BEGIN
		N_NEW = N+COUNT
		NEW = STRARR(N_NEW)
		COUNTER=0L
 		LINE = LONARR(N_NEW)
		FOR NTH = 0L,N -1 DO BEGIN
 			T=STRSPLIT(TXT[NTH],_DELIM,/EXTRACT,/PRESERVE_NULL)
			N_WORDS = N_ELEMENTS(T)
			NEW(COUNTER) = T
			LINE(COUNTER) = REPLICATE(NTH,N_WORDS)
			COUNTER=COUNTER+N_WORDS
		ENDFOR
		IF KEYWORD_SET(NO_NULL) THEN BEGIN
			OK_NULL = WHERE(NEW EQ '',COUNT_NULL)
			IF COUNT_NULL GE 1 THEN BEGIN
				NEW 	= REMOVE(NEW,OK_NULL)
				LINE 	= REMOVE(LINE,OK_NULL)
			ENDIF
		ENDIF
		RETURN, NEW
;	===> IF NONE of the TXT lines have _DELIM then ...
	ENDIF ELSE BEGIN
		LINE = LINDGEN(N)
		RETURN, TXT
	ENDELSE

;	************************************************************
;	************************************************************

END; #####################  End of Routine ################################
