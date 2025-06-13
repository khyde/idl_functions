; $ID:	INTEGRAL_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO INTEGRAL_DEMO, ERROR = error

;+
; NAME:
;		INTEGRAL_DEMO
;
; PURPOSE:
;		This function
;		This procedure
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		INTEGRAL_DEMO, Parameter1, Parameter2, Foobar
;
;		Result = INTEGRAL_DEMO(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:	 If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
;	PROCEDURE:
;			This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'INTEGRAL_DEMO'

	PSPRINT,FILENAME=ROUTINE_NAME+'.PS',/COLOR,/HALF

;	*************************
;	*** Blending Function ***
;	*************************
	N = 1001 & CEN = N/2 & X = (FINDGEN(N)-CEN)/CEN

;	===> INTEGRAL OF (1 - X^2) IS : (1.0 + 1.5*X -  (X^3)/2)/2 ;;
	F = (1.0+1.5*X-(X^3)/2)/2 ;

;	===> Demonstration of the integral of the function
	CUM = TOTAL((1 - X^2),/CUMULATIVE)
	F_CUM =CUM/MAX(CUM)
	PLOT, X,(1-X^2)
	OPLOT, X,F_CUM & PAL_36 & OPLOT, X,F_CUM,COLOR=TC(35),THICK=7 & OPLOT, X,F,COLOR=TC[0] & PRINT,MINMAX(F_CUM-F)



	PSPRINT




	END; #####################  End of Routine ################################
