; $ID:	STABILITY.PRO,	2020-06-26-15,	USER-KJWH	$

 FUNCTION STABILITY, DEPTH=DEPTH,SIG=SIG, Z=Z
;+
; NAME:
; 	STABILITY

;		This Program Computes Stability (sigma_40)
;		OUTPUT: A structure
;			Z0 The uppermost depth
;			ZA The depth Above the interpolated sig
;			ZI The depth of the interpolated sig
;			ZB The depth Below the interpolated sig
;			SIG0 The sigmat at the uppermost depth
;			SIGA The sigmat at the depth Above the interpolated sigmat
;			SIGI The sigmat at the interpolated depth
;			SIGB The sigmat at the depth Below the interpolated sigmat
;
;

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='STABILITY'
	ERROR = 0
	IF N_ELEMENTS(Z) NE 1 THEN _Z = 40 ELSE _Z = Z

;	===> Sort Depth
	s=SORT(DEPTH)
	DEPTH=DEPTH(S)
	SIG=SIG(S)


	Z0= FIRST(DEPTH)
	ZI  = _Z < LAST(DEPTH)
	SIG0=FIRST(SIG)
	SIGI= LAST(INTERP_XTEND(DEPTH,SIG, [0,ZI], XTEND=XTEND, MAKE_MISSING=make_missing,ERROR=error))
	OK=WHERE(DEPTH LT _Z,COUNT)
	IF COUNT GE 1 THEN BEGIN
		ZA = LAST(DEPTH[OK])
		SIGA = LAST(SIG[OK])
	ENDIF ELSE BEGIN
		ZA= -1
		SIGA = MISSINGS(SIG)
	ENDELSE

	OK=WHERE(DEPTH GE _Z,COUNT)
	IF COUNT GE 1 THEN BEGIN
		ZB = FIRST(DEPTH[OK])
		SIGB = FIRST(SIG[OK])
	ENDIF ELSE BEGIN
		ZB = -1
		SIGB = MISSINGS(SIG)
	ENDELSE

	DSIG = SIGI-SIG0

	RETURN,CREATE_STRUCT('Z0',Z0,'ZA',ZA,'ZI',ZI,'ZB',ZB,'SIG0',SIG0,'SIGA',SIGA,'SIGI',SIGI,'SIGB',SIGB,'DSIG',DSIG)

END; #####################  End of Routine ################################



