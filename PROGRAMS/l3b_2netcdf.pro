; $ID:	L3B_2NETCDF.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO L3B_2NETCDF, FILES, PRODS=PRODS, DIR_OUT=DIR_OUT, MAP_OUT=map_out, LONLAT=lonlat, MAP_SUBSET=map_subset, L3b_GLOBAL=l3b_global, LONS=LONS, LATS=LATS, $
   LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX, TAGNAMES_GLOBAL=TAGNAMES_GLOBAL, TAGNAMES_IMAGE=TAGNAMES_IMAGE, TAGNAMES_MASK=TAGNAMES_MASK, OVERWRITE=overwrite
;+
; NAME:
;       L3B_2NETCDF
;
; PURPOSE:
;				Read a L3Bx netcdf and create a subset netcdf
;
; PROCEDURE:
;       
;
;	INPUT KEYWORDS:
;	  FILES: Input files
;	  PRODS: Products to be read from the original L3B file and added to the netcdf
;	  DIR_OUT: Output directory
;	  MAP_OUT: Output map
;	  
;	OPTIONAL KEYWORDS  
;	  LONLAT: Add the LON and LAT coordinates to the output file
;   LONS: Longitude array to subset the L3Bx data
;   LATS: Latitude array to subset the L3Bx data
;	  L3B_GLOBAL: If set, use the GLOBAL info from the original L3Bx netcdf
;	  TAGNAMES_GLOBAL: Optional GLOBAL tags to add to the netcdf
;	  TAGNAMES_DATE: Optional DATE tags to add to the netcdf
;	  TAGNAMES_MASK: Optional MASK tags to add to the netcdf  
;	  OVERWRITE: Overwrite an existing file 
;
;	RESTRICTIONS:
;		
;
;	EXAMPLE:
;   L3B_2NETCDF, FILES, DIR_OUT=DIR_OUT, MAP_OUT=AMAP, LONLAT=1, MAP_SUBSET=1, L3B_GLOBAL=1, OVERWRITE=OVERWRITE
;
; MODIFICATION HISTORY:
;       Written July 29, 2016 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;       AUG 01, 2016 - KJWH: Continued adapting the code to work with L3B files - still need to update to get GLOBAL product information from the original L2 sat files
;       AUG 01, 2016 - KJWH: Added GLOBAL_PROD information
;       AUG 30, 2016 - KJWH: Changed DIR_GLOBAL to !S.GLOBAL_PRODS
;       
;-

  ROUTINE_NAME='L3B_2NETCDF'

