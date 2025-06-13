; $Id:	angle_2pixels.pro,	February 13 2007	$

	FUNCTION ANGLE_2PIXELS, ANGLE

;+
; NAME:
;		ANGLE_2PIXELS
;
; PURPOSE:;
;		This function calculates the distance in pixels for a given angle
;
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;		Write the calling sequence here. Include only positional parameters
;		(i.e., NO KEYWORDS). For procedures, use the form:
;
;		ROUTINE_NAME, Parameter1, Parameter2, Foobar
;
;		Note that the routine name is ALL CAPS and arguments have Initial
;		Caps.  For functions, use the form:
;
;		Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
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
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:  ;
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
	ROUTINE_NAME = 'ANGLE_2PIXELS'

;	RETURN,  COS( (FLOAT(ANGLE) MOD 45)  /!RADEG)

	RETURN,  1./  (COS( (FLOAT(ABS(ANGLE)) MOD 90)  /!RADEG) +  SIN( (FLOAT(ABS(ANGLE)) MOD 90)  /!RADEG))




	END; #####################  End of Routine ################################
