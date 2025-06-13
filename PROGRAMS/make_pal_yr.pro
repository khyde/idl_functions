; $ID:	MAKE_PAL_YR.PRO,	2020-07-08-15,	USER-KJWH	$

PRO MAKE_PAL_YR, YEARS, RANGE=range, BAR=bar, VIEW=view
;+
; NAME:
;   MAKE_PAL_YR
;
; PURPOSE:;
;   This procedure will create a color palette based on the number of years in a date range.  
;
; CALLING SEQUENCE:
;   PAL_MAKE_YR, 5
;   PAL_MAKE_YR, RANGE=['1998','2008']
;   
; INPUTS:
;   YEARS:  Number of years or colors to divide the color bar into
;   RANGE:  Date range (used to calculate the number of years)
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;   This procudre creates a color palette that is saved in IDL/PROGRAMS.  Palette is named based on the number of years/colors.
;
; EXAMPLE:
;   MAKE_PAL_YR, 5 creates a new program named PAL_Y5.PRO
;
; MODIFICATION HISTORY:
;     Written Dec 3, 2009 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
; ****************************************************************************************************


  PAL_GRAY,RR,GG,BB     ; Load a generic color palette
  PAL_SW3,R,G,B         ; Load PAL_SW3 as the palette to get the colors from
  
  
; Determine the number of years of the date range  
  IF N_ELEMENTS(YEARS) NE 1 THEN NYEARS = 10 ELSE NYEARS = YEARS
  IF N_ELEMENTS(RANGE) EQ 2 THEN BEGIN
    MINYR = STRMID(RANGE[0],0,4)
    MAXYR = STRMID(RANGE[1],0,4)
    DIF   = FIX(MAXYR)-FIX(MINYR)
    NYEARS = DIF + 1
  ENDIF ELSE RANGE = [0,0] 
  IF NYEARS GT 250 THEN STOP
  
; Determine the width of each division based on the number of years and a color range of 1-250  
  NCOLORS = 250
  WIDTH   = ROUND(NCOLORS/NYEARS)    ; Width of the color range
  EDGE    = (250-(WIDTH*NYEARS))/2  
  SCOLOR  = 1 + EDGE                 ; Starting color
  ECOLOR  = SCOLOR+WIDTH-1           ; Ending color
  IF EDGE GT 0 THEN BEGIN
    RR(1:SCOLOR-1) = 255 & RR(SCOLOR) = 0
    GG(1:SCOLOR-1) = 255 & GG(SCOLOR) = 0
    BB(1:SCOLOR-1) = 255 & BB(SCOLOR) = 0
  ENDIF  
  FOR NTH = 0L, NYEARS-1 DO BEGIN
    MCOLOR = (SCOLOR+ECOLOR)/2
PRINT, SCOLOR, ECOLOR, WIDTH    
    RR(SCOLOR:ECOLOR-1) = R(MCOLOR) & RR(ECOLOR) = 0  ; Fill in the width with a single color and create a black bar inbetween colors
    GG(SCOLOR:ECOLOR-1) = G(MCOLOR) & GG(ECOLOR) = 0
    BB(SCOLOR:ECOLOR-1) = B(MCOLOR) & BB(ECOLOR) = 0
    SCOLOR = SCOLOR + WIDTH     
    ECOLOR = ECOLOR + WIDTH  
  ENDFOR  
    
; Fill in the remaining colors from the last ECOLOR to 250 with the last color used
  ENDCOLOR = 250-EDGE
  IF EDGE GT 0 THEN BEGIN
    RR(ENDCOLOR+1:250) = 255 & RR(ENDCOLOR) = R(MCOLOR)
    GG(ENDCOLOR+1:250) = 255 & GG(ENDCOLOR) = B(MCOLOR)
    BB(ENDCOLOR+1:250) = 255 & BB(ENDCOLOR) = G(MCOLOR)
  ENDIF  

; Fill in 'grey' colors with those from PAL_SW3
  RR(250:255) = R(250:255)
  GG(250:255) = G(250:255)
  BB(250:255) = B(250:255)
PRINT, 250-ENDCOLOR
PRINT, EDGE  
  
  PAL = 'pal_y'+NUM2STR(NYEARS)   ; Palette named saved in D:\IDL\PROGRAMS
  WRITEPAL,PAL,RR,GG,BB           ; Create the new color palette
    
  ; Make demo colorbar with new palette
  CALL_PROCEDURE, PAL,R,G,B  
  IF N_ELEMENTS(MINYR) EQ 0 THEN RANGE[0] = 2000
  IF N_ELEMENTS(MAXYR) EQ 0 THEN RANGE[1] = RANGE[0] + NYEARS - 1
  
  ; Create a special scale name based on the date range
  SPECIAL_SCALE = '!Y_'+NUM2STR(RANGE[0])+'_'+NUM2STR(RANGE[1])
  BAR = COLOR_BAR_SCALE(PROD='JD',/NO_UNIT,PAL=PAL,BACKGROUND=255,SPECIAL_SCALE=SPECIAL_SCALE,TITLE='YEAR')
  IF KEYWORD_SET(VIEW) THEN SLIDEW, BAR

END
