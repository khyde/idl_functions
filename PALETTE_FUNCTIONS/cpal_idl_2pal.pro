; $ID:	CPAL_IDL_2PAL.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CPAL_IDL_2PAL, NUM, NO_GRAY=NO_GRAY, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_IDL_2PAL
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = CPAL_IDL_2PAL($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 28, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 28, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_IDL_2PAL'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  

  IF N_ELEMENTS(NUM) EQ 0 THEN NUM = INDGEN(74) ; As of 7/28/21, there are 75 IDL color palettes

  FOR C=0, N_ELEMENTS(NUM) DO BEGIN
    PNAME = 'pal_idl' + NUM2STR(C)
    IF FILE_TEST(!S.PALETTE_FUNCTIONS+PNAME+ '.pro') AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
    LOADCT, NUM[C], RGB_TABLE=RGB
    
    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & GG = RR & BB = RR
    RR = RGB[*,0]
    GG = RGB[*,1]
    BB = RGB[*,2]
    
    ; ===> Fill in the beginning (0=black) and end (250-255=shades of gray) of the new palette
    IF ~KEYWORD_SET(NO_GRAY) THEN BEGIN
      SUBS = [0,251,252,253,254,255]
      CLRS = [0,128,160,192,224,255]
      RR[SUBS] = CLRS
      GG[SUBS] = CLRS
      BB[SUBS] = CLRS
    ENDIF
    
    PRINT, 'Viewing ' + PNAME
    TVLCT, RR, GG, BB
    CPAL_COLORBOX,DELAY=2

    CPAL_WRITE,PNAME,RR,GG,BB
    PFILE,PNAME
    
  ENDFOR



END ; ***************** End of CPAL_IDL_2PAL *****************
