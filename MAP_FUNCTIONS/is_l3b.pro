; $ID:	IS_L3B.PRO,	2023-09-21-13,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION IS_L3B, TXT

; PURPOSE: 
;   Check to see if the text contains L3B 
; 
; CATEGORY:	
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE: 
;   RESULT = IS_L3B(TEXT)
;
; REQUIRED INPUTS: 
;   TXT...... The text string to look for the 'L3B' text  
;
; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: 
;   None
;
; OUTPUTS: 
;   1 if the text string contains 'L3B'
;   0 of the text string does not contain 'L3B' 
;		
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   Only looks for the 'L3B' text and does not check to see if it is a valid L3B map
;
; RESTRICTIONS:
;   None
; 
; EXAMPLES:
;   PRINT, IS_L3B('L3B4')
;       
;
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 09, 2017 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
; 
; MODIFICATION HISTORY:
;	  JUL 09, 2017 - JEOR: Wrote initial code
;		AUG 25, 2017 - KJWH: Changed input parameter "FILE" to "TEXT" 
;		AUG 09, 2021 - KJWH: Changed HAS() to STRPOS()
;		                     Updated documentation
;		                     Added COMPILE_OPT IDL2
;		                     Moved to MAP_FUNCTIONS
;-
; *********************************************************************************
  ROUTINE_NAME  = 'IS_L3B'
  COMPILE_OPT IDL2

  IF STRPOS(STRUPCASE(TXT),'L3B') GE 0 THEN RETURN, 1 ELSE RETURN,0
          
END; #####################  END OF ROUTINE ################################
