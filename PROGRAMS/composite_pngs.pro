; $ID:	COMPOSITE_PNGS.PRO,	2021-04-15-17,	USER-KJWH	$

PRO COMPOSITE_PNGS, FILES, FILEPROD, IMGPROD=IMGPROD, MAP_OUT=MAP_OUT, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, $
                        PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, LAND_COLOR=LAND_COLOR, COAST_COLOR=COAST_COLOR,$
                        IMG_TITLES=IMG_TITLES, ROW_TITLES=ROW_TITLES,COL_TITLES=COL_TITLES,$
                        BATHY_DEPTHS=BATHY_DEPTHS, OUTLINE=OUTLINE,MASK=MASK,$
                        DIMS=DIMS, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, SPACE=SPACE, $
                        NO_COLORBAR=NO_COLORBAR, BUFFER=BUFFER, VERBOSE=VERBOSE, ERROR=ERROR, OVERWRITE=OVERWRITE, $
                        DO_MONTHS=DO_MONTHS, DO_ANNUAL=DO_ANNUAL, YEARS=YEARS, MONTHS=MONTHS,YEARS_ON_TOP=YEARS_ON_TOP
                        
;+
; NAME:
;   COMPOSITE_PNGS
;
; PURPOSE:
;   This procedure creates a composite of images
;
; CATEGORY:
;   GRAPHICS
;
; CALLING SEQUENCE:
;   COMPOSITE_PNGS, FILES, PROD
;
; IREQUIRED NPUTS:
;   FILES................ The names of the input files to plot
;   
; OPTIONAL INPUTS:
;   FILEPROD............. The product name for the input files
;   IMGPROD.............. The "product" for the images (to be bassed to PRODS_2BYTE)
;   STATPROD............. The STAT (mean, std, var) to be used in the plots
;   MAP_OUT.............. The output map for the images
;   DIR_OUT.............. The output directory
;   OUTFILE.............. The name of the output png file
;   DATERANGE............ Daterange for the files
;   PAL.................. The color palette for the scaled data
;   COLORBAR_TITLE....... Title for the colobar
;   FONT_SIZE............ Font size for the text
;   LAND_COLOR........... Color for the land mask
;   COAST_COLOR.......... Color for the coastline
;   DIMS................. Dimensions
;   IMG_TITLES........... Titles for the individual images
;   ROW_TITLES........... Titles for the rows
;   COL_TITLES........... Titles for the columns
;   BATHY_DEPTHS......... Bathymetry depth contour lines (passed to PRODS_2PNG)
;   OUTLINE.............. Outline passed to PRODS_2PNG
;   MASK................. Subarea mask passed to PRODS_2PNG
;   XDIM.................
;   YDIM.................
;   NROWS................ Number of rows
;   NCOLS................ Number of columns
;   TOP.................. Space for the top margin
;   BOT.................. Space for the bottom margin
;   LEFT................. Space for the left margin
;   RIGHT................ Space for the right margin
;   SPACE................ Space betweeen the images
;   YEARS................ Passed to COMPOSITES_MONTHLY or COMPOSITES_ANNUAL
;   MONTHS............... Passed to COMPOSITES_MONTHLY or COMPOSITES_ANNUAL
;   YEARS_ON_TOP......... Passed to COMPOSITES_MONTHLY or COMPOSITES_ANNUAL
;
; KEYWORD PARAMETERS:
;   DO_MONTHS............ Set to use COMPOSITE_MONTHLY to create the composite
;   DO_ANNUAL............ Set to use COMPOSITE_ANNUAL to create the composite
;   NO_COLORBAR.......... Do not include a colorbar
;   BUFFER............... Graphics window buffer
;   VERBOSE.............. Print out steps
;   OVERWRITE............ Overwrite the output png if it already exists
;
; OUTPUTS:
;   This procedure creates a monthly composite image saved to an output directory
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
;   FILES = GET_FILES('MUR',PERIODS='M',MATH_TYPE='STATS',PRODS='SST',DATERANGE='2020')
;   COMPOSITE_PNGS, FILES, 'SST',imgprod='SST_0_30', PAL='PAL_BLUE_RED', COLORBAR_TITLE = UNITS('TEMPERATURE'), MAP_OUT='NES', DIR_OUT=!S.SST + 'MUR/NES/',NROWS=3, NCOLS=4
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2016, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 11, 2016 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 11, 2016 - KJWH: Initial code written - adapted from MONTHLY_COMPOSITES (now COMPOSITE_MONTHLY)
;   Feb 07, 2019 - KJWH: Changed name to COMPOSITE_PNGS to make it consistent with other compositing programs and easier to find
;   Sep 28, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated documentation
;                        Adjusted keywords 
;                                            
;               
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'COMPOSITE_PNGS'
  SL = PATH_SEP()
  COMPILE_OPT IDL2
  
  IF NONE(FILES) THEN GOTO, DONE

