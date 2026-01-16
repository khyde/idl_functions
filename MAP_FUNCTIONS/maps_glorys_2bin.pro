; $ID:	MAPS_GLORYS_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION MAPS_GLORYS_2BIN, ARRAY, MAP_OUT, MAP_IN=MAP_IN, LONS=LONS, LATS=LATS, INIT=INIT, BINS_OUT=BINS_OUT

;+
; NAME:
;   MAPS_GLORYS_2BIN
;
; PURPOSE:
;   This program converts a GLORYS (9KM) subset array to a L3B array
;
; CATEGORY:
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_GLORYS_2BIN($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on January 16, 2025 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jun 02, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_GLORYS_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON MAPS_GLORYS_2BIN, BINS9, BINS4, BINS2, BINS1
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS9) THEN BINS9 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS4) THEN BINS4 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS2) THEN BINS2 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS1) THEN BINS1 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(FLONS) THEN FLONS = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(FLATS) THEN FLATS = []

  PX = 4320 & PY = 2041
  PXY = 'PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY
  
  ;SZ = SIZEXYZ(GLORYS)
  ;IF SZ.PX NE 373 OR SZ.PY NE 311 THEN RETURN, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE 373 X 311'
  IF ~N_ELEMENTS(MAP_OUT) THEN RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B4 OR L3B9'

  FILE  = !S.MAPINFO + 'GLORYS-'+PXY+'-2'+MAP_OUT+'.SAV'
  LATFILE = !S.MAPINFO + 'GLORYS-' + PXY + '-LAT.SAV'
  LONFILE = !S.MAPINFO + 'GLORYS-' + PXY + '-LON.SAV'
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY

  CASE STRUPCASE(MAP_OUT) OF
    'L3B9': BINS  = BINS9
    'L3B4': BINS  = BINS4
    'L3B2': BINS  = BINS2
    'L3B1': BINS  = BINS1
    ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B4 OR L3B9'
  ENDCASE

  L3B = FLTARR(NBINS) & L3B[*] = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF EXISTS(FILE) EQ 0 THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF ~N_ELEMENTS(BINS) THEN BINS = IDL_RESTORE(FILE)
  IF ~N_ELEMENTS(BINS9) AND MAP_OUT EQ 'L3B9' THEN BINS9 = BINS ; Save BINS9 in common for subsequent calls
  IF ~N_ELEMENTS(BINS4) AND MAP_OUT EQ 'L3B4' THEN BINS4 = BINS ; Save BINS4 in common for subsequent calls
  IF ~N_ELEMENTS(BINS2) AND MAP_OUT EQ 'L3B2' THEN BINS2 = BINS ; Save BINS2 in common for subsequent calls
  IF ~N_ELEMENTS(BINS1) AND MAP_OUT EQ 'L3B1' THEN BINS1 = BINS ; Save BINS1 in common for subsequent calls

  SZ = SIZEXYZ(ARRAY,PX=APX,PY=APY)
  IF APX NE PX AND APY NE PY THEN BEGIN
    IF N_ELEMENTS(LATS) EQ 0 OR N_ELEMENTS(LONS) EQ 0 THEN MESSAGE, 'ERROR: Must provide either a full 17280x34560 input array or LONS and LATS variables'

    IF N_ELEMENTS(FLONS) EQ 0 THEN FLONS = IDL_RESTORE(LONFILE)
    IF N_ELEMENTS(FLATS) EQ 0 THEN FLATS = IDL_RESTORE(LATFILE)

    OKLON = WHERE_MATCH(ROUNDS(FLOAT(FLONS[*,0]),2),ROUNDS(FLOAT(LONS),2),COMPLEMENT=CLONS,CTLON)
    OKLAT = WHERE_MATCH(ROUNDS(FLOAT(FLATS[0,*]),2),ROUNDS(FLOAT(LATS),2),COMPLEMENT=CLATS,CTLAT)

    LL = BYTARR(PX,PY)
    LL[OKLON,*] = 1
    LL[*,OKLAT] = LL[*,OKLAT]+1

    SUBS = WHERE(LL EQ 2, COUNT)
    FARR = FLTARR(PX,PY) & FARR[*] = MISSINGS(FARR)
    IF COUNT GT 0 THEN FARR[SUBS] = ARRAY
  ENDIF ELSE FARR = ARRAY

  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF N+1 GE N_ELEMENTS(R) THEN CONTINUE ; Temporary fix to try and figure out why this is crashing here
    IF R[N+1]-R[N] GE 1 THEN BEGIN
      L3B[N] = MEAN(FARR[R[R[N]:R[N+1]-1]],/NAN)
      if finite(l3b[n]) then stop
    ENDIF
  ENDFOR

  L3B[WHERE(FINITE(L3B) EQ 0)] = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B[0:*] = L3B
  GONE, L3B

  BINS_OUT = MAPS_L3B_BINS(MAP_OUT)
  IF KEYWORD_SET(MAP_SUBSET) THEN BEGIN
    IF VALIDS('MAPS',MAP_SUBSET) EQ '' THEN MESSAGE, 'ERROR: ' + MAP_SUBSET + ' is not a "VALID" map.'
    L3BSUB = MAPS_L3B_SUBSET(_L3B, INPUT_MAP=MAP_OUT, SUBSET_MAP=MAP_SUBSET, SUBSET_BINS=BINS_OUT)
    _L3B = L3BSUB
  ENDIF

  RETURN, _L3B


END ; ***************** End of MAPS_ACSPO_2BIN *****************
