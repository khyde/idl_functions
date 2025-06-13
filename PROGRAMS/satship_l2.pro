; $ID:	SATSHIP_L2.PRO,	2020-07-29-14,	USER-KJWH	$

FUNCTION SATSHIP_L2, SHIP_STRUCT=SHIP_STRUCT, SAT_FILES=SAT_FILES, HOURS=HOURS, PRODS=PRODS, CPRODS=CPRODS, AROUND=AROUND, $
                     SKIP_L2_FLAGS=SKIP_L2_FLAGS, FLAG_BITS=FLAG_BITS, REMOVE_BAD=REMOVE_BAD, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;   SATSHIP_L2.PRO
;
; PURPOSE:
;   Take an input Level 2 or level 1B satellite HDF file and a SHIP csv file,
;   and determine the pixel or surrounding pixels from the latitude/longitude of the SHIP location.
;   Uses and depends on OC_GET_HDF_PIXELS_FROM_LATLON(). 
;
; CATEGORY:
;   SATSHIP Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   SAT_FILE     := SEAWIFS, MODIS or other L1/l2 data HDF file
;   SHIP_STRUCT  := Structure containing SHIP data.  MUST include DATETIME, YYYYMMDDHHMMSS (in GMT time), LAT and LON
;   HOURS        := Acceptable difference in time from the point in the SAT file from that in the SHIPRECORD
;   PROD         := Products to extract from the HDF
;   CPRODS       := Products that we only need the center value for
;   AROUND       := To designate the array size
;     0 = single pixel
;     1 = 3x3 array
;     2 = 5x5 array
;     3 = 7x7 array, and so on up to an arbitrary MAXSIZE.
;         MAXSIZE (9) for the pixel array is set at the initialization and may adjusted.
;   FLAG_BITS    := The flags to apply to the data extracted from the HDF file
;   SKIP_L2_FLAGS:= Skip the L2_FLAGS step
;   ERROR=ERROR
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns the Satellite product pixel array (NxN)
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;     This is usually a description of the method, or any data manipulations
;
; EXAMPLES:
;   SATSHIP = SATSHIP_L2(SHIP_STRUCT=SHIP_STRUCT,SAT_FILES=SATFILES,AROUND=1,HOURS=MAX([3,24]),FLAG_BITS=FLAG_BITS,PRODS=['chlor_a','par'],CPRODS=['solz','aot'])
;   
; NOTES:
;   This routine works for either single lat/lon points or arrays of lat[]/lon[]
;   For now, only one product at a time can be passed in PRODS.
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;
;
;
; MODIFICATION HISTORY:
;     Written May 1, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;                         Adapted from SD_HDF_SAT_SHIP
;   May 11, 2015 - KJWH: Added SENSOR to the output structure     
;   Jun 02, 2015 - KJWH: Changed name to SATSHIP_L2 and added code to read .nc files in addition to .hdf    
;   Jun 09, 2015 - KJWH: Updated to work with the new HDF5 L2 files from SeaDAS and added L2_FLAGS to prods if missing       
;   Jul 16, 2015 - KJWH: Added RETURN, [] if no data are returned   
;   Jul 27, 2015 - KJWH: Removed duplicate ship entries (i.e. multiple depths per station)
;   Mar 18, 2016 - KJWH: Changed DATATYPE to IDLTYPE
;   Mar 30, 2020 - KJWH: Updated the output so that if specific ship coordinates were not found the ship data is written out in the structure, 
;                          the center subscript is listed as -999 and all other satellite data is MISSINGS.  
;                          Previously, the entire file was skipped if just one input coordinate pair did not have matching satellite data.
;   May 08, 2020 - KJWH: Removed the "unzip" step because L2 files are not currently being stored zipped
;                        Added the capability to work with "mapped" SAV files (L3B)
;   Jun 19, 2020 - KJWH: Fixed the code to add a "stations" to the structure if they did not already exist   
;                        Added an option to add a generic "CRUISE" variable to the structure if it does not exist in the input ship structure             
;   Jun 02, 2021 - KJWH: Added step to return !NULL when there is an error reading the file
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR
; ****************************************************************************************************

  ROUTINE_NAME='SATSHIP_L2'
  ERROR = 0
  ERR_MSG = ''
  SL = PATH_SEP()
  AS=DELIMITER(/ASTER)
  DASH=DELIMITER(/DASH)
  UL=DELIMITER(/UL)
  DECIMAL_DAYS = FLOAT(HOURS) / 24.0  
  
  ; ===> Create COMMON LON and LAT variables for iput files with predetermined LON/LAT locations so the saved LON/LAT files do not have to be read in for each file
  COMMON MAPS_MUR_2MAP_, MUR_LONS, MUR_LATS
  IF KEY(INIT) THEN BEGIN
    MUR_LONS = [] 
    MUR_LATS = [] 
  ENDIF  
  
  IF NONE(PRODS)        THEN PRODS        = 'CHLOR_A'     ELSE PRODS = STRUPCASE(PRODS)
  IF NONE(FLAG_BITS)    THEN FLAG_BITS    = [0,1,2,3,4,5,8,9,12,14,15,16,25]
  IF NONE(AROUND)       THEN AROUND       = 1           
  IF NONE(HOURS)        THEN HOURS        = 48.1   
  JDDIFF = HOURS / 24.0
  
  IF NOT KEYWORD_SET(SKIP_L2_FLAGS) AND HAS(PRODS,'L2_FLAGS') EQ 0 THEN PRODS = [PRODS,'L2_FLAGS']

