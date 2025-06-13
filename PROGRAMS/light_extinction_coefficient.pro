; $ID:	LIGHT_EXTINCTION_COEFFICIENT.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION LIGHT_EXTINCTION_COEFFICIENT, DEPTH=depth, LIGHT=light, CHL = CHL, CDEPTH = CDEPTH,TEMP = TEMP, TDEPTH = TDEPTH, TITLE=TITLE, $
 					ST_DEPTH=ST_DEPTH,SHOW=SHOW ,I0=I0, _EXTRA=_extra
;+
; NAME:
;       LIGHT_EXTINCTION_COEFFICIENT
;
; PURPOSE:
;				Return a Structure with
;				extinction coefficients (Kd), Euphotic Depths (1%), and Regression statistics based on three models:
;				1) Ln(Light 	= A0 + A1*Depth  							(Linear);
;
;				3) Ln(Light)	=	A0 + A1*A2^Depth  					(Exponential)
;				In all 3 models the Y-variate is the Natural Log of the Light Intensities
;
;	EXAMPLES:
;				(ALSO SEE LIGHT_EXTINCTION_COEFFICIENT_DEMO.PRO)

; EXAMPLE 1:
;				DEPTH=[0.5,		1,		2,	4,		5,		7.7]
;				LIGHT=[1600,1000,	500,	250,	120,	 30]
;				struct=LIGHT_EXTINCTION_COEFFICIENT(DEPTH=DEPTH,LIGHT=LIGHT, ERROR=error, /SHOW)
;				Num        Kd       RSQ        I0
;				  6    0.5312     0.991   1789.97
;
;	EXAMPLE 2: (Shows how to pass other commands to the PLOT via the _EXTRA )
;				DEPTH=[0.5,		1,		2,	4,		5,		7.7]
;				LIGHT=[1600,1000,	500,	250,	120,	 30]
;				struct=LIGHT_EXTINCTION_COEFFICIENT(DEPTH=DEPTH,LIGHT=LIGHT, ERROR=error, /SHOW,TITLE='STATION 2',CHARSIZE=3)
;
; INPUTS:
;       DEPTH:		Depth (meters)
;				LIGHT:		Light Measurements
;				CHL:			Chlorophyll profile measurements (fluorescence)
;				CDEPTH:		Chlorophyll depths
;				TEMP:			Temperature profile
;				TDEPTH:		Temperature depths
;				ST_DEPTH: Depth (meters) of the station
;				TITLE:		Title for Plot (if /SHOW)

; OUTPUTS:
;				Structure Containing:
;   N               LONG                29										Number of Depth-Light Measurements
;   MIN_DEPTH       FLOAT           2.00000										Minimum Depth
;   MAX_DEPTH       FLOAT           16.5000										Maximum Depth
;
;																															Linear Model
;   COEFFS_LIN      STRING    ' 6.19040 -0.341751'						Regression Coefficients
;   KD_LIN          FLOAT          0.341751										Kd (1%)
;   I0_LIN          FLOAT           488.043										Light Intensity at Surface
;   ZEU_LIN         FLOAT           13.4752										Euphotic Depth (1%)
;   IZEU_LIN        FLOAT           4.88043										Light Intensity at Euphotic Depth (1%)
;   RSQ_LIN         FLOAT          0.971859										R-squared
;   ERROR_LIN       STRING    '0'															Error Flag
;
;																															Exponential Model
;   COEFFS_EXP      STRING    ' -1.18815 8.53121 0.920258'		Regression Coefficients
;   KD_EXP          FLOAT          0.493587										Kd (1%)
;   I0_EXP          FLOAT           1545.43										Light Intensity at Surface
;   ZEU_EXP         FLOAT           9.33000										Euphotic Depth (1%)
;   IZEU_EXP        FLOAT               Inf										Light Intensity at Euphotic Depth (1%)
;   RSQ_EXP         FLOAT          0.998284										R-squared
;   ERROR_EXP       STRING    '0'															Error Flag
;
;
;		KEYWORDS
;				SHOW:		Show Plot and Print Results
;				I0:			Calculate I0 from upper data points
;
;	NOTES:
;				IDL'S COMFIT Returns coefficients as Y = A0*A1^X + A2
;	 			(THIS PROGRAM SHIFTS CONSTANTS SO: Y = A0 + A1*A2^X)

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 8,2004
;				Modified by; Kim Whitman & J.E.O'Reilly, July 28, 2004, to include a 2nd order polynomial regression;
;				Modified by: J.E.O'Reilly & Kim Whitman, July 29, 2004, to return a structure with statistical results and coefficients
;				Modified by: J.E.O'Reilly & Kim Whitman, July 30, 2004, (Added Exponential Model)
;				Modified by: J.E.O'Reilly & Kim Whitman, Aug   1, 2004, (Plot model estimates extrapolated to surface and Zeu)
;				Modified by: J.E.O'Reilly & Kim Whitman, Aug   7, 2004, (Added Exponential Model based on obs within the euphotic depth)
;				Modified by: J.E.O'Reilly & Kim Whitman, Aug 	13, 2004, (Added Linear and 2nd Poly models based on obs within the euphotic depth and added station depth to the plot)
;				Modified by: 							  Kim Whitman, Aug, 17, 2004,	(Added Chlorophyll profile to plot)
;				Modified by:								Kim Whitman, Sept, 2004,		Removed polynomial regression
;																																Added Temperature profile plot
;																																Added new estimate of I0 just using surface data and subsequent calculations
;				Modified by:								Kim Hyde,		 October, 2004	Removed euphotic models
;																																Revised the estimates of I0 using the surface data
;																																Added interpolated and extrapolated estimates of IZeu based on new estimate of I0 for the linear and exponential models
;				Modified by: J.E.O'Reilly								 Nov 14, 2004		Linear Regressions now use Type II Reduced Major Axis
; 			Modified by:								Kim Hyde,		 March, 2005		Cleaned up the program, added a couple more check points, and fixed errors in the plotting section
;				Modified by: 								Kim Hyde,		 April, 8, 2005	Added the Kd for the second optical depth (Kd_2OD)
;				Modified by:                Kim Hyde,    July 3, 2017:  Added EXTRAP_DEPTH to the output structure
;;

ROUTINE_NAME='LIGHT_EXTINCTION_COEFFICIENT'

; *********************
;	***** CONSTANTS *****
; *********************
	depth_resolution = 0.01	; Resolution of Euphotic Depth (meters) for 2nd-Order Poly and Exponential Models
	euphotic_max     = 200.0
	N_ZZ = FIX(euphotic_max/depth_resolution)+1 ;
	Z_DEPTHS 	= FINDGEN(N_ZZ)*depth_resolution

;	===> Colors
	PAL_36,r,g,b
	COLOR_DATA_POINTS 	= 32
	COLOR_DATA_LINE 		= 32
	COLOR_MODEL_LIN 		= 6
	COLOR_MODEL_EXP 		= 20
	COLOR_MODEL_LIN_UP 	= 22
	COLOR_CHL						= 13
	COLOR_TEMP					= 4

