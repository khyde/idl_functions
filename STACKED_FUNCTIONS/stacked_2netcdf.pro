; $ID:	STACKED_2NETCDF.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
PRO STACKED_2NETCDF, FILES, D3PRODS=D3PRODS, MASKSTRUCT=MASKSTRUCT, PERIOD_OUT=PERIOD_OUT, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, $
                    LOGLUN=LOGLUN, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, OUTFILE=OUTFILE
;+
; NAME:
;   STACKED_2NETCDF
; 
; PURPOSE:  
;   This program writes a "stacked" netcdf4 from a "D3HASH" file
;
; CATEGORY: 
;   D3_FUNCTIONS
;
; CALLING SEQUENCE:
;   STACKED_2NETCDF, D3_FILE
;
; REQUIRED INPUTS: 
;   FILES...... Input D3 file(s)
;
; OPTIONAL_INPUTS
;   D3PRODS....... The names of the products in the D3 file to be saved in the netcdf file (default is to include all products)
;   MASKSTRUCT.... A structure containing information for a data MASK
;   PERIOD_OUT.... The output period for the netcdf files (e.g. if W is provided, the daily files from a given week will be included in the file)
;   DIR_OUT....... Directory for writing output nc file
;   MAP_OUT....... Name of the map for the output structure 
;   LOGLUN........ The LUN for writing information to the LOG file
; 
; KEYWORDS 
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
;   _STACKED_2NETCDF... Structure to save the information from the NETCDF_MASTER
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
;   Works with a NEFSC created D3 HASH files 
;       
; NOTES:
;   NetCDF Metadata conventions: http://cfconventions.org/Data/cf-conventions/cf-conventions-1.7/cf-conventions.html#description-of-file-contents
;
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written January 25, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   Jul 06, 2021 - KJWH: Wrote initial code - copied from D3_2NETCDF.pro
;   Jul 08, 2021 - KJWH: Updated formating and documentation
;   Jul 14, 2021 - KJWH: Added MASKSTRUCT keyword and the option to add a data mask to the netcdf file
;   Oct 13, 2021 - KJWH: Changed _fillvalue to _FillValue to meet netcdf standards. 
;   Nov 05, 2021 - KJWH: Added LOGLUN parameter and PLUN statements    
;   Nov 14, 2022 - KJWH: Changed name of program from D3HASH_2NETCDF to STACKED_2NETCDF
;   Apr 11, 2023 - KJWH: Changed the x, y and z labels to longitude, latitude and time in order to be compliant with ERDDAP
;-
; ##################################################################################################################

  ROUTINE = 'STACKED_2NETCDF'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  CLOSE,/ALL,/FORCE
  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN                                                                ; Set up the LUN to record in the log file 
  
  COMMON _STACKED_2NETCDF, GLOBAL_STR, MTIME
  MASTER = !S.IDL_MAINFILES + 'NETCDF_MAIN.csv'
  STAT_NAMES = VALIDS('STATS')
  IF NONE(MTIME) THEN MTIME = GET_MTIME(MASTER)
  IF GET_MTIME(MASTER) GT MTIME THEN INIT = 1 ELSE INIT = 0
  IF NONE(GLOBAL_STR) OR KEY(INIT) THEN BEGIN & GLOBAL_STR = CSV_READ(MASTER) & TIME = GET_MTIME(MASTER) & ENDIF 
         
  FOR D=0, N_ELEMENTS(FILES)-1 DO BEGIN
    D3_FILE = FILES[D]
    FA=PARSE_IT(D3_FILE,/ALL)                                                                   ; Parse the file name
    PX=LONG(FA.PX) & PY=LONG(FA.PY) & PZ=LONG(FA.PZ) & MAPP=FA.MAP & PROD=FA.PROD               ; Get dimensions, map and prod from the D3_FILE name   
  
  ; ===> Get the map information
    IF NONE(MAP_OUT) THEN MP = MAPP ELSE MP = MAP_OUT
    IF IS_L3B(MP) THEN MESSAGE, 'ERROR: WRITE_NETCDF_STACKED not equipped to work with L3B files. MAP_OUT must be provided.'
    MSZ = MAPS_SIZE(MP,PX=MPX,PY=MPY)
    
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
      WHILE ~HAS(FP.SUB,'STACKED_') DO BEGIN
        COUNTER = COUNTER + 1
        IF COUNTER GT 5 OR FP.SUB EQ 'DATASETS' THEN MESSAGE, 'ERROR: Unable to create the output directory'
        POS = STRPOS(FP.DIR,SL+FP.SUB+SL,/REVERSE_SEARCH)
        FP = FILE_PARSE(STRMID(FP.DIR,0,POS+1))
      ENDWHILE
      DIR = REPLACE(FP.DIR,[FA.MAP,FP.SUB+SL,'SAVE','STATS','ANOMS'],[MP,'','NETCDF','NETCDF_STATS','NETCDF_SAVE']) + 'NETCDF' + SL + FA.PROD_ALG + SL
    ENDIF ELSE DIR = DIR_OUT
    DIR_TEST, DIR
  
  ; ===> Determine the output periods
    PERIODS = FA.PERIOD
    
    NCFILE = DIR + REPLACE(FA.NAME,[FA.MAP,'PXY_'+FA.PX+'_'+FA.PY],[MP,'']) + '.nc'
    IF HAS(NCFILE,'SUBSET') THEN BEGIN
      FP = STRSPLIT(NCFILE,'-',/EXTRACT)
      OK = WHERE_STRING(FP,'SUBSET')
      NCFILE = REPLACE(NCFILE,FP[OK],'')
    ENDIF
    WHILE HAS(NCFILE,'--') DO NCFILE = REPLACE(NCFILE,'--','-')

    IF FILE_MAKE(D3_FILE,NCFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    IF FILE_TEST(NCFILE) THEN FILE_DELETE, NCFILE ; Remove the NCFILE if it already exists
    
    ; ===> Open the D3 file
    POF, D, FILES, OUTTXT=OUTTXT,/QUIET
    PFILE, D3_FILE, /R, _POFTXT=OUTTXT, LOGLUN=LUN
    D3 = STACKED_READ(D3_FILE,INFO=INFO,BINS=BINS,KEYS=KEYS,PRODS=PRODS,DB=DB,METADATA=META)
    DATAPROD = META.GLOBAL.PROD
    IF N_ELEMENTS(D3PRODS) GE 1 THEN BEGIN
      OK = WHERE_MATCH(KEYS,D3PRODS,COUNT)
      IF COUNT GE 1 THEN PRODKEYS = KEYS[OK]
    ENDIF ELSE PRODKEYS = REMOVE(KEYS,VALUES=['FILE_DB','PRODS','BINS','INFO','METADATA','FMASK_INFO'])                                                                 ; Keep just the D3 variable names
    
    ; ===> Update the D3 database info
    DB = STRUCT_RENAME(DB,['STATFILE','ANOMFILE','STATNAME','ANOMNAME'],['FULLNAME','FULLNAME','NAME','NAME']);,/STRUCT_ARRAYS)
    DBDTR = STRSPLIT(DB.DATE_RANGE[0],'_',/EXTRACT)
    SUBS = WHERE(DB.DATE_RANGE NE '',COUNT)
    PERS = DB[SUBS].PERIOD
    DBPERSTR = PERIOD_2STRUCT(DB.PERIOD)
    DBSTART = DATE_2JD(DBPERSTR[SUBS[0]].DATE_START)
    DBEND   = DATE_2JD(DBPERSTR[SUBS[-1]].DATE_END)
    TIMES = JD_2SECONDS1970(PERIOD_2JD(DB[SUBS].PERIOD)) ; ===> Get the TIME information from the files
    
    INFILES = DB[SUBS].NAME
    IF HAS(DB,'ORIGINAL_FILES') THEN BEGIN
      ORGFILES = STR_BREAK(DB[SUBS].ORIGINAL_FILES,'; ')
      FN = FILE_PARSE(ORGFILES)
      ORGSET = WHERE_SETS(FN.DIR)
      ORGFILES = REPLACE(ORGFILES,ORGSET.VALUE,REPLICATE('',N_ELEMENTS(ORGSET)))
    ENDIF ELSE ORGFILES = []
    
    ; ===> Get the metadata from the D3 metadata file
    NCI = META.GLOBAL & NCTAGS = TAG_NAMES(NCI)
    NCIS = META.FILE_INFORMATION
    
    ; ===> Get additional global metadata
    CONTRIB = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'CONTRIBUTOR')) & CTAGS = TAG_NAMES(CONTRIB)
    SOURCE  = STRUCT_COPY(NCI,WHERE_STRING(NCTAGS,'SOURCE_DATA')) & STAGS = TAG_NAMES(SOURCE)
     
     
      ; ===> Start the NCDF interface
      PFILE, NCFILE, /M, _POFTXT=OUTTXT, LOGLUN=LUN
      SD_ID = NCDF_CREATE(NCFILE[0],/CLOBBER,/NETCDF4_FORMAT)
      IF SD_ID EQ -1 THEN MESSAGE, 'ERROF: NCDF_CREATE failed'
  
      ; ===> Write the global attributes
      NCDF_ATTPUT, SD_ID, 'title', NCI.TITLE, /GLOBAL, /CHAR
    
      FOR N=0, N_ELEMENTS(GLOBAL_STR)-1 DO IF GLOBAL_STR[N].VALUE NE MISSINGS(GLOBAL_STR[N].VALUE) THEN NCDF_ATTPUT, SD_ID, GLOBAL_STR[N].TAG, GLOBAL_STR[N].VALUE, /GLOBAL, /CHAR
      NCDF_ATTPUT, SD_ID, 'date_netcdf_created', DATE_FORMAT(DATE_NOW(),/DAY), /GLOBAL, /CHAR
      NCDF_ATTPUT, SD_ID, 'date_input_files_created', DATE_FORMAT(MIN(GET_MTIME(D3_FILE,/DATE)))+'_'+DATE_FORMAT(MAX(GET_MTIME(D3_FILE,/DATE))), /GLOBAL, /CHAR
      IF ORGFILES NE [] THEN NCDF_ATTPUT, SD_ID, 'original_file_name', ORGFILES, /GLOBAL, /CHAR
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
  
      ; ===> Add the global PRODUCT info
      IF NCI.LEVEL         NE '' THEN NCDF_ATTPUT, SD_ID, 'processing_level',    NCI.LEVEL,         /GLOBAL, /CHAR
      IF NCI.PROD          NE '' THEN NCDF_ATTPUT, SD_ID, 'product_name',        NCI.PROD,          /GLOBAL, /CHAR
      IF NCI.ALG_NAME      NE '' THEN NCDF_ATTPUT, SD_ID, 'product_algorithm',   NCI.ALG_NAME,      /GLOBAL, /CHAR
      IF NCI.ALG           NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_name',      NCI.ALG,           /GLOBAL, /CHAR
      IF NCI.ALG_REFERENCE NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_reference', NCI.ALG_REFERENCE, /GLOBAL, /CHAR
      IF NCI.UNITS         NE '' THEN NCDF_ATTPUT, SD_ID, 'units',               NCI.UNITS,         /GLOBAL, /CHAR
  
      ; ===> Add the global TIME info
      NCDF_ATTPUT, SD_ID, 'time_coverage_start',    NCIS[0].TIME_START,  /GLOBAL, /CHAR
      NCDF_ATTPUT, SD_ID, 'time_coverage_end',      NCIS[-1].TIME_END,    /GLOBAL, /CHAR
      NCDF_ATTPUT, SD_ID, 'time_period',            NCI.PERIOD_NAME, /GLOBAL, /CHAR
      NCDF_ATTPUT, SD_ID, 'time_coverage_duration', NCI.DURATION,    /GLOBAL, /CHAR

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; Add the Scientific Data variabiles
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      ; ===> Create the TIME variable
      TID = NCDF_DIMDEF(SD_ID, 'time', N_ELEMENTS(TIMES))                                                 ; Create a Z (time) dimesion for the data files 
      TIMEID = NCDF_VARDEF(SD_ID, 'time', TID, /FLOAT, GZIP=9)                                           ; Add the TIME varialbe to the file

      ; ===> Add the TIME dataset attributes  
      NCDF_ATTPUT, SD_ID, TIMEID, '_CoordinateAxisType','Time', /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'axis','T', /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'long_name', 'reference time of the data field', /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'standard_name','time', /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'ioos_category', 'Time',/CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'coverage_content_type', 'coordinate', /CHAR
      IF NCIS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
        stop ; Need to figure out how to record the climatology "times"
        NCDF_ATTPUT, SD_ID, TIMEID, 'climatology', 'climatology bounds', /CHAR
        NCDF_ATTPUT, SD_ID, TIMEID, 'climatology period', NCI.CLIM_BOUNDS, /CHAR
        NCDF_ATTPUT, SD_ID, TIMEID, 'method', NCI.CLIM_METHOD, /CHAR
      ENDIF
      NCDF_ATTPUT, SD_ID, TIMEID, 'comment', 'nominal time from the start of the time period', /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'time_origin', NCI.TIME_ORIGIN, /CHAR
      NCDF_ATTPUT, SD_ID, TIMEID, 'units', NCI.TIME_UNITS, /CHAR
      NCDF_CONTROL, SD_ID, /ENDEF                                                                         ; Leave define mode and enter data mode.
      NCDF_VARPUT,  SD_ID, TIMEID, TIMES                                                                 ; Add the TIME information to the file
      
      IF NCIS[0].PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
      
       stop ; Need to figure out how to record the climatology "times"
        
        NCDF_CONTROL, SD_ID, /REDEF                                                                       ; Put the open netcdf file into define mode
        CLI_ID = NCDF_VARDEF(SD_ID, 'climatology_bounds', TID, /FLOAT)                                    ; Add the TIME varialbe to the file
        NCDF_ATTPUT, SD_ID, CLI_ID, 'climatology', 'climatology bounds', /CHAR
        NCDF_ATTPUT, SD_ID, CLI_ID, 'long_name', 'Climate Time Boundaries
        NCDF_ATTPUT, SD_ID, CLI_ID, 'ioos_category', 'Time',/CHAR
        NCDF_ATTPUT, SD_ID, CLI_ID, 'coverage_content_type', 'coordinate', /CHAR
        NCDF_ATTPUT, SD_ID, CLI_ID, 'climatology period', NCI.CLIM_BOUNDS, /CHAR
        NCDF_ATTPUT, SD_ID, CLI_ID, 'method', NCI.CLIM_METHOD, /CHAR
        NCDF_ATTPUT, SD_ID, CLI_ID, 'units', 'seconds since 1970-01-01T00:00:00Z', /CHAR
        NCDF_CONTROL, SD_ID, /ENDEF                                                                       ; Leave define mode and enter data mode.
        NCDF_VARPUT,  SD_ID, CLI_ID, NCI.TIME                                                             ; Add the TIME information to the file
      ENDIF


      ; ===> Create the LON and LAT variables 
      NCDF_CONTROL, SD_ID, /REDEF                                                                         ; Put the open netcdf file into define mode
      LONID = NCDF_DIMDEF(SD_ID, 'longitude', PXLON)                                                      ; Create the X dimensions for the gridded data
      LATID = NCDF_DIMDEF(SD_ID, 'latitude', PYLAT)                                                       ; Create the Y dimensions for the gridded data
      IF KEY(LONLAT_1D) THEN BEGIN
        LON_ID = NCDF_VARDEF(SD_ID, 'longitude', LONID, /FLOAT, GZIP=9)                                   ; Add the 1D longitude variable to the file
        LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', LATID, /FLOAT, GZIP=9)                                    ; Add the 1D latitude varialbe to the file
      ENDIF ELSE BEGIN
        LON_ID = NCDF_VARDEF(SD_ID, 'longitude', [LONID,LATID],/FLOAT, GZIP=9)                            ; Add the 2D longitude variable to the file
        LAT_ID = NCDF_VARDEF(SD_ID, 'latitude', [LONID,LATID],/FLOAT, GZIP=9)                             ; Add the 2D latitude variable to the file
      ENDELSE

      ; ===> Add the LON/LAT dataset attributes
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
      NCDF_CONTROL, SD_ID, /ENDEF                                                                         ; Leave define mode and enter data mode.
      NCDF_VARPUT,  SD_ID, LON_ID, LONS                                                                   ; Add the longitude values
    
      NCDF_CONTROL, SD_ID, /REDEF                                                                         ; Put the open netcdf file into define mode
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
      NCDF_CONTROL, SD_ID, /ENDEF                                                                         ; Leave define mode and enter data mode.
      NCDF_VARPUT,  SD_ID, LAT_ID, LATS                                                                   ; Add the latitude values

      
      ; ===> Add the scientific data products   
      FPX = PXLON & FPY = PYLON & FPZ = N_ELEMENTS(SUBS)
      NCDF_CONTROL, SD_ID, /REDEF                                                                         ; Put the open netcdf file into define mode                                                    ; Create the Z dimensions for the gridded data
      SNAMES = []                                                                                         ; Blank array to hold the product names and look for duplicates
  
      ; ===> Loop through PRODKEYS
      FOR K=0,N_ELEMENTS(PRODKEYS)-1L DO BEGIN
        PKEY = PRODKEYS[K]
        STATTYPE = REPLACE(PKEY,DATAPROD+'_','')
        IF STATTYPE EQ PKEY THEN PROD = PKEY ELSE PROD = REPLACE(PKEY,'_'+STATTYPE,'')
        IF PROD EQ 'MASK' THEN CONTINUE
