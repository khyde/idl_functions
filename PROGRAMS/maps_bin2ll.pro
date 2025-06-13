; $ID:	MAPS_BIN2LL.PRO,	2019-07-29-12,	USER-KJWH	$
FUNCTION MAPS_BIN2LL, MP, LONS=LONS, LATS=LATS, SKIP_LONLAT=SKIP_LONLAT
;    
;+
; NAME:
;   MAPS_BIN2LL
;
; PURPOSE:
;   This function computes the latitude/longitude values for an array of bin numbers.
;
; CATEGORY:
;   MAPPING
;
; CALLING SEQUENCE:
;
;   BINS = MAPS_L3B_LONLAT_2BIN_J(MP,LONS=LONS,LATS=LATS)
;
; INPUTS:
;   MP:  Must provide a L3Bx map
;   
; OUTPUTS:
;   LONS:   Longitudes associated with the respective bin numbers
;   LATS:   Latitudes associated with the respective bin numbers
;
; KEYWORDS:
;         
;
; NOTES:
;   Adapted from NASA's BIN2LL found in the Ocean Color IDL library https://oceancolor.gsfc.nasa.gov/cgi/idllibrary.cgi?dir=l3bin 
;   
;
; MODIFICATION HISTORY:
;     Written:  March 13, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     MAR 13, 2017 - KJWH: Changed the PROGRAM to a FUNCTION
;                          Removed the beginning PRINT statements 
;                          Updated formatting
;                          Changed BINS = LINDGEN(NBINS) to BINS = LINDGEN(NBINS)+1 to convert the array, which starts at 0, to bin numbers that start at 1     
;     AUG 24, 2017 - KJWH: Added 'NBINS_ROW',NUMBIN (Number of BINS per row) to the output structure    
;     SEP 07, 2017 - KJWH: Added LAST_BIN (the last bin number in a row) to the output structure   
;     JUL 26, 2019 - KJWH: Added IF MP EQ 'L3B2N' THEN LATBIN=((I + 0.5) * (180.0D0/NROWS) - 90.0) to increase the precision needed for the new L3B2 bins
;     JUL 29, 2019 - KJWH: Added SKIP_LONLAT keyword to skip the step to calculate the lons and lats of each bin (not needed for MAPS_L3B_LONLAT_2BIN)                 
;-

  NROWS = MAPS_L3B_NROWS(MP)
  NBINS = MAPS_L3B_NBINS(MP)
  BINS = LONARR(1,NBINS) 
  BINS[0,*] = LINDGEN(NBINS)+1 ; Convert the array, which starts at 0, to bin numbers that start at 1

  I=INDGEN(NROWS)
  LATBIN=((I + 0.5) * (180.0D0/NROWS) - 90.0)
  NUMBIN=LONG(COS(LATBIN *!DPI/180.0) * (2.0*NROWS) +0.5)
  BASEBIN=LINDGEN(NROWS) & BASEBIN[0]=1
  FOR I=1,NROWS-1 DO BASEBIN[I]=BASEBIN[I-1] + NUMBIN[I-1]

  TOTBINS = BASEBIN[NROWS-1] + NUMBIN[NROWS-1] - 1
  BASEBIN = [BASEBIN, TOTBINS+1]
  
  NBINS = N_ELEMENTS(BINS)  
   
  IF KEY(SKIP_LONLAT) THEN RETURN, STR = CREATE_STRUCT('MAP',MP,'NROWS',NROWS,'NBINS',NBINS,'BINS',BINS,'TOTAL_BINS',TOTBINS,'FIRST_BIN',BASEBIN(0:-2),'LAST_BIN',BASEBIN(0:-2)+NUMBIN-1,'NBINS_ROW',NUMBIN)
    
  LATS = FLTARR(1,NBINS)
  LONS = FLTARR(1,NBINS)
  
  OLDROW = 1
  FOR I=0L,N_ELEMENTS(BINS)-1 DO BEGIN
    BIN=LONG(BINS[I])
    
    IF BIN GE BASEBIN(OLDROW-1) AND BIN LT BASEBIN(OLDROW) THEN ROW = OLDROW ELSE BEGIN
      RLOW = 1
      RHI = NROWS
      ROW = -1
      WHILE (ROW NE RLOW) DO BEGIN
        RMID = (RLOW + RHI - 1) / 2
        IF BASEBIN[RMID] GT BIN  THEN RHI = RMID ELSE RLOW = RMID + 1    
        IF RLOW EQ RHI THEN  BEGIN
          ROW = RLOW
          OLDROW = ROW
        ENDIF
      ENDWHILE          
    ENDELSE    
    
    LAT = LATBIN[ROW-1]
    LON = 360.0 * (BIN - BASEBIN[ROW-1] + 0.5) / NUMBIN[ROW-1]  
    LON = LON - 180
  
    IF (LON LT -180) THEN LON = LON+360
    IF (LON GT  180) THEN LON = LON-360
    
    LATS[0,I] = LAT
    LONS[0,I] = LON
  ENDFOR
  
  RETURN, STR = CREATE_STRUCT('MAP',MP,'NROWS',NROWS,'NBINS',NBINS,'BINS',BINS,'LONS',LONS,'LATS',LATS,'TOTAL_BINS',TOTBINS,'FIRST_BIN',BASEBIN(0:-2),'LAST_BIN',BASEBIN(0:-2)+NUMBIN-1,'NBINS_ROW',NUMBIN)
END
