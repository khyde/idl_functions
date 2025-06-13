; $ID:	PROFILE_INTEGRATION.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION PROFILE_INTEGRATION, VAR=VAR, DEPTH=DEPTH, MAX_DEPTH=MAX_DEPTH, KD_Z90=KD_Z90, Z_90=Z_90, Z90_CHL=Z90_CHL, INT_Z=INT_Z, SHOW=SHOW, XRANGE=XRANGE, YRANGE=YRANGE, TITLE=TITLE, XTITLE=XTITLE, BUFFER=BUFFER,  PNGFILE=PNGFILE, EXTRA=EXTRA, LABEL=LABEL, _EXTRA=_EXTRA
;+
; NAME:
; 	PROFILE_INTEGRATION

;		This Program Calculates the integrated value of profile data (chlorophyll, nitrogen, etc.) for a given depth and can calculate
;		the Optically-Weighted Chlorophyll concentration in the upper optical depth according to
;		Gordon and Clark, 1980,	approximating the chlorophyll concentration registered by passive remote sensing
;
; INPUTS:
;   	DEPTH:				Depth (meters)
;			VAR:					Profile measurements (chlorophyll, nitrogen, etc.)
;			KD_Z90				Extinction coefficient for the upper water column (calculated in LIGHT_EXTINCTION_COEFFICIENT.PRO)
;			Z90:					Depth of the first optical depth - the depth of 90% of the signal received by the satellite (calculated in LIGHT_EXTINCTION_COEFFICIENT.PRO)
;			MAX_DEPTH:		Maximum integration depth (maximum depth, euphotic depth, mixed layer depth)
;			TITLE:				Title for Plot (if /SHOW)
;			INT_Z:				Maximum depth for integration (used to calculate INTEGRATED_Z)

; OUTPUTS:
;				Structure Containing:
;   N               LONG                29										Number of chlorophyll-depth measurements
;		MAX_DEPTH				FLOAT								12.2									Maximum depth for integration
;		DEPTH_CODE			''									INT										Method used to determine C_Zeu (INTERPOLATION or EXTENDED)
;		X_MAX_DEPTH			STRING							0.45									X varialbe concentration at the maximum depth (either integrated or extended down from the previous measurement)
;		INTEGRATED_X		FLOAT								1.36									Areal chlorophyll (mg/m^2)
;		INTEGRATED_Z		FLOAT								1.33									Areal chlorophyll (mg/m^2) integrated to a given depth (e.g. Zeu)
;		ERROR_X					STRING							''										Errors in euphotic or areal chlorophyll calculation
;		N_Z90						LONG								3											Number of chlorophyll-depth measurements within the Z90
;		C_Z90						FLOAT								1.45									Interpolated chlorophll value at depth Z90
;		WT_CHL					FLOAT								2.33									Weighted chlorophyll a concentration
;		ERROR_Z90				STRING							''										Errors in Z90 or weighted calculation

;
;		KEYWORDS
;				SHOW:				Show Plot and Print Results
;				Z90_CHL:		Do optically weighted chlorophyll calculation
;

; MODIFICATION HISTORY:
;		Written Jan 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;		(Based on code from J.Werdell)
;		Modified March 11, 2005 by K. Hyde ===> added return structure and included plotting option
;		Modified March 18, 2005 by K. Hyde ===> added areal chlorophyll calculation
;																			 ===> added Z90_CHL KEYWORD so that if set, it will call the CHL_Z90 program and calculate the weighted chlorophyll
;																			 ===> replaced chlorophyll with X so that other variables such as nitrogen can be inputed
;		Modified April 1, 2005 by  K. Hyde ===> added XRANGE and YRANGE variables
;		Modified November 29, 2006 by K. Hyde ===> adjusted INTERP_EXTEND to work with the new version, which returns a structure
;-

	ROUTINE_NAME='PROFILE_INTEGRATION'

	IF N_ELEMENTS(TITLE) EQ 1 THEN _TITLE = TITLE ELSE _TITLE = ''
	IF N_ELEMENTS(XTITLE) EQ 1 THEN _XTITLE = XTITLE ELSE _XTITLE = ''
	IF N_ELEMENTS(XRANGE) EQ 2 THEN _XRANGE = XRANGE ELSE _XRANGE = MISSINGS(32767)
	IF N_ELEMENTS(YRANGE) EQ 2 THEN _YRANGE = YRANGE ELSE _YRANGE = MISSINGS(32767)
	IF N_ELEMENTS(LABEL) EQ 1 THEN _LABEL = LABEL ELSE _LABEL = 'x'
	IF N_ELEMENTS(INT_Z) EQ 1 THEN _INT_Z = INT_Z ELSE _INT_Z = MAX(DEPTH)

	STRUCT = CREATE_STRUCT('N',0L,'VARIABLE','','DEPTH','','MAX_DEPTH',0.0,'X_MAX_DEPTH',0.0,'DEPTH_CODE','','INTEGRATED_X',0.0,'INTEGRATED_Z',0.0,'X_INT_Z',0.0,$
												'ERROR_X','','N_Z90',0L,'Z90',0.0,'WCHL',0.0,'Z90_CHL',0.0,'ERROR_Z90','')
	STRUCT = STRUCT_2MISSINGS(STRUCT)

