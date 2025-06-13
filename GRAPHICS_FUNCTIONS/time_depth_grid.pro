; $ID:	TIME_DEPTH_GRID.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO TIME_DEPTH_GRID, DATE_ARRAY, DEPTH_ARRAY, ARRAY,$
                       PROD=PROD, PAL=PAL, TOP_COLOR=TOP_COLOR,$
                       MDATE=MDATE, MDEPTH=MDEPTH, DEPTH_INTERVAL=DEPTH_INTERVAL, AX_INTERVAL=AXINTERVAL, NEAR=NEAR,$
                       INTERPOLATE=INTERPOLATE, DIMENSIONS=DIMENSIONS, MAKE_MISSINGS=MAKE_MISSINGS,$
                       TITLE=TITLE, BLANK_WINDOW=BLANK_WINDOW, $
                       XTITLE=XTITLE, NOXDATES=NOXDATES, ADD_DATE_TICKS=ADD_DATE_TICKS, DATE_SYMBOL=DATE_SYMBOL, DATE_FILL=DATE_FILL, DATE_COLOR=DATE_COLOR, DATE_SIZE=DATE_SIZE,$
                       FYEAR=FYEAR, ADD_YEAR_TITLE=ADD_YEAR_TITLE,$
                       YTITLE=YTITLE,YRANGE=YRANGE, YTITLE_ORIENTATION=YTITLE_ORIENTATION, DEPTH_CUTOFF=DEPTH_CUTOFF,
                       ADD_SAMPLE_POINTS=ADD_SAMPLE_POINTS, SAMPLE_SYMBOL=SAMPLE_SYMBOL, SAMPLE_FILL=SAMPLE_FILL, SAMPLE_COLOR=SAMPLE_COLOR, SAMPLE_SIZE=SAMPLE_SIZE,$
                            LAYOUT=LAYOUT,PAL=PAL,XMINOR=XMINOR,XMAJOR=XMAJOR,YMINOR=YMINOR,YMAJOR=YMAJOR,MARGIN=MARGIN,$
                         PROD=PROD, SPECIAL_SCALE=SPECIAL_SCALE, LOG=LOG, INTERPOLATE=INTERPOLATE, MAKE_MISSING=MAKE_MISSING,NODEPTH=NODEPTH,EXTRA=EXTRA,TARGET=TARGET,$


                       
                       MISSING_COLOR=MISSING_COLOR, $
                       
                       RETURN_IMAGE=RETURN_IMAGE, OUT_IMAGE=OUT_IMAGE

;+
; NAME:
;   TIME_DEPTH_GRID
;
; PURPOSE:
;   Creates a gridded contour of a depth-dependent variable over time
;
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   TIME_DEPTH_GRID, DATE_ARRAY, DEPTH_ARRAY, ARRAY
;
; REQUIRED INPUTS:
;   DATE_ARRAY...... The date array (yyyymmdd or yyyymmddhhmmss)
;   DEPTH_ARRAY..... The depth array
;   ARRAY........... The data array
;
; OPTIONAL INPUTS:
;   PROD............ The product name (with or without the data range)
;   PAL............. The color palette
;   TOP_COLOR....... Maximum color for the colorbar scaling (default=250)
;   MISSING_COLOR... The palette color number for "missing" data
;   FONT_SIZE....... The font size for the plots
;   YTITLE_ORIENTATION..... The orientation for the year label
;   MDATE........... Two element array of the minimum and maximum dates
;   MDEPTH.......... The two element array of the minimum and maximum depths
;   AX_INTERVAL..... The xaxis interval for DATE_AXIS (e.g. 'DAY, 'MONTH', 'YEAR')
;   DEPTH_INTERVAL.. The depth interval to fill in the missing data with (0.5 meters, 2 meters, etc.)
;   DIMENSIONS...... Input variable to GRIDDATA
;   NEAR............ Input variable to WHERE_NEAREST for filling in the new structure
;
; KEYWORD PARAMETERS:
;   INTERPOLATE..... To interpolate values within the profile
;   MAKE_MISSINGS... Keyword input into INTERP_XTEND
;   NOXDATES........ Keyword to omit the X axis date labels
; 
; OUTPUTS:
;   A gridded plot showing depth over time
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
;   Jan 03, 2022 - KJWH: Initial code written - adapted from TIME_DEPTH_GRID_NG
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'TIME_DEPTH_GRID'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DATE_ARRAY) NE N_ELEMENTS(DEPTH_ARRAY) OR N_ELEMENTS(DATE_ARRAY) EQ N_ELEMENTS(ARRAY) THEN MESSAGE, 'ERROR: DATE, DEPTH and DATA arrays must be equal'
  DT = DATE_ARRAY
  DP = DEPTH_ARRAY
  AR = ARRAY
  
  IF ~N_ELEMENTS(PROD) THEN PRD = 'NUM' ELSE PRD = PROD
  IF ~N_ELEMENTS(AX_INTERVAL) THEN AX_INTERVAL = 'MONTH'
  
; ===> Plotting defaults
  IF ~N_ELEMENTS(PAL)  THEN PAL = 'PAL_DEFAULT'
  IF ~N_ELEMENTS(MISSING_COLOR) THEN MISSING_COLOR = 255
  IF ~N_ELEMENTS(TOP_COLOR) THEN TOP_COLOR = 250          
  IF ~N_ELEMENTS(FONT_SIZE) THEN FONT_SIZE = 14
  
  IF N_ELEMENTS(MDATE) NE 2 THEN MDATE = [MIN(DT),MAX(DT)]
  
  CASE AX_INTERVAL OF 
    'SECOND'  : AX = DATE_AXIS(DATE_2JD(MDATE),/SECOND)
    'MINUTE'  : AX = DATE_AXIS(DATE_2JD(MDATE),/MINUTE)
    'HOUR'    : AX = DATE_AXIS(DATE_2JD(MDATE),/HOUR)
    'DAY'     : AX = DATE_AXIS(DATE_2JD(MDATE),/DAY)
    'MONTH'   : AX = DATE_AXIS(DATE_2JD(MDATE),/MONTH)
    'YEAR'    : AX = DATE_AXIS(DATE_2JD(MDATE),/YEAR)
  ENDCASE
  IF KEYWORD_SET(FYEAR) AND AX_INTERVAL EQ 'MONTH' THEN AX = DATE_AXIS(DATE_2JD(MDATE),/MONTH,/FYEAR)
  
  IF ~KEYWORD_SET(NOXDATES) THEN XTICKNAME=AX.TICKNAME ELSE XTICKNAME = REPLICATE('',N_ELEMENTS(AX.TICKNAME))
  XMAJOR=AX.TICKS
  XTICKVALUES=AX.TICKV
  XRANGE = [MIN(AX.JD),MAX(AX.JD)]
  
  


END ; ***************** End of TIME_DEPTH_GRID *****************