; ===> Check for input files
  IF N_ELEMENTS(SAT_FILES) LT 1 THEN SAT_FILES = DIALOG_PICKFILE(TITLE='Pick save files') ELSE _SAT_FILES = SAT_FILES
  FP = PARSE_IT(SAT_FILES)
  IF FP[0].FULLNAME EQ '' THEN BEGIN
    ERROR = 1
    ERR_MSG = 'No input files provided'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF
  JD_SAT= PERIOD_2JD(FP.PERIOD)
 
; ===> Check to make sure the SHIP_STRUCT is a structure 
  IF IDLTYPE(SHIP_STRUCT) NE 'STRUCT' THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Ship data not in a structure'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF

; ===> Check for DATE and station coordinates in the SHIP_STRUCT  
  IF HAS(SHIP_STRUCT,'DATE') EQ 0 OR HAS(SHIP_STRUCT,'LON') EQ 0 OR HAS(SHIP_STRUCT,'LAT') EQ 0 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Ship structure missing either DATE, LON, or LAT tag'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF

; ===> Check the DATE to make sure it is at least 12 characters long (can ignore ss)
  IF MIN(STRLEN(SHIP_STRUCT.DATE)) LT 12 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Ship DATE is not in the correct format (yyyymmssddmmss)'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF

; ===> Find SATFILES that match up with the SHIP_STRUCT dates  
  JD_SHIP = DATE_2JD(SHIP_STRUCT.DATE)
  OK = WHERE_NEAREST(JD_SHIP,JD_SAT,NEAR=JDDIFF,COUNT,VALID=VALID,INVALID=INVALID)   
  IF COUNT EQ 0 THEN BEGIN
    ERROR = 1
    ERR_MSG = 'Sat file DATES are not within the range of the ship data'
    PRINT, ERR_MSG
    DIR_BAD_DATE = FP[0].DIR + 'OUT_OF_DATE_FILES' + SL & DIR_TEST, DIR_BAD_DATE
    IF KEY(REMOVE_BAD) THEN FILE_MOVE, SAT_FILES, DIR_BAD_DATE
    RETURN, []
  ENDIF  
  FILES = SAT_FILES(VALID)  
     
; ===> Add STATION tag to SHIP_STRUCT if not already present
  IF HAS(SHIP_STRUCT,'STATION') EQ 0 THEN BEGIN
    STATIONS = REPLICATE(CREATE_STRUCT('STATION',''),N_ELEMENTS(SHIP_STRUCT))
    STATIONS.STATION = NUM2STR(INDGEN(N_ELEMENTS(SHIP_STRUCT))+1)
    SHIP_STRUCT = STRUCT_MERGE(STATIONS,SHIP_STRUCT)
  ENDIF
  
