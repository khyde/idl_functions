; $ID:	COMPOSITE_MONTHLY.PRO,	2021-04-15-17,	USER-KJWH	$

PRO COMPOSITE_MONTHLY, FILES, FILEPROD, IMGPROD=IMGPROD, STATPROD=STATPROD, MAP_OUT=MAP_OUT, DIR_OUT=DIR_OUT, OUTFILE=OUTFILE, DATERANGE=DATERANGE, YEARS=YEARS, MONTHS=MONTHS,$
                        PAL=PAL, COLORBAR_TITLE=COLORBAR_TITLE, FONT_SIZE=FONT_SIZE, LAND_COLOR=LAND_COLOR, COAST_COLOR=COAST_COLOR, XDIM=XDIM, YDIM=YDIM, NROWS=NROWS, NCOLS=NCOLS, TOP=TOP, BOTTOM=BOTTOM, LEFT=LEFT, RIGHT=RIGHT, SPACE=SPACE,$
                        NO_COLORBAR=NO_COLORBAR, BUFFER=BUFFER, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE

;+
; NAME:
;   COMPOSITE_MONTHLY
;
; PURPOSE:
;   This procedure creates a composite of monthly (M) images
;
; CATEGORY:
;   GRAPHICS
;
; CALLING SEQUENCE:
;   COMPOSITE_MONTHLY, FILES, PROD
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
;   YEARS................ The 
;   MONTHS...............
;   PAL..................
;   COLORBAR_TITLE.......
;   FONT_SIZE............
;   LAND_COLOR...........
;   COAST_COLOR..........
;   XDIM.................
;   YDIM.................
;   NROWS................
;   NCOLS................
;   TOP..................
;   BOT..................
;   LEFT.................
;   RIGHT................
;   SPACE................
;
; KEYWORD PARAMETERS:
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
;   COMPOSITE_MONTHLY, FILES, 'SST',imgprod='SST_0_30', PAL='PAL_BLUE_RED', COLORBAR_TITLE = UNITS('TEMPERATURE'), MAP_OUT='NES', DIR_OUT=!S.SST + 'MUR/NES/',NROWS=3, NCOLS=4
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 21, 2014 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:;
;   APR  3, 2014 - KJWH: Switched the columns and row so that each year is a column and month a row.
;                        Made the number of rows dependent on the months and number of columns dependent on the years
;                        Added YEARS and MONTHS keywords
;   SEP 16, 2016 - KJWH: Updated with recent code  
;                        Now also works with 'MONTH' files   
;   FEB 07, 2019 - KJWH: Changed name to COMPOSITE_MONTHLY to be consistent with other compositing programs and make it easier to find                                     
;   AUG 07, 2020 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []  
;                        Changed PROD to FILEPROD
;                        Changed default pal from PAL_BR to PAL_DEFAULT
;                        Replaced PRODS_COLORBAR with CBAR
;                                  
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'COMPOSITE_MONTHLY'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF NONE(FILES) THEN GOTO, DONE

; ===> Verify files
  FP = PARSE_IT(FILES,/ALL)
  IF NONE(DATERANGE)  THEN DATERANGE = [MIN(FP.DATE_START),MAX(FP.DATE_END)]
  FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT)
  IF COUNT EQ 0 THEN GOTO, DONE
  IF SAME(FP.PERIOD_CODE) EQ 0 THEN MESSAGE, 'ERROR: All input files must have the same period code (M or MONTH)'
  IF FP[0].PERIOD_CODE NE 'M' AND FP[0].PERIOD_CODE NE 'MONTH' THEN MESSAGE, 'ERROR: Input files must have the period code M or MONTH'
  IF SAME(FP.PROD) EQ 0 THEN MESSAGE, 'ERROR: All input files should have the same product'
  
