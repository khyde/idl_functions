; $Id:	GAUSS2DFIT_DEMO.pro,	January 08 2007	$

	PRO GAUSS2DFIT_DEMO, ERROR = error

;+
; NAME:
;		GAUSS2DFIT_DEMO
;
; PURPOSE:
;		This function
;		This procedure
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;		Write the calling sequence here. Include only positional parameters
;		(i.e., NO KEYWORDS). For procedures, use the form:
;
;		GAUSS2DFIT_DEMO, Parameter1, Parameter2, Foobar
;
;		Note that the routine name is ALL CAPS and arguments have Initial
;		Caps.  For functions, use the form:
;
;		Result = GAUSS2DFIT_DEMO(Parameter1, Parameter2, Foobar)
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

; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	PROCEDURE:
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GAUSS2DFIT_DEMO'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''



;This example creates a 2D gaussian, adds random noise and then applies GAUSS2DFIT_DEMO.
; Define array dimensions:
nx = 128 & ny = 100
; Define input function parameters:
A = [ 5., 10., nx/6., ny/10., nx/2., .6*ny]
; Create X and Y arrays:
X = FINDGEN(nx) # REPLICATE(1.0, ny)
Y = REPLICATE(1.0, nx) # FINDGEN(ny)
; Create an ellipse:
U = ((X-A[4])/A[2])^2 + ((Y-A[5])/A[3])^2
; Create gaussian Z:
Z = A[0] + A[1] * EXP(-U/2)
SLIDE,BYTSCL(Z)

; Add random noise, SD = 1:
Z = Z + RANDOMN(seed, nx, ny)
SLIDE,BYTSCL(Z)
; Fit the function, no rotation:
yfit = GAUSS2DFIT(Z, B)
; Report results:
PRINT, 'Should be: ', STRING(A, FORMAT='(6f10.4)')
PRINT, 'Is: ', STRING(B(0:5), FORMAT='(6f10.4)')




	END; #####################  End of Routine ################################