; ===> Check to make sure the number of depths equals the number of chlorophylls
	IF N_ELEMENTS(DEPTH) NE N_ELEMENTS(VAR) THEN BEGIN
		STRUCT.ERROR_X = 'Unequal_depths'
		PRINT, 'Number of depths does not equal the number of chlorophyll measurements'
		RETURN, STRUCT
	ENDIF

	OK = WHERE(DEPTH NE MISSINGS(0.0),COUNT)
	IF COUNT GE 1 THEN BEGIN
		_DEPTH = DEPTH[OK]
		_VAR		 = VAR[OK]
		VORG    = VAR ; Original variable points for plotting
		DORG    = DEPTH ; Original depth points for plotting
	ENDIF

;	***********************************************************************************
;	If zero depth not present then add it and assume that the chlorophyll at 0m is
;	identical to the uppermost chlorophyll value present in the profile

	OK = WHERE(_DEPTH EQ 0,COUNT)
	IF COUNT EQ 0 THEN BEGIN
		XX = 0
		YY = INTERP_XTEND(_DEPTH,_VAR, XX, X_MISSING=0.0, Y_MISSING=0.0, ERROR=error)
		_VAR 			= [_VAR, YY.Y]
		_DEPTH 		= [_DEPTH, XX]
	ENDIF

;	===> Sort _DEPTH and _CHL_PROFILE again
	SRT 				= SORT(_DEPTH)
	_DEPTH 			= _DEPTH(SRT)
	_VAR				= _VAR(SRT)

;	*****************************************************************************************************
	IF KEYWORD_SET(Z90_CHL) THEN BEGIN				; Calculate optically weighted chlorophyll at the Z90 depth
;	*****************************************************************************************************
		DEPTH 		= _DEPTH
		CHL				= _VAR
		IF N_ELEMENTS(KD_Z90) EQ 1 OR N_ELEMENTS(Z_90) EQ 1 THEN BEGIN
			NEW = CHL_Z90(DEPTH=depth,CHL=CHL,KD_Z90=kd_Z90,Z_90=Z_90,ERROR=error)
			STRUCT.N_Z90 			= NEW.N_Z90
			STRUCT.WCHL				= NEW.WCHL
			STRUCT.ERROR_Z90	= NEW.ERROR_Z90
			STRUCT.Z90				= NEW.Z90
			STRUCT.Z90_CHL		= NEW.Z90_CHL
		ENDIF ELSE BEGIN
			STRUCT.ERROR_Z90	= 'Missing_Kd'
			PRINT, 'MISSING Kd_Z90'
		ENDELSE
	ENDIF
; *****************************************************************************************************
; *****************************************************************************************************

; ===> Check to make sure Max_depth is provided
	IF N_ELEMENTS(MAX_DEPTH) NE 1 OR MAX_DEPTH EQ MISSINGS(0.0) THEN BEGIN
		STRUCT.MAX_DEPTH 	= MISSINGS(0.0)
		STRUCT.ERROR_X		= 'Missing_Max_Depth'
		PRINT, 'Missing max depth input'
		GOTO, PLOT
	ENDIF ELSE _MAX_DEPTH = MAX_DEPTH
	STRUCT.MAX_DEPTH = _MAX_DEPTH