; ===> SPECIAL CASES 
  IF KEY(DO_MONTHLY) THEN BEGIN ; Create composites with M or MONTH data
    COMPOSITE_MONTHLY,FILES, PROD, IMGPROD=IMGPROD, MAP_OUT=MAP_OUT, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, YEARS=YEARS, MONTHS=MONTHS,YEARS_ON_TOP=YEARS_ON_TOP,$
      PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, $
      NO_COLORBAR=NO_COLORBAR, SPACE=SPACE, BUFFER=BUFFER, VERBOSE=VERBOSE, ERROR=ERROR, OVERWRITE=OVERWRITE
    GOTO, DONE  
  ENDIF
  
  IF KEY(DO_ANNUAL) THEN BEGIN ; Create composites with A data
    COMPOSITE_ANNUAL,FILES, PROD, IMGPROD=IMGPROD, MAP_OUT=MAP_OUT, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, YEARS=YEARS, MONTHS=MONTHS,YEARS_ON_TOP=YEARS_ON_TOP,$
      PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, $
      NO_COLORBAR=NO_COLORBAR, SPACE=SPACE, BUFFER=BUFFER, VERBOSE=VERBOSE, ERROR=ERROR, OVERWRITE=OVERWRITE
    GOTO, DONE
  ENDIF

