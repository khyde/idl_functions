; $ID:	ACF_FIRST_ZERO.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	ACF_FIRST_ZERO:	This Function Finds the First Zero Crossing for an Auto Correlation Function
;
;	ACF:  The Auto Correlation Function
;	TP_ACF :	The Time Period that the ACF encompasses
;						(Remember to double the input TP_ACF if the ACF encompases both positive and negative time (positive and negative lags) or
;						if the ACF was generated from a DFT (which has positive and negative (mirror image) frequencies)
;	EXAMPLES:
;	1) Positive lags only with lags equal to the number of elements in the data
;  	TIME=FINDGEN(101)/20. & TP_ACF=MAX(TIME)-MIN(TIME) & DATA = FINDGEN(101) & LAG = INDGEN(N_ELEMENTS(DATA)-2) & ACF = A_CORRELATE(DATA,LAG) & PLOT, TIME,ACF & T0 = ACF_FIRST_ZERO(ACF,TP_ACF=TP_ACF) & OPLOT,MINMAX(TIME),[0,0],LINESTYLE=1 & PRINT, T0
;
;		Negative and Positive lags with lags equal to 2* the number of elements in the data + 1 (zero);
;		TIME=FINDGEN(101)/20. & TP_ACF= 2*(MAX(TIME)-MIN(TIME)) & DATA = FINDGEN(101) & LAG = [-INDGEN(N_ELEMENTS(DATA)-2),0,INDGEN(N_ELEMENTS(DATA)-2)] & ACF = A_CORRELATE(DATA,LAG) & PLOT, TIME,ACF & T0 = ACF_FIRST_ZERO(ACF,TP_ACF=TP_ACF) & PRINT, T0
;


;  					ACT=A_CORRELATE(F_, Lag  , /DOUBLE)
;						Original Data over 6  years and If the original data were over a 6 year period and and a complete ACFover which the ACF was computed ~ (MAX(TIMES)-MIN(TIMES)
; HISTORY:	May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION ACF_FIRST_ZERO,ACF, TP_ACF=tp_acf, WIDTH=WIDTH,TRAP=TRAP, SUBS=SUBS,SMO=smo,  ERROR=error
  ROUTINE_NAME='ACF_FIRST_ZERO'
  ERROR=0
  IF N_ELEMENTS(WIDTH) NE 1 THEN _WIDTH = 11 ELSE _WIDTH = WIDTH

	N=N_ELEMENTS(ACF)

	TIME_PER_BIN = TP_ACF/FLOAT(N)

	INDEX=LINDGEN(N)

	_ACF=REAL_PART(ACF)

;	===> Locate Maximum ACF and Normalize to 1.0
;			(may not already be normalized to 1 for zero lag)
 	MAX_ACF=MAX(_ACF,SUB_MAX)
	_ACF = _ACF/_ACF(SUB_MAX)


;	===> Smooth the ACF
	IF KEYWORD_SET(TRAP) THEN BEGIN
		SMO = FILTER_DANIELL(_ACF,_WIDTH)
	ENDIF ELSE BEGIN
		;SMO = SMOOTH(_ACF,_WIDTH,/EDGE_TRUNCATE)
		SMO = SMOOTH(_ACF,_WIDTH)
	ENDELSE

	OK=WHERE(SMO LE 0 AND INDEX GT SUB_MAX ,COUNT)

	FIRST_ZERO = FIRST[OK]
	PAIR = [(0>FIRST_ZERO-1),FIRST_ZERO]
	SUBS = [SUB_MAX, INTERPOL(PAIR,SMO(PAIR), 0.0  )]

;	TIME_OF_FIRST_ZERO = TIME_PER_BIN * I
	RETURN, TIME_PER_BIN * SPAN(SUBS)

END; #####################  End of Routine ################################
