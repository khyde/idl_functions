; $ID:	MINMAX.PRO,	2004 07 02 02:37	$
;+
;NAME:
;   MINMAX
;
;PURPOSE:
;		Compute the Minimum, Maximum (and subscripts of the minimum and maximum)
;
;CATEGORY:
;	MATH
;
;INPUTS:
;		Data:	Numerical Data
;
;KEYWORDS:
;		SUBS: 	Subscripts of the minimum and maximum data values
;		FIN:		Exclude data matching NAN and INFINITY data from the minmax
;		MISSING: Exclude data matching the MISSING value from the minmax
;
;EXAMPLES:
;		PRINT, MINMAX(FINDGEN(11))
;		PRINT, MINMAX(FINDGEN(11),SUBS=SUBS) & PRINT, SUBS
;		X=[1,2,-9,3,!VALUES.F_INFINITY] & PRINT, MINMAX(X,SUBS=SUBS) & PRINT, SUBS
;		X=[1,2,-9,3,!VALUES.F_INFINITY] & PRINT, MINMAX(X,SUBS=SUBS,/FIN) & PRINT, SUBS;
;		X=[1,2,-9,3,!VALUES.F_INFINITY] & PRINT, MINMAX(X,SUBS=SUBS,MISSING= -9) & PRINT, SUBS
;		X=[1,2,-9,3,!VALUES.F_INFINITY] & PRINT, MINMAX(X,SUBS=SUBS,/FIN,MISSING= -9) & PRINT, SUBS
;   X=[1,2,-9,3,!VALUES.F_NAN] 			& PRINT, MINMAX(X,SUBS=SUBS,/FIN,MISSING= -9) & PRINT, SUBS
;		X=[1,2,-9,3,!VALUES.F_NAN]      & PRINT, MINMAX(X,SUBS=SUBS,MISSING= -999) & PRINT, SUBS
;
;HISTORY:
; 	Oct 6, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION MINMAX,DATA, SUBS=SUBS,FIN=FIN, MISSING=missing
  ROUTINE_NAME='MINMAX'

	GOOD=REPLICATE(1B,N_ELEMENTS(DATA))


	IF N_ELEMENTS(MISSING) EQ 1 THEN BEGIN
		OK=WHERE(DATA EQ MISSING,COUNT)
		IF COUNT GE 1 THEN GOOD(OK) = 0
	ENDIF

	IF KEYWORD_SET(FIN) EQ 1 THEN BEGIN
		OK=WHERE(FINITE(DATA) EQ 0,COUNT)
		IF COUNT GE 1 THEN GOOD(OK) = 0
	ENDIF


;	===> Now find just the good values
	OK=WHERE(GOOD EQ 1,COUNT)

	IF COUNT GE 1 THEN BEGIN
		MAXIMUM = MAX( DATA(OK), SUB_MAX,MIN= MINIMUM, SUBSCRIPT_MIN=SUB_MIN)
		 SUB_MAX = OK(SUB_MAX)
		 SUB_MIN = OK(SUB_MIN)
	ENDIF ELSE BEGIN
		SUB_MIN	= -1L
		SUB_MAX = -1L
		MINIMUM = !VALUES.F_NAN
		MAXIMUM = !VALUES.F_NAN
	ENDELSE


	SUBS = [SUB_MIN,SUB_MAX]
  RETURN, [MINIMUM,MAXIMUM]

END; #####################  End of Routine ################################
