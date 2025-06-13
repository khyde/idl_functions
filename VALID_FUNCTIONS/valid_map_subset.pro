; $ID:	VALID_MAP_SUBSET.PRO,	2022-10-18-15,	USER-KJWH	$
  FUNCTION VALID_MAP_SUBSET, MAPP, VALID=VALID

;+
; NAME:
;   VALID_MAP_SUBSET
;
; PURPOSE:
;   Look for "subset" maps in file names and return the MAP names based on recognized processing maps (found in MAPS_MAIN)
;
; CATEGORY:
;   VALID_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = VALID_MAP_SUBSET()
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   MAPP......... A string containing the name of the input MAP (could be just the map name itself or a full file name)
;
; KEYWORD PARAMETERS:
;   VALID........ Return a 1 if the map is "valid", 0 if not
;
; OUTPUTS:
;   The list of "valid" maps
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   COMMON _VALIDS, DB
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 18, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 18, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'VALID_MAP_SUBSET'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(MAPP) THEN RETURN, ''
  IF MAX(STRPOS(MAPP,'SUBSET')) LT 0 THEN RETURN, STRARR(N_ELEMENTS(MAPP))  ; If "subset" is not found in the string array, then return blank array
  
  RECOGNIZED = MAPS_READ(/NAMES) + '_SUBSET'
  
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
  

END ; ***************** End of VALID_MAP_SUBSET *****************
