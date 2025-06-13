; $ID:	GET_MTIME.PRO,	2017-10-17-15,	USER-KJWH	$

FUNCTION GET_MTIME, FILE, DATE=DATE, JD=JD

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
;			Written:  April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;			  APR 01, 2014 - KJWH: Added JD return keyword option
;			  NOV 17, 2017 - KJWH: Changed FILE_INFO to FILE_MODTIME to make it faster       
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_MTIME'
	
	MTIME = FILE_MODTIME(FILE)
	IF KEYWORD_SET(DATE) THEN RETURN, MTIME_2DATE(MTIME)
	IF KEYWORD_SET(JD)   THEN RETURN, MTIME_2JD(MTIME)
	RETURN, MTIME

END; #####################  End of Routine ################################
