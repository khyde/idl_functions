; $ID:	SATSHIP_GETPIXELS.PRO,	2020-03-30-17,	USER-KJWH	$

;+
; NAME:
;   SATSHIP_GETPIXELS.PRO
;
; PURPOSE:
;   Routine to take an L1/L2 satellite file and extract the pixel, or pixels and surrounding ones,
;   at the location specified by lat/lon.  Lat/Lon may be arrays.
;    
; CATEGORY:
;   HDF Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   SAT_FILE   := SEAWIFS, MODIS or other L1/l2 data HDF file
;   LON, LAT   := Longitude and Latitude (may be arrays) for the desired points.
;
; OPTIONAL INPUTS:
;   PSIZE=PSIZE := 
;     0 = single pixel
;     1 = 3x3 array
;     2 = 5x5 array
;     3 = 7x7 array, and so on up to an arbitrary MAXSIZE.
;         MAXSIZE (9) for the pixel array is set at the initialization and may adjusted.
;   ERROR=ERROR
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns a structure *or* structure array with Satellite product pixel array (NxN),
;   and the beginning and ending scan lines and the beginning and ending pixel indices from the
;   satellite image.  The format of a structure element result R is:
;     R.PIXVALS := [NxN]
;     R.BOUNDS  := [SPX, EPX, SLP, ELP]
;       SPX, EPX are Starting and Ending pixels (X)
;       SLP, ELP are Starting and Ending scan line pixels (Y)
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;     This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;   Get the pixels/bounds in a 3x3 array around the location of point lat/lon:
;     R = get_hdf_pixels_from_latlon('S2010...hdf',-44.0, -71.0, 'chlor_a', PSIZE=1, error=error)
;   Get the pixels/bounds in a 5x5 array around the location of points in arrays lat[]/lon[]
;     R = OC_GET_HDF_PIXELS_FROM_LATLON(SAT_FILE, LAT(LX), LON(LX), PROD, PSIZE=2, ERROR=ERROR)
;   Get the pixel in a 5x5 array around the location of points in arrays lat[]/lon[]
;     R = OC_GET_HDF_PIXELS_FROM_LATLON(SAT_FILE, LAT(LX), LON(LX), PROD, PSIZE=2, ERROR=ERROR)
;   
; NOTES:
;   This routine works for either single lat/lon points or arrays of lat[]/lon[]
;   The function may be called for single lat/lon, but looping over lat lons
;   should be done by this funcion, not the caller. This is due to the overhead of opening
;   the HDF file and reading in the image, which is done only once each time it is called.
;   The BOUNDS are enough to determine the pixel arrays for other variables in the same range,
;   as in A = SD[SPX:EPX,SLP:ELP], so the actual indices of the values are not determined.
;   This routine is independent except for READALL utility and the SeaDAS system's 'lonlat2pixline'.
;
; MODIFICATION HISTORY:
;   Written April 27, 2011 by D.W. Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;   Modification History
;           May  5, 2015 - KJWH: Now returning subscripts so there is no need for products
;                                Read the HDF (or NC) file in the calling program and just input the GLOBAL, LON and LAT structures
;           Jul 16, 2015 - KJWH: Removed GLOBAL keyword    
;           Jul 24, 2015 - KJWH: Removed SATFILE input and changed order of LON and LAT inputs       
;           Mar 30, 2020 - KJWH: Changed the RMISS.CENTER_SUB value to -999
;                                Now writing an error message if a particular lon/lat was not found in the file, but not returning an ERROR=1 because there could be other valid pixels
;                                
;-
; ****************************************************************************************************

FUNCTION SATSHIP_GETPIXELS, LON, LAT, AROUND=AROUND, MISSVAL=MISSVAL, LONGITUDE=LONGITUDE, LATITUDE=LATITUDE, ERROR=ERROR,ERR_MSG=ERR_MSG

  ROUTINE_NAME='SATSHIP_GETPIXELS'
  ERROR = 0
  ERR_MSG = ''
  RESULT = []
  MAXSIZE = 9 ; adjust this if desired
  IF N_ELEMENTS(AROUND) EQ 0 THEN AROUND = 0

; THIS IS ARBITRARY (9)
  IF AROUND GE MAXSIZE THEN BEGIN
    ERROR = ' Error in ' + ROUTINE_NAME + ': size must be less than internally specified maxsize = ' + NUM2STR(MAXSIZE) 
    PRINT,ERROR
    RETURN, []
  ENDIF
 
; LON/LAT may optionally be arrays now.
  NLAT = N_ELEMENTS(LAT)
  NLON = N_ELEMENTS(LON)
  IF NLON NE NLAT THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Error in ' + ROUTINE_NAME + ': Number of elements in lat and lon arrays must be equal.'
    PRINT,ERR_MSG
    RETURN, []
  ENDIF

  LX = WHERE(LAT LT 90 OR LAT GT -90, COUNTX)
  LY = WHERE(LON LT 180 OR LON GT -180, COUNTY) 
  IF (COUNTX EQ 0) OR (COUNTY EQ 0) THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Error in ' + ROUTINE_NAME + ': no elements in lat/lon array found in world bounds.'
    PRINT,ERR_MSG
    RETURN,[] 
  ENDIF 
  
; Initialize array   
  ASIZE = (AROUND * 2 ) + 1
  RA = LONARR(ASIZE,ASIZE) 
  RA[*,*] = MISSINGS(RA)
  R = CREATE_STRUCT('CENTER_SUB', 0L, 'BOX_SUBS', RA)
  RMISS = R  
  RMISS.CENTER_SUB = -999

  FOR I = 0, NLAT - 1 DO BEGIN ; Loop through LONLATS
   CENTERSUB = SATSHIP_GET_LONLAT_SUB(LON[I], LAT[I], LATITUDE=LATITUDE,LONGITUDE=LONGITUDE, error=err, err_msg=err_msg)
   IF ERR NE 0 THEN BEGIN
     ERR_MSG = 'SATSHIP_GET_LONLAT_SUB was unable to find points in for ' + NUM2STR(LON[I]) + ', ' + NUM2STR(LAT[I]) + '.'
     RESULT=[RESULT, RMISS]
     CONTINUE ; skip to the next lat lon pair
   ENDIF
     
   BOXSUBS = []
   R.CENTER_SUB = CENTERSUB
   IF AROUND GT 0 THEN BEGIN
     BOX = BOX_AROUND(LONGITUDE, CENTERSUB, SUBS=BOXSUBS, AROUND=AROUND)   
     R.BOX_SUBS   = BOXSUBS      
   ENDIF
    RESULT = [RESULT, R]
  ENDFOR
  RETURN, RESULT  

END
