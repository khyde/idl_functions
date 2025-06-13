; $ID:	SATSHIP_MAP.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION SATSHIP_MAP, SHIP_STRUCT=SHIP_STRUCT, SAT_FILES=SAT_FILES, MAP=MAP, PX=PX, PY=PY, HOURS=HOURS, AROUND=AROUND, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;   SATSHIP_MAP.PRO
;
; PURPOSE:
;   Take an mapped satellite file and a SHIP csv file,
;   and determine the pixel or surrounding pixels from the latitude/longitude of the SHIP location.
;   Uses and depends on MAP_DEGREE2IMAGE(). 
;
; CATEGORY:
;   SATSHIP Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   SAT_FILE     := SEAWIFS, MODIS or other SAV file
;   SHIP_STRUCT  := Structure containing SHIP data.  MUST include DATETIME, YYYYMMDDHHMMSS (in GMT time), LAT and LON
;   HOURS        := Acceptable difference in time from the point in the SAT file from that in the SHIPRECORD
;   PROD         := Products to extract from the HDF
;   AROUND       := To designate the array size
;     0 = single pixel
;     1 = 3x3 array
;     2 = 5x5 array
;     3 = 7x7 array, and so on up to an arbitrary MAXSIZE.
;         MAXSIZE (9) for the pixel array is set at the initialization and may adjusted.
;   ERROR        := 1 if there is an ERROR
;   ERR_MSG      := Descrption of the ERROR
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
;    SATSHIP = SATSHIP_MAP(SHIP_STRUCT=SHIP_STRUCT,SAT_FILES=SATFILES,AROUND=1,HOURS=MAX([3,24]),PROD='SST',CPROD=CPRODS)  
;   
; NOTES:
;   
; MODIFICATION HISTORY:
;     Written May 27, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;                         Adapted from SATSHIP_HDF and SD_SAT_SHIP
;     Modification History:
;             May 28, 2015 - KJWH:       
;             Jul 27, 2015 - KJWH: Removed duplicate ship entries (i.e. multiple depths per station)       
;             Mar 18, 2016 - KJWH: Changed DATATYPE to IDLTYPE
;             Feb 19, 2019 - KJWH: Minor formatting
;
;-
; ****************************************************************************************************

  ROUTINE_NAME='SATSHIP_MAP'
  ERROR = 0
  ERR_MSG = ''
  AS=DELIMITER(/ASTER)
  DASH=DELIMITER(/DASH)
  UL=DELIMITER(/UL)
  DECIMAL_DAYS = FLOAT(HOURS) / 24.0    
  
  
  
  IF NONE(AROUND)       THEN AROUND       = 1           
  IF NONE(HOURS)        THEN HOURS        = 48.1   
  JDDIFF = HOURS / 24.0

; ===> Check for input files
  IF N_ELEMENTS(SAT_FILES)    LT 1 THEN SAT_FILES     = DIALOG_PICKFILE(TITLE='Pick save files') ELSE _SAT_FILES = SAT_FILES
  FP = PARSE_IT(SAT_FILES,/ALL)
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

; ===> Find SATFILES with that match up with the SHIP_STRUCT dates  
  JD_SHIP = DATE_2JD(SHIP_STRUCT.DATE)
  OK = WHERE_NEAREST(JD_SHIP,JD_SAT,NEAR=JDDIFF,COUNT,VALID=VALID,INVALID=INVALID)   
  IF COUNT EQ 0 THEN GOTO, DONE  
  FILES = SAT_FILES(VALID) 
  FP = FP(VALID) 
     
; ===> Add STATION tag to SHIP_STRUCT if not already present
  IF HAS(SHIP_STRUCT,'STATION') EQ 0 THEN BEGIN
    STATIONS = NUM2STR(INDGEN(N_ELEMENTS(SHIP_STRUCT))+1)
    STATION = REPLICATE(CREATE_STRUCT('STATION',''),NOF(STATIONS))
    FOR S=0, NOF(STATIONS)-1 DO STATION(S).STATION = STATIONS(S)
    SHIP_STRUCT=STRUCT_MERGE(SHIP_STRUCT,STATION)
  ENDIF

