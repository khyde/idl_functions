; $ID:	BLEND_TANH_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO BLEND_TANH_DEMO, ERROR = error

;+
; NAME:
;		BLEND_TANH_DEMO
;
; PURPOSE:
;		This function demonstrates blending based on the TANH function

;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		BLEND_TANH_DEMO, Parameter1, Parameter2, Foobar
;
;		Result = BLEND_TANH_DEMO(Parameter1, Parameter2, Foobar)
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
	ROUTINE_NAME = 'BLEND_TANH_DEMO'

	RANGE = [0.001,0.999]
	P = !PI*2
	X = (FINDGEN(1001)-500)/500.
	F=  ( TANH( X*!PI*P )/2.0)+0.5

DOY_RANGE =  DATE_2DOY(['20200511','20200630'])

  !p.multi=[0,1,2]
  PLOT, f,CHARSIZE=2
	PAL_36
  OPLOT, F,COLOR=TC(21)

	OK=WHERE(F GE RANGE[0] AND F LE RANGE[1],COUNT)

  PLOT_EVENT,[FIRST[OK],LAST[OK]]

	PLOT,F(0:499) ,1- REVERSE(F(500:*)),PSYM=3


  PRINT, DOY_RANGE


	FF=F[OK]

  DAYS= DOY_RANGE[0] + FINDGEN(SPAN(DOY_RANGE))

  FRACT = FF( COUNT *( DAYS - DOY_RANGE[0])/SPAN(DOY_RANGE))

	PRINT, FRACT

  STOP




	END; #####################  End of Routine ################################
