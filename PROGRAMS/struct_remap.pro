; $ID:	STRUCT_REMAP.PRO,	2020-06-03-17,	USER-KJWH	$
;##############################################################################################
FUNCTION STRUCT_REMAP, STRUCT, MAP_IN=MAP_IN, MAP_OUT=MAP_OUT, INIT=INIT
;+
; PURPOSE:
; THIS FUNCTION READS A REMAPPED STRUCTURE 
;
;  KEYWORDS:
;      STRUCT......... THE STRUCT TO REMAP
;      MAP_OUT........ THE STANDARD MAP NAME FOR THE REMAP
;      INIT........... PASSED TO MAPS_REMAP TO INIT OUT THE COMMON_MAPS_REMAP STRUCURE HELD IN COMMON MEMORY
;    
;  OUTPUT:   REMAPPED STRUCTURE CONTAINING ALL THE TAGS IN THE INPUT STRUCTURE BUT WITH ANY 2-D DATA ARRAYS REMAPPED [RESIZED] TO MAP_OUT
;  
;  EXAMPLES: SEE STRUCT_REMAP_DEMO  
;    

;   MODIFICATION_HISTORY:
;   JUL 30, 2004 - TD:   ADOPTED FROM STRUCT_SD_2IMAGE AND STRUCT_SD_REMAP.
;		MAR 11, 2014 - KJWH: ADDED RETURN_STRUCT KEYWORD TO RETURN THE STRUCTURE INSTEAD OF SAVING THE FILE
;		NOV 25, 2014 - KJWH: REMOVED LME MAPPING LOGIC
;		FEB 14, 2015 - JEOR: RENAMED FROM STRUCT_SD_REMAP AND UPDATED WITH NEW FUNCTIONS AND PROGRAMS
;		                     REPLACED STRUCT_SD_READ WITH STRUCT_READ
;		                     MADE IT A PRO NOT A FUNCTION
;		                     IF ISTAG(FA_IN(N),'PX') THEN BEGIN
;                        IF HAS(STRUCT,'IMAGE') THEN  IMAGE=STRUCT.IMAGE
;                        IF HAS(STRUCT,'DATA') THEN  IMAGE=STRUCT.DATA
;   FEB 18, 2015 - KJWH: CLEANED UP AND REMOVED UNNEEDED CODE
;                        REMOVED REFRESH KEYWORD (NOT NEEDED BECAUSE IT IS RESET IN THE PROGRAM)
;                        CHANGED KEYWORD RETURN_STRUCT TO REMAP_STRUCT 
;                        IF GET_STRUCT THEN CAN ONLY HAVE ONE MAP
;                        CHANGED HOW THE NEW FILE NAME IS CREATED
;                        CHANGED HOW THE NEW OUTPUT STRUCTURE IS CREATED 
;   MAR  6, 2015 - JEOR: IF WHERE(TAG_NAMES(STRUCT) EQ 'FILE_NAME') NE -1 THEN FA=PARSE_IT(STRUCT.FILE_NAME,/ALL)
;                        IF WHERE(TAG_NAMES(STRUCT) EQ 'NAME') NE -1 THEN FA=PARSE_IT(STRUCT.NAME,/ALL)
;   MAR 31, 2015 - KJWH: CHANGED FILES = STRUCT.NAME TO FILES = FA.FULLNAME BECAUSE NOT ALL STRUCTURES HAVE .NAME AS A TAG
;   APR 14,2015, - JEOR: ADDED KEY ERROR
;   DEC 09,2015, - JEOR: REPLACED HAS WITH STRUCT_HAS,GET WITH STRUCT_GET,MAP_REMAP WITH MAPS_REMAP
;                        IF STRUCT_HAS(STRUCT , 'FILE_NAME')
;   MAY 29,2016, - JEOR: IF NONE(DIR_OUT) THEN DIR_OUT = !S.IDL_TEMP
;   NOV 05,2016, - JEOR: MAJOR OVERHAUL OF PROGRAM
;   NOV 06,2016, - JEOR: ADDED CASE,REMOVED ERROR [NOT REALLY USED],INSTEAD RETURN AN INFORMATIVE ERROR STRING
;   NOV 07,2016, - JEOR: FINAL REVISIONS AND TESTED
;   NOV 08,2016, - KJWH: ADDED BINS=BINS TO CALL TO MAPS_REMAP
;   JAN 05, 2017 - KJWH: Now only takes a single structure as an input and returns the remapped structure
;                        To open and create new SAV files, use STRUCT_REMAP_WRITE
;                        Added steps to remap SUBSET maps
;   FEB 16, 2017 - KJWH: BUG FIX - Changed SUB_LAT and SUB_LON to SUB_LATS and SUB_LONS in the ENDIF ELSE BEGIN block         
;   MAR 09, 2017 - KJWH: Changed STRUCT.NBINS to N_ELEMENTS(STRUCT.BINS) because not all structures have the tag NBINS    
;   MAY 20, 2019 - KJWH: Added steps to remap the level 2 'LONLAT' files.  Now looking for LONS and LATS in the structure and inputing them as CONTROL_LATS and CONTROL_LONS to MAPS_REMAP.
;                          May not work for all LONLAT type files, but currently working with LONLAT FRONTS files      
;   MAY 12, 2020 - KJWH: Added a MAP_IN option to manually provide the input map if not found in the structure                            
;##############################################################################################
;-
;*********************
  ROUTINE='STRUCT_REMAP'
