; $ID:	GRIDDED_TIMESERIES_INTERPOLATION.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION GRIDDED_TIMESERIES_INTERPOLATION, DATE_ARRAY, ARRAY, $
                       DATERANGE=DATERANGE, INTERPOLATE=INTERPOLATE, MAKE_MISSING=MAKE_MISSING, INTERP_SPAN_WINDOW=INTERP_SPAN_WINDOW, DIMENSIONS=DIMENSIONS
         
;+
; NAME:
;   GRIDDED_TIMESERIES_INTERPOLATION
;
; PURPOSE:
;   Function to create a "grid" of timeseries data
;   
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   TIME_DEPTH_INTERPOLATION, DATE_ARRAY, DEPTH_ARRAY, ARRAY
;
; REQUIRED INPUTS:
;   DATE_ARRAY...... The date array (yyyymmdd or yyyymmddhhmmss)
;   ARRAY........... The data array
;
; OPTIONAL INPUTS:
;   DATERANGE........... Two element array of the minimum and maximum dates
;   INTERP_SPAN_WINDOW.. The span window to blank out data in the interpolated array if number of days between input data is too big
;   DIMENSIONS.......... Input variable to GRIDDATA
;
; KEYWORD PARAMETERS:
;   INTERPOLATE..... To interpolate values within the profile
;   MAKE_MISSINGS... Keyword input into INTERP_XTEND
; 
; OUTPUTS:
;   A gridded time array
;
; OPTIONAL OUTPUTS:
;   DATERANGE....... If not provided, it will be based on the min and max date array
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
;   This is designed for interpolating data collected over time for making a gridded plot.  
;     * First the timeseries are interpolated throughout the time span
;     * Then the data are "gridded" over time using TRIANGULATE and GRIDDATA
;   The output can then be plotted using STACKED_GRIDDED_TIMESERIES
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
;   Jan 05, 2022 - KJWH: Initial code written - adapted from TIME_DEPTH_GRID_NG
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GRIDDED_TIMESERIES_INTERPOLATION'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DATE_ARRAY) NE N_ELEMENTS(ARRAY) THEN MESSAGE, 'ERROR: DATE and DATA arrays must be equal'
  IF ~N_ELEMENTS(INTERPOLATE) THEN INTERPOLATE = 1 ; Default is to interpolate the data
  
; ===> Set up DATE data
  DT = DATE_ARRAY
  IF N_ELEMENTS(DATERANGE) NE 2 THEN DTR = [MIN(DT),MAX(DT)] ELSE DTR=DATERANGE
  
  CR  = CREATE_DATE(DTR[0],DTR[1])
  NEW = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('DATE','','DEPTH',0.0,'VAR',0.0)),N_ELEMENTS(CR))
  NEW.DATE = CR
  NEW.DEPTH = 0

  OK = WHERE_MATCH(NEW.DATE,DT,COUNT,VALID=VALID,NCOMPLEMENT=ncomplement,COMPLEMENT=complement,ninvalid=ninvalid,invalid=invalid)
  IF COUNT GE 1 THEN NEW[OK].VAR = ARRAY[VALID]
  IF NCOMPLEMENT GE 1 THEN NEW[COMPLEMENT].VAR = MISSINGS(0.0)

  IF KEYWORD_SET(INTERPOLATE) AND COUNT GE 2 THEN BEGIN
    VAR = INTERP_XTEND(DATE_2JD(NEW[OK].DATE),NEW[OK].VAR,DATE_2JD(NEW.DATE),MAKE_MISSING=MAKE_MISSING)
    NEW.VAR = VAR.Y
    INTERP_DATA = VAR.Y
    IF KEYWORD_SET(INTERP_SPAN_WINDOW) THEN BEGIN
      TS_INTERP_BLANK, JD=DATE_2JD(NEW[OK].DATE),INTERP_DATA=INTERP_DATA, INTERP_JD=DATE_2JD(NEW.DATE), SPAN=INTERP_SPAN_WINDOW, MISS=MISSINGS(NEW.VAR)
      NEW.VAR = INTERP_DATA
    ENDIF ; INTERP_SPAN_WINDOW
  ENDIF ; INTERPOLATE
; ===> Replicate the structure with multiple "depths"
  NEW2 = NEW
  NEW2.DEPTH = 0.5
  NEW3 = NEW
  NEW3.DEPTH = 1
  NEW = STRUCT_CONCAT(NEW,NEW2)
  NEW = STRUCT_CONCAT(NEW,NEW3)
  
  F = NEW.VAR
  Y = NEW.DEPTH
  X = DATE_2JD(NEW.DATE)-DATE_2JD(MIN(DTR))
    
  IF N_ELEMENTS(DIMENSIONS) NE 2 THEN DIMENSIONS = [N_ELEMENTS(CR),3]
  
  TRIANGULATE,X,Y,TRIANGLES
  GRID = GRIDDATA(X,Y,F,/NATURAL_NEIGHBOR,TRIANGLES=TRIANGLES,DIMENSION=DIMENSIONS,MISSING=MISSINGS(F))

  DATERANGE=DTR
  RETURN, GRID
  


END ; ***************** End of GRIDDED_TIMESERIES_INTERPOLATION *****************
