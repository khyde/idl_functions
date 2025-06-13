; $ID:	GRIDDED_TIMESERIES_PLOT.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO GRIDDED_TIMESERIES_PLOT, $
        ; Data inputs
        DATES, ARRAY,$
        ; Interpolation parameters
        DATERANGE=DATERANGE, DATA_DATERANGE=DATA_DATERANGE, INTERPOLATE=INTERPOLATE, MAKE_MISSING=MAKE_MISSING, DIMENSIONS=DIMENSIONS,$
        ; Plotting parameters
        PROD=PROD, LOG=LOG, $
        AX_INTERVAL=AX_INTERVAL, FYEAR=FYEAR, NOXDATES=NOXDATES,$
        YTITLE=YTITLE, YT_ORIENTATION=YT_ORIENTATION,$
        PAL=PAL, COLOR_RANGE=COLOR_RANGE, MISSING_COLOR=MISSING_COLOR,$
        FONT_SIZE=FONT_SIZE, POSITION=POSTION, MARGIN=MARGIN, LAYOUT=LAYOUT,$
        CURRENT=CURRENT, BUFFER=BUFFER, OBJ=OBJ

;+
; NAME:
;   GRIDDED_TIMESERIES_PLOT
;
; PURPOSE:
;   Create a plot of the gridded timeseries
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_GRIDDED_TIMESERIES, DATES, ARRAY
;
; REQUIRED INPUTS:
;   DATES........... The date array (yyyymmdd or yyyymmddhhmmss)
;   ARRAY........... The data array
;   
; OPTIONAL INPUTS:
;   DATERANGE....... Two element array of the minimum and maximum dates for the plotting 
;   DATA_DATERANGE... Two element array of the minimum and maximum dates of the data
;   DIMENSIONS...... Input variable to GRIDDATA
;   
;   PROD............ The name of the prod represented by the array (with or without scaling)
;   AX_INTERVAL..... The xaxis interval for DATE_AXIS (e.g. 'DAY, 'MONTH', 'YEAR')
;   YTITLE.......... The text for the Y axis label
;   YT_ORIENTATION.. The text orientation for the Y axis lable
;   PAL............. The name of the color palette
;   COLOR_RANGE..... The range of the colorbar scaling (default=[1,250])
;   MISSING_COLOR... The palette color number for "missing" data
;   FONT_SIZE....... The font size for the plots
;   MARGIN.......... The margin size for the plots
;   POSITION........ The position for the images on the graphics window
;   LAYOUT.......... The number of total plots and staring position for the plots (e.g. [1,20,10] = 1 wide x 20 tall, starting at position 10) 
;   
; KEYWORD PARAMETERS:
;   INTERPOLATE..... To interpolate values within the profile
;   MAKE_MISSINGS... Keyword input into INTERP_XTEND
;   LOG............. To plot the data on a log scale
;   FYEAR........... To omit the YEAR in the X date labels
;   NOXDATES........ To omit the XTICK lables
;   CURRENT......... To add the image to an existing graphics window
;   BUFFER.......... To hide the graphics in the background
;   
; OUTPUTS:
;   A plot of the gridded timeseries
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
;   DATES = '20210101000000' & FOR D=1, 365/5-1 DO DATES=[DATES,JD_2DATE(JD_ADD(DATE_2JD(20210101),D*5,/DAY))]
;   VAR = FLOAT(30*RANDOMU(SEED,N_ELEMENTS(DATES)))
;   GRIDDED_TIMESERIES_PLOT, DATES, VAR
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 03, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 03, 2022 - KJWH: Initial code written - Adapted from TIME_DEPTH_GRID_NG
;   Oct 30, 2023 - KJWH: Added DATA_DATERANGE so that data that does not extend through the entire year are not "extended" in the plot.  May need to add a similar update for the beginning of the array if it doesn't start on Jan 1
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GRIDDED_TIMESERIES_PLOT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(GRID_Y) THEN GRID_Y=10
  
; ===> Create the interpolated "image"
  IF N_ELEMENTS(DATERANGE) NE 2 THEN DTR = [MIN(DATES),MAX(DATES)] ELSE DTR=DATERANGE & DTR = GET_DATERANGE(DTR)  ; Get the daterange
  IF N_ELEMENTS(DATA_DATERANGE) NE 2 THEN DATA_DTR = DTR ELSE DATA_DTR = GET_DATERANGE(DATA_DATERANGE)
  CR = CREATE_DATE(DTR[0],DTR[1])
  DATA_CR  = CREATE_DATE(DATA_DTR[0],DATA_DTR[1])                                                                                ; Create a full array of dates
  OK = WHERE_MATCH(CR,DATES,COUNT,VALID=VALID,NINVALID=NINVALID)                         ; Find where the input dates match the full date array
  IF NINVALID GT 0 THEN MESSAGE, 'ERROR: Some input dates were not in the full date array'                     ; Check the match-ups

  VAR = INTERP_XTEND(DATE_2JD(DATES),ARRAY,DATE_2JD(DATA_CR),MAKE_MISSING=MAKE_MISSING)                                ; Interpolate and "extend" the data array
  INTERP_DATA = VAR.Y
  IF KEYWORD_SET(INTERP_SPAN_WINDOW) THEN $                                                                       ; Blank out parts of the "image" if the interpolation span exceeds the "window"
    TS_INTERP_BLANK, JD=DATE_2JD(DATES),INTERP_DATA=INTERP_DATA, INTERP_JD=DATE_2JD(DATA_CR), SPAN=INTERP_SPAN_WINDOW, MISS=MISSINGS(NEW.VAR)
  ARR = INTERP_DATA
  
  GRID = FLTARR(N_ELEMENTS(CR),GRID_Y)                                                                            ; Make the grid
  FOR N=0, GRID_Y-1 DO GRID[0:N_ELEMENTS(ARR)-1,N] = ARR                                                                            ; Fill in the grid
 
  ; ===> Plotting defaults
  IF N_ELEMENTS(PROD) EQ 1 THEN PRD = PROD ELSE BEGIN
    IF KEYWORD_SET(LOG) THEN PRD = 'LNUM' ELSE PRD = 'NUM'
    PRD = STRJOIN([PRD,ROUNDS(NICE_RANGE(ARRAY),1)],'_')
  ENDELSE
  
  IF ~N_ELEMENTS(AX_INTERVAL) THEN AX_INTERVAL = 'MONTH'
  IF ~N_ELEMENTS(PAL)  THEN PAL = 'PAL_DEFAULT'
  IF ~N_ELEMENTS(MISSING_COLOR) THEN MISSING_COLOR = 255
  IF N_ELEMENTS(COLOR_RANGE) NE 2 THEN COLOR_RANGE = [1,250]
  IF ~N_ELEMENTS(FONT_SIZE) THEN FONT_SIZE = 14

  MDATE = [MIN(DATERANGE),MAX(DATERANGE)]

  CASE AX_INTERVAL OF
    'SECOND'  : AX = DATE_AXIS(DATE_2JD(MDATE),/SECOND)
    'MINUTE'  : AX = DATE_AXIS(DATE_2JD(MDATE),/MINUTE)
    'HOUR'    : AX = DATE_AXIS(DATE_2JD(MDATE),/HOUR)
    'DAY'     : AX = DATE_AXIS(DATE_2JD(MDATE),/DAY)
    'MONTH'   : AX = DATE_AXIS(DATE_2JD(MDATE),/MONTH)
    'YEAR'    : AX = DATE_AXIS(DATE_2JD(MDATE),/YEAR)
  ENDCASE
  IF KEYWORD_SET(FYEAR) AND AX_INTERVAL EQ 'MONTH' THEN AX = DATE_AXIS(DATE_2JD(MDATE),/MONTH,/FYEAR)

  IF ~KEYWORD_SET(NOXDATES) THEN XTICKNAMES=AX.TICKNAME ELSE XTICKNAMES = REPLICATE('',N_ELEMENTS(AX.TICKNAME))
  XMAJOR=AX.TICKS
  XTICKVALUES=AX.TICKV
  XRANGE = [MIN(AX.JD),MAX(AX.JD)]

; ===> Create an image of the data
  IMG = BYTE(GRID) & IMG[*,*]=0
  FIN = FINITE(GRID)
  OK = WHERE(FIN EQ 1,COUNT, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)
  IF COUNT GE 1 THEN IMG[OK] = PRODS_2BYTE(GRID[OK],PROD=PRD, CB_RANGE=COLOR_RANGE)
  IF NCOMP GE 1 THEN IMG[COMP] = MISSING_COLOR
  
  IM = IMAGE(IMG,RGB_TABLE=CPAL_READ(PAL),AXIS_STYLE=2,LAYOUT=LAYOUT,XMAJOR=0,YTICKNAME='',YMAJOR=0,XMINOR=0,YMINOR=0,CURRENT=CURRENT,BUFFER=BUFFER,MARGIN=MARGIN,POSITION=POSITION,TITLE=TITLE,FONT_SIZE=FONT_SIZE)
  XAX = AXIS('X',LOCATION=[0,0],TICKNAME=XTICKNAMES,MAJOR=XMAJOR,MINOR=0,TICKVALUES=JD_2DOY(XTICKVALUES),TITLE=XTITLE,TICKLEN=0.2,TARGET=IM,TICKFONT_SIZE=FONT_SIZE)
  IF KEYWORD_SET(YTITLE) THEN TXT = TEXT(MIN(IM.XRANGE)-1,MEAN(IM.YRANGE),YTITLE,ALIGNMENT=1,VERTICAL_ALIGNMENT=0.5,CLIP=0,COLOR='BLACK',FONT_SIZE=FONT_SIZE,/DATA,TARGET=IM,ORIENTATION=YT_ORIENTATION)

  OBJ=IM

END ; ***************** End of GRIDDED_TIMESERIES_PLOT *****************