; ===> Set up defaults  
  IF NONE(FILEPROD)       THEN FILEPROD = FP[0].PROD        ; Product to extract from the file
  IF NONE(IMGPROD)        THEN IMGPROD  = FILEPROD          ; Product name used for byte scaling
  IF NONE(DIR_OUT)        THEN DIR_OUT  = REPLACE(FP[0].DIR,[FP[0].MAP,'STATS','ANOMS'],[MAP_OUT,'COMPOSITES','COMPOSITES']) & DIR_TEST, DIR_OUT ; Default location for output composites
  IF NONE(MAP_OUT)        THEN MAP_OUT  = FP[0].MAP         ; Map for the output images  
  IF IS_L3B(MAP_OUT)      THEN MAP_OUT  = MAPS_L3B_GET_GS(MAP_OUT) ; If the MAP_OUT is a L3B map then use the matching GS map
  IF NONE(OUTFILE)        THEN OUTFILE = DIR_OUT + FP[0].PERIOD_CODE + '-' + FP[0].SENSOR + '-' + MAP_OUT + '-' + FILEPROD + '-' + FP[0].ALG + '-' + FP[0].MATH + '-' + 'COMPOSITE.PNG'
  
  IF NONE(COLORBAR_TITLE) THEN COLORBAR_TITLE = UNITS(FILEPROD)  
  IF NONE(FONT_SIZE)      THEN FONT_SIZE = 16
  IF NONE(CFONT_SIZE)     THEN CFONT_SIZE = 12
  
  IF NONE(LAND_COLOR)     THEN LAND_COLOR  = 252
  IF NONE(COAST_COLOR)    THEN COAST_COLOR = 0
  IF NONE(PAL)            THEN PAL = 'PAL_DEFAULT' & RGB = CPAL_READ(PAL)

