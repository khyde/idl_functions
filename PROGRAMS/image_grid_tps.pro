; $ID:	IMAGE_GRID_TPS.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION  image_grid_tps, ARR, METHOD=method, MISSING=missing

;+
; NAME:
;       image_grid_min_curve_surf.pro
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = image_grid_min_curve_surf(arr)
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
;       Written by:  J.E.O'Reilly, Jan, 2000.
;-



  IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(ARR)
  IF N_ELEMENTS(METHOD) NE 1 THEN METHOD = 1


; SHRINK ARRAY BY FACTOR OF 2
  ARR = REBIN(ARR,256,256,/SAMPLE)


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
;
 ZZ = GRID_TPS(x, y, z, NGRID=[PX, PY], START=[0,0], DELTA=[1,1])


 return, ZZ


RETURN,ZZ

END
