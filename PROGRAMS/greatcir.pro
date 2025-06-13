; $Id: greatcir.pro, v 1.1 1996/02/18 12:00:00 J.E.O'Reilly Exp $
;
;+
; NAME:
;       greatcir
;
; PURPOSE:
;       Function Computes Approximate Great Circle Distance from
;       the Lat and Lon coordinates for two locations.
;       Program assumes input coordinates are in DECIMAL DEGREES
;       (IF not then user should first run DMS2DEG.PRO
;       to convert degrees,minutes,seconds to decimal degrees)
;       This is useful for calculating distances (km) of stations
;       along a transect.
;
; CATEGORY:
;      	Maps
;
; CALLING SEQUENCE:

;       NOTE: Program expects x,y order or longitude,latitude,longitude,latitude
;
;       result=greatcir()  ; Program will prompt for starting lon,lat, and ending lon,lat
;
;		result=greatcir(70,40,71,40) : Program will return distance in km between two coordinate pairs
;
;       The following will return 3 distances (different starting coordinates)
;       result=greatcir([70.1,70.2,70.3],[35.1,35.2,35.3],[70.1,70.2,70.3],[36.1,36.2,36.3])
;
;       The following will return 3  distances (same single starting coordinate)
;       result=greatcir(70.1,35.1,[70.1,70.2,70.3],[36.1,36.2,36.3])
;
; INPUTS:
;       If no inputs then Program will prompt for input
;
; KEYWORD PARAMETERS:
;      	NONE
;
; OUTPUTS:
;    	Distance(s) in KM
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;       NOTE: PROGRAM EXPECTS INPUT IN LAT,LON,   LAT, LON
;       NOTE: Longitudes may be - or + but longitudes must be all negative or all positive.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 10, 1995.
;       DERIVED FROM CROSSSECT.FOR
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu

;       March 11,1996 Revised: To handle distances from a single starting coordinate
;       March 18,1996 Revised: Program assumes input coords are in DECIMAL degrees
;                              If program detects data > 999 (3 digits) then stops and
;                              suggests input data are not in decimal degrees.
;-

  FUNCTION GREATCIR,LON1,LAT1,LON2,LAT2
; ====================>
  PI= DOUBLE(3.1415927)
  DTR = DOUBLE(PI/180.0)
  ZERO = DOUBLE(0.0)
; ====================>

  IF N_PARAMS() LT 4 THEN BEGIN
	PRINT, 'Enter lon1,lat1,lon2,lat2 '
	READ,  LON1,LAT1,LON2, LAT2
  ENDIF

; ====================>
; If user wants several distances from a single coordinate
; then replicate the single starting coordinate
  IF N_ELEMENTS(LAT1) EQ 1 AND N_ELEMENTS(LON1) EQ 1 AND $
     N_ELEMENTS(LAT2) GT 1 AND $
     N_ELEMENTS(LAT2) EQ N_ELEMENTS(LON2) THEN BEGIN
     LAT1  = REPLICATE(lat1,N_ELEMENTS(lat2))
     LON1  = REPLICATE(lon1,N_ELEMENTS(lon2))
  ENDIF

; ====================>
; Distances generated using Pairs of coordinates
  IF N_ELEMENTS(LAT1) EQ N_ELEMENTS(LON1) AND $
     N_ELEMENTS(LAT2) EQ N_ELEMENTS(LON2) AND $
     N_ELEMENTS(LAT2) EQ N_ELEMENTS(LAT1) THEN BEGIN

;   Calculate the distance along the section, RAD = the earth's radius in km
    LATBAR = 0.5*(LAT1+LAT2)
    RAD = (-13.34*LATBAR/90.0 + 3963.35)/1.1516
    RAD = RAD*1.852
    PA = (90.0 - LAT1)*DTR
    PB = (90.0 - LAT2)*DTR
    APB = (LON1 - LON2)*DTR
    AB = DOUBLE(ACOS(COS(PA)*COS(PB) + SIN(PA)*SIN(PB)*COS(APB)))
;    next two lines in orig program not needed ??
;    PAB = ASIN(SIN(APB)*SIN(PB)/SIN(AB))
;    IF (PB  GT  PA) THEN PAB = PI - PAB
    kms = AB*RAD

    RETURN, KMS
  ENDIF ELSE BEGIN
    PRINT, 'ERROR: IN INPUT DATA'
    RETURN, 0.0D
  ENDELSE
  END ; End of program
