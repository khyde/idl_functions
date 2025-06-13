; $ID:	CPAL_DISCRETE.PRO,	2023-09-21-13,	USER-KJWH	$
PRO CPAL_DISCRETE, NUM, PAL=PAL,COLORS=COLORS, FILENAME=FILENAME, SUFFIX=SUFFIX, VIEW=VIEW, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_DISCRETE
;
; PURPOSE: 
;   Create a discrete color palette based on the number of requested sections  
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   CPAL_DISCRETE, 5
;   
; REQUIRED INPUTS:
;   NUM.......... The number of discrete colors to divide the palette into
;
; OPTIONAL INPUTS:
;   PAL.......... The color palette to "borrow" the colors from
;   COLORS....... An array of color names or indices for extracting colors from PAL_SOURCE
;   SUFFIX....... The suffix to add to the name of the palette
;   FILENAME..... The name of the palette program to use instead of the default
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite the palette if it already exists
;   VIEW......... Calls CPAL_VIEW to display the palette and then CBAR to view it as a colorbar
;
; OUTPUTS:
;   A new color palette saved in !S.PALETTE_FUNCTIONS  
;   
; OPTIONAL OUTPUTS:
;   Temporary visualizations displaying the colorpalette  
;
;; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;   CPAL_DISCRETE, 5 ;CREATES A NEW PROGRAM NAMED PAL_5.PRO
;   CPAL_DISCRETE, 5,/VIEW
;   CPAL_DISCRETE, 5,/VIEW,PAL_SOURCE = 'PAL_36'
;   CPAL_DISCRETE, 5,/VIEW,COLORS =['GREEN','AQUA','YELLOW','BLUE','RED']
;   CPAL_DISCRETE, 5,/VIEW,COLORS =['GREEN','GREEN','GREEN','GREEN','GREEN']; FOR TESTING
;   CPAL_DISCRETE, 7,/VIEW,COLORS =['ORANGE','GOLD','YELLOW','AQUA','TOMATO','CRIMSON','MAROON']
;   CPAL_DISCRETE, 7,/VIEW,COLORS =['ORANGE','GOLD','YELLOW','AQUA','TOMATO','CRIMSON','MAROON'],SUFFIX = '_UGLY'
;   CPAL_DISCRETE, 2,/VIEW,COLORS =['BLUE','RED']
; 
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2009, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 3, 2009 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   DEC 03, 2009 - KJWH: Initial code written
;   JUL 07, 2014 - JEOR: Renamed from PAL_MAKE_YR to PAL_DISCRETE
;                        Updated formatting
;                        Added OUTPUT NAME = 'PAL_'+STRTRIM(NUM,2)
;                        Added PALS_WRITE which adds 'PAL_' to the name
;                        Added PAL = STRTRIM(NUM,2) (Removed the 'Y') 
;                        Now using PAL_VIEW & PALS_WRITE
;   JUL 09, 2014 - JEOR: Added more examples for COLORS
;                        Added IF NONE(COLORS) THEN RR(ENDCOLOR) = R(MCOLOR)
;                        Added the keyword SUFFIX
;                        Added a check for the number of COLORS
;   NOV 13, 2014 - JEOR: Added IF KEY(VIEW) THEN CPAL_VIEW,'PAL_' +PAL
;   JUL 19, 2021 - KJWH: Updated documentation & formatting
;                        Streamlined the code
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Now always starting colors at 1.  If needed, the last color may extend beyond 250
;                        Added FILENAME as an optional input to force the output name
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_DISCRETE'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(COLORS)     GT 0 THEN NUM = N_ELEMENTS(COLORS) ELSE COLORS = []
  IF N_ELEMENTS(NUM)        NE 1 THEN MESSAGE,'ERROR: Either NUM or an array of COLORS is required.'
  IF N_ELEMENTS(SUFFIX)     NE 1 THEN SUFFIX = ''
  IF N_ELEMENTS(PAL)        NE 1 THEN PAL = 'PAL_DEFAULT' 

  IF KEYWORD_SET(COLORS) THEN PALFILE = STRLOWCASE('PAL_COLORS_STEP_' + NUM2STR(N_ELEMENTS(COLORS))) $
                         ELSE PALFILE = STRLOWCASE(PAL + '_STEP_' + NUM2STR(NUM))
  
  
  IF FILE_TEST(!S.PALETTE_FUNCTIONS + PALFILE + '.pro') EQ 1 AND ~KEYWORD_SET(OVERWRITE) THEN BEGIN
    PRINT, !S.PALETTE_FUNCTIONS + PALFILE + '.pro already exists.'
    I = CPAL_COLORBOX(PAL=PALFILE)
    GOTO, DONE
  ENDIF
  
  PAL_DEFAULT,RR,GG,BB             ; Load a generic color palette for the RGB arrays 
  CALL_PROCEDURE,PAL,R,G,B         ; Load the source palette
  
  ;===> Get the "greys" at the "end" of the palette
  ERR = R[251:255]
  EGG = G[251:255]
  EBB = B[251:255]

  ; ===> Get the RGBs for the specified coors
  IF KEYWORD_SET(COLORS) THEN BEGIN
    RGB = RGBS(COLORS)
    R = REFORM(RGB[0,*]) & G = REFORM(RGB[1,*]) & B = REFORM(RGB[2,*])
  ENDIF 

; ===> Determine the width of each division based on the a color range of 1-250  
  NCOLORS = 250
  WIDTH   = ROUND(NCOLORS/FLOAT(NUM))    
  COUNTER = 0
  RERUN:
  SCOLOR  = 1                        ; The starting color
  ECOLOR  = SCOLOR+WIDTH-1           ; The last color of the first division
    
  FOR NTH=0, NUM-1 DO BEGIN
    IF KEYWORD_SET(COLORS) THEN BEGIN
      RR[SCOLOR:ECOLOR] = R[NTH] 
      GG[SCOLOR:ECOLOR] = G[NTH] 
      BB[SCOLOR:ECOLOR] = B[NTH] 
    ENDIF ELSE BEGIN
      MCOLOR = (SCOLOR+ECOLOR)/2 ; Use the "middle" color in-between the start and end color
      RR[SCOLOR:ECOLOR] = R[MCOLOR] 
      GG[SCOLOR:ECOLOR] = G[MCOLOR] 
      BB[SCOLOR:ECOLOR] = B[MCOLOR] 
    ENDELSE
    
    IF ECOLOR GT 255 THEN BEGIN
      WIDTH = WIDTH-1
      GOTO, RERUN
    ENDIF
    
    SCOLOR = SCOLOR + WIDTH     
    ECOLOR = ECOLOR + WIDTH
    
  ENDFOR;FOR NTH = 0L, NUM-1 DO BEGIN
    
  ; ===> Fill in the remaining colors from the last ecolor to 250 with the last color used
  IF SCOLOR LE 250 AND N_ELEMENTS(COLORS) EQ 0 THEN BEGIN
    RR[SCOLOR:250] = R[MCOLOR] 
    GG[SCOLOR:250] = G[MCOLOR] 
    BB[SCOLOR:250] = B[MCOLOR] 
  ENDIF   

  ; ===> Fill in the end 'grey' colors with those from pal_source
  RR[251:255] = ERR
  GG[251:255] = EGG
  BB[251:255] = EBB
  
  ; ===> View the new color palette
  TVLCT, RR, GG, BB
  CPAL_COLORBOX,DELAY=4 

  ; ===> Save the new color palette
  CPAL_WRITE,PALFILE,RR,GG,BB           

  DONE:
  
END; #####################  END OF ROUTINE ################################
