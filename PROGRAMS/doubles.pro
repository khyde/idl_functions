; $ID:	DOUBLES.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION DOUBLES, RANGE
;+
; NAME:
;       DOUBLES
;
; PURPOSE:
;       Generate a complete series (BASE = 2) over the supplied range
;
; CATEGORY:
;       Numerical Series
;
; CALLING SEQUENCE:
;       Result = DOUBLES()
;       Result = DOUBLES([-32,38])
;
; INPUTS:
;       RANGE: [MIN,MAX] of exponents
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       ARRAY OF DOUBLES IN INCREMENTS OF 1/10TH

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, May 11,2000
;				March 24, 2003 jor fixed bug
;-

  IF N_ELEMENTS(RANGE) EQ 0 OR N_ELEMENTS(RANGE) GT 2 THEN RANGE = [-40,40]
	IF N_ELEMENTS(RANGE) EQ 1 THEN RANGE=[RANGE,RANGE] ELSE RANGE[0]=RANGE[0]+1


	RETURN, 2.^(LINDGEN(ABS(RANGE[1]-RANGE[0]))+RANGE[1])


END; #####################  End of Routine ################################
