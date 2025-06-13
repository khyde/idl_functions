; $ID:	IMAGE_GRID_INTERPOLATE.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION  image_grid_interpolate, ARR, METHOD=method,MISSING=missing, MIN_VALUE=min_value,MAX_VALUE=max_value
;+
; NAME:
;       image_grid_triangulate
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = image_grid_triangulate(a)
;
; INPUTS:
;
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
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-



  IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(ARR)
  IF N_ELEMENTS(METHOD) NE 1 THEN METHOD = 1
  IF N_ELEMENTS(MIN_VALUE) NE 1 THEN MIN_VALUE = -32766
  IF N_ELEMENTS(MAX_VALUE) NE 1 THEN MAX_VALUE = MAX(ARR)

  S = SIZE(ARR)
  PX=S[1]
  PY=S(2)

  IF METHOD EQ 1 THEN BEGIN
;   ====================>
;   Method 1
    OK = WHERE(arr NE MISSING,COUNT)
    ONE2TWO,OK,[PX,PY],X,Y
    z = ARR[OK]
  ENDIF


  IF METHOD EQ 2 THEN BEGIN
;   ===================>
;   Method 2. FOR SQUARE ARRAYS
;   Triangulate all data and then provide valid data range to trigrid
    OK = REFORM(LINDGEN(PX,PY),N_ELEMENTS(ARR))
    ONE2TWO,OK,[PX,PY],X,Y
    Z = REFORM(ARR,N_ELEMENTS(ARR))
  ENDIF


; ====================>
; Get triangles Tesselation
  TRIANGULATE,x,y,tr,b

;for i = 0, N_ELEMENTS(TR)/3-1 DO BEGIN
;   t = [tr(*,i), tr(0,i)]
;   plots, x(t),y(t)
;endfor


ZZ=TRIGRID(X,Y,Z, TR, [1,1],[0,0,PX,PY], NX=PX,NY=PY, MIN_VALUE= MIN_VALUE, MAX_VALUE=MAX_VALUE,extrapolate =B)


RETURN,ZZ
;contour, z,/OVERPLOT,/cell_fill,/closed,nLEVELS=10
contour,z,x,y,triangulation=tr,/OVERPLOT,/cell_fill,/closed,nLEVELS=10,$
xrange=[-30,30],yrange=[-30,30]

ZWIN
STOP
;   ====================>
;   Enlarge the grid to 1024,1024
;    LCHL = CONGRID(GRID,PX,PY)
;    M = 21
;    LCHL = MEDIAN(LCHL,M)

;   ====================>
;   Make a COPY (CHL) OF LCHL AND A grey_scale_chl image
;    CHL = FLTARR(PX,PY)
;    grey_chl = BYTARR(PX,PY)

END
