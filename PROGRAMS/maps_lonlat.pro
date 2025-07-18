; $ID:	MAPS_LONLAT.PRO,	2020-07-08-15,	USER-KJWH	$
;#########################################################################################
  FUNCTION MAPS_LONLAT,ARRAY,LON=LON,LAT=LAT,MAP_OUT=MAP_OUT,METHOD=METHOD,INIT=INIT,SUBS=SUBS
;+
; NAME: MAPS_LONLAT
;
; PURPOSE:
;    WARP AN ARRAY WITH LON-LAT CONTROL POINTS [E.G.MUR-SST] 
;    TO ANY STANDARD MAP_OUT PROJECTION IN THE MAPS MASTER [E.G.NEC]
;
; CATEGORY:
;       MAPS FAMILY
;
; CALLING SEQUENCE:
;       NEC = MAPS_LONLAT(ARRAY,LON=LON,LAT=LAT,MAP_OUT = 'NEC')
;
; INPUTS:
;       ARRAY A 2-D IMAGE ARRAY WITH COMPANION LON,LAT CONTROL POINTS [REQUIRED]
;
; KEYWORD PARAMETERS:
;                LON...... LONGITUDE CONTROL POINTS FOR THE ARRAY [REQUIRED]
;                LAT...... LATITUDE CONTROL POINTS  FOR THE ARRAY [REQUIRED]
;                MAP_OUT.. NAME OF OUTPUT MAP [E.G. NEC] [REQUIRED] 
;                METHOD... 'POLY'[POLYWARP] OR 'TRI' [WARP_TRI] OR 'GRID' [GRIDDATA]
;                INIT..... INITIALIZE[REFRESH] MEMORY [ARRAY_] 
;                SUBS..... SUBSCRIPTS IN OUTPUT HAVING INFORMATION   
;       
; OUTPUTS: A 2-D ARRAY WARPED TO MAP_OUT
; 
;          
; EXAMPLES:   
;      NEC =  MAPS_LONLAT(MUR_SST,MAP_OUT='NEC') & IMGR,NEC,PROD = 'SST',MAP = 'NEC',PNGFILE = !S.IDL_TEMP + 'MUR2NEC.PNG'

; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, AUG 30,2015 PATTERNED AFTER NECW_2NEC_COEF AND NECW_2NEC [COASTWATCH MAPS]
;       AUG 31, 2015 - JOR:  REFINMENTS
;       SEP 01, 2015 - KJWH: IF !S.OS EQ 'UNIX' THEN SET_PLOT,'X' ELSE SET_PLOT,STRMID(!S.OS,0,3)
;       SEP 04, 2015 - JOR:  RENAMED FROM MUR_2NEC, MADE MORE GENERIC WITH MAP_OUT KEYWORD
;       SEP 06, 2015 - JOR:  STREAMLINED 
;       SEP 10, 2015 - JOR:  RENAMED VARIABLES [X_MAP,Y_MAP,X_ARR,Y_ARR] FOR LEGIBILITY
;       SEP 11, 2015 - KJWH: ADDED A BUFFER OF 2 DEGREES AROUND THE SUBSET AREA
;                            ADDED LOGIC TO DETERMINE IF THE LON/LAT CORDINATES ARE 1D OR 2D
;       SEP 13, 2015 - JOR:  REARRANGED CODE IN PROPER SEQUENCE 
;                            ADDED  IS_1D LOGICAL FUNCTION
;                            ADDED ARRAY_ TO COMMON  TO SPEED UP TESTING
;                            THE EXTRACTED ARR MUST HAVE AN ASPECT RATIO OF 2:1 [PX MUST BE 2X PY
;                            FOR ARR TO CONFORM TO THE EXPECTIONS OF A CYLINDRICAL MAP [I.E. GEQ = 4096:2048]      
;       SEP 14, 2015 - JOR:  ADJUSTED LONMIN & LONMAX TO GET A 2X:1Y RATIO FOR THE EXTRACTED ARR
;       SEP 15, 2015 - JOR:  ADDED KEY INIT
;       SEP 16, 2015 - KWJH: ADDED ERROR MESSAGES FOR 2D LON/LAT INPUTS AND IF THE INPUT RESOLUTION IS LOWER THAN THE OUTPUT
;       SEP 16, 2015, - JOR: ADDED METHOD 'GRID'
;       SEP 17, 2015, - JOR: METHOD = "NearestNeighbor" FOR GRID
;       SEP 19, 2015, - JOR: ;===> ENSURE THAT IMAGEW IS CORRECT SIZE FOR EXTRACTION [USING CONGRID]
;                            IF LONMAX LT 180 THEN BEGIN
;                            ADDED CASE BLOCKS FOR EACH METHOD
;       SEP 23, 2015  - JOR: ADDED SUBSETTING IN GRID METHOD SECTION:
                             ;===> SUBSET X AND Y TO VALUES WITHIN 0 AND PX_OUT-1, PY_OUT-1
;       SEP 24, 2015  - JOR: ADDED LL_GRACE FOR THE GRID METHOD SECTION:
;                            OK = WHERE(X GE (0-LL_GRACE) AND X LE (PX_OUT+ LL_GRACE) AND Y GE (0-LL_GRACE) AND Y LE (PY_OUT+LL_GRACE),COUNT)
;       SEP 26, 2015, - JOR: SAVE STRUCTURE FOR KEY INFO IN GRID METHOD
;       NOV 24, 2015  - JOR: ADDED KEY SUBS,SUBS = WHERE(FINITE(G),COUNT)

;       


;################################################################################################
;-
;***************************
ROUTINE_NAME = 'MAPS_LONLAT'
;***************************
COMMON  MAPS_LONLAT_,ARRAY_
IF KEY(INIT) THEN GONE,ARRAY_
;
;===> DEFAULTS
IF MAP_OUT EQ 'GEQ' THEN DDEG = 1 ELSE DDEG = 1.0/6.0
POLY_DEGREE = 5
IF !S.OS EQ 'UNIX' THEN SET_PLOT,'X' ELSE SET_PLOT,STRMID(!S.OS,0,3)
OLD_DEVICE = !D.NAME
IF NONE(XY_FACTOR) THEN XY_FACTOR = 2
IF NONE(METHOD) THEN METHOD = 'POLY'
LL_GRACE = 16 ; ABOUT 20 KM EXTRA FOR NEC
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;===> CHECK INPUTS
IF NONE(ARRAY_)               THEN ARRAY_ = TEMPORARY(ARRAY)
IF NONE(ARRAY_)               THEN MESSAGE,'ERROR: ARRAY IS REQUIRED'
IF NONE(LON) OR NONE(LAT)     THEN MESSAGE,'ERROR: LON & LAT ARE REQUIRED'
IF NONE(MAP_OUT)              THEN MESSAGE,'ERROR: MAP_OUT IS REQUIRED'
IF SIZE(LON, /N_DIMENSIONS) NE SIZE(LAT, /N_DIMENSIONS) THEN STOP ; BOTH LON/LAT ARRAYS MUST HAVE THE SAME NUMBER OF DIMENSIONS


M = MAPS_READ(MAP_OUT)
LATMIN = FLOAT(M.LATMIN)
LATMAX = FLOAT(M.LATMAX)
LONMIN = FLOAT(M.LONMIN)
LONMAX = FLOAT(M.LONMAX)

PX_OUT = ULONG(M.PX)
PY_OUT = ULONG(M.PY)

;##########################  
CASE (STRUPCASE(METHOD)) OF
;##########################  
'POLY': BEGIN
 
;######################################################################
;ADJUST LONMIN & LONMAX SO THE EXTRACTED ARR WILL HAVE A RATIO OF 2X/1Y
IF LONMAX LT 180 THEN BEGIN
  X=SPAN([LONMIN,LONMAX])
  Y=SPAN([LATMIN,LATMAX])
  Y2 = XY_FACTOR*Y
  DIF = Y2-X
  LONMIN = LONMIN - DIF
  LONMAX = LONMAX + DIF
ENDIF;IF LONMAX LT 180 THEN BEGIN


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||





;##############################################################
;===> ESTABLISH THE MAP_OUT PROJECTION IN THE Z GRAPHICS DEVICE
MAPS_SET,MAP_OUT,PX = PX_OUT,PY = PY_OUT
ERASE,255
;===> PLOT A GRATICULE
PLOTGRAT,DDEG,COLOR = 1,PSYM = 3
MAP_IMG = TVRD()

;===> GET THE DEVICE COORDINATES FOR ALL THE GRATICULE POINTS FROM MAP_IMG
OK = WHERE(MAP_IMG EQ 1,COUNT)

;===> CONVERT OK INDICES TO X_MAP & Y_MAP COORDS
XY = ARRAY_INDICES([PX_OUT,PY_OUT],OK,/DIMENSIONS)
X_MAP=REFORM(XY(0,*))
Y_MAP=REFORM(XY(1,*))

;===> GET THE CORRESPONDING LONS AND LATS FOR X_MAP AND Y_MAP
XYZ = CONVERT_COORD(X_MAP,Y_MAP,/DEVICE,/TO_DATA)
LONS_MAP = REFORM(XYZ(0,*))
LATS_MAP = REFORM(XYZ(1,*))
ZWIN;===> CLOSE THE Z DEVICE AND FREE UP ITS MEMORY
;||||||||||||||||||||||||||||||||||||||||||||||||||

;#########################################################################################
;===> FIND THE LONS & LATS FOR THE SUBSET OF THE ARRAY THAT ARE WITHIN THE MAP_OUT DOMAIN
;===> FOR 1D LON/LAT CONTROL POINTS
IF IS_1D(LON) AND IS_1D(LAT) THEN BEGIN 
  OK_LON = WHERE(LON GE LONMIN AND LON LE LONMAX,PX_ARR)
  OK_LAT = WHERE(LAT GE LATMIN AND LAT LE LATMAX,PY_ARR)
ENDIF ELSE BEGIN
  MESSAGE, 'ERROR: LON AND LATS ARE 2D ===> WE NEED A METHOD TO WORK WITH 2D LON/LAT INPUTS ===>'
ENDELSE ; IF IS_1D(LON) AND IS_1D(LAT) THEN BEGIN

IF PX_ARR EQ 0 OR PY_ARR EQ 0 THEN MESSAGE,'ERROR: NO LON OR LAT WITHIN THE MAP_OUT DOMAIN'
 
;===> FOR 2D LON/LAT CONTROL POINTS  
IF IS_2D(LON) AND IS_2D(LAT) THEN BEGIN 
;  OK_WITHIN_MAP_OUT = WHERE(LON GE LONMIN AND LON LE LONMAX AND LAT GE LATMIN AND LAT LE LATMAX,COUNT,NCOMPLEMENT=N_OUTSIDE_MAP_OUT,COMPLEMENT=OUTSIDE_MAP_OUT)
;  ARR = ARRAY(OK_WITHIN_MAP_OUT)
  STOP ; CURRENTLY DOES NOT WORK WITH 2D LON/LAT ARRAYS.
ENDIF;IF IS_1D(LON) AND IS_1D(LAT) THEN BEGIN

;===> EXTRACT THE ARR FROM _ARRAY
 ARR = TEMPORARY(ARRAY_(FIRST(OK_LON):LAST(OK_LON),FIRST(OK_LAT):LAST(OK_LAT)))

;===> GET THE LIMITS & PO_LAT & PO_LON FOR THE ARR
;     EXTRACTED FROM THE INPUT ARRAY
M_LIMIT = [LAT(FIRST(OK_LAT)),LON(FIRST(OK_LON)),LAT(LAST(OK_LAT)),LON(LAST(OK_LON))]
P0_LAT= MEAN([LAT(FIRST(OK_LAT)),LAT(LAST(OK_LAT))])
P0_LON= MEAN([LON(FIRST(OK_LON)),LON(LAST(OK_LON))])

; ===> ESTABLISH THE MAP PROJECTION FOR THE ARR SUBSET
SET_PLOT,'Z'
DEVICE,SET_RESOLUTION=[PX_ARR,PY_ARR]
MAP_SET,P0_LAT,P0_LON,0.0,/CYLINDRICAL,LIMIT = M_LIMIT,POSITION=[0.0, 0.0, 1.0, 1.0],/NOBORDER
ERASE,255
;===> PLOT THE LONS_MAP AND LATS_MAP COORDS 
PLOTS,LONS_MAP,LATS_MAP,PSYM = 3,COLOR = 1,/DATA
ARR_IMG = TVRD()
OK = WHERE(ARR_IMG EQ 1,COUNT)
IF COUNT EQ 0 THEN STOP
XY = ARRAY_INDICES([PX_ARR,PY_ARR],OK,/DIMENSIONS)
X_ARR=REFORM(XY(0,*))
Y_ARR=REFORM(XY(1,*))
;===> CLOSE THE Z DEVICE AND FREE UP ITS MEMORY
DEVICE,/CLOSE
SET_PLOT, OLD_DEVICE

;IF NUMBERS DO NOT AGREE THEN REPLOT FINITE LONS_MAP,LATS_MAP IN MAP_OUT DOMAIN TO GET BALANCED NUMBERS OF POINTS
;###################################################################################################
IF NOF(X_ARR) NE NOF(X_MAP) OR NOF(Y_ARR) NE NOF(Y_MAP) THEN BEGIN
  OK = WHERE(FINITE(LONS_MAP) EQ 1,COUNT)
  
  MAPS_SET,MAP_OUT,PX = PX_OUT,PY = PY_OUT
  ERASE,255
  ;===> PLOT 
  PLOTS,LONS_MAP[OK],LATS_MAP[OK],PSYM = 3,COLOR = 1,/DATA
  MAP_IMG = TVRD()

  ;===> GET THE DEVICE COORDINATES FOR ALL THE GRATICULE POINTS FROM MAP_IMG
  OK = WHERE(MAP_IMG EQ 1,COUNT)

  ;===> CONVERT OK INDICES TO X_MAP & Y_MAP COORDS
  XY = ARRAY_INDICES([PX_OUT,PY_OUT],OK,/DIMENSIONS)
  X_MAP=REFORM(XY(0,*))
  Y_MAP=REFORM(XY(1,*))
  ZWIN
ENDIF;IF NOF(X_ARR) NE NOF(X_MAP) OR NOF(Y_ARR) NE NOF(Y_MAP) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



;===> GET THE WARPING TRANSFORMATION COEFFICIENTS KX, AND KY
POLYWARP, X_ARR,Y_ARR,X_MAP,Y_MAP, POLY_DEGREE, KX, KY ,/DOUBLE

;===> WARP THE IMAGE TO THE MAP_OUT PROJECTION
IMAGEW = POLY_2D(ARR, KX,KY,MISSING=MISSINGS(ARR[0]),PIXEL_CENTER=0.5) ; NEAREST NEIGHBOR
;===> EXTRACT FROM THE MAP_OUT REGION FROM THE IMAGEW
;===> ENSURE THAT IMAGEW IS CORRECT SIZE FOR EXTRACTION
SZ = SIZE(IMAGEW,/DIMENSIONS)
IF SZ[0] LT PX_OUT OR SZ[1] LT PY_OUT THEN BEGIN
  IMAGEW = CONGRID(IMAGEW,PX_OUT,PY_OUT,/MINUS_ONE)
ENDIF;IF SZ(0) LT PX_OUT OR SZ(1) LT PY_OUT THEN BEGIN

;===> RETURN THE WARPED ARR
RETURN, IMAGEW(0:PX_OUT-1,0:PY_OUT-1)


END;'POLY'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;####################################################################################  
 'TRI': BEGIN

  RETURN, WARP_TRI( X_MAP, Y_MAP, X_ARR, Y_ARR, ARR , OUTPUT_SIZE=[PX_OUT,PY_OUT],/QUINTIC )
  END;'TRI'
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

 'GRID': BEGIN
;####################################################################################  
  XOUT = INTERVAL([0,PX_OUT-1])
  YOUT = INTERVAL([0,PY_OUT-1])
  MAPS_SET,MAP_OUT,PX = PX_OUT,PY = PY_OUT
  ;===> GET THE CORRESPONDING X AND Y FROM LON AND LAT
  XYZ = CONVERT_COORD(LON,LAT,/DATA,/TO_DEVICE)
  X = REFORM(XYZ(0,*))
  Y = REFORM(XYZ(1,*))
  ZWIN;===> CLOSE THE Z DEVICE AND FREE UP ITS MEMORY
  
  MISSING=MISSINGS(ARRAY_)
  
  ;===> SUBSET X AND Y TO VALUES WITHIN 0 AND PX_OUT-1, PY_OUT-1
  OK = WHERE(X GE (0-LL_GRACE) AND X LE (PX_OUT+ LL_GRACE) AND Y GE (0-LL_GRACE) AND Y LE (PY_OUT+LL_GRACE),COUNT)
  IF COUNT GE 1 THEN BEGIN
    X = X[OK]
    Y = Y[OK] 
    ARRAY_= ARRAY_(OK)  
  ENDIF;IF COUNT GE 1 THEN BEGIN
  ;|||||||||||||||||||||||||||||

  TRIANGULATE, X, Y,TRIANGLES,CONNECTIVITY = C
  G = GRIDDATA( X,Y,ARRAY_,METHOD = "NearestNeighbor",$
    TRIANGLES=TRIANGLES,/GRID,XOUT=XOUT,YOUT=YOUT, MISSING = MISSINGS(ARRAY_))
  ;===> FIND SUBSCRIPTS FOR GOOD DATA IN G
  SUBS = WHERE(FINITE(G),COUNT)
  RETURN,G
  END;'GRID'
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\|
ELSE: BEGIN
  MESSAGE,'ERROR: METHOD ' + METHOD + ' IS NOT SUPPORTED'
END
ENDCASE;CASE (STRUPCASE(METHOD)) OF
;##################################  




END; #####################  END OF ROUTINE ################################