;        IF WHERE_MATCH(STAT_NAMES,PROD) NE [] THEN BEGIN
;          IF N_ELEMENTS(DATAPROD) GT 1 THEN MESSAGE, 'ERROR: Need to update code to work with more than one data product for stat files'
;          PRS = PRODS_READ(DATAPROD)
;          ANAME = PROD
;        ENDIF ELSE BEGIN
        PRS = PRODS_READ(PROD)
        ANAME = STRLOWCASE(PRS.NC_PROD) & IF ANAME EQ '' THEN ANAME = STRLOWCASE(PRS.PROD)
        IF STATTYPE NE PKEY THEN ANAME = PKEY ; Use the PKEY as the name in the netcdf file 
; TODO: Make the ANAME netcdf compliant
;         
;        DATAPROD = PROD
;        ENDELSE
        
        ; ===> Check for duplicate names
        OK = WHERE(SNAMES EQ STRLOWCASE(ANAME),COUNT)
        IF COUNT GT 0 THEN BEGIN
          SNAME = STRLOWCASE(SD_TAGS[NTH])
          OK = WHERE(SNAMES EQ SNAME,COUNT)
          IF COUNT GT 0 THEN MESSAGE, 'ERROR: Duplicate product names can not be written into the netcdf file.'
        ENDIF ELSE SNAME = STRLOWCASE(ANAME)
        SNAMES = [SNAMES,SNAME]

        ; ===> Extract the data from the D3HASH
        D3ARR = STRUCT_GET(D3,PKEY)                                                                                  ; Extract the data from the D3 HASH
        NDIMS = SIZE(D3ARR,/N_DIMENSIONS)                                                                 ; Determine the number of dimensions
        
        ; ===> Create the data array, fill value and PROD_ID based on the data type
        CASE IDLTYPE(D3ARR) OF
          'FLOAT' : BEGIN & FULLARR = FLTARR(FPX,FPY,FPZ) & FILL = -99999.0    & PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [LONID,LATID,TIMEID], /FLOAT,  GZIP=9) & END
          'LONG'  : BEGIN & FULLARR = LONARR(FPX,FPY,FPZ) & FILL = -99999L     & PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [LONID,LATID,TIMEID], /LONG,   GZIP=9) & END
          'INT'   : BEGIN & FULLARR = INTARR(FPX,FPY,FPZ) & FILL = FIX(-32767) & PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [LONID,LATID,TIMEID], /SHORT,  GZIP=9) & END
          'DOUBLE': BEGIN & FULLARR = DBLARR(FPX,FPY,FPZ) & FILL = -99999.0D   & PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [LONID,LATID,TIMEID], /DOUBLE, GZIP=9) & END
          'STRING': BEGIN & FULLARR = STRARR(FPX,FPY,FPZ) & FILL = 'NA'        & PROD_ID = NCDF_VARDEF(SD_ID, ANAME[0], [LONID,LATID,TIMEID], /STRING, GZIP=9) & END
          ELSE: MESSAGE, 'ERROR: Must add the array for the data type ' + IDLTYPE(RDATA)
        ENDCASE
        FULLARR[*] = MISSINGS(FULLARR)
        IF PROD_ID EQ -1 THEN MESSAGE, 'ERROR: Check PROD_ID'
        
        ; ===> Loop through the subscripts and add the data to the full array
        FOR F=0, N_ELEMENTS(SUBS)-1 DO BEGIN
          CASE NDIMS OF
            2: ARR = D3ARR[*,SUBS[F]]                                                                     ; Extract the data from the D3 array
            3: ARR = D3ARR[*,*,SUBS[F]]                                                                   ; Extract the data from the D3 array
          ENDCASE
          IF MP NE MAPP THEN ARR = MAPS_REMAP(ARR, MAP_IN=MAPP, MAP_OUT=MP, BINS=BINS)                    ; Remap the data array
          FULLARR[*,*,F] = ARR                                                                            ; Add the data array to the full array
        ENDFOR ; SUBS
      
        ; ===> Find any MISSING data and replace with the FILL value
        OK = WHERE(FULLARR EQ MISSINGS(FULLARR),COUNT)
        IF COUNT GT 0 THEN FULLARR[OK] = FILL
                            
        ; ===> Define attribute information for the product 
        ANCILLARY_VARIABLES = []
        SCOMMENT = []
        IOOS = []
        CCTYPE = 'physicalMeasurement'
        METHOD = []
        SMIN = []
        SMAX = []
        SUNIT = PRS.UNITS 
        STANDARD_NAME = PRS.CF_STANDARD_NAME
        LONG_NAME = PRS.CF_LONG_NAME
       