;*********************
  
  IF IDLTYPE(STRUCT) NE 'STRUCT' THEN RETURN, 'ERROR: Input must be a STRUCTURE'
  IF N_ELEMENTS(MAP_OUT) NE 1    THEN RETURN, 'ERROR: Must provide a single MAP_OUT'
  IF HAS(STRUCT,'MAP') EQ 0 THEN BEGIN
    IF N_ELEMENTS(MAP_IN) EQ 0 THEN RETURN, 'ERROR: Must either provide a single MAP_IN or the input structure must have a MAP tag'
    IMP = MAP_IN
  ENDIF ELSE IMP = STRUCT.MAP
  IF NONE(INIT)                  THEN INIT = 0

  IMP_SZ = MAPS_SIZE(IMP,PX=_PX,PY=_PY)
  IF IMP EQ 'LONLAT' THEN BEGIN
    INIT = 1
    _PX = STRUCT.PX
    _PY = STRUCT.PY
  ENDIF
  IPXY = 'PXY_'+NUM2STR(_PX) + '_' + NUM2STR(_PY)

  OMP = STRUPCASE(MAP_OUT)
  IF HAS(OMP,'SUBSET') THEN BEGIN
    SUBSET_LAT = FILE_SEARCH(!S.MAPINFO + OMP + '-PXY_*-LAT.SAV',COUNT=COUNT_LAT)
    SUBSET_LON = FILE_SEARCH(!S.MAPINFO + OMP + '-PXY_*-LON.SAV',COUNT=COUNT_LON)
    IF COUNT_LAT GT 1 OR COUNT_LON GT 1 THEN MESSAGE, 'ERROR: More than 1 SUBSET coordinate file found'
    IF COUNT_LAT EQ 0 OR COUNT_LON EQ 0 THEN MESSAGE, 'ERROR: Subset files not found'

    SUB_LATS = IDL_RESTORE(SUBSET_LAT)
    SUB_LONS = IDL_RESTORE(SUBSET_LON)
    SZ = SIZEXYZ(SUB_LATS,PX=PX,PY=PY)
    OPXY = 'PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)
    MAP_SUBSET = 1
  ENDIF ELSE BEGIN
    OMP_SZ = MAPS_SIZE(OMP)
    OPXY = 'PXY_'+NUM2STR(OMP_SZ.PX) + '_' + NUM2STR(OMP_SZ.PY) ; PXY based on the default map size
    SUB_LATS = []
    SUB_LONS = []
    MAP_SUBSET = 0
  ENDELSE
  
    
  TAGS=TAG_NAMES(STRUCT)
	IF STRUCT_HAS(STRUCT,'BINS') THEN BINS = STRUCT.BINS ELSE BINS = []
	IF STRUCT_HAS(STRUCT,'LATS') AND STRUCT_HAS(STRUCT,'LONS') THEN BEGIN
	  CONTROL_LATS=STRUCT.LATS
	  CONTROL_LONS=STRUCT.LONS
	ENDIF
		    
