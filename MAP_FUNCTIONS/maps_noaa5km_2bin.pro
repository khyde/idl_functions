; $ID:	MAPS_NOAA5KM_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION MAPS_NOAA5KM_2BIN, ARRAY, MAP_OUT, LONS=LONS, LATS=LATS, INIT=INIT, BINS_OUT=BINS_OUT

;+
; NAME:
;   MAPS_NOAA5KM_2BIN
;
; PURPOSE:
;   This program converts a 7200 x 3600 global NOAA 5km array to a L3B array
;
; CATEGORY:
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_NOAA5KM_2BIN(ARRAY)
;
; REQUIRED INPUTS:
;   ARRAY.......... The input NOAA 5km data array
;   MAP_OUT........ The name of the output map
;
; OPTIONAL INPUTS:
;   LONS........... Longitude array if the input is not a full 7200x3600 array
;   LATS........... Latitude array if the input is not a full 7200x3600 array
;
; KEYWORD PARAMETERS:
;   INIT............ Reinitialize the COMMON block
;
; OUTPUTS:
;   OUTPUT.......... A remapped array
;
; OPTIONAL OUTPUTS:
;   BINS_OUT....... The array of output map "bins"
;
; COMMON BLOCKS: 
;   MAPS_SESCAPE_2BIN_, BINS9, BINS4, BINS2, BINS1 
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   The NOAA5KM_7200_3600_2L3B9(4).SAV files were created using MAPS_L3B_SUBS
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 04, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 04, 2021 - KJWH: Initial code written
;   Feb 18, 2022 - KJWH: Changed name from MAPS_SEASCAPES_2BIN to MAPS_NOAA5KM_2BIN to work with other NOAA 5km products
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_NOAA5KM_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON MAPS_NOAA5KM_2BIN_, BINS9, BINS5, BINS4, BINS2, BINS1, FLONS, FLATS 
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS9) EQ 0 THEN BINS9 = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS5) EQ 0 THEN BINS5 = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS4) EQ 0 THEN BINS4 = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS2) EQ 0 THEN BINS2 = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS1) EQ 0 THEN BINS1 = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLONS) EQ 0 THEN FLONS = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLATS) EQ 0 THEN FLATS = []
  
  IF N_ELEMENTS(MAP_OUT) EQ 0 THEN RETURN, 'ERROR: MAP_OUT must be either L3B1, L3B2, L3B4 or L3B9'
  
  FILE  = !S.MAPINFO + 'NOAA5KM-PXY_7200_3600-2'+MAP_OUT+'.SAV'
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY

  CASE STRUPCASE(MAP_OUT) OF
    'L3B9': BINS = BINS9
    'L3B5': BINS = BINS5
    'L3B4': BINS = BINS4
    'L3B2': BINS = BINS2
    'L3B1': BINS = BINS1
    ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B2, L3B4 L3B5, OR L3B9'
  ENDCASE
  
  L3B = FLTARR(NBINS) & L3B[*] = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF ~FILE_TEST(FILE) THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF N_ELEMENTS(BINS)  EQ 0 THEN BINS = IDL_RESTORE(FILE)
  IF N_ELEMENTS(BINS9) EQ 0 AND MAP_OUT EQ 'L3B9' THEN BINS9 = BINS ; Save BINS9 in common for subsequent calls
  IF N_ELEMENTS(BINS5) EQ 0 AND MAP_OUT EQ 'L3B5' THEN BINS5 = BINS ; Save BINS5 in common for subsequent calls
  IF N_ELEMENTS(BINS4) EQ 0 AND MAP_OUT EQ 'L3B4' THEN BINS4 = BINS ; Save BINS4 in common for subsequent calls
  IF N_ELEMENTS(BINS2) EQ 0 AND MAP_OUT EQ 'L3B2' THEN BINS2 = BINS ; Save BINS2 in common for subsequent calls
  IF N_ELEMENTS(BINS1) EQ 0 AND MAP_OUT EQ 'L3B1' THEN BINS1 = BINS ; Save BINS1 in common for subsequent calls


  SZ = SIZEXYZ(ARRAY,PX=PX,PY=PY)
  IF PX NE 7200 AND PY NE 3600 THEN BEGIN
    IF N_ELEMENTS(LATS) EQ 0 OR N_ELEMENTS(LONS) EQ 0 THEN MESSAGE, 'ERROR: Must provide either a full 7200x3600 input array or LONS and LATS variables'
    IF FLONS EQ [] THEN FLONS = IDL_RESTORE(!S.MAPINFO + 'NOAA5KM-PXY_7200_3600-LON.SAV')
    IF FLATS EQ [] THEN FLATS = IDL_RESTORE(!S.MAPINFO + 'NOAA5KM-PXY_7200_3600-LAT.SAV')
    
    OKLON = WHERE_MATCH(FLONS[*,0],LONS,COMPLEMENT=CLONS)
    OKLAT = WHERE_MATCH(FLATS[0,*],LATS,COMPLEMENT=CLATS)

    LL = BYTARR(7200,3600)
    LL[*,OKLON] = 1
    LL[OKLAT,*] = LL[OKLAT,*]+1
            
    SUBS = WHERE(LL EQ 2, COUNT)
    FARR = BYTARR(7200,3600)
    IF COUNT GT 0 THEN FARR[SUBS] = ARRAY
  ENDIF ELSE FARR = ARRAY
  
  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF R[N+1]-R[N] GE 1 THEN L3B[N] = MEAN(FARR[R[R[N]:R[N+1]-1]],/NAN)
  ENDFOR

  BINS_OUT = MAPS_L3B_BINS(MAP_OUT)


  L3B[WHERE(FINITE(L3B) EQ 0)] = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B[0:*] = L3B
  GONE, L3B
  RETURN, _L3B
  



END ; ***************** End of MAPS_SEASCAPE_2BIN *****************
