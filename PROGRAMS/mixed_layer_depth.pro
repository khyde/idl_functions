; $ID:	MIXED_LAYER_DEPTH.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION MIXED_LAYER_DEPTH, DEPTH=depth, SIGMAT=SIGMAT, MAX_DEPTH=MAX_DEPTH, ERROR=error, ERR_MSG=err_msg
;+
; NAME:
; 	MIXED_LAYER_DEPTH

;		This program determines the mixed layer depth based on the Levutys density criteria where:
;		  MLD = depth where sigma-t has increased by 0.125 from the near surface value (surface sigma_t+0.125)
;
; INPUTS:
;   	DEPTH:				Depth (meters)
;			SIGMAT:		  	Sigma T (kg/m^3)
;			MAX_DEPTH:		The station depth
;			TITLE:				Title for figure
;			XRANGE:				XRANGE for figure
;			YRANGE:				YRANGE for figure

; OUTPUTS:
;   MIXED_LAYER_DEPTH       FLOAT              	15.45									Depth of the mixed layerd calculation
;
;		KEYWORDS
;

; MODIFICATION HISTORY:
;		Written Dec 5, 2005 by Kimberly J.W. Hyde
;		Modified:
;		 JUN 16, 2017 - KJWH: Changed SIGMA_T to SIGMAT to avoid conflicts with the SIGMA_T function
;
;-

	ROUTINE_NAME='MIXED_LAYER_DEPTH'
	PAL_36
	XSTYLE =2
	ERROR = 0
	ERR_MSG = ''
	DIF		= 0.125			; Maximum difference within the mixed layer

	IF N_ELEMENTS(TITLE) EQ 1 THEN _TITLE = TITLE ELSE _TITLE = ''
	IF N_ELEMENTS(XRANGE) EQ 2 THEN _XRANGE = XRANGE ELSE _XRANGE = MISSINGS(32767)
	IF N_ELEMENTS(YRANGE) EQ 2 THEN _YRANGE = YRANGE ELSE _YRANGE = MISSINGS(32767)

	
; ===> Check to make sure the number of depths equals the number of temperatures
	IF N_ELEMENTS(DEPTH) NE N_ELEMENTS(SIGMAT) THEN BEGIN
		ERROR = 1
		ERR_MSG = 'Unequal_depths'
		PRINT, 'Number of depths does not equal the number of temperature measurements'
		RETURN, []
	ENDIF

;	===> Find good data
	OK = WHERE(SIGMAT NE MISSINGS(SIGMAT) AND DEPTH NE MISSINGS(DEPTH),COUNT)
	IF COUNT EQ 0 THEN BEGIN
		ERROR = 1
		ERR_MSG = 'Missing_data'
		PRINT, 'MISSING density and depth data'
		RETURN, []
	ENDIF

	_DEPTH 				= DEPTH[OK]
	_SIGMA			  = SIGMAT[OK]
	
;	===> Make sure there is sufficient data
	IF N_ELEMENTS(_DEPTH) LE 3 THEN BEGIN
		ERROR = 1
		ERR_MSG = 'Insuf_data'
		PRINT, 'Must have more than 3 data points'
		RETURN, []
	ENDIF

; ===> Sort data by depth
	SRT 		= SORT(_DEPTH)
	_DEPTH 	= _DEPTH(SRT)
	_SIGMA 	= _SIGMA(SRT)

; ===> Make sure min depth is less than 3 meters
	IF MIN(_DEPTH) GT 3 THEN BEGIN
		ERROR = 1
		ERR_MSG = 'Deep_MIN_depth'
		PRINT, 'MIN depth  > 3 meters'
	;	RETURN, []
	ENDIF

	SURF 	= _SIGMA[0]				; Surface density
	DMAX	= SURF+DIF					; Max density difference within mixed layer (0.125)
	OK = WHERE(_SIGMA LE DMAX,COUNT)
	IF COUNT GE 1 THEN BEGIN
		RETURN, INTERPOL(_DEPTH,_SIGMA,DMAX)
	ENDIF ELSE BEGIN
		ERROR = 1
		ERR_MSG = 'No_mixed_depth'
		PRINT, 'ERROR NO MIXED DEPTH FOUND'
		RETURN, []
	ENDELSE


END; #####################  End of Routine ################################




