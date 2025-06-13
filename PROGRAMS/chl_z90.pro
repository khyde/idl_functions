; $ID:	CHL_Z90.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION CHL_Z90, DEPTH=depth, CHL=CHL, KD_Z90=KD_Z90, Z_90=Z_90,ERROR=error
;+
; NAME:
; 	CHL_Z90

;		This Program Calculates the Optically-Weighted Chlorophyll concentration in the upper optical depth according to
;		Gordon and Clark, 1980,	approximating the chlorophyll concentration registered by passive remote sensing
;
; INPUTS:
;   	DEPTH:		Depth (meters)
;			CHL:			Chlorophyll profile measurements
;			KD_Z90		Extinction coefficient for the upper water column (calculated in LIGHT_EXTINCTION_COEFFICIENT.PRO)
;			Z90:			Depth of the first optical depth - the depth of 90% of the signal received by the satellite (calculated in LIGHT_EXTINCTION_COEFFICIENT.PRO)

; OUTPUTS:
;				Structure Containing:
;   N               LONG                29										Number of chlorophyll-depth measurements
;		N_Z90						LONG								3											Number of chlorophyll-depth measurements within the Z90
;		C_Z90						FLOAT								1.45									Interpolated chlorophll value at depth Z90
;		WT_CHL					FLOAT								2.33									Weighted chlorophyll a concentration
;		ERROR_Z90				STRING							''										Errors in Z90 or weighted calculation
;
;		KEYWORDS
;
;

; MODIFICATION HISTORY:
;		Written Jan 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;		(Based on code from J.Werdell)
;		Modified March 11, 2005 by K. Hyde ===> added return structure and included plotting option
;		Modified March 18, 2005 by K. Hyde ===> removed plotting option
;		Modified November 29, 2006 by K. Hyde ===> adjusted INTERP_EXTEND to work with the new version, which returns a structure
;-

	ROUTINE_NAME='CHL_Z90'

	ERROR = 0
	ES = 100.0 ; surface % light

	NEW = CREATE_STRUCT('N',0L,'N_Z90',0L,'Z90',0.0,'WCHL',0.0,'ERROR_Z90','','Z90_CHL',0.0)
	NEW = STRUCT_2MISSINGS(NEW)

; ===> Check to make sure the number of depths equals the number of chlorophylls
	IF N_ELEMENTS(DEPTH) NE N_ELEMENTS(CHL) THEN BEGIN
		NEW.ERROR_Z90 = 'Unequal_depths'
		PRINT, 'Number of depths does not equal the number of chlorophyll measurements'
		RETURN, NEW
	ENDIF

; ===> Check to make sure Kd_Z90 is provided
	IF N_ELEMENTS(KD_Z90) NE 1 AND N_ELEMENTS(Z_90) NE 1 THEN BEGIN
		NEW.ERROR_Z90 = 'Missing_Kd'
		PRINT, 'MISSING Kd'
		RETURN, NEW
	ENDIF

;	===> If Z90 not provided then estimate it from 1.0/kd
	IF N_ELEMENTS(Z_90) NE 1 THEN _Z90 = 1.0/KD_Z90 ELSE _Z90 = Z_90
	IF _Z90 EQ MISSINGS(_Z90) THEN _Z90 = 1.0/KD_Z90
	NEW.Z90 = _Z90

;	===> Find good data
	OK = WHERE(CHL NE MISSINGS(CHL) AND DEPTH NE MISSINGS(DEPTH),COUNT)
	IF COUNT EQ 0 THEN BEGIN
		NEW.ERROR_Z90 = 'Missing_data'
		PRINT, 'MISSING chlorophyll and depth data'
		RETURN, NEW
	ENDIF

	_DEPTH 				= DEPTH[OK]
	_CHL_PROFILE  = CHL[OK]
	NEW.N 				= N_ELEMENTS(_DEPTH)

; ===> If only one point, make sure the depth is less than Z90, then just return the chl
	IF COUNT EQ 1 THEN BEGIN
		IF _DEPTH LE _Z90 THEN BEGIN
			NEW.WCHL = _CHL_PROFILE[0]
			NEW.ERROR_Z90 = '1_chl'
			PRINT, 'Only 1 valid chlorophyll measurement'
			RETURN, NEW
		ENDIF ELSE BEGIN
			NEW.ERROR_Z90 = 'Deep_chl'
			PRINT, 'Minimum depth is greater than the Z90 depth'
		 	RETURN, NEW
		ENDELSE
	ENDIF

; ===> Make sure there is at least one depth above Z90
	OK = WHERE(_DEPTH LE _Z90,COUNT)
	IF COUNT EQ 0 THEN BEGIN
		NEW.ERROR_Z90 = 'Deep_chl'
		PRINT, 'Minimum depth is greater than the Z90 depth'
		RETURN, NEW
	ENDIF
	IF COUNT GE 1 THEN NEW.N_Z90 = COUNT

;	===> Sort _DEPTH and _CHL_PROFILE
	SRT 		= SORT(_DEPTH)
	_DEPTH 	= _DEPTH(SRT)
	_CHL_PROFILE = _CHL_PROFILE(SRT)


;	***********************************************************************************
;	If zero depth not present then add it and assume that the chlorophyll at 0m is
;	identical to the uppermost chlorophyll value present in the profile and
; interpolate the Z90 depth


	OK = WHERE(_DEPTH EQ 0,COUNT0)		
	OK = WHERE(_DEPTH EQ _Z90,COUNT90)
	IF COUNT0 EQ 1 AND COUNT90 EQ 1 THEN GOTO, SKIP_INTER_XTEND
	XX = [0,_Z90]	
	YY = INTERP_XTEND(_DEPTH,_CHL_PROFILE, XX, X_MISSING=0.0, Y_MISSING=0.0, ERROR=error)
	_CHL_PROFILE 	= [_CHL_PROFILE, YY.Y]
	_DEPTH 				= [_DEPTH, XX]
	SKIP_INTER_XTEND:

;	===> Sort _DEPTH and _CHL_PROFILE again
	SRT 					= SORT(_DEPTH)
	_DEPTH 				= _DEPTH(SRT)
	_CHL_PROFILE 	= _CHL_PROFILE(SRT)
	OK = WHERE(_DEPTH EQ _Z90[0],COUNT)
		IF COUNT EQ 1 THEN NEW.Z90_CHL = _CHL_PROFILE[OK] ELSE RETURN, NEW

;	===> Calculate Percent Light for each DEPTH
	PCT_LIGHT = EXP(ALOG(ES) - KD_Z90 * _DEPTH)

;	===> Calculate Weights
 	WEIGHTS   = (PCT_LIGHT/ES)^2 ;

;	===> Calculate Weighted Chlorophyll
 	CHL_WEIGHTED	=	_CHL_PROFILE * WEIGHTS


;	===> Find the _DEPTH equal to the _Z90 and integrate (TOTAL) the array elements down to the Z_90 depth
	OK = WHERE(_DEPTH EQ _Z90,COUNT)
	IF COUNT EQ 1 THEN BEGIN
		ZZ =INDGEN(OK[0]+1)
		NEW.WCHL = TOTAL(CHL_WEIGHTED(ZZ)) / TOTAL(WEIGHTS(ZZ))
		NEW.ERROR_Z90 = '0'
		RETURN, NEW
	ENDIF ELSE BEGIN
		PRINT,'ERROR: No Z90 depth found'
		NEW.ERROR_Z90 = 'No_Z90'
		RETURN, NEW
	ENDELSE

;	===> Return the Optically-Weighted Chlorophyll Concentration
  RETURN,NEW

END; #####################  End of Routine ################################




