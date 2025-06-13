; $ID:	FRONT_INDICATORS_2NETCDF.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO FRONT_INDICATORS_2NETCDF, DATARRAY, TAGS=TAGS, MAPSTRUCT=MAPSTRUCT, METASTRUCT=METASTRUCT, MASKSTRUCT=MASKSTRUCT, NCFILE=NCFILE, SAVFILES=SAVFILES

;+
; NAME:
;   FRONT_INDICATORS_2NETCDF
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   $CATEGORY$
;
; CALLING SEQUENCE:
;   FRONT_INDICATORS_2NETCDF,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   FILES.......... Files with frontal indicator data 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 29, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 29, 2021 - KJWH: Initial code written
;   Oct 13, 2021 - KJWH: Changed _fillvalue to _FillValue to meet netcdf standards.     
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'FRONT_INDICATORS_2NETCDF'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(NCFILE) NE 1 THEN MESSAGE, 'ERROR: Must provide output nc file name.'
  NCIS = METASTRUCT
  NCI = NCIS[0] & NCTAGS = TAG_NAMES(NCI)
  TIMES = NCIS.TIME
  MPS = MAPSTRUCT
  MI = MPS.MAP_INFO
  MR = MPS.MAP_READ
  MAPP = (PARSE_IT(SAVFILES[0],/ALL)).MAP
  
  SZ = SIZE(DATARRAY)
  IF SZ[0] NE 4 THEN MESSAGE, 'ERROR: 4D array expected'
  IF SZ[4] NE N_ELEMENTS(TAGS) THEN MESSAGE, 'ERROR: The number of tags should eq ' + NUM2STR(SZ[4])

  ; ===> Get additional global metadata
  CONTRIB = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'CONTRIBUTOR')) & CTAGS = TAG_NAMES(CONTRIB)
  SOURCE  = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'SOURCE_DATA')) & STAGS = TAG_NAMES(SOURCE)

  ; ===> Start the NCDF interface
  PFILE, NCFILE, /M, _POFTXT=OUTTXT
  IF FILE_TEST(NCFILE) THEN FILE_DELETE, NCFILE                         ; Delete NCFILE if it exists
  SD_ID = NCDF_CREATE(NCFILE[0],/CLOBBER,/NETCDF4_FORMAT)
  IF SD_ID EQ -1 THEN MESSAGE, 'ERROF: NCDF_CREATE failed'

  ; ===> Write the global attributes
  NCDF_ATTPUT, SD_ID, 'title', NCI.TITLE, /GLOBAL, /CHAR

  FOR N=0, N_ELEMENTS(GLOBAL_STR)-1 DO IF GLOBAL_STR[N].VALUE NE MISSINGS(GLOBAL_STR[N].VALUE) THEN NCDF_ATTPUT, SD_ID, GLOBAL_STR[N].TAG, GLOBAL_STR[N].VALUE, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'date_netcdf_created', DATE_FORMAT(DATE_NOW(),/DAY), /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'date_input_files_created', DATE_FORMAT(MIN(GET_MTIME(SAVFILES,/DATE)))+'_'+DATE_FORMAT(MAX(GET_MTIME(SAVFILES,/DATE))), /GLOBAL, /CHAR
  ; NCDF_ATTPUT, SD_ID, 'original_file_name', FN.NAME_EXT, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'input_filenames', SAVFILES, /GLOBAL, /CHAR

  ; ===> Add the global CONTRIBUTOR and SOURCE info
  FOR N=0, N_ELEMENTS(CTAGS)-1 DO IF CONTRIB.(N) NE '' THEN NCDF_ATTPUT, SD_ID, STRLOWCASE(CTAGS[N]), CONTRIB.(N), /GLOBAL, /CHAR
  FOR N=0, N_ELEMENTS(STAGS)-1 DO IF SOURCE.(N)  NE '' THEN NCDF_ATTPUT, SD_ID, STRLOWCASE(STAGS[N]), SOURCE.(N),  /GLOBAL, /CHAR

  ; ===> Add the SENSOR info
  NCDF_ATTPUT, SD_ID, 'platform', NCI.PLATFORM, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'sensor',   NCI.SHORT_NAME, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'source_data_version',   NCI.SOURCE_DATA_VERSION, /GLOBAL, /CHAR

  ; ===> Add the global MAP info
  NCDF_ATTPUT, SD_ID, 'geospatial_lat_max', MI.LL_BOX[2], /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_lat_min', MI.LL_BOX[0], /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_lat_resolution', MPS.LATRES + ' degrees', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'geospatial_lat_units', 'degrees_north', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'geospatial_lon_max', MI.LL_BOX[3], /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_lon_min', MI.LL_BOX[1], /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_lon_resolution', MPS.LONRES + 'degrees', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'geospatial_lon_units', 'degrees_east', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'geospatial_vertial_max', 0.0, /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_vertial_min', 0.0, /GLOBAL
  NCDF_ATTPUT, SD_ID, 'geospatial_vertial_positive', 'up', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'geospatial_vertial_units', 'm', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'spatial_resolution', MPS.SPARES + ' km/pixel', /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'central_lat', FLOAT(MI.MID_MID[0]), /GLOBAL
  NCDF_ATTPUT, SD_ID, 'central_lon', FLOAT(MI.MID_MID[1]), /GLOBAL
  NCDF_ATTPUT, SD_ID, 'projection', MR.PROJ4, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'projection_type','lonlat_grid', /GLOBAL, /CHAR
  IF IS_L3B(MAPP) AND ~IS_L3B(MPS.MAP) THEN NCDF_ATTPUT, SD_ID, 'map_notes', 'Level-3 binned data remapped using IDL', /GLOBAL, /CHAR

  ;   ===> Add the global PRODUCT info
  IF NCI.LEVEL         NE '' THEN NCDF_ATTPUT, SD_ID, 'processing_level',    NCI.LEVEL,         /GLOBAL, /CHAR
  IF NCI.PROD          NE '' THEN NCDF_ATTPUT, SD_ID, 'product_name',        NCI.PROD,          /GLOBAL, /CHAR
  IF NCI.ALG_NAME      NE '' THEN NCDF_ATTPUT, SD_ID, 'product_algorithm',   NCI.ALG_NAME,      /GLOBAL, /CHAR
  IF NCI.ALG           NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_name',      NCI.ALG,           /GLOBAL, /CHAR
  IF NCI.ALG_REFERENCE NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_reference', NCI.ALG_REFERENCE, /GLOBAL, /CHAR
  IF NCI.UNITS         NE '' THEN NCDF_ATTPUT, SD_ID, 'units',               NCI.UNITS,         /GLOBAL, /CHAR

  ;   ===> Add the global TIME info
  NCDF_ATTPUT, SD_ID, 'time_coverage_start',    NCIS[0].TIME_START,  /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'time_coverage_end',      NCIS[-1].TIME_END,    /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'time_period',            NCI.PERIOD_NAME, /GLOBAL, /CHAR
  NCDF_ATTPUT, SD_ID, 'time_coverage_duration', NCI.DURATION,    /GLOBAL, /CHAR

  ;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  ; ===> Add the Scientific Data information

  ; ===> Create the TIME variable
  ;NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
  TID = NCDF_DIMDEF(SD_ID, 'time', N_ELEMENTS(TIMES)) ; Create a Z (time) dimesion for the data files
  TIME_ID = NCDF_VARDEF(SD_ID, 'time', TID, /FLOAT, GZIP=9) ; Add the TIME varialbe to the file

  ;   ===> Add the TIME dataset attributes
  NCDF_ATTPUT, SD_ID, TIME_ID, '_CoordinateAxisType','Time', /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'axis','T', /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'long_name', 'reference time of the data field', /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'standard_name','time', /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'ioos_category', 'Time',/CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'coverage_content_type', 'coordinate', /CHAR
  IF NCIS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
    stop ; Need to figure out how to record the climatology "times"
    NCDF_ATTPUT, SD_ID, TIME_ID, 'climatology', 'climatology bounds', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'climatology period', NCI.CLIM_BOUNDS, /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'method', NCI.CLIM_METHOD, /CHAR
  ENDIF
  NCDF_ATTPUT, SD_ID, TIME_ID, 'comment', 'nominal time from the start of the time period', /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'time_origin', NCI.TIME_ORIGIN, /CHAR
  NCDF_ATTPUT, SD_ID, TIME_ID, 'units', NCI.TIME_UNITS, /CHAR
  NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
  NCDF_VARPUT,  SD_ID, TIME_ID, TIMES ; Add the TIME information to the file

  IF NCIS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN

    stop ; Need to figure out how to record the climatology "times"

    NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
    CLI_ID = NCDF_VARDEF(SD_ID, 'climatology_bounds', TID, /FLOAT) ; Add the TIME varialbe to the file
    NCDF_ATTPUT, SD_ID, CLI_ID, 'climatology', 'climatology bounds', /CHAR
    NCDF_ATTPUT, SD_ID, CLI_ID, 'long_name', 'Climate Time Boundaries
    NCDF_ATTPUT, SD_ID, CLI_ID, 'ioos_category', 'Time',/CHAR
    NCDF_ATTPUT, SD_ID, CLI_ID, 'coverage_content_type', 'coordinate', /CHAR
    NCDF_ATTPUT, SD_ID, CLI_ID, 'climatology period', NCI.CLIM_BOUNDS, /CHAR
    NCDF_ATTPUT, SD_ID, CLI_ID, 'method', NCI.CLIM_METHOD, /CHAR
    NCDF_ATTPUT, SD_ID, CLI_ID, 'units', 'seconds since 1970-01-01T00:00:00Z', /CHAR
    NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
    NCDF_VARPUT,  SD_ID, CLI_ID, NCI.TIME ; Add the TIME information to the file
  ENDIF


  ; ===> Create the LON and LAT variables
  NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
  LONID = NCDF_DIMDEF(SD_ID, 'longitude', MPS.PXLON) ; Create the X dimensions for the gridded data
  LATID = NCDF_DIMDEF(SD_ID, 'latitude', MPS.PYLAT) ; Create the Y dimensions for the gridded data
  IF KEY(MPS.LONLAT_1D) THEN BEGIN
    LON_ID = NCDF_VARDEF(SD_ID, 'longitude', LONID, /FLOAT, GZIP=9) ; Add the 1D longitude variable to the file
    LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', LATID, /FLOAT, GZIP=9) ; Add the 1D latitude varialbe to the file
  ENDIF ELSE BEGIN
    LON_ID = NCDF_VARDEF(SD_ID, 'longitude', [LONID,LATID],/FLOAT, GZIP=9) ; Add the 2D longitude variable to the file
    LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', [LONID,LATID],/FLOAT, GZIP=9) ; Add the 2D latitude variable to the file
  ENDELSE

  ;   ===> Add the LON/LAT dataset attributes
  NCDF_ATTPUT,  SD_ID, LON_ID, '_CoordinateAxisType', 'Lon', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'comment', 'Longitude values are at the center of the grid cells', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'actual_range', STRJOIN(ROUNDS(MINMAX(MPS.LONS),2),'; '), /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'axis', 'X', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'coordsys', 'geographic', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'ioos_category', 'Location', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'coverage_content_type', 'coordinate', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'long_name','Longitude', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'standard_name','longitude', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'units', 'degrees_east', /CHAR
  NCDF_ATTPUT,  SD_ID, LON_ID, 'valid_max', 180.0
  NCDF_ATTPUT,  SD_ID, LON_ID, 'valid_min', -180.0
  NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
  NCDF_VARPUT,  SD_ID, LON_ID, MPS.LONS ; Add the longitude values

  NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
  NCDF_ATTPUT,  SD_ID, LAT_ID, '_CoordinateAxisType', 'Lat', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'comment', 'Latitude values are at the center of the grid cells', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'actual_range', STRJOIN(ROUNDS(MINMAX(MPS.LATS),2),'; '), /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'axis', 'Y', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'coordsys', 'geographic', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'ioos_category', 'Location', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'coverage_content_type', 'coordinate', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'long_name','Latitude', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'standard_name','latitude', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'units', 'degrees_north', /CHAR
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'valid_max', 90.0
  NCDF_ATTPUT,  SD_ID, LAT_ID, 'valid_min', -90.0
  NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
  NCDF_VARPUT,  SD_ID, LAT_ID, MPS.LATS ; Add the latitude values

  SNAMES = [] ; Create a list of product names and look for duplicates
  NCDF_CONTROL, SD_ID, /REDEF;PUT THE OPEN NETCDF FILE INTO DEFINE MODE
  FASIZE = SIZEXYZ(DATARRAY[*,*,*,0],PX=FPX,PY=FPY,PZ=FPZ)
  XID = NCDF_DIMDEF(SD_ID, 'x', FPX) ; Create the X dimensions for the gridded data
  YID = NCDF_DIMDEF(SD_ID, 'y', FPY) ; Create the Y dimensions for the gridded data
  ZID = NCDF_DIMDEF(SD_ID, 'z', FPZ) ; Create the Z dimensions for the gridded data

