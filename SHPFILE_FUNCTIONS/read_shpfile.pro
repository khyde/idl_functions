; $ID:	READ_SHPFILE.PRO,	2023-09-21-13,	USER-KJWH	$
;########################################################################################################################################
FUNCTION READ_SHPFILE, SUBAREA,  MAPP=MAPP, ATT_TAG=ATT_TAG, $
  STRUCT=STRUCT, COLORS=COLORS, NORMAL=NORMAL, AROUND=AROUND,  GET_RANGE=GET_RANGE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, _EXTRA=_EXTRA
  
;+
; NAME:
;   READ_SHPFILE
;   	
;	PURPOSE:
;	 This function reads the entity and attribute information in shape files creating subarea .SAV files and mapped .PNG files
;
; CATEGORY:
;   SHP_FUNCTIONS
;   
; CALLINS SEQUENCE:
;   R = READ_SHPFILE, SUBAREA, MAPP=MAPP
;   
; REQUIRED INPUTS:
;   SUBAREA....... The "SUBAREA" name of the shapefile
;   MAPP.......... The name of the base map to overplot the subarea on
;   
; OPTIONAL INPUTS:
;   COLORS........ Colors to use when plotting the subareas on a map
;   ATT_TAG....... Selects the tagname from the attributes in the shapefile dbf
;   AROUND........ Sent to BOX_AROUND when reading x,y point shapefiles
;   _EXTRA........ Extra commands passed to PLOTS and POLYFILL
;   
; OUTPUTS:
;   A structure with the subscripts for the subareas in a given map.  
;   Map specific images are also created if they do not already exist
;   
; OPTIONAL OUTPUTS:
;  None
;  
; COMMON BLOCKS:
;   None
;   
; SIDE EFFECTS:
;   None  
; 
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2002, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 26, 2002 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquires can be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;	  MAR 26, 2002 - JEOR: Wrote initial code
;  	OCT 25, 2011 - JEOR: ADDED KEYWORD FILL
;	  NOV 21, 2012 - JEOR: REPLACED PARSE_IT WITH FILE_PARSE
;	  DEC 05, 2012 - JEOR: FORMATTING; CHANGE DIR TO ORIGINAL; REMOVED UNUSED COMMENTS
;  	DEC 14, 2012 - JEOR: STREAMLINED, ADDED KEYWORDS
;	  DEC 23, 2012 - JEOR: CYCLE THROUGH ENTITIES TO FIND THE TAGNAME ATTRIBUTE  AND THE TAGNAME  VALUE
;	  DEC 26, 2012 - JEOR: IF FOUND_ATTRIBUTE_NAME EQ 1 AND N_ELEMENTS(START_ENT)EQ 0 THEN BEGIN
;   DEC 29, 2012 - JEOR: UPPERCASE:  ATTINDEX = WHERE(STRUPCASE(ATTRIBUTE_NAMES) EQ STRUPCASE(TAGNAME), FOUND_ATTRIBUTE_NAME)
;   JAN 01, 2013 - JEOR: IF N_ELEMENTS(VALUE) EQ 1 THEN _VALUE = STRUPCASE(VALUE) ELSE _VALUE = ''
;   JAN 02, 2012 - JEOR: ; ######     CONVERT X,Y FROM LONLAT TO NORMAL COORDINATES     #####
;                         ADDED KEYWORD LONLAT
;                         PLOT, XRANGE, YRANGE, XSTYLE=5, YSTYLE=5, POSITION=[0,0, 1,1], /NODATA,/NOERASE,NORMAL=NORMAL,DATA=DATA
;   JAN 03, 2013 - JEOR: CHANGED DEFAULT TO ASSUME X,Y COORDS IN SHAPEFILE ARE LON,LAT ; ADDED KEYWORD NORMAL FOR OTHER INPUT
;                        IF N_ELEMENTS(LINESTYLE) EQ 1 THEN _LINESTYLE =LINESTYLE ELSE _LINESTYLE= 0
;   JAN 22, 2013 - JEOR: IF N_ELEMENTS(VALUE) GT 1 THEN MESSAGE,'VALUE MUST BE SCALAR'
;   JAN 27, 2013 - JEOR: REMOVED UNUSED COMMENTED CODE;REPORT, '##### FOUND  TAGNAME VALUE     #####' +AVALUE
;                        CHANGED X TO Y: MM_Y =MINMAX(Y)
;                        ALWAYS REPORT:      REPORT, 'FOUND  TAGNAME VALUE:  ' +AVALUE
;   AUG 13, 2013 - JEOR: _COLOR = AVALUE
;   AUG 15, 2013 - JEOR: CHANGED TARGET TO TAGNAME ENTITY_TAGNAME = STRTRIM((*ENTITY.ATTRIBUTES).(ATTINDEX), 2)
;                        IF FOUND_ATTRIBUTE_NAME EQ 1 AND (AVALUE EQ _VALUE OR FLOAT(AVALUE) EQ FLOAT(_VALUE))  THEN BEGIN
;   AUG 16, 2013 - JEOR: ENTITY_ = STRTRIM((*ENTITY.ATTRIBUTES).(ATTINDEX), 2)
;                        IF KEYWORD_SET(ENTITY_COLOR) THEN _COLOR = ENTITY_ MOD 256
;   AUG 17, 2013 - JEOR: GOTO,PLOT_ENTITY;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                        IF AVALUE EQ 'WARM' AND IDLTYPE(ENTITY_) EQ 'STRING' THEN ENTITY_ = 67; PWP
;   AUG 18, 2013 - JEOR: ADDED KEYWORDS RANGE_LON,RANGE_LAT
;   AUG 19, 2013 - JEOR: IF N_ELEMENTS(COLOR) EQ 1 THEN _COLOR = COLOR ELSE _COLOR = AVALUE
;   SEP 15, 2013 - JEOR: IF FOUND_ATTRIBUTE_NAME EQ 1 AND STRTRIM(AVALUE,2) EQ STRTRIM(_VALUE,2)  THEN BEGIN
;                        IF FOUND_ATTRIBUTE_NAME EQ 1 THEN AVALUE=(STRTRIM((*ENT.ATTRIBUTES).(ATTINDEX), 2)) ELSE AVALUE = ''
;                        IF N_ELEMENTS(VALUE) EQ 1 THEN _VALUE = VALUE ELSE _VALUE = '' [REMOVED STRUPCASE(VALUE)]
;   OCT 06, 2013 - JEOR: ADDED KEYWORD GET_RANGE [ FOR CENTRAL_ARCTIC]
;   OCT 18, 2013 - JEOR: ADDED KEYWORD DO_ALL
;   APR 06, 2014 - JEOR: ADDED KEYWORD AUTO
;                        [IF KEYWORD_SET(AUTO) THEN TAGNAME = LAST(ATTRIBUTE_NAMES)
;   MAY 28, 2014 - JEOR: COPIED FROM PLOT_SHAPE, STREAMLINED,AUTO FIXED
;                        IF N_ELEMENTS(TAGNAME) NE 1 THEN  AUTO = 1 & ENTITY_COLOR = 1
;   MAY 30, 2014 - JEOR: ADDED KEYWORDS LONS,LATS
;   JUN 04, 2014 - JEOR: IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN
;                        ADDED PSYM,SYMSIZE [FOR POINTS]
;   JUN 10, 2014 - JEOR: ADDED BOX_AROUND  FOR LON,LAT POINT
;   JUN 17, 2014 - JEOR: RANGE_LON= MINMAX(LONS)
;   JUN 19, 2014 - JEOR: CODE TO EXTRACT ALL 9 PIXELS WHEN AROUND = 1
;   DEC 08, 2014 - JEOR: CHANGED IMAGE_PXPY TO IMG_XPYP
;   DEC 08, 2016 - KJWH: UPDATED THE FORMATTING
;                        NOW LOOPING THROUGH ENTITIES IN ORDER TO EXTRACT MULTIPLE POLYGONS PER FILE
;                        CAN NOW GET AN OUTPUT STRUCTURE FROM THE MULTIPLE FILES AND POLYGONS
;                        ADDED ATTR = SHAPEFILEOBJ->GETATTRIBUTES(_ENT) TO GET THE ATTRIBUTE INFO FROM THE SHP FILE
;                        USING ATTRIBUTE_0 TO NAME THE POLYGONS IN THE OUTPUT STRUCTURE -                              ?????? IS ATTRIBUTE_0 COMMONLY THE NAME OF THE POLYGON ????????
;                        ADDED KEYWORD MAPP (MAP) IN ORDER TO RESET THE MAP DOMAIN WITH EACH ENTITY
;                        NOW WRITING A SAV FILE WITH THE MAP AND SHAPEFILE SPECIFIC INFORMATION
;                        ADDED FILE_MAKE STEP TO DETERMINE IF THE SAV FILE NEEDS TO BE CREATED
;                        ADDED OVERWRITE KEYWORD
;   DEC 12, 2016 - KJWH: ADDED SUBS TO THE OUTPUT STRUCTURE
;   DEC 17, 2016 - JEOR: FIXED WHEN ATTRIB.ATTRIBUTE_0 IS NUMERIC:
;                        TAG = STRUCT_TAGNAMES_FIX(STRTRIM(ATTRIB.ATTRIBUTE_0,2))  ; ASSUMES THE POLYGON NAME IS IN ATTRIBUTE_0
;   FEB 08, 2017 - JEOR: MASTER_STRUCT=CREATE_STRUCT(MASTER_STRUCT,STRUCT_TAGNAMES_FIX(FP.NAME),STR)
;                        NAME_TAG = 'NAME_' +STRUCT_TAGNAMES_FIX(FP.NAME);PREPEND 'NAME_' TO AVOID DUPLICATE TAGNAME
;                        KIM WE NEED TO STREAMLINE THE OUTPUT STRUCT
;   FEB 09, 2017 - JEOR: ;===> WORKAROUND ?? PGM STOPPING [MYSTERY]
;                        IF AVALUE EQ '' THEN CONTINUE;>>>>>>>>
;                        CHANGED MP TO MAPP [MAP PROJECTION- EASIER TO RECOGNIZE AND SEARCH THAN MP]
;                        MASTER_STRUCT=CREATE_STRUCT(MASTER_STRUCT,STRUCT_TAGNAMES_FIX(FP.NAME),STR)
;                        IF EXISTS(OUTFILE) THEN STR = STRUCT_READ(OUTFILE) ELSE STR = ''
;   FEB 12, 2017 - JEOR: ADDED CODE TO GET COORDS OF PIXELS INSIDE POLYGONS
;                        [NOT JUST THE LONS/LATS OF THE POLY OUTLINES AS BEFORE]
;                        REMOVED ZWIN INSIDE,AT END OF FOR SEG=0, ENTITY.N_PARTS-1 DO BEGIN
;                        BECAUSE THIS WAS SETTING THE DEFAULT WINDOW TO WIN PREMATURELY [WHEN MORE THAN ONE ENTITY.N_PARTS
;                        ADDED AT END IF !D.NAME EQ 'Z' THEN ZWIN
;                        !! MAJOR REVISION/REVERSION: REMOVED LOOP ON FILES [THIS MUST BE DONE BY AN OUTSIDE CALLING PROGRAM]
;                        [OTHERWISE IT IS NOT CLEAR WHICH SHAPE FILE THE RETURNED LONS & LATS ARE FOR]
;   FEB 19, 2017 - JEOR: ADDED CATCH BLOCK TO PRINT ERROR STRING
;                        COPIED KEY STRUCT COMPONENTS FROM KIM'S PLT_SHP_LOOP
;                        ADDED FOR LOOP TO THIS PROGRAM
;                        TESTED WITH OVERWRITE = 0 AND 1 USING REGION ECOREGIONS
;                        GREATLY STREAMLINED THE NESTED OUTPUT STRUCT:
;                        1) FILE_STRUCT IS NOW DEFINED NEAR THE END OF THE PROGRAM TO GATHER UP PREVIOUS INFO;
;                        2) FILE_STRUCT NOW CONTAINS ONLY USEFUL INFORMATION [NOT REFERENCES TO NULL POINTERS,ETC];
;                        3) FILE_STRUCT NOW CONTAINS ONLY USEFUL INFO FROM THE ENT STRUCTURE [SHAPE_TYPE,ISHAPE,BOUNDS,N_PARTS,N_VERTICES ];
;                        4) ADDED LONS & LATS TO FILE_STRUCT [CRITICALLY NEEDED BY SUBAREAS_EXTRACT]
;                        5) WITH THE NEW FILE_STRUCT THE SUBS MAY BE EASILY OBTAINED AS:  SUBS = STRUCT_GET(STRUCT.(0),'SUBS').
;                        6) WHEN ONLY ONE SHAPEFILE, THE FILE_STRUCT IS SAVED AS STRUCT
;   FEB 22, 2017 - KJWH: Removed redundant code
;                        Move the defaults to the beginning before the FILES loop
;                        Added KEY(VERBOSE) statements
;                        Now saving the FILE_STRUCT for each SHAPEFILE - previously only saving if there was a single SHAPEFILE
;                        Formatting
;   FEB 23, 2017 - KJWH: Changed the LONS and LATS variables associated with reading the SHAPEFILE to LON and LAT in order to avoid issues with later variables also called LONS and LATS
;                        Removed LONS and LATS from the output structure and from the keywords
;                        If the map is a L3B, then use the corresponding GL map to get the LONS and LATS, then MAPS_L3B_LONLAT_2BIN to get the bins/subscripts
;                        Removed COLOR and IMG from the output structure (IMG made the structure unnecessarily too big)
;   FEB 24, 2017 - KJWH: Changed MAPS_MAP_OR_L3BMAP to MAPS_L3B_OR_MAP
;   MAR 10, 2017 - KJWH: Removed the FILL keyword - Now returning both the outline and the filled in structure for each subarea.
;   MAR 15, 2017 - KJWH: Added OUTLINE (the subscripts for the outline of the polygon) to each SUBREGION structure and a combined OUTLINE_SUBS for all subregions
;   JUN 13, 2017 - KJWH: Overhauled program, changed the name from PLT_SHP to READ_SHPFILE, and changed it from a program to a function
;                        Removed unused/unnecessary keywords - COLOR, THICK, DO_ALL, VALUE, AUTO, PSYM, SYMSIZE
;                        Changed keyword TAGNAME to ATT_TAG, now looking for the first "STRING" attribute to get the attribute name if not provided.
;                        Added a CONTINUE step for when no subscripts from the shapefile entity are found within the MAP MESSAGE,'ERROR: No subscripts found in map ' + MP, /CONTINUE  ;===> CONVERT SUBS OF IMG TO LONS & LATS [ONLY WHEN SUBS NE ''] & CONTINUE
;                        Removed the START_ENT and END_ENT variables and the FOR _EN = START_ENT, END_ENT DO BEGIN loop because it was a loop of ENTITIES inside of a loop of ENTITIES
;                        Added IF ENT.SHAPE_TYPE EQ 3 THEN PLOTS, X, Y, PSYM=3, SYMSIZE=3, COLOR=_COLOR, THICK=1, /DATA to plot the polylines (instead of using POLYFILL)
;                        If no OUTLINE_SUBS then don't add to the output structure
;   JUN 21, 2017 - KJWH: Changed the location of the output files from !S.IDL_SHAPEFILES to !S.IDL_SHAPEFILES + 'SAVES' + SL
;                        Now using the *ENT.VERTICES for the outline LON and LAT values
;                        Now using PLOT to get the subscripts for the OUTLINE
;   AUG 24, 2017 - KJWH: Now using IS_L3B to determine if the input map is L3B - IF IS_L3B(MAPP) THEN MP = MAPS_L3B_OR_MAP(MAPP) ELSE MP = MAPP
;   AUG 25, 2017 - KJWH: Fixed issue when getting the subscripts for the L3B files - Added MAPS_L3BGS_SWAP to get accuract subscripts
;   NOV 27, 2017 - KJWH: Added OUTFILE keyword
;   FEB 18, 2018 - KJWH: Added steps to create PNG image(s) of the subareas
;                        Removed COLORS from the output structure, but added it as an optional output keyword
;   MAR 08, 2018 - KJWH: Changed IF NTAGS LT 1000 AND FILE_MAKE(OUTFILE,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
;                             to IF NTAGS GT 1000 AND FILE_MAKE(OUTFILE,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
;   MAR 14, 2018 - KJWH: Changed POS = WHERE(TAGS,'OUTLINE',COMPLEMENT=COMPLEMENT)
;                             to POS = WHERE_STRING(TAGS,'OUTLINE',COMPLEMENT=COMPLEMENT)
;   MAR 23, 2018 - KJWH: Added IF IDLTYPE(FILE_STRUCT.(S)) NE 'STRUCT' THEN CONTINUE in the PNG step
;                        Changed IF IS_L3B(MAPP) THEN IM = MAPS_L3BGS_SWAP(BLK) to IF IS_L3B(MAPP) THEN IM = MAPS_L3BGS_SWAP(IM) (in the PNG step)
;   AUG 16, 2018 - KJWH: Added COLORS to POS = WHERE_STRING(TAGS,['OUTLINE','COLORS'],COMPLEMENT=COMPLEMENT) in the subarea plotting steps
;   OCT 16, 2018 - KJWH: Added R = SHAPEFILE_2LONLAT(SHAPEFILE,MP=MAPP) to create LONLAT files of the outline
;                        Changed LAND = READ_LANDMASK(MAPP) to LAND = READ_LANDMASK(MP)
;   MAR 08, 2019 - KJWH: Added VERBOSE and OVERWRITE keywords to the SHAPEFILE_2LONLAT call
;                        Added IF N_ELEMENTS(SHAPEFILE) NE 1 THEN SHAPEFILE = DIALOG_PICKFILE(TITLE='PICK A SHAPEFILE')
;                        Removed IF NONE(COLOR)           THEN _COLOR = 10                ELSE _COLOR = COLOR
;                        Changed FILES to SHP - Now just need to input the SHP directory name
;   SEP 24, 2019 - KJHW: Fixed a bug when creating images for L3B maps.  Now using the landmask from the L3B and converting it to a GS map just before saving.
;   JUN 11. 2020 - KJWH: Now only reading one shapefile at a time.
;                        Removed the MASTER_STRUCT
;                        Added a MAPPED_IMAGE to the output structure
;   JUL 08, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed subscript () to []                     
;   OCT 01, 2020 - KJWH: Updated documentation
;                        Changed MAP_GET_RANGE to MAPS_GET_RANGE
;                        Removed unused keywords           
;   NOV 03, 2020 - KJWH: Found a bug when reading the LME66 shapefile with the Central Arctic polygon
;                          Added _COLOR+1 to POLYFILL, X, Y, /DATA, COLOR=_COLOR+1, _EXTRA=_EXTRA  
;   OCT 14, 2021 - KJWH: Added steps to convert UTM units to lon/lat if found in the shapefile.
;                        TODO: Convert the reading and parsing of the .prj file to a function
;                        CAUTION: This will need to be updated for other datums                                               
;   NOV 29, 2021 - KJWH: Now will create the PNG images if the SAV file is already present, but the PNGs are not
;                        Updated the color scaling for the PNG images 
;   JAN 31, 2022 - KJWH: Added updates to work with "point" shapefiles
;                          - Added step to look for UTC lon/lats
;                          - Now creating a png with the points data (but skipping plotting individual point maps)
;                          - Added "point" information to the output structure
;                          - Now only adding the "outlines" if the shapes are polygons
;   MAY 10, 2022 - KJWH: Added the SUBAREA_TITLE to the output structure if found in the shapefile. NOTE - only works with locally created shapefiles                       
;-
;#################################################################################################

  ROUTINE_NAME= 'READ_SHPFILE'
  COMPILE_OPT IDL2


  SL = PATH_SEP()
  PAL_LANDMASK,RR,GG,BB


  IF N_ELEMENTS(MAPP) NE 1 THEN MESSAGE, 'ERROR: Must provide a single valid map name'
  IF IS_L3B(MAPP) THEN BEGIN
    MP = MAPS_L3B_OR_MAP(MAPP)
    L3B = MAPP
    LAND = READ_LANDMASK(L3B)
  ENDIF ELSE BEGIN
    MP = MAPP
    L3B = []
    LAND = READ_LANDMASK(MP)
  ENDELSE


  IF N_ELEMENTS(SUBAREA) NE 1 THEN MESSAGE, 'ERROR: Must input one SHP name'

  SHP = STRUPCASE(SUBAREA)

  ;SAVDIR    = !S.SHAPEFILES + 'SAVES' + SL
  PNGDIR    = !S.SHAPEFILES + 'PNGS'  + SL & DIR_TEST, PNGDIR
  OUTDIR    = !S.SHAPEFILES + 'OUTLINES' + SL & DIR_TEST, OUTDIR
  SHPDIR    = !S.SHAPEFILES + 'SHAPES' + SL + SHP + SL & DIR_TEST, SHPDIR
  SHAPEFILE = SHPDIR + SHP + '.shp'
  PRJFILE   = SHPDIR + SHP + '.prj' & IF FILE_TEST(PRJFILE) EQ 0 THEN PRJFILE   = SHPDIR + SHP + '.PRJ'
  IF FILE_TEST(SHAPEFILE) EQ 0 THEN MESSAGE, 'ERROR: ' + SHAPEFILE + ' does not exist'

  FP = FILE_PARSE(SHAPEFILE)
  SHPPNG = FP.DIR + 'PNGS' + SL + STRUPCASE(MP) + SL
  OUTFILE   = SHPDIR + STRUPCASE(MP + '-' + FP.NAME + '.SAV')

  R = SHAPEFILE_2LONLAT(SHAPEFILE,MAPP=MP,VERBOSE=VERBOSE,OVERWRITE=OVERWRITE) ; Create .SAV and .CSV outputs of the LONS and LATS of the outline (could probably done within this program, but was written later)

  IF FILE_MAKE(SHAPEFILE,OUTFILE,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN
    FILE_STRUCT = IDL_RESTORE(OUTFILE) ; If SAV file already exists, read it and return the info in the SAV file
    GOTO, CHECK_PNGS
  ENDIF

  RANGE_LON =[MISSINGS(0.),-MISSINGS(0.)] & RANGE_LAT = RANGE_LON  ;===> INITIALIZE RANGE_LON,RANGE_LAT

  SHAPEFILEOBJ=OBJ_NEW('IDLFFSHAPE',SHAPEFILE)                                                                                                     ; ===> OPEN THE SHAPEFILE
  SHAPEFILEOBJ -> IDLFFSHAPE::GETPROPERTY, N_ENTITIES=N_ENTITIES,ENTITY_TYPE=ENTITY_TYPE,N_ATTRIBUTES=N_ATTRIBUTES,ATTRIBUTE_NAMES=ATTRIBUTE_NAMES ; ===> GET THE NUMBER OF ENTITIES, NUMBER OF ATTRIBUTES, AND ATTRIBUTE NAMES FROM SHAPEFILEOBJ
  ENTITIES = SHAPEFILEOBJ -> IDLFFSHAPE::GETENTITY(/ALL,/ATTRIBUTES)                                                                               ; ===> GET THE ENTITIES
  ATTR = SHAPEFILEOBJ -> IDLFFSHAPE::GETATTRIBUTES(/ALL,/ATTRIBUTE_STRUCTURE)                                                                      ; ===> GET THE ATTRIBUTES

  IF KEY(VERBOSE) THEN PRINT,'N_ENTITIES = ',N_ENTITIES
  IF KEY(VERBOSE) THEN PRINT,'N_ATTRIBUTES = ',N_ATTRIBUTES
  IF KEY(VERBOSE) THEN PRINT,'ATTRIBUTE_NAMES = ',ARR_2STR(ATTRIBUTE_NAMES)
  IF KEY(VERBOSE) THEN PRINT

  ;===> GET ALL ENTITIES
  ENTITIES = PTR_NEW(/ALLOCATE_HEAP)
  *ENTITIES = SHAPEFILEOBJ -> GETENTITY(/ALL, /ATTRIBUTES)

  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  COLORS = []                             ; Set up a null array to hold the COLORS of the entities
  TAGS = []                               ; Set up a null array to hold the TAGNAMES for each entities
  FILE_STRUCT = []                        ; Set up a null structure for the file specific structure
  OUTLINE_SUBS = []                       ; SET up a null array to hold all of the subscripts for the outlines of all polygons in each file
  POINTS_SUBS = []                        ; Set up a null array to hold the subscripts for the points
  FINAL_IMAGE = MAPS_BLANK(MP,FILL=-1)    ; SET up a blank map to hold the final image

;  FOR _ENT=0, N_ELEMENTS(*ENTITIES)-1 DO BEGIN ; Loop through all ENTITIES
;    ENT = SHAPEFILEOBJ->IDLFFSHAPE::GETENTITY(_ENT,/ATTRIBUTES)
;    ENTITY = (*ENTITIES)[_ENT]
;    ATT = SHAPEFILEOBJ->GETATTRIBUTES(_ENT)
;    IF KEYWORD_SET(VERBOSE) THEN PRINT, ATT.(0)
;  ENDFOR


  FOR _ENT=0, N_ELEMENTS(*ENTITIES)-1 DO BEGIN ; Loop through all ENTITIES
    ENT = SHAPEFILEOBJ->IDLFFSHAPE::GETENTITY(_ENT,/ATTRIBUTES)
    ENTITY = (*ENTITIES)[_ENT]
    ATT = SHAPEFILEOBJ->GETATTRIBUTES(_ENT)
    IF KEYWORD_SET(VERBOSE) THEN PRINT, ATT.(0)

    ATTINDEX = []
    IF KEYWORD_SET(ATT_TAG) THEN BEGIN
      FOR A=0, N_ELEMENTS(ATT_TAG)-1 DO BEGIN
        ATTOK = WHERE(STRUPCASE(ATTRIBUTE_NAMES) EQ STRUPCASE(ATT_TAG[A]), /NULL)
        IF ATTOK EQ [] THEN MESSAGE, 'ERROR: Can not find ' + ATT_TAG + ' attribute in ' + SHAPEFILE $
                       ELSE ATTINDEX = [ATTINDEX,ATTOK]
      ENDFOR                 
    ENDIF

    _COLOR = (_ENT MOD 240)+10
    MAPS_SET, MP

    ; ===> GET XP AND YP INFO
    IF ENT.SHAPE_TYPE EQ 1 OR ENT.SHAPE_TYPE EQ 11 THEN BEGIN ; SHAPE_TYPE 1 are for X,Y points
      PLONS = []
      PLATS = []
      PTS = [ENT.VERTICES]
      LON = ENT.BOUNDS[0]
      LAT = ENT.BOUNDS[1]
      
      IF MIN(ABS(LON)) GT 180.0 AND MIN(ABS(LAT)) GT 90.0 THEN BEGIN  ; If the values exceed the expected lon/lat coordinates, then assume the coordinates are UTM
        IF FILE_TEST(PRJFILE) EQ 0 THEN MESSAGE, 'ERROR: Must include a projection (prj) file in ' + SHPDIR
        ; TODO: Convert to a function
        PRJ = READ_TXT(PRJFILE)
        PRJ = STR_BREAK(PRJ,'",')
        OK = WHERE_STRING(PRJ,'PROJCS["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Projection not found (or more than one found)'
        PROJ = STRUPCASE(STR_BREAK(REPLACE(PRJ[OK],'PROJCS["',''),'_'))
        IF WHERE(PROJ EQ 'UTM',/NULL) EQ [] THEN MESSAGE, 'ERROR: UTM not found in the projection name.'
        OK = WHERE(PROJ EQ 'ZONE',/NULL) & IF OK EQ [] THEN MESSAGE, 'ERROR: UTM zone not found.'
        ZONE = PROJ[OK+1]

        OK = WHERE_STRING(PRJ,'DATUM["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Datum not found (or more than one found)'
        DATUM = REPLACE(PRJ[OK],'DATUM["','')
        CASE DATUM OF
          'D_North_American_1983': DATUM='NAD83'
          ; Will need to update with other DATUM information as needed'
        ENDCASE

        LL = UTM_TO_LL(LON,LAT,DATUM,ZONE=ZONE,P=PMAP)
        LON = REFORM(LL[0,*])
        LAT = REFORM(LL[1,*])

      ENDIF
            
      RANGE_LON= MINMAX(LON)
      RANGE_LAT= MINMAX(LAT)
      ;===> CONVERT LON,LAT TO PIXEL COORDINATES
      XYZ = CONVERT_COORD(LON,LAT,/DATA,/TO_DEVICE)
      XP = ROUND(REFORM(XYZ[0,*])) & YP = ROUND(REFORM(XYZ[1,*]))
      XP = XP[0] & YP = YP[0]
      PX = !D.X_SIZE & PY = !D.Y_SIZE
      ;===> GET SUBSCRIPTS FOR A 3X3 BOX AROUND THE XP,YP POINT
      XY = IMG_XPYP([PX,PY])
      B = BOX_AROUND(BYTARR([PX,PY]), [XP,YP], SUBS=SUBS, AROUND=AROUND)
      ;===> CONVERT SUBS TO XPS,YPS  LAT
      XX = XY.X[SUBS] &  YY = XY.Y[SUBS]
      PLOTS, XX, YY, PSYM=3, SYMSIZE=5, COLOR=_COLOR+1, THICK=1, /DEVICE
      ;===> GET POINTS JUST PLOTTED AND CONVERT TO LONS,LATS
      IMG = TVRD()
      PSUBS = WHERE(IMG EQ _COLOR+1,COUNT,/NULL)
      IF COUNT GE 1 THEN BEGIN
        XY = ARRAY_INDICES(IMG,PSUBS)
        XP = REFORM(XY[0,*])
        YP = REFORM(XY[1,*])
        XYZ = CONVERT_COORD(XP,YP,/DEVICE,/TO_DATA)
        LON = REFORM(XYZ[0,*]) & LAT = REFORM(XYZ[1,*])
        
        IF KEYWORD_SET(VERBOSE) THEN PRINT, STRJOIN([LON,LAT],', ')
        POINTS_SUBS = [POINTS_SUBS, PSUBS]
        PLONS = [PLONS,LON]
        PLATS = [PLATS,LAT]
      ENDIF;IF COUNT GE 1 THEN BEGIN
      OSUBS = []
    ENDIF ELSE BEGIN ; IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN

      ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      ; ===> GET SUBSCRIPTS FOR THE OUTLINE
      OLONS = []
      OLATS = []
      ; ===> GET SUBSCRIPTS FOR THE POLYGON
      FOR SEG=0, ENT.N_PARTS-1 DO BEGIN
;        IF KEY(VERBOSE) THEN PRINT,'SHAPE_TYPE         :  ', ENT.SHAPE_TYPE
;        IF KEY(VERBOSE) THEN PRINT,'N PARTS            :  ', ENT.N_PARTS
;        IF KEY(VERBOSE) THEN PRINT,'N VERTICES         :  ', ENT.N_VERTICES
        
        SEGS = [*ENT.PARTS, ENT.N_VERTICES]
        X = REFORM((*ENT.VERTICES)[0, SEGS[SEG]:SEGS[SEG+1]-1]) 
        Y = REFORM((*ENT.VERTICES)[1, SEGS[SEG]:SEGS[SEG+1]-1]) 
        
        IF MIN(ABS(X)) GT 180.0 AND MIN(ABS(Y)) GT 90.0 THEN BEGIN  ; If the values exceed the expected lon/lat coordinates, then assume the coordinates are UTM
          IF FILE_TEST(PRJFILE) EQ 0 THEN MESSAGE, 'ERROR: Must include a projection (prj) file in ' + SHPDIR 
; TODO: Convert to a function
          PRJ = READ_TXT(PRJFILE)
          PRJ = STR_BREAK(PRJ,'",')
          OK = WHERE_STRING(PRJ,'PROJCS["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Projection not found (or more than one found)'
          PROJ = STRUPCASE(STR_BREAK(REPLACE(PRJ[OK],'PROJCS["',''),'_'))
          IF WHERE(PROJ EQ 'UTM',/NULL) EQ [] THEN MESSAGE, 'ERROR: UTM not found in the projection name.'
          OK = WHERE(PROJ EQ 'ZONE',/NULL) & IF OK EQ [] THEN MESSAGE, 'ERROR: UTM zone not found.'
          ZONE = PROJ[OK+1]
          
          OK = WHERE_STRING(PRJ,'DATUM["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Datum not found (or more than one found)'
          DATUM = REPLACE(PRJ[OK],'DATUM["','')
          CASE DATUM OF
            'D_North_American_1983': DATUM='NAD83'
            ; Will need to update with other DATUM information as needed'
          ENDCASE
          
          LL = UTM_TO_LL(X,Y,DATUM,ZONE=ZONE,P=PMAP)
          X = REFORM(LL[0,*])
          Y = REFORM(LL[1,*])
          
        ENDIF
        OLONS = [OLONS,X]
        OLATS = [OLATS,Y]
        
        MM_X =MINMAX(X) & MM_Y =MINMAX(Y)
        RANGE_LON[0] = MM_X[0] < RANGE_LON[0]
        RANGE_LON[1] = MM_X[1] > RANGE_LON[1]
        RANGE_LAT[0] = MM_Y[0] < RANGE_LAT[0]
        RANGE_LAT[1] = MM_Y[1] > RANGE_LAT[1]

        IF KEY(NORMAL) THEN BEGIN ; ===> CONVERT X, Y TO NORMAL COORDINATES
          NORMAL = 1 & DATA = 0 ; ===> THE ENTIRE GLOBE
          XRANGE=[0,1] &  YRANGE=XRANGE
          XYZ = CONVERT_COORD(X,Y,/DATA,/TO_NORMAL)
          X=REFORM(XYZ[0,*])
          Y=REFORM(XYZ[1,*])
          PLOT, XRANGE, YRANGE, XSTYLE=5, YSTYLE=5, POSITION=[0,0, 1,1], /NODATA,/NOERASE,NORMAL=NORMAL,DATA=DATA
        ENDIF ELSE BEGIN
          IF KEYWORD_SET(GET_RANGE) THEN BEGIN
            MAPS_GET_RANGE & XRANGE=!X.RANGE & YRANGE=!Y.RANGE
            PLOT, XRANGE, YRANGE, XSTYLE=5, YSTYLE=5, POSITION=[0,0, 1,1], /NODATA,/NOERASE,NORMAL=NORMAL,DATA=DATA,_EXTRA=_EXTRA
          ENDIF ; IF KEYWORD_SET(GET_RANGE) THEN BEGIN
          NORMAL = 0 & DATA = 1 ; DEFAULT
        ENDELSE ; IF KEYWORD_SET(NORMAL) THEN BEGIN

        PLOTS, X, Y, LINESTYLE=0, COLOR=_COLOR, THICK=1, /DATA
        IF PTR_VALID(ENTITY) THEN HEAP_FREE, ENTITY
      ENDFOR;FOR SEG=0, ENTITY.N_PARTS-1 DO BEGIN
      IMG = TVRD()
      OSUBS = WHERE(IMG EQ _COLOR,/NULL)
      
      ; ===> Get the X and Y for the outline
      OUTLINE_PXY = MAP_DEG2IMAGE(IMG,OLONS,OLATS,X=OPX,Y=OPY)
      
;if osubs eq [] then continue
      IF IS_L3B(MAPP) THEN BEGIN
        BLK = MAPS_BLANK(MP)
        BLK[OSUBS] = 1
        LBL = MAPS_L3BGS_SWAP(BLK)
        OSUBS = WHERE(LBL EQ 1,/NULL)  ;SUBS = MAPS_L3B_LONLAT_2BIN(MAPP,LONS,LATS)
      ENDIF

      OUTLINE_SUBS = [OUTLINE_SUBS,OSUBS]
      
      ; ===> GET SUBSCRIPTS FOR THE POLYGON
      FOR SEG=0, ENT.N_PARTS-1 DO BEGIN
        SEGS = [*ENT.PARTS, ENT.N_VERTICES]
        X = REFORM((*ENT.VERTICES)[0, SEGS[SEG]:SEGS[SEG+1]-1])
        Y = REFORM((*ENT.VERTICES)[1, SEGS[SEG]:SEGS[SEG+1]-1])
        
        IF MIN(ABS(X)) GT 180.0 AND MIN(ABS(Y)) GT 90.0 THEN BEGIN  ; If the values exceed the expected lon/lat coordinates, then assume the coordinates are UTM
          IF FILE_TEST(PRJFILE) EQ 0 THEN MESSAGE, 'ERROR: Must include a projection (prj) file in ' + SHPDIR
          ; TODO: Convert to a function
          PRJ = READ_TXT(PRJFILE)
          PRJ = STR_BREAK(PRJ,'",')
          OK = WHERE_STRING(PRJ,'PROJCS["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Projection not found (or more than one found)'
          PROJ = STRUPCASE(STR_BREAK(REPLACE(PRJ[OK],'PROJCS["',''),'_'))
          IF WHERE(PROJ EQ 'UTM',/NULL) EQ [] THEN MESSAGE, 'ERROR: UTM not found in the projection name.'
          OK = WHERE(PROJ EQ 'ZONE',/NULL) & IF OK EQ [] THEN MESSAGE, 'ERROR: UTM zone not found.'
          ZONE = PROJ[OK+1]

          OK = WHERE_STRING(PRJ,'DATUM["',COUNT) & IF COUNT NE 1 THEN MESSAGE, 'ERROR: Datum not found (or more than one found)'
          DATUM = REPLACE(PRJ[OK],'DATUM["','')
          CASE DATUM OF
            'D_North_American_1983': DATUM='NAD83'
            ; Will need to update with other DATUM information as needed'
          ENDCASE

          LL = UTM_TO_LL(X,Y,DATUM,ZONE=ZONE,P=PMAP)
          X = REFORM(LL[0,*])
          Y = REFORM(LL[1,*])

        ENDIF

        MM_X =MINMAX(X) & MM_Y =MINMAX(Y)
        RANGE_LON[0] = MM_X[0] < RANGE_LON[0]
        RANGE_LON[1] = MM_X[1] > RANGE_LON[1]
        RANGE_LAT[0] = MM_Y[0] < RANGE_LAT[0]
        RANGE_LAT[1] = MM_Y[1] > RANGE_LAT[1]

        IF KEY(NORMAL) THEN BEGIN ; ===> CONVERT X, Y TO NORMAL COORDINATES
          NORMAL = 1 & DATA = 0 ;===> THE ENTIRE GLOBE
          XRANGE=[0,1] &  YRANGE=XRANGE
          XYZ = CONVERT_COORD(X,Y,/DATA,/TO_NORMAL)
          X=REFORM(XYZ[0,*])
          Y=REFORM(XYZ[1,*])
          PLOT, XRANGE, YRANGE, XSTYLE=5, YSTYLE=5, POSITION=[0,0, 1,1], /NODATA,/NOERASE,NORMAL=NORMAL,DATA=DATA
        ENDIF ELSE BEGIN
          IF KEYWORD_SET(GET_RANGE) THEN BEGIN
            MAP_GET_RANGE & XRANGE=!X.RANGE & YRANGE=!Y.RANGE
            PLOT, XRANGE, YRANGE, XSTYLE=5, YSTYLE=5, POSITION=[0,0, 1,1], /NODATA,/NOERASE,NORMAL=NORMAL,DATA=DATA,_EXTRA=_EXTRA
          ENDIF ; IF KEYWORD_SET(GET_RANGE) THEN BEGIN
          NORMAL = 0 & DATA = 1 ; DEFAULT
        ENDELSE ; IF KEYWORD_SET(NORMAL) THEN BEGIN

        IF ENT.SHAPE_TYPE EQ 3 THEN PLOTS,    X, Y, LINESTYLE=0, COLOR=_COLOR+1, THICK=1, /DATA $
                               ELSE POLYFILL, X, Y, /DATA, COLOR=_COLOR+1, _EXTRA=_EXTRA

        IF PTR_VALID(ENTITY) THEN HEAP_FREE, ENTITY
      ENDFOR;FOR SEG=0, ENTITY.N_PARTS-1 DO BEGIN
    ENDELSE ; IF ENT.SHAPE_TYPE EQ 1 THEN BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

    IMG = TVRD()
    SUBS = WHERE(IMG EQ _COLOR+1,/NULL)
    FINAL_IMAGE[SUBS] = _ENT

    OUTLINE_SUBS = [OUTLINE_SUBS,OSUBS]
    ;IF OSUBS EQ [] THEN OSUBS = MISSINGS(OUTLINE_SUBS)
    COLORS = [COLORS,_COLOR+1] ; ===> RETURN _COLOR IN KEYWORD COLOR

    IF ATTINDEX EQ [] THEN BEGIN
      ATT_TYPE = []
      FOR A=0, N_ATTRIBUTES -1 DO ATT_TYPE = [ATT_TYPE,IDLTYPE(ATT.(A))]
      OKATT = WHERE(ATT_TYPE EQ 'STRING',COUNT_ATT)
      IF COUNT_ATT GE 1 THEN ATTINDEX = OKATT[0] ; ASSUMES THE POLYGON NAME IS THE FIRST "STRING" ATTRIBUTE
      IF COUNT_ATT GT 1 THEN TITLEINDEX = OKATT[-1] ELSE TITLEINDEX = [] ; ASSUMES THE TITLE IS THE LAST "STRING" - THIS IS ONLY TRUE FOR LOCALLY CREATED SHAPEFILES
    ENDIF
    IF ATTINDEX EQ [] THEN SUBAREA_NAME = SUBAREA + '_' + NUM2STR(_ENT) $ ; IF THERE IS NO STRING ATTRIBUTE, USE THE ENTITY NUMBER TO DESCRIBE THE SUBAREA
    ELSE BEGIN
      SUBAREA_NAME = []
      FOR A=0, N_ELEMENTS(ATTINDEX)-1 DO SUBAREA_NAME = [SUBAREA_NAME,STRTRIM(STRING(ATT.(ATTINDEX[A])),2)] 
      SUBAREA_NAME = STRJOIN(SUBAREA_NAME,'_')
     
      SUBAREA_TITLE=''
      IF TITLEINDEX NE [] THEN BEGIN
        STITLE = STRING(ATT.(TITLEINDEX))
        IF HAS(STITLE,'TITLE-') THEN SUBAREA_TITLE = REPLACE(STITLE,'TITLE-','') 
      ENDIF
    ENDELSE 
    
    IF SUBAREA_NAME EQ '' THEN SUBAREA_NAME = SUBAREA + '_' + NUM2STR(_ENT) ; IF THERE IS NO STRING ATTRIBUTE, USE THE ENTITY NUMBER TO DESCRIBE THE SUBAREA                
    IF SUBS EQ [] THEN BEGIN
      MESSAGE,'ERROR: No subscripts for subarea ' + SUBAREA_NAME + ' found in map ' + MP, /CONTINUE  ;===> CONVERT SUBS OF IMG TO LONS & LATS [ONLY WHEN SUBS NE '']
      CONTINUE
    ENDIF

    DIMS = SIZE(IMG, /DIMENSIONS)
    XY = ARRAY_INDICES(DIMS,SUBS,/DIMENSIONS)
    X = REFORM(XY[0,*])
    Y = REFORM(XY[1,*])
    XYZ = CONVERT_COORD(X,Y,/DEVICE,/TO_DATA)
    LONS=REFORM(XYZ[0,*])
    LATS=REFORM(XYZ[1,*])
    IF IS_L3B(MAPP) THEN BEGIN
      BLK = MAPS_BLANK(MP)
      BLK[SUBS] = 1
      LBL = MAPS_L3BGS_SWAP(BLK)
      SUBS = WHERE(LBL EQ 1,/NULL)  ;SUBS = MAPS_L3B_LONLAT_2BIN(MAPP,LONS,LATS)
    ENDIF

    OK = WHERE(TAGS EQ SUBAREA_NAME,COUNT)
    IF COUNT EQ 1 THEN SUBAREA_NAME = SUBAREA_NAME + '_' + NUM2STR(_ENT)
    TAGS = [TAGS, SUBAREA_NAME]
    ENT_STRUCT = CREATE_STRUCT('SHP_FILE',SHP,'MAP',MP,'SUBAREA',SUBAREA_NAME,'SUBAREA_TITLE',SUBAREA_TITLE,'SUBSCRIPT_NUMBER',_ENT,'SUBS',SUBS,'ENTITY',ENT,'ATTRIBUTES',ATT)
    IF OSUBS NE [] THEN ENT_STRUCT = CREATE_STRUCT(ENT_STRUCT,'OUTLINE',OSUBS,'OUTLINE_LONS',OLONS,'OUTLINE_LATS',OLATS,'OUTLINE_PX',OPX,'OUTLINE_PY',OPY)
    IF PSUBS NE [] THEN ENT_STRUCT = CREATE_STRUCT(ENT_STRUCT,'POINTS', PSUBS,'POINT_LONS',  PLONS,'POINT_LATS',  PLATS)

    FILE_STRUCT = CREATE_STRUCT(FILE_STRUCT,STRUCT_TAGNAMES_FIX(SUBAREA_NAME),ENT_STRUCT)
  ENDFOR ; FOR _ENT = 0,N_ELEMENTS(*ENTITIES) -1 DO BEGIN

  IF OUTLINE_SUBS NE [] THEN FILE_STRUCT = CREATE_STRUCT(FILE_STRUCT,'OUTLINE',OUTLINE_SUBS)       ; Add a tag at the main structure level for the subarea outlines
  IF POINTS_SUBS  NE [] THEN FILE_STRUCT = CREATE_STRUCT(FILE_STRUCT,'POINTS', POINTS_SUBS)        ; Add a tag at the main structure level for all of the points
  IF FINAL_IMAGE  NE [] THEN FILE_STRUCT = CREATE_STRUCT(FILE_STRUCT,'MAPPED_IMAGE',FINAL_IMAGE)   ; Add a tag at the main structure level of the final mapped image

  ; ===> CLOSE/DESTROY/FREE THE SHAPEFILE & ENTITIES
  IF OBJ_VALID(SHAPEFILE) THEN OBJ_DESTROY, SHAPEFILE
  IF PTR_VALID(ENTITIES) THEN PTR_FREE, ENTITIES;
  IF PTR_VALID(ENTITIES) THEN HEAP_FREE, ENTITIES;
  OBJ_DESTROY, SHAPEFILEOBJ

  SAVE, FILENAME=OUTFILE, FILE_STRUCT
  IF KEY(VERBOSE) THEN PFILE,OUTFILE

  IF !D.NAME EQ 'Z' THEN ZWIN ;===> IF ACTIVE CLOSE ZWIN

  ; ===> CREATE PNG IMAGES OF THE SHAPEFILES
  CHECK_PNGS:
  
  TAGS = TAG_NAMES(FILE_STRUCT)
  POS = WHERE_STRING(TAGS,['OUTLINE','COLORS','POINTS'],COMPLEMENT=COMPLEMENT)
  TAGS = TAGS[COMPLEMENT]
  NTAGS = N_ELEMENTS(TAGS)
  IF STRUCT_HAS(FILE_STRUCT,'OUTLINE') THEN OUTLINE_SUBS = STRUCT_GET(FILE_STRUCT,'OUTLINE') ELSE OUTLINE_SUBS = []
  IF STRUCT_HAS(FILE_STRUCT,'POINTS')  THEN POINTS_SUBS  = STRUCT_GET(FILE_STRUCT,'POINTS')  ELSE POINTS_SUBS  = []

  FULL_IMG = LAND
  OUT_IMG  = LAND

  
  ;SUBPNGDIR = PNGDIR + FP.NAME + SL + MP + SL
  PNG =  SHPDIR + MP + '-' + SHP + '.PNG'
  FPNG = PNGDIR + MP + '-' + SHP + '.PNG'
  OPNG = OUTDIR + MP + '-' + SHP + '-OUTLINE.PNG'
  PPNG = OUTDIR + MP + '-' + SHP + '-POINTS.PNG'
  PNGS = SHPPNG[0] + TAGS[0:-1] + '-' + MP[0] + '.PNG'
  IF NTAGS GT 1000 AND FILE_MAKE(OUTFILE,[PNG,OPNG,FPNG],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  IF FILE_MAKE(OUTFILE,[PNG,PNGS,OPNG,PPNG],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  IF OUTLINE_SUBS NE [] AND POINTS_SUBS EQ [] AND FILE_MAKE(OUTFILE,[PNG,PNGS,OPNG],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  IF OUTLINE_SUBS EQ [] AND POINTS_SUBS NE [] AND FILE_MAKE(OUTFILE,[PNG,PNGS,PPNG],OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  
  CLRS = BINDGEN(250)+1
  SC = SCALE([1,250],[0,NTAGS],INTERCEPT=INTERCEPT,SLOPE=SLOPE)
  IF NTAGS LT 250 THEN CLRS = 0 > (CLRS-FLOAT(INTERCEPT))/FLOAT(SLOPE) < 250 ELSE WHILE N_ELEMENTS(CLRS) LT NTAGS DO CLRS = [CLRS,BINDGEN(250)+1]
  IF NTAGS GT 1000 THEN PRINT, 'NOTE: THERE ARE MORE THAN 1000 SUBAREAS SO ONLY THE COMBINED SUBAREA PNG WILL BE SAVED' ; DON'T WRITE OUT IMAGES FOR SHAPEFILES THAT HAVE AN EXCESS NUMBER OF SUBAREAS
  IF NTAGS LE 1000 THEN DIR_TEST, SHPPNG

  OUTSUBS = []
  FOR S=0, NTAGS-1 DO BEGIN
    IF IDLTYPE(FILE_STRUCT.(S)) NE 'STRUCT' THEN CONTINUE
    IMG_SUBS = FILE_STRUCT.(S).SUBS
    IF STRUCT_HAS(FILE_STRUCT.(S),'OUTLINE') THEN OSUBS = FILE_STRUCT.(S).OUTLINE ELSE OSUBS = []
    IF STRUCT_HAS(FILE_STRUCT.(S),'POINTS')  THEN PSUBS = FILE_STRUCT.(S).POINTS  ELSE PSUBS = []
    IM = LAND
    IM[IMG_SUBS] = 230
    FULL_IMG[IMG_SUBS] = CLRS[S]
    IF OSUBS NE [] THEN BEGIN
      IM[OSUBS] = 170
      OUT_IMG[OSUBS] = 230
      SAVE_OUTLINE = 1
    ENDIF
    IF PSUBS NE [] THEN BEGIN
      IM[PSUBS] = 180
      OUT_IMG[PSUBS] = 240
      FULL_IMG[PSUBS] = 240
      SAVE_POINT = 1
    ENDIF
    IF FILE_MAKE(OUTFILE,PNGS[S],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    IF NTAGS GT 1000 THEN CONTINUE          ; DON'T WRITE OUT IMAGES FOR SHAPEFILES THAT HAVE AN EXCESS NUMBER OF SUBAREAS
    IF N_ELEMENTS(PSUBS) EQ 1 THEN CONTINUE ; Don't write out images for individual points
    IF KEY(L3B) THEN IM = MAPS_L3BGS_SWAP(IM)
    WRITE_PNG,PNGS[S], IM, RR,GG,BB  &  IF KEY(VERBOSE) THEN PFILE,PNGS[S]
  ENDFOR ; TAGS
  IF FILE_MAKE(OUTFILE,PNG,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
    FOUT_IMG = FULL_IMG
    IF OUTLINE_SUBS NE [] THEN FOUT_IMG[OUTLINE_SUBS] = 200
    IF POINTS_SUBS  NE [] THEN FOUT_IMG[POINTS_SUBS]  = 240
    IF KEY(L3B) THEN BEGIN
      FULL_IMG = MAPS_L3BGS_SWAP(FULL_IMG)
      FOUT_IMG = MAPS_L3BGS_SWAP(FOUT_IMG)
      OUT_IMG  = MAPS_L3BGS_SWAP(OUT_IMG)
    ENDIF
    WRITE_PNG, PNG,  FULL_IMG, RR,GG,BB
    WRITE_PNG, FPNG, FOUT_IMG, RR,GG,BB
    IF KEYWORD_SET(SAVE_OUTLINE) THEN WRITE_PNG, OPNG, OUT_IMG, RR,GG,BB
    IF KEYWORD_SET(SAVE_POINT)   THEN WRITE_PNG, PPNG, OUT_IMG, RR,GG,BB
    IF KEY(VERBOSE) THEN PFILE, PNG
  ENDIF
  DONE:
  RETURN, FILE_STRUCT

END; #####################  END OF ROUTINE ################################
