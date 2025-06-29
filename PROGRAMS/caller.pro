; $ID:	CALLER.PRO,	2016-02-13,	USER-JOR	$
;####################################################################
	FUNCTION CALLER, STEP

;+
; NAME:
;		CALLER
;
; PURPOSE:;
;		THIS FUNCTION DETERMINES THE NAME OF THE ROUTINE THAT CALLED
;
; CATEGORY:
;		PROGRAMING
;
; CALLING SEQUENCE:
;
;		RESULT = CALLER()
;
; INPUTS:
;		NONE REQUIRED
;
; OPTIONAL INPUTS:
;		STEP:  1=PREVIOUS ROUTINE (THE CALLER); 
;		       2=THE CALLER OF THE CALLER; 
;		       3=THE CALLER OF THE CALLER OF THE CALLER
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		THIS FUNCTION RETURNS THE NAME OF THE CALLING ROUTINE
;
;
; EXAMPLE:
;		RESULT = CALLER()
;		RESULT = CALLER(2)
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 27,  2006 BY J.O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.O'REILLY@NOAA.GOV)
;			JUN 3,2013,JOR FORMATTING
;			JUL 5,2014,JOR MINOR MODS
;			FEB 13,2016,JOR :IF TXT EQ '<(   0)>' THEN TXT = 'MAIN'
;     AUG 03, 2016 - KJWH: Replaced HELP, CALLS=CALLS (obsolete as of IDL 6.2) with CALLS = SCOPE_TRACEBACK(/STRUCT)
;
;-
;###############################################################################

  ROUTINE_NAME = 'CALLER'

;	===> DEFAULT STEP IS 1 = THE CALLING ROUTINE
	IF NONE(STEP) THEN STEP = 1 ELSE STEP = STEP

  CALLS = SCOPE_TRACEBACK(/STRUCT)
  TXT = REVERSE(CALLS.ROUTINE)

;	===> CONSTRAIN THE VALUE OF STEP
  STEP = 0 > STEP < (N_ELEMENTS(TXT)-1)

  RETURN,TXT[STEP]
  

END; #####################  END OF ROUTINE ################################
