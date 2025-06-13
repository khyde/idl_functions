; $Id: SMALLEST.pro,v 1.1 1997/06/25 12:00:00 J.E.O'Reilly Exp $

function SMALLEST, array,number,$
                   PERCENT=percent


;+
; NAME:
;       SMALLEST
;
; PURPOSE:
;       Return the smallest (n) numbers in an array
;       or, the smallest (percent) of numbers in an array
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = SMALLEST(Array)           ; Will return the smallest number from the array
;       Result = SMALLEST(Array,10)
;       Result = SMALLEST(Array,10,/PERCENT)
;
; INPUTS:
;      An array
;
; KEYWORD PARAMETERS:
;      PERCENT      : To extract the smallest percent of the array
;
; OUTPUTS:
;      A Array containing the smallest number (s)
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 20, 1996.
;       Returns the actual smallest data not the indices June 24, 1997
;-

; ==================>
  IF N_PARAMS()LT 1 THEN MESSAGE,'ERROR: MUST PROVIDE ARRAY'
  IF N_ELEMENTS(NUMBER) NE 1 THEN NUMBER = 1

  N = N_ELEMENTS(ARRAY)

; order from smallest to biggest
  order = array(SORT(array))


  start   = 0
  IF KEYWORD_SET(PERCENT) THEN BEGIN
    IF number LT 0 OR number GT 100 THEN MESSAGE,'ERROR: PERCENT number MUST BE 0-100 '
    fraction=  DOUBLE(number)/100D
    finish  = 0 >  (ROUND(N*fraction)-1) < (N-1)
  ENDIF ELSE BEGIN
    finish  = 0 > (number-1) < (N-1)
  ENDELSE


 RETURN, ORDER(start:finish)
 END
