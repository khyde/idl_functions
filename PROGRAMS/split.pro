; $Id: SPLIT.pro, November 8,1999  J.O'Reilly
; WARNING: PROGRAM DOES NOT ALWAYS RETURN THE DESIRED NUMBER OF SETS !!!!!!!!!!!!
function SPLIT,DATA, N , SUBS=subs
;+
; NAME:
;       SPLIT
;
; PURPOSE:
;       Split an array into 2 or more approximately even groups
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = SPLIT(data)
;
; INPUTS:
;       ARRAY: An array
;       N   : Number of resulting groups
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
;       Written by:  J.E.O'Reilly, November 8,1999
;-



; ====================>
; Default is to split into 2
  IF N_ELEMENTS(N) NE 1 THEN N = 2

  number = N_ELEMENTS(data)
 ; IF NUMBER EQ 1 THEN RETURN, DATA

  IF N GE NUMBER THEN N = 1

  SET_SIZE = NUMBER / LONG(N)

  NTH = NUMBER -1L

  GROUPS = INDGEN(NUMBER)
  GROUPS = (GROUPS/ (SET_SIZE))
  U = UNIQ(GROUPS)
  U = [-1L,U]

  IF KEYWORD_SET(SUBS) THEN RETURN, U

  FOR I = 0, N_ELEMENTS(U)-2L DO BEGIN

    ;IF I EQ (N-1L) AND LAST LT (NUMBER-1L) THEN LAST = (NUMBER-1L)
   ; PRINT, FIRST,LAST
    SUB = DATA(U(I)+1L: U(I+1))


    NAME = '_' + NUM2STR(I)

     IF N_ELEMENTS(ARR) EQ 0 THEN BEGIN
       ARR=CREATE_STRUCT(NAME,sub)
     ENDIF ELSE BEGIN
       ARR=CREATE_STRUCT(ARR,NAME,sub)
     ENDELSE

  ENDFOR


  RETURN, ARR

  END; END OF PROGRAM
