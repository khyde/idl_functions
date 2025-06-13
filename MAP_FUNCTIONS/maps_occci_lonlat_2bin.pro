; $ID:	MAPS_OCCCI_LONLAT_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION MAPS_OCCCI_LONLAT_2BIN, ARRAY, MAP_OUT, MAP_IN=MAP_IN, LONS=LONS, LATS=LATS, INIT=INIT

;+
; NAME:
;   MAPS_OCCCI_LONLAT_2BIN
;
; PURPOSE:
;   This program converts a OCCCI-LONLAT (1KM or 4KM) subset array to a L3B array
;
; CATEGORY:
;   MAPS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_OCCCI_LONLAT_2BIN(ARRAY)
;
; REQUIRED INPUTS:
;   ARRAY.......... The input data array
;   SUBSET......... The name of the subset map (of the input array)
;   MAP_IN......... The name input map type (1KM or 4KM)
;   MAP_OUT........ The name of the output map
;
; OPTIONAL INPUTS:
;   LONS........... Longitude array if the input is not a full (e.g. 17280x34560/1km) array
;   LATS........... Latitude array if the input is not a full (e.g. 17280x34560/1km) array
;
; KEYWORD PARAMETERS:
;   INIT............ Reinitialize the COMMON block
;
; OUTPUTS:
;   OUTPUT.......... A remapped array
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   MAPS_OCCCI_LONLAT_2BIN_, BINS9, BINS4, BINS2, BINS1 
;
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
;   The OCCCI1KM-xxx_SUBSET_px_py_2L3B#.SAV files were created using MAPS_L3B_SUBS
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 15, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 24, 2021 - KJWH: Initial code written
;   Jun 05, 2023 - KJWH: Changed name from MAPS_OCCCI1KM_2BIN to MAPS_OCCCI_LONLAT_2BIN
;                        Added the ability to work with 1KM files as well
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_OCCCI_LONLAT_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON MAPS_OCCCI_LONLAT_2BIN_, BINS9_1KM, BINS4_1KM, BINS2_1KM, BINS1_1KM, FLONS_1KM, FLATS_1KM, $
                                  BINS9_4KM, BINS4_4KM, BINS2_4KM, BINS1_4KM, FLONS_4KM, FLATS_4KM
  
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS9_1KM) EQ 0 THEN BINS9_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS4_1KM) EQ 0 THEN BINS4_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS2_1KM) EQ 0 THEN BINS2_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS1_1KM) EQ 0 THEN BINS1_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLONS_1KM) EQ 0 THEN FLONS_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLATS_1KM) EQ 0 THEN FLATS_1KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS9_4KM) EQ 0 THEN BINS9_4KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS4_4KM) EQ 0 THEN BINS4_4KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS2_4KM) EQ 0 THEN BINS2_4KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(BINS1_4KM) EQ 0 THEN BINS1_4KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLONS_4KM) EQ 0 THEN FLONS_4KM = []
  IF KEYWORD_SET(INIT) OR N_ELEMENTS(FLATS_4KM) EQ 0 THEN FLATS_4KM = []
  
  IF N_ELEMENTS(MAP_OUT) EQ 0 THEN RETURN, 'ERROR: MAP_OUT must be either L3B1, L3B2, L3B4 or L3B9'

  CASE MAP_IN OF
    '1KM': BEGIN & PX = 34560 & PY = 17280 & END
    '4KM': BEGIN & PX = 8640  & PY = 4320 & END
  ENDCASE

   
  PXY = 'PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)   
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY

  CASE STRUPCASE(MAP_IN) OF
    '1KM': BEGIN
      CASE STRUPCASE(MAP_OUT) OF 
        'L3B9': BINS = BINS9_1KM
        'L3B4': BINS = BINS4_1KM
        'L3B2': BINS = BINS2_1KM
        'L3B1': BINS = BINS1_1KM
        ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B2, L3B4 OR L3B9'
      ENDCASE
    END  
    '4KM': BEGIN
      CASE STRUPCASE(MAP_OUT) OF
        'L3B9': BINS = BINS9_4KM
        'L3B4': BINS = BINS4_4KM
        'L3B2': BINS = BINS2_4KM
        'L3B1': BINS = BINS1_4KM
        ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B2, L3B4 OR L3B9'
      ENDCASE 
    END     
  ENDCASE ; MAP_IN
    
  FILE    = !S.MAPINFO + 'OCCCI-' + MAP_IN + '-' + PXY + '-2' + MAP_OUT+'.SAV'
  LATFILE = !S.MAPINFO + 'OCCCI-' + MAP_IN + '-' + PXY + '-LAT.SAV'
  LONFILE = !S.MAPINFO + 'OCCCI-' + MAP_IN + '-' + PXY + '-LON.SAV'
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY

  L3B = FLTARR(NBINS) & L3B[*] = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF ~FILE_TEST(FILE) THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF N_ELEMENTS(BINS)  EQ 0 THEN BINS = IDL_RESTORE(FILE)
  IF N_ELEMENTS(BINS9_1KM) EQ 0 AND MAP_OUT EQ 'L3B9' AND MAP_IN EQ '1KM' THEN BINS9_1KM = BINS ; Save BINS9 in common for subsequent calls
  IF N_ELEMENTS(BINS4_1KM) EQ 0 AND MAP_OUT EQ 'L3B4' AND MAP_IN EQ '1KM' THEN BINS4_1KM = BINS ; Save BINS4 in common for subsequent calls
  IF N_ELEMENTS(BINS2_1KM) EQ 0 AND MAP_OUT EQ 'L3B2' AND MAP_IN EQ '1KM' THEN BINS2_1KM = BINS ; Save BINS2 in common for subsequent calls
  IF N_ELEMENTS(BINS1_1KM) EQ 0 AND MAP_OUT EQ 'L3B1' AND MAP_IN EQ '1KM' THEN BINS1_1KM = BINS ; Save BINS1 in common for subsequent calls
  IF N_ELEMENTS(BINS9_4KM) EQ 0 AND MAP_OUT EQ 'L3B9' AND MAP_IN EQ '4KM' THEN BINS9_4KM = BINS ; Save BINS9 in common for subsequent calls
  IF N_ELEMENTS(BINS4_4KM) EQ 0 AND MAP_OUT EQ 'L3B4' AND MAP_IN EQ '4KM' THEN BINS4_4KM = BINS ; Save BINS4 in common for subsequent calls
  IF N_ELEMENTS(BINS2_4KM) EQ 0 AND MAP_OUT EQ 'L3B2' AND MAP_IN EQ '4KM' THEN BINS2_4KM = BINS ; Save BINS2 in common for subsequent calls
  IF N_ELEMENTS(BINS1_4KM) EQ 0 AND MAP_OUT EQ 'L3B1' AND MAP_IN EQ '4KM' THEN BINS1_4KM = BINS ; Save BINS1 in common for subsequent calls

  SZ = SIZEXYZ(ARRAY,PX=APX,PY=APY)
  IF APX NE PX AND APY NE PY THEN BEGIN
    IF N_ELEMENTS(LATS) EQ 0 OR N_ELEMENTS(LONS) EQ 0 THEN MESSAGE, 'ERROR: Must provide either a full 17280x34560 input array or LONS and LATS variables'

    IF N_ELEMENTS(FLONS) EQ 0 THEN FLONS = IDL_RESTORE(LONFILE)
    IF N_ELEMENTS(FLATS) EQ 0 THEN FLATS = IDL_RESTORE(LATFILE)

    OKLON = WHERE_MATCH(FLOAT(FLONS[*,0]),FLOAT(LONS),COMPLEMENT=CLONS,CTLON)
    OKLAT = WHERE_MATCH(FLOAT(FLATS[0,*]),FLOAT(LATS),COMPLEMENT=CLATS,CTLAT)

    LL = BYTARR(PX,PY)
    LL[OKLON,*] = 1
    LL[*,OKLAT] = LL[*,OKLAT]+1

    SUBS = WHERE(LL EQ 2, COUNT)
    FARR = FLTARR(PX,PY) & FARR[*] = MISSINGS(FARR)
    IF COUNT GT 0 THEN FARR[SUBS] = ARRAY
  ENDIF ELSE FARR = ARRAY

  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF R[N+1]-R[N] GE 1 THEN L3B[N] = MEAN(FARR[R[R[N]:R[N+1]-1]],/NAN)
  ENDFOR

  L3B[WHERE(FINITE(L3B) EQ 0)] = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B[0:*] = L3B
  GONE, L3B
  RETURN, _L3B





END ; ***************** End of MAPS_OCCCI1KM_2BIN *****************
