; $ID:	COMPOSITE_PHYTO.PRO,	2021-04-15-17,	USER-KJWH	$

PRO COMPOSITE_PHYTO, FILES, MP=MP, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, YEARS=YEARS, MONTHS=MONTHS,YEARS_ON_TOP=YEARS_ON_TOP,$
                        PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, $
                        ADD_LAND=ADD_LAND, ADD_COAST=ADD_COAST, NO_COLORBAR=NO_COLORBAR, SPACE=SPACE, BUFFER=BUFFER, VERBOSE=VERBOSE, ERROR=ERROR, OVERWRITE=OVERWRITE

;+
; NAME:
;   COMPOSITE_PHYTO
;
; PURPOSE:
;   This procedure creates a composite of the phytoplankton concentrations and percent data derived from PHYTO_COMMUNITY_PAN
;
; CATEGORY:
;   PLOTTING
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;   
;
; OPTIONAL INPUTS:
;  
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   
;
; OPTIONAL OUTPUTS:
;   
;
; PROCEDURE:
;
; EXAMPLE:
;
;
; NOTES:
;
;
;COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
; 
;
; MODIFICATION HISTORY:
;     Written:  Feb 04, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;     Modified: Feb 07, 2018 - KJWH: Changed name to COMPOSITE_PHYTO to be consistent with other composite programs and easier to find
;               
;               
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'COMPOSITE_PHYTO'
  SL = PATH_SEP()
  
  IF NONE(FONT_SIZE)      THEN FONT_SIZE = 16
  IF NONE(CFONT_SIZE)     THEN CFONT_SIZE = 12
  IF NONE(ADD_LAND)       THEN ADD_LAND = 1
  IF NONE(ADD_COAST)      THEN ADD_COAST = 1
  IF NONE(PAL)            THEN PAL = 'PAL_BR'
  RGB = CPAL_READ(PAL)
  
  ALL =   ['BROWN_PERCENTAGE','BROWN_ALGAE','DIATOM','DIATOM_PERCENTAGE','DINOFLAGELLATE_A','DINOFLAGELLATE_B','DINOFLAGELLATE','DINOFLAGELLATE_PERCENTAGE','CHLOROPHYTE',$
           'CRYPTOPHYTE','CRYPTOPHYTE_PERCENTAGE','CYANOBACTERIA','GREEN_ALGAE','GREEN_PERCENTAGE','HAPTOPHYTE_A','HAPTOPHYTE_B','PRASINOPHYTE_A','PRASINOPHYTE_B','PROCHLOROPHYTE',$
           'MICRO','MICRO_PERCENTAGE','NANO','NANO_PERCENTAGE','PICO','PICO_PERCENTAGE','NANOPICO','NANOPICO_PERCENTAGE']
  OK = WHERE_STRING(ALL,'PERCENTAGE',COUNT,COMPLEMENT=COMPLEMENT)
  PHYTO   = ALL(COMPLEMENT)
  PERCENT = ALL[OK]
       
  LOOPS = ['PHY','PER']
  
  FOR NTH=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[NTH]
    FP = PARSE_IT(AFILE,/ALL)
    IF FP.PERIOD_CODE NE 'D' THEN CONTINUE ; CURRENTLY ONLY WORKS WITH DAILY COMBINED FILES
    IF FP.PROD NE 'PHYTO' THEN CONTINUE ; THIS COMPOSITING ROUTINE CURRENTLY ONLY WORKS WITH THE COMBINED DAILY PIGMENTS FILES 
    
    IF NONE(MP) THEN AMAP = FP.MAP ELSE AMAP = MP
    IF IS_L3B(AMAP) THEN AMAP = 'NWA'
    
    IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FP[0].DIR,['SAVE','STATS'],['COMPOSITES','COMPOSITES']) & DIR_TEST, DIR_OUT ; DEFAULT LOCATION FOR OUTPUT COMPOSITES
    
  
    OUTFILES = DIR_OUT + FP.NAME + '-' + ['COMPOSITE','PERCENT-COMPOSITE'] + '.PNG'
    IF FILE_MAKE(AFILE,OUTFILES,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    D = STRUCT_READ(AFILE,STRUCT=S,MAP_OUT=AMAP)

    FOR L=0, N_ELEMENTS(LOOPS)-1 DO BEGIN
      CASE LOOPS(L) OF
        'PHY': BEGIN 
          PRODS   = PHYTO
          OUTFILE = DIR_OUT + FP.NAME + '-' + 'COMPOSITE' + '.PNG' 
          PROD    = 'PIGMENTS_0.001_3' 
          NCOLS   = 6
          NROWS   = 3
        END
        'PER': BEGIN 
          PRODS   = PERCENT 
          OUTFILE = DIR_OUT + FP.NAME + '-' + 'PERCENT-COMPOSITE' + '.PNG' 
          PROD    = 'PERCENT_0_1'
          NCOLS   = 3
          NROWS   = 3
        END 
      ENDCASE
    
      IF FILE_MAKE(AFILE,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
      ; ===> SET UP PLOT SPACING
      IF NONE(BUFFER) THEN BUFFER = 0 ; Do plotting in background
      IF NONE(SPACE)  THEN SPACE  = 10
      IF NONE(LEFT)   THEN LEFT   = SPACE * 3
      IF NONE(RIGHT)  THEN RIGHT  = SPACE * 3
      IF NONE(TOP)    THEN TOP    = SPACE * 4
      IF NONE(BOTTOM) THEN IF NOT KEYWORD_SET(NO_COLORBAR) THEN BOTTOM = SPACE * 8 ELSE BOTTOM = SPACE * 3
      IF NONE(XDIM)   THEN XDIM   = 200
      IF NONE(YDIM)   THEN YDIM   = XDIM
      XNSPACE = NCOLS-1 & YNSPACE = NROWS-1
      WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
      HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP
          
      W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
      COUNTER = 0
    
      FOR G=0, N_ELEMENTS(PRODS)-1 DO BEGIN
        DAT = GET(S,PRODS(G))
        C = G MOD NCOLS           ; Number of columns is associated with the number of months so C represents the column number
        XPOS = LEFT + C*XDIM + C*SPACE  ; Determine the left side of the image
        IF C EQ 0 THEN R = G/NCOLS ELSE R = 0 ; When C = 0, start a new row
        IF C EQ 0 THEN YPOS = HEIGHT - TOP - R*YDIM - R*SPACE ELSE YPOS = YPOS ; Determine the top position of the image
        POS = [XPOS,YPOS-YDIM,XPOS+XDIM,YPOS]  
        IM = PRODS_2BYTE(DAT, PROD=PROD, MP=AMAP, ADD_LAND=ADD_LAND, ADD_COAST=ADD_COAST)          ; Extract data and convert to BYTE     
        IMG = IMAGE(IM, RGB_TABLE=RGB, POSITION=POS, BUFFER=BUFFER, /DEVICE, /CURRENT)
        TXT = TEXT(XPOS+SPACE/2,YPOS-SPACE*2,PRODS(G),FONT_SIZE=CFONT_SIZE,/DEVICE)
      ENDFOR ; PRODS
    
      CBPOS = [WIDTH*.25, BOTTOM*.65, WIDTH*.75, BOTTOM*.95]
      IF NOT KEYWORD_SET(NO_COLORBAR) THEN PRODS_COLORBAR, PROD, IMG=IMG, POSITION=CBPOS, TEXTPOS=0, FONT_SIZE=CFONT_SIZE, TITLE=TITLE, TICKDIR=0,/DEVICE
    
      PFILE, OUTFILE, /W
      W.SAVE, OUTFILE, RESOLUTION=RESOLUTION
      W.CLOSE
    ENDFOR ; LOOP
  ENDFOR ; FILES

  DONE:
  
END; #####################  End of Routine ################################
