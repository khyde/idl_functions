; $ID:	IS_NASADATE.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION IS_NASADATE, TXT, SATDATE=SATDATE

;+
; NAME:
;   IS_NASADATE
;
; PURPOSE:
;   This function tests if txt string contains a "NASA satdate" (which represents the "new" default date structure (as of 2020) for the downloaded NASA satellite files)
;
; CATEGORY:
;   DATE function
;
; CALLING SEQUENCE:
;   Result = IS_NASADATE(TXT)
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
;   PRINT, IS_NASADATE('AQUA_MODIS.20020704T045505.L2.SST4'); = 1
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 13, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 13, 2020 - KJWH: Initial code written
;   Dec 20, 2022 - KJWH: Updated to work with L3 daily files that have an eight digit date
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'IS_NASADATE'
  COMPILE_OPT IDL2

  IF NONE(TXT) THEN MESSAGE,'ERROR: input text is required'
  
; ===> Create blank arrays to hold the oupputs  
  RESULTS = REPLICATE(0,N_ELEMENTS(TXT))
  SDATES  = REPLICATE('',N_ELEMENTS(TXT))
  
; ===> Standardize the input text  
  SATDATE = STRUPCASE(TXT)
  SATDATE = REPLACE(SATDATE,['.','-'],[' ',' ']) ; ===> LOOK FOR DELIMITERS WITHIN THE NAME AND REPLACE WITH BLANK SPACES
  SATDATE = STR_BREAK(SATDATE,' ')
  SZ = SIZE(SATDATE,/DIMENSIONS)
  IF N_ELEMENTS(SZ) EQ 1 THEN RETURN, RESULTS ; Check the dimensions of the "satdate"
  IF SZ[1] LT 3 THEN RETURN, RESULTS          ; "satdata" files have at least 3 dimensions in the filename
  
; ===> Look for the date/time in the third component of the name
  OK_SAT = WHERE(STRLEN(SATDATE[*,1]) EQ 15 OR STRLEN(SATDATE[*,1]) EQ 8 AND VALID_PERIOD_CODES(SATDATE[*,0],/VALID) EQ 0,COUNT)
  IF COUNT GE 1 THEN BEGIN
    SAT = SATDATE[OK_SAT,1]
    RES = RESULTS[OK_SAT]
    
    OK = WHERE(STRLEN(SAT) EQ 8 AND NUMBER(SAT) EQ 1,COUNT,COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
    IF COUNT GE 1 THEN RES[OK] = 1 
    IF NCOMP GE 1 THEN BEGIN
      ; ===> Look for an 8 digit YYYYMMNN, followed by "T", and then a 6 digit time
      OK_DATE = WHERE(NUMBER(STRMID(SAT[COMP],0,8)) EQ 1 AND STRMID(SAT[COMP],8,1) EQ 'T' AND NUMBER(STRMID(SAT[COMP],9,6)) EQ 1, COUNT, NCOMPLEMENT=NCOMP2, COMPLEMENT=COMP2)
      IF COUNT  GE 1 THEN RES[COMP[OK_DATE]] = 1
      IF NCOMP2 GE 1 THEN SAT[COMP[COMP2]]   = '' 
    ENDIF
    
    RESULTS[OK_SAT] = RES
    SDATES[OK_SAT] = SAT
  ENDIF

  SATDATE=SDATES
  RETURN, RESULTS

END ; ***************** End of IS_NASADATE *****************
