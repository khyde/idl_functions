; $ID:	MAPS_L3BGS_SWAP.PRO,	2020-06-26-15,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3BGS_SWAP, ARR, L3BGS_MAP=L3BGS_MAP, $
                          LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX,MAP_SUBSET=MAP_SUBSET,$
                          GSSUBS=GSSUBS, L3SUBS=L3SUBS, L3OCEAN_SUBS=L3OCEAN_SUBS, SUBSET_STRUCT=SUBSET_STRUCT, $
                          INIT=INIT, VERBOSE=VERBOSE
;+
; PURPOSE:  Convert a L3B map array or a GS map array into its corresponding GS or L3B equivalent 
;           [L3B9 --> GS9, L3B4 --> GS4,  L3B2 -->GS2   L3B1 --> GS1 L3B10 --> GS10  or
;            GS9 --> L3B9,  GS4 --> L3B4  GS2 --> L3B2  GS1 --> L3B1 GS10 -->  L3B10
;
; CATEGORY: 
;   MAPS_ FAMILY
;
;
; REQUIRED INPUTS: 
;   ARR.......... A L3B or GS data array
;   
; OPTIONAL INPUTS
;   L3BGS_MAP.... The name of the input data array map
;   LONMIN......... The minimum longitude if subsetting the input array
;   LONMAX......... The maximum longitude if subsetting the input array
;   LATMIN......... The minimum latitude if subsetting the input array
;   LATMAX......... The maximum latitude if subsetting the input array
;   SUBSET_MAP..... A map name to subset the input array
;   
;
; KEYWORD PARAMETERS:  
;   INIT........... Reinitialize the COMMON block
;   VERBOSE........ Print program progress
;
; OUTPUTS: 
;   The corresponding L3B/GS array 
;
; OPTIONAL OUTPUTS:
;   GSSUBS
;   L3SUBS
;   L3OCEAN_SUBS
;   SUBSET_STRUCT
; 
; COMMON BLOCKS:
;   MAPS_L3BGS_SWAP_ to hold the "swap" information for each L3B/GS pair
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
; 
; EXAMPLES:
;   HELP,MAPS_L3BGS_SWAP(MAPS_BLANK('L3B9'),/VERBOSE)
;   HELP,MAPS_L3BGS_SWAP(MAPS_BLANK('L3B4'),/VERBOSE)
;   HELP,MAPS_L3BGS_SWAP(MAPS_BLANK('L3B10'),/VERBOSE)
;   HELP,MAPS_L3BGS_SWAP(MAPS_BLANK('GS9'),/VERBOSE);
;   HELP,MAPS_L3BGS_SWAP(MAPS_BLANK('GS4'),/VERBOSE);
;
; COPYRIGHT:
; Copyright (C) 2017, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on Mar 04, 2017 by Jay O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
; 
; MODIFICATION HISTORY:
;   MAR 04, 2017 - JEOR: Initial code written
;   MAR 05, 2017-  JEOR: Tested 5 examples above
;   MAR 28, 2017 - KJWH: Changed the name from MAPS_SWAP_L3BGS to MAPS_L3BGS_SWAP so that it is in the MAPS_L3B family
;   FEB 15, 2018 - KJWH: Added COMMON structure to for the swamp structure
;   JUL 29, 2019 - KJWH: Changed the number of L3B1 bins from 380187134 to 380187138 and
;                                              L3B2 bins from 95046854 to 95046858 to be compatible with the new binner in SeaDAS 7.5.3
;   AUG 11, 2022 - KJWH: Updated the COMMON structure to include the L3B map name in the tag and the L3B and GS maps in the structure
;   AUG 17, 2023 - KJWH: Fixed the output subset subscripts.  Now returning both the GS subscripts and L3B subscripts
;   AUG 01, 2024 - KJWH: Added the ability to subset by LON/LAT and not just a predefined map
;                        Updated documentation
;                        Added COMPILE_OPT IDL2
;-
; 
; ****************************************************************************************************

  ROUTINE = 'MAPS_L3BGS_SWAP'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  COMMON MAPS_L3BGS_SWAP_, L3BGS_STRUCT, STRUCT_SUBSET
  IF KEYWORD_SET(INIT) THEN BEGIN & L3BGS_STRUCT = [] & STRUCT_SUBSET = [] & ENDIF
  
  MI = SIZEXYZ(ARR,PX=PX,PY=PY)
  IF MI.N_DIMENSIONS EQ 1 AND PY EQ 0 THEN PY = PX

;CCCCCCCCCCCCCCCCCCCCCCCCCCC
  CASE (PY) OF
    412:       NUM = '10'
    5940422:   NUM = '9'
    16501158:  NUM = '5' 
    23761676:  NUM = '4'
    95046858:  NUM = '2'
    380187138: NUM = '1'
    18:        NUM = '10'     
    2160:      NUM = '9'
    3600:      NUM = '5'
    4320:      NUM = '4'
    8640:      NUM = '2'  
    17280:     NUM = '1'
    ELSE: MESSAGE,' ERROR: INPUT ARRAY IS NOT A L3B OR GS MAP'
  ENDCASE
;CCCCCCCCCCCCCCCCCCCCCCCCCCC
  
; ===> GET THE SIZE THE L3B AND GS MAPS  
  L3B = 'L3B'+NUM & MSL = MAPS_SIZE(L3B, PX=PXL, PY=PYL, /STRING)
  GS  = 'GS' +NUM & MGS = MAPS_SIZE(GS,  PX=PXG, PY=PYG, /STRING)
  
; ===> CREATE THE XPYP SWAP FILE NAME 
  MP_TXT = L3B +'_'+ PXL + '_'  + PYL + '_' +  GS + '_'+ PXG + '_' + PYG
  FILE = !S.MAPINFO + 'XPYP-' + MP_TXT + '.SAV'
  
  IF ANY(L3BGS_STRUCT) THEN BEGIN
    OK = WHERE(TAG_NAMES(L3BGS_STRUCT) EQ MP_TXT, COUNT_MAP_OUT)
    IF COUNT_MAP_OUT EQ 1 THEN S = L3BGS_STRUCT.(OK) ELSE S = []
  ENDIF ELSE S = []
  
; ===> READ XPYP SWAP FILE
  IF S EQ [] THEN BEGIN
    IF KEY(VERBOSE) THEN PFILE, FILE, /R
    IF EXISTS(FILE) EQ 0 THEN S = MAPS_L3B_2GS(L3B, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE) ELSE S = IDL_RESTORE(FILE)
    IF L3BGS_STRUCT NE [] THEN BEGIN
      IF COUNT_MAP_OUT EQ 0 THEN L3BGS_STRUCT = CREATE_STRUCT(L3BGS_STRUCT,MP_TXT,S)
    ENDIF ELSE L3BGS_STRUCT = CREATE_STRUCT(MP_TXT,S)
  ENDIF  
  
  IF PY EQ MSL.PY THEN BEGIN ; IF THE INPUT IS A L3B ARRAY, USE THE GS SUBSCRIPTS TO CONVERT IT TO A GS MAP
    A = ARR[S.XP_L3_2GS,S.YP_L3_2GS]
    A[S.GS_EDGES] = MISSINGS(A) ; MAKE THE EDGES OF THE ARRAY MISSINGS
    IF KEYWORD_SET(MAP_SUBSET) OR LONMIN NE [] THEN LL = MAPS_2LONLAT(GS,LONS=LONS,LATS=LATS)
    L3BGS_MAP = GS
  ENDIF ELSE BEGIN ; IF THE INPUT IS A GS ARRAY
    A = ARR[S.YP_GS_2L3]
    IF KEYWORD_SET(MAP_SUBSET) THEN LL = MAPS_2LONLAT(L3B,LONS=LONS,LATS=LATS)
    L3BGS_MAP = L3B
  ENDELSE  
  
  ; ===> Get the min/max lon/lat from the subset map (if provided)
  MAP_TAG = []
  IF N_ELEMENTS(MAP_SUBSET) EQ 1 OR N_ELEMENTS(LONMIN) EQ 1 THEN BEGIN
    IF ~N_ELEMENTS(STRUCT_SUBSET) OR KEYWORD_SET(INIT) THEN STRUCT_SUBSET=CREATE_STRUCT('_','') ; ; ===> Create a blank structure to the COMMON STRUCT_MAPS_REMAP structure
    IF N_ELEMENTS(MAP_SUBSET) EQ 1 THEN MAP_TAG = MAP_SUBSET + '_' + L3B ELSE MAP_TAG = 'LONLAT_'+STRJOIN(REPLACE(NUM2STR(ABS([LONMIN,LONMAX,LATMIN,LATMAX]),DECIMALS=2),'.',''),'_') + '_' + L3B
    OK_TAG = WHERE(TAG_NAMES(STRUCT_SUBSET) EQ MAP_TAG,COUNT) ; Look for tag in the structure
    IF COUNT EQ 0 THEN BEGIN
    
      IF N_ELEMENTS(MAP_SUBSET) EQ 1 THEN BEGIN
        MAPS_SET, MAP_SUBSET
        S=MAPS_LL_BOX()  ; Get the min and max lons and lats for a given map projection
        ZWIN
        LONMIN = S.LONMIN & LONMAX = S.LONMAX
        LATMIN = S.LATMIN & LATMAX = S.LATMAX
      ENDIF ELSE MAP_SUBSET = 'LONLAT'
      
      IF LONMIN EQ [] OR LONMAX EQ [] OR LATMIN EQ [] OR LATMAX EQ [] THEN MESSAGE, 'ERROR: Min and max Lon and Lat are missing'  
      
      ; ===> Make NaN LONS and LATS a real number, -999999
      LONS[WHERE(NAN_2INFINITY(LONS) EQ MISSINGS(LONS),/NULL)] = -99999.0D & OKLONS = WHERE(LONS GT LONMIN -1.0 AND LONS LT LONMAX + 1) & SUBLONS = LONS[OKLONS]
      LATS[WHERE(NAN_2INFINITY(LATS) EQ MISSINGS(LATS),/NULL)] = -99999.0D & OKLATS = WHERE(LATS GT LATMIN -1.0 AND LATS LT LATMAX + 1) & SUBLATS = LATS[OKLATS]
        
      ; ===> Create a blank map and find the pixels within the lon/lat range
      BLK = MAPS_BLANK(L3BGS_MAP,FILL=-1.0D) & BLK[OKLONS] = 1.0D & BLK[OKLATS] = BLK[OKLATS] + 1.0D
      
      ; ===> Find just the "ocean" pixels
      LM = READ_LANDMASK(L3BGS_MAP,/STRUCT)
      OCE = BLK
      OCE[LM.OCEAN] = OCE[LM.OCEAN] + 1.0D
      OCE[LM.COAST] = OCE[LM.COAST] + 1.0D
      L3OCEAN_SUBS = WHERE(MAPS_L3BGS_SWAP(OCE) GE 3, COMPLEMENT=COMP)
            
      ; ===> Find the pixels to subset (where BLK equals 2), make the non-subset pixles -1 and create and array of bins
      SUBSET = WHERE(BLK EQ 2, COMPLEMENT=COMP) & BLK[COMP] = -1 & BLK[SUBSET] = DINDGEN(N_ELEMENTS(SUBSET))
      L3SUBS = WHERE(MAPS_L3BGS_SWAP(BLK) NE -1)
      XY = IMAGE_PXPY(BLK)
      
      ; ===> Find the first and last of the subset pixels and get the subscript for the min/max lon/lat
      OK = WHERE(BLK EQ 0,COUNT)        & LONMIN = XY.X[OK] & LATMIN = XY.Y[OK] & IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than 1 lonmin found'
      OK = WHERE(BLK EQ MAX(BLK),COUNT) & LONMAX = XY.X[OK] & LATMAX = XY.Y[OK] & IF COUNT GT 1 THEN MESSAGE, 'ERROR: More than 1 lonmax found'
      STRUCT_SUBSET = CREATE_STRUCT(STRUCT_SUBSET,MAP_TAG,CREATE_STRUCT('MAP',MAP_SUBSET,'GSMAP',GS,'L3BMAP',L3B,'GSSUBS',SUBSET,'L3SUBS',L3SUBS,'L3OCEAN_SUBS',L3OCEAN_SUBS,'LONMIN',LONMIN,'LONMAX',LONMAX,'LATMIN',LATMIN,'LATMAX',LATMAX))
    ENDIF
    SUBSET_STRUCT = STRUCT_SUBSET.(WHERE(TAG_NAMES(STRUCT_SUBSET) EQ MAP_TAG,/NULL))
    L3SUBS = SUBSET_STRUCT.L3SUBS
    GSSUBS = SUBSET_STRUCT.GSSUBS
    L3OCEAN_SUBS = SUBSET_STRUCT.L3OCEAN_SUBS
    IF ~IS_L3B(L3BGS_MAP) THEN A = A[SUBSET_STRUCT.LONMIN:SUBSET_STRUCT.LONMAX,SUBSET_STRUCT.LATMIN:SUBSET_STRUCT.LATMAX] $
                          ELSE A = A[SUBSET_BINS]  
  ENDIF
  
  
  
  RETURN, A
  
END; #####################  END OF ROUTINE ################################
