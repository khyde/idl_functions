; $ID:	CPAL_RGB_2PAL.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CPAL_RGB_2PAL, RGBFILE, PALNAME=PALNAME, GRAYFILL=GRAYFILL, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_RGB_2PAL
;
; PURPOSE:
;   Convert a .rgb file to a pal_*.pro file
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   PALS_RGB_2PAL
;
; REQUIRED INPUTS:
;   None.......... If no input files are provided, the program will search for files in !S.PALETTES/RGB/ and loop through all files
;
; OPTIONAL INPUTS:
;   RGBFILE....... The name of the .rgb file 
;   PALNAME....... The name of the output pal_*.pro file
;
; KEYWORD PARAMETERS:
;   GRAYFILL...... Add "gray" colors at the end of the palette (default=1)
;   OVERWRITE..... Overwrite the output pal file if it exists
;
; OUTPUTS:
;   OUTPUT........ A new pal_*.pro file in !S.PALETTE_FUNCTIONS
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
; Copyright [C] 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 14, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 14, 2021 - KJWH: Initial code written
;   Apr 15, 2021 - KJWH: Changed name to CPAL_RGB_2PAL
;   Jul 26, 2021 - KJHW: Updated code to use CPAL_COLORBOX to view the colorbar 
;                        Added more "PAL" names
;                        Now adding the gray end to colorbars that have 256 colors unless specified
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_RGB_2PAL'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(GRAYFILL) EQ 0 THEN GRAYFILL = 1
  
  IF N_ELEMENTS(RGBFILES) EQ 0 THEN RGBFILES = FILE_SEARCH(!S.IDL_PALETTES + 'RGB' + SL + ['*.RGB','*.rgb'])
  IF N_ELEMENTS(RGBFILES) EQ 0 THEN MESSAGE, 'ERROR: No RGB files found.'
  IF N_ELEMENTS(RGBFILES) GT 1 AND N_ELEMENTS(PALNAME) EQ 1 THEN MESSAGE, 'ERROR: The number of .pal names must equal the number of .rgb files'
  RGBFILES = RGBFILES[SORT(RGBFILES)]
 
  FOR F=0, N_ELEMENTS(RGBFILES)-1 DO BEGIN
    RFILE = RGBFILES[F]
    FR = FILE_PARSE(RFILE)
    IF FR.DIR EQ '' THEN RFILE = !S.IDL_PALETTES + 'RGB' + SL + RFILE
    IF FR.EXT EQ '' THEN RFILE = RFILE + '.rgb'
    IF ~FILE_TEST(RFILE) THEN BEGIN
      MESSAGE, 'ERROR: ' + RFILE + ' does not exist'
      CONTINUE
    ENDIF
    
    GRAY_FILL = GRAYFILL
    CASE FR.NAME OF
      'RGB_gray':     BEGIN & PNAME = 'GRAY2'    & GRAY_FILL=0 & END
      'GMT_gray':     BEGIN & PNAME = 'GMT_GRAY' & GRAY_FILL=0 & END
      'BlueDarkOrange18': PNAME = 'BLUEGREEN_ORANGE'
      'GMT_no_green':     PNAME = 'GMT_NO_GREEN'
      'BlueWhiteOrangeRed': PNAME = 'BWOR'
      'BlueDarkRed18': PNAME = 'BLUE_RED'
      'BlueGreen14': PNAME = 'BLUE_GREEN'
      'BrownBlue12': PNAME = 'BROWN_BLUE'
      'CBR_coldhot': PNAME = 'COLD_HOT'
      'CBR_drywet': PNAME = 'DRY_WET'
      'CBR_wet': PNAME = 'PRECIP'
      'cmocean_balance': PNAME = 'DARKBLUE_DARKRED'
      'GMT_relief_oceanonly': PNAME = 'OCEAN_RELIEF'
      'GreenMagenta16': PNAME = 'GREEN_MAGENTA'
      'MPL_YlGnBu': PNAME = 'YELLOW_BLUE'
      'NCV_blu_red': PNAME = 'BLUE_RED2'
      'nrl_sirkes': PNAME = 'TEAL_RED'
      'percent_11lev': PNAME = 'PURPLE_RED_RAINBOW'
      'posneg_1': PNAME = 'BLUE_RED3'
      'precip4_11lev': PNAME = 'PRECIP2'
      'rh_19lev': PNAME = 'YELLOW_BLUE_RAINBOW'
      'srip_reanalysis': PNAME = 'MULTICOLOR'
      'stepseq25': PNAME = 'RED_PURPLE_RAINBOW'
      'sunshine_9lev': PNAME = 'SUNSHINE'
      'sunshine_diff_12lev': PNAME = 'SUNSHINE_DIF'
      ELSE: PNAME = FR.NAME
    ENDCASE
    PNAME = 'PAL_' + PNAME
    
    IF N_ELEMENTS(PALNAME) NE 0 THEN PNAME = PALNAME[N]

    PALFILE = !S.PALETTE_FUNCTIONS + STRLOWCASE(PNAME) + '.pro'
    IF FILE_MAKE(RFILE,PALFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

    ; ===> Set up blank RGB arrays
    RR = INTARR(256) & RR[*]=-1
    GG = RR
    BB = RR

    ; ===> Fill in the beginning (0=black) and end (250-255=shades of gray) of the new palette
    IF KEYWORD_SET(GRAY_FILL) THEN BEGIN
      SUBS = [0,251,252,253,254,255]
      CLRS = [0,128,160,192,224,255]
      FOR S=0, N_ELEMENTS(SUBS)-1 DO BEGIN
        RR[SUBS[S]] = CLRS[S]
        GG[SUBS[S]] = CLRS[S]
        BB[SUBS[S]] = CLRS[S]
      ENDFOR
      MAXCLR = 250
      STRCLR = 1
    ENDIF 

    ; ===> Read the rgb palette
    PAL = READ_DELIMITED(RFILE, DELIM = ' ')
    IF N_TAGS(PAL) EQ 1 THEN PAL = READ_DELIMITED(RFILE, DELIM = ',')
    
    ; ===> If the palette is not a full 256 array, interpolate between colors
    IF N_ELEMENTS(PAL) LT 256 THEN BEGIN
      STEP = FLOAT(MAXCLR)/N_ELEMENTS(PAL)
      CT = STRCLR
      FOR N=0, N_ELEMENTS(PAL.R)-2 DO BEGIN
        C = ROUND(CT)
        CT = CT + STEP
        IF CT GT MAXCLR THEN CONTINUE
        IF PAL[N].R LE 1.0 THEN RR[C] = ROUND(PAL[N].R*255.) ELSE RR[C] = PAL[N].R & IF RR[C] GT 255 THEN RR[C] = 255
        IF PAL[N].G LE 1.0 THEN GG[C] = ROUND(PAL[N].G*255.) ELSE GG[C] = PAL[N].G & IF GG[C] GT 255 THEN GG[C] = 255
        IF PAL[N].B LE 1.0 THEN BB[C] = ROUND(PAL[N].B*255.) ELSE BB[C] = PAL[N].B & IF BB[C] GT 255 THEN BB[C] = 255
      ENDFOR
      IF PAL[N].R LE 1.0 THEN RR[MAXCLR] = ROUND(PAL[N].R*255.) ELSE RR[MAXCLR] = PAL[N].R
      IF PAL[N].G LE 1.0 THEN GG[MAXCLR] = ROUND(PAL[N].G*255.) ELSE GG[MAXCLR] = PAL[N].G
      IF PAL[N].B LE 1.0 THEN BB[MAXCLR] = ROUND(PAL[N].B*255.) ELSE BB[MAXCLR] = PAL[N].B

      INTERVALS  = WHERE(RR NE -1)
      R = INTERPOL(RR[INTERVALS],INTERVALS,INDGEN(256))
      G = INTERPOL(GG[INTERVALS],INTERVALS,INDGEN(256))
      B = INTERPOL(BB[INTERVALS],INTERVALS,INDGEN(256))

    ENDIF ELSE BEGIN
      IF MAX(PAL.R) LT 1.0 THEN RR = FLOAT(PAL.R)*255 ELSE RR = PAL.R
      IF MAX(PAL.G) LT 1.0 THEN GG = FLOAT(PAL.G)*255 ELSE GG = PAL.G
      IF MAX(PAL.B) LT 1.0 THEN BB = FLOAT(PAL.B)*255 ELSE BB = PAL.B
      R = RR & G = GG & B = BB
      IF KEYWORD_SET(GRAY_FILL) THEN BEGIN
        R[SUBS] = CLRS
        G[SUBS] = CLRS
        B[SUBS] = CLRS
      ENDIF
    ENDELSE

    ; ===> View the new color palette
    PRINT, 'Viewing ' + PNAME
    TVLCT, R, G, B
    CPAL_COLORBOX,DELAY=2
    
    CPAL_WRITE,PNAME,R,G,B
    PFILE,PNAME

  ENDFOR


END ; ***************** End of PALS_RGB_2PAL *****************
