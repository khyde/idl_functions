; $ID:	CUMULATE.PRO,	2020-06-26-15,	USER-KJWH	$

FUNCTION CUMULATE,array,MISSING=missing
;+
; NAME:
;       cumulate
;
; PURPOSE:
;
;  Cumulative sum of an array.
;	 Will skip over array values equal to missing code
;
;
; CATEGORY:
;      MATH
;
; CALLING SEQUENCE:
;       Result = cumulate(a)
;       Result = cumulate(a, missing = -9)
;
; INPUTS:
;   Array
;
; KEYWORD PARAMETERS:
;  Missing:   value for missing data is set to NAN and the cumulative total for this array element will be same as previous array element
;
; OUTPUTS:
;		Array that is cumulated
;
;
; MODIFICATION HISTORY:
;       Written August 15, 1995, J.E. O'Reilly, NOAA, NMFS Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;	Nov 5, 2003 now using IDL's TOTAL function
;-

; ===> Copy array into data variable (This keeps original array unchanged)
	data = DOUBLE(array)

;	===> Change missing values to NAN so IDL TOTAL function works correctly
	IF KEYWORD_SET(missing)  THEN BEGIN
    ok = WHERE(data EQ  missing, count)
    IF COUNT GE 1 THEN DATA[OK] = !VALUES.D_NAN
  ENDIF

  RETURN, TOTAL( Data, /CUMULATIVE,/DOUBLE, /NAN )


END

