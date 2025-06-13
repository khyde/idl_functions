; $ID:	SHAPEFILE_2LONLAT.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION SHAPEFILE_2LONLAT, SHAPEFILE, MAPP=MAPP, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE

;+
; NAME:
;   SHAPEFILE_2LONLAT
;
; PURPOSE:
;   This function will extract the longitude and latitude values of the polygon outlines from a shapefile
;
; CATEGORY:
;   SHAPEFILES
;
; CALLING SEQUENCE:
;   R = SHAPEFILE_2LONLAT(FILE,MAP)
;   
; INPUTS:
;   SHAPEFILES......The name of the input shapefile(s) 
;
; OPTIONAL INPUTS:
;   MP..............Name of a map to use for the output png
;
; KEYWORD PARAMETERS:
;  VERBOSE .........Print out information 
;  OVERWRITE........Create new files if they currently exist   
;
; OUTPUTS:
;   
;
; OPTIONAL OUTPUTS:
;   
;
; PROCEDURE:
;
; EXAMPLE:
;   R = SHAPEFILE_2LONLAT(!S.IDL_SHAPEFILES + 'NES_ECOREGIONS/EPU_NOESTUARIES.shp')
;   R = SHAPEFILE_2LONLAT(!S.IDL_SHAPEFILES + 'NES_ECOREGIONS/EPU_NOESTUARIES.shp',MP='NEC)
;
; NOTES:
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;    
;
; MODIFICATION HISTORY:
;			Written:  October 16, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Oct 19, 2018 - KJWH: Updated the MAPP/MP keywords to avoid overwriting the MAPP information in READ_SHAPEFILE
;			          Mar 08, 2019 - KJWH: Updated the plotting steps so that it loops through each "part"
;			                               Added VERBOSE and OVERWRITE keywords
;			                               Changed the output directory to be LONLAT_SAVES
;			                               Adding a copy of the OUTLINE PNG to the SHAPES directory
;			          Sep 23, 2019 - KJWH: Added steps to correcting values beyond the LON/LAT bounds (-180,180,-90,90) which are likely a result of converting the data to DOUBLE                      
;                                    Added IF MAX([PX,PY]) GT 8192 THEN BUFFER = 1 ELSE BUFFER = 0 because of image size errors with large maps
;               Jul 08, 2020 - KJWH: Added COMPILE_OPT IDL2
;                                    Changed subscript () to []
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SHAPEFILE_2LONLAT'
	COMPILE_OPT IDL2
	
	SL = PATH_SEP()
	
	IF NONE(MAPP) THEN MP = 'GEQ' ELSE MP = MAPP 
	IF IS_L3B(MP) THEN MP = MAPS_L3B_GET_GS(MP)
	LAND = READ_LANDMASK(MP)
	PAL = 'PAL_LANDMASK'
	
	IF N_ELEMENTS(SHAPEFILE) NE 1 THEN SHAPEFILE = DIALOG_PICKFILE(TITLE='PICK A SHAPEFILE')
	IF FILE_TEST(SHAPEFILE) EQ 0 THEN MESSAGE, 'ERROR: ' + SHAPEFILE + ' does not exist'
	FP = FILE_PARSE(SHAPEFILE)
  REGION = STRUCT_TAGNAMES_FIX(STRUPCASE(FP.SUB))
  SUBAREA = STRUCT_TAGNAMES_FIX(STRUPCASE(FP.NAME))
  OUTFILE = !S.IDL_SHAPEFILES + 'LONLAT_SAVES' + SL + 'LONLAT-' + FP.NAME + '.SAV' 
  CSVFILE = !S.IDL_SHAPEFILES + 'LONLAT_SAVES' + SL + 'LONLAT-' + FP.NAME + '.CSV'
  PNGDIR =  !S.IDL_SHAPEFILES + 'OUTLINES'  + SL  
  DIR_TEST, [!S.IDL_SHAPEFILES + 'LONLAT_SAVES' + SL, PNGDIR]
 
  IF FILE_MAKE(SHAPEFILE,[OUTFILE,CSVFILE],OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN ; If SAV file already exists, read it and add the info to the MASTER_STRUCTURE
    FILE_STRUCT = IDL_RESTORE(OUTFILE)
    GOTO, MAKE_PNG ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ENDIF;IF FILE_MAKE(SHAPEFILE,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN

  RANGE_LON =[MISSINGS(0.),-MISSINGS(0.)] & RANGE_LAT = RANGE_LON  ;===> INITIALIZE RANGE_LON,RANGE_LAT

  SHAPEFILEOBJ=OBJ_NEW('IDLFFSHAPE',SHAPEFILE)                                                                                                     ; ===> OPEN THE SHAPEFILE
  SHAPEFILEOBJ -> IDLFFSHAPE::GETPROPERTY, N_ENTITIES=N_ENTITIES,ENTITY_TYPE=ENTITY_TYPE,N_ATTRIBUTES=N_ATTRIBUTES,ATTRIBUTE_NAMES=ATTRIBUTE_NAMES ; ===> GET THE NUMBER OF ENTITIES, NUMBER OF ATTRIBUTES, AND ATTRIBUTE NAMES FROM SHAPEFILEOBJ
  ENTITIES = SHAPEFILEOBJ -> IDLFFSHAPE::GETENTITY(/ALL,/ATTRIBUTES)                                                                               ; ===> GET THE ENTITIES
  ATTR = SHAPEFILEOBJ -> IDLFFSHAPE::GETATTRIBUTES(/ALL,/ATTRIBUTE_STRUCTURE)                                                                      ; ===> GET THE ATTRIBUTES

  IF KEY(VERBOSE) THEN BEGIN
    PRINT,'N_ENTITIES = ',N_ENTITIES
    PRINT,'N_ATTRIBUTES = ',N_ATTRIBUTES
    PRINT,'ATTRIBUTE_NAMES = ',ARR_2STR(ATTRIBUTE_NAMES)
    PRINT, ATTRIBUTE_NAMES
  ENDIF  

  IF KEY(ATT_TAG) THEN BEGIN
    ATTINDEX = WHERE(STRUPCASE(ATTRIBUTE_NAMES) EQ STRUPCASE(ATT_TAG), FOUND_ATTRIBUTE_NAME)
    IF FOUND_ATTRIBUTE_NAME EQ 0 THEN MESSAGE, 'ERROR: Can not find ' + ATT_TAG + ' attribute in ' + SHAPEFILE
  ENDIF ELSE ATTINDEX = []

  ;===> GET ALL ENTITIES
  ENTITIES = PTR_NEW(/ALLOCATE_HEAP)
  *ENTITIES = SHAPEFILEOBJ -> GETENTITY(/ALL, /ATTRIBUTES)

  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  COLORS = []          ; Set up a null array to hold the colors of the entities
  TAGS = []            ; Set up a null array to hold the tagnames for each entities
  FILE_STRUCT = []     ; Set up a null structure for the file specific structure
  FOR _ENT=0, N_ELEMENTS(*ENTITIES)-1 DO BEGIN ; Loop through all ENTITIES
    ENT = SHAPEFILEOBJ->IDLFFSHAPE::GETENTITY(_ENT,/ATTRIBUTES)
    ENTITY = (*ENTITIES)[_ENT]
    ATT = SHAPEFILEOBJ->GETATTRIBUTES(_ENT)

    _COLOR = (_ENT MOD 240)+10
    IF KEY(VERBOSE) THEN PRINT,'SHAPE_TYPE         :  ', ENT.SHAPE_TYPE
    IF KEY(VERBOSE) THEN PRINT,'N PARTS            :  ', ENT.N_PARTS
    IF KEY(VERBOSE) THEN PRINT,'N VERTICES         :  ', ENT.N_VERTICES

    ; ===> GET XP AND YP INFO
    IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN ; SHAPE_TYPE 1 are for X,Y points
      PT = [ENT.VERTICES]
      LON = ENT.BOUNDS[0]
      LAT = ENT.BOUNDS[1]
      RANGE_LON= MINMAX(LON)
      RANGE_LAT= MINMAX(LAT)
    ENDIF ELSE BEGIN ; IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN
      ; ===> GET SUBSCRIPTS FOR THE OUTLINE
      OLONS = []
      OLATS = []
      NPOLY  = []
      ; ===> GET SUBSCRIPTS FOR THE POLYGON
      FOR SEG=0, ENT.N_PARTS-1 DO BEGIN
        SEGS = [*ENT.PARTS, ENT.N_VERTICES]
        X = REFORM((*ENT.VERTICES)[0, SEGS[SEG]:SEGS[SEG+1]-1]) & OLONS = [OLONS,X]
        Y = REFORM((*ENT.VERTICES)[1, SEGS[SEG]:SEGS[SEG+1]-1]) & OLATS = [OLATS,Y]
        NPOLY = [NPOLY,REPLICATE(SEG,N_ELEMENTS(X))]

        MM_X =MINMAX(X) & MM_Y =MINMAX(Y)
        RANGE_LON[0] = MM_X[0] < RANGE_LON[0]
        RANGE_LON[1] = MM_X[1] > RANGE_LON[1]
        RANGE_LAT[0] = MM_Y[0] < RANGE_LAT[0]
        RANGE_LAT[1] = MM_Y[1] > RANGE_LAT[1]

        IF PTR_VALID(ENTITY) THEN HEAP_FREE, ENTITY
      ENDFOR;FOR SEG=0, ENTITY.N_PARTS-1 DO BEGIN  
    ENDELSE ; IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

    IF ATTINDEX EQ [] THEN BEGIN
      ATT_TYPE = []
      FOR A=0, N_ATTRIBUTES -1 DO ATT_TYPE = [ATT_TYPE,IDLTYPE(ATT.(A))]
      OKATT = WHERE(ATT_TYPE EQ 'STRING',COUNT_ATT)
      IF COUNT_ATT GE 1 THEN ATTINDEX = OKATT[0] ; ASSUMES THE POLYGON NAME IS THE FIRST "STRING" ATTRIBUTE
    ENDIF
    IF ATTINDEX NE [] THEN SUBAREA_NAME = STRTRIM(STRING(ATT.(ATTINDEX)),2) $
    ELSE SUBAREA_NAME = SUBAREA + '_' + NUM2STR(_ENT) ; IF THERE IS NO STRING ATTRIBUTE, USE THE ENTITY NUMBER TO DESCRIBE THE SUBAREA

    OK = WHERE(TAGS EQ SUBAREA_NAME,COUNT)
    IF COUNT EQ 1 THEN SUBAREA_NAME = SUBAREA_NAME + '_' + NUM2STR(_ENT)
    TAGS = [TAGS, SUBAREA_NAME]
    
    ; ===> Make sure coordinates fall within the LON/LAT bounds
    OK180  = WHERE(OLONS GE  180.0,COUNT_180)  & IF COUNT_180  GT 0 THEN OLONS[OK180]  =  180.0
    OKN180 = WHERE(OLONS LE -180.0,COUNT_N180) & IF COUNT_N180 GT 0 THEN OLONS[OKN180] = -180.0
    OK90   = WHERE(OLATS GE   90.0,COUNT_90)   & IF COUNT_90   GT 0 THEN OLATS[OK90]   =   90.0
    OKN90  = WHERE(OLATS LE  -90.0,COUNT_N90)  & IF COUNT_N90  GT 0 THEN OLATS[OKN90]  =  -90.0

    ENT_STRUCT = CREATE_STRUCT('SHP_FILE',SHAPEFILE,'SUBAREA',SUBAREA_NAME,'PART_NUMBER',NPOLY,'OUTLINE_LONS',OLONS,'OUTLINE_LATS',OLATS,'ENTITY',ENT,'ATTRIBUTES',ATT)

    FILE_STRUCT = CREATE_STRUCT(FILE_STRUCT,STRUCT_TAGNAMES_FIX(SUBAREA_NAME),ENT_STRUCT)
  ENDFOR ; FOR _ENT = 0,N_ELEMENTS(*ENTITIES) -1 DO BEGIN

  ; ===> CLOSE/DESTROY/FREE THE SHAPEFILE & ENTITIES
  IF OBJ_VALID(SHAPEFILE) THEN OBJ_DESTROY, SHAPEFILE
  IF PTR_VALID(ENTITIES) THEN PTR_FREE, ENTITIES;
  IF PTR_VALID(ENTITIES) THEN HEAP_FREE, ENTITIES;
  OBJ_DESTROY, SHAPEFILEOBJ

  SAVE, FILENAME=OUTFILE, FILE_STRUCT
  PFILE,OUTFILE
   
  FOR S=0, N_TAGS(FILE_STRUCT)-1 DO BEGIN
    SS = FILE_STRUCT.(S)
    T  = REPLICATE(CREATE_STRUCT('SUBAREA','','PART_NUMBER',0L,'LON',0.0,'LAT',0.0),N_ELEMENTS(SS.OUTLINE_LONS))
    T.SUBAREA     = SS.SUBAREA
    T.PART_NUMBER = SS.PART_NUMBER
    T.LON         = SS.OUTLINE_LONS
    T.LAT         = SS.OUTLINE_LATS
    IF S EQ 0 THEN STR = T ELSE STR = [STR,T]
  ENDFOR   
  STRUCT_2CSV,CSVFILE,STR
   
 
	 
	RETURN, FILE_STRUCT


END; #####################  End of Routine ################################