; TODO: Fix the valid min and valid max of stats (e.g. NUM, STD)        
        CR = VALIDS('PROD_CRITERIA',PROD) 
        IF CR EQ '-Inf_Inf' THEN MESSAGE, 'ERROR: Must add PROD_CRITERIA information to PRODS_MAIN for ' + ANAME
        IF N_ELEMENTS(CR) EQ 1 AND CR[0] EQ '' THEN CR = ['',''] ELSE CR = STRSPLIT(CR,'_',/EXTRACT)
        IF CR EQ [] THEN SMIN = '' ELSE SMIN = FLOAT(CR[0])
        IF CR EQ [] THEN SMAX = '' ELSE SMAX = FLOAT(CR[1])

; TODO: Update the attributes for stat and anomaly data  
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
        
        NCDF_CONTROL, SD_ID, /ENDEF                                                                         ; Leave define mode and enter data mode. 
        NCDF_VARPUT,  SD_ID, PROD_ID, FULLARR                                                               ; Write the image data to the file
      ENDFOR ; Product loop  
      
      ; ===> Add MASK information (if provided)
      IF HAS(PRODKEYS,'MASK') THEN BEGIN   
        MASKSTRUCT = INFO.MASK
        D3ARR = D3['MASK']                                                                                  ; Extract the data from the D3 HASH
        NDIMS = SIZE(D3ARR,/N_DIMENSIONS)                                                                   ; Determine the number of dimensions
        LM = READ_LANDMASK(MP,/STRUCT)

        CASE IDLTYPE(D3ARR) OF ; Define the variables to be used in the file based on the data type
          'BYTE':   BEGIN & FULLARR = BYTARR(FPX,FPY,FPZ) & FILL = 0         & PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /BYTE,   GZIP=9) & END
          'FLOAT':  BEGIN & FULLARR = FLTARR(FPX,FPY,FPZ) & FILL = -99999.0  & PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /FLOAT,  GZIP=9) & END
          'INT':    BEGIN & FULLARR = INTARR(FPX,FPY,FPZ) & FILL = -32767    & PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /SHORT,  GZIP=9) & END
          'LONG':   BEGIN & FULLARR = LONARR(FPX,FPY,FPZ) & FILL = -99999L   & PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /LONG,   GZIP=9) & END
          'DOUBLE': BEGIN & FULLARR = DBLARR(FPX,FPY,FPZ) & FILL = -99999.0D & PROD_ID = NCDF_VARDEF(SD_ID, 'mask', [XID,YID,ZID], /DOUBLE, GZIP=9) & END
        ENDCASE
        IF PROD_ID EQ -1 THEN MESSAGE, 'ERROR: Unable to create the PROD_ID'

        ; ===> Loop through the subscripts and add the data to the full array
        FOR F=0, N_ELEMENTS(SUBS)-1 DO BEGIN
          CASE NDIMS OF
            2: ARR = D3ARR[*,SUBS[F]]                                                                     ; Extract the data from the D3 array
            3: ARR = D3ARR[*,*,SUBS[F]]                                                                   ; Extract the data from the D3 array
          ENDCASE
          IF MP NE MAPP THEN ARR = MAPS_REMAP(ARR, MAP_IN=MAPP, MAP_OUT=MP, BINS=BINS)                    ; Remap the data array
          LAND = WHERE(STRUPCASE(MASKSTRUCT.MASK_NAMES) EQ 'LAND',COUNT_LAND)
          IF COUNT_LAND EQ 1 THEN ARR[LM.LAND] = MASKSTRUCT.MASK_CODES[LAND]
          COAST = WHERE(STRUPCASE(MASKSTRUCT.MASK_NAMES) EQ 'COAST',COUNT_COAST)
          IF COUNT_COAST EQ 1 THEN ARR[LM.COAST] = MASKSTRUCT.MASK_CODES[COAST]
          FULLARR[*,*,F] = ARR                                                                            ; Add the data array to the full array
        ENDFOR ; SUBS

        NCDF_ATTPUT,  SD_ID, PROD_ID, 'long_name',     'data mask', /CHAR
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'standard_name', 'mask', /CHAR
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'units',         'na', /CHAR
        NCDF_ATTPUT,  SD_ID, PROD_ID, '_fillvalue',    0
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'mask_codes',    STRJOIN(STRTRIM(MASKSTRUCT.MASK_CODES,2),';'),/CHAR
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'mask_names',    STRJOIN(MASKSTRUCT.MASK_NAMES,';'),/CHAR
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_min',     MIN(MASKSTRUCT.MASK_CODES)
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'valid_max',     MAX(MASKSTRUCT.MASK_CODES)
        NCDF_ATTPUT,  SD_ID, PROD_ID, 'comment',       MASKSTRUCT.MASK_NOTES, /CHAR

        NCDF_CONTROL, SD_ID, /ENDEF                                ; Leave define mode and enter data mode.
        NCDF_VARPUT,  SD_ID, PROD_ID, FULLARR                      ; Write the image data into the dataset
      ENDIF ; Add MASK
      
      ;===> Close the ncdf file
      NCDF_CLOSE,SD_ID
      CLOSE,/ALL,/FORCE
       
    IF KEY(VERBOSE) THEN PFILE, NCFILE
  ENDFOR ; FILES loop 
END ; End of STACKED_2NETCDF
