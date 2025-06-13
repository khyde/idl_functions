; $ID:	IMAGE_SCALE.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION IMAGE_SCALE, IMAGE, SCALE
;+
; NAME:
; 	IMAGE_SCALE

;		This Program  SCALES (shrinks or enlarges) 2-d image arrays (Single plane images as well as True Color 3-plane image)
;		Nearest Neighbor Method is used, with NO interpolation and NO derived values which are not present in the input IMAGE

; 	MODIFICATION HISTORY:
;
;			Written Aug 3, 2006, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-;

	SZ=SIZE(IMAGE,/STRUCT)
	N_PLANES = SZ.N_DIMENSIONS

	IMAGE1 = IMAGE

	IF N_PLANES EQ 3 THEN BEGIN
		PX = SZ.DIMENSIONS[1]
		PY = SZ.DIMENSIONS(2)
	ENDIF ELSE BEGIN ; 2-D
		PX = SZ.DIMENSIONS[0]
		PY = SZ.DIMENSIONS[1]
	 	N_PLANES = 1
	 	IMAGE1 = REFORM(IMAGE1,N_PLANES,PX,PY)
	ENDELSE

	IF N_ELEMENTS(SCALE) NE 1 THEN _SCALE = 1.0 ELSE _SCALE = FLOAT(SCALE)

	PX_OUT = FIX(PX* _SCALE)
	PY_OUT = FIX(PY* _SCALE)

;	===> Dimension array of same type as input image. If 2d then make first dimension a degenerate dimension of 1
	IMAGE2=MAKE_ARRAY(N_PLANES, PX_OUT,PY_OUT,TYPE=SZ.TYPE)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR PLANE = 0,N_PLANES-1 DO BEGIN
		FOR I = 0,PX_OUT-1 DO BEGIN
	  	FOR J = 0, PY_OUT-1 DO BEGIN
	       IMAGE2(PLANE,I,J) = IMAGE1(PLANE,(I/_SCALE),(J/_SCALE))
	  	ENDFOR
	  ENDFOR
	ENDFOR

  RETURN, REFORM(IMAGE2)
END