;	===> Thick
	THICK_MODEL_LIN			=	4
	THICK_MODEL_EXP 		= 4
	THICK_MODEL_LIN_UP	= 5
	THICK_CHL						= 4
	THICK_TEMP 					= 4

	XSTYLE=1

	IF N_ELEMENTS(TITLE) NE 1 THEN _TITLE = '' ELSE _TITLE = TITLE
	IF N_ELEMENTS(ST_DEPTH) NE 1 THEN _ST_DEPTH = MISSINGS(0.0) ELSE _ST_DEPTH = FLOAT(ST_DEPTH)
	IF _ST_DEPTH LE 1 THEN _ST_DEPTH = MISSINGS(0.0)
	IF N_ELEMENTS(CHL) GE 1 THEN _CHL = FLOAT(CHL) ELSE _CHL = MISSINGS(0.0)
	IF N_ELEMENTS(CDEPTH) GE 1 THEN _CDEPTH = FLOAT(CDEPTH) ELSE _CDEPTH = MISSINGS(0.0)
	IF N_ELEMENTS(TEMP) GE 1 THEN _TEMP = FLOAT(TEMP) ELSE _TEMP = MISSINGS(0.0)
	IF N_ELEMENTS(TDEPTH) GE 1 THEN _TDEPTH = FLOAT(TDEPTH) ELSE _TDEPTH = MISSINGS(0.0)



;	===> Create a Structure to hold regression statistics for the Linear, 2nd-Order Polynomial and Exponential Models
  STRUCT = CREATE_STRUCT('N',0L,'MIN_DEPTH',0.0,'MAX_DEPTH',0.0,$
  												'COEFFS_LIN','','Kd_LIN',0.0,	'I0_LIN',0.0,	'Zeu_LIN',0.0,'IZeu_LIN',0.0,	'RSQ_LIN',0.0,'ERROR_LIN','',$
  												'COEFFS_EXP','','Kd_EXP',0.0,	'I0_EXP',0.0,	'Zeu_EXP',0.0,'IZeu_EXP',0.0,	'RSQ_EXP',0.0,'ERROR_EXP','','Z2_EXP',0.0,$
  												'UP_MODEL_CODE','','UP_OPTICAL_DEPTH','','COEFFS_UP','','N_UP',0L,'Kd_Z90',0.0,'Kd_2OD',0.0,'I_Z90',0.0,'Z90',0.0,'Z_2OD',0.0,'I_2OD',0.0,$
  												'RSQ_UP',0.0,'ERROR_UP','','UP_DATA_REMOVED',0L,$
  												'Z_CODE_DOWN','','EXTRAP_DEPTH',0.0,'COEFFS_DOWN','','BOT','','IBOT',0.0,$
  												'BULK_I0',0.0,'BULK_Zeu',0.0, 'BULK_IZeu',0.0,'BULK_Kd',0.0, 'BULK_COEFFS','','BULK_ERROR','')



;	===> Make elements in STRUCT missing
	STRUCT=STRUCT_2MISSINGS(STRUCT)
	STRUCT.N=0L
	STRUCT.UP_DATA_REMOVED = 0L

;	===> Check that at least 2 depths are provided and that the number of depths equals the number of light measurements
	N_DEPTH = N_ELEMENTS(DEPTH) & N_LIGHT = N_ELEMENTS(LIGHT)
	IF N_DEPTH LT 2 OR N_LIGHT LT 2 OR N_DEPTH NE N_LIGHT OR MIN(DEPTH) LT 0 THEN BEGIN
		PRINT,'ERROR: Must have at least 2 depths '
		PRINT,'Number of light readings must equal number of depths'
		PRINT,'Depths must be positive'
		STRUCT.ERROR_LIN	='ERROR: Must have at least 2 depths; Number of light readings must equal number of depths; Depths must be positive'
		STRUCT.ERROR_EXP	='ERROR: Must have at least 2 depths; Number of light readings must equal number of depths; Depths must be positive'
	;	STRUCT.ERROR_EXPEU	='ERROR: Must have at least 2 depths; Number of light readings must equal number of depths; Depths must be positive'
		RETURN, STRUCT
	ENDIF ELSE ERROR=0 ;	Initialize ERROR to zero

	MIN_DEPTH=MIN(DEPTH)
	MAX_DEPTH=MAX(DEPTH)

;	===> Regress Natural Log of light intensity (y) versus depth (x)
	x = FLOAT(DEPTH)
	y =	ALOG(FLOAT(LIGHT))

;	===> Fill in structure
	STRUCT.N = N_DEPTH
	STRUCT.MIN_DEPTH = MIN_DEPTH
	STRUCT.MAX_DEPTH = MAX_DEPTH




;	****************************************************************
;	***** Linear Regression Model TYPE II (Reduced Major Axis) *****
;	****************************************************************

;; PREVIOUSLY LINEAR REGRESSSION - REPLACED WITH REDUCED MAJOR AXIS REGRESSION:
;;		COEFFS_LIN = REGRESS(X, Y, CONST=CONST_LIN, CORRELATION=CORRELATION_LIN, 	FTEST=FTEST_LIN, SIGMA=SIGMA_LIN, STATUS=STATUS_LIN , YFIT=YFIT_LIN)

	_STATS=STATS2(X,Y, ERROR=STATUS_LIN,MODEL='LSY') 							; Least Squares Y. Note STATUS ERRORS NOT FULLY TESTED

  CORRELATION_LIN = _STATS.R & COEFFS_LIN = _STATS.SLOPE &  CONST_LIN  = _STATS.INT & YFIT_LIN= CONST_LIN + COEFFS_LIN * X

