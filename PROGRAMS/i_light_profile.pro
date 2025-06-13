; $ID:	I_LIGHT_PROFILE.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION I_LIGHT_PROFILE, DEPTH=DEPTH,CHL =CHL , Z_THICK=z_thick
;+
; NAME:
;       I_LIGHT_PROFILE
;
; PURPOSE:
;				Compute the mean light intensity (Fraction of 1.0) based on light extinction coefficient (k m-1) and Depth (Z meters)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 23,2004
;-

ROUTINE_NAME='I_LIGHT_PROFILE'

;	===> Number of Layers
	IF N_ELEMENTS(Z_THICK) NE 1 THEN _Z_THICK = 0.01 ELSE _Z_THICK = Z_THICK

;	===> pure water absorption (m-1) [Kw=0.04]
  Kw=0.04 ; (m-1)

; ===> Kx Absorption by 'other' (m-1) [Kx = 0.02]
	Kx = 0.02

;_K = DOUBLE(K)
;_Z = DOUBLE(Z)
;
;IF N_ELEMENTS(K) EQ 1 AND N_ELEMENTS(Z) GT 1 THEN _K=REPLICATE(K,N_ELEMENTS(Z)) ELSE _K = K
;IF N_ELEMENTS(Z) EQ 1 AND N_ELEMENTS(K) GT 1 THEN _Z=REPLICATE(Z,N_ELEMENTS(K)) ELSE _Z = Z
;
;_K = DOUBLE(_K)
;_Z = DOUBLE(_Z)
;OK=WHERE(_K GT 0,COUNT)
;IF COUNT GE 1 THEN _K[OK] = -1*_K[OK]
;
;a = _K*_Z
;fraction= -1*((1.0D - EXP(a))/a) ;

	MAX_ZEU = 200; M
;	===> Layer Thickness
	IF N_ELEMENTS(Z_THICK) NE 1 THEN Z_THICK = 0.01 ; (m)

	N_LAYERS = LONG(MAX_Zeu/Z_THICK)+1
	ZZ = FINDGEN(N_LAYERS)*Z_THICK

;	*******************************************************
;	*** I N T E R P O L A T E    C H L O R O P H Y L L  ***
;	*******************************************************
	CHL_PROFILE= INTERP_XTEND(DEPTH,CHL, ZZ, X_MISSING = x_missing,Y_MISSING=y_missing,MAKE_MISSING=make_missing,ERROR=error)

	ABS_CHL    =
;+

STOP
;		===> Calculate chlorophyll concentration profile for the Middle of each layer: ZMID_PROFILE
; 		CHL_PROFILE 	=	chl_sat(nth) +(h/sig/SQRT(2*!DPI))*EXP(-((ZMID_PROFILE)-zm)^2/2/sig^2)/y ;

;		===> Calculate KPAR_PROFILE from CHL_PROFILE plus extinction coefficients for water and 'other'
		KPAR_PROFILE	=	kw +kx + kc*CHL_PROFILE.Y ;

; 	===> Fraction of Surface Light at the top of each layer
 		LIGHT_FRACT_TOP	= EXP(KPAR_PROFILE[0]*Z_THICK 		+ TOTAL(-1.0D*KPAR_PROFILE*Z_THICK,/CUMULATIVE,/DOUBLE))

;;;	===> Fraction of Surface Light at the middle of each layer (NOT USED)
;; 	LIGHT_FRACT_MID = EXP(KPAR_PROFILE[0]*Z_THICK*0.5 + TOTAL(-1.0D*KPAR_PROFILE*Z_THICK,/CUMULATIVE,/DOUBLE))

; 	===> Fraction of Surface Light at the bottom of each layer:
 		LIGHT_FRACT_BOT	= EXP(         											TOTAL(-1.0D*KPAR_PROFILE*Z_THICK,/CUMULATIVE,/DOUBLE))

;		===> MEAN Fraction of Surface Light for each layer
;				(Light_fraction_mean values are slightly greater than values at the middle of each layer)
		aa = -KPAR_PROFILE* Z_THICK
		LIGHT_FRACT_MEAN = -1*LIGHT_FRACT_TOP*((1.0d - EXP(aa))/aa)

;		===> Calculate PAR profile (Einsteins m-2 d-1) for each layer)
		PAR_PROFILE = PAR_SAT[NTH]*LIGHT_FRACT_MEAN

;  	===> Find the layers within the euphotic zone (The deepest layer found with WHERE will contain the 0.01 value within that layer)
	 	OK=WHERE(LIGHT_FRACT_TOP GT 0.01,COUNT)
	 	INDEX_Zmax =  (0L > (COUNT-1) ) ;


;		===> Determine Zmax, the depth at the bottom of the deepest layer found within the euphotic zone
	 	Zmax = ZBOT_PROFILE(INDEX_Zmax)
	 	Zeu(nth)  = Zmax


; 	===> If Bottom Depth is provided then make Zmax the lesser of Zeu and Bottom Depth and recompute the INDEX_Zmax
		IF CHECK_BOTTOM EQ 1 THEN BEGIN
			IF BOTTOM_DEPTH(nth) LT Zmax THEN BEGIN
				BOTTOM_FLAG(nth) = 1
				OK=WHERE(ZBOT_PROFILE LE BOTTOM_DEPTH(nth),COUNT)
	 			INDEX_Zmax= 0L > (COUNT-1)   ; do not allow any -1 subscripts
	 			Zmax = ZBOT_PROFILE(INDEX_Zmax)
	 			Zeu(nth)  = Zmax
			ENDIF
		ENDIF

;		===> Compute Euphotic K_PAR (from surface to 1% depth, or Bottom Depth if less than 1% light depth
		K_PAR[NTH] = -ALOG(LIGHT_FRACT_BOT(INDEX_Zmax))/ZBOT_PROFILE(INDEX_Zmax)

END; #####################  End of Routine ################################



