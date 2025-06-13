; $ID:	INTERP_XTEND.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION INTERP_XTEND, X,Y, XX, X_MISSING = x_missing,Y_MISSING=y_missing,MAKE_MISSING=make_missing,ERROR=error
;+
; NAME:
; 	INTERP_XTEND
;		This Function generates a set of Y interpolates at each new XX location based on the x,y paired input

;		NOTE that the program does not EXTRAPOLATE, instead, it EXTENDS
;		NOTE that the program EXTENDS (REPLICATES) the first Y value for all XX LT the first X
;		NOTE that the program EXTENDS (REPLICATES) the last  Y value for all XX GT the last  X


;
;	INPUTS:
;		X:  X locations
;		Y:  Y Data Values
;	 XX:	X locations for interpolated values
;
;	 X_MISSING: Missing data code for X
;	 Y_MISSING: Missing data code for Y

;
;	OUTPUTS:
;		The Function returns a STRUCTURE with interpolates at the XX locations
;		ERROR:  Set to 1 if error, 0 if no error encountered

; EXAMPLES:
; PRINT, INTERP_XTEND([2.,3,4.5,5,6],[10.,15,20,15,20],[0,1,2,3,4,5,6,7,8], XTEND=XTEND) & PRINT, XTEND
; INTERP_XTEND([2.,3,4.5,5,6],[10.,15,20,15,20],[0,1,2,3,4,5,6,7,8], XTEND=XTEND,/MAKE_MISSING) & PRINT, XTEND

; MODIFICATION HISTORY:
;		Written March 19, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;		Nov 5, 2006 JOR Using VALUE_LOCATE
;-

ROUTINE_NAME='INTERP_XTEND'

	ERROR = 0

;	===> Missing x,y codes
	IF N_ELEMENTS(X_MISSING) NE 1 THEN _X_MISSING = MISSINGS(X) ELSE _X_MISSING = X_MISSING
	IF N_ELEMENTS(Y_MISSING) NE 1 THEN _Y_MISSING = MISSINGS(Y) ELSE _Y_MISSING = Y_MISSING

;	===> Find non-missing x,y
	OK=WHERE(X NE _X_MISSING AND Y NE _Y_MISSING ,COUNT)
	IF COUNT EQ 0 THEN BEGIN
		ERROR = 1
		RETURN,-1L
	ENDIF

 	_X = X[OK]
 	_Y = Y[OK]

	IF IDLTYPE(_X,/CODE) EQ 7 THEN _X = FLOAT(_X)
	IF IDLTYPE(_Y,/CODE) EQ 7 THEN _Y = FLOAT(_Y)

;	===> Sort _X,_Y in ascending _X order
	srt = SORT(_X)
	_X=_X(srt)
	_Y=_Y(srt)

;	===> Sort _XX in ascending XX order
	srt = SORT(XX)
	_XX  = XX(srt)

;	===> Compute Linear Interpolates (YY) at locations XX based on input data (_Y) at input locations (_X)
	YY = INTERPOL(_Y,_X, _XX)

;	===> Create a spreadsheet type structure to hold all output,initialize TYPE to 'INTERP'
	STRUCT= REPLICATE(CREATE_STRUCT('X',MISSINGS(XX),'Y',MISSINGS(YY),'TYPE','INTERP','FIRST',MISSINGS(XX),'SECOND',MISSINGS(XX)),N_ELEMENTS(YY))
 	STRUCT.X = _XX
	STRUCT.Y =  YY



;	===> Use VALUE_LOCATE to determine where locations for the interpolation (XX) are less than input X locations
	SUBS_UP=VALUE_LOCATE(_X,_XX)
	STRUCT.FIRST = _X(SUBS_UP)

;	===> Use VALUE_LOCATE to determine where locations for the interpolation (XX) are greater than input X locations
	_X_REVERSE = REVERSE(_X)
	SUBS_DOWN=VALUE_LOCATE(_X_REVERSE,_XX)
	STRUCT.SECOND = _X_REVERSE(SUBS_DOWN)


	OK = WHERE(_XX LT FIRST(_X),COUNT)
	IF COUNT GE 1 THEN BEGIN
		STRUCT[OK].TYPE = 'EXTEND'
		IF NOT KEYWORD_SET(MAKE_MISSING) THEN STRUCT[OK].Y = FIRST(_Y) ELSE STRUCT[OK].Y = MISSINGS(_Y)
	ENDIF

	OK = WHERE(_XX GT LAST(_X),COUNT)
	IF COUNT GE 1 THEN BEGIN
		STRUCT[OK].TYPE = 'EXTEND'
		IF NOT KEYWORD_SET(MAKE_MISSING) THEN STRUCT[OK].Y = LAST(_Y) ELSE STRUCT[OK].Y = MISSINGS(_Y)
	ENDIF


;	===> Replace any TYPE with 'DATA' where the interpolation locations (XX) match the input X locations
	OK = WHERE_IN(_XX,_X,COUNT)
	IF COUNT GE 1 THEN BEGIN
		STRUCT[OK].TYPE = 'DATUM'
	ENDIF


; print, xx & print & print,x & print & print, _x_reverse & print & print & print, subs_up & print &  print, (subs_down)




;	===> REPLACE ANY NANS WITH INF
	YY= NAN_2INFINITY(YY)




	RETURN, STRUCT

END; #####################  End of Routine ################################



