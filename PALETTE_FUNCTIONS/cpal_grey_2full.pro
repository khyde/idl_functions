; $ID:	CPAL_GREY_2FULL.PRO,	2024-12-13-14,	USER-KJWH	$
  PRO CPAL_GREY_2FULL, PALS, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_GREY_2FULL
;
; PURPOSE:
;   Convert a color palette with "greys" at the end to a full spectrum color palette
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   CPAL_GREY_2FULL,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   PAL....... The name of a color palette 
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
; Copyright (C) 2024, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 13, 2024 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 13, 2024 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_GREY_2FULL'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  FOR L=0, N_ELEMENTS(PALS)-1 DO BEGIN
    PAL = PALS[L]
    IF FILE_TEST(!S.PALETTE_FUNCTIONS + STRLOWCASE(PAL) + '.pro') EQ 0 THEN BEGIN
      MESSAGE, 'ERROR: ' + PAL + '.pro not found in ' + !S.PALETTE_FUNCTIONS, /CONTINUE
      CONTINUE
    ENDIF
    
    INFILE = !S.PALETTE_FUNCTIONS + STRLOWCASE(PAL) + '.pro'
    OUTFILE = !S.PALETTE_FUNCTIONS + REPLACE(STRLOWCASE(PAL),'pal_','cp_') + '.pro'
    IF FILE_MAKE(INFILE,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
    RGB = CPAL_READ(PAL,R=R,G=G,B=B)
    
    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR[*]=-1
    GG = RR
    BB = RR
    
    ; ===> Replace the first black pixel and interpolate between the first two colors
    RR[0] = R[1] & GG[0] = G[1] & BB[0] = B[1]   ; Make the spot the first true color (RGB[0] is typically black)
    RR[2] = R[2] & GG[2] = G[2] & BB[2] = B[2]   ; Make the third spot the second true color
    
    R[0:2] = INTERPOL(RR[[0,2]],[0,2],INDGEN(3)) ; Interpolate between the first two true colors to fill in the first three spots
    G[0:2] = INTERPOL(GG[[0,2]],[0,2],INDGEN(3))
    B[0:2] = INTERPOL(BB[[0,2]],[0,2],INDGEN(3))
    
    
    ; ===> Replace the grey pixels at the end with true colors
    RR[0:240] = R[0:240] & GG[0:240] = G[0:240] & BB[0:240] = B[0:240]   ; Fill in the RR/GG/BB arrays
    
    ; ===> Spread out the colors towards the end
    CLRS = [240,242,246,248,250]
    SUBS = [240,244,248,252,255]
    FOR N=1, N_ELEMENTS(CLRS)-1 DO BEGIN
      RR[SUBS[N]] = R[CLRS[N]]
      GG[SUBS[N]] = G[CLRS[N]]
      BB[SUBS[N]] = B[CLRS[N]]
    ENDFOR
        
    INTERVALS = WHERE(RR NE -1) ; Find the missing pixels
    R[0:255] = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
    G[0:255] = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
    B[0:255] = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))
        
        
    ; ===> View the new color palette
    TVLCT, R, G, B
   ; CPAL_COLORBOX,DELAY=3, BUFFER=1
  
    ; ===> Save the new color palette
    CPAL_WRITE, REPLACE(STRLOWCASE(PAL),'pal_','cp_'),R,G,B
    CPAL_COLORBOX, REPLACE(STRLOWCASE(PAL),'pal_','cp_'), /PNG
    ;CPAL_REVERSE, 'pal_navy_gold_full', outname='pal_gold_navy_full'
  ENDFOR  


END ; ***************** End of CPAL_GREY_2FULL *****************
