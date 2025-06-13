; $Id:	template_kim.pro,	May 16 2007	$

	PRO DOWNWELLING_IRRADIANCE

;+
; NAME:
;		DOWNWELLING_IRRADIANCE
;
; PURPOSE:;
;		This function computes the solar irradiance just below the surface given meteorological data (interactively) and writes to a data file.
;		Direct and diffuse component are broken out separately.
;		This procedure
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
;	NOTES:  Adapted from Watson W. Gregg, NASA/Goddard Space Flight Center (301) 614-5711
;	
;	REFERENCE: Gregg, W.W. and K.L. Carder, 1990.  A simple spectral solar irradinace model for cloudless maritime atmospheres.
;            Limnology and Oceanography 35: 1657-1675.
;
;
; MODIFICATION HISTORY:
;			Written July 15, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DOWNWELLING_IRRADIANCE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''






	END; #####################  End of Routine ################################
