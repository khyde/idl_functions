; $ID:	MAPS_L3B_BINS.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_BINS,L3BMAP
;+
; PURPOSE:  
;   This function returns the bins or a L3BMAP
;   
; CATEGORY: 
;   MAP FUNCTIONS;
;
; REQUIRED INPUTS: 
;   L3BMAP....... The name of the L3B map (e.g. 'L3B1','L3B2','L3B4', or 'L3B9')
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS: 
;   None
;
; OUTPUTS: 
;   An array of bin numbers (from 1 to ...) for the specified L3B map
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
; EXAMPLES:          
;   PMM, MAPS_L3B_BINS('L3B9')
;   PMM, MAPS_L3B_BINS('L3B4')
;   PMM, MAPS_L3B_BINS('L3B2')
;   
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 08, 2017 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   FEB 08, 2017 - JEOR: Initial code written
;   FEB 24, 2017 - KJWH: Changed MAP_SIZE to MAPS_SIZE
;   MAR 01, 2017 - KJWH: Changed UL64INDGEN([1,N_BINS])>1) to UL64INDGEN([1,N_BINS])+1)
;   AUG 09, 2021 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Added L3B5 map
;                        Changed IF THEN statement to a CASE statement
;                        Change IF NONE(L3BMAP) to IF N_ELEMENTS(L3BMAP) NE 1
;                        Moved to MAP_FUNCTIONS
;    OCT 27, 2023 - KJWH: Added L3B25 map
;-
; ***************************************************************************8**************************
  ROUTINE = 'MAPS_L3B_BINS'
  COMPILE_OPT IDL2
  
  IF N_ELEMENTS(L3BMAP) EQ 1 THEN L3BMAP=STRUPCASE(L3BMAP)
  CASE L3BMAP OF 
    'L3B1':  VALID = 1
    'L3B2':  VALID = 1
    'L3B4':  VALID = 1
    'L3B5':  VALID = 1
    'L3B9':  VALID = 1
    'L3B10': VALID = 1
    'L3B25': VALID = 1
    ELSE:  MESSAGE,'ERROR: ' + L3BMAP + ' is not a recognized map.'
  ENDCASE
  
  N_BINS = (MAPS_SIZE(L3BMAP)).PY
  RETURN,(UL64INDGEN([1,N_BINS])+1); First bin is 1 not 0 

END ; ***************** End of MAPS_L3B_BINS *****************
