; $ID:	MAPS_LANDMASK_CLEANUP_DEMO.PRO,	2020-06-26-15,	USER-KJWH	$

PRO MAPS_LANDMASK_CLEANUP_DEMO, MAPP, OCEAN_CODE=OCEAN_CODE, COAST_CODE=COAST_CODE, LAND_CODE=LAND_CODE

  ;+
  ; NAME:
  ;   MAPS_LANDMASK_CLEANUP_DEMO
  ;
  ; PURPOSE:;
  ;   This cleans up a newly created created landmask by replacing ocean pixels adjacent to land with coastline pixels,
  ;       removing lakes with no water, and replacing land pixels surrounded by coast with coast
  ;
  ; CATEGORY:
  ;   LANDMASK
  ;
  ; CALLING SEQUENCE:
  ;   MASK = MAPS_LANDMASK_CLEANUP(MAP_ARRAY)
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
  ;   This function returns a new landmask with an improved coastline
  ;
  ; NOTES:
  ;
  ;
  ; MODIFICATION HISTORY:
  ;     Written Nov 5, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
  ;     Dec 11, 2013 - KJWH: Changed DATA variable to DT
  ;     Mar 22, 2016 - KJWH: Changed name to MAPS_LANDMASK_CLEANUP and added the RREMOVE_LAKE_BOUNDARIES logic
  ;                          No longer calling READ_LANDMASK, just input the map array and then find the OCEAN pixels
  ;                          Changed input variable from LANDMASK_FILE to MAP_ARRAY
  ;                          Added optional keywords OCEAND_CODE, LAND_CODE and COAST_CODE
  ;     Mar 25, 2016 - KJWH: Added TIC and TOC 
  ;                          Removed MAP_ARRAY input
  ;                          Added STRUPCASE(MAPP)
  ;     Mar 28, 2016 - KJWH: Now creating "THICK" and "THIN" coastlines                     
  ;                                              
  ;
  ;-
  ; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_LANDMASK_CLEANUP_DEMO'

  PAL_LANDMASK,R,G,B
  DIR = !S.DEMO + ROUTINE_NAME + PATH_SEP() & DIR_TEST, DIR