; ===> Add CRUISE tag to SHIP_STRUCT if not already present
  IF HAS(SHIP_STRUCT,'CRUISE') EQ 0 THEN BEGIN
    CRUISES = REPLICATE(CREATE_STRUCT('CRUISE',''),N_ELEMENTS(SHIP_STRUCT))
    CRUISES.CRUISE = 'CRUISE'
    SHIP_STRUCT = STRUCT_MERGE(CRUISES,SHIP_STRUCT)
  ENDIF  

; ===> Initialize output array size
  ASIZE = (AROUND * 2 ) + 1
  LA = LONARR(ASIZE,ASIZE) & LA(*,*) = MISSINGS(LA)
  FA = FLTARR(ASIZE,ASIZE) & FA(*,*) = MISSINGS(FA)
     
; ===> Make output structure with all product names    
  TEMPLATE=CREATE_STRUCT( 'SHIP_DATE','','CRUISE','','STATION','','SHIP_LON',0.0,'SHIP_LAT',0.0, 'SAT_DATE','', 'SAT_AROUND',0L, 'SATNAME','','PERIOD','','SENSOR','','TIME_DIF_HOURS',0.0,$
                          'MAP','','SAT_LAT_0',0.0,'SAT_LON_0',0.0,'PIXSIZE_X',0.0,'PIXSIZE_Y',0.0,'PIXSIZE_MEAN',0.0,'PIXDIF_METERS',0.0)
  IF AROUND NE 0 THEN TEMPLATE = STRUCT_MERGE(TEMPLATE,CREATE_STRUCT('SAT_LAT',FA,'SAT_LON',FA))                               
  
  FOR CTH=0, N_ELEMENTS(CPRODS)-1 DO BEGIN
    CPROD   = STRUPCASE(CPRODS(CTH))
    TEMPLATE=STRUCT_MERGE(TEMPLATE,CREATE_STRUCT(CPROD,0.0))
  ENDFOR 
  
  IF ANY(CPRODS) THEN TARGETS = CPRODS ELSE TARGETS = []
  IF ANY(CPRODS) THEN LABELS = REPLICATE('',N_ELEMENTS(TARGETS)) ELSE LABELS = []
  FOR PTH = 0, N_ELEMENTS(PRODS)-1 DO BEGIN
    PROD = PRODS(PTH) ; PRODS must be a single element
    APROD = VALIDS('PRODS',PROD)    
    IF APROD EQ '' THEN APROD = PROD      
    ATARGET  = REPLACE(PROD,DASH,UL)    
    IF STRPOS(ATARGET,'_',/REVERSE_OFFSET,/REVERSE_SEARCH) EQ STRLEN(ATARGET)-1 THEN ATARGET = STRMID(ATARGET,0,STRPOS(ATARGET,'_',/REVERSE_OFFSET))
    TARGETS = [TARGETS,ATARGET]
    LAB  = UL+REPLACE(ATARGET,DASH,UL)
    LABELS = [LABELS,LAB]
    
    IF ATARGET NE 'L2_FLAGS' THEN BEGIN
      IF AROUND EQ 0 THEN TEMPLATE=STRUCT_MERGE(TEMPLATE,CREATE_STRUCT('SAT'+LAB,0.0)) ELSE $ 
                          TEMPLATE=STRUCT_MERGE(TEMPLATE,CREATE_STRUCT('SAT_CENTER'+LAB,0.0,'N'+LAB,0L,'SAT'+LAB,FA))
    ENDIF ELSE BEGIN     
      TEMPLATE=STRUCT_MERGE(TEMPLATE,CREATE_STRUCT('L2_FLAGS_CENTER',0L, 'L2_FLAGS',LA,'MASK',LA))
      FOR _BITS =0, N_ELEMENTS(FLAG_BITS)-1 DO TEMPLATE = STRUCT_MERGE(TEMPLATE,CREATE_STRUCT('BIT_'+NUM2STR(FLAG_BITS(_BITS)),LA))      
    ENDELSE  
  ENDFOR    
  STR_TAGS = TAG_NAMES(TEMPLATE) 
  OUTSTRUCT = STRUCT_2MISSINGS(TEMPLATE)          
          