; ===> Initialize output array size
  ASIZE = (AROUND * 2 ) + 1
  LA = LONARR(ASIZE,ASIZE) & LA(*,*) = MISSINGS(LA)
  FA = FLTARR(ASIZE,ASIZE) & FA(*,*) = MISSINGS(FA)
     
; ===> Make output structure with all product names    
  TEMPLATE=CREATE_STRUCT( 'SHIP_DATE','','CRUISE','','STATION','','SHIP_LON',0.0,'SHIP_LAT',0.0, 'SAT_DATE','', 'SAT_AROUND',0L, $
                          'SATNAME','','PERIOD','','SENSOR','','SAT_PROD','','SAT_ALG','','TIME_DIF_HOURS',0.0,$
                          'MAP','','SAT_LAT_0',0.0,'SAT_LON_0',0.0,'SAT_LAT',FA,'SAT_LON',FA,'PIXSIZE_X',0.0,'PIXSIZE_Y',0.0,'PIXSIZE_MEAN',0.0,'PIXDIF_METERS',0.0,$
                          'SAT_CENTER',0.0,'SAT_N',0L,'SAT_DATA',FA) 
  IF AROUND EQ 0 THEN TEMPLATE = STRUCT_COPY(TEMPLATE,TAGNAMES=['SAT_LAT','SAT_LON','SAT_N','SAT_DATA'],/REMOVE)                                  
  OUTSTRUCT = [] ; STRUCT_2MISSINGS(TEMPLATE)          
          
