; $ID:	SATSHIP_GET_LONLAT_SUB.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; NAME:
;   SATSHIP_GET_LONLAT_SUB.PRO
;
; PURPOSE:
;   Take an input Level 2 or level 1B satellite HDF file and find the pixels around lon / lat.
;   Based on algorithms in SeaDAS lonlat2pixline.
;
; CATEGORY:
;   HDF Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   FILE  := SEAWIFS, MODIS or other L1/l2 data HDF file
;   X     := number of pixels to surround the lat lon pixel found
;   lon   := desired longitude
;   lat   := desired latitude
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   prints out the longitude, latitude, start and end scan lines, and start and end pixels.
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;   Utilizes the lonlat2pixline algorithm, with changes to suit IDL and elimates some complexity.
;
; EXAMPLES:
;   
; NOTES:
;
; MODIFICATION HISTORY:
;     Written May  5, 2011 by D.W. Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;             May  6, 2011 DWM  Implemented algorithm using IDL arrays instead of looping
;             May 10, 2011 DWM  Added checks for boundary + err_msg
;             May 25, 2011 DWM  Added COMMONS for saving computations between calls, *huge* speedup.
;                               Compared results for testing with previous "uncommon" and they check.
;             Jun 09, 2011 DWM  Added RESET routine to blast the previous_file common.  Must be done
;                               prior to running a series.  Changed much debugging level output to 2.
;             May  6, 2015 KJWH Fixed error - program correctly found the closest matching pixel for the center, but when creating the box, it shifted the center pixel to the bottom left
;                               Removed several +1 in the section that determines the pixel locations for the BOX
;                               Changed name to SATSHIP_GET_LONLAT_SUB to be in the SATSHIP family
;                               Removed calls to READ_HDF - instead input the LON, LAT and GLOBAL information
;                               Now only finding the subscript of the center pixel - can use BOX_AROUND in the calling program to find additional pixels
;             Jun 08, 2015 KJWH Changed the logic for determining the number of scan lines (rows) and pixel lines (columns) because the new L2 nc files do not contain tags for number of scan lines or pixels per scan line
;             Jul 16, 2015 KJWH Removed GLOBAL keyword 
;-
; ****************************************************************************************************
FUNCTION SATSHIP_GET_LONLAT_SUB, LON, LAT, LATITUDE=LATITUDE, LONGITUDE=LONGITUDE, ERROR=ERROR, ERR_MSG=ERR_MSG

  ROUTINE_NAME='SATSHIP_GET_LONLAT_SUB'

  ERROR = ''
  FAIL = 0
 
  RADEG=DOUBLE(57.29577951)
  MAXCOS = DOUBLE(-1)
  SWLON = DOUBLE(LON)
  SWLAT = DOUBLE(LAT)

  CORNERLON = FINDGEN(2)
  CORNERLAT = FINDGEN(2)

  UVPIX = DBLARR(3)
  UV    = DBLARR(3)

  LONA = LONGITUDE  ; ARRAY[NPIX, NSCANS]
  LATA = LATITUDE   ; ARRAY[NPIX, NSCANS]
  SZ = SIZE(LONA,/DIMENSIONS)
  NROWS = SZ[1]
  NCOLS = SZ[0]
  
  LONADEG = LONA / RADEG
  LATADEG = LATA / RADEG
  
  LONCOS = COS(LONADEG)
  LONSIN = SIN(LONADEG)
  LATCOS = COS(LATADEG)
  LATSIN = SIN(LATADEG)
  PROD0 = LATCOS * LONCOS
  PROD1 = LATCOS * LONSIN
  PROD2 = LATSIN

  CORNERLON[0] = SWLON - 0.1
  CORNERLON[1] = SWLON + 0.1

  IF (CORNERLON[0] LT -180) THEN CORNERLON[0] = 360 - CORNERLON[0]
  IF (CORNERLON[1] GT +180) THEN CORNERLON[1] = CORNERLON[1] - 360

  CORNERLAT[0] = SWLAT - 0.1
  CORNERLAT[1] = SWLAT + 0.1
  IF (CORNERLAT[0] LT -90) THEN CORNERLAT[0] = -89.99
  IF (CORNERLAT[1] GT +90) THEN CORNERLAT[1] = +89.99

  UVPIX[0] = COS(SWLAT / RADEG) * COS(SWLON / RADEG)
  UVPIX[1] = COS(SWLAT / RADEG) * SIN(SWLON / RADEG)
  UVPIX[2] = SIN(SWLAT / RADEG)

; final implementation, utilizing all IDL array abilities, FASTEST solution
  DOTA  = PROD0 * UVPIX[0] + PROD1 * UVPIX[1] + PROD2 * UVPIX[2]
  DMAX  = MAX(DOTA,LOCATION)
  SOLN  = ARRAY_INDICES(DOTA, LOCATION)
  
  PIXPX = SOLN[0]
  PIXSN = SOLN[1]
  
  ; check boundaries
  IF (PIXSN) LT 1 THEN FAIL = 1
  IF (PIXPX) LT 1 THEN FAIL = 1
  IF (PIXSN) GE NROWS-1 THEN FAIL = 1
  IF (PIXPX) GE NCOLS-1 THEN FAIL = 1

  IF FAIL EQ 1 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Desired pixels not found in '
    DEBUG_PRINT, 2, ERR_MSG
    RETURN, []
  ENDIF 

  RETURN, TWO2ONE(PIXPX, PIXSN, LONA)
END
