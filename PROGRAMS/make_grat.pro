; $ID:	MAKE_GRAT.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION MAKE_GRAT,  DEG=DEG, LON=LON, LAT=LAT, FILE=FILE,   _EXTRA=_extra
;+
; NAME:
;       MAKE_GRAT
;
; PURPOSE:
;       Generate a longitude,latitude graticule ascii file
;       Formated as 2 f10.6
;
; CATEGORY:
;      MAPPING,PLOTTING
;
; CALLING SEQUENCE:
;       MAKE_GRAT,DEG=0.25, LON=[-77,-61],LAT=[33,45] ,FILE='C:\IDL\JAY\NEA_GRAT_1_4.DIM' ; NEA MAP
;       MAKE_GRAT,DEG=0.25, LON=[-83,-69],LAT=[24,38] ,FILE='C:\IDL\JAY\SEA_GRAT_1_4.DIM' ; NEA MAP
;       MAKE_GRAT,DEG=1.0/6.0, LON=[ -79.0781,-61.8828],LAT=[31.4453,45.8203] ,FILE='NECW_GRAT.DIM' ; NECW
; 			MAKE_GRAT,DEG=1.0/6.0, LON=[ -78.197444,-61.802556],LAT=[34.021297,45.755557] ,FILE='NEC_GRAT.DIM' ; NEC

; 			MAKE_GRAT,DEG=1.0/6.0, LON=[ -90.0, -71.0],LAT=[21.0,39.0] ,FILE='SEC_GRAT.TXT' ; SEC


; INPUTS:
;
;
; KEYWORD PARAMETERS:
;      DEG:   Decimal degrees for incremental lon and lat
;      LON:   Longitude array [minimum, maximum]
;      LAT:   Latitude  array [minimum, maximum]
;      FILE:  Output ASCII File Name
;
; OUTPUTS:
;      File containing lon,lat coordinates
;      Default FORMAT = '(F10.5,f10.5)'
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 15, 1995.
;       June 30, 1997 Changed check on !x.type from 2 to 3(idl 5.0)
;       June 30, 1997 DEG IS now a parameter instead of a keyword
;       March 7,1999  KEYWORD LONLAT PROVIDED to return array of lons and lats to calling program
;-
; ====================>

; Check if degree parameter supplied by user.
  IF N_ELEMENTS(deg) NE 1 THEN deg = 1.0


; ====================>
; Check that Lon and lat provided
  IF N_ELEMENTS(LON) NE 2 THEN MESSAGE, 'ERROR: LON MUST BE [MinLon,MaxLon)'
  IF N_ELEMENTS(LAT) NE 2 THEN MESSAGE, 'ERROR: LAT MUST BE [MinLat,MaxLat)'


; ====================>
; Get a starting min,max lon and lat
; on a increment of decimal degrees (deg)
  minlon = FLOOR(lon[0]) - deg
  maxlon = CEIL(lon[1]) + deg
  minlat = FLOOR(lat[0]) - deg
  maxlat = CEIL(lat[1]) + deg


; ====================>
; Open file
  IF N_ELEMENTS(FILE) NE 1 THEN FILE = 'make_grat.txt'

  OPENW,LUN,FILE,/GET_LUN

; ====================>
; Loop to plot each graticule
  lon = minlon
  WHILE lon LE (maxlon) DO BEGIN
    lon  = lon + deg
    lat  = minlat
    WHILE lat LE maxlat DO BEGIN
      lat = lat + deg
      PRINTF,LUN, lon,lat, FORMAT='(f10.5,f10.5)',_EXTRA=_extra
    ENDWHILE
  ENDWHILE

  CLOSE,LUN
; ====================>
  END  ; END OF PROGRAM
