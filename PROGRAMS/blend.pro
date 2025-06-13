; $ID:	BLEND.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION BLEND,Xarray, DOWN=down, METHOD=method,ERROR = error

;+
; NAME:
;		BLEND
;
; PURPOSE:
;		This function returns a blending fraction (0 to 1) over the interval provided in Xarray
;
; CATEGORY:
;		FUNCTIONS
;
; CALLING SEQUENCE:
;
;		BLEND, Parameter1, Parameter2, Foobar
;
;		Result = BLEND(Xarray)
;
; INPUTS:
;		Xarray:	The range [min,max] for scaling
;
; KEYWORD PARAMETERS:
;		DOWN... The blending function Decreases from 1 to 0 (Instead of the Default 0 to 1)
;		METHOD:	The function to use (not used at present)
;
; OUTPUTS:
;		This function returns a Structure with the Xarray and the blending factor [0,1]
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;		Result = BLEND([132,182]) & PLOT, Result.x, Result.f,/xstyle,/ystyle
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;		===> Demonstration of the integral of the function
;		N = 1001
;		CEN = N/2
;		X = (FINDGEN(N)-CEN)/CEN
;		===> INTEGRAL OF (1 - X^2) IS : (1.0 + 1.5*X -  (X^3)/2)/2 ;;
;		F = (1.0+1.5*X-(X^3)/2)/2 ;
;		===> Demonstration of the integral of the function
;		CUM = TOTAL((1 - X^2),/CUMULATIVE)
;		F_CUM =CUM/MAX(CUM)
;		PLOT, X,F_CUM & PAL_36 & OPLOT, X,F_CUM,COLOR=TC(35),THICK=7 & OPLOT, X,F,COLOR=TC[0] & PRINT,MINMAX(F_CUM-F)
;
; MODIFICATION HISTORY:
;			Written May 12, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'BLEND'

	IF N_ELEMENTS(Xarray) LT 2 THEN BEGIN
		ERROR='XRANGE MUST HAVE AT LEAST 2 ELEMENTS'
	 	RETURN,''
	ENDIF

	N = 1001
	CEN = N/2
	X = (FINDGEN(N)-CEN)/CEN

;	===> INTEGRAL OF (1 - X^2) IS : (1.0 + 1.5*X -  (X^3)/2)/2 ;;
	F = (1.0+1.5*X-(X^3)/2)/2 ;

	IF KEYWORD_SET(DOWN) THEN F=REVERSE(F)

;	===> Scale the x [-1,1] to the Input XRANGE
	XX=SCALE( Xarray, MINMAX(X))
	FF = INTERPOL(F,X,XX)

	RETURN,FF

	END; #####################  End of Routine ################################
