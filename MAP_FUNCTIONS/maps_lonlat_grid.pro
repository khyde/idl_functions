; $ID:	MAPS_LONLAT_GRID.PRO,	2023-09-21-13,	USER-KJWH	$
;#########################################################################################
FUNCTION MAPS_LONLAT_GRID, ARRAY,LON=LON,LAT=LAT,MAP_OUT=MAP_OUT,METHOD=METHOD,$
                           LL_GRACE=LL_GRACE,TRIANGLES=TRIANGLES,INIT=INIT,SUBS=SUBS,STRUCT=STRUCT,$
                           DO_MASK=DO_MASK
;+
; NAME: 
;   MAPS_LONLAT_GRID
;
; PURPOSE:
;    Warp an array with lon-lat control points [e.g. l2 seadas created files] to any standard map_out projection in the maps master [e.g.nec]
;
; CATEGORY:
;   MAP FUNCTIONS
;
; CALLING SEQUENCE:
;   RESULT = MAPS_LONLAT_GRID(ARRAY,LON=LON,LAT=LAT,MAP_OUT='NEC',SUBS=SUBS)  
;
; REQUIRED INPUTS:
;   ARRAY........ A 2-D image array with companion longitude and latitude control points 
;   LON.......... Longitude control points for the array
;   LAT.......... Latitude control points  for the array
;   MAP_OUT...... Name of output map [e.g. NEC] 
;
; KEYWORD PARAMETERS:
;   METHOD...... Method used for gridding [see GRIDDATA], DEFAULT = "NearestNeighbor"
;   LL_GRACE.... Extra space outside lon lat domain DEFAULT = 16 [about 20 km extra for NEC]
;   INIT........ Initialize (refresh) memory [array_] 
;   SUBS........ Subscripts for good data
;   STRUCT...... Structure with triangles, mask, x, y etc. [output or input]
;   DO_MASK..... Apply the mask from triangles to the output from GRIDDATA 
;                   
; OUTPUTS: 
;   A 2-D array gridded to map_out using control lons & lats
;
; OPTIONAL OUTPUTS:
;      
; COMMON BLOCKS:
;      
; SIDE EFFECTS:
;   
; RESTRICTIONS:
;   
; EXAMPLE:  
;   NEC = MAPS_LONLAT(MUR_SST,MAP_OUT='NEC') & IMGR,NEC,PROD = 'SST',MAP = 'NEC',PNGFILE = !S.IDL_TEMP + 'MUR2NEC.PNG'
; 
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 30, 2015 by John E, O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquiries should be sent to kimberly.hyde@noaa.gov
;     
; MODIFICATION HISTORY:
;          
; EXAMPLES:   
;  
;
; MODIFICATION HISTORY:
;   AUG 30, 2015 - JEOR: Initial code adapted from NECW_2NEC_COEF and NECW_2NEC [COASTWATCH MAPS]
;   AUG 31, 2015 - JEOR: Refinments
;   SEP 01, 2015 - KJWH: Added IF !S.OS EQ 'UNIX' THEN SET_PLOT,'X' ELSE SET_PLOT,STRMID(!S.OS,0,3)
;   SEP 04, 2015 - JEOR: Renamed from MUR_2NEC, made more generic with map_out keyword
;   SEP 06, 2015 - JEOR: Streamlined 
;   SEP 10, 2015 - JEOR: Renamed variables [X_MAP,Y_MAP,X_ARR,Y_ARR] for legibility
;   SEP 11, 2015 - KJWH: Added a buffer of 2 degrees around the subset area
;                        Added logic to determine if the lon/lat cordinates are 1d or 2d
;   SEP 13, 2015 - JEOR: Rearranged code in proper sequence 
;                        Added  is_1d logical function
;                        Added array_ to COMMON BLOCK  to speed up testing
;                        The extracted arr must have an aspect ratio of 2:1 [PX must be 2X PY]
;                        for arr to conform to the expections of a cylindrical map [I.E. GEQ = 4096:2048]      
;   SEP 14, 2015 - JEOR: Adjusted LONMIN & LONMAX to get a 2x:1y ratio for the extracted arr
;   SEP 15, 2015 - JEOR: Added keyword INIT
;   SEP 16, 2015 - KWJH: Added error messages for 2d lon/lat inputs and if the input resolution is lower than the output
;   SEP 16, 2015 - JEOR: Added method 'GRID'
;   SEP 17, 2015 - JEOR: METHOD = "NearestNeighbor" FOR GRID
;   SEP 19, 2015 - JEOR: Ensure that imagew is correct size for extraction [using CONGRID]
;                        Added IF LONMAX LT 180 THEN BEGIN
;                        Added CASE BLOCKS for each method
;   SEP 23, 2015 - JEOR: Added subsetting in grid method section:
;                          SUBSET X AND Y TO VALUES WITHIN 0 AND PX_OUT-1, PY_OUT-1
;   SEP 24, 2015 - JEOR: Added LL_GRACE for the grid method section:
;                          SUBS_WITHIN_MAP = WHERE(X GE (0-LL_GRACE) AND X LE (PX_OUT+ LL_GRACE) AND Y GE (0-LL_GRACE) AND Y LE (PY_OUT+LL_GRACE),COUNT)
;   SEP 26, 2015 - JEOR: Save structure for key info in grid method
;   SEP 29, 2015 - JEOR: Added keywords NAME, DIR_SAV
;   OCT 27, 2015 - KJWH: Removed DIR_SAV - This program should only do the remapping and the wrapper program will save the new info 
;                        Removed all but the "GRID" method steps (and method keyword)
;                        Renamed maps_lonlat_grid so that the procedures for the other methods can be preserved in MAPS_LONLAT
;                        Added X, Y AND TRIANGLES keywords - if provided, then don't need to be recreated for GRIDDATA
;   NOV 07, 2015 - JEOR: Changed COMMON MAPS_LONLAT to MAPS_LONLAT_GRID_
;   NOV 24, 2015 - JEOR: ADDED KEY SUBS
;   NOV 29, 2015 - JEOR: IF IS_1D(LON) AND IS_1D(LAT) AND NOF(LON) NE NOF(LAT) THEN BEGIN
;   DEC 02, 2015 - JEOR: Added keyword METHOD, B TO TRIANGULATE
;                        Added POLYFILL, X(B), Y(B), COLOR = 1 to get subs
;   DEC 03, 2015 - JEOR: Added SUBS = WHERE(FINITE(G) AND IMG EQ 1,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
;   DEC 06, 2015 - JEOR: Added keyword LL_GRACE
;   FEB 04, 2016 - JEOR: Added keyword STRUCT
;                        Changed TOLERANCE = SMALLNUM(0.D)[ SMALLEST NUMBER/PRECISION POSSIBLE]
;   FEB 05, 2016 - JEOR: Added IF NONE(ARRAY_) THEN ARRAY_ = ARRAY
;   MAR 17, 2016 - KJWH: Formatting 
;                        Added check to make sure the MAP_OUT in the structure matches the MAP_OUT keyword
;                        Removed "COMMON  MAPS_LONLAT_GRID_,ARRAY_" because you do not want to reuse the array
;   MAR 21, 2016 - KJWH: Added ERROR if there are less than 10 valid pixels found within the map boundaries    
;   MAR 28, 2016 - KJWH: Commented out all of the references to the "mask" because it was mapping out good data within the map                 
;   APR 06, 2016 - JEOR: Added keyword DO_MASK and IF KEY(DO_MASK) THEN BEGIN
;   NOV 06, 2020 - KJWH: Updated documentation
;                        Changed subscript () to []
;                        Added COMPILE_OPT IDL2
;
;-
; *********************************************************************************************************************
  ROUTINE_NAME = 'MAPS_LONLAT_GRID'
  COMPILE_OPT IDL2

  IF KEY(INIT) THEN GONE, STRUCT

; ===> DEFAULTS
  IF NONE(LL_GRACE) THEN  LL_GRACE = 16 
  IF NONE(METHOD)   THEN METHOD = "NearestNeighbor"

; ===> CHECK INPUTS
  IF NONE(ARRAY) THEN MESSAGE,'ERROR: ARRAY IS REQUIRED' ELSE ARRAY_ = ARRAY        ; To conserve the original array 
  IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN IF STRUCT.MAP_OUT EQ MAP_OUT THEN GOTO, HAVE_STRUCT   
  IF NONE(LON) OR NONE(LAT)      THEN MESSAGE,'ERROR: LON & LAT are required'
  IF NONE(MAP_OUT)               THEN MESSAGE,'ERROR: MAP_OUT is required'
  IF SIZE(LON, /N_DIMENSIONS) NE SIZE(LAT, /N_DIMENSIONS) THEN MESSAGE, 'ERROR: Both LON & LAT arrays must have the same number of dimensions'
 
  M = MAPS_READ(MAP_OUT) & PX_OUT = ULONG(M.PX) & PY_OUT = ULONG(M.PY)
  XOUT = INTERVAL([0,PX_OUT-1]) & YOUT = INTERVAL([0,PY_OUT-1])
    
  ZWIN, [PX_OUT, PY_OUT]
  MAPS_SET, MAP_OUT, PX=PX_OUT, PY=PY_OUT
      
; ===> ENSURE LON AND LAT ARE SAME SIZE BEFORE CONVERT_COORD
  IF IS_1D(LON) AND IS_1D(LAT) AND NOF(LON) NE NOF(LAT) THEN BEGIN
    D = ARR_XY(LON,LAT)
    LON = D.X
    LAT = D.Y  
    GONE, D      
  ENDIF;IF IS_1D(LON) AND IS_1D(LAT) AND NOF(LON) NE NOF(LAT) THEN BEGIN
    
; ===> GET THE CORRESPONDING X AND Y FROM LON AND LAT
  XYZ = CONVERT_COORD(LON,LAT,/DATA,/TO_DEVICE) 
  X = REFORM(XYZ[0,*])
  Y = REFORM(XYZ[1,*]) 
  ZWIN ;===> CLOSE THE Z DEVICE AND FREE UP ITS MEMORY
    
;===> SUBSET X AND Y TO VALUES WITHIN THE MAP_OUT AREA PLUS SOME ADDITIONAL BUFFER PIXELS AROUND THE EDGE (I.E. LL_GRACE)
  SUBS_WITHIN_MAP = WHERE(X GE (0-LL_GRACE) AND X LE (PX_OUT+ LL_GRACE) AND Y GE (0-LL_GRACE) AND Y LE (PY_OUT+LL_GRACE),COUNT) 
  IF COUNT GE 10 THEN BEGIN
    X = X[SUBS_WITHIN_MAP]
    Y = Y[SUBS_WITHIN_MAP] 
    ARRAY_= ARRAY_[SUBS_WITHIN_MAP]  
  ENDIF ELSE BEGIN
    STRUCT = 'ERROR: Less than 10 pixels found within the map boundaries'
    RETURN, STRUCT 
  ENDELSE
    
  TRIANGULATE, X, Y,TRIANGLES,B,TOLERANCE = SMALLNUM(0.D),CONNECTIVITY = C 
;  TRIANGULATE, X+RANDOMN(SEED,N_ELEMENTS(X))*0.0001, Y+RANDOMN(SEED,N_ELEMENTS(Y))*0.0001,TRIANGLES,B,TOLERANCE = SMALLNUM(0.D),CONNECTIVITY = C 
 
; ===> CREATE A MASK FROM B FOR DETERMINING THE AREA OF THE GOOD DATA
  IF KEY(DO_MASK) THEN BEGIN
    MASK = REPLICATE(255B,[PX_OUT,PY_OUT])
    ZWIN,MASK
    PLOT,[0,PX_OUT],[0,PY_OUT],/NODATA,XMARGIN= [0,0],YMARGIN = [0,0]
    TV,MASK
    POLYFILL, X[B], Y[B], COLOR = 1
    MASK = TVRD()
    ZWIN
  ENDIF;IF KEY(DO_MASK) THEN BEGIN

; ===> GRID THE DATA
  G = GRIDDATA(X, Y, ARRAY_, METHOD=METHOD, TRIANGLES=TRIANGLES, /GRID, XOUT=XOUT, YOUT=YOUT, MISSING = MISSINGS(ARRAY_))
  
; ===> GET SUBSCRIPTS FOR GOOD DATA  
  IF KEY(DO_MASK) THEN BEGIN
    SUBS = WHERE(FINITE(G) AND MASK EQ 1,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
  ENDIF ELSE BEGIN
    SUBS = WHERE(FINITE(G),COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)  
  ENDELSE;IF KEY(DO_MASK) THEN BEGIN


; ===> MAKE A STRUCTURE
  IF NONE(STRUCT) THEN STRUCT=CREATE_STRUCT('MAP_OUT',MAP_OUT,'PX_OUT',PX_OUT,'PY_OUT',PY_OUT,'METHOD',METHOD,$
    'TRIANGLES',TRIANGLES,'SUBS_WITHIN_MAP',SUBS_WITHIN_MAP,'NCOMPLEMENT',NCOMPLEMENT,$
    'COMPLEMENT',COMPLEMENT,'X',X,'Y',Y,'XOUT',XOUT,'YOUT',YOUT)
  
  GOTO, MASK_GRIDDED_DATA

; ===> START HERE IF ALREADY HAVE A STRUCTURE
  HAVE_STRUCT:
  IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN  BEGIN
    ARRAY_= ARRAY_[STRUCT.SUBS_WITHIN_MAP] 
    G = GRIDDATA(STRUCT.X, STRUCT.Y, ARRAY_, METHOD=STRUCT.METHOD, TRIANGLES=STRUCT.TRIANGLES, /GRID, XOUT=STRUCT.XOUT, YOUT=STRUCT.YOUT, MISSING = MISSINGS(ARRAY_))
  ENDIF;IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN  BEGIN

; ===> MASK OUT AREA OUTSIDE GOOD DATA  
  MASK_GRIDDED_DATA:
  IF STRUCT.NCOMPLEMENT GE 1 THEN G[STRUCT.COMPLEMENT] = MISSINGS(G) 
  RETURN,G
  
END; #####################  END OF ROUTINE ################################
