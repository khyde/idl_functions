; $Id:	date_now.pro,	January 02 2007	$

	FUNCTION DATE_NOW, GMT=gmt, SHORT=short
;+
; NAME:
;		DATE_NOW
;
; PURPOSE:;
;		This Function returns the current Date-Time as a formatted string (YYYYMMDDHHMMSS)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;		Result = DATE_NOW()
;
; REQUIRED INPUTS:
;		None
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;		GMT......	Returns GMT date-time instead of the date determined from your computer's SYSTIME
;		               (actually the Universal Time Coordinated (UTC) is returned as defined by IDL's Help on SYSTIME:
;		               "UTC time is defined as Greenwich Mean Time updated with leap seconds."
;  SHORT..... Returns the date as YYYYMMDD
;  
; OUTPUTS:
;		A STRING (date: YYYYMMDDHHMMSS or YYYYMMDD)
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;		This routine assumes that your computer clock is set correctly
;
; EXAMPLE:
;		PRINT, DATE_NOW() 
;		PRINT, DATE_NOW(/GMT) 
;		PRINT, DATE_NOW(/SHORT)
;
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2001, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory. This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 02, 2001 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;			Jan 02, 2001 - JEOR: Initial code written
;			Aug 15, 2022 - KJWH: Added the keyword SHORT and IF KEYWORD_SET(SHORT) THEN RETURN, STRMID(JD_2DATE(JD),0,8)
;			                                    Moved to DATE_FUNCTIONS
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DATE_NOW'

  IF NOT KEYWORD_SET(GMT) THEN JD=SYSTIME(/JULIAN) ELSE JD=SYSTIME(/JULIAN,/UTC)
  IF KEYWORD_SET(SHORT) THEN RETURN, STRMID(JD_2DATE(JD),0,8)
	RETURN,JD_2DATE(JD)
END; #####################  End of Routine ################################
