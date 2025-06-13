; $ID:	LATLON_GEN.PRO,	JULY 24 2005, 07:25	$

 FUNCTION LATLON_GEN,  DEG=DEG, LON_RANGE=LON_RANGE, LAT_RANGE=LAT_RANGE, NOROUND=NOROUND,ERROR=error
;+
; NAME:
; 	LATLON_GEN
;
; PURPOSE:
; 	Generate a Structure containing 2-d arrays of longitude and latitudes within the range specified in LON,LAT,
;		and in increments specified by DEG
;
; CATEGORY:
;  	MAP
;
; INPUTS:
;		None are Required (defaults will be used)
; KEYWORD PARAMETERS:
;		DEG:   Decimal degrees for incremental lon and lat
;		LON_RANGE:   Longitude array [minimum, maximum]
;		LAT_RANGE:   Latitude  array [minimum, maximum]
;	 	NOROUND:		Prevents rounding (rounding is usually desired so that returned lat,lon are in uniform intervals

; OUTPUTS:
;		Structure with a 2-d array of latitudes and a 2-d array of longitudes
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;	EXAMPLES:
;     LL=LATLON_GEN(DEG=1.0, 		LON_RANGE=[ -73 ,-71],LAT_RANGE=[40,42]) & HELP,/STRUCT,LL
;			LL=LATLON_GEN(DEG= 1./6, 	LON_RANGE=[ -80 ,-61],LAT_RANGE=[34,46])  & HELP,/STRUCT,LL

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 24, 2005
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'LATLON_GEN'

; Check if degree parameter supplied by user.
  IF N_ELEMENTS(deg) NE 1 THEN deg = 1.0


; ====================>
; Check that LON_RANGE and LAT_RANGE provided
  IF N_ELEMENTS(LON_RANGE) NE 2 THEN MESSAGE, 'ERROR: LON_RANGE MUST BE [MinLon,MaxLon)'
  IF N_ELEMENTS(LAT_RANGE) NE 2 THEN MESSAGE, 'ERROR: LAT_RANGE MUST BE [MinLat,MaxLat)'

	LATS = INTERVAL(LAT_RANGE,DEG)
	LONS = INTERVAL(LON_RANGE,DEG)

	IF NOT KEYWORD_SET(NOROUND) THEN BEGIN
		LATS = (ROUND(1E6*LATS))*1E-6
		LONS = (ROUND(1E6*LONS))*1E-6
	ENDIF

  RETURN, CREATE_STRUCT('LON', LONS # REPLICATE(1,N_ELEMENTS(LATS)),  'LAT',  REPLICATE(1,N_ELEMENTS(LONS)) # LATS  )


	END; #####################  End of Routine ################################