;	===> Initialize
	SPACE = ' '
	SEMICOLON = ';'
	DASH = '-'
	SL = PATH_SEP()
	
	
	COMMON L3B_2NETCDF_, GLOBAL, SD, SUBSET_LATS, SUBSET_LONS, SUBSET_MAP
	IF NONE(SUBSET_MAP) THEN SUBSET_MAP = '' ; Initialize to ''	
	
	FOR _FILES=0,N_ELEMENTS(FILES)-1L DO BEGIN
	  AFILE=FILES(_FILES)
	  FN=PARSE_IT(AFILE,/ALL)
	  IF FN.EXT EQ 'nc' THEN SI = SENSOR_INFO(AFILE) ELSE SI = FN
	  IF NONE(MAP_OUT) THEN _MAP_OUT = FN.MAP ELSE _MAP_OUT = MAP_OUT
	  
	  IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = REPLACE(FN.DIR,'SAVE','NETCDF') ELSE _DIR_OUT = DIR_OUT
	  DIR_TEST, _DIR_OUT
	  NCDF_FILE = _DIR_OUT + SI.PERIOD + DASH + SI.SENSOR + DASH + SI.METHOD + DASH + SI.COVERAGE + DASH + _MAP_OUT + DASH + STRJOIN(PRODS,'_') + '.nc'
	  IF FILE_MAKE(AFILE,NCDF_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	  
	  ; ===> Add the LON and LAT data
	  IF KEYWORD_SET(LONLAT) THEN BEGIN
	    IF NONE(SUBSET_LATS) AND NONE(SUBSET_LONS) AND SUBSET_MAP NE _MAP_OUT THEN BEGIN
	      IF MAP_SUBSET EQ 1 THEN BEGIN
	        SUBSET_LATS = LATS
	        SUBSET_LONS = LONS
	      ENDIF ELSE BEGIN
	        LL=MAPS_2LONLAT(STRUCT.MAP, PX=STRUCT.PX,PY=STRUCT.PY,LONS=LONS,LATS=LATS)
	        SUBSET_LATS = LL.LAT
	        SUBSET_LONS = LL.LON
	      ENDELSE
	      SUBSET_MAP = _MAP_OUT
	    ENDIF
	  ENDIF

    IF FN.EXT EQ 'SAV' THEN BEGIN
      stop ; Need to figure out how to work with the .sav files
    ENDIF ELSE BEGIN
      S = READ_NC(AFILE,PRODS=['GLOBAL',PRODS])
      PFILE, AFILE, /R
    ENDELSE

;   ===> Start the SD interface
    IF FILE_TEST(NCDF_FILE) THEN FILE_DELETE, NCDF_FILE
	  SD_ID = NCDF_CREATE(NCDF_FILE,/CLOBBER,/NETCDF4_FORMAT)
    IF SD_ID EQ -1 THEN MESSAGE, 'NCDF_CREATE FAILED' 	
  
;	===> Identify Tagnames for Global Attributes
  	IF NONE(TAGNAMES_GLOBAL) THEN TAGNAMES_GLOBAL  = ['PERIOD','SENSOR','SATELLITE','SAT_EXTRA','METHOD','MAP','STAT','FILE_NAME']
  	IF NONE(TAGNAMES_DATE)   THEN TAGNAMES_DATE    = ['PERIOD','YEAR_START','MONTH_START','DAY_START','YEAR_END','MONTH_END','DAY_END']
  	IF NONE(TAGNAMES_MASK)   THEN TAGNAMES_MASK    = ['MASK','CODE_MASK','CODE_NAME_MASK']

;		*******************************
;		*** Write GLOBAL Attributes ***
;		*******************************
    IF KEY(L3B_GLOBAL) THEN BEGIN      
      GLOBAL = S.GLOBAL
      TAGNAMES_GLOBAL = TAG_NAMES(GLOBAL) 
      TAGNAMES = TAGNAMES_GLOBAL
    ENDIF ELSE GLOBAL = STRUCT  ; For the global attributes if the original GLOBAL file is not used
      
		FOR _TARGET = 0,N_ELEMENTS(TAGNAMES_GLOBAL)-1 DO BEGIN
			NAME = TAGNAMES_GLOBAL(_TARGET)
			OK_POS = WHERE(TAGNAMES EQ NAME,COUNT)
			IF COUNT EQ 1 THEN BEGIN
				VAL = GLOBAL.(OK_POS)
				SZ = SIZE(VAL,/STRUCT)
				IF SZ.N_ELEMENTS EQ 1 THEN BEGIN
					IF SZ.TYPE EQ 7 AND VAL EQ '' THEN VAL = SEMICOLON
				ENDIF

				IF SZ.N_ELEMENTS GE 2 AND SZ.TYPE EQ 7 THEN VAL = STRJOIN(VAL+SEMICOLON)
				NCDF_ATTPUT, SD_ID, NAME, VAL, /GLOBAL
			ENDIF
		ENDFOR

;   Add data source & date created    
    NCDF_ATTPUT, SD_ID, 'NETCDF_CREATED_BY', 'K. Hyde, NOAA/NMFS/NEFSC Narragansett Laboratory kimberly.hyde@noaa.gov', /GLOBAL
    NCDF_ATTPUT, SD_ID, 'NETCDF_DATE_CREATED', STRMID(DATE_NOW(),0,8), /GLOBAL

;		****************************
; 	*** Create an SD dataset ***
;		****************************
;   ===> Create a TIME variable
    TID = NCDF_DIMDEF(SD_ID, 'D', 1)
    TIME_ID = NCDF_VARDEF(SD_ID, 'TIME', TID, /LONG)
    TIME_VAL = STRMID(SI.PERIOD,STRPOS(FN.PERIOD,'_')+1)
    TAGNAMES = TAG_NAMES(FN)
    NCDF_ATTPUT, SD_ID, TIME_ID, 'DATETIME', LONG(TIME_VAL) 
    NCDF_ATTPUT, SD_ID, TIME_ID, 'FORMAT', STRMID('yyyymmddhhmmss',0,STRLEN(TIME_VAL))  
    FOR _TARGET = 0,N_ELEMENTS(TAGNAMES_DATE)-1 DO BEGIN
      NAME = TAGNAMES_DATE(_TARGET)
      OK_POS = WHERE(TAGNAMES EQ NAME,COUNT)
      IF COUNT EQ 1 THEN BEGIN
        VAL = FN.(OK_POS)
        SZ = SIZE(VAL,/STRUCT)
        IF SZ.N_ELEMENTS EQ 1 THEN BEGIN
          IF SZ.TYPE EQ 7 AND VAL EQ '' THEN VAL = SEMICOLON
        ENDIF
        IF SZ.N_ELEMENTS GE 2 AND SZ.TYPE EQ 7 THEN VAL = STRJOIN(VAL+SEMICOLON)
        NCDF_ATTPUT, SD_ID, TIME_ID, NAME, VAL
      ENDIF
    ENDFOR
    NCDF_CONTROL, SD_ID, /ENDEF
    NCDF_VARPUT, SD_ID, TIME_ID, TIME_VAL ; Write the DATE into the dataset
     
    FOR PTH=0, N_ELEMENTS(PRODS)-1 DO BEGIN 
      POS = WHERE(TAG_NAMES(S.SD) EQ PRODS(PTH),COUNT)
      IF COUNT EQ 0 THEN CONTINUE
      GSTRUCT = IDL_RESTORE(!S.GLOBAL_PRODS + SI.SENSOR + '-' + PRODS[0] + '-GLOBAL.SAV')
      STRUCT = S.SD.(POS)
      PDATA = STRUCT.DATA
      BINS  = STRUCT.BINS
      IF NONE(LONS) THEN LONS = SUBSET_LONS ; Recreate LONS variable because it gets overwritten during multiple calls to MAPS_REMAP
      IF NONE(LATS) THEN LATS = SUBSET_LATS ; Recreate LATS variable because it gets overwritten during multiple calls to MAPS_REMAP
      RDATA = MAPS_REMAP(PDATA, BINS=BINS, MAP_IN=SI.MAP, MAP_OUT=MAP_OUT, MAP_SUBSET=MAP_SUBSET, CONTROL_LONS=LONS, CONTROL_LATS=LATS)
      SZ = SIZEXYZ(RDATA,PX=PX,PY=PY)
      
;		  ===> Add the DATA product
  	  XID = NCDF_DIMDEF(SD_ID, 'X', PX)
  	  YID = NCDF_DIMDEF(SD_ID, 'Y', PY)
  		PROD_ID = NCDF_VARDEF(SD_ID, PRODS(PTH), [XID,YID], /FLOAT, GZIP=9)
				
;     ===> Add PROD attributes
      NCDF_ATTPUT, SD_ID, PROD_ID, 'LONG_NAME',     GSTRUCT.LONG_NAME._DATA[0]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'STANDARD_NAME', GSTRUCT.STANDARD_NAME._DATA[0]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'XDIM',          PX
      NCDF_ATTPUT, SD_ID, PROD_ID, 'YDIM',          PY
      NCDF_ATTPUT, SD_ID, PROD_ID, '_FILLVALUE',    MISSINGS(PDATA)
      NCDF_ATTPUT, SD_ID, PROD_ID, 'ADD_OFFSET',    0.0
      NCDF_ATTPUT, SD_ID, PROD_ID, 'SCALE_FACTOR',  1.0
      NCDF_ATTPUT, SD_ID, PROD_ID, 'UNITS',         GSTRUCT.UNITS._DATA[0]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'VALID_MIN',     GSTRUCT.VALID_MIN._DATA[0]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'VALID_MAX',     GSTRUCT.VALID_MAX._DATA[0]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'INPUT_FILES',   [AFILE,GLOBAL.INPUT_FILES]
      NCDF_ATTPUT, SD_ID, PROD_ID, 'COMMENT',       GLOBAL.TITLE
      NCDF_ATTPUT, SD_ID, PROD_ID, 'BINNING_NOTES', GLOBAL.BINNING_SCHEME
      NCDF_ATTPUT, SD_ID, PROD_ID, 'SOURCE',        GLOBAL.INSTITUTION
      NCDF_ATTPUT, SD_ID, PROD_ID, 'REFERENCE',     GSTRUCT.REFERENCE._DATA[0]
      
      NCDF_CONTROL, SD_ID, /ENDEF
      NCDF_VARPUT, SD_ID, PROD_ID, RDATA ; Write the image Data into the dataset
    ENDFOR
		
		IF KEY(LONLAT) THEN BEGIN
  		PROD = 'longitude'
  		SZ=SIZE(SUBSET_LONS,/STRUCT) 
  		NCDF_CONTROL, SD_ID, /REDEF
      XID = NCDF_DIMDEF(SD_ID, 'XLON', SZ.DIMENSIONS[0])
      YID = NCDF_DIMDEF(SD_ID, 'YLON', SZ.DIMENSIONS[1])
      LON_ID = NCDF_VARDEF(SD_ID, PROD,[XID,YID],/FLOAT, GZIP=9)
      
  ;		===> Add dataset attributes
   		NCDF_ATTPUT, SD_ID, LON_ID, 'XDIM', 			 SZ.DIMENSIONS[0]
   		NCDF_ATTPUT, SD_ID, LON_ID, 'YDIM', 			 SZ.DIMENSIONS[1]
   		NCDF_ATTPUT, SD_ID, LON_ID, '_FILLVALUE',  MISSINGS(SUBSET_LONS)
  	  NCDF_ATTPUT, SD_ID, LON_ID, 'ADD_OFFSET',	 0.0
  	  NCDF_ATTPUT, SD_ID, LON_ID, 'SCALE_FACTOR',1.0
  	  NCDF_ATTPUT, SD_ID, LON_ID, 'UNITS',       'degrees'
  	  NCDF_ATTPUT, SD_ID, LON_ID, 'VALID_MIN',   -180.0
  	  NCDF_ATTPUT, SD_ID, LON_ID, 'VALID_MAX',    180.0

  	  NCDF_CONTROL, SD_ID, /ENDEF
      NCDF_VARPUT, SD_ID, LON_ID, SUBSET_LONS
  	  
  		PROD = 'latitude'
  		SZ=SIZE(SUBSET_LATS,/STRUCT)
  		NCDF_CONTROL, SD_ID, /REDEF
      XID = NCDF_DIMDEF(SD_ID, 'XLAT', SZ.DIMENSIONS[0])
      YID = NCDF_DIMDEF(SD_ID, 'YLAT', SZ.DIMENSIONS[1])
      LAT_ID = NCDF_VARDEF(SD_ID, PROD,[XID,YID],/FLOAT, GZIP=9)
      
  ;		===> Add dataset attributes
   		NCDF_ATTPUT, SD_ID, LAT_ID, 'XDIM',        SZ.DIMENSIONS[0]
      NCDF_ATTPUT, SD_ID, LAT_ID, 'YDIM',        SZ.DIMENSIONS[1]
      NCDF_ATTPUT, SD_ID, LAT_ID, '_FILLVALUE',  MISSINGS(SUBSET_LATS)
      NCDF_ATTPUT, SD_ID, LAT_ID, 'ADD_OFFSET',  0.0
      NCDF_ATTPUT, SD_ID, LAT_ID, 'SCALE_FACTOR',1.0
      NCDF_ATTPUT, SD_ID, LAT_ID, 'UNITS',       'degrees'
      NCDF_ATTPUT, SD_ID, LAT_ID, 'VALID_MIN',   -90.0
      NCDF_ATTPUT, SD_ID, LAT_ID, 'VALID_MAX',    90.0
   		
  	  NCDF_CONTROL, SD_ID, /ENDEF
      NCDF_VARPUT, SD_ID, LAT_ID, SUBSET_LATS
  
  	ENDIF
  
  	NCDF_CLOSE,SD_ID
    PFILE, NCDF_FILE
	ENDFOR ; FOR _FILES=0,N_ELEMENTS(FILES)-1L DO BEGIN


END; #####################  End of Routine ################################
