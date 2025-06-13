; $ID:	QUOTE.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
	FUNCTION QUOTE,TXT 
;+
; NAME:
;		QUOTE
;
; PURPOSE: 
;   This function returns the txt string surronded by single quotes
;
; CATEGORY:
;		STRINGS
;
; CALLING SEQUENCE:
;   RESULT = QUOTE(TXT)
;
; INPUTS:
;		TXT:	INPUT STRING 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
; EXAMPLES:
;   PRINT, QUOTE('SEAWIFS')
;   PRINT, QUOTE(123)
;   PRINT, QUOTE(123.456)
;
;	NOTES:
;
;COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 05, 2013 by J.E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;   Inquiries on this code should be directed to: kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;		OCT 05, 2013 - JEOR: Wrote initial code
;	  OCT 09, 2013 - JEOR: Added IF N_ELEMENTS(TXT) EQ 0 THEN RETURN,Q
;   JUL 01, 2020 - KJWH: Removed CHARS() 
;                        Added COMPILE_OPT IDL2
;                        Updated documentation
;-
;#################################################################################
  ROUTINE_NAME  = 'QUOTE'
  COMPILE_OPT IDL2

  Q = "'"
  IF N_ELEMENTS(TXT) EQ 0 THEN RETURN, Q
  IF IDLTYPE(TXT) NE 'STRING' THEN T = STRTRIM(TXT,2) ELSE T = TXT
  RETURN, Q + T+ Q 


END; #####################  END OF ROUTINE ################################
