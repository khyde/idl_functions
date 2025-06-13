; $ID:	MAPS_L3B_NBINS.PRO,	2023-09-21-13,	USER-KJWH	$

FUNCTION MAPS_L3B_NBINS, L3BMAP

;+
; NAME:
;   MAPS_L3B_NBINS
; 
; PURPOSE:  
;   This simple function returns the number of bins in a l3bmap using MAPS_SIZE (which reads MAPS_MASTER) 
;
; CATEGORY: 
;   MAP_FUNCTIONS
;
; REQUIRED INPUTS: 
;   L3BMAP...... The name of the L3B map ['L3B1','L3B2','L3B4', 'L3B5', 'L3B9', or 'L3B10']
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORDS:  
;   None      
;
; OUTPUTS: 
;   The number of "bins" in a L3B map
;
;; OPTIONAL OUTPUTS:
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
;   PRINT, MAPS_L3B_NBINS('L3B9')  ; 5940422
;   PRINT, MAPS_L3B_NBINS('L3B4')  ; 23761676
;   PRINT, MAPS_L3B_NBINS('L3B2')  ; 95046858
;   PRINT, MAPS_L3B_NBINS('L3B1')  ; 380187134
;   PRINT, MAPS_L3B_NBINS('L3B10') ; 412
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
;   This program was written on February 08, 2007 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   FEB 08, 2017 - JEOR: Initial code written
;   FEB 21, 2017 - KJWH: Changed MAP_SIZE to MAPS_SIZE
;   MAR 01, 2017 - JEOR: Added L3B10
;                        Added ULONG() to the returned PY value
;   MAR 13, 2017 - KJWH: Added IF ~NONE(L3BMAP) THEN L3BMAP=STRUPCASE(L3BMAP) ELSE MESSAGE, 'ERROR: Must input a L3B MAP' to make sure the input map is upper case
;   AUG 09, 2021 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Added L3B5 map
;                        Changed IF THEN statement to a CASE statement
;                        Change IF NONE(L3BMAP) to IF N_ELEMENTS(L3BMAP) NE 1
;                        Moved to MAP_FUNCTIONS
;    OCT 27, 2023: KJWH: Added L3B10 and L3B25 maps
;-
; ***************************************************************************************************
  ROUTINE = 'MAPS_L3B_NBINS'
  COMPILE_OPT IDL2
  
  IF N_ELEMENTS(L3BMAP) EQ 1 THEN L3BMAP=STRUPCASE(L3BMAP) ELSE MESSAGE, 'ERROR: Must input a L3B MAP'
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
  
  RETURN,ULONG((MAPS_SIZE(L3BMAP)).PY)


END; #####################  END OF ROUTINE ################################
