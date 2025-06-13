; $ID:	MAPS_L3B_2MAP.PRO,	2020-06-30-17,	USER-KJWH	$
;##############################################################################
FUNCTION MAPS_L3B_2MAP, ARRAY, BINS, MAP_IN=MAP_IN, MAP_OUT=MAP_OUT, LATS=LATS, LONS=LONS, INIT=INIT, STRUCT_XPYP= STRUCT_XPYP   

; THIS PROGRAM CONVERTS A L3B ARRAY TO A MAPPED ARRAY
;
; CATEGORY:
;    MAPPING
;    
; UTILITY:
;    REMAPPING
;    
; CALLING SEQUENCE:
;    ARR = MAPS_L3B_2MAP(ARRAY,BINS,MAP_IN='L3B1',MAP_OUT='NEC',INIT=INIT)
;    
; INPUTS:
;   ARRAY   = DATA ARRAY
;   BINS    = BIN LOCATIONS FOR THE INPUT DATA
;   MAP_IN  = EITHER 'L3B9', 'L3B4','L3B2' OR 'L3B1'
;   MAP_OUT = OUTPUT MAP NAME 'NEC','EC' ETC.
;
; OPTIONAL INPUTS:
;   INIT    = INITIALIZE THE COMMON DATA
;   LATS    = LATIDUDES FOR AN UNSPECIFIED MAP
;   LONS    = LONGITUDES FOR AN UNSPECIFIED MAP
; KEYWORDS:
; STRUCT_XPYP.......... STRUCTURE FROM THE CURRENT LAYER IN STRUCT_L3_REMAP
;
; OUTPUTS:
;
; EXAMPLES:
;
; MODIFICATION HISTORY:
;     JUN 28, 2015  WRITTEN BY: BY K.J.W.HYDE, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (KIMBERLY.HYDE@NOAA.GOV)
;     JUL 07, 2016 - JEOR: UPDATED HOW THE BLANK ARRAY IS CREATED - ARR = REPLICATE(MISSINGS(0.0),[MS.PX, MS.PY]) (MUCH FASTER)
;     JUL 15, 2016 - KJWH: ADDED COMMON STRUCTURE TO SPEED UP REMAPPING THE SAME TYPE OF FILES
;     JUL 29, 2016 - KJWH: ADDED LONS AND LATS TO REMAP TO AN UNSPECIFIED MAP
;     OCT 04, 2016 - KJWH: MOVED MAPS_SIZE(MAP_IN) TO THE BEGINNING TO CHECK THE SIZE OF THE ARRAY
;                          IF IT IS A FULL ARRAY AND NO BINS ARE PROVIDED, CREATE A GENERIC ARRAY OF BINS (THEY WILL NOT BE USED FOR REMAPPING A FULL L3BX ARRAY)
;     NOV 08, 2016 - JEOR: BINS = LINDGEN(MI.PY)  [WAS INCORRECT BINS = INDGEN(MI.PY) ]
;     FEB 28, 2017 - JEOR: SUBSTITUTED   NROWS = MAPS_L3B_NROWS(MAP_IN) FOR THE CASE BLOCK
;     MAR 01, 2017 - JEOR: REPLACED IF NONE(BINS) THEN BINS = LINDGEN(MI.PY) WITH:
;                                   IF NONE(BINS) THEN BINS = MAPS_L3B_BINS(MAP_IN)
;     MAR 04, 2017 - JEOR: ADDED KEYWORD  STRUCT_XPYP
;                          MAKE  STRUCT_XPYP JUST BEFORE RETURN, MOARR
;     MAR 14, 2017 - KJWH: Added steps to change pixels with -1 BIN values to MISSINGS(ARR)
;                          Adding +1 to the output from MAPS_LONLAT_2BIN to convert the BIN numbers to subscripts
;     AUG 24, 2017 - KJWH: Changed ROUNDS to NUM2STR because ROUNDS was not altering the value for the L3B1 map dimensions     
;     AUG 25, 2017 - KJWH: Added special case for when MAP_OUT is a GSx map      
;     DEC 08, 2017 - KJWH: Fixed error with the output variables from MAPS_2LONLAT.  
;                            Changed LONS = LL.LON to LONS = LL.LONS and LATS = LL.LAT to LATS = LL.LATS
;     AUG 22, 2018 - KJWH: Added 'SUBS', MOBINS-1 to the output structure to capture the "mapped" subscripts within the original L3B map  
;     APR 05, 2019 - KJWH: Added steps to compare the create date of a particular map and the time the COMMON was created.  When testing new maps (found in MAPS_MASTER.CSV), the COMMON structure will need to be reinitialized in order to make the new map.                     
;     MAY 12, 2023 - KJWH: When converting a subset L3B array to a full array changed ARR[BINS] = ARRAY to ARR[BINS-1] = ARRAY to convert the bins back to subscripts
;###############################################################################################################     
;- 
  
;********************************
  ROUTINE_NAME = 'MAPS_L3B_2MAP'
