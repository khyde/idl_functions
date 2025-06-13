; $ID:	MAPS_COASTLINE.PRO,	2016-03-28,	USER-KJWH	$
PRO MAPS_COASTLINE, RESOLUTION, MINAREA=MINAREA, MIN_LAKEAREA=MIN_LAKEAREA, ANTARCTICA=ANTARCTICA,$
                    ADD_COAST=ADD_COAST, ADD_LAND=ADD_LAND, ADD_LAKES=ADD_LAKES, ADD_SMALL_LAKES=ADD_SMALL_LAKES, $
                    ADD_LAKE_SIDE=ADD_LAKE_SIDE, ADD_SMALL_LAKE_SIDE=ADD_SMALL_LAKE_SIDE, RIVERS=RIVERS, ISLANDS=ISLANDS,$
                    LAND_COLOR=LAND_COLOR, COAST_COLOR=COAST_COLOR, LAKE_COLOR=LAKE_COLOR, LAKESIDE_COLOR=LAKESIDE_COLOR, _EXTRA=_EXTRA

;+
; DESCRIPTION:
;    Plot coastlines from a GSHHS coastline files (v2.3.4).
;
;    The binary data files may be downloaded from http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
;    gshhs_f.b	Full resolution data
;    gshhs_h.b	High resolution data
;    gshhs_i.b	Intermediate resolution data
;    gshhs_l.b	Low resolution data
;    gshhs_c.b	Crude resolution data
;
;    NOTE: These are binary files in big-endian byte order.
;    Bytes will be flipped automatically if this program is run on a little-endian platform.
;
; USAGE:
;    MAPS_COASTLINE
;
; INPUT PARAMETERS:
;    None required
;    
; OUTPUT PARAMETERS:
;    None.
;
; OPTIONAL KEYWORDS:
;    RESOLUTION:         The resolution of the GSHHS file (FULL, HIGH, INTERMEDIATE, LOW, CRUDE)
;    MINAREA:            The minimum area of features to be plotted (sq. km; default = 500).
;    ADD_COAST:          Add coastline
;    ADD_LAND:           Add land
;    ADD_LAKES:          Include lakes
;    ADD_SMALL_LAKES:    Include smaller lakes
;    ADD_LAKESIDE:       Plot the lakeside of larger lakes
;    ADD_SMALL_LAKESIDE: Plot the lakeside of small lakes
;    RIVERS:             Plot large "river-lakes"
;    ISLANDS:            Include islands found in lakes
;    LAND_COLOR:         Color to fill in the land
;    COAST_COLOR:        Color to plot the coastline
;    LAKE_COLOR:         Color to fill in the lake
;    LAKESIDE_COLOR:     Color to plot the lakeside
;    _EXTRA:             Any keywords accepted by PLOTS or POLYFILL.
;
; NOTES:
;    GSHHS stands for the Global Self-consistent, Hierarchical, High-resolution Shoreline Database
;    and was assembled by Paul Wessel and Walter Smith.
;    For more information: http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
;    Currently using version 2.3.4 from January 1, 2015)
;
;    MAP_LEVELS: The level of geographical features of the gshhs polygons
;                  1 = land
;                  2 = lake
;                  3 = island in lake
;                  4 = pond in island in lake
;
;    Note, the authors of the GSHHS software *continually* change the header structure, which you MUST know 
;    to read the data file. There are are now at least four different structures in common use. Please find the one
;    you need from the commented list below. The current code uses the structure for the 2.0 version of the GSHHS software.
;
; MODIFICATION HISTORY:
;   This program was adapted from GSHHS_PLOT from Liam Gumley (Liam.Gumley@ssec.wisc.edu) and MAP_GSHHS_SHORELINE by David Fanning
;   
;   Liam E. Gumley - ftp://ftp.ssec.wisc.edu/pub/gumley/IDL/gshhs/
;   FANNING SOFTWARE CONSULTING
;      David Fanning, Ph.D.
;      1645 Sheely Drive
;      Fort Collins, CO 80526 USA
;      Phone: 970-221-0438
;      E-mail: david@idlcoyote.com
;      Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;   
;   Adapted by - K.J.W. Hyde 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Mar 23, 2016 - KJWH: Changed program name to MAPS_COASTLINE
;                          Added LANDMASK specific keywords and COLORS
;                          Included options to change the MINAREA based on the desire for SMALL_LAKES, RIVERS, etc.
;     Mar 24, 2016 - KJWH: Now writing out separate codes for SMALL_LAKES and SMALL_LAKESIDE   
;                          Added LG_LAKEAREA = 15000 to distinguish between large and small lake areas
;                          Added ANTARCTICA keyword and logic to plot either ICE front line or the GROUND line                  
;     Mar 28, 2016 - KJWH: Added [IF NONE(COAST_THICK_COLOR) THEN COAST_THICK_COLOR = 2] for consistency purposes with the other MAPS_LANDMASK programs.                     
;-

  ROUTINE_NAME = 'MAPS_COASTLINE'

