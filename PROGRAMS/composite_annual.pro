; $ID:	COMPOSITE_ANNUAL.PRO,	2021-04-15-17,	USER-KJWH	$

PRO COMPOSITE_ANNUAL, FILES, PROD, IMGPROD=IMGPROD, MAP_OUT=MAP_OUT, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, YEARS=YEARS, YEARS_ON_TOP=YEARS_ON_TOP,$
                        PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, $
                        NO_COLORBAR=NO_COLORBAR, SPACE=SPACE, BUFFER=BUFFER, VERBOSE=VERBOSE, ERROR=ERROR, OVERWRITE=OVERWRITE

;+
; NAME:
;   COMPOSITE_ANNUAL
;
; PURPOSE:
;   This procedure creates a composite of annual (A) images
;
; CATEGORY:
;   PLOTTING
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   This procedure creates a monthly composite image saved to an output directory
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:  If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:

;
;
; MODIFICATION HISTORY:
;     Written:  SEP 16, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Modified: FEB 07, 2019 - KJWH: Changed name to COMPOSITE_ANNUAL to be consistent with other compositing programs and easier to find 
;                         
;               
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'COMPOSITE_ANNUAL'
  SL = PATH_SEP()
  
; ===> PARSE AND CHECK FILES 
  IF NONE(FILES) THEN GOTO, DONE
  FP = PARSE_IT(FILES,/ALL)
  IF NONE(DATERANGE)      THEN DATERANGE = [MIN(FP.DATE_START),MAX(FP.DATE_END)]
  FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT)
  IF SAME(FP.PERIOD_CODE) EQ 0 OR  FP[0].PERIOD_CODE NE 'A' THEN MESSAGE, 'ERROR: All input files must have the period code "A".'

; ===> SET UP DEFAULTS 
  IF COUNT EQ 0 THEN GOTO, DONE
  IF NONE(FILEPROD)       THEN FILEPROD = FP[0].PROD        ; Product to extract from the file
  IF NONE(IMGPROD)        THEN IMGPROD  = FILEPROD          ; Product name used for byte scaling
  IF NONE(DIR_OUT)        THEN DIR_OUT = REPLACE(FP[0].DIR,'STATS','COMPOSITES') & DIR_TEST, DIR_OUT ; DEFAULT LOCATION FOR OUTPUT COMPOSITES
  IF NONE(MAP_OUT)        THEN MAP_OUT = FP[0].MAP  
  
  IF NONE(OUTFILE)       THEN OUTFILE = DIR_OUT + 'A_' + MIN(FP.YEAR_START) + '_' + MAX(FP.YEAR_START) + '-' + MAP_OUT + '-' + PROD + '-' + FP[0].ALG + '-' + 'COMPOSITE.PNG'
  IF FILE_MAKE(FILES,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  
  IF NONE(COLORBAR_TITLE) THEN COLORBAR_TITLE = UNITS(PROD)  
  IF NONE(FONT_SIZE)      THEN FONT_SIZE = 16
  IF NONE(CFONT_SIZE)     THEN CFONT_SIZE = 12
  
  IF NONE(PAL)            THEN PAL = 'PAL_BR' 
  RGB = CPAL_READ(PAL)

; ===> GET LANDMASK
  LAND = READ_LANDMASK(MAP_OUT,/STRUCT)
  IF NONE(LAND_COLOR)  THEN LAND_COLOR  = 252
  IF NONE(COAST_COLOR) THEN COAST_COLOR = 0
 
; ===> GET YEARS FROM THE FILES  
  IF NONE(YEARS)  THEN YEARS  = YEAR_RANGE(MIN(FP.YEAR_START),MAX(FP.YEAR_START),/STRING)    
  
; ===> SET UP PLOT SPACING  
  IF NONE(BUFFER) THEN BUFFER = 1 ; Do plotting in background
  IF NONE(SPACE)  THEN SPACE  = 10
  IF NONE(LEFT)   THEN LEFT   = SPACE * 3
  IF NONE(RIGHT)  THEN RIGHT  = SPACE * 3
  IF NONE(TOP)    THEN TOP    = SPACE * 4
  IF NONE(BOTTOM) THEN IF NOT KEYWORD_SET(NO_COLORBAR) THEN BOTTOM = SPACE * 8 ELSE BOTTOM = SPACE * 3
  IF NONE(NCOLS)  THEN NCOLS  = N_ELEMENTS(YEARS)
  IF NONE(NROWS)  THEN NROWS  = 1
  IF NONE(XDIM)   THEN XDIM   = 120
  IF NONE(YDIM)   THEN YDIM   = XDIM
  
  XNSPACE = NCOLS-1 & YNSPACE = NROWS-1
  WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
  HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP
  
  W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
  COUNTER = 0
  
  FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
    AYEAR = YEARS(Y)
    C = COUNTER MOD NCOLS           ; Number of columns is associated with the number of months so C represents the column number
    XPOS = LEFT + C*XDIM + C*SPACE  ; Determine the left side of the image
    IF C EQ 0 THEN R = COUNTER/NCOLS ELSE R = Y ; When C = 0, start a new row
    IF Y EQ 0 THEN YPOS = HEIGHT - TOP - R*YDIM - R*SPACE ELSE YPOS = YPOS ; Determine the top position of the image
    POS = [XPOS,YPOS-YDIM,XPOS+XDIM,YPOS]
    
    IF Y EQ 0 THEN TMT = TEXT(POS[0]+XDIM/2,POS(3)+5,AYEAR,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE) ; Add month name to the image
  ;  IF M EQ 0 THEN TYR = TEXT(LEFT/2,POS(1)+YDIM/2,  AYEAR,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE,VERTICAL_ALIGNMENT=0.5,ORIENTATION=90) ; Add year to the image
    
    OK = WHERE(FP.YEAR_START EQ AYEAR,COUNT) ; Find the file corresponding to the correct year and month
    COUNTER = COUNTER + 1
    IF COUNT EQ 0 THEN CONTINUE
    
    DATA = STRUCT_READ(FILES[OK],STRUCT=STR,MAP_OUT=MAP_OUT) ; Read data file
    IM = PRODS_2BYTE(DATA, PROD=IMGPROD)          ; Extract data and convert to BYTE
    IM(LAND.LAND)  = LAND_COLOR                                ; Add land mask
    IM(LAND.COAST) = COAST_COLOR                               ; Add coast mask
     
    IF KEY(VERBOSE) THEN PRINT, 'Adding ' + FILES[OK]     
    IMG = IMAGE(IM, RGB_TABLE=RGB, POSITION=POS, BUFFER=BUFFER, /DEVICE, /CURRENT)
  ENDFOR
  
  CBPOS = [WIDTH*.25, BOTTOM*.65, WIDTH*.75, BOTTOM*.95]
  IF NOT KEYWORD_SET(NO_COLORBAR) THEN PRODS_COLORBAR, IMGPROD, IMG=IMG, POSITION=CBPOS, TEXTPOS=0, FONT_SIZE=CFONT_SIZE, TITLE=COLORBAR_TITLE, TICKDIR=0,/DEVICE
  
  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'Writing ' + OUTFILE
  W.SAVE, OUTFILE, RESOLUTION=RESOLUTION
  W.CLOSE

  DONE:
  
END; #####################  End of Routine ################################
