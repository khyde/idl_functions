; $Id: MOST.pro,v 1.0 1997/12/03 12:00:00 J.E.O'Reilly Exp $

function MOST, array,number,$
               PERCENT=percent


;+
; NAME:
;       MOST
;
; PURPOSE:
;       Return MOST (n) middle numbers in an array
;
;       Used to trim tails in a univariate distribution and return the central data
;
; CATEGORY:
;       Statistical
;
; CALLING SEQUENCE:
;       Result = MOST(Array)             ; Returns all but the lowest and highest value
;       Result = MOST(Array,5)           ; Returns the 5 middle values in an array
;       Result = MOST(Array,99,/PERCENT) ; Returns the middle 99% of values in an array
;
; INPUTS:
;      An array with 3 or more elements
;
; KEYWORD PARAMETERS:
;      PERCENT      :  Defines the Percent of the array (mid-range)to return
;
;
; OUTPUTS:
;      An array containing most of the data with the tails trimmed
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Input Array must have at least 3 elements..
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, December 3, 1997.
;
;-

; ==================>
; Check whether array is provided and that array has at least 3 elements
  IF N_PARAMS() LT 1 THEN MESSAGE,'ERROR: MUST PROVIDE ARRAY'
  N = N_ELEMENTS(ARRAY)
  IF N  LT 3 THEN MESSAGE,'ERROR: ARRAY MUST HAVE AT LEAST 3 ELEMENTS'

; ====================>
; Define subscript of center of array
; (-0.5 is used to deal with odd and even numbered arrays)
  center   = N/2.0 -0.5d

; ==================>
; If number parameter not supplied then default
; is to trim smallest and largest values from sorted array
  IF N_ELEMENTS(NUMBER) NE 1 THEN BEGIN
    start    = 1
    finish   = N-2
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(PERCENT) THEN BEGIN
      IF number LT 0 OR number GT 100 THEN MESSAGE,'ERROR: WHEN USING PERCENT KEYWORD the number parameter MUST BE 0-100 '
      number =  N*number/100.0D
    ENDIF
      start    = center - number/2.0d
      finish   = center + number/2.0d -1
  ENDELSE

; ==================>
; order input array from smallest to largest
  order = array(SORT(array))

; ==================>
; Ensure that subscripts will always exclude the first and last element from the array
  start   = 1 >  (ROUND(start))   < (N-2)
  finish  = 1 >  (ROUND(finish))  < (N-2)


; ==================>
; Ensure that finish subscript will be greater than  start subscript
  finish = start > finish

 RETURN, ORDER(start:finish)
 END  ; End of Program
