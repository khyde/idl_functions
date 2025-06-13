; $ID:	STRUCT_TAGNAMES_FIX.PRO,	2020-11-04-12,	USER-KJWH	$
;#################################################################################################################
 FUNCTION STRUCT_TAGNAMES_FIX, NAMES
;+
; NAME:
;   STRUCT_TAGNAMES_FIX
;
; PURPOSE:
;		Fix IDL structure tag names containing illegal characters
;
;	CATEGORY:
;	  UTILITY_FUNCTIONS
;	
;	REQUIRED INPUTS:
;	  NAMES.......... A text array of structure tagnames
;	
;	OPTIONAL INPUTS:
;	
;	KEYWORD PARAMETERS:
;		
; OUTPUTS:
;   New names that are valid structure tag names
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 27, 2004 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   NOV 27, 2004 - JEOR: Inidiatl code written
;   OCT 23, 2012 - JEOR: Updated formatting
;                        Conserving original names by making _NAMES
;   JAN 16, 2014 - JEOR: Now using IDL's IDL_VALIDNAME
;   AUG 13, 2015 - KJWH: Moved NAMES=STRCOMPRESS(NAMES,/REMOVE_ALL) to before the call to IDL_VALIDNAME     
;   NOV 04, 2020 - KJWH: Removed NAMES=STRCOMPRESS(NAMES,/REMOVE_ALL) 
;                        Added a step to look for multiple underscores (__) and replace them with a single underscore (_)
;                        Added COMPILE_OPT IDL2
;                        Updated documentation
;                        Removed the old obsolete code
;                        Moved the function to UTILITIES
;                        Added step to look for tags that end with an underscore (_) and remove it from the tag name
;                        
;-
; *************************************************************************
  ROUTINE_NAME='STRUCT_TAGNAMES_FIX'
  COMPILE_OPT IDL2
     
  NAMES=IDL_VALIDNAME(NAMES, /CONVERT_ALL)

; ===> Look for areas in the name with more than one underscore ('__') and replace with a single underscore ('_')  
  FOR N=0, N_ELEMENTS(NAMES)-1 DO WHILE(STRPOS(NAMES[N],'__') GE 0) DO NAMES[N] = REPLACE(NAMES[N],'__','_')
  
; ===> Look for names that end with an underscore
  FOR N=0, N_ELEMENTS(NAMES)-1 DO IF STRPOS(NAMES[N],'_',/REVERSE_SEARCH) EQ STRLEN(NAMES[N])-1 THEN NAMES[N] = STRMID(NAMES[N],0,STRLEN(NAMES[N])-1)
  
  RETURN, NAMES


END; #####################  END OF ROUTINE ################################



