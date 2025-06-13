; $ID:	PRODS_STRUCT.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
	FUNCTION PRODS_STRUCT, PROD, RANGE=RANGE, LOG=LOG, UNITS=UNITS
;+
; NAME:
;		PRODS_STRUCT
;
; PURPOSE: 
;   This function returns a standard prods structure 
;
; CATEGORY: 
;   PRODUCUT functions		 
;
; CALLING SEQUENCE: 
;   RESULT = PRODS_STRUCT()
;
; REQUIRED INPUTS: 
;   None        
;
; OPTIONAL INPUTS: 
;   PROD............ A product name
;		
; KEYWORD PARAMETERS:
;   RANGE........... Range of data
;   LOG............. If the data are log scaled [1 = ALOG10 scales; 0 = linear scaling]
;   UNITS........... Scientific units to use for titles on colorbars etc. [see UNITS.PRO]
;         
; OUTPUTS: A STANDARD PRODS STRUCTURE EMPTY 
;         [OR FILLED IF RANGE AND LOG ARE GIVEN]
;
; OPTIONAL OUTPUTS
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
;  ST, PRODS_STRUCT()
;  ST, PRODS_STRUCT('ANY_NAME_YOU_WISH')
;  ST, PRODS_STRUCT('JUNK',RANGE = [0,64])
;  ST, PRODS_STRUCT('JUNK',RANGE = [0.01,64],LOG = 'LOG')
;  ST, PRODS_STRUCT('JUNK',RANGE = [0.01,64],LOG = 'LOG',UNITS = UNITS('CHLOR_A',/NO_NAME))
; 
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2013, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written on December 5, 2013 by J.E. O'Reilly Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     and maintained by, Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882 kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;		DEC 05, 2013 - JEOR: Initial code written	
;		JAN 05, 2014 - JEOR: Added PROD if not PROD is provided
;		                     Added if CHLOR_A is not found in PRODS_MASTER then return the first prod
;		JAN 08, 2014 - JEOR: Revised structure, streamlined
;		JAN 13, 2014 - JEOR: Fill structure with input if present
;		JAN 15, 2014 - JEOR: Added examples
;	  APR 13, 2014 - JEOR: Changed dir to !S.MASTER
;   SEP 21, 2021 - KJWH: Changed !S.MASTER to !S.IDL_MAINFILES
;                        Updated documentations & formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;-
; ******************************************************************************************
  ROUTINE_NAME  = 'PRODS_STRUCT'
  COMPILE_OPT IDL2
    
  CB_RANGE = [1,250]
  CSVFILE = !S.MAINFILES + 'PRODS_MAIN.csv'
  S = STRUCT_FROM_CSV(CSVFILE)
  IF N_ELEMENTS(PROD) EQ 1 THEN BEGIN
    NAME = 'PROD' & VAL=PROD & V = STRUCT_IT(VAL,NAME) & STRUCT_ASSIGN,V,S,/NOZERO
  ENDIF ; N_ELEMENTS(PROD)
  
  IF N_ELEMENTS(RANGE) EQ 2 THEN BEGIN
    NAME = 'LOWER' & VAL=RANGE[0] & V=STRUCT_IT(VAL,NAME) & STRUCT_ASSIGN,V,S,/NOZERO
    NAME = 'UPPER' & VAL=RANGE[1] & V=STRUCT_IT(VAL,NAME) & STRUCT_ASSIGN,V,S,/NOZERO
  ENDIF ;N_ELEMENTS(RANGE) 
      
  IF N_ELEMENTS(LOG) EQ 1 THEN BEGIN
    NAME = 'LOG' & VAL=STRTRIM(LOG,2) & V=STRUCT_IT(VAL,NAME)& STRUCT_ASSIGN,V,S,/NOZERO
  ENDIF ; N_ELEMENTS(LOG) 
     
  IF N_ELEMENTS(UNITS) EQ 1 THEN BEGIN
    NAME = 'UNITS' & VAL=UNITS & V=STRUCT_IT(VAL,NAME)& STRUCT_ASSIGN,V,S,/NOZERO
  ENDIF ; N_ELEMENTS(LOG)
   
  IF N_ELEMENTS(PROD) EQ 1 AND N_ELEMENTS(RANGE) EQ 2 AND N_ELEMENTS(LOG) EQ 1 THEN BEGIN
    T = PRODS_TICKS(PROD, RANGE,LOG=LOG)
    STRUCT_ASSIGN,T,S,/NOZERO
 
    ; ===> Compute slope and intercept using scale
    IF LOG EQ 1 AND MIN(RANGE) GT 0.0 THEN BEGIN
      SCALED = SCALE(CB_RANGE, ALOG10(RANGE),INTERCEPT=INTERCEPT,SLOPE=SLOPE)
    ENDIF ELSE BEGIN
      LOG = 0
      SCALED = SCALE(CB_RANGE, RANGE,INTERCEPT=INTERCEPT,SLOPE=SLOPE)
      SCALED = ROUNDS(SCALED,3)
    ENDELSE;IF KEYWORD_SET(LOG) AND MIN(_RANGE) NE 0.0 THEN BEGIN
 
    INTERCEPT = ROUNDS(INTERCEPT,4,/SIG) & SLOPE = ROUNDS(SLOPE,4,/SIG)
    V=STRUCT_IT(INTERCEPT,'INTERCEPT')& STRUCT_ASSIGN,V,S,/NOZERO
    V=STRUCT_IT(SLOPE,'SLOPE')& STRUCT_ASSIGN,V,S,/NOZERO
    DATE = STRTRIM(DATE_FORMAT(DATE_NOW(),/YMD,/COMMA),2)
    V=STRUCT_IT(DATE,'DATE')& STRUCT_ASSIGN,V,S,/NOZERO
  ENDIF;IF N_ELEMENTS(PROD) EQ 1 AND IF N_ELEMENTS(RANGE) EQ 2  AND N_ELEMENTS(LOG) EQ 1 THEN BEGIN
      
  RETURN,S  
  DONE:          
END; #####################  END OF ROUTINE ################################
