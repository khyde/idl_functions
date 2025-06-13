; $ID:	MAPS_LANDMASK_CLEANUP.PRO,	2020-06-26-15,	USER-KJWH	$

	FUNCTION MAPS_LANDMASK_CLEANUP, MAP_ARRAY, OCEAN_CODE=OCEAN_CODE, COAST_CODE=COAST_CODE, COAST_THICK_CODE=COAST_THICK_CODE, LAND_CODE=LAND_CODE

;+
; NAME:
;		MAPS_LANDMASK_CLEANUP
;
; PURPOSE:;
;		This cleans up a newly created created landmask by replacing ocean pixels adjacent to land with coastline pixels,
;       removing lakes with no water, and replacing land pixels surrounded by coast with coast 
;
; CATEGORY:
;		LANDMASK
;
; CALLING SEQUENCE:
;		MASK = FIX_COASTLINE(MAP_ARRAY)
;
; INPUTS:
;   MAP_ARRAY - A landmask array
;		
; OPTIONAL INPUTS:
;   OCEAN_CODE - Value representing the ocean pixels
;   COAST_CODE - Value representing the coast pixels
;   LAND_CODE  - Value representing the land pixels		
;
; OUTPUTS:
;		This function returns a new landmask with an improved coastline
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Nov 5, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Dec 11, 2013 - KJWH: Changed DATA variable to DT
;     Mar 22, 2016 - KJWH: Changed name to MAPS_LANDMASK_CLEANUP and added the RREMOVE_LAKE_BOUNDARIES logic
;                          No longer calling READ_LANDMASK, just input the map array and then find the OCEAN pixels
;                          Changed input variable from LANDMASK_FILE to MAP_ARRAY
;                          Added optional keywords OCEAND_CODE, LAND_CODE and COAST_CODE
;     Mar 24, 2016 - KJWH: Fixed bugs in the OCEAN and LAND surrounded by COAST steps
;                          Added FIX_COAST keyword option to run the final step that thins out the coastline 
;     Mar 28, 2016 - KJWH: Added COAST_THICK_CODE 
;                          Removed FIX_COAST keyword - now returning the "THICK" and "THIN" coastlines as different codes                                        
;     
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MAPS_LANDMASK_CLEANUP'
	
; ===> Default codes in the landmask
  IF NONE(OCEAN_CODE)       THEN OCEAN_CODE       = 0
  IF NONE(COAST_CODE)       THEN COAST_CODE       = 1
  IF NONE(COAST_THICK_CODE) THEN COAST_THICK_CODE = 2
  IF NONE(LAND_CODE)        THEN LAND_CODE        = 3
    
; ===> Look for LAND pixels that are adjacent to the OCEAN (i.e. are missing a coastline) and make them COAST  
  OCEAN = WHERE(MAP_ARRAY EQ OCEAN_CODE, COUNT_OCEAN)
  FOR I = 0L, COUNT_OCEAN-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,OCEAN(I),SUBS=SUBS,AROUND=1)        
    OK = WHERE(BOX EQ LAND_CODE, COUNT) ; Find LAND pixels next to OCEAN pixels
    IF COUNT GE 1 THEN MAP_ARRAY(SUBS[OK]) = COAST_CODE           
  ENDFOR
  
; ===> Look for LAND pixels that are completely surrounded by COAST pixels and make them COAST
  LAND = WHERE(MAP_ARRAY EQ LAND_CODE, COUNT_LAND)
  FOR I = 0L, COUNT_LAND-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,LAND(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ COAST_CODE, COUNT) ; Find LAND pixels completely surrounded by COAST
    IF COUNT EQ 8 THEN MAP_ARRAY(LAND(I)) = COAST_CODE
  ENDFOR 

; ===> Look for OCEAN pixels that are completely surrounded by COAST pixels and make them COAST
  OCEAN = WHERE(MAP_ARRAY EQ OCEAN_CODE, COUNT_OCEAN)
  FOR I = 0L, COUNT_OCEAN-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,OCEAN(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ COAST_CODE,COUNT) ; Find OCEAN pixels completely surrounded by COAST
    IF COUNT EQ 8 THEN MAP_ARRAY(OCEAN(I)) = COAST_CODE
  ENDFOR
  
; ===> Look for COAST pixels that are not adjacent to OCEAN and make them land (thins out the coastline)
  THICK_COAST = WHERE(MAP_ARRAY EQ COAST_CODE, COUNT_COAST)
  FOR I = 0L, COUNT_COAST-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,THICK_COAST(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ OCEAN_CODE,COUNT) ; Find any OCEAN pixels in the box
    IF COUNT EQ 0 THEN MAP_ARRAY(THICK_COAST(I)) = LAND_CODE
  ENDFOR
  COAST = WHERE(MAP_ARRAY EQ COAST_CODE)
  MAP_ARRAY(THICK_COAST) = COAST_THICK_CODE
  MAP_ARRAY(COAST)       = COAST_CODE
  
  RETURN, MAP_ARRAY


END; #####################  End of Routine ################################