; ===> LOOP ON TAGNAMES
  NEW = []
  FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN                ; Loop through the STRUCT tags
    SZ = SIZEXYZ(STRUCT.(T),PX=PX, PY=PY)
    IF BINS NE [] THEN BEGIN ; If L3B with BINS (note - NBINS may not equal the MAP_IN size dimensions)
      IF SZ.N_ELEMENTS GE N_ELEMENTS(STRUCT.BINS) THEN BEGIN
        SUBSET_LATS = SUB_LATS & SUBSET_LONS = SUB_LONS ; Reset SUBSET_LATS/LONS values that are lost during the remapping step
        MP = MAPS_REMAP(STRUCT.(T), MAP_IN=IMP, MAP_OUT=OMP, BINS=BINS, MAP_SUBSET=MAP_SUBSET, SUBSET_LATS=SUBSET_LATS, SUBSET_LONS=SUBSET_LONS, INIT=INIT)
        NEW = CREATE_STRUCT(NEW,TAGS[T],MP)
      ENDIF ELSE NEW = CREATE_STRUCT(NEW,TAGS[T],STRUCT.(T)) ; For non-array tags  
    ENDIF ELSE BEGIN ; (For structures with no BINS)
      IF PX EQ _PX AND PY EQ _PY THEN BEGIN ; For regular maps
        MP = MAPS_REMAP(STRUCT.(T), MAP_IN=IMP, MAP_OUT=OMP, MAP_SUBSET=MAP_SUBSET, SUBSET_LATS=SUBSET_LATS, SUBSET_LONS=SUBSET_LONS, CONTROL_LATS=CONTROL_LATS, CONTROL_LONS=CONTROL_LONS, INIT=INIT)
        NEW = CREATE_STRUCT(NEW,TAGS[T],MP)
      ENDIF ELSE NEW = CREATE_STRUCT(NEW,TAGS[T],STRUCT.(T)) ; For non-array tags
    ENDELSE ; BINS 
  ENDFOR ; TAGS
  
  IF STRUCT_HAS(NEW,'MAP')      THEN NEW.MAP      = OMP
  IF STRUCT_HAS(NEW,'NAME')     THEN NEW.NAME     = REPLACE(NEW.NAME,[IMP,IPXY],[OMP,OPXY])
  IF STRUCT_HAS(NEW,'FILE')     THEN NEW.FILE     = REPLACE(NEW.FILE,[IMP,IPXY],[OMP,OPXY])
  IF STRUCT_HAS(NEW,'PX')       THEN NEW.PX       = OMP_SZ.PX
  IF STRUCT_HAS(NEW,'PY')       THEN NEW.PY       = OMP_SZ.PY
  IF STRUCT_HAS(NEW,'ROUTINE')  THEN NEW.ROUTINE  = ROUTINE
  IF STRUCT_HAS(NEW,'COMPUTER') THEN NEW.COMPUTER = !S.COMPUTER 
  IF STRUCT_HAS(NEW,'DATE')     THEN NEW.DATE     = DATE_NOW() ELSE NEW = CREATE_STRUCT(NEW,'DATE',DATE_NOW()) 
  IF STRUCT_HAS(NEW,'BINS')     THEN NEW          = STRUCT_REMOVE(NEW,['BINS','NBINS','TOTAL_BINS'])  ; Remove BIN related tags

	RETURN, NEW	
  DONE:

END; #####################  END OF ROUTINE ################################



