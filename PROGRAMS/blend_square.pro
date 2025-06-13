; $ID:	BLEND_SQUARE.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION BLEND_SQUARE, ERROR = error

;+
; NAME:
;		BLEND_SQUARE
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
;		BLEND_SQUARE, Parameter1, Parameter2, Foobar
;
;		Result = BLEND_SQUARE(Parameter1, Parameter2, Foobar)
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
	ROUTINE_NAME = 'BLEND_SQUARE'

	N = 1001
	CEN = N/2
	X = (FINDGEN(N)-CEN)/CEN

	F = (1 - X^2)
	CUM = TOTAL(F,/CUMULATIVE)
	F=CUM/MAX(CUM)



	PLOT, X,F,COLOR=TC[0]


	END; #####################  End of Routine ################################
