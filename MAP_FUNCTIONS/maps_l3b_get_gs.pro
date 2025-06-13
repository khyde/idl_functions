; $ID:	MAPS_L3B_GET_GS.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_GET_GS, L3B
;+
; NAME:
;   MAPS_L3B_GET_GS
; 
; PURPOSE:  
;   Returns the GS map name for a given L3B name
;
; CATEGORY: 
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE
;   Result = MAPS_L3B_GET_GS(L3B)
;
; REQUIRED INPUTS: 
;   L3B......... L3B MAP
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:  
;   None
;   
; OUTPUTS:  
;   The name aof the corresponding GS map
;       
; OPTIONAL OUTPUTS:
;   None
;   
; COMMON BLOCKS:
;   None
;   
; SIDE EFFECTS:
;   Must use a valid L3B map
;   
; EXAMPLES:
;   PRINT, MAPS_L3B_GET_GS('L3B9')
;   PRINT, MAPS_L3B_GET_GS('L3B4')
;
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 04, 2017 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   DEC 04, 2017 - KJWH: Initial code written
;   AUG 09, 2021 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Replaced the CASE block with REPLACE(L3B,'L3B','GS')
;                        Added a string length check
;                        Moved to MAP_FUNCTIONS
;-
; *******************************************************************************
  ROUTINE = 'MAPS_L3B_GET_GS'
  COMPILE_OPT IDL2
  
  IF ~IS_L3B(L3B) OR STRLEN(L3B) GT 5 THEN MESSAGE, 'ERROR: Must input a valid L3Bx map'
  
  RETURN, REPLACE(L3B,'L3B','GS')
  
  

END; #####################  END OF ROUTINE ################################
