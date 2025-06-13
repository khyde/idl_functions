; $ID:	TIME_DEPTH_INTERPOLATION.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION TIME_DEPTH_INTERPOLATION, DATE_ARRAY, DEPTH_ARRAY, ARRAY, $
                       DATERANGE=DATERANGE, DEPTH_RANGE=DEPTH_RANGE, DEPTH_INTERVAL=DEPTH_INTERVAL, DEPTH_CUTOFF=DEPTH_CUTOFF, $
                       NEAR=NEAR, INTERPOLATE=INTERPOLATE, MAKE_MISSING=MAKE_MISSING, DIMENSIONS=DIMENSIONS
                       
;+
; NAME:
;   TIME_DEPTH_INTERPOLATION
;
; PURPOSE:
;   Function to create a "grid" of profile data over time
;   
; CATEGORY:
;   GRAPHICS_FUNCTIONS
;
; CALLING SEQUENCE:
;   TIME_DEPTH_INTERPOLATION, DATE_ARRAY, DEPTH_ARRAY, ARRAY
;
; REQUIRED INPUTS:
;   DATE_ARRAY...... The date array (yyyymmdd or yyyymmddhhmmss)
;   DEPTH_ARRAY..... The depth array
;   ARRAY........... The data array
;   NEAR............ Input variable to WHERE_NEAREST for filling in the new structure
;
; OPTIONAL INPUTS:
;   DATERANGE....... Two element array of the minimum and maximum dates
;   DEPTH_RANGE..... The two element array of the minimum and maximum depths
;   DEPTH_INTERVAL.. The depth interval to fill in the missing data with (0.5 meters, 2 meters, etc.)
;   DEPTH_CUTOFF.... To "cutoff" the top and bottom depths
;   NEAR............ Input variable to WHERE_NEAREST for finding the actual depth closest to the interpolated depth array
;   DIMENSIONS...... Input variable to GRIDDATA
;
; KEYWORD PARAMETERS:
;   INTERPOLATE..... To interpolate values within the profile
;   MAKE_MISSINGS... Keyword input into INTERP_XTEND
; 
; OUTPUTS:
;   A gridded time depth array
;
; OPTIONAL OUTPUTS:
;   DATERANGE....... If not provided, it will be based on the min and max date array
;   DEPTH_RANGE..... If not provided, it will be based on the min and max depth array
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
;   This is designed for profile data collected over time.  
;     * First the individual profile data are interpolated throughout the water column
;     * Then the profile data are "gridded" over time using TRIANGULATE and GRIDDATA
;   The output can then be plotted using TIME_DEPTH_PLOT
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
;   Jan 03, 2022 - KJWH: Initial code written - adapted from TIME_DEPTH_GRID_NG
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'TIME_DEPTH_INTERPOLATION'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DATE_ARRAY) NE N_ELEMENTS(DEPTH_ARRAY) OR N_ELEMENTS(DATE_ARRAY) NE N_ELEMENTS(ARRAY) THEN MESSAGE, 'ERROR: DATE, DEPTH and DATA arrays must be equal'
  IF ~N_ELEMENTS(INTERPOLATE) THEN INTERPOLATE = 1 ; Default is to interpolate the data
  
; ===> Set up DATE data
  DT = DATE_ARRAY
  SETS = WHERE_SETS(DT)
  IF N_ELEMENTS(DATERANGE) NE 2 THEN DTR = [MIN(DT),MAX(DT)]
  CR = CREATE_DATE(DTR[0],DTR[1])
  
; ===> Set up DEPTH data  
  DP = FLOAT(DEPTH_ARRAY)
  IF N_ELEMENTS(DEPTH_RANGE) NE 2 THEN DPR = [MIN(DP), MAX(DP)] ELSE DPR = DEPTH_RANGE
  IF N_ELEMENTS(DEPTH_INTERVAL) NE 1 THEN BEGIN
    MAXNUM = MAX(SETS.N)
    SUBSETS = SETS[WHERE(SETS.N EQ MAX(SETS.N))]
    DEPTH_SPAN = 0
    FOR S=0, N_ELEMENTS(SUBSETS)-1 DO DEPTH_SPAN = DEPTH_SPAN > ROUND(SPAN(DP[WHERE_SETS_SUBS(SUBSETS[S])]))   
    N_INTERVALS = DEPTH_SPAN/MAXNUM*10
    DEPTH_INTERVAL = MAX(NICE_RANGE(SPAN(DPR)/N_INTERVALS))
    IF N_ELEMENTS(NEAR) NE 1 THEN NEAR = MIN(NICE_RANGE(SPAN(DPR)/N_INTERVALS))
  ENDIF
  IF DPR[0] NE 0 THEN DPR[0] = 0
  
  DEPTHS =INTERVAL(DPR,DEPTH_INTERVAL)
  DEPTHS = DEPTHS[WHERE(DEPTHS LE DPR[1] AND DEPTHS GE ABS(DPR[0]),/NULL)]
  ND = N_ELEMENTS(DEPTHS)
  