; ===> Defauls
  IF NONE(RESOLUTION) THEN RESOLUTION = 'HIGH'  ELSE RESOLUTION = STRUPCASE(RESOLUTION)    ; High resolution
  
  MAP_LEVELS = []
  IF KEY(ADD_COAST) OR KEY(ADD_LAND) THEN MAP_LEVELS = [MAP_LEVELS,1] 
  IF KEY(ADD_LAKES) OR KEY(ADD_SMALL_LAKES) OR KEY(ADD_LAKE_SIDE) OR KEY(ADD_SMALL_LAKE_SIDE) OR KEY(ADD_RIVERS) THEN MAP_LEVELS = [MAP_LEVELS,2]
  IF KEY(ISLANDS) THEN MAP_LEVELS = [MAP_LEVELS,3]
  IF MAP_LEVELS EQ [] THEN BEGIN
    MAP_LEVELS = 1                                                                         ; Default to level 1 polygons
    ADD_LAND   = 1                                                                         ; Default to add land
  ENDIF
  
  LG_LAKEAREA = 15000.0 
  IF NONE(MINAREA)                                    THEN MINAREA = 10.0                   ; Minimum polygon area
  IF KEY(ADD_LAKES) OR KEY(ADD_LAKE_SIDE)             THEN MIN_LAKEAREA = LG_LAKEAREA       ; Exclude small lakes
  IF KEY(ADD_SMALL_LAKES) OR KEY(ADD_SMALL_LAKE_SIDE) THEN MIN_LAKEAREA = 50.0              ; Include small lakes
  IF NONE(MIN_LAKEAREA)                               THEN MIN_LAKEAREA = MINAREA
  
  IF NONE(ANTARCTICA) THEN ANTARCTICA = 'GROUND'                                            ; Level 5 = ICE front line, Level 6 = GROUND line 
  
  IF NONE(COAST_COLOR)          THEN COAST_COLOR          = 1                               ; BLACK when using PAL_LANDMASK
  IF NONE(COAST_THICK_COLOR)    THEN COAST_THICK_COLOR    = 2                               ; DIM GREY when using PAL_LANDMASK
  IF NONE(LAND_COLOR)           THEN LAND_COLOR           = 3                               ; DARK GREY when using PAL_LANDMASK
  IF NONE(LAKE_COLOR)           THEN LAKE_COLOR           = 4                               ; GREY when using PAL_LANDMASK
  IF NONE(LAKESIDE_COLOR)       THEN LAKESIDE_COLOR       = 5                               ; WHITE SMOKE when using PAL_LANDMASK
  IF NONE(SMALL_LAKE_COLOR)     THEN SMALL_LAKE_COLOR     = 6                               ; LIGHT GREY when using PAL_LANDMASK
  IF NONE(SMALL_LAKESIDE_COLOR) THEN SMALL_LAKESIDE_COLOR = 7                               ; PAL YELLOW when using PAL_LANDMASK
  
  IF KEY(FILL) THEN TEMP_OUTLINE = 0 ELSE TEMP_OUTLINE = 1 & FILL = KEY(FILL)
  IF NONE(OUTLINE) THEN OUTLINE = TEMP_OUTLINE ELSE OUTLINE = KEY(OUTLINE)
  
; ===> Get shoreline file
  CASE RESOLUTION OF
    'FULL':         FILE = !S.MASTER + 'gshhs_f.b'
    'HIGH':         FILE = !S.MASTER + 'gshhs_h.b'
    'INTERMEDIATE': FILE = !S.MASTER + 'gshhs_i.b'
    'LOW':          FILE = !S.MASTER + 'gshhs_l.b'
    'CRUDE':        FILE = !S.MASTER + 'gshhs_c.b'
  ENDCASE  
  