; ===> Loop through files
  FOR NTH=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[NTH]
    REMOVE_FILE = []
    FA = PARSE_IT(AFILE,/ALL)
    IF FA.SENSOR EQ '' THEN BEGIN
      SI = SENSOR_INFO(AFILE)
      SENSOR = SI.SENSOR
    ENDIF ELSE SENSOR = FA.SENSOR
    
    JD_SAT = PERIOD_2JD(FA.PERIOD)
    LX = WHERE(ABS(JD_SHIP - JD_SAT) LE DECIMAL_DAYS, COUNT)  ; LX now contains the indices into *either* SHIP or LON,LAT which are in acceptable time range.
    IF COUNT EQ 0 THEN CONTINUE
    SHIP = SHIP_STRUCT(LX)  ; SHIP is now containing only the elements within the acceptable time range  
    BSETS = WHERE_SETS(NUM2STR(STRMID(SHIP.DATE,0,12))+'_'+NUM2STR(SHIP.LAT)+'_'+NUM2STR(SHIP.LON)+'_'+SHIP.CRUISE+'_'+SHIP.STATION)
    SHIP = SHIP(BSETS.FIRST) ; Remove duplicate entries (i.e. multiple depths) at each station
    LON = FLOAT(SHIP.LON)
    LAT = FLOAT(SHIP.LAT)
      
