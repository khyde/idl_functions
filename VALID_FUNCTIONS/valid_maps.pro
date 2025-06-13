; $ID:	VALID_MAPS.PRO,	2020-06-30-17,	USER-KJWH	$
;##########################################################################
FUNCTION VALID_MAPS, MAPP ,VALID=VALID
;+
; NAME:
;   VALID_MAPS
;   
; PURPOSE:
;   This function returns MAP names based on recognized processing maps (found in MAPS_MAIN)
; 
; CATEGORY:
;   VALID_FUNCTIONS
;   
; CALLING SEQUENCE:
;   Result = VALID_MAPS()
; 
; REQUIRED INPUTS:
;   None
;    
; OPTIONAL INPUS:
;   MAPP......... A string containing the name of the input MAP (could be just the map name itself or a full file name)
;    
; KEYWORD_PARAMETERS
;   VALID........ Return a 1 if the map is "valid", 0 if not
;
; OUTPUTS:
;   The list of "valid" maps
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
;   PRINT, VALID_MAPS()
;   PRINT, VALID_MAPS('NORTHEAST_US_CONTINENTAL_SHELF_J')
;   PRINT, VALID_MAPS('LME_NORTHEAST_US_CONTINENTAL_SHELF')
;   PRINT, VALID_MAPS('NEC')
;   PRINT, VALID_MAPS(['NEC','EC','SMI','JUNK'],/VALID)
;   PRINT, VALID_MAPS(['FILE-NEC'])
;   PRINT, VALID_MAPS(['LME_BALTIC_SEA','BALTIC_SEA_J','NEC']); 
;
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 12, 2003 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   JUN 12, 2003 - JEOR: Initial code written
;   NOV 21, 2013 - JEOR: Added keyword OLD
;   NOV 27, 2013 - JEOR: Added RECOGNIZED= MAPS_READ(/NAMES)
;   JAN 18, 2014 - JEOR: Changed TEXT to TXT
;   DEC 10, 2014 - JEOR: Overhauled script
;                        Removed keyword OLD and all the "old" map info
;   OCT 18, 2022 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL
;                        Moved to VALIDS_FUNCTIONS
; ***********************************************************************************
;-
  ROUTINE_NAME  = 'VALID_MAPS'
  COMPILE_OPT IDL2
  
  RECOGNIZED= MAPS_READ(/NAMES)
  IF ~N_ELEMENTS(MAPP) THEN RETURN, RECOGNIZED

  TXT = STRARR(N_ELEMENTS(MAPP)) & BVALID = BYTARR(N_ELEMENTS(MAPP))
  DELIM = DELIMITER(/DASH) &  SP_DELIM = ['',DELIM]
  WORD  = WORDS(STRUPCASE(MAPP),LINE=LINE) & OK = WHERE_MATCH(RECOGNIZED,STRUPCASE(WORD),COUNT,VALID=SUBS_VALID)
  U     = UNIQ(LINE)            & NU=N_ELEMENTS(U)          & OUT = STRARR(NU)
  IF COUNT GE 1 THEN BEGIN
    FOR NTH = 0L,N_ELEMENTS(SUBS_VALID)-1L DO BEGIN
      OUT[LINE[SUBS_VALID[NTH]]] = OUT[LINE[SUBS_VALID[NTH]]] + SP_DELIM[OUT[LINE[SUBS_VALID[NTH]]] NE '']+ WORD[SUBS_VALID[NTH]]
      BVALID[LINE[SUBS_VALID[NTH]]] = BVALID[LINE[SUBS_VALID[NTH]]] +1
    ENDFOR;FOR NTH = 0L,N_ELEMENTS(SUBS_VALID)-1L DO BEGIN
  ENDIF;IF COUNT GE 1 THEN BEGIN

  IF KEY(VALID) THEN BEGIN
      IF N_ELEMENTS(BVALID) EQ 1 THEN RETURN, BVALID[0] ELSE RETURN, BVALID
  ENDIF;IF KEY(VALID) THEN BEGIN

  IF N_ELEMENTS(OUT) EQ 1 THEN RETURN,OUT[0] ELSE RETURN, OUT
  
END; #####################  END OF ROUTINE ################################
