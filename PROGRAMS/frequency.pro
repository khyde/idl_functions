; $ID:	FREQUENCY.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Computes the Frequency of values in an array
; SYNTAX:
;		Result = FREQUENCY(Array)
; OUTPUT:
;		Structure containing each unique value and the frequency for the value
; ARGUMENTS:
;		Array:
; KEYWORDS:
;		none
; EXAMPLE:
;		A= [0,0,1,1,2,3,4,4,4,5,0,1] & S=frequency(a) & PRINT, S.VALUE & PRINT,S.FREQ
; CATEGORY:
;		STATISTICS
; NOTES:
; VERSION:
;		Mar 15, 2001
; HISTORY:
;		Mar 15, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION FREQUENCY,Array, UP=up,DOWN=down
  ROUTINE_NAME='FREQUENCY'
  sz=SIZE(Array,/STRUCT)
  n=sz.N_ELEMENTS
  IF n EQ 0 THEN RETURN, -1

  s=SORT(Array)
  copy = Array(s)
  u=UNIQ(copy)
  nth = N_ELEMENTS(u)-1L
  IF nth EQ 0 THEN BEGIN
    freq		= N
  ENDIF ELSE BEGIN
  	freq		= u - ([0,u(0:nth)])
  	freq[0]	=freq[0]+1
  ENDELSE

  IF KEYWORD_SET(UP) OR KEYWORD_SET(DOWN) THEN BEGIN
    s=SORT(freq)
    IF KEYWORD_SET(DOWN) THEN s=REVERSE(s)
		struct = CREATE_STRUCT('Value',copy(u(s)),'Freq',freq(s))
  ENDIF ELSE BEGIN
  	struct = CREATE_STRUCT('Value',copy(u),'Freq',freq)
  ENDELSE

  RETURN,Struct

END; #####################  End of Routine ################################
