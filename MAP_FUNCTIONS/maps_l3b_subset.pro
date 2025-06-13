; $ID:	MAPS_L3B_SUBSET.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION MAPS_L3B_SUBSET, ARRAY, INPUT_MAP=INPUT_MAP, $
                            LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX, SUBSET_MAP=SUBSET_MAP, $
                            SUBSET_BINS=SUBSET_BINS, OCEAN_BINS=OCEAN_BINS,$
                            INIT=INIT

;+
; NAME:
;   MAPS_L3B_SUBSET
;
; PURPOSE:
;   Subset a L3B/GS map array using either a standard map or input LON/LAT bounds
;
; CATEGORY:
;   MAPS_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_L3B_SUBSET(ARRAY, INPUT_MAP=INPUT_MAP)
;
; REQUIRED INPUTS:
;   ARRAY.......... A data array with the deminsions of the INPUT_MAP
;   INPUT_MAP...... The name of the "valid" INPUT_MAP
;
; OPTIONAL INPUTS:
;   LONMIN......... The minimum longitude if subsetting the input array
;   LONMAX......... The maximum longitude if subsetting the input array
;   LATMIN......... The minimum latitude if subsetting the input array
;   LATMAX......... The maximum latitude if subsetting the input array
;   SUBSET_MAP..... A map name to subset the input array
;
; KEYWORD PARAMETERS:
;   None
;   
; OUTPUTS:
;   OUTPUT.......... A subset array
;
; OPTIONAL OUTPUTS:
;   SUBSET_BINS..... The L3B BIN numbers for the subset
;   OCEAN_BINDS..... The L3B BIN numbers for the subset that are in the ocean (excludes land pixels)
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
;   M = MAPS_L3B_SUBSET(READ_LANDMASK('L3B9'),INPUT_MAP='GS9',SUBSET_MAP='NEC',SUBSET_BINS=SUBSET_BINS)
;   M = MAPS_L3B_SUBSET(READ_LANDMASK('L3B9'),INPUT_MAP='L3B9',SUBSET_MAP='NEC',SUBSET_BINS=SUBSET_BINS)
;   M = MAPS_L3B_SUBSET(READ_LANDMASK('L3B9'),INPUT_MAP='L3B9',LONMIN=-82.5,LONMAX=-51.5,LATMIN=22.5,LATMAX=48.5,SUBSET_BINS=SUBSET_BINS)
;
; NOTES:
;   Information on NASA's integerized sinusoidal binning scheme - https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 14, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Feb 14, 2022 - KJWH: Initial code written
;   May 12, 2022 - KJWH: Updated the code so that an L3B map is returned if the input map is L3B
;   Nov 15, 2022 - KJWH: Added OCEAN_BINS as an optional output to get just the subset bins that are in the ocean
;   Nov 16, 2022 - KJWH: Now returning a 2D array if the input map is L3B (1,N_BINS)
;   May 12, 2023 - KJWH: Fixed error with the output BINS (+1 was added twice)
;                                       Now including the coastal pixels in the OCEAN bins
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_L3B_SUBSET'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON MAPS_L3B_SUBSET_, L3BSUB_STRUCT, STRUCT_SUBSET
  IF KEY(INIT) THEN L3SUB_STRUCT = []
  
  ; ===> Add a dummy tag to initialize the STRUCT_SUBSET structure
  IF ~N_ELEMENTS(L3SUB_STRUCT) OR KEYWORD_SET(INIT) THEN L3SUB_STRUCT=CREATE_STRUCT('_','')
  
  ; ===> Get the size of the input map and data array
  MSL = MAPS_SIZE(INPUT_MAP,PX=PXL,PY=PYL)
  SZ  = SIZEXYZ(ARRAY, PX=PXD, PY=PYD)
  
  ; ===> If the input data are L3B, then convert to a GS map
  IF IS_L3B(INPUT_MAP) THEN BEGIN
    IF PXL NE PXD AND PYL NE PYD AND ~N_ELEMENTS(BINS) THEN MESSAGE, 'ERROR: If not a full L3B array then must provide BIN numbers'
    IF PYL NE PYD THEN LARR = MAPS_L3B_2ARR(ARRAY,MP=INPUT_MAP,BINS=BINS) ELSE LARR=ARRAY 
    GARR = MAPS_L3BGS_SWAP(LARR)
    _INPUT_MAP=MAPS_L3B_GET_GS(INPUT_MAP)
  ENDIF ELSE BEGIN
    IF PXL NE PXD AND PYL NE PYD THEN MESSAGE, 'ERROR: The input array size does not match the GS map size.'
    GARR = ARRAY
  ENDELSE
  
  ; ===> Get the min/max lon/lat from the subset map (if provided)
  IF N_ELEMENTS(SUBSET_MAP) EQ 1 THEN BEGIN
    MAPS_SET, SUBSET_MAP
    S=MAPS_LL_BOX()  ; Get the min and max lons and lats for a given map projection
    ZWIN
    LONMIN = S.LONMIN & LONMAX = S.LONMAX
    LATMIN = S.LATMIN & LATMAX = S.LATMAX
  ENDIF 
  
  ; ===> Create the tag name for the COMMON structure
  LLSTRING = _INPUT_MAP+'_'+STRJOIN(REPLACE(NUM2STR(ABS([LONMIN,LONMAX,LATMIN,LATMAX]),DECIMALS=2),'.',''),'_')  

  ; ===> Look for the tag name in the structure, if not found, get the subscripts within the lon/lat range
  OK_TAG = WHERE(TAG_NAMES(L3SUB_STRUCT) EQ LLSTRING,COUNT)
  IF COUNT EQ 0 THEN BEGIN
    ; ===> Get the lons and lats of the input map
    LL = MAPS_2LONLAT(_INPUT_MAP,LONS=LONS,LATS=LATS)
    
    ; ===> Make and NaN LONS and LATS a real number, -999999
    LONS[WHERE(NAN_2INFINITY(LONS) EQ MISSINGS(LONS),/NULL)] = -99999.0D  
    LATS[WHERE(NAN_2INFINITY(LATS) EQ MISSINGS(LATS),/NULL)] = -99999.0D 

    ; ===> Find where the pixels with in the lon/lat range of the subset map with a little buffer 
    OKLONS = WHERE(LONS GT LONMIN -1.0 AND LONS LT LONMAX + 1) 
    OKLATS = WHERE(LATS GT LATMIN -1.0 AND LATS LT LATMAX + 1) 

    ; ===> Create a blank map and find the pixels within the lon/lat range
    BLK = MAPS_BLANK(_INPUT_MAP,FILL=-1.0D) & BLK[OKLONS] = 1.0D & BLK[OKLATS] = BLK[OKLATS] + 1.0D
    
    ; ===> Find just the "ocean" pixels
    LM = READ_LANDMASK(_INPUT_MAP,/STRUCT)
    OCE = BLK 
    OCE[LM.OCEAN] = OCE[LM.OCEAN] + 1.0D   
    OCE[LM.COAST] = OCE[LM.COAST] + 1.0D    
    OCESET = WHERE(OCE GE 3, COMPLEMENT=COMP)
    OCEAN_BINS = OCESET 
    
    ; ===> Find the pixels to subset (where BLK equals 2), make the non-subset pixles -1 and create and array of bins
    SUBSET = WHERE(BLK EQ 2, COMPLEMENT=COMP) & BLK[COMP] = -1     & BLK[SUBSET] = DINDGEN(N_ELEMENTS(SUBSET))
    BINS = SUBSET
    XY = IMAGE_PXPY(BLK)
    
    ; ===> Find the first and last of the subset pixels and get the subscript for the min/max lon/lat
    OK = WHERE(BLK EQ 0,COUNT)        & LONMIN = XY.X[OK] & LATMIN = XY.Y[OK] & IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than 1 lonmin found'
    OK = WHERE(BLK EQ MAX(BLK),COUNT) & LONMAX = XY.X[OK] & LATMAX = XY.Y[OK] & IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than 1 lonmax found'
    L3SUB_STRUCT = CREATE_STRUCT(L3SUB_STRUCT,LLSTRING,CREATE_STRUCT('LL_BOUNDS',LLSTRING,'SUBSET_BINS',BINS,'OCEAN_BINS',OCEAN_BINS,'LONMIN',LONMIN,'LONMAX',LONMAX,'LATMIN',LATMIN,'LATMAX',LATMAX))
  ENDIF 
  
  ; ===> Find the tag in the COMMON structure
  SS = L3SUB_STRUCT.(WHERE(TAG_NAMES(L3SUB_STRUCT) EQ LLSTRING,/NULL))
  
  ; ===> Get the subset bins (an optional output)
  SUBSET_BINS = SS.SUBSET_BINS
  OCEAN_BINS  = SS.OCEAN_BINS
  
  ; ===> Subset the data array
  IF IS_L3B(INPUT_MAP) THEN BEGIN
    TEMP_ARR = MAPS_BLANK(_INPUT_MAP,FILL=0)
    TEMP_ARR[SUBSET_BINS] = 1
    TEMP_ARR[OCEAN_BINS] = 2
    TEMP_L3B = MAPS_L3BGS_SWAP(TEMP_ARR)
    SUBSET_BINS = WHERE(TEMP_L3B GE 1) + 1 ; BIN numbers start at 1
    OCEAN_BINS = WHERE(TEMP_L3B EQ 2) + 1 
    ARR = ARRAY[WHERE(TEMP_L3B GE 1)]  
    TMP = FLTARR(1,N_ELEMENTS(ARR))
    TMP[0,*] = ARR
    ARR = TMP 
  ENDIF ELSE ARR = GARR[SS.LONMIN:SS.LONMAX,SS.LATMIN:SS.LATMAX]

  RETURN, ARR

END ; ***************** End of MAPS_L3B_SUBSET *****************
