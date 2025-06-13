; $ID:	MAPS_GET_RANGE.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
	PRO MAPS_GET_RANGE, VERBOSE
	
;+
; NAME:
;		MAPS_GET_RANGE
;
; PURPOSE:  
;   This program sets up the !X.CRANGE, !Y.CRANGE, !X.RANGE, !Y.RANGE to the map limits when map_set has been previously called
;
; CATEGORY:
;		MAP_FUNCTIONS
;
; CALLING SEQUENCE: 
;   MAPS_GET_RANGE
;
; REQUIRED INPUTS: 
;   None
;		
; OPTIONAL INPUTS:
;		None	
;		
; KEYWORD PARAMETERS:
;		VERBOSE..... Will print out the !X.CRANGE, !Y.CRANGE, !X.RANGE, !Y.RANGE values
;
; OUTPUTS: 
;		New values for !X.CRANGE, !Y.CRANGE, !X.RANGE, !Y.RANGE
;		
;	OPTIONAL OUTPUTS:
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
;   MAPS_GET_RANGE
;
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 1, 2013 by John E. O'Reilly Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce
;
; MODIFICATION HISTORY:
;   Jan 01, 2013 - JEOR: Wrote initial code
;   Jan 03, 2013 - JEOR: Added VERBOSE keyword
;   Oct 01, 2020 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Change () subscripts to []
;                        Changed name from MAP_GET_RANGE to MAPS_GET_RANGE to be consistent with other mapping functions
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_GET_RANGE'
  COMPILE_OPT IDL2		


  IF !X.TYPE EQ 3 THEN BEGIN
    !X.RANGE = [!MAP.LL_BOX[1],!MAP.LL_BOX[3]]
    !Y.RANGE = [!MAP.LL_BOX[0],!MAP.LL_BOX[2]]

    IF KEYWORD_SET(VERBOSE) THEN BEGIN
      PRINT,'!X.CRANGE  ', !X.CRANGE
      PRINT,'!X.RANGE  ', !X.RANGE
      PRINT,'!Y.CRANGE  ', !Y.CRANGE
      PRINT,'!Y.RANGE  ', !Y.RANGE
    ENDIF;IF KEYWORD_SET(VERBOSE) THEN BEGIN
    
  ENDIF;IF !X.TYPE EQ 3 THEN BEGIN

END; #####################  End of MAPS_GET_RANGE ################################
