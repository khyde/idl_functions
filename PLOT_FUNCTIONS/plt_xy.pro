; $ID:	PLT_XY.PRO,	2023-09-21-13,	USER-KJWH	$
PRO PLT_XY, $
  
; REQUIRED INPUTS
  X, $                                 ; X input data
  Y, $                                 ; Y input data
            
; OPTIONAL KEYWORDS & INPUTS 
  Z, $                                 ; Z (optional) string input data
  ; ===> Missing data and outliers
  MISSINGX=MISSINGX,$                  ; Missing value for X
  MISSINGY=MISSINGY,$                  ; Missing value for Y
  OUTLIERS=OUTLIERS,$                  ; Outlier values to remove from regression statistics and plot
  
  ; ===> Regression statistics inputs (passed to STATS2)
  MODEL=MODEL,$                        ; Name of the regression model (see STATS2)
  PARAMS=PARAMS,$                      ; Name of the output parameters (see STATS2)
  DECIMALS=DECIMALS,$                  ; Number of decimal places to displaty (see STATS2)
  STATS_FILE=STATS_FILE,$              ; File to append the output statistics to (see STATS2)
  
  ; ===> Plot window setup keywords & inputs           
  CURRENT=CURRENT,$                    ; KEYWORD to plot to current window
  DEVICE=DEVICE,$                      ; KEYWORD to use device coordinates
  NORMAL=NORMAL,$                      ; KEYWORD to use normal coordinates
  DATA=DATA,$                          ; KEYWORD to use data coordinates
  LAYOUT=LAYOUT,$                      ; Plot layout (passed to PLOT)
  PLT_DIMS=PLT_DIMS,$                  ; Plot dimensions
  POSITION=POSITION,$                  ; Position of the plot in the window
  MARGIN=MARGIN,$                      ; Plot margins
  TITLE=TITLE,$                        ; Plot title
  BACKGROUND_COLOR=BACKGROUND_COLOR,$  ; Plot background color
      
  ; ===> Axis keywords & inputs
  XLOG=XLOG,$                          ; KEYWORD to use a LOG10 xaxis scale (and for the regression statistics)
  YLOG=YLOG,$                          ; KEYWORD to use a LOG10 yaxis scale (and for the regression statistics)
  EXPAND = EXPAND,$                    ; KEYWORD or expanding NICE_RANGE
  XTITLE=XTITLE,$                      ; Xaxis Title
  YTITLE=YTITLE,$                      ; Yaxis Title
  XRANGE=XRANGE,$                      ; Xaxis Range
  YRANGE=YRANGE,$                      ; Yaxis Range
  XTICKV=XTICKV,$                      ; Xaxis tick values
  YTICKV=YTICKV,$                      ; Yaxis tick values
  XMINOR=XMINOR,$                      ; Number of minor Xaxis tick marks
  YMINOR=YMINOR,$                      ; Number of minor Yaxis tick marks
  XSTYLE=XSTYLE,$                      ; Set the "style" of the Xaxis (see PLOT method)
  YSTYLE=YSTYLE,$                      ; Set the "style" of the Yaxis (see PLOT method)
  XTICKNAME=XTICKNAME,$                ; Xaxis tick names
  YTICKNAME=YTICKNAME,$                ; Yaxis tick names
  AXES_COLOR=AXES_COLOR,$              ; Color of main plot axes
  AXES_THICK=AXES_THICK,$              ; Thickness of main axes
  AXES_FONT_SIZE=AXES_FONT_SIZE,$      ; Size of the axis fonts
  ASPECT_RATIO=ASPECT_RATIO,$          ; Aspect ratio of Y plot dimensions to X plot dimension
                
  ; ===> Data symbol keyword & inputs
  SYM_ADD=SYM_ADD,$                    ; KEYWORD to plot symbols
  SYM_FILLED= SYM_FILLED,$             ; Fill in the symbol shape (see PLOT function)
  SYMBOL=SYMBOL,$                      ; Symbol type (see PLOT function)
  SYM_COLOR=SYM_COLOR,$                ; Symbol color (see PLOT function)
  SYM_SIZE=SYM_SIZE,$                  ; Symbol size (see PLOT function)
  SYM_THICK=SYM_THICK,$                ; Symbol thickness (see PLOT function) 
  SYM_FILL_COLOR=SYM_FILL_COLOR,$      ; Symbol filled in color (see PLOT function)
  SYM_CLIP=SYM_CLIP,$                  ; Clip the symbol (see PLOT function)
  
  ; ===> Mid-data line keyword & inputs
  LIN_ADD=LIN_ADD,$                    ; KEYWORD to plot the XY data line
  LIN_COLOR=LIN_COLOR,$                ; Color of the mid-data line
  LIN_THICK=LIN_THICK,$                ; Thickness of the mid-data line
  LIN_STYLE=LIN_STYLE,$                ; Linestyle of the mid-data line
  LIN_MID_COLOR=LIN_MID_COLOR,$        ; Color of the mid-data line
  LIN_MID_THICK=LIN_MID_THICK,$        ; Thickness of the mid-data line
  LIN_MID_STYLE=LIN_MID_STYLE,$        ; Linestyle of the mid-data line

 ; ===> Statistics legend keywords & inputs
  STATS_ADD=STATS_ADD,$                ; KEYWORD to plot the regression statistics legend
  STATS_POS=STATS_POS,$                ; Position for stats legend (data units, X, Y)
  STATS_COLOR=STATS_COLOR,$            ; Stats legend color
  STATS_SIZE=STATS_SIZE,$              ; Stats legend text size
  STATS_ALIGN=STATS_ALIGN,$            ; Alignment for the stats legend
  DOUBLE_SPACE=DOUBLE_SPACE,$          ; KEYWORD to use double line spaces between stat legend outputs