;    IF STRUPCASE(FA.EXT) EQ 'GZ' OR STRUPCASE(FA.EXT) EQ 'BZ2' THEN BEGIN
;      ZIP,FILES=AFILE,DIR_OUT=FA.DIR,KEEP_TEMP=KEEP_TEMP,TEMPFILES=AFILE                
;      REMOVE_FILE = AFILE
;    ENDIF
 
 ;   IF STRUPCASE(FA.EXT) EQ 'HDF' THEN DAT = READ_HDF_2STRUCT(AFILE,PRODUCTS=['latitude','longitude',TARGETS],ATTRIBUTES=ATTRIBUTES,ERROR=ERROR,ERR_MSG=ERR_MSG)
    
    IF STRUPCASE(FA.EXT) NE 'SAV' THEN BEGIN
      DAT = READ_NC(AFILE,PRODS=['latitude','longitude','LAT','LON',TARGETS])
      IF IDLTYPE(DAT) EQ 'STRING' THEN MESSAGE, 'ERROR: ' + DAT
      SD_TAGS = TAG_NAMES(DAT.SD)      
      IF HAS(SD_TAGS,'LONGITUDE') THEN LONGITUDE = DAT.SD.LONGITUDE.IMAGE ELSE LONGITUDE = DAT.SD.LON.IMAGE
      IF HAS(SD_TAGS,'LATITUDE')  THEN LATITUDE  = DAT.SD.LATITUDE.IMAGE  ELSE LATITUDE  = DAT.SD.LAT.IMAGE
      IF N_ELEMENTS(LATITUDE) EQ 1 OR N_ELEMENTS(LONGITUDE) EQ 1 THEN BEGIN
        MESSAGE, 'ERROR: ' + AFILE + ' does not contain a full latitude or longitude array...', /CONTINUE
        ERR_MSG = 'File is incomplete'
        IF N_ELEMENTS(FILES) EQ 1 THEN RETURN, [] ELSE CONTINUE
      ENDIF  
      DSTRUCT = []
    ENDIF ELSE BEGIN
      IF IS_L3B(FA.MAP) THEN MAP_OUT = MAPS_L3B_GET_GS(FA.MAP) ELSE MAP_OUT = FA.MAP
      DAT = STRUCT_READ(AFILE,STRUCT=DSTRUCT)
      LONLAT = MAPS_2LONLAT(MAP_OUT,LONS=LONGITUDE,LATS=LATITUDE) 
      SD_TAGS = TAG_NAMES(DSTRUCT)
    ENDELSE
    
    CASE FA.SENSOR OF
      'MUR': BEGIN
        MP = 'MUR_GRID'
        IF NONE(MUR_LONS) THEN MUR_LONS = IDL_RESTORE(!S.MAPINFO + 'MUR-PXY_36000_17999-LON.SAV')  
        IF NONE(MUR_LATS) THEN MUR_LATS = IDL_RESTORE(!S.MAPINFO + 'MUR-PXY_36000_17999-LAT.SAV')
        LONGITUDE = MUR_LONS
        LATITUDE  = MUR_LATS       
      END  
      'OCCCI': BEGIN
        MP = MAP_OUT
        IF HAS(DSTRUCT,'DATA') THEN DSTRUCT = STRUCT_REMAP(DSTRUCT,MAP_OUT=MAP_OUT) ELSE BEGIN
          TEMP_STRUCT = []
          REMOVE_TAGS = []
          FOR S=0, N_ELEMENTS(SD_TAGS)-1 DO BEGIN
            IF IDLTYPE(DSTRUCT.(S)) EQ 'STRUCT' THEN BEGIN
              REMOVE_TAGS = [REMOVE_TAGS,S]
              NEW_STRUCT = STRUCT_REMAP(DSTRUCT.(S),MAP_IN=DSTRUCT.MAP,MAP_OUT=MAP_OUT)
              TEMP_STRUCT = CREATE_STRUCT(TEMP_STRUCT,SD_TAGS(S),NEW_STRUCT)
            ENDIF 
          ENDFOR
          NEW_STRUCT = STRUCT_COPY(DSTRUCT,REMOVE_TAGS,/REMOVE)
          DSTRUCT = CREATE_STRUCT(TEMP_STRUCT,NEW_STRUCT)
          DSTRUCT.MAP = MAP_OUT
        ENDELSE
      END  
      'GLOBCOLOUR': BEGIN
        MP = MAP_OUT
        IF HAS(DSTRUCT,'IMAGE') THEN DSTRUCT = STRUCT_REMAP(DSTRUCT,MAP_OUT=MAP_OUT) ELSE BEGIN
          stop ; Need to update for GLOBCOLOUR data (code below copied from OCCCI block above)
          TEMP_STRUCT = []
          REMOVE_TAGS = []
          FOR S=0, N_ELEMENTS(SD_TAGS)-1 DO BEGIN
            IF IDLTYPE(DSTRUCT.(S)) EQ 'STRUCT' THEN BEGIN
              REMOVE_TAGS = [REMOVE_TAGS,S]
              NEW_STRUCT = STRUCT_REMAP(DSTRUCT.(S),MAP_IN=DSTRUCT.MAP,MAP_OUT=MAP_OUT)
              TEMP_STRUCT = CREATE_STRUCT(TEMP_STRUCT,SD_TAGS(S),NEW_STRUCT)
            ENDIF
          ENDFOR
          NEW_STRUCT = STRUCT_COPY(DSTRUCT,REMOVE_TAGS,/REMOVE)
          DSTRUCT = CREATE_STRUCT(TEMP_STRUCT,NEW_STRUCT)
          DSTRUCT.MAP = MAP_OUT
        ENDELSE   
      END       
      ELSE: MP = 'UNMAPPED_LEVEL_2'
    ENDCASE  
    
    L2 = SATSHIP_GETPIXELS(LON, LAT, AROUND=AROUND, LATITUDE=LATITUDE, LONGITUDE=LONGITUDE, ERROR=ERROR, ERR_MSG=ERR_MSG)
    IF ERROR EQ 1 THEN BEGIN
      PRINT, ERR_MSG
      PRINT, ' '
      IF KEY(REMOVE_BAD) THEN BEGIN
        DIR_BAD = FA.DIR + 'OUT_OF_AREA_FILES' + SL & DIR_TEST, DIR_BAD
        STOP
        FILE_MOVE, AFILE, DIR_BAD
      ENDIF
      CONTINUE
    ENDIF
    
    OK = WHERE(L2.CENTER_SUB NE -999.,COUNT)       ; Find the pixels where no matches were found
   ; IF COUNT EQ 0 THEN STOP
    IF COUNT GT 0 THEN L2 = L2[OK]                ; Remove the locations from the structure
    
        
    _STRUCT = REPLICATE(STRUCT_2MISSINGS(TEMPLATE),N_ELEMENTS(L2))    
    FOR SUB=0, N_ELEMENTS(L2)-1 DO BEGIN  ; ; Loop over the ship points (sub = ship point #N)
      _STRUCT[SUB].SATNAME        = FA.FIRST_NAME
      _STRUCT[SUB].SAT_DATE       = PERIOD_2DATE(FA.PERIOD)
      _STRUCT[SUB].PERIOD         = FA.PERIOD    
      _STRUCT[SUB].SENSOR         = SENSOR   
      _STRUCT[SUB].CRUISE         = SHIP[SUB].CRUISE
      _STRUCT[SUB].STATION        = SHIP[SUB].STATION
      _STRUCT[SUB].SHIP_DATE      = SHIP[SUB].DATE
      _STRUCT[SUB].TIME_DIF_HOURS = ABS(DATE_2JD(SHIP[SUB].DATE)-JD_SAT)*24
      _STRUCT[SUB].MAP            = MP
      _STRUCT[SUB].SHIP_LON       = SHIP[SUB].LON
      _STRUCT[SUB].SHIP_LAT       = SHIP[SUB].LAT
      _STRUCT[SUB].SAT_AROUND     = AROUND
      _STRUCT[SUB].PIXSIZE_X      = 0
      _STRUCT[SUB].PIXSIZE_Y      = 0
      _STRUCT[SUB].PIXSIZE_MEAN   = 0
      
      CENSUB = L2[SUB].CENTER_SUB
      IF CENSUB EQ -999 THEN BEGIN
        
       ; _STRUCT[SUB].SAT_LAT_0      = -999
       ; _STRUCT[SUB].SAT_LON_0      = -999
        CONTINUE ; Continue if there were no valid matching pixel
      ENDIF
      BOXSUB = L2[SUB].BOX_SUBS

      SLAT = LATITUDE[BOXSUB]
      SLON = LONGITUDE[BOXSUB]
      LAT_DATA = NUM2STR(SLAT) & OK = WHERE(LAT_DATA EQ MISSINGS(0.0),COUNT) & IF COUNT GE 1 THEN LAT_DATA[OK] = "''"
      LON_DATA = NUM2STR(SLON) & OK = WHERE(LON_DATA EQ MISSINGS(0.0),COUNT) & IF COUNT GE 1 THEN LON_DATA[OK] = "''"
      
      _STRUCT[SUB].SAT_LAT_0      = LATITUDE[CENSUB]
      _STRUCT[SUB].SAT_LON_0      = LONGITUDE[CENSUB]

      IF AROUND NE 0 THEN _STRUCT[SUB].SAT_LAT  = LAT_DATA
      IF AROUND NE 0 THEN _STRUCT[SUB].SAT_LON  = LON_DATA
      _STRUCT[SUB].PIXDIF_METERS  = MAP_2POINTS(SHIP[SUB].LON,SHIP[SUB].LAT,_STRUCT[SUB].SAT_LON_0,_STRUCT[SUB].SAT_LAT_0,/METERS)

      
      IF NOT KEYWORD_SET(SKIP_L2_FLAGS) THEN BEGIN
        MASK_FLAG = SD_FLAGS_COMBO(DAT.SD.L2_FLAGS.IMAGE[BOXSUB],FLAG_BITS)
        OK_L2_FLAGS = WHERE(MASK_FLAG GT 0, COUNT_L2_FLAGS)
       ; IF COUNT_L2_FLAGS EQ N_ELEMENTS[BOXSUB] THEN PROD_TARGETS = 'L2_FLAGS' ELSE PROD_TARGETS = TARGETS
      ENDIF ELSE COUNT_L2_FLAGS = 0
                        
      FOR PTH=0, N_ELEMENTS(TARGETS)-1 DO BEGIN
        ATARGET = STRUPCASE(TARGETS(PTH))
        ALAB = LABELS(PTH)
                
; ===>  Extract pixels from larger image       
        IF DSTRUCT EQ [] THEN BEGIN                                            ; DSTRUCT is the structure from the .SAV files.  If NULL, get the data from the .nc structure
          OK_PROD = WHERE(SD_TAGS EQ ATARGET,COUNT_PROD)                       ; Find the product in the structure
          IF COUNT_PROD EQ 0 THEN CONTINUE                                     ; If the product is not found, skip to the next products
          DT = DAT.SD.(OK_PROD)                                                ; Get the product structure from the .nc file
          IMG  = DT.IMAGE[BOXSUB]                                              ; Get the subset of data from the product IMAGE        
        ENDIF ELSE BEGIN
          OK = WHERE(SD_TAGS EQ ATARGET,COUNT)                                 ; Find the product tag in the .SAV structure
          IF COUNT NE 1 THEN BEGIN                                             ; If a single tag with the product name was not found, assume there are multiple products in the structure
            OK = WHERE(SD_TAGS EQ ATARGET,COUNT)                               ; Look for the tag in the structure
            IF COUNT NE 1 THEN OK = WHERE(SD_TAGS EQ 'DATA',COUNT)             ; If the product tag is missing, look for a DATA tag
            IF COUNT NE 1 THEN OK = WHERE(SD_TAGS EQ 'IMAGE',COUNT)            ; If the product and DATA tag are missing, look for the IMAGE tag
            IF COUNT NE 1 THEN MESSAGE, 'ERROR: Unable to find the product'    ; Write out an error if the tag was not found
            DT = DSTRUCT
            IMG = DT.(OK)[BOXSUB]                                              ; Get the subset data from the image array 
          ENDIF ELSE BEGIN
            DT = DSTRUCT.(OK)                                                  ; Get the product structure if the product was found in DSTRUCT
            IMG = DT.IMAGE[BOXSUB]                                             ; Get the subset of data from the image array  
          ENDELSE
        ENDELSE
        DTAGS = STRUPCASE(TAG_NAMES(DT))                                       ; Get the tags from the product structure
        SAT_DATA = IMG

; ===>  Fill in structure with CENTER ONLY products        
        IF HAS(CPRODS,ATARGET) THEN BEGIN
          _STRUCT[SUB].(WHERE(STR_TAGS EQ ATARGET)) = IMG(AROUND,AROUND)
          CONTINUE 
        ENDIF
        
; ===>  Initialize N value as 0 and later overwrite if there is GOOD_DATA
        IF AROUND GT 0 AND ATARGET NE 'L2_FLAGS' THEN _STRUCT[SUB].(WHERE(STR_TAGS EQ 'N'+ALAB)) = 0 
        
; ===>  Find FILLED/BAD data
        IF HAS(DTAGS,'_FILLVALUE') THEN BEGIN
          IF IDLTYPE(DT._FILLVALUE) EQ 'STRUCT' THEN FV = DT._FILLVALUE._DATA[0] ELSE FV = DT._FILLVALUE[0]
        ENDIF ELSE FV = MISSINGS(IMG)
        IF HAS(DTAGS,'BAD_VALUE_SCALED') THEN BV = DT.BAD_VALUE_SCALED ELSE BV = MISSINGS(IMG)
        
; ===>  Find the valid min and max values
        IF HAS(DTAGS,'VALID_MIN') AND HAS(DTAGS,'VALID_MAX') THEN BEGIN
          VMIN = DT.VALID_MIN._DATA[0]
          VMAX = DT.VALID_MAX._DATA[0]
          OK_VALID = WHERE(IMG GE VMIN AND IMG LE VMAX,COUNT_VALID,COMPLEMENT=INVALID,NCOMPLEMENT=NINVALID)
          IF N_ELEMENTS(INVALID) GT 0 THEN IMG[INVALID] = BV       
        ENDIF       

; ===>  Find GOOD data 
        IF ATARGET NE 'L2_FLAGS' THEN OK_GOOD=WHERE(IMG NE MISSINGS(IMG) AND IMG NE BV AND IMG NE FV AND IMG NE MISSINGS(0) AND IMG NE -MISSINGS(0),COUNT_GOOD,COMPLEMENT=OK_BAD,NCOMPLEMENT=COUNT_BAD) $
                                 ELSE OK_GOOD=WHERE(IMG NE MISSINGS(IMG), COUNT_GOOD, COMPLEMENT=OK_BAD,NCOMPLEMENT=COUNT_BAD)
 
; ===> Scale with slope and intercept if available       
        SLOPE = 1.0 & INTERCEPT = 0.0
        IF HAS(DTAGS,'SLOPE') THEN SLOPE = FLOAT(DT.SLOPE[0])
        IF HAS(DTAGS,'SCALE_FACTOR') THEN BEGIN
          IF IDLTYPE(DT.SCALE_FACTOR) EQ 'STRUCT' THEN SLOPE = FLOAT(DT.SCALE_FACTOR._DATA[0]) ELSE SLOPE = FLOAT(DT.SCALE_FACTOR[0])
        ENDIF  
        IF HAS(DTAGS,'INTERCEPT') THEN INTERCEPT = FLOAT(DT.INTERCEPT[0])
        IF HAS(DTAGS,'ADD_OFFSET') THEN BEGIN
          IF IDLTYPE(DT.ADD_OFFSET) EQ 'STRUCT' THEN INTERCEPT = FLOAT(DT.ADD_OFFSET._DATA[0]) ELSE INTERCEPT = FLOAT(DT.ADD_OFFSET[0])
        ENDIF  
        
        IF ATARGET NE 'L2_FLAGS' THEN SAT_DATA = IMG * SLOPE + INTERCEPT

; ===>  Make "BAD" data MISSINGS       
        IF ATARGET NE 'L2_FLAGS' AND COUNT_BAD      GE 1 THEN SAT_DATA[OK_BAD]      = MISSINGS(SAT_DATA) ; Mask out MISSING and BAD_VALUE data
        IF ATARGET NE 'L2_FLAGS' AND COUNT_L2_FLAGS GE 1 THEN SAT_DATA[OK_L2_FLAGS] = MISSINGS(SAT_DATA) ; Mask out data based on L2 FLAGS

; ===> If no good data, skip writing out data        
        OK_MISS = WHERE(SAT_DATA NE MISSINGS(SAT_DATA),COUNT_MISS)
        IF COUNT_MISS EQ 0 THEN CONTINUE   
        SAT_DATA_CENTER = SAT_DATA(AROUND,AROUND)

; ===>  Fill in data structure        
        IF AROUND NE 0 THEN BEGIN 
          IF ATARGET EQ 'L2_FLAGS' THEN BEGIN ; Add L2_FLAGS data to the structure
            _STRUCT[SUB].L2_FLAGS_CENTER = SAT_DATA_CENTER
            _STRUCT[SUB].L2_FLAGS        = SAT_DATA
            _STRUCT[SUB].MASK            = SD_FLAGS_COMBO(SAT_DATA,FLAG_BITS) ; 0 = Not Masked 
            STRUCT_TAGNAMES = TAG_NAMES(_STRUCT)
            FOR _BITS=0, N_ELEMENTS(FLAG_BITS)-1 DO BEGIN ; Add FLAG bit info
              BIT_POS = WHERE(STRUCT_TAGNAMES EQ 'BIT_'+ NUM2STR(FLAG_BITS(_BITS)))
              _STRUCT[SUB].(BIT_POS) = SD_FLAGS_COMBO(SAT_DATA,FLAG_BITS(_BITS))              
            ENDFOR
          ENDIF ELSE BEGIN ; Add the satellite data to the structure
            OK_GOOD = WHERE(SAT_DATA NE MISSINGS(SAT_DATA), COUNT_GOOD) ; Find all non missing data 
            _STRUCT[SUB].(WHERE(STR_TAGS EQ 'SAT_CENTER'+ALAB)) = SAT_DATA_CENTER
            _STRUCT[SUB].(WHERE(STR_TAGS EQ 'SAT'+ALAB))        = SAT_DATA
            _STRUCT[SUB].(WHERE(STR_TAGS EQ 'N'+ALAB))          = COUNT_GOOD
          ENDELSE ; IF ATARGET EQ 'L2_FLAGS' THEN BEGIN       
        ENDIF ELSE BEGIN  ; IF _AROUND NE 0 THEN BEGIN
          _STRUCT[SUB].(WHERE(STR_TAGS EQ 'SAT_DATA'+ALAB))   = SAT_DATA
        ENDELSE ; IF AROUND NE 0 THEN BEGIN         
      ENDFOR ; FOR EACH PRODUCT/TARGET  
    ENDFOR ; FOR EACH LON/LAT WITHIN A FILE
    OUTSTRUCT=STRUCT_CONCAT(OUTSTRUCT, _STRUCT)
    GONE,_STRUCT
  ENDFOR ;  FOR EACH FILE
  
  OUTSTRUCT = OUTSTRUCT[WHERE(OUTSTRUCT.SATNAME NE '')] ; Remove any blank records 
  RETURN, OUTSTRUCT
  DONE:
  RETURN, []
END