; ===> Open the file (note: GSHSS binary data files are big-endian)
  OPENR, LUN, FILE, /GET_LUN, /SWAP_IF_LITTLE_ENDIAN

; ===> Define the polygon header. This is for versions of the GSHHS software of 1.3 and earlier.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              polygonLevel: 0L, $ ; 1 land, 2 lake, 3 island-in-lake, 4 pond-in-island.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L, $      ; The area of polygon in 1/10 km^2.
;              version: 0L, $   ; Polygon version, always set to 3 in this version.
;              greenwich: 0S, $ ; Set to 1 if Greenwich median is crossed by polygon.
;              source: 0S }     ; Database source: 0 WDB, 1 WVS.

; ===>Define the polygon header, for GSHHS software 1.4 through 1.11, which uses a 40 byte header structure. For example, gshhs_i.b from the gshhs_1.10.zip file.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              flag: 0L, $      ; Contains polygonlevel, version, greenwich, and source values.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L, $      ; Database source: 0 WDB, 1 WVS.
;              junk:bytarr(8)}  ; Eight bytes of junk to pad header.

; ===> Define the polygon header, for GSHHS software 1.4 through 1.11, which uses a 32 byte header structure. For example, gshhs_h.b from the gshhs_1.11.zip.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              flag: 0L, $      ; Contains polygonlevel, version, greenwich, and source values.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L}        ; Database source: 0 WDB, 1 WVS.

; ===> Define the polygon header, for GSHHS software 2.0, which uses a 44 byte header structure. For example, gshhs_h.b from the gshhs_2.0.zip.
  HEADER = {ID: 0L, $        ; A unique polygon ID number, starting at 0.
            NPOINTS: 0L, $   ; The number of points in this polygon.
            FLAG: 0L, $      ; Contains polygon level, version, greenwich, source, and river values.
            WEST: 0L, $      ; West extent of polygon boundary in micro-degrees.
            EAST: 0L, $      ; East extent of polygon boundary in micro-degrees.
            SOUTH: 0L, $     ; South extent of polygon boundary in micro-degrees.
            NORTH: 0L, $     ; North extent of polygon boundary in micro-degrees.
            AREA: 0L, $      ; Area of polygon in 1/10 km^2.
            AREA_FULL: 0L, $ ; Area of origiinal full-resolution polygon in 1/10 km^2.
            CONTAINER: 0L, $ ; ID of container polygon that encloses this polygon (-1 if "none").
            ANCESTOR: 0L }   ; ID of ancestor polygon in the full resolution set that was the source of this polygon (-1 of "none").

          
; ===> Read each polygon
  WHILE (EOF(LUN) NE 1) DO BEGIN
    READU, LUN, HEADER  ; Read the polygon header

; ===> Parse the flag (Version 6 corresponds to 1.1x. Version 7 cooresponds to 2.0.)
    F = HEADER.FLAG 
    VRS = ISHFT(F, -8) AND 255B
 
    IF VRS LT 7 THEN BEGIN
      IF VRS GT 3 THEN BEGIN
        POLYGONLEVEL = (F AND 255B)
      ENDIF ELSE BEGIN
        POLYGONLEVEL = HEADER.LEVEL
      ENDELSE
      GREENWICH = ISHFT(F, -16) AND 255B
      SOURCE = ISHFT(F, -24) AND 255B
    ENDIF ELSE BEGIN
      LEVEL = F AND 255B
      POLYGONLEVEL = (F AND 255B)
      GREENWICH = ISHFT(F, -16) AND 1B
      SOURCE = ISHFT(F, -24) AND 1B
      RIVER_LEVEL = ISHFT(F, -25) AND 1B
      MAGNITUDE = ISHFT(F, -26) AND 255B ; Divide header.area by 10^magnitude to get true area
    ENDELSE
    
    IF VRS LE 8 THEN BEGIN
      POLYGONAREA = DOUBLE(HEADER.AREA) * 0.1 ; KM^2
    ENDIF ELSE BEGIN
      POLYGONAREA = DOUBLE(HEADER.AREA) / 10.0^MAGNITUDE ; KM^2
    ENDELSE
 
; ===> Get the polygon coordinates. Convert to lat/lon.
    PLYGON = LONARR(2, HEADER.NPOINTS, /NOZERO)
    READU, LUN, PLYGON 
      