; ===> Regression line keywords & inputs
  REG_ADD=REG_ADD,$                    ; KEYWORD to plot the regression line
  REG_COLOR=REG_COLOR,$                ; Color of the regression line
  REG_THICK=REG_THICK,$                ; Thickness of the regression line
  REG_LINESTYLE=REG_LINESTYLE,$        ; Linestyle of the regression line
  REG_MID_COLOR=REG_MID_COLOR,$        ; Color of the overplotting regression line
  REG_MID_THICK=REG_MID_THICK,$        ; Thickness of the overplotting regression line
  REG_MID_LINESTYLE=REG_MID_LINESTYLE,$; Linestyle of the overplotting regression line

  ; ===> One to one line keywords & inputs
  ONE_ADD=ONE_ADD,$                    ; KEYWORD to plot the one to one line
  ONE_COLOR=ONE_COLOR,$                ; Color of the one to one line
  ONE_THICK=ONE_THICK,$                ; Thickness of the one to one line
  ONE_LINESTYLE=ONE_LINESTYLE,$        ; Linestyle of the one to one line

  ; ===> Plot the MEAN X,Y keywords & inputs
  MEAN_ADD=MEAN_ADD,$                  ; KEYWORD to plot the mean X,Y value
  MEAN_SYMBOL=MEAN_SYMBOL,$            ; Symbol to use for the mean
  MEAN_SIZE=MEAN_SIZE,$                ; Size of the mean symbol
  MEAN_COLOR=MEAN_COLOR,$              ; Color of the mean symbol
  MEAN_THICK=MEAN_THICK,$              ; Thickness of the mean symbol
            
  ; ===> Plot grid keyword & inputs
  GRID_ADD=GRID_ADD,$                  ; KEYWORD to add the grid to the plot
  GRID_COLOR=GRID_COLOR,$              ; Color of the grid
  GRID_THICK=GRID_THICK,$              ; Thickness of the grid 
  GRID_LINESTYLE=GRID_LINESTYLE,$      ; Linestyle of the grid 
            
  ; ===> Text keyword & inputs
  TXT_ADD=TXT_ADD ,$                   ; KEYWORD to add text to the XY coordinates
  TXT_FONT=TXT_FONT,$                  ; Font to use for the txt (see TEXT function)
  TXT_COLOR=TXT_COLOR,$                ; Color to use for the txt (see TEXT function)
  TXT_SIZE=TXT_SIZE,$                  ; Size to use for the txt (see TEXT function)
  TXT_STYLE=TXT_STYLE,$                ; Style to use for the txt (see TEXT function)
  TXT_ALIGN=TXT_ALIGN,$                ; Horizontal alignment to use for the txt (see TEXT function)
  TXT_VALGIN=TXT_VALIGN,$              ; Vertical alignment to use for the txt (see TEXT function)

  ; ===> Legend keyword & inputs
  LEG_ADD=LEG_ADD,$                    ; KEYWORD to add the plot legend    
  LEG_TXT= LEG_TXT,$                   ; Legend text
  LEG_POS= LEG_POS,$                   ; Legend position
  LEG_FONT=LEG_FONT,$                  ; Font to use for the legend (see TEXT function)
  LEG_COLOR=LEG_COLOR,$                ; Color to use for the legend (see TEXT function)
  LEG_SIZE=LEG_SIZE,$                  ; Size to use for the legend (see TEXT function)
  LEG_STYLE=LEG_STYLE,$                ; Style to use for the legend (see TEXT function)
  LEG_ALGIN=LEG_ALIGN,$                ; Horizontal alignment to use for the legend (see TEXT function)
  LEG_VALGIN=LEG_VALIGN,$              ; Vertical alignmen to use for the legend (see TEXT function)
  LEG_FILL_BACKGROUND=LEG_FILL_BACKGROUND,$ ; KEYWORD to backfill the legend area (see TEXT function)
  LEG_FILL_COLOR=LEG_FILL_COLOR,$      ; Color for the background legend area (see TEXT function)

  ; ===> Output keywords & inputs
  APPEND=APPEND,$                      ; Append each graphic
  CLOSE=CLOSE,$                        ; Closes the file [See SAVE method]
  DELAY=DELAY,$                        ; Seconds to delay closing plot window
  BUFFER=BUFFER,$                      ; Draw the plot in the buffer instead of the screen
  BORDER=BORDER,$                      ; [See SAVE method]
  BIT_DEPTH=BIT_DEPTH,$                ; [See SAVE method]
  OBJ=OBJ,$                            ; The plot "object"
  FILE=FILE                            ; Full name of the output file


