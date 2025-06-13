; $ID:	D3_2NETCDF.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
PRO D3_2NETCDF, D3_FILES, PERIOD_OUT=PERIOD_OUT, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, MERGE_FILES=MERGE_FILES, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, OUTFILE=OUTFILE
;+
; NAME:
;   D3_2NETCDF
; 
; PURPOSE:  
;   This program writes a "stacked" netcdf4 from a "D3" file
;
; CATEGORY: 
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:
;   D3_2NETCDF, D3_FILE
;
; REQUIRED INPUTS: 
;   D3_FILES...... Input D3 file(s)
;
; OPTIONAL_INPUTS
;   DIR_OUT....... Directory for writing output nc file
;   MAP_OUT....... Name of the map for the output structure 
; 
; KEYWORDS 
;   MERGE_FILES... Merge the data from multiple D3 files into a single netcdf
;   OVERWRITE..... Overwrite output nc file
;   VERBOSE....... Print program progress
;       
; OUTPUTS: 
;   A netcdf file written to the specified DIR_OUT directory
;
; OPTIONAL OUTPUTS
;   OUTFILE....... The name of the output nc file
;
; COMMON BLOCKS:
;   _WRITE_NETCDF_STACKED... Structure to save the information from the NETCDF_MASTER
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
;      
;      
; RESTRICTIONS:
;   Works with a NEFSC created D3 files 
;       
; NOTES:
;   NetCDF Metadata conventions: http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html#description-of-file-contents
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written January 25, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   Jan 25, 2021 - KJWH: Wrote initial code - adapted from WRITE_NETCDF.pro
;   Feb 03, 2021 - KJWH: Changed the name to D3_2NETCDF
;                        Now the input is a D3 file created by D3_MAKE
;   Sep 21, 2021 - KJWH: Updated to work with "stats" stacked files for a single product (e.g. SST)         
;   Oct 13, 2021 - KJWH: Changed _fillvalue to _FillValue to meet netcdf standards.     
;-
; ##################################################################################################################

  ROUTINE = 'D3_2NETCDF'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  CLOSE,/ALL,/FORCE
  
  COMMON _D3_2NETCDF, GLOBAL_STR, MTIME
  MASTER = !S.MAINFILES + 'NETCDF_MAIN.csv'
  IF NONE(MTIME) THEN MTIME = GET_MTIME(MASTER)
  IF GET_MTIME(MASTER) GT MTIME THEN INIT = 1 ELSE INIT = 0
  IF NONE(GLOBAL_STR) OR KEY(INIT) THEN BEGIN & GLOBAL_STR = CSV_READ(MASTER) & TIME = GET_MTIME(MASTER) & ENDIF 
  
  IF N_ELEMENTS(D3_FILES) NE 1 AND ~KEYWORD_SET(MERGE_FILES) THEN MESSAGE, 'ERROR: Must provide a single D3 input file unless the files are being merged.'
  
  D3_DB_FILES = [] & D3_METAFILES = [] & D3_BINS_FILES = []
  FOR D=0, N_ELEMENTS(D3_FILES)-1 DO BEGIN
    D3_FILE = D3_FILES[D]
    IF STRPOS(D3_FILE,'-D3_DAT.FLT') LT 0 THEN MESSAGE, 'ERROR: The input file should be the D3_DAT.FLT file'
    D3_DB_FILES  = [D3_DB_FILES,REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_DB.SAV')]
    D3_METAFILES = [D3_METAFILES,REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_METADATA.SAV')]
    D3_BINS_FILES = [D3_BINS_FILES,REPLACE(D3_FILE,'-D3_DAT.FLT','-D3_BINS.SAV')]  
  ENDFOR
  IF TOTAL(FILE_TEST([D3_FILES,D3_DB_FILES,D3_METAFILES])) NE 3*N_ELEMENTS(D3_FILES) THEN MESSAGE, 'ERROR: One of the D3 file(s) does not exist.'
       
  ; ===> Get dimensions, map and prod from the D3_FILE
  FA=PARSE_IT(D3_FILES[0],/ALL) & PX=LONG(FA.PX) & PY=LONG(FA.PY) & PZ=LONG(FA.PZ) & MAPP=FA.MAP & PROD=FA.PROD
  
  ; ===> Get the map information
  IF NONE(MAP_OUT) THEN MP = MAPP ELSE MP = MAP_OUT
  IF IS_L3B(MP) THEN MESSAGE, 'ERROR: WRITE_NETCDF_STACKED not equipped to work with L3B files. MAP_OUT must be provided.'
  MSZ = MAPS_SIZE(MP,PX=MPX,PY=MPY)
  IF HAS(D3_FILE,'L3B') THEN BINS = IDL_RESTORE(D3_BINS_FILES[0]) ELSE BINS = []               ; Get the BIN information if a L3B map
  
  ; ===> Get the MAP information for the global attributes and lon/lat data
  MI = MAPS_INFO(MP)                                                                          ; Get standard information about the "MAP"
  MR = MAPS_READ(MP)                                                                          ; Read the "MAP" information
  LL = MAPS_2LONLAT(MP,LONS=LONS,LATS=LATS)                                                   ; Get the LONS and LATS of the "MAP"
  SZLAT = SIZEXYZ(LATS,PX=PXLAT,PY=PYLAT)                                                     ; Get the size dimensions of the LAT array
  SZLON = SIZEXYZ(LONS,PX=PXLON,PY=PYLON)                                                     ; Get the size dimensions of the LON array
  IF SAME(LATS[*,0]) AND SAME(LATS[*,-1]) AND SAME(LONS[0,*]) AND SAME(LONS[-1,*]) THEN BEGIN ; Look for "gridded" map coordinates
    LATS = REFORM(LATS[0,*])                                                                  ; Create 1D latitude array
    LONS = REFORM(LONS[*,0])                                                                  ; Create 1D longitude array
    LONLAT_1D=1
  ENDIF ELSE LONLAT_1D=0
  IF KEY(LONLAT_1D) AND (N_ELEMENTS(LATS) NE PYLAT OR N_ELEMENTS(LONS) NE PXLON) THEN MESSAGE, 'ERROR: Check the lon/lat dimensions.'
  LONRES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT])/111.0,3)            ; Get the LON resolution
  LATRES = ROUNDS(MEAN([MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3)           ; Get the LAT resolution
  SPARES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT,MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3) ; Get the spatial resolution

  
  ; ===> Create the output directory
  IF NONE(DIR_OUT) THEN BEGIN
    FP = FA
    COUNTER = 0
    WHILE FP.SUB NE 'STACKED_FILES' DO BEGIN
      COUNTER = COUNTER + 1
      IF COUNTER GT 5 OR FP.SUB EQ 'DATASETS' THEN MESSAGE, 'ERROR: Unable to create the output directory'
      POS = STRPOS(FP.DIR,SL+FP.SUB+SL,/REVERSE_SEARCH)
      FP = FILE_PARSE(STRMID(FP.DIR,0,POS+1))
    ENDWHILE
    DIR = REPLACE(FP.DIR,[FA.MAP,'SAVE','STATS','ANOMS'],[MP,'NETCDF','NETCDF_STATS','NETCDF_SAVE']) + 'NETCDF' + SL + FA.PROD_ALG + SL
  ENDIF ELSE DIR = DIR_OUT
  DIR_TEST, DIR
  
  ; ===> Get the number of files from the DB and determine the output periods
  DB=STRUCT_READ(D3_DB_FILES[0]) & N_FILES=NOF(DB) & IF KEY(VERBOSE) THEN PLUN, LOG_LUN,'N_FILES = ' ,N_FILES
  IF ANY(PERIOD_OUT) THEN BEGIN
    SETS = PERIOD_SETS(PERIOD_2JD(DB.PERIOD),PERIOD_CODE=PERIOD_OUT) 
    DBSUBS = SETS.SUBS
    PERIODS = SETS.PERIOD
  ENDIF ELSE BEGIN
    DBSUBS = STRJOIN(INDGEN(N_ELEMENTS(DB)),';')
    PERIODS = FA.PERIOD
  ENDELSE
  
  NCFILES = []
  FOR S=0, N_ELEMENTS(PERIODS)-1 DO NCFILES = [NCFILES,DIR + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP],[PERIODS[S],MP]) + '.nc']
  IF FILE_MAKE(D3_FILES,NCFILES,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE  
  
  ; ===> Get the metadata from the D3 metadata file
  META = STRUCT_READ(D3_METAFILES[0])
  NCI = META.GLOBAL & NCTAGS = TAG_NAMES(NCI)
  NCIS = META.FILE_INFORMATION
  
  ; ===> Get additional global metadata
  CONTRIB = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'CONTRIBUTOR')) & CTAGS = TAG_NAMES(CONTRIB)
  SOURCE  = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'SOURCE_DATA')) & STAGS = TAG_NAMES(SOURCE)
 
  ; ===> Check to make sure the files in the DB and METADATA files match  
  OK = WHERE(NCIS.FILE NE DB.NAME+'.SAV',COUNT)
  IF COUNT GT 0 THEN MESSAGE, 'ERROR: DB and METADATA file information do not match.'

