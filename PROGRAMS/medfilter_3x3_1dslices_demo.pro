; $Id:	MEDFILTER_3x3_1DSLICES_DEMO.pro,	January 08 2007	$

	PRO MEDFILTER_3x3_1DSLICES_DEMO, IMAGE, ERROR = error

;+
; NAME:
;		MEDFILTER_3x3_1DSLICES_DEMO
;
; PURPOSE:
;		This function
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		MEDFILTER_3x3_1DSLICES, Parameter1, Parameter2, Foobar
;
;		Result = MEDFILTER_3x3_1DSLICES(Parameter1, Parameter2, Foobar)
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
;			A box size of 3x3 pixels
;			PEAK TEST USES 5-POINT SLICES in 4 DIRECTIONS: WE, NS, NWSE, NESW
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
;			A new algorithm
;			Written April 23, 2007  Igor Belkin, University of Rhode Island
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MEDFILTER_3x3_1DSLICES_DEMO'

	IMAGE = FLTARR(10,7)
	IMAGE(2,2) = 23
	IMAGE(1,2) = 21
	IMAGE(0,2) = 20.5
	IMAGE(3,2) = 21.3

  IMAGE = FINDGEN(10,5)
	MED = MEDFILTER_3x3_1DSLICES(IMAGE)
	END; #####################  End of Routine ################################