; ===> Set up variable (i.e. product) information
  ARR = ARRAY
 
; ===> Create new structure with the date, depth and interpolated variable data  
  NSETS = N_ELEMENTS(SETS)
  IF DTR[0] NE SETS[0].VALUE THEN NSETS = NSETS + 1
  IF DTR[1] NE SETS[-1].VALUE THEN NSETS = NSETS + 1
  NEW = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('DATE','','DEPTH',0.0,'VAR',0.0)),ND*NSETS)
  IF DTR[0] NE SETS[0].VALUE THEN BEGIN
    NEW[0:ND-1].DATE = REPLICATE(DTR[0],ND)
    NEW[0:ND-1].DEPTH = DEPTHS
    COUNTER = ND
  ENDIF ELSE COUNTER = 0  
  FOR NTH=0, N_ELEMENTS(SETS)-1 DO BEGIN  ; Loop through the sets (i.e. profiles) and fill in the data in the structure
    SUBS=WHERE_SETS_SUBS(SETS[NTH])
    SETVAR = ARR[SUBS]
    SETDEPTH = DP[SUBS]
    S = COUNTER
    E = S+ND-1
    NEW[S:E].DATE  = SETS[NTH].VALUE
    NEW[S:E].DEPTH = DEPTHS
    NVAR = DEPTHS
    NARRAY = DEPTHS
    NVALUE = SETDEPTH
    IF N_ELEMENTS(NEAR) NE 1 THEN MESSAGE, 'ERROR: No NEAR input for WHERE_NEAREST'
    OK = WHERE_NEAREST(NARRAY,NVALUE,COUNT,VALID=VALID,NEAR=NEAR,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID)
    IF COUNT GE 1 THEN BEGIN
      NVAR[OK] = SETVAR[VALID]
      IF NCOMPLEMENT GE 1 THEN NVAR[COMPLEMENT] = MISSINGS(0.0)
      IF KEYWORD_SET(INTERPOLATE) AND N_ELEMENTS(SETVAR) GE 2 THEN BEGIN
        NVAR = INTERP_XTEND(SETDEPTH,SETVAR,DEPTHS,MAKE_MISSING=MAKE_MISSING)
        NEW[S:E].VAR = NVAR.Y
      ENDIF
    ENDIF ELSE NEW[S:E].VAR = MISSINGS(0.0)
    COUNTER = COUNTER+ND
  ENDFOR
  IF DTR[1] NE SETS[-1].VALUE THEN BEGIN
    NEW[COUNTER:N_ELEMENTS(NEW)-1].DATE = REPLICATE(MAX(DTR),ND)
    NEW[COUNTER:N_ELEMENTS(NEW)-1].DEPTH = DEPTHS
  ENDIF
  
  F = NEW.VAR
  Y = -NEW.DEPTH
  X = DATE_2JD(NEW.DATE)-DATE_2JD(MIN(DTR))
  IF N_ELEMENTS(DEPTH_CUTOFF) EQ 2 THEN BEGIN
    OK = WHERE(Y LT -DEPTH_CUTOFF[0] OR Y GT -DEPTH_CUTOFF[1], COUNT)
    IF COUNT GE 1 THEN F[OK] = MISSINGS(F)
  ENDIF
  
  IF N_ELEMENTS(DIMENSIONS) NE 2 THEN DIMENSIONS = [N_ELEMENTS(CR),ND]
  
  TRIANGULATE,X,Y,TRIANGLES
  GRID = GRIDDATA(X,Y,F,/NATURAL_NEIGHBOR,TRIANGLES=TRIANGLES,DIMENSION=DIMENSIONS,MISSING=MISSINGS(ARR))

  DATERANGE=DTR
  DEPTH_RANGE=DPR
  RETURN, GRID
  


END ; ***************** End of TIME_DEPTH_INTERPOLATION *****************
