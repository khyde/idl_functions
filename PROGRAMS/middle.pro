; $Id: middle.pro,v 1.1 1997/06/25 12:00:00 J.E.O'Reilly Exp $

function middle, array,number,$
                   PERCENT=percent,SUB=sub


;+
; NAME:
;       middle
;
; PURPOSE:
;       Return the middle (n) numbers in an array
;       or, the middle (percent) of numbers in an array
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = middle(Array)           ; Will return the middle number from the array
;       Result = middle(Array,10)
;       Result = middle(Array,10,/PERCENT)
;
; INPUTS:
;      An array
;
; KEYWORD PARAMETERS:
;      PERCENT      : To extract the middle percent of the array
;
; OUTPUTS:
;      A Array containing the middle number (s)
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
;       Returns the actual middle data not the indices June 24, 1997
;-

; ==================>
  IF N_PARAMS()LT 1 THEN MESSAGE,'ERROR: MUST PROVIDE ARRAY'
  IF N_ELEMENTS(NUMBER) NE 1 THEN NUMBER = 1

  N = N_ELEMENTS(ARRAY)

; order from middle to biggest
  SORTED = SORT(array)
  ORDER  = ARRAY(SORTED)



  IF KEYWORD_SET(PERCENT) THEN BEGIN
    IF number LT 0 OR number GT 100 THEN MESSAGE,'ERROR: PERCENT number MUST BE 0-100 '
    fraction= DOUBLE(number)/100D
    n_set     = fraction*N
    nth_mid   = (N/2.0)
    start     = nth_mid - n_set/2L
    finish    = nth_mid + n_set/2L -1L
    start   = 0L > (start)  < (N-1L)
    finish  = 0L > (finish) < (N-1L)


  ENDIF ELSE BEGIN
    finish  = 0 > (number-1) < (N-1)
  ENDELSE

IF NOT KEYWORD_SET(SUB) THEN BEGIN
  RETURn, ORDER(start:finish)
ENDIF ELSE BEGIN
  RETURN,SORTED(start:finish)
ENDELSE
END