; $ID:	VALID_PXYZ.PRO,	2021-09-21-11,	USER-KJWH	$

FUNCTION VALID_PXYZ, INFO, VALID=VALID

;
;+
; NAME
;   VALID_PXYZ
;   
; PURPOSE: 
;   This function returns the PX, PY, & PZ based on the recognized PXYZ VALUES ['PXY','PXYZ']
; 
; CATEGORY
;   VALIDS FUNCTIONS
;   
; REQUIRED INPUTS
;   None
;        
; OPTIONAL INPUTS
;   INFO............ A text string to search for the PX, PY and PZ information
;   
; KEYWORD PARAMETERS
;   VALID........... Return a 0 or 1 if the input INFO is not valid or is valid (respectively)
; 
; OUTPUTS
;   Returns the "valid" PX, PY and PZ values
;   
; OPTIONAL OUTPUTS
;   Returns a 0 or 1 depending on the "valid" status  
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
;  PRINT,VALID_PXYZ()
;  F = 'D3-PXYZ_1024_1024_364-NEC-CHLOR_A-MEM.FLT' & F = [F,F,'PXY_1024_1024','Z_1024_1024_364'] & SPREAD,VALID_PXYZ(F)
;  F = 'D3-PXYZ_1024_1024_364-NEC-CHLOR_A-MEM.FLT' & F = [F,F,'PXY_1024_1024','Z_1024_1024_364'] & PRINT,VALID_PXYZ(F,/VALID)
;
; NOTES:
;  This program replaces VALID_PXY
;  
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 25, 2015 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov.
;
; MODIFICATION HISTORY:
;   FEB 25, 2015 - JEOR: Initial code written - adapted from VALID_PXY
;   SEP 21, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;   JAN 09, 2023 - KJWH: Added the PXY and PXYZ label to the output structure                     
;-

; ******************************************************************************************
  ROUTINE_NAME='VALID_PXYZ'
  COMPILE_OPT IDL2

; ===> List the "recognized" PXYZ info that may be found in the input text
  RECOGNIZED = ['PXY','PXYZ']
  IF ~N_ELEMENTS(INFO) THEN RETURN, RECOGNIZED
  
  N = N_ELEMENTS(INFO)
  S = CREATE_STRUCT('PXY','','PXYZ','','PX','','PY','','PZ','')
  IF N EQ 0 THEN RETURN, S

; ===> Replicate valid_info and the structure
  VALID_INFO = REPLICATE(0,N)
  S = REPLICATE(S,N)

; ===> Find which info has the recognized phrases
  OK_REC = WHERE_STRING(INFO,RECOGNIZED,N_REC)

; ===> Loop through the number of "recognized" phrases
  FOR NTH = 0L,N_REC-1L DO BEGIN 
    WDS = WORDS(INFO[NTH])                              ; Get the "words" ("words" are always delimited by '-')
    
    ; ===> find which word has recognized
    OK_REC = WHERE_STRING(WDS,RECOGNIZED,COUNT_REC)
    IF COUNT_REC EQ 1 THEN BEGIN
      T = STR_SEP(WDS[OK_REC],'_')
      SUB = WHERE_IN(T,RECOGNIZED,CT)                                         ; Find the subscript in T that has the recognized phrase   
      IF CT EQ 1 THEN BEGIN
        S[NTH].PX = T[SUB+1]                                                  ; Add the PX value
        S[NTH].PY = T[SUB+2]                                                  ; Add the PY value
        IF N_ELEMENTS(T) GE 4 AND NUMBER(T[SUB+3]) THEN BEGIN  ; Add the PZ value
          S[NTH].PZ = T[SUB+3]
          S[NTH].PXYZ = WDS[OK_REC]
        ENDIF ELSE S[NTH].PXY = WDS[OK_REC]
        VALID_INFO[NTH] = 1     
      ENDIF ; CT 
    ENDIF ;COUNT_REC
  ENDFOR ; N_REC
  
  IF KEYWORD_SET(VALID) THEN RETURN, VALID_INFO
  
; ===> Clean up the output struct by removing the PXY or PXYZ tags if they are completely blank
  OKXY = WHERE(S.PXY EQ '',COUNTXY)
  OKXYZ = WHERE(S.PXYZ EQ '',COUNTXYZ)
  IF COUNTXY EQ N_ELEMENTS(S) THEN S = STRUCT_COPY(S,'PXY',/REMOVE)
  IF COUNTXYZ EQ N_ELEMENTS(S) THEN S = STRUCT_COPY(S,'PXYZ',/REMOVE)

  IF N_ELEMENTS(S) EQ 1 THEN RETURN,S[0] ELSE RETURN, S

END; #####################  END OF ROUTINE ################################
