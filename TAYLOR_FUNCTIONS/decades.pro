; $Id:	decades.pro,	December 05 2006	$

FUNCTION DECADES, Range, HALF=half
;+
; NAME:
;		DECADES;
; PURPOSE:
;		This FUNCTION generates an array of DECADES in increments of 1/10TH decade
; CATEGORY:
;		Numeric
; CALLING SEQUENCE:
;   Result = DECADES()
; INPUTS:
;		Range: [MIN,MAX] of exponents of base 10
;		e.g. [1,3] means [10^1,10^3]
;		If Range is not provided then [-10,10] is assumed.
; OUTPUTS:
;		An array of DECADES in increments of 1/10TH decade.
;
;	EXAMPLE:
;   Result = DECADES() 				& PRINT, Result
;		Result = DECADES(0)				& PRINT, Result
;		Result = DECADES([-1,1])	& PRINT, Result

;		Result = DECADES([1,-1])	& PRINT, Result ; ;		Descending order:
;   Result = DECADES([-38,38])& PRINT, Result
;
;		Result = DECADES([0,0])  	& PRINT, Result
;
; 	RESTRITION:
;			SEE IDL'S MACHAR function for largest and smallest usable floating-point and double-precision data types.
;
; MODIFICATION HISTORY:
;		Written May 11,2000 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	*************************************************************************
	ROUTINE_NAME='DECADES'

;	===> Initialize TENS
	TENS = (FINDGEN(10)+1)

;	===> Constrain to [-10,10] if Range not provided
  IF N_ELEMENTS(Range) EQ 0 OR N_ELEMENTS(Range) GT 2 THEN Range = [-10,10]
	IF N_ELEMENTS(Range) EQ 1 THEN Range=[Range,Range]

;	===> Fix Range as an Integer
	MIN_RANGE 	= MIN(RANGE,SUB)
	RANGE(SUB) 	= FLOOR(RANGE(SUB))

	MAX_RANGE = MAX(RANGE,SUB)
	RANGE(SUB) = CEIL(RANGE(SUB))

;	===> Floating points are only accurate to approx. 1e38.  If Range is higher then promote Range to Double-Precision
	IF Range(0) LT -38 OR Range(1) GE 38 THEN _RANGE = DOUBLE(RANGE) ELSE _RANGE = RANGE

;	===> Determine if ascending or decending step
  IF _Range(0) GT _Range(1) THEN STEP = -1 ELSE STEP = 1

;	===> Initialize ARR to hold output
  ARR = 0.0


;	===> Loop over Range and concatenate results with ARR
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR N= _Range(0),_Range(1), STEP DO BEGIN
  	PART = TENS*10.0^(N-1)
    IF N EQ _Range(0) THEN ARR = [ARR,PART] ELSE ARR = [ARR, PART(1:*)]
  ENDFOR
; ||||||

	IF KEYWORD_SET(HALF) THEN BEGIN
STOP
	ENDIF

;	===> Return all but the initialized value for ARR
  RETURN,ARR(1:*)

END; #####################  End of Routine ################################