;	===> If there is a regression error then status is 1 or 2 ( See IDL's REGRESS for STATUS Codes)
	IF IDLTYPE(_STATS) EQ 'STRUCT' THEN BEGIN
		STRUCT.ERROR_LIN 	= ''
		STRUCT.KD_LIN = -coeffs_LIN[0] 																			; regression slope (Change sign of extinction coefficient Kd to be positive)
		IF STRUCT.KD_LIN GT 0 THEN BEGIN
			STRUCT.ZEU_LIN = -ALOG(0.01)/STRUCT.Kd_LIN
			STRUCT.I0_LIN  = EXP(CONST_LIN)																			; regression intercept (at 0m)
			STRUCT.COEFFS_LIN = STRCOMPRESS(STRJOIN(' '+STRING([CONST_LIN,COEFFS_LIN[0]])))
			STRUCT.RSQ_LIN   	= CORRELATION_LIN^2
			STRUCT.IZeu_LIN		= STRUCT.I0_LIN*0.01 															; By definition
			IF STRUCT.I0_LIN LE 10 THEN STRUCT.ERROR_LIN = 'I0 LT 10'									; If I0 is low, then add error code
		ENDIF ELSE BEGIN
			STRUCT.ERROR_LIN = 'KD LT 0'
			STRUCT.KD_LIN = MISSINGS(0.0)
		ENDELSE
	ENDIF ELSE STRUCT.ERROR_LIN = _STATS ;

;	*****************************************
;	***** Exponential Regression Model ******
;	*****************************************
;	NOTE THAT THIS IS ACTUALLY A DOUBLE EXPONENTIAL MODEL BECAUSE LIGHT IS LOG-TRANSFORMED.
;	IDL'S COMFIT Returns coefficients as Y = A0*A1^X + A2
;	!!! NOTE: THIS PROGRAM SHIFTS CONSTANTS SO: Y = A0 + A1*A2^X
;	When X is zero, Y = (A0 + A1*1 ) = A0+A1

	IF N_ELEMENTS(DEPTH) GT 3 THEN BEGIN
		COEFFS_EXP 			= COMFIT( DEPTH, ALOG(LIGHT),[1,1,1],/EXPONENTIAL,YFIT=YFIT_EXP)
	  COEFFS_EXP			= SHIFT(coeffs_exp,1)			;Shift Coeffs_exp
		CORRELATION_EXP = CORRELATE(ALOG(LIGHT),YFIT_EXP)

	;	===> There is no error code is returned from comfit
		IF N_ELEMENTS(COEFFS_EXP) EQ 3 AND TOTAL(COEFFS_EXP) NE 0 THEN 	STATUS_EXP = '' ELSE STATUS_EXP = 'ERROR: COEFFS_EXP'
		IF COEFFS_EXP[0] EQ TOTAL(YFIT_EXP)/N_ELEMENTS(YFIT_EXP) THEN STATUS_EXP = 'ERROR: COEFFS_EXP'
		IF STATUS_EXP EQ MISSINGS(STATUS_EXP) THEN BEGIN
			STRUCT.ERROR_EXP 		= ''
			STRUCT.I0_EXP  			= EXP(coeffs_EXP[0] + coeffs_EXP[1])						; Regression intercept (at 0m)
			IF STRUCT.I0_EXP LE 10 THEN STRUCT.ERROR_EXP = 'I0 LE 10'						; If I0 is low, then add error code
			STRUCT.RSQ_EXP   		= CORRELATION_EXP^2 ;
			STRUCT.COEFFS_EXP 	= STRCOMPRESS(STRJOIN(' '+STRING(COEFFS_EXP)))
			STRUCT.Izeu_EXP 		= 0.01*STRUCT.I0_EXP														; Izeu = 0.01*I0 by definition

	;		===> Estimate Light from Z_DEPTHS using Exponential Model
			YY 	= COEFFS_EXP[0]+ COEFFS_EXP[1]*COEFFS_EXP(2)^Z_DEPTHS

	;		===> Locate the model light values GE Izeu
			OK_ABOVE=WHERE(YY GE ALOG(STRUCT.Izeu_EXP),count_above)

			IF COUNT_ABOVE GE 1 AND COUNT_ABOVE NE N_ELEMENTS(YY) THEN BEGIN
				YY=YY(OK_ABOVE)
				ZZ=Z_DEPTHS(OK_ABOVE)
	;			===> Because the fit may 'double back' there is not always one unique solution ...
	;			So find where there is a break in the subscripts, this will indicate a 'doubling back situation'
				ok_para = WHERE(OK_ABOVE+1 NE SHIFT(OK_ABOVE,-1),COUNT_para)
	;			===> The last OK_ABOVE+1 will never be equal to the SHIFT(OK_ABOVE,-1) so COUNT_para will alway be at least 1
	;				If count_para is 2 or more then the Zeu = is the first (shallowest)
				IF COUNT_PARA EQ 1 THEN Zeu = ZZ(LAST(OK_ABOVE)) ELSE	Zeu = ZZ(OK_ABOVE(OK_PARA[0]))

	;			===> Test that the Zeu found above is reasonable
	;			Estimate I` by passing the estimated zeu to the Exponential function
				IzeuP 	= EXP(COEFFS_EXP[0] + COEFFS_EXP[1]*COEFFS_EXP(2)^Zeu)				 	 			  ;
				ratio= IzeuP/STRUCT.IZeu_EXP
				IF ratio GE 0.95 AND RATIO LE 1.05 THEN BEGIN
					STRUCT.Zeu_EXP = Zeu
	;				===> Now that we have the zeu calculate the bulk kd
					kd = -ALOG(0.01)/zeu
	 				STRUCT.KD_EXP			=	kd 			;
	 			ENDIF
			ENDIF	ELSE STRUCT.ERROR_EXP = 'DOUBLING BACK SITUATION'		; IF COUNT_ABOVE GE 1 THEN BEGIN
		ENDIF ELSE STRUCT.ERROR_EXP = STATUS_EXP	 	; IF STATUS_EXP EQ 0 THEN BEGIN (IN this case the poly did not estimate a depth deep enough (weird data))
		IF STRUCT.KD_EXP LE 0 THEN STRUCT.ERROR_EXP = 'KD_EXP LT 0'
	ENDIF	ELSE STRUCT.ERROR_EXP = 'N_ELEMENTS DEPTH AND LIGHT LT 4'

; ***************************************************************************************************************************************
; ***** USE KD_EXP TO DETERMINE THE SECOND OPTICAL DEPTH AND THEN USE LINEAR AND EXP MODELS TO CALCULATE I0 FROM THOSE POINTS ABOVE *****
; ***************************************************************************************************************************************

	IF STRUCT.ERROR_EXP EQ MISSINGS(STRUCT.ERROR_EXP) THEN BEGIN							; USE THE Kd FROM THE EXPONENTIAL MODEL TO DETERMINE THE
		KD = STRUCT.KD_EXP																											;	DEPTH OF THE SECOND OPTICAL LAYER
		STRUCT.UP_MODEL_CODE = 'EXP'
		ZEU = STRUCT.ZEU_EXP
	ENDIF ELSE BEGIN
		IF STRUCT.ERROR_LIN EQ MISSINGS(STRUCT.ERROR_LIN) THEN BEGIN
			KD = STRUCT.KD_LIN																										; IF THE EXPONENTIAL Kd IS MISSING, THEN USE THE LINEAR Kd
			STRUCT.UP_MODEL_CODE = 'LIN'
			ZEU = STRUCT.ZEU_LIN
		ENDIF ELSE GOTO, SKIP_I0
	ENDELSE
	Z2 = 2/KD																																	; DETERMINE THE DEPTH OF THE SECOND OPTICAL LAYER
	Z3 = 3/KD																																	; DETERMINE THE DEPTH OF THE THIRD OPTICAL LAYER
	IF Z2 GE ZEU THEN STOP																										; CHECK TO MAKE SURE Z2 IS SHALLOWER THAN THE EUPHOTIC LAYER
	OK = WHERE(DEPTH LE Z2,COUNT2)																						; FIND ALL DEPTHS ABOVE Z2
	IF COUNT2 GE 1 THEN BEGIN
		IF COUNT2 GE 5 THEN BEGIN																								; WANT AT LEAST FIVE DEPTHS TO EXTRAPOLATE TO SURFACE
			X2 = DEPTH[OK]																												; GET SURFACE DEPTHS
			Y2 = ALOG(LIGHT[OK])																									; GET SURFACE LIGHT
			STRUCT.UP_OPTICAL_DEPTH = 'SECOND'
		ENDIF ELSE BEGIN																												; IF THERE ARE LESS THAN FIVE DEPTHS, USE THIRD OPTICAL DEPTH
			OK = WHERE(DEPTH LE Z3, COUNT3)
			IF COUNT3 GE 5 THEN BEGIN
				X2 = DEPTH[OK]
				Y2 = ALOG(LIGHT[OK])
				STRUCT.UP_OPTICAL_DEPTH = 'THIRD'
			ENDIF ELSE GOTO, SKIP_I0
		ENDELSE
	ENDIF ELSE GOTO, SKIP_I0

; ******************************************************************
;	LINEAR CALCULATION OF UPPER Kd AND Z90
	_STATS=STATS2(X2,Y2,MODEL='LSY') 									; Reduced Major Axis. Note STATUS ERRORS NOT FULLY TESTED
	CORRELATION_UP = _STATS.R & COEFFS_UP = _STATS.SLOPE &  CONST_UP  = _STATS.INT & YFIT_UP = CONST_UP + COEFFS_UP * X2
	IF IDLTYPE(_STATS) EQ 'STRUCT' THEN BEGIN
		COUNTER = 0
		IF COUNTER GT 1 THEN BEGIN
			LOOP_REGRESSION:
				_STATS=STATS2(X2,Y2, ERROR=STATUS_UP,MODEL='LSY') 									; Reduced Major Axis. Note STATUS ERRORS NOT FULLY TESTED
				CORRELATION_UP = _STATS.R & COEFFS_UP = _STATS.SLOPE &  CONST_UP  = _STATS.INT & YFIT_UP = CONST_UP + COEFFS_UP * X2
				IF IDLTYPE(_STATS) EQ 'STRING' THEN GOTO, SKIP_LOOP
		ENDIF
		STRUCT.N_UP = N_ELEMENTS(X2)
		STRUCT.ERROR_UP 	= ''
		I0  = EXP(CONST_UP)																								; regression intercept (at 0m)
  	STRUCT.KD_2OD = -coeffs_UP[0]
  	IF STRUCT.KD_2OD GT 0 THEN BEGIN
			COEFFS_UP = [CONST_UP,COEFFS_UP[0]]
			STRUCT.BULK_I0			= I0			;
			STRUCT.RSQ_UP		   	= CORRELATION_UP^2 ;
			STRUCT.BULK_IZeu		= I0*0.01 																				; By definition
			STRUCT.COEFFS_UP 	= STRCOMPRESS(STRJOIN(' '+STRING(COEFFS_UP)))
			STRUCT.I_Z90 = EXP(-1)*I0																							; FIND THE LIGHT AT THE 1ST OPTICAL DEPTH FROM NEW I0
			STRUCT.Z90	 = (ALOG(STRUCT.I_Z90)-COEFFS_UP[0])/COEFFS_UP[1]					; DETERMINE THE DEPTH OF 1ST OPTICAL DEPTH FROM I2
			STRUCT.KD_Z90 = -(ALOG(STRUCT.I_Z90/STRUCT.BULK_I0))/STRUCT.Z90
			STRUCT.I_2OD = EXP(-2)*I0																							; FIND THE LIGHT AT THE 2ND OPTICAL DEPTH FROM NEW I0
			STRUCT.Z_2OD = (ALOG(STRUCT.I_2OD)-COEFFS_UP[0])/COEFFS_UP[1]					; DETERMINE THE DEPTH OF 2ND OPTICAL DEPTH FROM I2
			I3 = EXP(-3)*I0																												; FIND THE LIGHT AT THE 3RD OPTICAL DEPTH FROM NEW I0
			Z3 = (ALOG(I3)-COEFFS_UP[0])/COEFFS_UP[1]															; DETERMINE THE DEPTH OF 3RD OPTICAL DEPTH FROM I3
			IF STRUCT.RSQ_UP LE 0.95 THEN BEGIN
				OK = WHERE(X2 NE MAX(X2),COUNT)
				IF COUNT GE 5 THEN BEGIN
					COUNTER = COUNTER+1
					X2 = X2[OK]
					Y2 = Y2[OK]
					LOOP = 1
					GOTO, LOOP_REGRESSION
				ENDIF ELSE BEGIN
	; IF RSQ IS LE 0.95 AND THERE ARE LESS THAN 5 DEPTHS THEN NULL OUT THE Z90 VARIABLES
					SKIP_LOOP:
					STRUCT.ERROR_UP 	= 'RSQ LT 0.95 AND N_ELEMENTS DEPTHS LT 5'
					STRUCT.N_UP				= 0
					STRUCT.KD_2OD			= MISSINGS(0.0)
					STRUCT.KD_Z90			= MISSINGS(0.0)
					STRUCT.BULK_I0 		= MISSINGS(0.0)
					STRUCT.RSQ_UP			= MISSINGS(0.0)
					STRUCT.BULK_IZeu 	= MISSINGS(0.0)																		; By definition
					STRUCT.COEFFS_UP 	= MISSINGS('')
					STRUCT.I_Z90			= MISSINGS(0.0)
					STRUCT.Z90 				= MISSINGS(0.0)
					STRUCT.I_2OD		 	= MISSINGS(0.0)
					STRUCT.Z_2OD			= MISSINGS(0.0)
				ENDELSE
			ENDIF
			STRUCT.UP_DATA_REMOVED = COUNTER
		ENDIF ELSE BEGIN
		; IF STATUS NE 0 THEN NULL OUT THE Z90 VARIABLES AND GOTO SKIP I0
			STRUCT.ERROR_UP 	= 'ERROR'
			STRUCT.N_UP				= 0
			STRUCT.KD_2OD			= MISSINGS(0.0)
			STRUCT.KD_Z90			= MISSINGS(0.0)
			STRUCT.BULK_I0 		= MISSINGS(0.0)
			STRUCT.RSQ_UP			= MISSINGS(0.0)
			STRUCT.BULK_IZeu 	= MISSINGS(0.0)																		; By definition
			STRUCT.COEFFS_UP 	= MISSINGS('')
			STRUCT.I_Z90			= MISSINGS(0.0)
			STRUCT.Z90 				= MISSINGS(0.0)
			STRUCT.I_2OD		 	= MISSINGS(0.0)
			STRUCT.Z_2OD 			= MISSINGS(0.0)
			GOTO, SKIP_I0
		ENDELSE
	ENDIF ELSE GOTO, SKIP_I0

; END CALCULATION OF UPPER KD AND Z90
; ******************************************************************

;	********************************************************************************************************************************
;	FIND THE DEPTH OF IZeu BY EITHER INTERPOLATING BETWEEN TWO MEASURED LIGHT VALUES, OR BY EXTRAPOLATING FROM THE 3RD OPTICAL DEPTH

; ***************************************************************************
;	DO INTERPOLATION OF ZEU
	IF STRUCT.ERROR_UP EQ MISSINGS(STRUCT.ERROR_UP) THEN BEGIN
		OK = WHERE(LIGHT LE STRUCT.BULK_IZEU,COUNT)															; FIND THE LIGHT LE IZEU
		IF COUNT GE 1 THEN BEGIN																								; IF THERE ARE LOWER LIGHT VALUES, THEN CAN INTERPOLATE Zeu
			D1 = MIN[OK]																													; RETURNS THE SUBSCRIPT OF THE SHALLOWEST LIGHT VALUE BELOW IZeu
			D2 = D1-1																															; RETURNS THE SUBSCRIPT OF THE LIGHT VALUE ABOVE D1
			D  = [D2,D1]																													; SUBSCRIPTS OF THE TWO LIGHT VALUES BRACKETING Zeu
			X3 = DEPTH(D)																													; GET DEPTH OF THE TWO LIGHT VALUES BRACKETING Zeu
			Y3 = ALOG(LIGHT(D))																										; GET LIGHT OF THE TWO LIGHT VALUES BRACKETING Zeu
			IZEU = ALOG(STRUCT.BULK_IZEU)
			IF Y3[0] GE ALOG(STRUCT.BULK_IZEU) AND Y3[1] LE ALOG(STRUCT.BULK_IZEU) THEN BEGIN			; CONFIRM THAT IZeu IS BETWEEN THE 2 LIGHT VALUES
				STRUCT.BULK_ZEU 		= INTERPOL(X3,Y3,IZEU)													; INTERPOLATE Zeu
				STRUCT.Z_CODE_DOWN 	= 'INTERPOLATE'																	; ADD 'INTERPOLATION' CODE
				KD									= -ALOG(0.01)/STRUCT.BULK_ZEU										; CALCULATE Kd FROM Zeu
				STRUCT.BOT 					= 'DARK'
			ENDIF ELSE STOP																												; IF IZeu IS NOT BRACKETED THEN STOP
; IF Zeu CAN'T BE INTERPOLATED THEN MUST EXTRAPOLATE TO Zeu
; ***************************************************************************
; FIND THE DEPTHS TO EXTRAPOLATE WITH
		ENDIF ELSE BEGIN
			OK = WHERE(DEPTH GE Z2,COUNTD)																					; FIND DEPTHS BELOW Z2
			IF COUNTD GE 1 THEN BEGIN
				OK = WHERE(DEPTH GE Z3,COUNT)
				IF COUNT GE 5 THEN BEGIN																							; WANT AT LEAST 5 POINTS FOR EXTRAPOLATION
					X3 = DEPTH[OK]
					Y3 = ALOG(LIGHT[OK])
					IZEU = ALOG(STRUCT.BULK_IZEU)
				  STRUCT.EXTRAP_DEPTH = MIN(X3)                                       ; THE DEPTH THE EXTRAPOLATION STARTS (FOR PLOTTING PURPOSES)
				ENDIF ELSE BEGIN																											; IF NUMBER OF DEPTHS IS LE 5 THEN EXTRAPOLATE FROM 2ND OPTICAL DEPTH
					OK = WHERE(DEPTH GE Z2,COUNT2)																			;	FIND DEPTHS BELOW Z2
						IF COUNT2 GE 5 THEN BEGIN
						X3 = DEPTH[OK]																										; GET DEPTHS LE Z2
						Y3 = ALOG(LIGHT[OK])																							; GET LIGHT LE Z2
						IZEU = ALOG(STRUCT.BULK_IZEU)
						STRUCT.EXTRAP_DEPTH = MIN(X3)                                     ; THE DEPTH THE EXTRAPOLATION STARTS (FOR PLOTTING PURPOSES)
					ENDIF ELSE GOTO, SKIP_EXTRAPOLATION																	; IF STILL DON'T HAVE 5 DEPTHS TO EXTRAPOLATE FROM SKIP LIN EXTRAPOLATION
				ENDELSE
			ENDIF ELSE GOTO, SKIP_EXTRAPOLATION
; **************************************************************************
; DO EXTRAPOLATION OF IZEU ONLY IF VALUES AREN'T TOO SIMILAR
			S = STATS(Y3)																														; TEST BOTTOM DEPTHS TO MAKE SURE THEY AREN'T EQUAL OR TOO SIMILAR
			IF S.STD LE 0.05 THEN BEGIN
				STRUCT.BULK_ERROR = 'EQUAL_BOT_LIGHT'																	; If all Y3 variables are equal (of very similar STD LE 0.05)
				GOTO, SKIP_EXTRAPOLATION																										; 	then skip bottom extrapolation
			ENDIF

			_STATS=STATS2(X3,Y3, ERROR=STATUS3,MODEL='LSY') 												; Reduced Major Axis. Note STATUS ERRORS NOT FULLY TESTED
			; PREVIOUSLY: C  = REGRESS(X3,Y3,CONST=CONST3,CORRELATION=CORRELATION3,FTEST=FTEST3,SIGMA=SIGMA3,STATUS=STATUS3,YFIT=YFIT3)  ; DO REGRESSION ON LOWER DEPTHS
		  CORRELATION3 = _STATS.R & C = _STATS.SLOPE &  CONST3  = _STATS.INT & YFIT3 = CONST3 + C * X3
			IF IDLTYPE(_STATS) EQ 'STRUCT' THEN BEGIN
				COEFFS3 = [CONST3,C[0]]																							; GET COEFFICIENTS
				STRUCT.BULK_ZEU = (IZEU-COEFFS3[0])/COEFFS3[1]											; DETERMINE Zeu USING NEW COEFFICIENTS AND IZeu
				STRUCT.Z_CODE_DOWN = 'EXTRAPOLATE'																	; ADD 'EXTRAPOLATION' CODE
				KD = -ALOG(0.01)/STRUCT.BULK_IZEU																		; CALCULATE Kd FROM Zeu
				STRUCT.COEFFS_DOWN 	= STRCOMPRESS(STRJOIN(' '+STRING(COEFFS3)))
				IF STRUCT.BULK_ZEU GT _ST_DEPTH THEN BEGIN
					STRUCT.IBOT = (_ST_DEPTH*COEFFS3[1]) + COEFFS3[0]
					STRUCT.BOT = '>1%'
				ENDIF ELSE STRUCT.BOT = 'DARK'
			ENDIF 																																; END IF STATUS3 NE 0
		ENDELSE
; END EXTRAPOLATION
; ***************************************************************************
; ***************************************************************************
; DO BULK KD
; ===> Find the surface and bottom intensities
		IF STRUCT.BOT NE '>1%' THEN BEGIN
			YY = [ALOG(STRUCT.BULK_I0),ALOG(STRUCT.BULK_IZEU)]
			XX = [0,STRUCT.BULK_ZEU]
		ENDIF ELSE BEGIN
			YY = [ALOG(STRUCT.BULK_I0),ALOG(STRUCT.IBOT)]
			XX = [0,_ST_DEPTH]
		ENDELSE
		_STATS=STATS2(XX,YY, ERROR=STATUS_Kd,MODEL='LSY') ; Reduced Major Axis. Note STATUS ERRORS NOT FULLY TESTED
		; PREVIOUSLY:	BULK_Kd = REGRESS(XX,YY,CONST=CONST_Kd,CORRELATION=CORRELATION_Kd,FTEST=FTEST_Kd,SIGMA=SIGM_Kd,STATUS=STATUS_Kd,YFIT=YFIT_Kd)
		CORRELATION_Kd = _STATS.R & BULK_Kd = _STATS.SLOPE &  CONST_Kd  = _STATS.INT
		IF IDLTYPE(_STATS) EQ 'STRUCT' THEN BEGIN
			STRUCT.BULK_ERROR = ''
			COEFFS_Kd = [CONST_Kd,BULK_Kd[0]]
			STRUCT.BULK_COEFFS = STRCOMPRESS(STRJOIN(' '+STRING(COEFFS_Kd)))
			STRUCT.BULK_Kd = -BULK_Kd[0]
		ENDIF ELSE STRUCT.BULK_ERROR = _STATS
	ENDIF	ELSE STRUCT.BULK_ERROR = STRUCT.ERROR_UP
	GOTO, CHECKS
; END BULK KD
; **************************************************************************
; **************************************************************************
; FILL IN ERRORS

	SKIP_I0:
		STRUCT.ERROR_UP = 'SKIP_I0'
		STRUCT.BULK_ERROR = 'SKIP_I0'

	SKIP_EXTRAPOLATION:
		STRUCT.BULK_ERROR = 'SKIP_EXTRAPOLATION'

	CHECKS:
; ===> Check to see if results are reasonable
		IF STRUCT.BULK_ZEU LE 0 THEN STRUCT.BULK_ERROR 	= 'Negative_Zeu'
		IF STRUCT.BULK_KD  LE 0 THEN STRUCT.BULK_ERROR	= 'Negative_Kd'
		IF STRUCT.KD_2OD	 LE 0 THEN STRUCT.ERROR_UP		= 'Negative_Kd'
		IF STRUCT.Z90			 LE 0 THEN STRUCT.ERROR_UP		= 'Negative_Z90'

; *******************************************************************************
	IF KEYWORD_SET(SHOW) THEN BEGIN  ; Plot & List Data and Regression Models *****
;	*******************************************************************************
		PRINT, _TITLE

;		===> Compute greater of Zeu_LIN and Zeu_P2 and Zeu_EXPand Deepest Depth (for depth axis)
		ZMAX = [STRUCT.Zeu_LIN, STRUCT.Zeu_EXP, STRUCT.MAX_DEPTH, _ST_DEPTH, STRUCT.BULK_ZEU]
		OK=WHERE(FINITE(ZMAX) EQ 1,COUNT)
		IF COUNT GE 1 THEN Zmax=MAX(Zmax(ok))
		YRANGE=[-Zmax,0]

;		===> Compute min and max light for X axis
		XRANGE = [LIGHT,  STRUCT.I0_LIN,	STRUCT.I0_EXP,	STRUCT.BULK_I0,$
											STRUCT.IZeu_LIN,	STRUCT.IZeu_EXP, STRUCT.BULK_IZEU]
		OK = WHERE(FINITE(XRANGE) EQ 1,COUNT)
		IF COUNT GE 1 THEN XRANGE = [MIN(XRANGE[OK]),MAX(XRANGE[OK])] ELSE STOP
		XRANGE=ALOG(XRANGE)


		CHARSIZE = 1.15
;		****************
;		***** DATA *****
;		****************
;		===> Plot axes with no data
		PLOT, ALOG(LIGHT),-1.0*DEPTH, XRANGE=XRANGE,YRANGE=yrange,XTICKS=1,XTITLE=_TITLE,YTITLE='Depth (m)',COLOR=0,$
			XSTYLE=XSTYLE,TICKLEN = 0,/NODATA,_EXTRA=_extra, CHARSIZE = CHARSIZE
;		===> Overplot data
		OPLOT,ALOG(LIGHT),-1.0*DEPTH,  COLOR = COLOR_DATA_LINE, THICK=2.5, PSYM=-1, SYMSIZE=1.15
		AXIS,XAXIS=1,!Y.CRANGE[1],/XSTYLE,XTITLE='Ln(Light)', CHARSIZE=CHARSIZE, /SAVE
;   ===> If station depth is not missings, then overplot the station depth
		IF _ST_DEPTH NE MISSINGS(_ST_DEPTH) THEN BEGIN
			XST = XRANGE
			YST = [_ST_DEPTH,_ST_DEPTH]
			OPLOT, XST,-1.0*YST, COLOR = 0, THICK = 3, LINESTYLE = 0
		ENDIF

;		************************
;		***** LINEAR MODEL *****
;		************************
		IF STRUCT.ERROR_LIN EQ MISSINGS(STRUCT.ERROR_LIN) THEN BEGIN
;		===> Overplot Linear Model Regression Fit Data as a line
		OPLOT,YFIT_LIN, 			-1.0*DEPTH, 			COLOR	=	COLOR_MODEL_LIN,THICK=THICK_MODEL_LIN

;		===> Calculate Model Light for all Z_DEPTHS
		COEFFS=FLOAT(STRSPLIT(STRUCT.COEFFS_LIN,/EXTRACT))
		MODEL_LIN = COEFFLS[0] + COEFFLS[1]*Z_DEPTHS

;		===> Plot Surface-Extrapolated Estimates
		OK=WHERE(Z_DEPTHS LE MIN_DEPTH,COUNT)
		IF COUNT GE 2 THEN $
		OPLOT,MODEL_LIN(ok),-1.0*Z_DEPTHS(ok),COLOR=COLOR_MODEL_LIN,THICK=THICK_MODEL_LIN,linestyle=1

;		===> Plot Zeu-Extrapolated Estimates
		OK=WHERE(Z_DEPTHS GE MAX_DEPTH AND Z_DEPTHS LE STRUCT.Zeu_LIN,COUNT)
		IF COUNT GE 2 THEN $
		OPLOT,MODEL_LIN(ok),-1.0*Z_DEPTHS(ok),COLOR=COLOR_MODEL_LIN,THICK=THICK_MODEL_LIN,linestyle=1

;		===> Plot Linear Model Extrapolated Surface I0 as a plus symbol
		PLOTS,  ALOG(STRUCT.I0_LIN),0.0,PSYM=2,SYMSIZE=.5,COLOR=COLOR_MODEL_LIN,THICK=THICK_MODEL_LIN
;		===> Overplot Linear Model 1% Light Depth as dashed line
    PLOTS, XRANGE, [-1.0*STRUCT.Zeu_LIN,-1.0*STRUCT.Zeu_LIN], COLOR=COLOR_MODEL_LIN,THICK=1,LINESTYLE=2
		ENDIF

;		******************************************
;		***** LINEAR 2(OPTICAL DEPTHS) MODEL *****
;		******************************************
		IF STRUCT.ERROR_UP EQ MISSINGS(STRUCT.ERROR_UP) THEN BEGIN
;		===> Overplot Linear Model Regression Fit Data as a line
		OPLOT,YFIT_UP, 			-1.0*X2, 			COLOR	=	COLOR_MODEL_LIN_UP,THICK=THICK_MODEL_LIN_UP

;		===> Calculate Model Light for all DEPTHS_2
		COEFFS=FLOAT(STRSPLIT(STRUCT.COEFFS_UP,/EXTRACT))
		MODEL_LIN_UP = COEFFLS[0] + COEFFLS[1]*Z_DEPTHS

;		===> Plot Surface-Extrapolated Estimates
		OK=WHERE(Z_DEPTHS LE MIN_DEPTH,COUNT)
		IF COUNT GE 2 THEN $
		OPLOT,MODEL_LIN_UP(ok),-1.0*Z_DEPTHS(ok),COLOR=COLOR_MODEL_LIN_UP,THICK=THICK_MODEL_LIN_UP,linestyle=2

;		===> Plot the interpolated 1% light depth
		IF STRUCT.BULK_IZEU NE MISSINGS(STRUCT.BULK_IZEU) THEN BEGIN
			PLOTS,ALOG(FLOAT(STRUCT.BULK_IZEU)),-1*(FLOAT(STRUCT.BULK_ZEU)),PSYM = 5, SYMSIZE = 2.5, COLOR = 22, THICK=THICK_MODEL_LIN_UP
			YZ = [0,-1*STRUCT.BULK_ZEU]
			XZ = [ALOG(FLOAT(STRUCT.BULK_I0)),ALOG(FLOAT(STRUCT.BULK_IZEU))]
			OPLOT, XZ,YZ,COLOR=22,THICK=4,LINESTYLE=4
		ENDIF
		IF STRUCT.Z_CODE_DOWN EQ 'EXTRAPOLATE' THEN BEGIN
			COEFFS2 = FLOAT(STRSPLIT(STRUCT.COEFFS_DOWN,/EXTRACT))
			MODEL_LIN_DOWN = COEFFS2[0] + COEFFS2[1]*Z_DEPTHS
			OK = WHERE(Z_DEPTHS GE MIN(X3) AND Z_DEPTHS LE STRUCT.BULK_ZEU,COUNT)
			IF COUNT GE 2 THEN $
			OPLOT, MODEL_LIN_DOWN[OK], -1.0*Z_DEPTHS[OK], COLOR = 22, THICK = THICK_MODEL_LIN_UP, LINESTYLE=2
		ENDIF

;		===> Plot Linear_2 Model Extrapolated Surface I0
		PLOTS,  ALOG(STRUCT.BULK_I0),0.0, PSYM=5,SYMSIZE=2.5,COLOR = COLOR_MODEL_LIN_UP, THICK = THICK_MODEL_LIN_UP
;		===> Overplot the Depth of the Second Optical Layer, Determined by the Exponential Model as dashed line
    PLOTS, XRANGE, [-1.0*STRUCT.Z2_EXP,-1.0*STRUCT.Z2_EXP], COLOR =COLOR_MODEL_LIN_UP, THICK =THICK_MODEL_LIN_UP ,LINESTYLE = 4
		ENDIF

;		*****************************
;		***** Exponential Model *****
;		*****************************
		IF STRUCT.ERROR_EXP EQ MISSINGS(STRUCT.ERROR_EXP) THEN BEGIN
;		===> Overplot Exponential Model Regression Fit Data as a line
		OPLOT,YFIT_EXP, 			-1.0*DEPTH, 			COLOR	=	COLOR_MODEL_EXP,THICK=THICK_MODEL_EXP

;		===> Calculate Model Light for all Z_DEPTHS
		COEFFS=FLOAT(STRSPLIT(STRUCT.COEFFS_EXP,/EXTRACT))
		MODEL_EXP = COEFFLS[0] + COEFFLS[1]*COEFFLS(2)^Z_DEPTHS  ;

;		===> Plot Surface-Extrapolated Estimates
		OK=WHERE(Z_DEPTHS LE MIN_DEPTH,COUNT)
		IF COUNT GE 2 THEN $
		OPLOT,MODEL_EXP(ok),-1.0*Z_DEPTHS(ok),COLOR=COLOR_MODEL_EXP,THICK=THICK_MODEL_EXP,linestyle=1

;		===> Plot Zeu-Extrapolated Estimates
		OK=WHERE(Z_DEPTHS GE MAX_DEPTH AND Z_DEPTHS LE STRUCT.Zeu_EXP,COUNT)
		IF COUNT GE 2 THEN $
		OPLOT,MODEL_EXP(ok),-1.0*Z_DEPTHS(ok),COLOR=COLOR_MODEL_EXP,THICK=THICK_MODEL_EXP,linestyle=1

;		===> Plot 2nd-Order Model Extrapolated Surface I0 as a plus symbol
		PLOTS,  ALOG(STRUCT.I0_EXP),0.0,PSYM=2,SYMSIZE=.5,COLOR=COLOR_MODEL_EXP,THICK=THICK_MODEL_EXP
;		===> Overplot 2nd-Order Model 1% Light Depth as dashed line
    PLOTS, XRANGE, [-1.0*STRUCT.Zeu_EXP,-1.0*STRUCT.Zeu_EXP], COLOR=COLOR_MODEL_EXP,THICK=THICK_MODEL__EXP,LINESTYLE=2
		ENDIF
;		*********************************************************************
;		***** Overplot chlorophyll and temperagure profiles if provided *****
;		*********************************************************************

		IF N_ELEMENTS(_CHL) GE 2 THEN BEGIN
			IF N_ELEMENTS(_CDEPTH) GE 2 THEN _CDEPTH = _CDEPTH ELSE _CDEPTH = DEPTH
			IF MAX(_CHL) LT 5 THEN C_RANGE = [0,5]
			IF MAX(_CHL) GE 5 AND MAX(_CHL) LE 10 THEN C_RANGE = [0,10]
			IF MAX(_CHL) GE 10 THEN C_RANGE = [0,MAX(_CHL)+1]
			S1 = 0.1*ZMAX
			AXIS,0,S1,XAXIS=1,!Y.CRANGE[1]*0.4,XRANGE=C_RANGE,/XSTYLE,XTITLE='Chlorophyll (ug/L)', CHARSIZE = CHARSIZE,/SAVE, COLOR=COLOR_CHL
			OPLOT, _CHL, -1.0*_CDEPTH, COLOR = COLOR_CHL, THICK = THICK_CHL, LINESTYLE = 3, PSYM = -6, SYMSIZE = 1
		ENDIF
		IF N_ELEMENTS(_TEMP) GE 2 THEN BEGIN
			IF N_ELEMENTS(_TDEPTH) GE 2 THEN _TDEPTH = _TDEPTH ELSE _TDEPTH = DEPTH
			IF MAX(_TEMP) LT 5 THEN T_RANGE = [0,5]
			IF MAX(_TEMP) GE 5  AND MAX(_TEMP) LE 10 THEN T_RANGE = [0,10]
			IF MAX(_TEMP) GE 10 AND MAX(_TEMP) LE 20 THEN T_RANGE = [0,20]
			IF MAX(_TEMP) GE 20 THEN T_RANGE = [0,MAX(_TEMP)+1]
			S2 = 0.2*ZMAX
			AXIS,0,S2,XAXIS=1,!Y.CRANGE[1]*0.6,XRANGE=T_RANGE,/XSTYLE,XTITLE='Temperature (C)', CHARSIZE=CHARSIZE, /SAVE, COLOR=COLOR_TEMP
			OPLOT, _TEMP, -1.0*_TDEPTH, COLOR = COLOR_TEMP, THICK = THICK_TEMP, LINESTYLE = 3, PSYM = -6, SYMSIZE = 1
		ENDIF


;		**********************
;		***** Annotation *****
;		**********************
		TXT=   'N: ' + STRTRIM(N_DEPTH,2)

		IF _ST_DEPTH NE MISSINGS(_ST_DEPTH) THEN TXT = [TXT, '!CStation Depth: ' + STRMID(NUM2STR(_ST_DEPTH),0,4) + '!C  ']

		XPOS= !X.CRANGE[0]+0.02*ABS(!X.CRANGE[1]-!X.CRANGE[0])
		YPOS= -0.05*ABS(!Y.CRANGE[0]-!Y.CRANGE[1])

;		===> Size the Annotation Text depending on number of plots per page width

		IF !P.MULTI[1] EQ 0 THEN CHARSIZE_LEGEND = 1.15 ELSE CHARSIZE_LEGEND = 1.15/!P.MULTI[1]

		XYOUTS, XPOS,YPOS ,TXT,/DATA,ALIGN=0.0, COLOR=0,CHARSIZE=CHARSIZE_LEGEND

 		TXT=[		 ' Linear:           '		+ '  Kd: ' + STRTRIM(STRING(STRUCT.KD_LIN, 	 FORMAT = '(F6.3)'),2) + ' Rsq: ' + STRTRIM(STRING(STRUCT.RSQ_LIN,    FORMAT = '(F6.3)'),2) + ' Zeu: ' + STRTRIM(STRING(STRUCT.Zeu_LIN, 		FORMAT = '(F5.1)'),2) + $
							' I0: ' + STRTRIM(STRING(ALOG(STRUCT.I0_LIN),			FORMAT = '(F4.1)'),2)]
		IF STRUCT.ERROR_EXP EQ MISSINGS(STRUCT.ERROR_EXP) THEN $
		TXT=[TXT,' Exponential:      '	  + '  Kd: ' + STRTRIM(STRING(STRUCT.KD_EXP,		 FORMAT =	'(F6.3)'),2) + ' Rsq: ' + STRTRIM(STRING(STRUCT.RSQ_EXP,  	 FORMAT = '(F6.3)'),2) + ' Zeu: ' + STRTRIM(STRING(STRUCT.Zeu_EXP,	  FORMAT = '(F5.1)'),2) + $
							' I0: ' + STRTRIM(STRING(ALOG(STRUCT.I0_EXP), 		FORMAT = '(F4.1)'),2)] ELSE $
		TXT=[TXT,' Exponential:        Error']
		IF STRUCT.ERROR_UP EQ MISSINGS(STRUCT.ERROR_UP) THEN $
		TXT=[TXT,' Linear-up (bulk): '		+ '  Kd: ' + STRTRIM(STRING(STRUCT.KD_2OD, FORMAT = '(F6.3)'),2) + ' Rsq: ' + STRTRIM(STRING(STRUCT.RSQ_UP, FORMAT = '(F6.3)'),2) + ' Zeu: ' + STRTRIM(STRING(STRUCT.BULK_ZEU, FORMAT = '(F5.1)'),2) + $
							' I0: ' + STRTRIM(STRING(ALOG(STRUCT.BULK_I0),  FORMAT = '(F4.1)'),2) + ' IZeu: ' + STRTRIM(STRING(ALOG(STRUCT.BULK_IZEU),      FORMAT = '(F4.1)'),2)] ELSE $
		TXT=[TXT, ' Linear-up (bulk):   Error']
		TXT=[TXT,' Chlorophyll  		']
		TXT=[TXT,' Temperature  		']

 		COLORS = [COLOR_MODEL_LIN,COLOR_MODEL_EXP,COLOR_MODEL_LIN_UP,COLOR_CHL,COLOR_TEMP]
 		THICKS = [THICK_MODEL_LIN,THICK_MODEL_EXP,THICK_MODEL_LIN_UP,THICK_CHL,THICK_TEMP]
 		LINESTYLE = [0,0,0,3,3]


 		LEG,pos =[0.02 ,0.76,0.06,0.90], color=colors,label=TXT,THICK=THICKS,LSIZE=CHARSIZE_LEGEND,LINESTYLE=LINESTYLE

		PRINT
		PRINT, ['Num','Kd_LIN','RSQ_Lin','I0_Lin','Zeu_Lin','IZeu_Lin'],	FORMAT='(A4,5A10)'
		PRINT, STRUCT.N,STRUCT.Kd_LIN,STRUCT.RSQ_LIN,STRUCT.I0_LIN,STRUCT.Zeu_LIN,STRUCT.IZeu_LIN,	FORMAT='(I4, F10.4, F10.3, 3F10.2)'
		PRINT, ['Num','Kd_Exp','RSQ_Exp','I0_EXP','Zeu_Exp','IZeu_Exp'],	FORMAT='(A4,5A10)'
		PRINT, STRUCT.N,STRUCT.Kd_EXP,STRUCT.RSQ_EXP,STRUCT.I0_EXP,STRUCT.Zeu_EXP,STRUCT.IZeu_EXP,	FORMAT='(I4, F10.4, F10.3, 3F10.2)'
		PRINT, ['Num','Kd_LIN_UP','RSQ_Lin_UP','I0_Lin_UP','Zeu_Lin_UP','IZeu_Lin_UP'],	FORMAT='(A4,5A10)'
		PRINT, STRUCT.N,STRUCT.Kd_2OD,STRUCT.RSQ_UP,STRUCT.BULK_I0,STRUCT.BULK_Zeu,STRUCT.BULK_IZeu,	FORMAT='(I4, F10.4, F10.3, 3F10.2)'
	ENDIF

	RETURN, STRUCT


END; #####################  End of Routine ################################



