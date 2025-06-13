; $ID:	IS_STACKED.PRO,	2023-10-30-09,	USER-KJWH	$
  FUNCTION IS_STACKED, FILES

;+
; NAME:
;   IS_STACKED
;
; PURPOSE:
;   Test if a file is a "stacked" file type (e.g. STACKED_SAVE, STACKED_STATS, STACKED_ANOMS)
;
; CATEGORY:
;   STACKED_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = IS_STACKED(FILES)
;
; REQUIRED INPUTS:
;   FILES.......... An array of input files to test
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   An array of 0's (not stacked) and 1's (stacked)
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 30, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 30, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'IS_STACKED'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  IF N_ELEMENTS(FILES) EQ 0 THEN RETURN, []
  IF IDLTYPE(FILES) NE 'STRING' THEN MESSAGE, 'ERROR: Input array must be string'
  
  RES = BYTARR(N_ELEMENTS(FILES))
  OK = WHERE(STRPOS(FILES,'STACKED') NE -1, COUNT)
  IF COUNT GT 0 THEN RES[OK] = 1
  
  RETURN, RES


END ; ***************** End of IS_STACKED *****************