; ===> Check to see if profile has at least 3 depths
	IF N_ELEMENTS(DEPTH) LE 2 THEN BEGIN
		STRUCT.ERROR_X		= 'Depths_LE_2'
		PRINT, 'Need at least 3 measured values'
		GOTO, PLOT
	ENDIF

	IF STRUCT.MAX_DEPTH NE MISSINGS(0.0) THEN BEGIN
		OK = WHERE(_DEPTH EQ _MAX_DEPTH,COUNT)
		IF COUNT EQ 1 THEN 	STRUCT.X_MAX_DEPTH = _VAR[OK]
		IF COUNT EQ 0 THEN BEGIN
			XX = _MAX_DEPTH
			YY = INTERP_XTEND(_DEPTH,_VAR, XX, X_MISSING=0.0, Y_MISSING=0.0, ERROR=error)
			STRUCT.X_MAX_DEPTH = YY.Y
			_VAR		 	= [_VAR, YY.Y]
			_DEPTH 		= [_DEPTH, XX]
		ENDIF

		SRT 			= SORT(_DEPTH)													;	===> Sort _DEPTH and _CHL_PROFILE again
		_DEPTH 		= _DEPTH(SRT)
		_VAR		 	= _VAR(SRT)

;	===> Trapezoidal integration
		STRUCT.INTEGRATED_X 			= TSUM(_DEPTH,_VAR)
		STRUCT.ERROR_X 						= ''

; ===> Trapezoidal integration to specified depth INT_Z
		_DEPTHZ		= _DEPTH
		_VARZ			= _VAR
		OK = WHERE(_DEPTH EQ _INT_Z,COUNT)
		IF COUNT EQ 1 THEN 	STRUCT.X_INT_Z = _VAR[OK]
		IF COUNT EQ 0 THEN BEGIN
			XX = _INT_Z
			YY = INTERP_XTEND(_DEPTH,_VAR, XX, X_MISSING=0.0, Y_MISSING=0.0,  ERROR=error)
			STRUCT.X_INT_Z = YY.Y
			_VARZ		 	= [_VAR, YY.Y]
			_DEPTHZ		= [_DEPTH, XX]
		ENDIF

		OK = WHERE(_DEPTHZ LE _INT_Z,COUNT)
		IF COUNT GE 2 THEN BEGIN
			_DEPTHZ 	= _DEPTHZ[OK]
			_VARZ   	= _VARZ[OK]
			SRT 			= SORT(_DEPTHZ)													;	===> Sort _DEPTH and _CHL_PROFILE again
			_DEPTHZ		= _DEPTHZ(SRT)
			_VARZ		 	= _VARZ(SRT)

;	===> Trapezoidal integration
			STRUCT.INTEGRATED_Z 			= TSUM(_DEPTHZ,_VARZ)
		ENDIF

	ENDIF ELSE STRUCT.ERROR_X = 'No_integrated_variable'
	STRUCT.VARIABLE = STRJOIN(_VAR,',')
	STRUCT.DEPTH    = STRJOIN(_DEPTH,',')

PLOT:
; ********************************************************************************
	IF KEYWORD_SET(SHOW) THEN BEGIN  ; Plot Chlorophyll profile and Weight chl *****
;	********************************************************************************

; Plot Z90 data	
			PRINT, _TITLE
			X 			= _VAR
			Y	 			= _DEPTH*(-1)
			IF _XRANGE[0] NE MISSINGS(32767) THEN _XRANGE=_XRANGE ELSE _XRANGE 	= NICE_RANGE([0,MAX(X)])
			IF _YRANGE[0] NE MISSINGS(32767) THEN _YRANGE=_YRANGE ELSE _YRANGE	= NICE_RANGE([MIN(Y),0])
      
      W = WINDOW(DIMENSIONS=[650,500],BUFFER=BUFFER)
			PT = PLOT(_VAR,-1*_DEPTH,XRANGE=_XRANGE,YRANGE=_YRANGE,XSTYLE=XSTYLE,XTITLE=XTITLE,YTITLE='Depth (m)',TITLE=_TITLE,/NODATA,POSITION=[60,70,490,450],/DEVICE,/CURRENT)
			PLI = PLOT(_VAR,-1*_DEPTH,SYMBOL='TRIANGLE',COLOR='BLUE',THICK=3, SYM_SIZE=2,/OVERPLOT,LINESTYLE=2,CLIP=0,NAME=' Interpolated') ; Interpolated and extended data
			PLO = PLOT(VORG,-1*DORG,SYMBOL='CIRCLE',COLOR='BLUE',/SYM_FILLED,THICK=3, SYM_SIZE=1.5,/OVERPLOT,NAME=' Original')
			L  = LEGEND(TARGET=[PLO,PLI],POSITION=[495,425],/DEVICE,HORIZONTAL_ALIGNMENT=0,SHADOW=0,FONT_SIZE=12,SAMPLE_WIDTH=0.2,TRANSPARENCY=100) 
  		
  	IF STRUCT.ERROR_Z90 EQ '0' AND STRUCT.ERROR_X NE '' THEN BEGIN	
  		Z       = STRUCT.Z90*(-1)
  	  W       = STRUCT.WCHL
  		PL = PLOT(_XRANGE,[Z,Z],LINESTYLE=1, THICK = 2,/OVERPLOT)
			PL = PLOT([W,W],[0.0,Z],LINESTYLE=2,COLOR='RED',THICK=3,/OVERPLOT)
			TXT=   'No areal calculation: ' + '!C    ' + STRUCT.ERROR_X
			TX = TEXT(0.1,0.95 ,TXT,/DEVICE,COLOR='BLACK',FONT_SIZE=10.0)
