; $ID:	PLOTGRAT.PRO,	2016-02-22,	USER-JOR	$
;##################################################################################################
PRO PLOTGRAT,DEG, XDEG=XDEG,YDEG=YDEG,COLOR=COLOR,PSYM=PSYM,NOCLIP=NOCLIP,PLOT_LINE=PLOT_LINE,EXTEND=EXTEND,_EXTRA=_EXTRA
;+
; NAME:  PLOTGRAT
;
; PURPOSE:
;      PLOT A GRATICULE ON TOP OF A PREVIOUSLY ESTABLISHED
;      MAP PROJECTION
;
; CATEGORY:
;      MAPPING,PLOTTING
;
; CALLING SEQUENCE:
;       PLOTGRAT
;       PLOTGRAT, 0.5
;       PLOTGRAT, 0.25,COLOR=128,SYMSIZE=.5
;
; INPUTS:
;      DEG (DECIMAL DEGREES FOR GRATICULE).
;
; KEYWORD PARAMETERS:
;
;      NOCLIP: ALLOWS PLOTTING GRADICULE BEYOUND MAP LIMITS BUT
;              WITHIN GRAPHICS WINDOW (SETS NOCLIP TO 1 )
; OUTPUTS:
;      PLOT OF GRATICULE IN GRAPHICS WINDOW.

; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, MARCH 15, 1995.
;       JUNE 30, 1997 CHANGED CHECK ON !X.TYPE FROM 2 TO 3(IDL 5.0)
;       JUNE 30, 1997 DEG IS NOW A PARAMETER INSTEAD OF A KEYWORD
;       FEB   4,1998  GRATICULE IS PLOTTED IN INCREMENTS OF DEG
;                     (IF DEG = 5 THEN GRATICULE IS AT 5 DEGREE INCREMENTS CENTERED ON WHOLE DEGREES)
;       AUG 30,2015,JOR MAJOR REVISIONS [SIMPLIFIED,STREAMLINED]
;       FEB 22,2016,JOR RENAMED TAGS TO AGREE WITH MAPS STRUCTURE
;################################################################################################
;-
;************************
ROUTINE_NAME = 'PLOTGRAT'
;************************
;===>	DEFAULTS 
IF NONE(COLOR) THEN COLOR = 0
IF NONE(DEG)  THEN DEG = 1.0
IF NONE(XDEG) THEN XDEG = DEG
IF NONE(YDEG) THEN YDEG = DEG
IF NONE(NOCLIP) THEN NOCLIP = 0
IF NONE(PSYM) THEN PSYM = 3

; ===> CHECK THAT THE MAP TRANSFORM HAS BEEN ESTABLISHED.
  IF (!X.TYPE NE 3) THEN MESSAGE,'MAP TRANSFORM NOT ESTABLISHED.'

; ===> ESTABLISH LONGITUDE AND LATITUDE MIN,MAX
; IF XMARGIN OR YMARGIN IS PRESENT THEN !X.WINDOW AND !Y.WINDOW
; WILL BE >0 AND < 1.0 IN NORMAL UNITS
   IF KEYWORD_SET(EXTEND) EQ 0 THEN BEGIN
    X_MIN = !X.WINDOW[0]
    X_MAX = !X.WINDOW[1]
    Y_MIN = !Y.WINDOW[0]
    Y_MAX = !Y.WINDOW[1]
   ENDIF ELSE BEGIN
    X_MIN = !X.REGION[0]
    X_MAX = !X.REGION[1]
    Y_MIN = !Y.REGION[0]
    Y_MAX = !Y.REGION[1]
   ENDELSE

; ===> DETERMINE MINIMUM,MAXIMUM, LONGITUDES AND LATITUDES IN MAP AREA
M = MAPS_LL_BOX()
LATMIN = M.LATMIN
LONMIN = M.LONMIN
LATMAX = M.LATMAX
LONMAX = M.LONMAX
IF LONMIN LT 0 THEN LONMIN = FLOOR(LONMIN) - XDEG ELSE LONMIN = CEIL(LONMIN) - XDEG
IF LONMAX LT 0 THEN LONMAX = CEIL(LONMAX) + XDEG ELSE LONMAX = FLOOR(LONMAX) + XDEG
 
LATMIN = CEIL(LATMIN) - YDEG
LATMAX = FLOOR(LATMAX) + YDEG

	LL = LATLON_GEN(DEG=DEG,LON=[LONMIN,LONMAX],LAT=[LATMIN,LATMAX])
	
	IF KEYWORD_SET(PLOT_LINE) THEN BEGIN
		LONS = INTERVAL([LONMIN,LONMAX])
		LATS = INTERVAL([LATMIN,LATMAX])
		LON = LONMAX
		LAT = LATMAX
		WHILE LON GT LONMIN DO BEGIN
	    LON  = LON - XDEG
	    PLOTS, REPLICATE(LON,N_ELEMENTS(LATS)), LATS, LINESTYLE=0, THICK=2,COLOR=COLOR
	  ENDWHILE
	  WHILE LAT GT LATMIN DO BEGIN
	    LAT  = LAT - YDEG
	    PLOTS, LONS,REPLICATE(LAT,N_ELEMENTS(LONS)), LINESTYLE=0, THICK=2,COLOR=COLOR
	  ENDWHILE
  ENDIF ELSE PLOTS,LL.LON,LL.LAT,PSYM=PSYM,NOCLIP=NOCLIP,COLOR=COLOR


END; #####################  END OF ROUTINE ################################