; ===> Check level and area of this polygon
    IF POLYGONLEVEL EQ 5 AND ANTARCTICA EQ 'ICE'    THEN POLYGONLEVEL = 1  ; Change ANTARCTICA ICE polygon to level 1
    IF POLYGONLEVEL EQ 6 AND ANTARCTICA EQ 'GROUND' THEN POLYGONLEVEL = 1  ; Change ANTARCTICA GROUND polygon to level 1
    IF WHERE_MATCH(POLYGONLEVEL,MAP_LEVELS) EQ [] THEN CONTINUE            ; Skip if polygon level is not selected
    IF POLYGONAREA LE MINAREA THEN CONTINUE                                ; Skip if polygon area is too small
    IF POLYGONLEVEL EQ 2 AND POLYGONAREA LE MIN_LAKEAREA THEN CONTINUE     ; Skip if lake area is too small
    IF NONE(RIVERS) AND RIVER_LEVEL GE 1 THEN CONTINUE                     ; Skip if polygon is a river or river-lake and is not selected

; ===> Extract longitude and latitude data
    LON = REFORM(PLYGON[0,*] * 1.0E-6)
    LAT = REFORM(PLYGON[1,*] * 1.0E-6)
    GONE, PLYGON

; ===> If MAP_PROJ structure is defined, convert to data coordinates
    IF (N_ELEMENTS(MAP_STRUCTURE) NE 0) THEN BEGIN
      XY = MAP_PROJ_FORWARD(LON, LAT, MAP_STRUCTURE=MAP_STRUCTURE)
      LON = XY[0, *]
      LAT = XY[1, *]
    ENDIF

; ===> Check if this polygon should be displayed
    XY = CONVERT_COORD(LON, LAT, /DATA, /TO_NORMAL)
    XNORM = XY[0, *]
    YNORM = XY[1, *]
    LOC = (XNORM GE 0.0 AND XNORM LE 1.0) AND (YNORM GE 0.0 AND YNORM LE 1.0)
    IF MAX(LOC) EQ 0 THEN CONTINUE

; ===> Plot the polygon 
    CASE POLYGONLEVEL OF
      1: BEGIN
        IF KEY(ADD_LAND)                                           THEN POLYFILL, LON, LAT, COLOR=LAND_COLOR,  _EXTRA=_EXTRA
        IF KEY(ADD_COAST)                                          THEN PLOTS,    LON, LAT, COLOR=COAST_COLOR, _EXTRA=_EXTRA
      END
      2: BEGIN
        IF KEY(ADD_LAKES)           AND POLYGONAREA GE LG_LAKEAREA THEN POLYFILL, LON, LAT, COLOR=LAKE_COLOR, _EXTRA=_EXTRA
        IF KEY(ADD_LAKE_SIDE)       AND POLYGONAREA GE LG_LAKEAREA THEN PLOTS,    LON, LAT, COLOR=LAKESIDE_COLOR, _EXTRA=_EXTRA
        IF KEY(ADD_SMALL_LAKES)     AND POLYGONAREA LT LG_LAKEAREA THEN POLYFILL, LON, LAT, COLOR=SMALL_LAKE_COLOR, _EXTRA=_EXTRA
        IF KEY(ADD_SMALL_LAKE_SIDE) AND POLYGONAREA LT LG_LAKEAREA THEN PLOTS,    LON, LAT, COLOR=SMALL_LAKESIDE_COLOR, _EXTRA=_EXTRA  
        IF KEY(RIVERS) AND KEY(ADD_SMALL_LAKES)                    THEN POLYFILL, LON, LAT, COLOR=SMALL_LAKE_COLOR, _EXTRA=_EXTRA
        IF KEY(RIVERS) AND KEY(ADD_SMALL_LAKE_SIDE)                THEN PLOTS,    LON, LAT, COLOR=SMALL_LAKESIDE_COLOR, _EXTRA=_EXTRA
      END
      3: BEGIN
        IF KEY(LAND)                                               THEN POLYFILL, LON, LAT, COLOR=LAND_COLOR,  _EXTRA=_EXTRA
        IF KEY(COAST)                                              THEN PLOTS,    LON, LAT, COLOR=COAST_COLOR, _EXTRA=_EXTRA  
      END  
    ENDCASE  
        
  ENDWHILE

; ===> Close the file
  CLOSE, LUN & FREE_LUN, LUN

END
