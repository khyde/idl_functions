; $ID:	STR_JOIN.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION STR_JOIN, DATA0,DATA1,DATA2,DATA3,DATA4,DATA5,DATA6,DATA7,DATA8,DATA9,$
  									DELIM=DELIM, PAD=PAD
;+
; NAME:
; 	STR_JOIN

;		This Program Makes a string from several arrays, converting numeric types into strings

;	KEYWORDS:
;		DELIM:	Delimiter to apply between strings, default is comma ','
;		PAD:		Pads each input data array with zeros to the left for proper subsequent sorting

; 	MODIFICATION HISTORY:
;			WRITTEN NOV 3, 2005 BY J.O'REILLY
;-

	ROUTINE_NAME='STR_JOIN'

  OK_PARAMS  = WHERE_PARAMS(DATA0,DATA1,DATA2,DATA3,DATA4,DATA5,DATA6,DATA7,DATA8,DATA9,COUNT=N_PARAM,NCOMPLEMENT=ncomplement,COMPLEMENT=COMPLEMENT)



	IF N_PARAM EQ 0 THEN RETURN, ''
	IF N_ELEMENTS(DELIM) NE 1 THEN _DELIM = ',' ELSE _DELIM = DELIM

;;	TXT=''
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0L,N_PARAM-1L DO BEGIN
		POS = OK_PARAMS(nth)
		IF pos EQ 0  THEN DATA = DATA0
		IF pos EQ 1  THEN DATA = DATA1
		IF pos EQ 2  THEN DATA = DATA2
		IF pos EQ 3  THEN DATA = DATA3
		IF pos EQ 4  THEN DATA = DATA4
		IF pos EQ 5  THEN DATA = DATA5
		IF pos EQ 6  THEN DATA = DATA6
		IF pos EQ 7  THEN DATA = DATA7
		IF pos EQ 8  THEN DATA = DATA8
		IF pos EQ 9  THEN DATA = DATA9
		STR 	= STRTRIM(DATA,2)
;		===> Determine maximum length of strings so they may padded with leading zeros
;				 This ensures that the final returned structure will be properly sorted by values

 		NUM_STR=N_ELEMENTS(STR)
 		SUBS_STR = LINDGEN(NUM_STR)

		IF KEYWORD_SET(PAD) THEN BEGIN
			LEN 	= STRTRIM(MAX(STRLEN(STR)), 2)
			FMT   = '(A'+LEN+')'
			STR   = STR_SPACE2ZERO(STRING(STR,FORMAT=FMT))
		ENDIF


 ;	===> Dimension TXT
		IF N_ELEMENTS(TXT) EQ 0 THEN BEGIN
			TXT =  STR
		ENDIF ELSE BEGIN
			T = REPLICATE('',  NUM_STR > NUM_TXT)
			T(SUBS_TXT) =  TXT(SUBS_TXT)
			IF num_str GT NUM_TXT THEN BEGIN
				OK=WHERE(SUBS_STR EQ SUBS_TXT)
				START = LAST[OK]+1
				T(START:*) = _DELIM
			ENDIF
			T(SUBS_STR) = T(SUBS_STR) + STR
			TXT=T
		ENDELSE

		NUM_TXT = N_ELEMENTS(TXT)
		SUBS_TXT = LINDGEN(NUM_TXT)
		TXT = TXT + _DELIM
	ENDFOR

	RETURN, TXT

END; #####################  End of Routine ################################