stop			
		ENDIF

	; Plot Integrated data
		IF STRUCT.ERROR_X EQ '' AND STRUCT.ERROR_Z90 NE '0' THEN BEGIN
			Z 			= _MAX_DEPTH*(-1)
			C 			= STRUCT.X_MAX_DEPTH
			A 			= STRUCT.INTEGRATED_X
			PZ = PLOT(_XRANGE,[Z,Z],LINESTYLE=1,THICK=3,/OVERPLOT)
			
			INT = INTERVAL([Y[0],Y(-1)],(Y(-1)-Y[0])*0.05)
			FOR I=1, N_ELEMENTS(INT)-1 DO BEGIN
			  XX = INTERP_XTEND(Y,X, INT(I), X_MISSING=0.0, Y_MISSING=0.0,  ERROR=error)
			  PI = PLOT([X[0],XX.Y],[INT(I),INT(I)],COLOR='DODGER_BLUE',THICK=1,/OVERPLOT)
			ENDFOR
			PL = POLYLINE([X[0],X[0],X(-1)],[Y[0],Y(-1),Y(-1)],LINESTYLE=2,COLOR='DODGER_BLUE',THICK=2,/DATA,TARGET=PT)
			IF A NE MISSINGS(0.0) THEN BEGIN
				TXT=   'Integrated data = !C' + STRTRIM(STRING(A),2) + ' (x/m^2)'
				TX = TEXT(X[0]+(X(-1)-X[0])*.1,(Y(-1)-Y[0])*.5,TXT,/DATA,COLOR='BLACK',FONT_SIZE=11.0,FONT_STYLE='BOLD',VERTICAL_ALIGNMENT=0.5,ALIGNMENT=0.0)
      ENDIF
		ENDIF

	; Plot Z90 and Integrated data
		IF STRUCT.ERROR_X EQ '' AND STRUCT.ERROR_Z90 EQ '0' THEN BEGIN
			Z 			= STRUCT.Z90*(-1)
			ZZ 			= _MAX_DEPTH*(-1)
			CC 			= STRUCT.X_MAX_DEPTH
			W 			= STRUCT.WCHL
			A 			= STRUCT.INTEGRATED_X
			PL = PLOT(_XRANGE,[ZZ,ZZ],LINESTYLE=1, THICK = 2,/OVERPLOT)
			PL = PLOT(_XRANGE,[Z,Z],LINESTYLE=3, THICK = 2,/OVERPLOT)
  		PL = PLOT([W,W],[0.0,Z],LINESTYLE=2,COLOR='RED',THICK=3,/OVERPLOT)
  		SY = SYMBOL(CC,ZZ,LINESTYLE=2, COLOR='ORANGE',THICK=3,/OVERPLOT)
			IF A NE MISSINGS(0.0) THEN BEGIN
				TXT=   'Integrated data = '  + STRTRIM(STRING(A),2) + ' (' + _LABEL + '/m^2)'
				TX = TEXT(0.1,0.91 ,TXT,/DEVICE,COLOR='BLACK',FONT_SIZE=10.0)
			ENDIF
stop			
		ENDIF
		IF NONE(PNGFILE) THEN WAIT, 5 ELSE W.SAVE, PNGFILE
		W.CLOSE
	ENDIF

;	===> Return the Optically-Weighted Chlorophyll Concentration
  RETURN,STRUCT

END; #####################  End of Routine ################################



