; $Id:	demean.pro,	October 07 2008	$

  FUNCTION DEMEAN, array, $
                   ROW=row, MISSING=missing, DMEAN=dmean
;+
; NAME:
;       DEMEAN
;
; PURPOSE:
;       For each column (or row) of an array,
;       compute the column (or row) values minus the column (or row) mean
;
; CATEGORY:
;       Math
;
; CALLING SEQUENCE:
;       RESULT = DEMEAN(a)
;
; INPUTS:
;       an array of one or more columns
;
; KEYWORD PARAMETERS:
;       ROW:  works on the rows instead of the columns
;   MISSING:  Your code for missing data
;             1)The program sets values equal to your missing code to NAN;
;             2)The NAN's are not used to compute the mean,
;             3)The array returned has NAN's substituted for values
;               you specify as missing.
;		MEAN:			Optional output is the mean
;
; OUTPUTS:
;       An array of same size and type as input.
;
;
; SIDE EFFECTS:
;       The returned array will be float or double
;
;       IF missing code provided then
;       the returned array will have NAN's substuted for any missing values.
;
; RESTRICTIONS:
;       1 or 2 DIMENSIONAL ARRAYS
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly , Feb 24,1999
;-

; ==================>
; Check the size of the input array
  SZ=SIZE(ARRAY)
  IF SZ(0) LT 1 OR SZ(0) GE 3 THEN RETURN,-1 ; Can not handle 0 OR 3 dimensions

	IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(ARRAY)

; ====================>
; Determine the variable type
  type = sz(sz(0)+1)

; ====================>
; Make a copy of the input array
; The copy will be float or double
; This is done so that the !VALUES.F_NAN may be substituted for missing values
; and missing values (NAN) will be ignored in computing the mean.
; IF float or double then retain type
  IF TYPE EQ 4 OR TYPE EQ 5 THEN COPY = ARRAY
; If byte, integer, long then make copy float
  IF TYPE EQ 1 OR TYPE EQ 2 OR TYPE EQ 3 THEN COPY = FLOAT(ARRAY)

; If string then make copy float
  IF TYPE EQ 7 THEN COPY = FLOAT(ARRAY)

; If U_INTEGER, U_LONG OR U_64 then make copy double
  IF TYPE EQ 12 OR TYPE EQ 13 OR TYPE EQ 14 THEN COPY = DOUBLE(ARRAY)

; ===> If Missing code provided then substitute NAN for these values
  bad = WHERE(COPY EQ MISSING,COUNT_MISSING)
  IF COUNT_MISSING GE 1 THEN  copy(bad) = !VALUES.F_NAN



; ====================>
; IF single dimension array
  IF SZ(0) EQ 1 THEN BEGIN
    M = MEAN(COPY ,/NAN)
    COPY = COPY - M
  ENDIF

; ====================>
; IF 2 dimension array
  IF SZ(0) EQ 2 THEN BEGIN
    IF NOT KEYWORD_SET(ROW) THEN BEGIN
      FOR N = 0L, SZ(1)-1L DO BEGIN
        M = MEAN(COPY(N,*),/NAN)
        COPY(N,*) = COPY(N,*)-M
      ENDFOR
    ENDIF ELSE BEGIN
      FOR N = 0L,SZ(2)-1L DO BEGIN
        M = MEAN(COPY(*,N),/NAN)
        COPY(*,N) = COPY(*,N)-M
      ENDFOR
    ENDELSE
  ENDIF ;  IF SZ(0) EQ 2 THEN BEGIN

  DMEAN=M
  RETURN, COPY

  END ; END OF PROGRAM