; ===> Get years and months from the files    
  IF NONE(YEARS)  THEN YEARS  = YEAR_RANGE(MIN(FP.YEAR_START),MAX(FP.YEAR_START),/STRING)    
  IF NONE(MONTHS) THEN MONTHS = MONTH_RANGE(MIN(FP.MONTH_START),MAX(FP.MONTH_START),/STRING) 
  NAMES  = MONTH_NAMES(MONTH)
  IF FP[0].PERIOD_CODE EQ 'MONTH' THEN YEARS = ''
  IF N_ELEMENTS(YEARS) EQ 1 THEN BEGIN
    IF N_ELEMENTS(MONTHS) EQ 12 THEN OUTFILE = REPLACE(OUTFILE,SL+'M-',SL+'M_'+YEARS+'-') ELSE OUTFILE = REPLACE(OUTFILE,SL+'M-',SL+'M_'+YEARS+MONTHS[0]+'_'+YEARS+MONTHS[-1]+'-') 
  ENDIF
  IF N_ELEMENTS(YEARS) GT 1 THEN OUTFILE = REPLACE(OUTFILE,SL+'M-',SL+'M_'+MIN(YEARS)+'_'+MAX(YEARS)+'-')
  IF FP[0].PERIOD_CODE EQ 'MONTH' THEN OUTFILE = REPLACE(OUTFILE,SL+'M-',SL+'MONTH-')
  OUTFILE = REPLACE(OUTFILE,'--','-')
  IF FILE_MAKE(FILES,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE ; If the file exists goto the end of the program
  
; ===> Set up plot spacing  
  IF NONE(BUFFER) THEN BUFFER = 1 ; Do plotting in background
  IF NONE(SPACE)  THEN SPACE  = 10
  IF NONE(LEFT)   THEN LEFT   = SPACE * 3
  IF NONE(RIGHT)  THEN RIGHT  = SPACE * 3
  IF NONE(TOP)    THEN TOP    = SPACE * 4
  IF NONE(BOTTOM) THEN IF NOT KEYWORD_SET(NO_COLORBAR) THEN BOTTOM = SPACE * 8 ELSE BOTTOM = SPACE * 3
  IF NONE(NCOLS)  THEN NCOLS  = N_ELEMENTS(MONTHS)
  IF NONE(NROWS)  THEN NROWS  = N_ELEMENTS(YEARS) 
  IF NONE(XDIM)   THEN XDIM   = 120
  IF NONE(YDIM)   THEN YDIM   = XDIM
  
  XNSPACE = NCOLS-1 & YNSPACE = NROWS-1
  WIDTH   = LEFT   + NCOLS*XDIM + XNSPACE*SPACE + RIGHT
  HEIGHT  = BOTTOM + NROWS*YDIM + YNSPACE*SPACE + TOP
  CBPOS = [.25, (BOTTOM*.65)/HEIGHT, .75, (BOTTOM*.95)/HEIGHT]

  ; ===> Get landmask
  LAND = READ_LANDMASK(MAP_OUT,/STRUCT)

  
  W = WINDOW(DIMENSIONS=[WIDTH,HEIGHT],BUFFER=BUFFER)
  CBAR, IMGPROD, CB_TYPE=3, FONT_SIZE=CFONT_SIZE, FONT_STYLE='BOLD', CB_POS=CBPOS, CB_TITLE=COLORBAR_TITLE, PAL=PAL, OBJ=W
  COUNTER = 0
  
  FOR Y=0, N_ELEMENTS(YEARS)-1 DO BEGIN
    AYEAR = YEARS[Y]
    FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
      AMONTH = MONTHS[M]
      ANAME  = NAMES[M]
      C = COUNTER MOD NCOLS           ; Number of columns is associated with the number of months so C represents the column number
      XPOS = LEFT + C*XDIM + C*SPACE  ; Determine the left side of the image
      IF C EQ 0 THEN R = COUNTER/NCOLS ELSE R = Y ; When C = 0, start a new row
      IF M EQ 0 THEN YPOS = HEIGHT - TOP - R*YDIM - R*SPACE ELSE YPOS = YPOS ; Determine the top position of the image
      POS = [XPOS,YPOS-YDIM,XPOS+XDIM,YPOS]
      
      IF N_ELEMENTS(Y) EQ 1 THEN BEGIN
        TMT = TEXT(POS[0]+XDIM/2,POS[3]+5,ANAME,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE) ; Add month name to the image
      ENDIF ELSE IF Y EQ 0 THEN TMT = TEXT(POS[0]+XDIM/2,POS[3]+5,ANAME,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE) ; Add month name to the image
      
      IF M EQ 0 THEN BEGIN
        IF N_ELEMENTS(YEARS) EQ 1 THEN TYR = TEXT(WIDTH-SPACE*2,SPACE*2,AYEAR,ALIGNMENT=1.0,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE,VERTICAL_ALIGNMENT=0.0,ORIENTATION=0) $
                                  ELSE TYR = TEXT(LEFT/2,POS[1]+YDIM/2,AYEAR,ALIGNMENT=0.5,FONT_STYLE='BOLD',FONT_SIZE=FONT_SIZE,/DEVICE,VERTICAL_ALIGNMENT=0.5,ORIENTATION=90) ; Add year to the image
      ENDIF
      OK = WHERE(FP.YEAR_START EQ AYEAR AND FP.MONTH_START EQ AMONTH,COUNT) ; Find the file corresponding to the correct year and month
      COUNTER = COUNTER + 1
      IF COUNT EQ 0 THEN CONTINUE
      
      DATA = STRUCT_READ(FILES[OK],STRUCT=STR,MAP_OUT=MAP_OUT)   ; Read data file
      IM = PRODS_2BYTE(DATA, PROD=IMGPROD)                       ; Extract data and convert to BYTE
      IM[LAND.LAND]  = LAND_COLOR                                ; Add land mask
      IM[LAND.COAST] = COAST_COLOR                               ; Add coast mask
       
      IF KEY(VERBOSE) THEN PRINT, 'Adding ' + FILES[OK]     
      IMG = IMAGE(IM, RGB_TABLE=RGB, POSITION=POS, BUFFER=BUFFER, /DEVICE, /CURRENT)
    ENDFOR
  ENDFOR
    
  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'Writing ' + OUTFILE
  W.SAVE, OUTFILE, RESOLUTION=RESOLUTION
  W.CLOSE

  DONE:
  
END; #####################  End of Routine ################################
