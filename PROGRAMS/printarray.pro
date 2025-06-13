; $ID:	PRINTARRAY.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO PRINTARRAY, array, X0,X1, Y0,Y1
;+
; NAME:
;       PRINTARRAY
;
; PURPOSE:
;       Print an array by rows
;
; CATEGORY:
;       PRINTING
;
; CALLING SEQUENCE:
;        PRINTARRAY,ARRAY
;
; INPUTS:
;        array: 2-dimensional array
;        x0   : beginning x element
;        x1   : ending    x element
;        y0   : beginning y element
;        y1   : emding    y element
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;       Prints array
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
;       Written by:  J.E.O'Reilly, December 30,1997
;-



; ==============>
; Make a copy of input array
  data = array

; ====================>
; Make sure array is provided and it is 2-Dimensions
  s = SIZE(data)
  IF S[0] NE 2 THEN MESSAGE,'ERROR: Must Provide a 2-dimensional array'


; Default is to print out only array(0,0)
  IF N_ELEMENTS(X0) EQ 0 THEN X0 = 0
  IF N_ELEMENTS(X1) EQ 0 THEN X1 = 0
  IF N_ELEMENTS(Y0) EQ 0 THEN Y0 = 0
  IF N_ELEMENTS(Y1) EQ 0 THEN Y1 = 0


; ===================>
; Make sure x0 subscripts less than x1
; If not then reverse
  xx  = x0 < x1
  xxx = x0 > x1
  x0  = xx
  x1  = xxx

; ===================>
; Make sure y0 subscripts less than y1
; If not then reverse
  yy  = y0 < y1
  yyy = y0 > y1
  y0  = yy
  y1  = yyy


; ====================>
; Make sure x and y within subscripts allowed by input array
  x0 = 0 > x0  < (s[1] -1)
  x1 = 0 > x1  < (s[1] -1)
  y0 = 0 > y0  < (s(2) -1)
  y1 = 0 > y1  < (s(2) -1)

; ===============>
; Print the subscripted array

  FOR J = Y0,Y1, 1 DO BEGIN
    PRINT, data(X0:X1, J)
  ENDFOR

END  ; End of Program