IF KEYWORD_SET(MERGE_FILES) THEN MESSAGE, 'ERROR: Still need to work up the code to merge multiple D3 files'
  
  ; ===> Open the D3 file
  IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'
  OPENR, D3_LUN, D3_FILE, /GET_LUN
  SHMMAP, 'D3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=D3_FILE  ;===> MAP THE D3 ARRAY TO THE D3_FILE
  D3 = SHMVAR('D3')     ; ;===> GET THE D3 ARR
  
  FOR S=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
    APER = PERIODS[S]
    ; ===> Create the output NC file name
    NC_FILE = DIR + REPLACE(FA.NAME,[FA.PERIOD,FA.MAP],[APER,MP]) + '.nc'
    IF FILE_MAKE(D3FILE, NC_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    IF FILE_TEST(NC_FILE) THEN FILE_DELETE, NC_FILE ; Remove the NC_FILE if it already exists
    
    ; ===> Subset the data
    SUBS = STRSPLIT(DBSUBS[S],';',/EXTRACT)
    DSUBS = DB[SUBS]
    NCISUBS = NCIS[SUBS]
    INFILES = DSUBS.NAME
    
    ; ===> Loop through files
    FULLARR = FLTARR(PXLON,PYLON,N_ELEMENTS(SUBS))
    FOR F=0,N_ELEMENTS(SUBS)-1L DO BEGIN
      SUB = FIX(SUBS[F])
      ARR  = D3[*,*,SUB]
      IF MP NE MAPP THEN ARR = MAPS_REMAP(ARR, MAP_IN=MAPP, MAP_OUT=MP, BINS=BINS)
      FULLARR[*,*,F] = ARR
    ENDFOR
    
        
    ; ===> Get the TIME information from the files
    TIMES = NCISUBS.TIME
  
    ; ===> Start the NCDF interface
    PFILE, NC_FILE, /M, _POFTXT=OUTTXT
    SD_ID = NCDF_CREATE(NC_FILE[0],/CLOBBER,/NETCDF4_FORMAT)
    IF SD_ID EQ -1 THEN MESSAGE, 'ERROF: NCDF_CREATE failed'

  ; ===> Write the global attributes
    NCDF_ATTPUT, SD_ID, 'title', NCI.TITLE, /GLOBAL, /CHAR
  
    FOR N=0, N_ELEMENTS(GLOBAL_STR)-1 DO IF GLOBAL_STR[N].VALUE NE MISSINGS(GLOBAL_STR[N].VALUE) THEN NCDF_ATTPUT, SD_ID, GLOBAL_STR[N].TAG, GLOBAL_STR[N].VALUE, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'date_netcdf_created', DATE_FORMAT(DATE_NOW(),/DAY), /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'date_input_files_created', DATE_FORMAT(MIN(GET_MTIME(D3_FILE,/DATE)))+'_'+DATE_FORMAT(MAX(GET_MTIME(D3_FILE,/DATE))), /GLOBAL, /CHAR
   ; NCDF_ATTPUT, SD_ID, 'original_file_name', FN.NAME_EXT, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'input_filenames', INFILES, /GLOBAL, /CHAR

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
    NCDF_ATTPUT, SD_ID, 'geospatial_lat_resolution', LATRES + ' degrees', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'geospatial_lat_units', 'degrees_north', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'geospatial_lon_max', MI.LL_BOX[3], /GLOBAL
    NCDF_ATTPUT, SD_ID, 'geospatial_lon_min', MI.LL_BOX[1], /GLOBAL
    NCDF_ATTPUT, SD_ID, 'geospatial_lon_resolution', LONRES + 'degrees', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'geospatial_lon_units', 'degrees_east', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'geospatial_vertial_max', 0.0, /GLOBAL
    NCDF_ATTPUT, SD_ID, 'geospatial_vertial_min', 0.0, /GLOBAL
    NCDF_ATTPUT, SD_ID, 'geospatial_vertial_positive', 'up', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'geospatial_vertial_units', 'm', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'spatial_resolution', SPARES + ' km/pixel', /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'central_lat', FLOAT(MI.MID_MID[0]), /GLOBAL
    NCDF_ATTPUT, SD_ID, 'central_lon', FLOAT(MI.MID_MID[1]), /GLOBAL
    NCDF_ATTPUT, SD_ID, 'projection', MR.PROJ4, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'projection_type','lonlat_grid', /GLOBAL, /CHAR
    IF IS_L3B(MAPP) AND ~IS_L3B(MP) THEN NCDF_ATTPUT, SD_ID, 'map_notes', 'Level-3 binned data remapped using IDL', /GLOBAL, /CHAR
  
  ;   ===> Add the global PRODUCT info
    IF NCI.LEVEL         NE '' THEN NCDF_ATTPUT, SD_ID, 'processing_level',    NCI.LEVEL,         /GLOBAL, /CHAR
    IF NCI.PROD          NE '' THEN NCDF_ATTPUT, SD_ID, 'product_name',        NCI.PROD,          /GLOBAL, /CHAR
    IF NCI.ALG_NAME      NE '' THEN NCDF_ATTPUT, SD_ID, 'product_algorithm',   NCI.ALG_NAME,      /GLOBAL, /CHAR
    IF NCI.ALG           NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_name',      NCI.ALG,           /GLOBAL, /CHAR
    IF NCI.ALG_REFERENCE NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_reference', NCI.ALG_REFERENCE, /GLOBAL, /CHAR
    IF NCI.UNITS         NE '' THEN NCDF_ATTPUT, SD_ID, 'units',               NCI.UNITS,         /GLOBAL, /CHAR
  
  ;   ===> Add the global TIME info
    NCDF_ATTPUT, SD_ID, 'time_coverage_start',    NCISUBS[0].TIME_START,  /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'time_coverage_end',      NCISUBS[-1].TIME_END,    /GLOBAL, /CHAR
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
    IF NCISUBS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
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
    
    IF NCISUBS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
    
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
    LONID = NCDF_DIMDEF(SD_ID, 'longitude', PXLON) ; Create the X dimensions for the gridded data
    LATID = NCDF_DIMDEF(SD_ID, 'latitude', PYLAT) ; Create the Y dimensions for the gridded data
    IF KEY(LONLAT_1D) THEN BEGIN
      LON_ID = NCDF_VARDEF(SD_ID, 'longitude', LONID, /FLOAT, GZIP=9) ; Add the 1D longitude variable to the file
      LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', LATID, /FLOAT, GZIP=9) ; Add the 1D latitude varialbe to the file
    ENDIF ELSE BEGIN
      LON_ID = NCDF_VARDEF(SD_ID, 'longitude', [LONID,LATID],/FLOAT, GZIP=9) ; Add the 2D longitude variable to the file
      LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', [LONID,LATID],/FLOAT, GZIP=9) ; Add the 2D latitude variable to the file
    ENDELSE

;   ===> Add the LON/LAT dataset attributes
    NCDF_ATTPUT,  SD_ID, LON_ID, '_CoordinateAxisType', 'Lon', /CHAR
    NCDF_ATTPUT,  SD_ID, LON_ID, 'comment', 'Longitude values are at the center of the grid cells', /CHAR
    NCDF_ATTPUT,  SD_ID, LON_ID, 'actual_range', STRJOIN(ROUNDS(MINMAX(LONS),2),'; '), /CHAR
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
    NCDF_VARPUT,  SD_ID, LON_ID, LONS ; Add the longitude values
  
    NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
    NCDF_ATTPUT,  SD_ID, LAT_ID, '_CoordinateAxisType', 'Lat', /CHAR
    NCDF_ATTPUT,  SD_ID, LAT_ID, 'comment', 'Latitude values are at the center of the grid cells', /CHAR
    NCDF_ATTPUT,  SD_ID, LAT_ID, 'actual_range', STRJOIN(ROUNDS(MINMAX(LATS),2),'; '), /CHAR
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
    NCDF_VARPUT,  SD_ID, LAT_ID, LATS ; Add the latitude values

  
    NCDF_CONTROL, SD_ID, /REDEF;PUT THE OPEN NETCDF FILE INTO DEFINE MODE
    FASIZE = SIZEXYZ(FULLARR,PX=FPX,PY=FPY,PZ=FPZ)
    XID = NCDF_DIMDEF(SD_ID, 'x', FPX) ; Create the X dimensions for the gridded data
    YID = NCDF_DIMDEF(SD_ID, 'y', FPY) ; Create the Y dimensions for the gridded data
    ZID = NCDF_DIMDEF(SD_ID, 'z', FPZ) ; Create the Z dimensions for the gridded data
      
    SNAMES = [] ; Create a list of product names and look for duplicates
    FILL = []
    OK = WHERE(FULLARR EQ MISSINGS(FULLARR),COUNT)
    IF COUNT GT 0 THEN BEGIN
      CASE IDLTYPE(FULLARR) OF
        'FLOAT' : FILL = -99999.0
        'LONG'  : FILL = -99999L
        'INT'   : FILL = -32767
        'DOUBLE': FILL = -99999.0D
        'STRING': FILL = 'NA'
        ELSE: MESSAGE, 'ERROR: Must add _FILLVALUE for the data type ' + IDLTYPE(RDATA)
      ENDCASE
      FULLARR[OK] = FILL
    ENDIF
                
; ===> Define attribute information for the product 
      ANCILLARY_VARIABLES = []
      SCOMMENT = []
      IOOS = []
      CCTYPE = 'physicalMeasurement'
      METHOD = []
      SMIN = []
      SMAX = []
      SUNIT = (PRODS_READ(PROD)).UNITS 
      STANDARD_NAME =(PRODS_READ(PROD)).CF_STANDARD_NAME
      CR = VALIDS('PROD_CRITERIA',PROD) 
      IF CR EQ '-Inf_Inf' THEN MESSAGE, 'ERROR: Must add PROD_CRITERIA information to PRODS_MAIN for ' + APROD
      IF N_ELEMENTS(CR) NE 1 THEN CR = [] ELSE CR = STRSPLIT(CR,'_',/EXTRACT)
      IF CR NE [] THEN SMIN = FLOAT(CR[0])
      IF CR NE [] THEN SMAX = FLOAT(CR[1])

      PRS = PRODS_READ(PROD)
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
      
      CASE IDLTYPE(FULLARR) OF ; Define the variables to be used in the file based on the data type
        'FLOAT':  PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /FLOAT,  GZIP=9)
        'INT':    PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /LONG,   GZIP=9)
        'LONG':   PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /FLOAT,  GZIP=9)
        'DOUBLE': PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [XID,YID,ZID], /DOUBLE, GZIP=9)
      ENDCASE
       
      IF PROD_ID EQ -1 THEN MESSAGE, 'ERROR: Check PROD_ID'

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
      IF ANY(IOOS)                THEN IF IOOS                NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', IOOS, /CHAR $
                                                                    ELSE NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', NCI.IOOS_CATEGORY, /CHAR
      NCDF_ATTPUT, SD_ID, PROD_ID, 'coverage_content_type', CCTYPE, /CHAR 
      
      NCDF_CONTROL, SD_ID, /ENDEF;LEAVE DEFINE MODE AND ENTER DATA MODE. 
      NCDF_VARPUT,  SD_ID, PROD_ID, FULLARR ; WRITE THE IMAGE DATA INTO THE DATASET
      
      ;===> CLOSE THE NCDF FILE
      NCDF_CLOSE,SD_ID
      CLOSE,/ALL,/FORCE

      GONE, XID
      GONE, YID
      GONE, SD_ID
    
    ENDFOR ; FOR NTH=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
 
    
    
   
    IF KEY(VERBOSE) THEN PFILE, NC_FILE
    
 ; ENDFOR;FOR _FILES=0,N_ELEMENTS(FILES)-1L DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'
  DONE:

END; #####################  END OF ROUTINE ################################