; ===> SET UP DEFAULTS
  FP = PARSE_IT(FILES,/ALL)
  IF NONE(FILEPROD)      THEN FILEPROD = FP[0].PROD
  IF NONE(DIR_OUT)       THEN DIR_OUT = REPLACE(FP[0].DIR,FP[0].SUB,'COMPOSITES') & DIR_TEST, DIR_OUT ; DEFAULT LOCATION FOR OUTPUT COMPOSITES
  IF NONE(OUTFILE)       THEN OUTFILE = DIR_OUT + 'COMPOSITE.PNG'
  IF FILE_MAKE(FILES,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE

  IF NONE(FONT_SIZE)      THEN FONT_SIZE  = 16
  IF NONE(CFONT_SIZE)     THEN CFONT_SIZE = 12
  IF NONE(FONT_STYLE)     THEN FONT_STYLE = 'BOLD'
  IF NONE(PAL)            THEN PAL = 'PAL_DEFAULT' & RGB = CPAL_READ(PAL)
  IF NONE(LAND_COLOR)     THEN LAND_COLOR  = 252
  IF NONE(COAST_COLOR)    THEN COAST_COLOR = 0

  IF ANY(DIMS) THEN BEGIN
    DIMS = STRSPLIT(STRUPCASE(DIMS),'X',/EXTRACT)
    IF NONE(NCOLS) THEN NCOLS = DIMS[0]
    IF NONE(NROWS) THEN NROWS = DIMS[1]
  ENDIF
  
; ===> SET UP PLOT SPACING  
  IF NONE(BUFFER) THEN BUFFER = 1 ; Do plotting in background
  IF NONE(SPACE)  THEN SPACE  = 10
  IF NONE(LEFT)   THEN LEFT   = SPACE * 3
  IF NONE(RIGHT)  THEN RIGHT  = SPACE * 3
  IF NONE(TOP)    THEN TOP    = SPACE * 4
  IF NONE(BOTTOM) THEN IF NOT KEYWORD_SET(NO_COLORBAR) THEN BOTTOM = SPACE * 8 ELSE BOTTOM = SPACE * 3
  IF NONE(NCOLS)  THEN NCOLS  = N_ELEMENTS(FILES)
  IF NONE(NROWS)  THEN NROWS  = 1 
  IF NONE(XDIM)   THEN XDIM   = 120
  IF NONE(YDIM)   THEN YDIM   = XDIM
  IF NONE(ROW_TITLES) THEN ROW_TITLES = REPLICATE('',NROWS)
  IF NONE(COL_TITLES) THEN COL_TITLES = REPLICATE('',NCOLS)
  
  XNSPACE = NCOLS-1 & YNSPACE = NROWS-1
  WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
  HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP
  
  WIMG = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
  COUNTER = 0
  MAPP = ''
  
  CBPOS = [.25, (BOTTOM*.65)/HEIGHT, .75, (BOTTOM*.95)/HEIGHT]
  IF NOT KEYWORD_SET(NO_COLORBAR) THEN CBAR, FILEPROD, OBJ=WIMG, FONT_SIZE=CFONT_SIZE, FONT_STYLE=FONT_STYLE, CB_TYPE=3, CB_POS=CBPOS, CB_TITLE=COLORBAR_TITLE, PAL=PAL
 
  FOR W=0, NROWS-1 DO BEGIN
    CTITLE = ROW_TITLES[W]
    FOR L=0, NCOLS-1 DO BEGIN
      RTITLE = COL_TITLES[L]
      C = COUNTER MOD NCOLS           ; Number of columns is associated with the number of months so C represents the column number
      XPOS = LEFT + C*XDIM + C*SPACE  ; Determine the left side of the image
      IF C EQ 0 THEN R = COUNTER/NCOLS ELSE R = W ; When C = 0, start a new row
      IF L EQ 0 THEN YPOS = HEIGHT - TOP - R*YDIM - R*SPACE ELSE YPOS = YPOS ; Determine the top position of the image
      POS = [XPOS,YPOS-YDIM,XPOS+XDIM,YPOS]
     
      IF W EQ 0 THEN TMT = TEXT(POS[0]+XDIM/2,POS[3]+5,RTITLE,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE) ; Add month name to the image
      IF L EQ 0 THEN TYR = TEXT(LEFT/2,POS[1]+YDIM/2,  CTITLE,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE,VERTICAL_ALIGNMENT=0.5,ORIENTATION=90) ; Add year to the image
      
      IF NONE(FILEPROD)       THEN FILEPROD = FP[COUNTER].PROD        ; Product to extract from the file
      IF NONE(IMGPROD)        THEN IMGPROD  = FILEPROD                ; Product name used for byte scaling
      IF NONE(COLORBAR_TITLE) THEN COLORBAR_TITLE = UNITS(FILEPROD)   ; Title for the colorbar
      IF NONE(MAP_OUT)        THEN MAP_OUT  = FP[COUNTER].MAP_OUT     ; Output map
      
      ; ===> GET LANDMASK (ONLY READ IF THE MAP IS DIFFERENT THAN THE PREVIOUS FILE)
      IF FP[COUNTER].MAP NE MAPP THEN LAND = READ_LANDMASK(MAP_OUT,/STRUCT)
      MAPP = MAP_OUT    
      IF KEY(VERBOSE) THEN PRINT, 'Adding ' + FILES[OK]     
      PRODS_2PNG, FILES[COUNTER], PROD=IMGPROD, ADD_CB=0, PAL=PAL, IMG_POS=POS, MAPP=MAP_OUT, DEPTH=BATHY_DEPTHS, OUTLINE=OUTLINE, OUT_COLOR=0, MASK=MASK, OUT_THICK=3, /CURRENT, /DEVICE, BUFFER=BUFFER
      IF ANY(IMG_TITLES) THEN TXT = TEXT(XPOS+5,YPOS-5,IMG_TITLES[COUNTER],FONT_SIZE=FONT_SIZE,FONT_STYLE=FONT_STYLE,VERTICAL_ALIGNMENT=1,/DEVICE)
      COUNTER = COUNTER + 1
    ENDFOR
  ENDFOR
  
  
  ;PRODS_COLORBAR, IMGPROD, PAL=PAL, POSITION=CBPOS, TEXTPOS=0, FONT_SIZE=CFONT_SIZE, TITLE=COLORBAR_TITLE, TICKDIR=0,/DEVICE
  
  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'Writing ' + OUTFILE
  WIMG.SAVE, OUTFILE, RESOLUTION=RESOLUTION
  WIMG.CLOSE

  DONE:
  
END; #####################  End of Routine ################################