;+;+
; NAME:
;       PLT_XY
;
; PURPOSE:
;   Creates a scatter plot of X and Y arrays and the functional (or other) linear regression line, the one to one line, and regression statistics
;
; CATEGORY:
;   PLOTS_FUNCTIONS
;   
; CALLING SEQUENCE:
;   PLT_XY, X, Y
;
; REQUIRED INPUTS:
;   X............. X data array
;   Y............. Y data array
;
; OPTIONAL INPUTS:
;   See descriptions above
;
; KEYWORD PARAMETERS:
;   See descriptions above
;  
; OUTPUTS:
;   Displays a scatter plot in the graphics window
;
; OPTIONAL OUTPUTS:
;   The plot can be saved as a .PNG file or returned as an OBJ
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
;   See PLT_XY_DEMO
; 
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 14, 2014 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   MAR 14, 2014 - JEOR: Initial code written - Adapted from PLOTXY and modified for IDL new graphics functions
;   APR 11, 2014 - JEOR: Made X,Y DOUBLE 
;   APR 20, 2014 - JEOR: Added PLT_GRIDS
;   APR 23, 2014 - JEOR: Added PLT_SLOPE & PLT_STRUCT
;   APR 27, 2014 - JEOR: Removed keyword TXXT
;                        Added input parameter Z (for text input) and replaced with XLOG and YLOG keywords
;   APR 30, 2014 - JEOR: Added WINDOW function and fixed multiple plots within a window
;   MAY 01, 2014 - JEOR: All graphics objects now called OBJ
;                        LEG renamed stats for consistency with PLT_HIST2D and older pros
;                        LEG is reserved for legend in future versions 
;   MAY 01, 2014 - KJWH: Added TXT_ALIGN
;                        Added TXT_VALGIN
;                        Added STATS_ALIGN
;                        Added PLT_DIMS (PLOT DIMENSIONS)
;                        Added DEVICE
;                        Added NORMAL
;                        Added DATA
;                        Added POSITION
;   MAY 01, 2014 - JEOR: Defaults are to request the regression line, one to one line, mean and stats
;                        The default plot is a simple scatter plot
;                        Added keyword OBJ to retain the plot object 
;   MAY 04, 2014 - JEOR: Added capability to plot the data line [/LIN_ADD]
;   MAY 20, 2014 - KJWH: Added XY RANGE and TICKNAME keywords
;                        Changed default title to ''
;   JUL 04, 2014 - JEOR: Added steps to log the data just for STATS2
;                         IF KEYWORD_SET(XLOG) THEN XL = ALOG10(XD) ELSE XL = XD
;                         IF KEYWORD_SET(YLOG) THEN YL = ALOG10(YD) ELSE YL = YD
;                         S = STATS2(XL,YL,MODEL=MODEL,PARAMS=PARAMS,DECIMALS=DECIMALS,SHOW=SHOW,FAST=FAST,DOUBLE_SPACE=DOUBLE_SPACE)
;   AUG 05, 2014 - JEOR: Removed ,/OVERPLOT from IF KEYWORD_SET(LIN_ADD)
;   AUG 31, 2014 - JEOR: Added KEY JAY
;   SEP 07, 2014 - JEOR: TXT_COLOR may now be an array of different colors 
;   SEP 10, 2014 - JEOR: Added IF N_ELEMENTS(TXT_COLOR) EQ 1 THEN TXT_COLOR = REPLICATE(TXT_COLOR,N_ELEMENTS(Z))
;   OCT 21, 2014 - JEOR: Added LIN_MID_COLOR,LIN_MID_THICK,LIN_MID_STYLE
;   OCT 24, 2014 - JEOR: Added keywords LEG_FILL_BACKGROUND and LEG_FILL_COLOR
;   NOV 18, 2014 - JEOR: Added defaults for keyword JAY (Jay's default options)
;   MAR 11, 2015 - JEOR: Added FLOORCEIL to NICE_RANGE:
;                        Added IF N_ELEMENTS(XRANGE) NE 2 THEN XRANGE=NICE_RANGE(XD,EXPAND = EXPAND,/FLOORCEIL)
;   APR 07, 2015 - KJWH: Fixed bug at PLOTXY (changed LIN_MID_LINESTYLE to LIN_MID_STYLE)
;   JUL 12, 2015 - JEOR: Removed keyword FLOORCEIL in NICE_RANGE 
;                        IF N_ELEMENTS(XRANGE) NE 2 THEN XRANGE=NICE_RANGE(XD,EXPAND = EXPAND,/FLOORCEIL)
;   NOV 23, 2022 - KJWH: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Changed NONE() to ~N_ELEMENTS()
;                        Changed KEY() to KEYWORD_SET()
;                        Removed the keyword JAY and Jay's defaults
;                        Removed RGB_TABLE = RGBS() because the RGB_TABLE is never used
;
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PLT_XY'
  COMPILE_OPT IDL2

  ; ===> Check for the required input X and Y data
  IF ~N_ELEMENTS(X) OR ~N_ELEMENTS(Y) THEN GOTO, DONE ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  ; ===> Check for the Z input and that it is a string array
  IF N_ELEMENTS(Z) GE 1 THEN IF IDLTYPE(Z) NE 'STRING' THEN MESSAGE,'ERROR: third input must be string'  

  ; ===> Set the plot defaults 
  IF ~N_ELEMENTS(BACKGROUND_COLOR)   THEN BACKGROUND_COLOR = 'WHITE'
  IF ~N_ELEMENTS(TITLE)              THEN TITLE = ''
  IF ~N_ELEMENTS(XTITLE)             THEN XTITLE = ''
  IF ~N_ELEMENTS(YTITLE)             THEN YTITLE = ''
  IF ~N_ELEMENTS(XSTYLE)             THEN XSTYLE = 2 
  IF ~N_ELEMENTS(YSTYLE)             THEN YSTYLE = 2  
  IF ~N_ELEMENTS(MARGIN)             THEN MARGIN = [] ; Use IDLs default margin
  IF ~N_ELEMENTS(PLT_DIMS)           THEN PLT_DIMS = [1024,1024] ; A moderate size for a plot window.  if it is any larger, it may not work on all screens.
  IF ~N_ELEMENTS(POSITION)           THEN POSITION = [] ; Use idls default position

  ; ===> Set the AXES defaults
  IF ~N_ELEMENTS(AXES_COLOR)         THEN AXES_COLOR = 'BLACK'
  IF ~N_ELEMENTS(AXES_FONT_SIZE)     THEN AXES_FONT_SIZE = 16
  IF ~N_ELEMENTS(AXES_THICK)         THEN AXES_THICK = 1
  IF ~N_ELEMENTS(ASPECT_RATIO)       THEN ASPECT_RATIO = 0
  IF ~N_ELEMENTS(EXPAND)             THEN EXPAND = 1.0

  ; ===> Set the GRID defaults
  IF ~N_ELEMENTS(GRID_ADD)          THEN GRID_ADD= 0
  IF ~N_ELEMENTS(GRID_COLOR)         THEN GRID_COLOR= 'BLACK'
  IF ~N_ELEMENTS(GRID_THICK)         THEN GRID_THICK= 2
  IF ~N_ELEMENTS(GRID_LINESTYLE)     THEN GRID_LINESTYLE= 0

  ; ===> Set the PLOT WINDOW display defaults
  IF ~N_ELEMENTS(BUFFER)             THEN BUFFER= 0
  IF ~N_ELEMENTS(LAYOUT)             THEN LAYOUT= 0
  IF ~N_ELEMENTS(DELAY)              THEN DELAY= 0
  
  ;===> DATA IS THE  DEFAULT
  IF ~N_ELEMENTS(DATA) AND ~N_ELEMENTS(NORMAL) AND ~N_ELEMENTS(DEVICE) THEN DATA = 1

  ; ===> Set the SYMBOL defaults
  IF ~N_ELEMENTS(SYM_ADD)            THEN SYM_ADD= 0
  IF ~N_ELEMENTS(SYMBOL)             THEN SYMBOL = '*'
  IF ~N_ELEMENTS(SYM_SIZE)           THEN SYM_SIZE = 1
  IF ~N_ELEMENTS(SYM_THICK)          THEN SYM_THICK = 2
  IF ~N_ELEMENTS(SYM_COLOR)          THEN SYM_COLOR = 'MIDNIGHT BLUE'
  IF ~N_ELEMENTS(SYM_FILLED)         THEN SYM_FILLED = 0
  IF ~N_ELEMENTS(SYM_FILL_COLOR)     THEN SYM_FILL_COLOR = 'MIDNIGHT BLUE'
  IF ~N_ELEMENTS(SYM_CLIP)           THEN SYM_CLIP = 1   ; IDL DEFAULT
  
  ; ===> Set the DATA LINE defaults
  IF ~N_ELEMENTS(LIN_ADD)            THEN LIN_ADD = 0
  IF ~N_ELEMENTS(LIN_COLOR)          THEN LIN_COLOR = 'BLACK'
  IF ~N_ELEMENTS(LIN_STYLE)          THEN LIN_STYLE = 0
  IF ~N_ELEMENTS(LIN_THICK)          THEN LIN_THICK = 3
  IF ~N_ELEMENTS(LIN_MID_COLOR)      THEN LIN_MID_COLOR = 'BLACK'
  IF ~N_ELEMENTS(LIN_MID_STYLE)      THEN LIN_MID_STYLE = 0
  IF ~N_ELEMENTS(LIN_MID_THICK)      THEN LIN_MID_THICK = 1

  ; ===> Set the PLOT SYMBOLS defaults
  IF LIN_ADD EQ 0  AND SYM_ADD EQ 0 THEN SYM_ADD= 1
  IF SYM_ADD EQ 0                   THEN SYMBOL = 'NONE'; USE WHEN PLOTTING TXT AT X,Y

  ; ===> Set the MEAN [X,Y] defaults
  IF ~N_ELEMENTS(MEAN_ADD)           THEN MEAN_ADD= 0
  IF ~N_ELEMENTS(MEAN_SYMBOL)        THEN MEAN_SYMBOL = '+'
  IF ~N_ELEMENTS(MEAN_COLOR)         THEN MEAN_COLOR = 'GOLD'
  IF ~N_ELEMENTS(MEAN_SIZE)          THEN MEAN_SIZE = 5
  IF ~N_ELEMENTS(MEAN_THICK)         THEN MEAN_THICK = 5

  ; ===> Set the ONE2ONE LINE defaults
  IF ~N_ELEMENTS(ONE_ADD)            THEN ONE_ADD = 0
  IF ~N_ELEMENTS(ONE_COLOR)          THEN ONE_COLOR = 'BLACK'
  IF ~N_ELEMENTS(ONE_LINESTYLE)      THEN ONE_LINESTYLE = 0
  IF ~N_ELEMENTS(ONE_THICK)          THEN ONE_THICK = 3

  ; ===> Set the REGRESSION defaults [PLT_SLOPE]
  IF ~N_ELEMENTS(REG_ADD)           THEN REG_ADD = 0
  IF ~N_ELEMENTS(MODEL)              THEN MODEL = 'RMA' 
  IF ~N_ELEMENTS(DECIMALS)           THEN DECIMALS= 3 
  IF ~N_ELEMENTS(PARAMS)             THEN PARAMS= [1,5,6,7,11] 
  IF ~N_ELEMENTS(REG_FONT_SIZE)      THEN REG_FONT_SIZE = 21
  IF ~N_ELEMENTS(REG_COLOR)          THEN REG_COLOR = 'BLACK'
  IF ~N_ELEMENTS(REG_THICK)          THEN REG_THICK = 7
  IF ~N_ELEMENTS(REG_LINESTYLE)      THEN REG_LINESTYLE = 0
  IF ~N_ELEMENTS(REG_MID_COLOR)      THEN REG_MID_COLOR = 'BLACK' ; Should be the same as the regression line unless otherwise specified
  IF ~N_ELEMENTS(REG_MID_THICK)      THEN REG_MID_THICK = 3
  IF ~N_ELEMENTS(REG_MID_LINESTYLE)  THEN REG_MID_LINESTYLE = 0

  ; ===> Set the STATISTICAL LEGEND defaults [for PLT_STRUCT]
  IF ~N_ELEMENTS(STATS_ADD)         THEN STATS_ADD = 0
  IF ~N_ELEMENTS(STATS_POS)          THEN STATS_POS = [0.075,0.85]
  IF ~N_ELEMENTS(STATS_COLOR)        THEN STATS_COLOR = 'BLACK'
  IF ~N_ELEMENTS(STATS_SIZE)         THEN STATS_SIZE = 16
  IF ~N_ELEMENTS(STATS_ALIGN)        THEN STATS_ALIGN = 0
  IF ~N_ELEMENTS(DOUBLE_SPACE)       THEN DOUBLE_SPACE = 0

  ; ===>  Set the STATS text defaults
  IF ~N_ELEMENTS(TXT_ADD)            THEN TXT_ADD = 0
  IF ~N_ELEMENTS(TXT_FONT)           THEN TXT_FONT = "HELVETICA"
  IF ~N_ELEMENTS(TXT_COLOR)          THEN TXT_COLOR = 'MIDNIGHT_BLUE'
  IF ~N_ELEMENTS(TXT_SIZE)           THEN TXT_SIZE = 16
  IF ~N_ELEMENTS(TXT_STYLE)          THEN TXT_STYLE = 2
  IF ~N_ELEMENTS(TXT_ALIGN)          THEN TXT_ALIGN = 0.5
  IF ~N_ELEMENTS(TXT_VALIGN)         THEN TXT_VALIGN = 0.5

  ; ===> Set the LEGEND text defaults
  IF ~N_ELEMENTS(LEG_ADD)                THEN LEG_ADD = 0
  IF ~N_ELEMENTS(LEG_TXT)                THEN LEG_TXT = 'Legend'
  IF ~N_ELEMENTS(LEG_POS)                THEN LEG_POS = [0.75,0.75]
  IF ~N_ELEMENTS(LEG_FONT)               THEN LEG_FONT = 'HELVETICA'
  IF ~N_ELEMENTS(LEG_COLOR)              THEN LEG_COLOR = 'BLUE'
  IF ~N_ELEMENTS(LEG_SIZE)               THEN LEG_SIZE = 16
  IF ~N_ELEMENTS(LEG_STYLE)              THEN LEG_STYLE = 2
  IF ~N_ELEMENTS(LEG_ALIGN)              THEN LEG_ALIGN = 0.5
  IF ~N_ELEMENTS(LEG_VALIGN)             THEN LEG_VALIGN = 0.5
  IF ~N_ELEMENTS(LEG_FILL_BACKGROUND)    THEN LEG_FILL_BACKGROUND = 1
  IF ~N_ELEMENTS(LEG_FILL_COLOR)         THEN LEG_FILL_COLOR = 'WHITE_SMOKE'


  ; ===> Copy X and Y arrays into new variables and convert to double precision
  XD = DOUBLE(X)
  YD = DOUBLE(Y)

  ; ===> Eliminate infinite data or data equal to missing code
  IF ~N_ELEMENTS(MISSINGX) THEN MISSINGX = MISSINGS(XD)
  IF ~N_ELEMENTS(MISSINGY) THEN MISSINGY = MISSINGS(YD)
  OK = WHERE(XD NE MISSINGX AND YD NE MISSINGY,COUNT)
  IF COUNT LT 2 THEN  MESSAGE, 'NOT ENOUGH OBSERVATIONS'
  XD = XD[OK] & YD = YD[OK]

  ; ===> generate a nice XRANGE and YRANGE
  IF N_ELEMENTS(XRANGE) NE 2 THEN XRANGE=NICE_RANGE(XD, EXPAND=EXPAND)
  IF N_ELEMENTS(YRANGE) NE 2 THEN YRANGE=NICE_RANGE(YD, EXPAND=EXPAND)
  
  ; ===> Check for OUTLIERS (eliminate outlier ratios of 10:1, 1:10 etc.)
  IF KEYWORD_SET(OUTLIERS) THEN BEGIN
    OUTLIERS = DOUBLE(OUTLIERS)
    OK = WHERE((YD/XD) LT OUTLIERS AND (YD/XD) GT (1.0D/OUTLIERS), COUNT)
    XD = XD[OK] & YD = YD[OK]
    IF COUNT LT 2 THEN BEGIN
      PRINT, 'ERROR: Not enough observations'
      GOTO, DONE
    ENDIF
  ENDIF
 
  ; ===> Log data just for STATS2
  IF KEYWORD_SET(XLOG) THEN XL = ALOG10(XD) ELSE XL = XD
  IF KEYWORD_SET(YLOG) THEN YL = ALOG10(YD) ELSE YL = YD
  S = STATS2(XL,YL,MODEL=MODEL,PARAMS=PARAMS,DECIMALS=DECIMALS,DOUBLE_SPACE=DOUBLE_SPACE)
  
  ; ===> Plot data SYMBOLS ?
  IF KEYWORD_SET(SYM_ADD) THEN PLT = PLOT(XD,YD,BUFFER=BUFFER ,CURRENT=CURRENT,$
    BACKGROUND_COLOR=BACKGROUND_COLOR, ASPECT_RATIO=ASPECT_RATIO,$
    DIMENSIONS=PLT_DIMS, LAYOUT=LAYOUT, POSITION=POSITION, MARGIN=MARGIN,$
    TITLE=TITLE, XTITLE=XTITLE, YTITLE=YTITLE,$
    XLOG=XLOG, YLOG=YLOG, XRANGE=XRANGE, YRANGE=YRANGE, XSTYLE=XSTYLE, YSTYLE=YSTYLE,XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,$
    XTICKV=XTICKV, YTICKV=YTICKV, XMINOR=XMINOR, YMINOR=YMINOR, FONT_SIZE=AXES_FONT_SIZE, LINESTYLE='NONE',$
    SYMBOL=SYMBOL, SYM_FILLED=SYM_FILLED, SYM_COLOR=SYM_COLOR, SYM_FILL_COLOR=SYM_FILL_COLOR, SYM_SIZE=SYM_SIZE, SYM_THICK=SYM_THICK, CLIP=SYM_CLIP,$
    XTICKFORMAT='(G0)', XCOLOR=AXES_COLOR, XTHICK=AXES_THICK, YTICKFORMAT='(G0)', YCOLOR=AXES_COLOR, YTHICK= AXES_THICK)

  ; ===> Plot data as a LINE/CURVE ?
  IF KEYWORD_SET(LIN_ADD) THEN BEGIN
    PLT = PLOT(XD,YD,/NO_TOOLBAR, BUFFER=BUFFER ,CURRENT=CURRENT,$
      BACKGROUND_COLOR=BACKGROUND_COLOR, ASPECT_RATIO=ASPECT_RATIO, DIMENSIONS=PLT_DIMS, LAYOUT=LAYOUT, POSITION=POSITION, MARGIN=MARGIN,$
      TITLE=TITLE, XTITLE=XTITLE, YTITLE=YTITLE, XTICKNAME=XTICKNAME, YTICKNAME=YTICKNAME, XLOG=XLOG, YLOG=YLOG, XRANGE=XRANGE, YRANGE=YRANGE,$
      XTICKV=XTICKV, YTICKV=YTICKV, XMINOR=XMINOR, YMINOR=YMINOR, XSTYLE=XSTYLE, YSTYLE=YSTYLE, FONT_SIZE=AXES_FONT_SIZE, SYMBOL ='NONE',$
      COLOR=LIN_COLOR,THICK=LIN_THICK, XTICKFORMAT='(G0)', XCOLOR=AXES_COLOR, XTHICK=AXES_THICK, YTICKFORMAT='(G0)', YCOLOR=AXES_COLOR, YTHICK= AXES_THICK)
    IF LIN_THICK GE 3 THEN  PLT=PLOT(X,Y,/OVERPLOT,COLOR = LIN_MID_COLOR,THICK = LIN_MID_THICK,LINESTYLE =LIN_MID_STYLE)
  ENDIF;IF KEYWORD_SET(LIN_ADD) THEN BEGIN 

  ; ===> Add GRIDLINES ?
  IF KEYWORD_SET(GRID_ADD) THEN PLT_GRIDS, PLT, COLOR=GRID_COLOR, THICK=GRID_THICK, LINESTYLE=GRID_LINESTYLE

  ; ===> Add SLOPE ?
  IF KEYWORD_SET(REG_ADD) THEN PLT_SLOPE, PLT,STRUCT=S, REG_COLOR=REG_COLOR,REG_THICK=REG_THICK,REG_LINESTYLE=REG_LINESTYLE,$
   REG_MID_COLOR=REG_MID_COLOR,REG_MID_THICK=REG_MID_THICK,REG_MID_LINESTYLE=REG_MID_LINESTYLE

; ===> Add the ONE TO ONE line ?
  IF KEYWORD_SET(ONE_ADD) THEN PLT_ONE2ONE, PLT, COLOR=ONE_COLOR, LINESTYLE=ONE_LINESTYLE, THICK=ONE_THICK

; ===> Add MEAN ?
  IF KEYWORD_SET(MEAN_ADD) THEN PLT_MEAN, PLT, SYMBOL=MEAN_SYMBOL, SYM_SIZE=MEAN_SIZE, SYM_COLOR=MEAN_COLOR, SYM_THICK=MEAN_THICK, XLOG=XLOG, YLOG=YLOG

; ===> Add STATS LEGEND
  IF KEYWORD_SET(STATS_ADD) THEN PLT_STRUCT, PLT, STRUCT=S, POS=STATS_POS, COLOR=STATS_COLOR, FONT_SIZE=STATS_SIZE, THICK=3

; ===> PLOT Z at X,Y locations 
  IF  N_ELEMENTS(Z) GE 1 THEN BEGIN
    IF N_ELEMENTS(TXT_COLOR) EQ 1 THEN TXT_COLOR = REPLICATE(TXT_COLOR,N_ELEMENTS(Z))
    SETS=WHERE_SETS(TXT_COLOR)    
    FOR S = 0,N_ELEMENTS(SETS)-1 DO BEGIN
      SET = SETS[S]
      SUBS = WHERE_SETS_SUBS(SET)
      COLOR = SET.VALUE
      T = TEXT(XD[SUBS], YD[SUBS], STRTRIM(Z[SUBS],2), COLOR=COLOR, FONT_SIZE=TXT_SIZE, FONT_STYLE=TXT_STYLE,$
          FONT_NAME=TXT_FONT, TARGET=PLT, DEVICE=DEVICE, DATA=DATA, NORMAL=NORMAL, ALIGNMENT=TXT_ALIGN, VERTICAL_ALIGNMENT=TXT_VALIGN)
    ENDFOR;FOR S = 0,N_ELEMENTS(SETS)-1 DO BEGIN
  ENDIF;IF  N_ELEMENTS(Z) GE 1 THEN BEGIN

  ;===> Add the LEGEND ?
  IF KEYWORD_SET(LEG_ADD) THEN T = TEXT(LEG_POS[0],LEG_POS[1],/RELATIVE,LEG_TXT,FONT_SIZE = LEG_SIZE,COLOR = LEG_COLOR, TARGET=PLT, ALIGNMENT=LEG_ALIGN, VERTICAL_ALIGNMENT=LEG_VALIGN,FILL_BACKGROUND = LEG_FILL_BACKGROUND,FILL_COLOR=LEG_FILL_COLOR)
 
  WAIT,DELAY

  ; ===> CONSERVE THE PLT OBJECT IN OBJ
  OBJ = PLT

  IF KEYWORD_SET(FILE) THEN PLT_WRITE,PLT,FILE=FILE,BORDER=BORDER,BIT_DEPTH=BIT_DEPTH,APPEND=APPEND,CLOSE=CLOSE
  IF KEYWORD_SET(CLOSE) AND ~KEYWORD_SET(CURRENT) THEN PLT.CLOSE
  
  DONE: 
 
END; #####################  END OF ROUTINE ################################

