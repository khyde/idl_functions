; $ID:	STACKED_GRIDDED_TIMESERIES.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO STACKED_GRIDDED_TIMESERIES, $
        STRUCT, PROD_TAG, $
        PROD=PROD, YEARS=YEARS, PAL=PAL, $
        GRID_DIMS=GRID_DIMS, INTERPOLATE=INTERPOLATE, $
        TITLE=TITLE, YTITLE=YTITLE, XTITLE=XTITLE,MARGIN=MARGIN,$
        ADD_CB=ADD_CB, CB_POS=CB_POS, CB_TYPE=CB_TYPE, CB_TITLE=CB_TITLE,$
        OBJ=OBJ, WIN_DIMS=WIN_DIMS, LAYOUT=LAYOUT, CURRENT=CURRENT, BUFFER=BUFFER

;+
; NAME:
;   STACKED_GRIDDED_TIMESERIES
;
; PURPOSE:
;   To create a plot with annual stacked gridded timeseries
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_GRIDDED_TIMESERIES,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   STRUCT.......... A structure containing the DATE/PERIOD and the data to be plotted
;   PROD_TAG........ The tagname in the structure for the data to be plotted
;
; OPTIONAL INPUTS:
;   PROD............ The product name for the data byte scaling
;   GRID_DIMS....... The grid dimensions passed to GRIDDED_TIMESERIES
;   
;   YEARS............. The years for the plots
;   
;   
;   
;   OBJ............. The graphics window
;   WIN_DIMS........ The dimensions for the graphics window (if CURRENT is not set)
;   SPACE........... Used to calculate the plot spacing and window dimensions
;   LAYOUT.......... The number of total plots and staring position for the plots (e.g. [1,20,10] = 1 wide x 20 tall, starting at position 10)
;   
;   TITLE........... The title for the plot(s)
;   XTITLE.......... A title for the X axis
;   YTITLE.......... A title for the Y axis
;   
;   AX_INTERVAL..... The xaxis interval for DATE_AXIS (e.g. 'DAY, 'MONTH', 'YEAR')
;   YT_ORIENTATION.. The orientation for the Y axis lable
;   PAL............. The color palette
;   COLOR_RANGE..... The range of the colorbar scaling (default=[1,250])
;   MISSING_COLOR... The palette color number for "missing" data
;   FONT_SIZE....... The font size for the plots
;   
;   
;   CB_TYPE.........
;   CB_POSITION.....
;   CB_TITLE
;
; KEYWORD PARAMETERS:
;   
;   NO_YEAR_TITLE... Omit the Year titles
;   
;   ADD_CB.......... Keyword to add the colorbar
;   
;   CURRENT......... To add the image to an existing graphics window
;   BUFFER.......... To hide the graphics in the background
;   
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 03, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jan 03, 2022 - KJWH: Initial code written
;   Oct 30, 2023 - KJWH: Added steps for working with data series that are shorter than a full year.  Now passing in DATA_DATERANGE to the gridded timeseries plotting routine
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'STACKED_GRIDDED_TIMESERIES'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
; ===> Get the data from the structure
  IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE, 'ERROR: Must provide an input data structure'
  IF ~N_ELEMENTS(PROD_TAG) THEN MESSAGE, 'ERROR: Must provide the tag name of the variable to plot'
  TAGS = TAG_NAMES(STRUCT)
  IF WHERE(TAGS EQ PROD_TAG,/NULL) EQ [] THEN MESSAGE, 'ERROR: ' + PROD_TAG + ' not found in the structure.'
  ARRAY = STRUCT.(WHERE(TAGS EQ PROD_TAG))
  IF WHERE(TAGS EQ 'PERIOD',/NULL) EQ [] AND WHERE(TAGS EQ 'DATE',/NULL) EQ [] THEN MESSAGE, 'ERROR: PERIOD or DATE tags must be in the structure.'
  IF WHERE(TAGS EQ 'PERIOD',/NULL) NE [] THEN DATES = PERIOD_2DATE(STRUCT.PERIOD) $
                                         ELSE DATES = STRUCT.DATE 
  DP = DATE_PARSE(DATES)
  
; ===> Set up defaults
  IF ~N_ELEMENTS(YT_ORIENTATION) THEN YT_ORIENTATION = 1
  IF N_ELEMENTS(GRID_DIMS) NE 2 THEN GRID_DIMS = [365,10]
  
  DTR = GET_DATERANGE(MIN(DATES),MAX(DATES))
  IF N_ELEMENTS(YEARS) EQ 0 THEN YEARS = YEAR_RANGE(DTR[0],DTR[1],/STRING)
  NYRS = N_ELEMENTS(YEARS)
  
  
  IF ~N_ELEMENTS(SPACE) THEN SPACE=GRID_DIMS[1]
  IF ~N_ELEMENTS(TITLE) THEN TOP=SPACE*2 ELSE TOP=SPACE*3
  IF ~N_ELEMENTS(YTITLE) THEN LFT=SPACE*2 ELSE LFT=SPACE*3
  IF ~KEYWORD_SET(NO_YEAR_TITLE) THEN LFT = LFT+SPACE*2
  RHT = SPACE*2
  IF KEYWORD_SET(ADD_CB) THEN BEGIN ; Add room for the colorbar
    IF N_ELEMENTS(CB_TYPE) THEN IF CB_TYPE GT 3 THEN RHT = RHT+SPACE*5 $
    ELSE BOT = BOT+SPACE*5
  ENDIF
    
  IF ~KEYWORD_SET(CURRENT) THEN BEGIN
    IF ~N_ELEMENTS(WIN_DIMS) THEN WIN_DIMS = [TOP+BOT+NYRS*SPACE,LFT+RHT+GRID_DIMS[0]]
    IF ~N_ELEMENTS(LAYOUT) THEN LAYOUT = [1,WIN_DIMS[1]/SPACE,TOP/SPACE+1] 
    OBJ = WINDOW(DIMENSIONS=WIN_DIMS,BUFFER=BUFFER)
  ENDIF ELSE IF IDLTYPE(OBJ) NE 'OBJREF' THEN MESSAGE, 'ERROR: Must provide a graphics window object'
  IF N_ELEMENTS(LAYOUT) NE 3 THEN MESSAGE, 'ERROR: Must provide the image layout.'
  
  POS1 = []
  FOR Y=0, NYRS-1 DO BEGIN
    YR = YEARS[Y]
    LYT = [LAYOUT[0],LAYOUT[1],LAYOUT[2]+Y]
    OK = WHERE(DP.YEAR EQ YR,/NULL) & IF OK EQ [] THEN CONTINUE
    DARR = DATES[OK] & ARR = ARRAY[OK]
    SRT = SORT(DARR) & DARR = DARR[SRT] & ARR = ARR[SRT]
    
    DATERANGE = GET_DATERANGE(YR)
    IF MAX(DATE_2JD(DARR)) LT JD_ADD(DATE_2JD(DATERANGE[1]),-8,/DAY) THEN DATA_DATERANGE = GET_DATERANGE([DATERANGE[0], MAX(DARR)] ) ELSE DATA_DATERANGE = DATERANGE
    
    IF Y EQ NYRS-1 THEN NOXDATES=0 ELSE NOXDATES=1
    GRIDDED_TIMESERIES_PLOT, DARR, ARR, DATERANGE=DATERANGE, DATA_DATERANGE=DATA_DATERANGE, INTERPOLATE=INTERPOLATE, MAKE_MISSING=MAKE_MISSING, DIMENSIONS=GRID_DIMS,$
      ; Plotting parameters
      PROD=PROD, LOG=LOG, AX_INTERVAL=AX_INTERVAL, /FYEAR, NOXDATES=NOXDATES,$
      YTITLE=YR, YT_ORIENTATION=YT_ORIENTATION, PAL=PAL, COLOR_RANGE=COLOR_RANGE, MISSING_COLOR=MISSING_COLOR,$
      FONT_SIZE=FONT_SIZE, POSITION=POSITION, MARGIN=MARGIN, $
      LAYOUT=LYT,CURRENT=CURRENT, BUFFER=BUFFER, OBJ=OBJ
    IF POS1 EQ [] THEN POS1 = OBJ.POSITION
  ENDFOR
  
  IF KEYWORD_SET(ADD_CB) THEN BEGIN
    IF ~N_ELEMENTS(CB_TYPE) THEN CB_TYPE=5
    IF N_ELEMENTS(CB_POS) NE 4 THEN BEGIN
      POS = OBJ.POSITION
      HSP = POS[2]-POS[0]
      VSP = POS1[3]-POS[1]
      IF CB_TYPE LE 3 THEN CBPOS = [POS[0]+HSP*0.05,POS[1]-0.02,POS[0]+HSP*0.95,POS[1]-0.05] $
                      ELSE CBPOS = [POS[2]+0.01,POS[3],POS[2]+0.04,POS1[1]]
    ENDIF ELSE CBPOS=CB_POS
    CBAR, PROD, OBJ=OBJ, FONT_SIZE=FONT_SIZE, CB_TYPE=CB_TYPE, CB_POS=CBPOS, CB_TITLE=CB_TITLE, CB_TICKSN=CB_TICKS, PAL=PAL
  ENDIF



END ; ***************** End of STACKED_GRIDDED_TIMESERIES *****************
