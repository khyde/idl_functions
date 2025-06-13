; $Id:	scale.pro,	August 22 2007	$

FUNCTION SCALE, ARRAY, RANGE, MIN=MIN,MAX=MAX, INTERCEPT=intercept, SLOPE=slope, ERROR=error
;+
; NAME:
;       SCALE
;
; PURPOSE:
;				Linearly scale an input ARRAY to the RANGE provided
;
; CATEGORY:
;				MATH
;
; CALLING SEQUENCE:
;       Result = scale(a)
;
; INPUTS:
;				Array:  any numeric data
;				Range:  The desired range [min,max] to use in scaling the array
;								If Range is not provided then the range used will be the [MIN,MAX] of the FINITE data
;
; KEYWORD PARAMETERS:
;
;				MIN:				ARRAY values below the MIN are set to RANGE(0)
;				MAX:				ARRAY values above the MAX are set to RANGE(1)
;				INTERCEPT: 	The y-intercept of the linear equation used in scaling
;				SLOPE:			The slope of the linear equation used in scaling
;				ERROR:			'' = OK, 'ERROR MESSAGE'= ERROR
;
; OUTPUTS:
;				A double precision array scaled to the Range
;
;	EXAMPLES:
;
;	 PRINT, SCALE([2,3,8,127,255],[0,100])
;  S= SCALE([1,250], [-0.30, 0.30],intercept=intercept,slope=slope) & print, intercept,slope
;  S= SCALE([1,250], alog10([1,100]),intercept=intercept,slope=slope) & print, intercept,slope
;  S= SCALE([-3,1,4,250],[1,200],MIN= 1,MAX=200,intercept=intercept,slope=slope) & print, intercept,slope
;
; MODIFICATION HISTORY:
;       Written August 29,2000 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME = 'SCALE'

	ERROR = ''


  IF N_ELEMENTS(ARRAY) LT 1 THEN BEGIN
  	ERROR = 1
  	RETURN, !VALUES.D_INFINITY
  ENDIF


; ===> Find Finite data
	OK = WHERE(FINITE(ARRAY),COUNT)

;	===> Make good data double precision
	IF COUNT GE 1 THEN BEGIN
		_ARRAY = DOUBLE(ARRAY(OK))

		MIN_ARRAY = MIN(_ARRAY,MAX=MAX_ARRAY)

;		===> MIN AND MAX
		IF N_ELEMENTS(MIN) EQ 1 THEN _MIN = MIN ELSE _MIN = MIN_ARRAY
		IF N_ELEMENTS(MAX) EQ 1 THEN _MAX = MAX ELSE _MAX = MAX_ARRAY

;		===> Check on Range
		IF N_ELEMENTS(RANGE) NE 2 THEN _RANGE = [MIN_ARRAY,MAX_ARRAY] ELSE _RANGE = DOUBLE(RANGE)


		IF N_ELEMENTS(_ARRAY) GE 2 THEN BEGIN
			SLOPE 		= (_RANGE(1)-_RANGE(0))/(_MAX- _MIN)
  		INTERCEPT = _RANGE(1) - _MAX * SLOPE
  	ENDIF ELSE BEGIN
  		SLOPE =   1.0
  		INTERCEPT = 0.0
  	ENDELSE

 ;	===> Constrain the Scaled values to be between the MIN and MAX
		SCALED =  _RANGE(0) > (INTERCEPT + SLOPE* _ARRAY) <  _RANGE(1)

;		===> Make an array to hold the result and fill it with infinity
  	COPY   		= DOUBLE(ARRAY) & COPY(*) = !VALUES.D_INFINITY

;		===> Replace Copy with good scaled values
  	COPY(OK) 	= SCALED
  	RETURN, COPY

	ENDIF ELSE BEGIN
		ERROR			= 1
		SLOPE			=	!VALUES.D_INFINITY
  	INTERCEPT	=	!VALUES.D_INFINITY
		RETURN, 		''
	ENDELSE


END; #####################  End of Routine ################################