; ===> Default codes in the landmask
  IF NONE(OCEAN_CODE)       THEN OCEAN_CODE       = 0
  IF NONE(COAST_CODE)       THEN COAST_CODE       = 1
  IF NONE(COAST_THICK_CODE) THEN COAST_THICK_CODE = 2
  IF NONE(LAND_CODE)        THEN LAND_CODE        = 3
      
  IF NONE(MAPP) THEN MAPP = 'NEC' ELSE MAPP = STRUPCASE(MAPP)

  OCEAN_REPLACED = 0
  LAND_BY_OCEAN_REPLACED = 0
  LAND_REPLACED = 0
  COAST_REMOVED = 0

  TIC

  MAPS_SET, MAPP, BKG_COLOR=OCEAN_CODE
    MAPS_COASTLINE,'FULL',/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_LAKE_SIDE,/ADD_SMALL_LAKES,/ADD_SMALL_LAKE_SIDE
    MAP_ARRAY = TVRD()
  ZWIN

  WRITE_PNG,DIR+'MASK_LAND-'+MAPP+'-ORGINGAL' +'.PNG',MAP_ARRAY,R,G,B

  ; ===> Look for LAND pixels that are adjacent to the OCEAN (i.e. are missing a coastline) and make them COAST
  OCEAN = WHERE(MAP_ARRAY EQ OCEAN_CODE, COUNT_OCEAN)
  OUT_ARRAY = MAP_ARRAY
  FOR I = 0L, COUNT_OCEAN-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,OCEAN(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ LAND_CODE, COUNT) ; Find LAND pixels next to OCEAN pixels
    IF COUNT GE 1 THEN BEGIN
      MAP_ARRAY(SUBS[OK]) = COAST_CODE
      OUT_ARRAY(SUBS[OK]) = 225 ; RED
      LAND_BY_OCEAN_REPLACED = LAND_BY_OCEAN_REPLACED + COUNT
    ENDIF  
  ENDFOR
  WRITE_PNG,DIR +'MASK_LAND-'+MAPP+'-LAND_BY_OCEAN_REPLACED' +'.PNG',OUT_ARRAY,R,G,B


  ; ===> Look for LAND pixels that are completely surrounded by COAST pixels and make them COAST
  LAND = WHERE(MAP_ARRAY EQ LAND_CODE, COUNT_LAND)
  OUT_ARRAY = MAP_ARRAY
  FOR I = 0L, COUNT_LAND-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,LAND(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ COAST_CODE, COUNT) ; Find LAND pixels completely surrounded by COAST
    IF COUNT EQ 8 THEN BEGIN
      MAP_ARRAY(LAND(I)) = COAST_CODE
      OUT_ARRAY(LAND(I)) = 225 ; RED
      LAND_REPLACED = LAND_REPLACED + 1
    ENDIF  
  ENDFOR
  WRITE_PNG,DIR +'MASK_LAND-'+MAPP+'-LAND_REPLACED' +'.PNG',OUT_ARRAY,R,G,B


  ; ===> Look for OCEAN pixels that are completely surrounded by COAST pixels and make them COAST
  OCEAN = WHERE(MAP_ARRAY EQ OCEAN_CODE, COUNT_OCEAN)
  OUT_ARRAY = MAP_ARRAY
  FOR I = 0L, COUNT_OCEAN-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,OCEAN(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ COAST_CODE,COUNT) ; Find OCEAN pixels completely surrounded by COAST
    IF COUNT EQ 8 THEN BEGIN
      MAP_ARRAY(OCEAN(I)) = COAST_CODE
      OUT_ARRAY(OCEAN(I)) = 225 ; RED
      OCEAN_REPLACED = OCEAN_REPLACED + 1
    ENDIF  
  ENDFOR
  WRITE_PNG,DIR +'MASK_LAND-'+MAPP+'-OCEAN_REPLACED' +'.PNG',OUT_ARRAY,R,G,B

  
  ; ===> Look for COAST pixels that are not adjacent to OCEAN and make them land (thins out the coastline)
  THICK_COAST = WHERE(MAP_ARRAY EQ COAST_CODE, COUNT_COAST)
  OUT_ARRAY = MAP_ARRAY
    FOR I = 0L, COUNT_COAST-1 DO BEGIN
    BOX = BOX_AROUND(MAP_ARRAY,THICK_COAST(I),SUBS=SUBS,AROUND=1)
    OK = WHERE(BOX EQ OCEAN_CODE,COUNT) ; Find any OCEAN pixels in the box
    IF COUNT EQ 0 THEN BEGIN
      MAP_ARRAY(THICK_COAST(I)) = LAND_CODE
      OUT_ARRAY(THICK_COAST(I)) = 225 ; RED
      COAST_REMOVED = COAST_REMOVED + 1
    ENDIF  
  ENDFOR
  COAST = WHERE(MAP_ARRAY EQ COAST_CODE)
  MAP_ARRAY(THICK_COAST) = COAST_THICK_CODE
  MAP_ARRAY(COAST)       = COAST_CODE
  
  WRITE_PNG,DIR +'MASK_LAND-'+MAPP+'-COAST_REMOVED' +'.PNG',OUT_ARRAY,R,G,B

  WRITE_PNG,DIR +'MASK_LAND-'+MAPP+'-CLEANED_UP.PNG',MAP_ARRAY,R,G,B

  PRINT, 'OCEAN_REPLACED = ' + ROUNDS(OCEAN_REPLACED)
  PRINT, 'LAND_REPLACED    = ' + ROUNDS(LAND_REPLACED)
  PRINT, 'LAND_BY_OCEAN_REPLACED  = ' + ROUNDS(LAND_BY_OCEAN_REPLACED)
  PRINT, 'COAST_REMOVED  = ' + ROUNDS(COAST_REMOVED)

  TOC
  

END; #####################  End of Routine ################################
