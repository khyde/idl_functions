; $ID:	CPAL_GET.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION CPAL_GET, WILDCARD, CP=CP

;+
; NAME:
;   CPAL_GET
;
; PURPOSE:
;   Get the list of available color palettes
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = CPAL_GET()
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   WILDCARD....... Wildcard text for searching for specific palettes
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   The list of pal_*.pro files
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 10, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 10, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_GET'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(WILDCARD) THEN WC = '*' ELSE WC = WILDCARD
  
  PALS = FILE_SEARCH(!S.PALETTE_FUNCTIONS + 'pal_'+WC+'.pro')
  IF KEYWORD_SET(CP) THEN PALS = FILE_SEARCH(!S.PALETTE_FUNCTIONS + 'cp_'+WC+'.pro')
  
  FP = FILE_PARSE(PALS)
  
  RETURN, FP.NAME


END ; ***************** End of CPAL_GET *****************