; ===> Add the MASK data if it exists
  IF IDLTYPE(MASKSTRUCT) EQ 'STRUCT' THEN BEGIN
    
    CASE IDLTYPE(MASKSTRUCT.MASK) OF ; Define the variables to be used in the file based on the data type
      'BYTE':   PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /BYTE,   GZIP=9)
      'FLOAT':  PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /FLOAT,  GZIP=9)
      'INT':    PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /LONG,   GZIP=9)
      'LONG':   PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /LONG,   GZIP=9)
      'DOUBLE': PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /DOUBLE, GZIP=9)
    ENDCASE

    IF PROD_ID EQ -1 THEN MESSAGE, 'ERROR: Unable to create the PROD_ID'

    NCDF_ATTPUT,  SD_ID, PROD_ID, 'long_name',     'data mask', /CHAR
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'standard_name', 'mask', /CHAR
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'units',         'na', /CHAR
    NCDF_ATTPUT,  SD_ID, PROD_ID, '_FillValue',    0
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'mask_codes',    STRJOIN(STRTRIM(MASKSTRUCT.MASK_CODES,2),';'),/CHAR
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'mask_names',    STRJOIN(MASKSTRUCT.MASK_NAMES,';'),/CHAR
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_min',     MIN(MASKSTRUCT.MASK_CODES)
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_max',     MAX(MASKSTRUCT.MASK_CODES)
    NCDF_ATTPUT,  SD_ID, PROD_ID, 'comment',       MASKSTRUCT.MASK_NOTES, /CHAR

    NCDF_CONTROL, SD_ID, /ENDEF                                ; Leave define mode and enter data mode.
    NCDF_VARPUT,  SD_ID, PROD_ID, MASKSTRUCT.MASK              ; Write the image data into the dataset
  ENDIF
  
  FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN
    ARR = DATARRAY[*,*,*,T]
    ASZ = SIZEXYZ(ARR,PX=APX,PY=APY,PZ=APZ)
    IF APX NE FPX OR APY NE FPY OR APZ NE FPZ THEN MESSAGE, 'ERROR: Array dimensions do not match.'
    TAG = TAGS[T]
    PRS = PRODS_READ(TAG)
    ANAME = STRLOWCASE(PRS.NC_PROD) & IF ANAME EQ '' THEN ANAME = STRLOWCASE(PRS.PROD)
    OK = WHERE(SNAMES EQ STRLOWCASE(ANAME),COUNT)
    IF COUNT GT 0 THEN BEGIN
      SNAME = STRLOWCASE(SD_TAGS[NTH])
      OK = WHERE(SNAMES EQ SNAME,COUNT)
      IF COUNT GT 0 THEN MESSAGE, 'ERROR: Duplicate product names can not be written into the netcdf file.'
    ENDIF ELSE SNAME = STRLOWCASE(ANAME)
    SNAMES = [SNAMES,SNAME]

    LONG_NAME =(PRODS_READ(ANAME)).CF_LONG_NAME
    STANDARD_NAME =(PRODS_READ(ANAME)).CF_STANDARD_NAME
    SUNIT = (PRODS_READ(ANAME)).UNITS
    CR = VALIDS('PROD_CRITERIA',ANAME) & IF N_ELEMENTS(CR) EQ 1 AND CR[0] EQ '' THEN CR = ['',''] ELSE CR = STRSPLIT(CR,'_',/EXTRACT)
    IF CR EQ [] THEN SMIN = '' ELSE SMIN = FLOAT(CR[0])
    IF CR EQ [] THEN SMAX = '' ELSE SMAX = FLOAT(CR[1])
        
    FILL = []
    OK = WHERE(ARR EQ MISSINGS(ARR),COUNT)
    IF COUNT GT 0 THEN BEGIN
      CASE IDLTYPE(ARR) OF
        'FLOAT' : FILL = -99999.0
        'LONG'  : FILL = -99999L
        'INT'   : FILL = -32767
        'DOUBLE': FILL = -99999.0D
        'STRING': FILL = 'NA'
        ELSE: MESSAGE, 'ERROR: Must add _FILLVALUE for the data type ' + IDLTYPE(RDATA)
      ENDCASE
      ARR[OK] = FILL
    ENDIF
    
    CASE IDLTYPE(ARR) OF ; Define the variables to be used in the file based on the data type
      'FLOAT':  PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /FLOAT,  GZIP=9)
      'INT':    PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /LONG,   GZIP=9)
      'LONG':   PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /FLOAT,  GZIP=9)
      'DOUBLE': PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /DOUBLE, GZIP=9)
    ENDCASE
    
    IF PROD_ID EQ -1 THEN STOP

    IF LONG_NAME     NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'long_name',     LONG_NAME , /CHAR
    IF STANDARD_NAME NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'standard_name', STANDARD_NAME, /CHAR
    IF SUNIT         NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'units',         SUNIT, /CHAR
    IF ANY(FILL)           THEN NCDF_ATTPUT,  SD_ID, PROD_ID, '_FillValue',    FILL
    IF ANY(OFFSET)         THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'add_offset',    OFFSET
    IF ANY(FACTOR)         THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'scale_factor',  FACTOR
    IF ANY(SMIN)           THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_min',     FLOAT(SMIN)
    IF ANY(SMAX)           THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_max',     FLOAT(SMAX)
    IF ANY(ANCILLARY_VARIABLES) THEN IF ANCILLARY_VARIABLES NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'ancillary_variables', ANCILLARY_VARIABLES, /CHAR
    IF ANY(SCOMMENT)            THEN IF SCOMMENT            NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'comment', SCOMMENT, /CHAR
    IF ANY(METHOD)              THEN IF METHOD              NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'cell_methods', METHOD, /CHAR
    IF ANY(IOOS)                THEN BEGIN & IF IOOS        NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', IOOS, /CHAR 
                                                            ENDIF ELSE NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', NCI.IOOS_CATEGORY, /CHAR
    NCDF_ATTPUT, SD_ID, PROD_ID, 'coverage_content_type', 'physicalMeasurement', /CHAR

    NCDF_CONTROL, SD_ID, /ENDEF                    ; LEAVE DEFINE MODE AND ENTER DATA MODE.
    NCDF_VARPUT,  SD_ID, PROD_ID, ARR              ; WRITE THE IMAGE DATA INTO THE DATASET
   
  ENDFOR

  ;===> Close the ncdf file
  NCDF_CLOSE,SD_ID
  CLOSE,/ALL,/FORCE



END ; ***************** End of FRONT_INDICATORS_2NETCDF *****************
