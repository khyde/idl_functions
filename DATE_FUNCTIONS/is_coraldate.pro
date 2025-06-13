; $ID:	IS_CORALDATE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION IS_CORALDATE, TXT, SATDATE=SATDATE

;+
; NAME:
;   IS_CORALDATE
;
; PURPOSE:
;   This function tests if txt string contains a "NOAA Coral Reef Watch satdate" 
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = IS_CORALDATE(TXT)
;
; REQUIRED INPUTS:
;   TXT.......... Text string containing the name of the satellite data file
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Returns a logical value: 1 = true, 0 = false
;
; OPTIONAL OUTPUTS:
;   SATDATE..... Returns the SATDATE from any TRUE results
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
;   PRINT, IS_CORALDATE('coraltemp_v3.1_20220821'); = 1
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
;   This program was written on August 29, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 29, 2022 - KJWH: Initial code written - adapted from IS_NASADATE
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'IS_CORALDATE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  ; ===> Create blank arrays to hold the oupputs
  RESULTS = REPLICATE(0,N_ELEMENTS(TXT))
  SDATES  = REPLICATE('',N_ELEMENTS(TXT))

  ; ===> Standardize the input text
  SATDATE = STRUPCASE(TXT)
  SATDATE = REPLACE(SATDATE,['.','_','-'],[' ',' ',' ']) ; ===> Look for delimiters within the name and replace with blank spaces
  SATDATE = STR_BREAK(SATDATE,' ')
  SZ = SIZE(SATDATE,/DIMENSIONS)
  IF N_ELEMENTS(SZ) EQ 1 THEN RETURN, RESULTS ; Check the dimensions of the "satdate"
  IF SZ[1] LT 4 THEN RETURN, RESULTS          ; CoralReefWatch dates have at least 4 dimensions in the filename

  ; ===> Look for the date/time in the last component
  OK_SAT = WHERE(STRLEN(SATDATE[*,-1]) EQ 8 AND NUMBER(SATDATE[*,-1]) EQ 1,COUNT,COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
  IF COUNT GE 1 THEN BEGIN
    SDATES[OK_SAT] = SATDATE[OK_SAT,-1]
    RESULTS[OK_SAT] = 1
  ENDIF
  
  ; ===> Look for the date/time in the second to last component
  IF NCOMP GT 0 THEN BEGIN
    OK_SAT = WHERE(STRLEN(SATDATE[*,-2]) EQ 8 AND NUMBER(SATDATE[*,-2]) EQ 1,COUNT)
    IF COUNT GE 1 THEN BEGIN
      SDATES[OK_SAT] = SATDATE[OK_SAT,-2]
      RESULTS[OK_SAT] = 1
    ENDIF
  ENDIF

  SATDATE=SDATES
  RETURN, RESULTS


END ; ***************** End of IS_CORALDATE *****************
