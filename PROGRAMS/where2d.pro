; $ID:	WHERE2D.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION where2d,  array, missing, $
                   ROW=row
;+
; NAME:
;       where2d
;
; PURPOSE:
;       For each column (or row) of an array,
;       find the rows (or columns) which do not have missing data
;
; CATEGORY:
;       Math
;
; CALLING SEQUENCE:
;       RESULT = where2d(a,MISSING= 999)
;
; INPUTS:
;       an array of one or more columns
;       A missing value code
;
; KEYWORD PARAMETERS:
;       ROW:  works on the rows instead of the columns
;   MISSING:  Your code for missing data
;
; OUTPUTS:
;       A resized array with non-missing data
;
; SIDE EFFECTS:
;
;
; RESTRICTIONS:
;       1 or 2 DIMENSIONAL ARRAYS
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly , March 8,1999
;-

; ==================>
; Check the size of the input array
  SZ=SIZE(ARRAY)
  IF SZ[0] LT 1 OR SZ[0] GE 3 THEN RETURN,-1L ; Can not handle 0 OR 3 dimensions

; ====================>
; Determine the variable type
  type = sz(sz[0]+1)

; ====================>
; Make a copy of the input array
; The copy will be LONG
  copy = LONG(array)
  copy(*) = 0L

; ====================>
; IF single dimension array
  IF SZ[0] EQ 1 THEN BEGIN
     OK = WHERE(ARRAY NE MISSING,COUNT)
     IF COUNT GE 1 THEN BEGIN
       COPY = ARRAY[OK]
       RETURN,COPY
     ENDIF ELSE BEGIN
       COPY = -1L
     ENDELSE
  ENDIF

; ====================>
; IF 2 dimension array
  IF SZ[0] EQ 2 THEN BEGIN
    IF NOT KEYWORD_SET(ROW) THEN BEGIN
      FOR N = 0L, SZ[1]-1L DO BEGIN
        OK = WHERE(ARRAY(N,*) NE MISSING,COUNT)
        IF COUNT GE 1 THEN COPY(N,OK) = COPY(N,OK) + 1L ;
      ENDFOR
      OK = WHERE(TOTAL(COPY,2) EQ SZ(2),COUNT)
      IF COUNT GE 1 THEN BEGIN
        COPY=ARRAY(OK,*)
      ENDIF ELSE BEGIN
        COPY = -1L
      ENDELSE
    ENDIF ELSE BEGIN

      FOR N = 0L, SZ(2)-1L DO BEGIN
        OK = WHERE(ARRAY(*,N) NE MISSING,COUNT)
        IF COUNT GE 1 THEN COPY(OK,N) = COPY(OK,N) + 1L ;
      ENDFOR
      OK = WHERE(TOTAL(COPY,1) EQ SZ[1],COUNT)
      IF COUNT GE 1 THEN BEGIN
        COPY=ARRAY(*,OK)
      ENDIF ELSE BEGIN
        RETURN,-1L
      ENDELSE
    ENDELSE
  ENDIF ;

    RETURN, COPY
  END ; END OF PROGRAM
