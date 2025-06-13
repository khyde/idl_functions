; $ID:	SUBAREAS_IMAGE_2SHP.PRO,	2023-09-21-13,	USER-KJWH	$

PRO SUBAREAS_IMAGE_2SHP, FILE, SHPFILE=SHPFILE, SUBAREA_CODES=SUBAREA_CODES, LINE=LINE, REGION=REGION, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE

;+
; NAME:
;		SUBAREAS_IMAGE_2SHP
;
; PURPOSE:	
;   This procedure makes a shape file for a mapped subarea mask-image
;
; CATEGORY:
;		Subareas family
;		
; CALLING SEQUENCE:
;   SUBAREAS_IMAGE_2SHP, FILE, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
;
; INPUTS: 
;   FILE....... Full name of the subarea mask SAV file
;   
; OPTIONAL INPUTS:  
;  SHPFILE..... Optional file name for the output shapefile
;  DIR_OUT..... Optional directory name for the output directory
;  
; KEYWORDS:
;    VERBOSE... Will make an xy plot of lon vs lat
;    OVERWRITE. Overwrites output if it already exists 
;    	
; OUTPUTS:
;		 A SHP file [shape file] that includes all of the subareas found in the input file
;
; EXAMPLE:
;   SUBAREAS_IMAGE_2SHP,!S.SUBAREAS+'MASK_SUBAREA-NEC-PXY_1024_1024-GFISH4.SAV',OVERWRITE=1
; 
; NOTES:
; 
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written on June 4, 2014 by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  Inquiries should be directed to kimberly.hyde@noaa.gov.
; 
; MODIFICATION HISTORY:
;			JUN 05, 2014 - JEOR: ENTNEW.VERTICES = PTR_NEW(LONLAT , /ALLOCATE_HEAP, /NO_COPY ) 
;     JUN 07, 2014 - JEOR: GETTING LON LAT DIRECTLY FROM PATH_INFO & PATH_XY
;     JUN 08, 2014 - JEOR: ADDED KEYWORDS MASKFILE,CSVFILE
;                            CLOSED=0 TO AVOID INCLUDING OUTSIDE BOUNDARIES IN OUTPUT
;                            ADDED CHECK THAT SUBAREA_CODES IN CSVFILE MATCH COLORS IN MASKFILE
;                            ADDED ENTITIES IN LOOP ON PATH_INFO TO DEAL WITH UNCONNECTED SUBAREAS 
;                            [E.G. SNE NEAR SHORE HAS 2 COLOR BLOBS]
;    JUN 15, 2014 - JEOR: PAL_SUBAREAS
;    APR 12, 2015 - KJWH: CHANGED INPUT TO FILE AND REMOVED CSV LOGIC
;                           READ THE SAVEFILE INSTEAD OF THE PNG AND CSV
;                           REMOVED SET_PLOT AND FONT_HELVETICA
;                           ADDED - IF SUBAREA EQ 'LAND' OR SUBAREA EQ 'COAST' OR SUBAREA EQ 'OPEN_OCEAN' OR SUBAREA EQ 'OCEAN' THEN CONTINUE
;                           ADDED - MAP ATTRIBUTE TO SHP FILE
;    APR 16, 2015 - JEOR: USING KIM'S NEW SAV FILES [WHICH INCLUDE REGION]                      
;                           ADDED - MAP ATTRIBUTE TO SHP FILE
;		 MAY 05, 2015 - JEOR: RESTORED EARLIER VERSION OF SUBAREAS_MASK_2SHP TO FIX GSSOUTH SUBAREA
;		                        SUBAREA = STRUPCASE(REPLACE(STRTRIM(SUBAREA),' ', '_'))
;    MAY 07, 2015 - JEOR: XOFFSET,YOFFSET 
;    MAY 08, 2015 - JEOR: CONTOUR,DOUBLE(COPY)  [DOUBLE FOR GREATER ACCURACY]
;    NOV 22, 2017 - KJWH: Changed PLT_SHP to READ_SHPFILE
;    NOV 27, 2018 - KJWH: Changed name from SUBAREAS_MASK_2SHP to SUBAREAS_IMAGE_2SHP.  
;                           Now creating a single output SHP file from the multiple subareas within the image
;                           Added IF FILE_MAKE(FILE,SHP_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
;                           Added SH = READ_SHPFILE(SNAME, MAPP=AMAP) at the end to make the final .SAV and .PNG files
;    JUL 08, 2020 - KJWH: Added COMPILE_OPT IDL2
;                         Changed subscript () to []
;                         Added SHP->GetProperty, N_ENTITIES=NUM_ENTITIES to correctly indentify the attribute index
;                         Added COUNTER = 0 and COUNTER = COUNTER + 1 to correctly indentify if the loop should create a new shapefile or update an existing one
;    MAY 10, 2022 - KJWH: Added SUBAREA_TITLE to the output attributes if found in the input .SAV file (note, needs to be tested with a file that does not have the SUBAREA_TITLE in the structure)
;    DEC 12, 2023 - KJWH: Added LINE keyword to indicate the input data area  line and not a polygon
;                         Removed the "region" attribute in the output file 
;-
;##############################################################################
  ROUTINE_NAME  = 'SUBAREAS_IMAGE_2SHP'
  COMPILE_OPT IDL2

  SL = PATH_SEP()
  METHOD = 'IDL_' + ROUTINE_NAME
  CREATOR = 'K.Hyde NOAA/NEFSC'

; ===> CONSTANTS
  MIN_PTS = 10
  BKGR    = 255B
  XOFFSET = -1.5
  YOFFSET = .5
  NULL_NAMES = ['OCEAN','OPEN_OCEAN','LAND','COAST','LAKE','LAKESIDE','SMALL_LAKE','SMALL_LAKESIDE'] ; LANDMASK CODE NAMES

; ===> Read the mask and key info from the sav file
  FP = FILE_PARSE(FILE)
  NAMES = STR_BREAK(FP.NAME,'-')
  IF NONE(SHPFILE) THEN SNAME = NAMES[-1] ELSE SNAME = SHPFILE
  
; ===> Read the .SAV file to get the MAP
  MASK = STRUCT_READ(FILE,STRUCT=S)  
  AMAP   = S.MAP
  
; ===> Create the output file name and check if it exists  
  IF NONE(DIR_OUT) THEN DIR_OUT = !S.IDL_SHAPEFILES + 'SHAPES' + SL + SNAME + SL
  DIR_TEST, DIR_OUT
  IF NONE(SHPFILE) THEN SHP_FILE = SNAME + '.shp' ELSE SHP_FILE = SHPFILE
  FF = FILE_PARSE(SHP_FILE)
  IF FF.DIR EQ '' THEN SHP_FILE = DIR_OUT + SHP_FILE
  SHP_FILE = REPLACE(SHP_FILE,FF.EXT,'shp') ; Make sure the extension is a lowercase "shp"

  IF FILE_MAKE(FILE,SHP_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE
  IF EXISTS(SHP_FILE) THEN FILE_DELETE, SHP_FILE
    
  SZ = SIZEXYZ(MASK, PX=PX, PY=PY)
  IF ~HAS(S,'SUBAREA_CODE') OR ~HAS(S,'SUBAREA_NAME') THEN BEGIN ; REPLACE OLD TAG NAMES WITH NEW
    S = STRUCT_RENAME(S,['CODE_NAME_MASK','CODE_MASK'],['SUBAREA_NAME','SUBAREA_CODE']) 
  ENDIF

  CODES  = S.SUBAREA_CODE
  NAMES  = S.SUBAREA_NAME
  IF HAS(S,'SUBAREA_TITLE') THEN TITLES = S.SUBAREA_TITLE ELSE TITLES=[]
  
  IF ANY(SUBAREA_CODES) THEN BEGIN
    OK = WHERE_MATCH(FIX(CODES),SUBAREA_CODES,COUNT)
    IF COUNT GT 1 THEN BEGIN
      CODES = CODES[OK]
      NAMES = NAMES[OK]
      TITLES = TITLES[OK]
    ENDIF
  ENDIF
  
  
  SOURCE = (FILE_PARSE(FILE)).NAME
  REG = SUBAREAS_REGION(FILE)
  IF HAS(S,'REGION') THEN IF ~NONE(S.REGION) THEN REG = S.REGION
  IF ~NONE(REGION)  THEN REG = REGION
  
  
; ===> Loop through the subareas 
  COUNTER = 0
  FOR N=0L,N_ELEMENTS(CODES)-1 DO BEGIN
  	ACODE = CODES[N]
  	ANAME = STRUPCASE(REPLACE(NAMES[N],[' ','<','>'],['_','LT','GT']))
  	IF TITLES NE [] THEN ATITLE = 'Title:'+TITLES[N] ELSE ATITLE = 'NA'
  	OK = WHERE_MATCH(ANAME,NULL_NAMES,COUNT)
  	IF COUNT EQ 1 THEN CONTINUE ;>>>>>>>>>>>>

  	COPY=MASK
    COPY[*,*] = BKGR
    OK = WHERE(MASK EQ ACODE, COUNT_COLOR)
    COPY[OK] = 1B  
    IF COUNT_COLOR LT 1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>> Continue if code/color not found in the image

    ; ===> GET THE COORDINATES OF THE POLYGON IN THE MAPPED IMAGE USING CONTOUR
    ZWIN                            ; CLOSE OUT PREVIOUS ZWIN SO MAPS_SET STARTS WITH A 'CLEAN SLATE'
    MAPS_SET,AMAP,PX=PX,PY=PY       ; SET UP THE "MAP" AREA
    TV,COPY
    TARGET = 26
    ZWIN

    CONTOUR,DOUBLE(COPY),XSTYLE=5,YSTYLE=5,XMARGIN=[0,0],YMARGIN=[0,0],POSITION=[0,0,1,1],C_COLORS=TARGET,CLOSED=0, $ ; CONTOUR TO GET THE PATH_INFO FOR THE OUTLINES OF THE SUBAREA BLOBS
      /PATH_DATA_COORDS,/NOERASE, PATH_INFO=PATH_INFO,PATH_XY=PATH_XY,/PATH_DOUBLE,/FOLLOW
    
    IF N_ELEMENTS(PATH_INFO) LT 1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>> Continue if CONTOUR was not able to draw a polygon
    
    OK =WHERE(PATH_INFO.N GE MIN_PTS AND PATH_INFO.LEVEL EQ 1,COUNT_PATH) ; THIN PATH_INFO TO WHERE PATH_INFO.N GE MIN_PTS
    IF COUNT_PATH LT 1 THEN BEGIN
      PRINT,'ERROR: PATH_INFO NOT FOUND, SKIPPING TO NEXT SUBREGION...'
      CONTINUE;>>>>>>>>>>
    ENDIF
    
 ;   STRUCT=REPLICATE({TYPE:0B, HIGH:0B, LEVEL:0, NUM:0L, VALUE:0.0,X:'',Y:''},N_ELEMENTS(PATH_INFO))
    MAPS_SET,AMAP
    LON = [] & LAT = []
    FOR IN = 0,N_ELEMENTS(PATH_INFO)-1 DO BEGIN ; Loop through the PATH_INFO
      S = INDGEN(PATH_INFO[IN].N)
      XX = REFORM(PATH_XY[0,PATH_INFO[IN].OFFSET + S ])
      YY = REFORM(PATH_XY[1,PATH_INFO[IN].OFFSET + S ])

      ;===> ADD X,Y OFFSET [EMPIRICALLY DETERMINED]
      XX = XX + XOFFSET
      YY = YY + YOFFSET
      XYZ = CONVERT_COORD(XX,YY,/DEVICE,/TO_DATA)

      ;===> GET THE LONLAT INFO
      LON = [LON,DOUBLE(REFORM(XYZ[0,*]))]
      LAT = [LAT,DOUBLE(REFORM(XYZ[1,*]))]
    ENDFOR ; PATH_INFO
    ZWIN
    LONLAT = DBLARR(2,N_ELEMENTS(LON))
    LONLAT[0,*] = LON
    LONLAT[1,*] = LAT
    OFFSET = PATH_INFO.OFFSET
    N_PARTS = N_ELEMENTS(PATH_INFO)

    ; ===> CREATE THE NEW SHAPEFILE OR OPEN AN EXISTING SHAPEFILE 
    IF COUNTER EQ 0 THEN BEGIN
      SHP = OBJ_NEW('IDLFFSHAPE',SHP_FILE, /UPDATE, ENTITY_TYPE=5)  ; Define the ENTITY_TYPE as polygon (5)        
        
      ; ===> SET THE ATTRIBUTE DEFINITIONS FOR THE NEW SHAPEFILE
      SHP->ADDATTRIBUTE, 'SUBAREA', 7, MAX(STRLEN(STRTRIM(NAMES,2))),           PRECISION=0
      SHP->ADDATTRIBUTE, 'CODE',    7, STRLEN(STRTRIM(ACODE,2)),                PRECISION=0
      SHP->ADDATTRIBUTE, 'METHOD',  7, STRLEN(METHOD),                          PRECISION=0
      SHP->ADDATTRIBUTE, 'SOURCE',  7, STRLEN(SOURCE),                          PRECISION=0
      SHP->ADDATTRIBUTE, 'DATE',    7, STRLEN(DATE_NOW(/DATE_ONLY)),            PRECISION=0
      SHP->ADDATTRIBUTE, 'CREATOR', 7, STRLEN(CREATOR),                         PRECISION=0
      SHP->ADDATTRIBUTE, 'TITLE',   7, MAX(STRLEN(STRTRIM('Title:'+TITLES,2))), PRECISION=0

    ENDIF ELSE SHP = OBJ_NEW('IDLFFSHAPE',SHP_FILE, /UPDATE) ; Don't include the entity type if just updating the file

    ; ===> CREATE STRUCTURE FOR NEW ATTRIBUTES
    ATTRNEW = SHP->GETATTRIBUTES(/ATTRIBUTE_STRUCTURE)
    
    ; ===> DEFINE THE VALUES FOR THE NEW ATTRIBUTES
    ATTRNEW.ATTRIBUTE_0 = STRTRIM(ANAME,2)
;    ATTRNEW.ATTRIBUTE_1 = REG
    ATTRNEW.ATTRIBUTE_1 = STRTRIM(ACODE,2)
    ATTRNEW.ATTRIBUTE_2 = METHOD
    ATTRNEW.ATTRIBUTE_3 = SOURCE
    ATTRNEW.ATTRIBUTE_4 = DATE_NOW(/DATE_ONLY)
    ATTRNEW.ATTRIBUTE_5 = CREATOR
    ATTRNEW.ATTRIBUTE_6 = ATITLE
     
    ; ===> CREATE STRUCTURE FOR NEW ENTITY
    ENTNEW = {IDL_SHAPE_ENTITY}
    
    ; ===> DEFINE THE VALUES FOR THE NEW ENTITIES
    IF KEYWORD_SET(LINE) THEN ENTNEW.SHAPE_TYPE = 3 ELSE ENTNEW.SHAPE_TYPE = 5
    ENTNEW.BOUNDS[0]  = MIN(LON)
    ENTNEW.BOUNDS[1]  = MIN(LAT)
    ENTNEW.BOUNDS[2]  = 0.D
    ENTNEW.BOUNDS[3]  = 0.D
    ENTNEW.BOUNDS[4]  = MAX(LON)
    ENTNEW.BOUNDS[5]  = MAX(LAT)
    ENTNEW.BOUNDS[6]  = 0.D
    ENTNEW.BOUNDS[7]  = 0.D
    ENTNEW.N_PARTS    = N_ELEMENTS(PATH_INFO)
    ENTNEW.PARTS      = PTR_NEW(OFFSET, /ALLOCATE_HEAP, /NO_COPY)
    ENTNEW.N_VERTICES = N_ELEMENTS(LON)
    ENTNEW.VERTICES   = PTR_NEW(LONLAT, /ALLOCATE_HEAP, /NO_COPY)
   
    ; ===> ADD THE NEW ENTITY TO NEW SHAPEFILE
    SHP->PUTENTITY, ENTNEW
    
    ; ===> ADD THE ATTRIBUTES TO NEW SHAPEFILE.
    SHP->GetProperty, N_ENTITIES=NUM_ENTITIES
    SHP->SETATTRIBUTES, NUM_ENTITIES-1, ATTRNEW
print, aname    
    ;===> CLOSE/DESTROY THE SHAPEFILE
    OBJ_DESTROY, SHP
    COUNTER = COUNTER + 1
  ENDFOR ; CODES
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  PFILE, SHP_FILE
  

  DONE:
  SH = READ_SHPFILE(SNAME, MAPP=AMAP)
  

END; #####################  END OF ROUTINE ################################