;********************************  
 
  COMMON MAPS_L3B_2MAP_, STRUCT_L3_REMAP, JDTIME
  MPS = MAPS_READ([MAP_IN,MAP_OUT])
  PRS = PERIOD_2JD(MPS.PERIOD) ; Convert the periods found in the MAPS_MASTER (the date the map was created) to Julian date
  
  IF ANY(JDTIME) THEN IF MAX(PRS) GT JDTIME THEN INIT = 1 ; If there is a new MAPS_MASTER, reinitialize the remapping steps
  IF NONE(JDTIME) OR KEY(INIT) THEN JDTIME = SYSTIME(/JULIAN)
  IF NONE(STRUCT_L3_REMAP) OR KEY(INIT) THEN STRUCT_L3_REMAP=[]

 
 ; ===> Check the size of the input ARRAY and BINS
  MI = MAPS_SIZE(MAP_IN)
  IF NONE(BINS) AND N_ELEMENTS(ARRAY) NE MI.PY THEN RETURN, 'ERROR: If not a full L3Bx array, then must provide BINS'
  IF NONE(BINS) THEN BINS = MAPS_L3B_BINS(MAP_IN)
  
  IF N_ELEMENTS(BINS) NE N_ELEMENTS(ARRAY) AND N_ELEMENTS(ARRAY) NE MI.PY THEN $
    RETURN, 'ERROR: ARRAY SIZE MUST EQUAL ' + ROUNDS(MI.PY) + ' OR AN EQUAL NUMBER OF BINS MUST BE PROVIDED'
  
  IF NONE(ARRAY) OR NONE(MAP_IN) OR NONE(MAP_OUT) THEN RETURN,'ERROR: ARRAY, MAP_IN & MAP_OUT ARE REQUIRED'
  NROWS = MAPS_L3B_NROWS(MAP_IN)
  
; ===> If input ARRAY size does not equal the L3B map size, then the full array must be created
  IF N_ELEMENTS(ARRAY) NE MI.PY THEN BEGIN    
    ARR = MAPS_BLANK(MAP_IN)
    ARR[BINS-1] = ARRAY  ; Bin numbers start at 1 and need to be converted back to subscripts
  ENDIF ELSE ARR = ARRAY
  
  ASZ = SIZEXYZ(ARR,PX=PX,PY=PY)
  IF ASZ.N_DIMENSIONS EQ 1 THEN BEGIN
    AR = MAPS_BLANK(MAP_IN)
    AR(0,*) = ARR
    ARR = AR
    GONE, AR
  ENDIF
  
; ===> If output map is a GSx map then us MAPS_L3BGS_SWAP
  IF IS_GSMAP(MAP_OUT) THEN BEGIN
    STRUCT_XPYP = MAPS_L3B_2GS(MAP_IN)
    MOARR = MAPS_L3BGS_SWAP(ARR)
    RETURN, MOARR
  ENDIF
  
; ===> Get the LONS and LATS for the MAP_OUT 
  MO = MAPS_SIZE(MAP_OUT)
  IF MO.MAP EQ '' THEN MO = SIZEXYZ(LONS) 
  
; ===> Create a TAG NAME for the specific MAP_IN/MAP_OUT combo for the COMMON structure 
  MAP_TXT = STRUPCASE(MAP_IN)+'_'+NUM2STR(MI.PX)+'_'+NUM2STR(MI.PY)+'_'+STRUPCASE(MAP_OUT)+'_'+NUM2STR(MO.PX)+'_'+NUM2STR(MO.PY)
  
  IF HAS(STRUCT_L3_REMAP,MAP_TXT) EQ 0 THEN BEGIN ; If the MAP_TXT tag does not exist, then determine the BIN locations for the MAP_OUT
    IF HAS(MO,'MAP') THEN BEGIN
      LL = MAPS_2LONLAT(MAP_OUT)
      LONS = LL.LONS
      LATS = LL.LATS
    ENDIF  

; ===> Get the BIN numbers corresponding to the MAP_OUT LONS and LATS  
    MOBINS = MAPS_L3B_LONLAT_2BIN(MAP_IN,LONS,LATS)-1 ; NOTE: These are BIN numbers and NOT subscripts.  Need to subtract 1 to convert the BIN numbers to subscripts
    XP = REPLICATE(0L,MO.PX,MO.PY)
    YP = REFORM(MOBINS,MO.PX,MO.PY)
    GONE, LONS
    GONE, LATS

; ===> CREATE A COMMON STRUCTURE WITH MAP SPECIFIC INFORMATION  
    STR = CREATE_STRUCT('MAP_IN',MAP_IN,'PX_IN',MI.PX,'PY_IN',MI.PY,'MAP_OUT',MAP_OUT,'PX_OUT',MO.PX,'PY_OUT',MO.PY,'XP',XP,'YP',YP,'SUBS',MOBINS-1)
    STRUCT_L3_REMAP = CREATE_STRUCT(TEMPORARY(STRUCT_L3_REMAP),MAP_TXT,STR)
    GONE, MOBINS
  ENDIF ; IF HAS(STRUCT_L3_REMAP,MAP_TXT) EQ 0 THEN BEGIN   

; ===> Find the MAP_TXT tag in the COMMON structure and insert the L3 BINNED data into the MAP_OUT array  
  POS = WHERE(TAG_NAMES(STRUCT_L3_REMAP) EQ MAP_TXT,COUNT)
  IF COUNT EQ 1 THEN MOARR = ARR[STRUCT_L3_REMAP.(POS).XP,STRUCT_L3_REMAP.(POS).YP] $
                ELSE MOARR = 'ERROR: Map info was not found in the COMMON structure, rerun with INIT set.
   
  OK = WHERE(STRUCT_L3_REMAP.(POS).YP LT 0,COUNT_BLANK) ; Find the blank pixels in the GS maps       
  IF COUNT_BLANK GT 0 THEN MOARR[OK] = MISSINGS(MOARR)        
  STRUCT_XPYP = CREATE_STRUCT('MAP_TXT',MAP_TXT,STRUCT_L3_REMAP[POS].(0))
  RETURN, MOARR
  
END
