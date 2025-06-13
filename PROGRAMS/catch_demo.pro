; $Id: CATCH_DEMO.pro  $

	FUNCTION CATCH_DEMO,Data, ERROR=error

;+
; NAME:
;		CATCH_DEMO
;
; PURPOSE:;
;		This function is a DEMO for IDL's CATCH Procedure
;
; CATEGORY:
;		GENERAL
;
; CALLING SEQUENCE:
;
;		Result = CATCH_DEMO(Data, error=error)
;
; INPUTS:
;		Data:	Anything
;
;
; KEYWORD PARAMETERS:
;		ERROR:	IF no error then ERROR='' ELSE ERROR = !ERROR_STATE.MSG
;
; OUTPUTS:
;		-1
;
;
; EXAMPLE:
;  PRINT,CATCH_DEMO(1.,ERROR=ERROR) & PRINT, ERROR
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CATCH_DEMO'
	ERROR=''


;	*********************************
;	*** C A T C H    E R R O R S  ***
;	*********************************
	CATCH, Error_Status
   IF Error_Status NE 0 THEN BEGIN
    ERROR = !ERROR_STATE.MSG
   	CATCH, /CANCEL
   	RETURN,  -1
   ENDIF

	N=N_ELEMENTS(DATA)


;	===> Deliberately make a subscript mistake
	DATA(N) = 1

  RETURN, DATA

	END; #####################  End of Routine ################################
