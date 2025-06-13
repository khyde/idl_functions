; $ID:	I_SUN_KIRK_DAY_LENGTH_MAP.PRO,	2017-12-18-13,	USER-KJWH	$

  FUNCTION I_SUN_KIRK_DAY_LENGTH_MAP, DOY, MAPP=mapp, INIT=init, OVERWRITE=overwrite

;+
; NAME:
;       I_SUN_KIRK_DAY_LENGTH_MAP
;
; PURPOSE:
;       Calculate sun characteristics according to equations in:
;       Kirk, J.T.O, 1994, Light and photosynthesis in aquatic ecosystems,
;                          Cambridge University Press, 509pp.
;
; CATEGORY:
;       LIGHT, MAP
;
; CALLING SEQUENCE:
;
;       I_SUN_KIRK_DAY_LENGTH_MAP
;
; 
;
; KEYWORD PARAMETERS:
;       MAP..... An IDL MAP NAME (i.e.  NEC, GLOBAL_EQUIDISTANT, SEC)
;       DOY..... Day of year (1,366)
;
; OUTPUTS:
;       A map image with floating point values equal to the calculated DAY LENGTH
;
;  EXAMPLE:
;       DL = I_SUN_KIRK_DAY_LENGTH_MAP('NEC',001)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 27, 1999
;       Apr 02, 2008 - TD:   Get LAT for NENA
;       Jun 22, 2016 - KJWH: Updated L3B map info and removed NENA map
;       Feb 08, 2017 - KJWH: Now able to get the LAT info for L3B maps
;                            Removed REFORM(DAY_LENGTH,PX,PY) because the array already matches the dimensions (1D in the case of L3B or 2D for maps such as NEC) of the map
;                            Changed the keyword MAP to MAPP
;                            Added check for DOY
;       Dec 18, 2017 - KJWH: Instead of continually rerunning, now saving files and reading them when needed.  Added:
;                              DIR = !S.DAY_LENGTH + MP + '_PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + GET_PATH() & DIR_TEST,DIR 
;                              SAVEFILE = DIR + ADD_STR_ZERO(DOY,3) + '-' + MP + 'PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-DAY_LENGTH.SAV'
;                              IF EXISTS(SAVEFILE) AND ~KEY(OVERWRITE) THEN RETURN, IDL_RESTORE(SAVEFILE)            
;                              SAVE, DAY_LENGTH, FILENAME=SAVEFILE    
;                            Added DOY check to make sure it is valid      
;                              IF _DOY LT 1 OR _DOY GT 366 THEN RETURN, 'ERROR: DOY (' + NUM2STR(_DOY) +') out of range'
;
;-
; ====================>
  COMMON MAP_LAT_, MAP_NAME, LAT

  IF VALIDS('MAPS',MAPP) EQ '' THEN RETURN, 'ERROR: Must provide valid input map' ELSE MP = MAPP
  IF NONE(DOY) THEN RETURN, 'ERROR: No DOY provided' ELSE _DOY = DOY
  IF _DOY LT 1 OR _DOY GT 366 THEN RETURN, 'ERROR: DOY (' + NUM2STR(_DOY) +') out of range'

	MS = MAPS_SIZE(MP,PX=PX,PY=PY)
	
	DIR = !S.DAY_LENGTH + MP + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + GET_PATH() & DIR_TEST,DIR	
	SAVEFILE = DIR + 'DOY_' + ADD_STR_ZERO(_DOY,3) + '-' + MP + '-PXY_' + NUM2STR(PX) + '_' + NUM2STR(PY) + '-DAY_LENGTH.SAV'
	IF EXISTS(SAVEFILE) AND ~KEY(OVERWRITE) THEN RETURN, IDL_RESTORE(SAVEFILE)
	
	IF N_ELEMENTS(MAP_NAME) EQ 1 THEN IF MP NE MAP_NAME THEN INIT = 1

  IF NONE(LAT) OR KEY(INIT) THEN BEGIN
    PRINT, 'PUTTING LON/LAT FOR ' + MP + ' INTO COMMON MEMORY'
    MAP_NAME=MP
    IF IS_L3B(MP) THEN STRUCT = MAPS_L3B_2LONLAT(MP, LATS=LAT) ELSE STRUCT = MAPS_2LONLAT(MP,PX=PX,PY=PY,LATS=LAT)
    GONE, STRUCT
  ENDIF ; GET LATS

; ===> Compute day length
  _LAT = LAT
  DAY_LENGTH=I_SUN_KIRK_DAY_LENGTH(_LAT, _DOY)
  PFILE, SAVEFILE, /W
  IF HAS(MP,'L3B') THEN BEGIN
    DL = FLTARR(PX, PY)
    DL(0:*) = DAY_LENGTH
    GONE, DAY_LENTH
    SAVE, DL, FILENAME=SAVEFILE
    RETURN, DL
  ENDIF 

  SAVE, DAY_LENGTH, FILENAME=SAVEFILE
  RETURN, DAY_LENGTH

END ; END OF PROGRAM
