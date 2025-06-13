; $Id: LARGEST.pro,v 1.1 1997/06/24 12:00:00 J.E.O'Reilly Exp $

function LARGEST, array,number,$
                   PERCENT=percent


;+
; NAME:
;       LARGEST
;
; PURPOSE:
;       Return the LARGEST (n) numbers in an array
;       or, the LARGEST (percent) of numbers in an array
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = LARGEST(array)            ; Returns the largest number in the array
;       Result = LARGEST(array,10)         ; Returns the largest 10 numbers
;       Result = LARGEST(array,10,/PERCENT)
;
; INPUTS:
;      An array
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;      A ARRAY CONTAINING the largest numbers
;
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
;       Modified June 24, 1997 Now returns an array, not the indices.
;-

; ==================>
  IF N_PARAMS() LT 1 THEN MESSAGE,'ERROR: MUST PROVIDE ARRAY'
  IF N_ELEMENTS(NUMBER) NE 1 THEN NUMBER = 1

  N = N_ELEMENTS(ARRAY)

  order = array(REVERSE(SORT(array)))

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