; $ID:	MAPS_L3B_OCEAN_2BINS.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_OCEAN_2BINS, L3B, MAPP, INIT=INIT
;+
; PURPOSE:  
;   Return the bins for the ocean pixels (based on the LANDMASK) for an L3B array using a "MAP" as a reference
;
; CATEGORY: 
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE:
;   RESULT = MAPS_L3B_OCEAN_2BINS(L3B,MAPP)
;
; REQUIRED INPUTS: 
;   L3B.............. Name of the L3B map (e.g. L3B1, L3B2, L3B4...)
;   MAPP............. Standare non-L3B map name (e.g. NWA, NES, LIS - use MAPS_READ to get a full list) 
;   
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;   INIT............. Reinitializes the COMMON structure
;   
; OUTPUTS:
;   OUTPUT........... An array of bin numbers corresponding to the ocean pixels of the input map
;   
; OPTIONAL OUTPUTS:
;   None
;   
; COMMON BLOCKS:
;   STRUCT_L3_BINS... To hold the BINS for specific input maps
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;   R = MAPS_L3B_OCEAN_2BINS('L3B2','NWA')
;
; NOTES:
;   
;   
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 28, 2020 by Kimberly J. W. Hyde, 'Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce', kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   SEP 28, 2020 - KJWH: Initial code written - adapted from MAPS_OCEAN_BINS
;                        Changed name from MAPS_OCEAN_BINS to MAPS_L3B_OCEAN_2BINS  
;                        Updated documentation
;                        Changed input variable names
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to [] 
;                        Added COMMON structure to hold the output bins  
;                        Added INIT keyword for the COMMON structure
;-
; #########################################################################

  ROUTINE_NAME  = 'MAPS_L3B_OCEAN_2BINS'
  COMPILE_OPT IDL2
  
  COMMON MAPS_OCEAN_BINS_, STRUCT_L3_BINS
  IF NONE(STRUCT_L3_BINS) OR KEY(INIT) THEN STRUCT_L3_BINS=[]

; ===> Check the maps
  IF N_ELEMENTS(L3B)  EQ 1 THEN MAP_IN  = L3B  ELSE MESSAGE, 'ERROR: Must provide an input L3B map'
  IF N_ELEMENTS(MAPP) EQ 1 THEN MAP_OUT = MAPP ELSE MESSAGE, 'ERROR: Must provide an output map'  
  MPS = MAPS_READ([MAP_IN,MAP_OUT])
  IF N_ELEMENTS(MPS) NE 2 THEN MESSAGE, 'ERROR: Either ' + MAP_IN + ' or ' + MAP_OUT + ' is not a valid "map"'   

; ===> Get the MAP SIZE information for both maps  
  MI = MAPS_SIZE(MAP_IN)
  MO = MAPS_SIZE(MAP_OUT)
  
; ===> Create a TAG NAME for the specific MAP_IN/MAP_OUT combo for the COMMON structure
  MAP_TXT = STRUPCASE(MAP_IN)+'_'+NUM2STR(MI.PX)+'_'+NUM2STR(MI.PY)+'_'+STRUPCASE(MAP_OUT)+'_'+NUM2STR(MO.PX)+'_'+NUM2STR(MO.PY)

; ===> If the MAP_TXT exists in the COMMON structure, then return the BINS from the structure
  IF HAS(STRUCT_L3_BINS,MAP_TXT) THEN BEGIN
    OK = WHERE(TAG_NAMES(STRUCT_L3_BINS) EQ MAP_TXT,COUNT)
    IF COUNT EQ 1 THEN RETURN, STRUCT_L3_BINS.(OK).MOBINS
  ENDIF
  
; ===> Get the "oceacn" subscripts from the output map
  OCEAN = (READ_LANDMASK(MAP_OUT,/STRUCT)).OCEAN

; ===> Get the LONS and LATS for the output map
  LL = MAPS_2LONLAT(MAP_OUT,LONS=LONS,LATS=LATS)

; ===> Subset the LONS and LATS for just the ocean pixels
  LONS = LL.LONS[OCEAN]
  LATS = LL.LATS[OCEAN]
  
; ===> GET THE BINS FOR THE OCEAN LONS AND LATS
  MOBINS = MAPS_L3B_LONLAT_2BIN(MAP_IN,LONS,LATS)
  
  STR = CREATE_STRUCT('MAP_IN',MI.MAP, 'PX_IN', MI.PX,'PY_IN', MI.PY,$
                      'MAP_OUT',MO.MAP,'PX_OUT',MO.PX,'PY_OUT',MO.PY,'MOBINS',MOBINS)
  STRUCT_L3_BINS = CREATE_STRUCT(TEMPORARY(STRUCT_L3_BINS),MAP_TXT,STR)
  
  RETURN, MOBINS

END; #####################  END OF ROUTINE ################################
