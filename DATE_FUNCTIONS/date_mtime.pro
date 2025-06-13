; $Id:	get_mtime.pro,	April 18 2011	$

FUNCTION DATE_MTIME, FILE

;+
; NAME:
;		GET_MTIME
;
; PURPOSE:
;		This function returns the mtime of a set of files
;
; CATEGORY:
;		
; CALLING SEQUENCE:
;
; INPUTS:
;		FILE
;
; OPTIONAL INPUTS:		
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;		This function returns the MTIME 
;
; OPTIONAL OUTPUTS:
; 
;	PROCEDURE:
;			MTIME = GET_MTIME(FILES)
;
; EXAMPLE:
;
;	NOTES:
;		
; MODIFICATION HISTORY:
;			Written April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DATE_MTIME'
	
	FI = FILE_INFO(FILE)
	RETURN, MTIME_2DATE(FI.MTIME)

END; #####################  End of Routine ################################
