; $ID:	CPAL_COLORBOX.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CPAL_COLORBOX, PAL, DIMS=DIMS, COLOR=COLOR, ADD_NUMBERS=ADD_NUMBERS, NOCLOSE=NOCLOSE, PNG=PNG, OVERWRITE=OVERWRITE, DELAY=DELAY, ADDRGB=ADDRGB, BUFFER=BUFFER

;+
; NAME:
;   CPAL_COLORBOX
;
; PURPOSE:
;   Makes a numbered color box illustrating the 256 colors in a color palette
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = PALS_COLORBOX($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   PAL........... The name of the color palette to show in the box
;   DIMS.......... Dimesnions of the output image
;
; KEYWORD PARAMETERS:
;   PNG........... Keyword to save the file as a PNG
;   ADD_NUMBERS... Keyword to add the number of each box to the image
;
; OUTPUTS:
;   An image with the different colors in a color palette with or without numbers
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 14, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 14, 2021 - KJWH: Initial code written - adapted from COLORBOX
;   Jul 26, 2021 - KJHW: Updated the output directory for the saved colorbox
;                        Changed NO_NUMBER to ADD_NUMBERS so that the default is to not display the numbers
;   Aug 31, 2021 - KJWH: Now saving a PNG if not found in the PLOTS folder
;                        Now works with the palette name without starting the "pal" (e.g. CPAL_COLORBOX, 'DEFAULT' instead of 'PAL_DEFAULT')
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_COLORBOX'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(BUFFER) THEN BUFFER = 0
  IF KEYWORD_SET(PNG) THEN BUFFER = 1
  IF BUFFER EQ 1 THEN DELAY = 0
  IF ~N_ELEMENTS(DELAY) THEN DELAY = 5
  
  ; ===> Get the palette RGBs
  IF N_ELEMENTS(PAL) EQ 1 THEN BEGIN
    IF STRMID(STRUPCASE(PAL),0,4) NE 'PAL_' AND STRMID(STRUPCASE(PAL),0,3) NE 'CP_' THEN PAL = 'PAL_' + STRUPCASE(PAL)
    PALFILE = !S.PALETTE_FUNCTIONS + PAL + '.pro' 
    PNGFILE = !S.IDL_PALETTES + 'PLOTS' + SL + PAL + '-colorbox.png' 
    IF ~FILE_TEST(PALFILE) THEN MESSAGE, 'ERROR: ' + PALFILE + ' not found.'
    
    IF FILE_MAKE(PALFILE,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN
      I = READ_PNG(PNGFILE, R,G,B)
      IMG = IMAGE(I, RGB_TABLE=GET_RGB_TABLE(PAL),BUFFER=BUFFER)
      WAIT, DELAY
      IMG.CLOSE
      GOTO, DONE
    ENDIF
    CD, !S.PALETTE_FUNCTIONS
    CALL_PROCEDURE,PAL,R,G,B
    CD, !S.IDL_FUNCTIONS
  ENDIF ELSE BEGIN
    TVLCT,R,G,B,/GET
    PNGFILE = []
  ENDELSE
  RGB = BYTARR(3,N_ELEMENTS(R))
  RGB[0,*] = R
  RGB[1,*] = G
  RGB[2,*] = B
  
  ; ===> Create the dimensions for the output image "box"  
  IF KEYWORD_SET(DIMS) THEN BEGIN
    IF N_ELEMENTS(DIMS) EQ 1 THEN DIMS = [DIMS,DIMS]
    IF N_ELEMENTS(DIMS) GE 3 THEN   MESSAGE, 'ERROR: DIMS must have 1,or 2 dimensions'
  ENDIF ELSE DIMS = [600,600]
  _CHARSIZE = 0.8 * (DIMS[0]< DIMS[1])/32.
   
  ; ===> Set up the box details to create the image
  BOX = [256,256] 
  SEED = BYTARR(BOX[1],BOX[0])
  SEED[*,*] = 0B
  IMG = SEED
  
  ; ===> Grow the img array
  FOR I = 1,15  DO BEGIN
    SEED[*,*] = I*16B
    IMG = [IMG,SEED]
  ENDFOR

  IMG = ROTATE(IMG,3) ; Rotate the image
  SEED = IMG

  ; ===> Grow the img array again
  FOR I = 1,15 DO BEGIN
    SEED = SEED + 1B
    IMG = [IMG,SEED]
  ENDFOR;FOR I = 1,15 DO BEGIN
  
  IM = IMAGE(IMG, RGB_TABLE=RGB, DIMENSIONS=DIMS, MARGIN=0, BUFFER=BUFFER)
  
  IF N_ELEMENTS(COLOR) NE 1 THEN CLR = 'WHITE' ELSE CLR = COLOR
  
; ===> Add the number of each cell to the image  
  IF KEYWORD_SET(ADD_NUMBERS) THEN BEGIN
    COUNTER = 0
    FOR I=0,15 DO BEGIN
      FOR J=15, 0, -1 DO BEGIN
        NUM = COUNTER
        TXT1=STRTRIM(NUM,2)
        TXT2=STRTRIM(FIX(R[NUM]),2)+'!C'+STRTRIM(FIX(G[NUM]),2) + '!C'+STRTRIM(FIX(B[NUM]),2)
        
        PX = ((16-J)/16.) - (1/32.)
        PY = 1 - (((I+1)/16.) - (1/32.))
        
        IF KEYWORD_SET(ADDRGB) THEN TXT = TEXT(PX,PY,TXT2,COLOR=CLR,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.5) $
                               ELSE TXT = TEXT(PX,PY,TXT1,COLOR=CLR,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.5)
        
        COUNTER = COUNTER+1
      ENDFOR
    ENDFOR  
  ENDIF

  IF PNGFILE NE [] THEN IF FILE_MAKE(PALFILE,PNGFILE,OVERWRITE=OVERWRITE) THEN IM.SAVE, PNGFILE
  WAIT, DELAY
  IF ~KEYWORD_SET(NOCLOSE) THEN IM.CLOSE
  
  DONE:
  

END ; ***************** End of PALS_COLORBOX *****************
