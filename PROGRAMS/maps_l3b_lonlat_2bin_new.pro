; $ID:	MAPS_L3B_LONLAT_2BIN.PRO,	2017-03-14-15,	USER-KJWH	$

FUNCTION MAPS_L3B_LONLAT_2BIN_NEW, L3BMAP, LONS, LATS, BASEBIN=BASEBIN, NUMBIN=NUMBIN, LATBIN=LATBIN, TOTBINS=TOTBINS

;+
; NAME:
;   MAPS_L3B_LONLAT_2BIN
;
; PURPOSE:
;   This function generates the L3Bx bin locations for input LAT/LON arrays
;
; CATEGORY:
;   MAPPING
;
; CALLING SEQUENCE:
;
;   BINS = MAPS_L3B_LONLAT_2BIN(L3BMAP,LONS,LATS)
;
; INPUTS:
;   L3BMAP:  Must provide an input L3B1, L3B4, or L3B9 map
;   LON: Array of longitudes 
;   LAT: Array of latitudes
;   
; KEYWORDS:
;   LATBIN........... THE CENTRAL LATITUDE OF EACH ROW
;   NUMBIN........... THE NUMBER OF BINS IN EACH ROW  
;   BASEBIN.......... THE FIRST BIN NUMBER STARTING AT -180 FOR  EACH  ROW;   
;   TOTBINS.......... THE TOTAL NUMBER OF BINS FOR THE INPUT MAP
;
; OUTPUTS:  
;   An array of BIN locations
;  
; NOTES:
;
; MODIFICATION HISTORY:
;     Written:  June 22, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     JUN 22, 2016 - KJWH: Adapted from MAP_L3B9_LONLAT_2BIN
;     JUN 23, 2016 - KJWH: Changed the L3B1 NBINS from L to L64 data type
;                          Changed NUMBIN from INT to LONG
;     NOV 09, 2016 - KJWH: Updated the LATBIN and NUMBIN code to be consistent with NASA's ll2bin.pro and correct L3B to map errors
;                            http://oceancolor.gsfc.nasa.gov/DOCS/idl/ocidl/l3bin/ll2bin.pro                     
;     JAN 05, 2016 - KJWH: Was not able to remap from L3B9 to global (GEQ, SMI, GL8) maps because the NUMBIN was 1 short -> Changed I = INDGEN(NROWS) to I = INDGEN(NROWS+1)
;     MAR 11, 2017 - JEOR: Added keywords BASEBIN, NUMBIN, LATBIN
;     MAR 14, 2017 - KJWH: Reinstated the FOR I=0, NROWS DO BEGIN to fill in the LATBIN, NUMBIN and BASEBIN variables
;                          Added checks for the L3BMAP, LONS and LATS
;                          Removed the +1 from ROW = LONG64((90.0 + LAT)*(NROWS/180.0))
;                          Added IF ~FINITE(LAT) OR ~FINITE(LON) THEN CONTINUE
;                          Added TOTBINS as an optional output
;                          Changed MP to L3BMAP
;-
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ******************************
  ROUTINE='MAPS_L3B_LONLAT_2BIN'
; ******************************  

  IF NONE(L3BMAP) OR NONE(LATS) OR NONE(LONS) THEN MESSAGE,'ERROR: MUST PROVIDE L3BMAP & LONS & LATS'
  IF NOF(LONS) NE NOF(LATS)  THEN MESSAGE,'ERROR: DIMENSIONS OF LONS & LATS MUST BE SAME'
  
  NROWS =MAPS_L3B_NROWS(L3BMAP)
  NBINS = N_ELEMENTS(LONS)
  BINS  = REPLICATE(-1LL,NBINS) ; Make all BINS -1
  
  LATBIN = FINDGEN(NROWS+1)
  NUMBIN = INDGEN(NROWS+1)
  BASEBIN = L64INDGEN(NROWS+1)+1; & BASEBIN(0) = 1L
  I = INDGEN(NROWS)
  
	FOR I=0, NROWS DO BEGIN
	  LATBIN(I) = (I + 0.5) * (180.0D0/NROWS) - 90.0
	  NUMBIN(I) = LONG64(COS(LATBIN(I) * !DPI/180.0) * (2.0 * NROWS) + 0.5)
	  IF I GE 1 THEN BASEBIN(I) = BASEBIN(I-1) + NUMBIN(I-1)
	ENDFOR
	TOTBINS = BASEBIN(NROWS) + NUMBIN(NROWS) - 1
	
; Get idx number for specific lats & lons
	FOR N=0L, N_ELEMENTS(LATS)-1L DO BEGIN
		LAT = LATS(N)
    LON = LONS(N)
    IF ~FINITE(LAT) OR ~FINITE(LON) THEN CONTINUE
		ROW = LONG64((90.0 + LAT)*(NROWS/180.0))
		ROW = ROW < NROWS

		LON = LON + 180.0
		COL = LONG64(LON*NUMBIN(ROW)/360.0) + 1
		COL = COL < NUMBIN(ROW)
		BINS(N) = BASEBIN(ROW) + COL -1
	ENDFOR
	
	RETURN, BINS

END; #####################  END OF ROUTINE ################################
