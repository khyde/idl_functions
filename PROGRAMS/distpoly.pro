; $ID:	DISTPOLY.PRO,	2020-07-08-15,	USER-KJWH	$
  FUNCTION distpoly, XARRAY,YARRAY, coeffs, mp=mp
;+
; NAME:
;       distpoly
;
; PURPOSE:
;       Compute Perpendicular distances of points from a polynomial curve
;
; CATEGORY:
;       Geometry
;
; CALLING SEQUENCE:
;       Result = distpoly(1,1,1,1)
;
; INPUTS:
;       Individual x,y or matched arrays of x,y and the
;       Y-Intercept and slope of a line (e.g. regression line)
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       Perpendicular distances of x,y coordinates from the polynomial curve
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
;       Written by:  J.E.O'Reilly,
;-

; ===================>
; Check parameters
  IF N_PARAMS() NE 3 THEN MESSAGE,'ERROR, MUST PROVIDE X,Y, polynomial coefficients'
  IF N_ELEMENTS(XARRAY) NE N_ELEMENTS(YARRAY) THEN MESSAGE,'ERROR X AND Y ARRAYS MUST BE SAME SIZE'
  IF N_ELEMENTS(MP) NE 1 THEN _MP = 0 ELSE _MP = 1
  _DEG = N_ELEMENTS(COEFFS) -1
  IF _MP EQ 1 THEN _DEG = _DEG+1

  A=COEFFS
  RX=interval([-1,alog10(20)],BASE=10, 0.0005)



  IF _DEG EQ 0 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0]*ALOG10(rx))
   IF _DEG EQ 0 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0]*ALOG10(rx)) +a[1]

   IF _DEG EQ 1 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx))
   IF _DEG EQ 1 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx)) +a(2)

   IF _DEG EQ 2 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2)
   IF _DEG EQ 2 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2) + a(3)

   IF _DEG EQ 3 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3)
   IF _DEG EQ 3 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3)+a(4)

   IF _DEG EQ 4 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4)
   IF _DEG EQ 4 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4)+a(5)

   IF _DEG EQ 5 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5)
   IF _DEG EQ 5 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5)+a(6)

   IF _DEG EQ 6 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5 +a(6)*ALOG10(rx)^6)
       IF _DEG EQ 6 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5 + a(6)*ALOG10(rx)^6) +a(7)

   IF _DEG EQ 7 AND _MP EQ 0 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5 + a(6)*ALOG10(rx)^6 + a(7)*ALOG10(rx)^7)
       IF _DEG EQ 7 AND _MP EQ 1 THEN $
    MODEL = 10.0^(a[0] + a[1]*ALOG10(rx) + a(2)*ALOG10(rx)^2 + a(3)*ALOG10(rx)^3 + a(4)*ALOG10(rx)^4 + a(5)*ALOG10(rx)^5 + a(6)*ALOG10(rx)^6 + a(7)*ALOG10(rx)^7) +a(8)

  DIST_MIN=FLTARR(N_ELEMENTS(XARRAY))


  FOR N=0,N_ELEMENTS(XARRAY)-1L DO BEGIN
   X=XARRAY(N)
   Y=YARRAY(N)
   DIST_X = ALOG10(RX) - ALOG10(X)
   DIST_Y = ALOG10(MODEL) - ALOG10(Y)
   DIST_XY = (DIST_X^2 + DIST_Y^2)  ; DO SQUARED DISTANCE
   DIST_MIN(N) = MIN(DIST_XY)
  ENDFOR


  RETURN, DIST_MIN
  END
