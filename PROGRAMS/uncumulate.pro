; $ID:	UNCUMULATE.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION UNCUMULATE,array,MISSING=missing
;+
; NAME:
;       UNCUMULATE
;
; PURPOSE:
;  UN Cumulates an array
;	 Will skip over array values equal to missing code
;
; CATEGORY:
;      MATH
;
; CALLING SEQUENCE:
;       Result = UNCUMULATE(a)
;       Result = UNCUMULATE(a, missing = -9)
;
; INPUTS:
;   Array
;
; KEYWORD PARAMETERS:
;  Missing:   value for missing data is set to NAN and the cumulative total for this array element will be same as previous array element
;
; OUTPUTS:
;		Array that is UNCUMULATED
;
;
; MODIFICATION HISTORY:
;       Written Nov 5, 2003  J.E. O'Reilly, NOAA, NMFS Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;-

; ===> Copy array into data variable (This keeps original array unchanged)
	data = DOUBLE(array)

;	===> Change missing values to NAN so IDL TOTAL function works correctly
	IF KEYWORD_SET(missing)  THEN BEGIN
    ok = WHERE(data EQ  missing, count)
    IF COUNT GE 1 THEN DATA[OK] = !VALUES.D_INFINITY
  ENDIF

	X =  DATA- SHIFT(DATA,1)

	X[0] = DATA[0]
  RETURN, X


END

