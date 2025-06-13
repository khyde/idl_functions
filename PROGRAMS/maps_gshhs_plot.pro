PRO MAPS_GSHHS_PLOT, FILE, MAP_LEVEL=MAP_LEVEL, RIVER_LEVEL=RIVER_LEVEL, MINAREA=MINAREA, $
                     COLOR=COLOR, BACKGROUND=BACKGROUND, LAND_COLOR=LAND_COLOR, WATER_COLOR=WATER_COLOR,$
                     OUTLINE=OUTLINE, FILL=FILL, MAP_STRUCTURE=MAP_STRUCTURE, _EXTRA=_EXTRA

;+
; DESCRIPTION:
;    Plot coastlines from a GSHHS coastline file.
;
;    GSHHS stands for the Global Self-consistent, Hierarchical,
;    High-resolution Shoreline Database assembled by Paul Wessel
;    and Walter Smith. For more information:
;    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
;
;    The binary data files may be downloaded from the site above:
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
;    MAPS_GSHHS_PLOT, FILE
;
; INPUT PARAMETERS:
;    FILE          Full path and name of the GSHHS coastline file.
;
; OUTPUT PARAMETERS:
;    None.
;
; OPTIONAL KEYWORDS:
;    LEVEL         The level of geographical features plotted (default = 1).
;                  1 = land
;                  2 = lake
;                  3 = island in lake
;                  4 = pond in island in lake
;                  The selected level and all lower levels are plotted.
;    AREA          Minimum area of features to be plotted (sq. km; default = 500).
;    COLOR         Color table index for plotting (default = !D.TABLE_SIZE - 1).
;    BACKGROUND    Color table index for lakes or ponds when FILL is active (default = 0).
;    FILL          If set, land masses are filled with COLOR, and inland water
;                  bodies are filled with BACKGROUND.
;    MAP_STRUCTURE Set this keyword to a !MAP structure, as returned from MAP_PROJ_INIT. 
;
;    Also accepts any keywords accepted by PLOTS or POLYFILL.
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; Copyright (C) 2006 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
; 
; 
; Modification History - K.J.W. Hyde 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
; Mar 22, 2016 - KJWH: Changed program name to MAPS_GSHHS_PLOT
;                      Added RIVER_LEVEL
;                      Added several updates based on David Fanning's MAP_GSHHS_SHORELINE http://www.idlcoyote.com/programs/retired/map_gshhs_shoreline.pro
;                        * Added keywords LAND_COLOR, WATER_COLOR, and OUTLINE
;                        * Updated polygon header information for GSHHS version 2.3.4
;                        * Added VERSION information
;                      Added NARLAB code  
; 
; 
;-

  ROUTINE_NAME = 'MAPS_GSHHS_PLOT'

; ===> Defauls
  IF NONE(FILE)        THEN FILE = !S.MASTER + gshhs_h.b                     ; High resolution
  IF NONE(MAP_LEVEL)   THEN MAP_LEVEL = 2 ELSE MAP_LEVEL = 1 > MAP_LEVEL < 4 ; Lake
  IF NONE(RIVER_LEVEL) THEN RIVER_LEVEL = 0 ELSE RIVER_LEVEL = 0 > RIVER_LEVEL < 2 ; No rivers
  IF NONE(MINAREA)     THEN MINAREA = 500.0                                  ; Square kilometers
  IF NONE(COLOR)       THEN COLOR = 1                                        ; BLACK when using PAL_LANDMASK
  IF NONE(BACKGROUND)  THEN BACKGROUND = 0                                   ; WHITE when using PAL_LANDMASK
  IF NONE(WATER_COLOR) THEN WATER_COLOR = 0                                  ; WHITE when using PAL_LANDMASK
  IF NONE(LAND_COLOR)  THEN LAND_COLOR = 2                                   ; GREY when using PAL_LANDMASK
  IF NONE(COAST_COLOR) THEN COAST_COLOR = 1                                  ; BLACK when using PAL_LANDMASK
  
  IF KEY(FILL) THEN TEMP_OUTLINE = 0 ELSE TEMP_OUTLINE = 1 & FILL = KEY(FILL)
  IF NONE(OUTLINE) THEN OUTLINE = TEMP_OUTLINE ELSE OUTLINE = KEY(OUTLINE)
  
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
      RIVER = ISHFT(F, -25) AND 1B
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
    IF POLYGONLEVEL NE MAP_LEVEL OR POLYGONAREA LE MINAREA OR RIVER_LEVEL NE RIVER THEN CONTINUE

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
    USEPOLYGON = MAX(LOC)
    IF USEPOLYGON EQ 0 THEN CONTINUE

    p, 'POLY LEVEL = ' + ROUNDS(POLYGONLEVEL) + ' & POLYAREA = ' + ROUNDS(POLYGONAREA) + ' (' + ROUNDS(POLY_AREA(LON,LAT),2) + ') RIVER = ' + ROUNDS(RIVER)

    
; ===> Plot the polygon   
    IF KEY(FILL) THEN BEGIN
      IF (POLYGONLEVEL EQ 1) OR (POLYGONLEVEL EQ 3) THEN POLYFILL, LON, LAT, COLOR=LAND_COLOR,  _EXTRA=_EXTRA $
                                                    ELSE POLYFILL, LON, LAT, COLOR=WATER_COLOR, _EXTRA=_EXTRA
    ENDIF ELSE PLOTS, LON, LAT, COLOR=COLOR, _EXTRA=_EXTRA    
    
    IF KEY(FILL) AND KEY(OUTLINE) THEN PLOTS, LON, LAT, COLOR=COAST_COLOR, _EXTRA=EXTRA
        
  ENDWHILE

; ===> Close the file
  CLOSE, LUN & FREE_LUN, LUN

END
