; $Id: STR_COMBO_RIGHT.pro  June 13, 2003
;+
;	This Function returns COMBINATIONS of AN input String from LEFT to Right

; HISTORY:
;		June 13, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STR_COMBO_RIGHT,TEXT, DELIM=delim
  ROUTINE_NAME='STR_COMBO_RIGHT'

	IF N_ELEMENTS(DELIM) NE 1 THEN DELIM = '_'
	txt = STRSPLIT(STRUPCASE(TEXT),DELIM,/EXTRACT,/PRESERVE_NULL)
  N = N_ELEMENTS(TXT)
  IF N EQ 0 THEN RETURN, ''

 	N_CASES = TOTAL(INDGEN(N)+1)
  ALL = STRARR(N_CASES)
  counter = -1L

; LLLLLLLLLLLLLLLLLLLLLLL
 	FOR J = 0, N-1 DO BEGIN
;		LLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR I = N-1, J,-1 DO BEGIN
			counter = counter + 1L
			KK = INDGEN(N-I)+J
	 		ALL(counter) = STRJOIN(TXT(KK) +DELIM)
	 		ALL(counter) = STRMID(all(counter),0,STRLEN(ALL(counter))-1 )
		ENDFOR
	ENDFOR
	RETURN, ALL
END; #####################  End of Routine ################################



