; ===> Loop through files
  FOR NTH=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[NTH]
    FA = FP[NTH]
    PRINT, 'WORKING ON FILE: ' + NUM2STR(NTH+1) + ' of ' + NUM2STR(N_ELEMENTS(FILES)) + ', '+AFILE
    
    JD_SAT = PERIOD_2JD(FA.PERIOD)
    LX = WHERE(ABS(JD_SHIP - JD_SAT) LE DECIMAL_DAYS, COUNT)  ; LX now contains the indices into *either* SHIP or LON,LAT which are in acceptable time range.
    IF COUNT EQ 0 THEN CONTINUE
    SHIP = SHIP_STRUCT(LX)  ; SHIP is now containing only the elements within the acceptable time range  
    BSETS = WHERE_SETS(NUM2STR(SHIP.DATE)+'_'+NUM2STR(SHIP.LAT)+'_'+NUM2STR(SHIP.LON)+'_'+SHIP.CRUISE+'_'+SHIP.STATION)
    SHIP = SHIP(BSETS.FIRST) ; Remove duplicate entries (i.e. multiple depths) at each station
    LON = FLOAT(SHIP.LON)
    LAT = FLOAT(SHIP.LAT)
    
    ; ===> Set up MAP info
    IF NONE(MAP) THEN MP = VALID_MAPS(AFILE) ELSE MP = MAP
    MS   = MAPS_SIZE(MP)
    IF NONE(PX) THEN _PX=MS.PX ELSE _PX = PX
    IF NONE(PX) THEN _PY=MS.PY ELSE _PY = PY
   
    ; ===> Read DATA   
    DATA = STRUCT_READ(AFILE,STRUCT=STRUCT,MAP_OUT=MP)
    SZ = SIZE(DATA,/DIMENSIONS)
    MS = MAPS_SIZE(MP)
    IF SZ[0] NE MS.PX OR SZ[1] NE MS.PY THEN BEGIN
      ERROR = 1
      ERR_MSG = 'Sat data dimensions do not match map dimensions'
      PRINT, ERR_MSG
      CONTINUE
    ENDIF ELSE ERROR = 0
    
    ; ===> Establish map coordinate system and get pixel subscripts
    LL = MAPS_2LONLAT(MP)                                          ; Get LON and LAT values for each pixel of the map
    MA = MAPS_PIXAREA(MP)                                          ; Get pixel areas for each pixel of the map
    ZWIN, DATA    
    MAPS_SET, MP 
    BOXDATA  = MAP_DEG2IMAGE(DATA,LON,LAT,X=XCEN,Y=YCEN,SUBS=BOXSUBS,AROUND=AROUND)   ; Get BOX values for specific coordinates
    ZWIN  
    
    CENDATA  = DATA(XCEN,YCEN)                                       ; Get center value
    BOXLAT   = LL.LATS(BOXSUBS)                                      ; Get BOX LATS
    BOXLON   = LL.LONS(BOXSUBS)                                      ; Get BOX LONS
    BOXPIX   = MA(BOXSUBS)                                           ; Get BOX PIXAREAS
    
    SZ = SIZE(BOXDATA,/DIMENSIONS)           
    DB = []  
    FOR SUB=0, SZ[0]-1 DO BEGIN  ; Loop over the ship points (sub = ship point #N)
      SHP = SHIP(SUB)
      BOXSUB = REFORM(BOXDATA(SUB,*),ASIZE,ASIZE)
      CENSUB = CENDATA(SUB)    
            
      SLAT = BOXLAT(SUB,*)
      SLON = BOXLON(SUB,*)   
      LAT_DATA = NUM2STR(SLAT) & OK = WHERE(LAT_DATA EQ MISSINGS(0.0),COUNT) & IF COUNT GE 1 THEN LAT_DATA[OK] = "''"
      LON_DATA = NUM2STR(SLON) & OK = WHERE(LON_DATA EQ MISSINGS(0.0),COUNT) & IF COUNT GE 1 THEN LON_DATA[OK] = "''"

      STRUCT = STRUCT_COPY(FA,['FIRST_NAME','PERIOD','SENSOR','MAP','PROD','ALG'])
      STRUCT = CREATE_STRUCT(STRUCT,'SAT_UNITS',UNITS(FA.PROD,/SI),'SAT_DATE',PERIOD_2DATE(FA.PERIOD),'SAT_AROUND',AROUND)
      STRUCT = CREATE_STRUCT(STRUCT,STRUCT_COPY(SHP,['CRUISE','STATION','DATE','LAT','LON']))
      STRUCT = STRUCT_RENAME(STRUCT,['FIRST_NAME','PROD',    'ALG',    'SHIP_DATE', 'SHIP_LON','SHIP_LAT'],$
                                    ['SATNAME',   'SAT_PROD','SAT_ALG','DATE',      'LON',     'LAT'])
      STRUCT = CREATE_STRUCT(STRUCT,'SAT_LAT_0',LL.LATS(XCEN(SUB),YCEN(SUB)),$
                                    'SAT_LON_0',LL.LONS(XCEN(SUB),YCEN(SUB)),$
                                    'TIME_DIF_HOURS',ABS(DATE_2JD(SHIP(SUB).DATE)-JD_SAT)*24,$
                                    'PIXSIZE_MEAN',MEAN(BOXPIX),$
                                    'PIXDIF_METERS',MAP_2POINTS(SHIP(SUB).LON,SHIP(SUB).LAT,LL.LONS(XCEN(SUB),YCEN(SUB)),LL.LATS(XCEN(SUB),YCEN(SUB)),/METERS),$
                                    'SAT_CENTER_VALUE',CENSUB)
      IF AROUND GT 0 THEN BEGIN
        STAT = STATS(BOXSUB,/BASIC)
        STRUCT = CREATE_STRUCT(STRUCT,'SAT_LAT',REFORM(LAT_DATA,ASIZE,ASIZE),$
                                      'SAT_LON',REFORM(LON_DATA,ASIZE,ASIZE),$
                                      'SAT_DATA',BOXSUB,$
                                      STAT) 
      ENDIF                                
      IF NONE(DB) THEN DB = STRUCT ELSE DB = [DB,STRUCT]    
      GONE, STRUCT              
    ENDFOR ; FOR EACH LON/LAT WITHIN A FILE
    IF NONE(OUTSTRUCT) THEN OUTSTRUCT=DB ELSE OUTSTRUCT=[OUTSTRUCT,DB]
    GONE,DB
  ENDFOR ;  FOR EACH FILE
  
  OUTSTRUCT = OUTSTRUCT[WHERE(OUTSTRUCT.SATNAME NE '')] ; Remove any blank records 
  RETURN, OUTSTRUCT
  DONE:
  
END
