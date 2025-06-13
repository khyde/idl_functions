; $ID:	GET_PROJECT_DIR.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION GET_PROJECT_DIR, PROJECT

;+
; NAME:
;   GET_PROJECT_DIR
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = GET_PROJECT_DIR($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 16, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 16, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_PROJECT_DIR'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  SDIR = []
  FOR S=0, N_ELEMENTS(PROJECT)-1 DO BEGIN
    OK = WHERE_MATCH(STRUPCASE(TAG_NAMES(!S)), STRUPCASE(PROJECT[S]),COUNT)
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + PROJECT[S] + ' not found in !S', /CONTINUE
    IF COUNT EQ 0 THEN SDIR = [SDIR,''] ELSE SDIR = [SDIR,!S.(OK)]
  ENDFOR

  RETURN, SDIR


END ; ***************** End of GET_PROJECT_DIR *****************
