; $ID:	WRITE_NETCDF.PRO,	2023-09-21-13,	USER-KJWH	$
; #########################################################################; 
PRO WRITE_NETCDF, FILES, DIR_OUT=DIR_OUT, MAP_OUT=MAP_OUT, SAV_PRODS=SAV_PRODS, NC_PRODS=NC_PRODS, NC_SUITE=NC_SUITE, TAGS_STAT=TAGS_STAT, $
                  LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX, SUBSET_MAP=SUBSET_MAP, $
                  OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, REVERSE_FILES=REVERSE_FILES, OUTFILES=OUTFILES, BADFILES=BADFILES
;+
; NAME:
;   WRITE_NETCDF
; 
; PURPOSE:  
;   This program writes a netcdf4 from a .SAV file
;
; CATEGORY: 
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   WRITE_NETCDF, FILES
;
; REQUIRED INPUTS: 
;   FILES......... Input .SAV files
;
; OPTIONAL_INPUTS
;   DIR_OUT....... Directory for writing output nc file
;   MAP_OUT....... Name of the map for the output structure 
;   SAV_PRODS..... Name(s) of the output products from the .SAV files
;   NC_PRODS...... Names(s) of the output products from the .NC files
;   NC_SUITE...... Name of the SUITE directory sent to NETCDF_INFO
;   TAGS_STAT..... The stat[s]to select from the struct for writing : DEFAULT = ['MEAN','NUM']
;   LONMIN........ The minimum longitude if subsetting a L3B file
;   LONMAX........ The maximum longitude if subsetting a L3B file
;   LATMIN........ The minimum latitude if subsetting a L3B file
;   LATMAX........ The maximum latitude if subsetting a L3B file
;   SUBSET_MAP.... A map name to subset a L3B file
; 
; KEYWORDS 
;   OVERWRITE..... Overwrite output nc file
;   VERBOSE....... Print program progress
;   REVERSE_FILES. Reverse the order to the files
;       
; OUTPUTS: 
;   A netcdf file written to the specified DIR_OUT directory
;
; OPTIONAL OUTPUTS
;   OUTFILES...... The name[s] of the output nc_file[s]
;   BADFILES...... The name[s] of any "bad" input file[s]
;
; COMMON BLOCKS:
;   _WRITE_NETCDF. Structure to save the information from the NETCDF_MASTER
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
;   See WRITE_NC_DEMO   
;      
; RESTRICTIONS:
;   Works with a NEFSC created .SAV files and other netcdf files, although it has not been fully tested with all types of netcdf files in the DATASETS directory
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
;   This program was written March 04, 2019 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   Mar 04, 2019 - KJWH: Wrote initial code - adapted from WRITE_NC.pro
;   Mar 25, 2019 - KJWH: Removed LICENSE (now in the GLOBAL master)
;                        Added COMMON block to hold the GLOBAL master structure  
;                        Updated documentation
;   Apr 03, 2019 - KJWH: Added /CHAR to any NCDF_ATTPUT call with a STRING type attribute   
;   May 17, 2019 - KJWH: Added NC_SUITE as the name of the SUITE directory sent to NETCDF_INFO.  
;                        Needed when the input files are not in the default !S.(SUITE) directories (e.g. files from !S.PROJECTS)      
;   Nov 07, 2019 - KJWH: Updated the STAT TAG information to include separate tags for both MEAN and GMEAN as well as NUM and LNUM if provided                                   
;   Jul 08, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed any subscripts from () to []
;                        Updated documentation
;                        Added the optional input SAV_PRODS to indicate which products in the SAV file to use
;                        Added the ability to work with multiple products in a SAV file
;   Aug 12, 2020 - KJWH: Updated documentation
;                        Moved from PROGRAMS to IDL_FUNCTIONS/FILE_FUNCTIONS
;   Aug 18, 2020 - KJWH: Fixed a bug with determining the valid range of the data     
;   Sep 22, 2020 - KJWH: Added BADFILES keyword to hold a list of "bad" input files (i.e. files that were converted to netcdf)
;                          If a file could not be read, and ERROR message is printed and the file is skipped  
;                          If any BADFILES exist, then they will be printed after the processing has completed.            
;   Oct 13, 2021 - KJWH: Changed _fillvalue to _FillValue to meet netcdf standards.     
;-
; ##################################################################################################################

  ROUTINE = 'WRITE_NETCDF'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  CLOSE,/ALL,/FORCE
  
  COMMON _WRITE_NETCDF, GLOBAL_STR, MTIME
  MASTER = !S.MAINFILES + 'NETCDF_MAIN.csv'
  IF ~N_ELEMENTS(MTIME) THEN MTIME = GET_MTIME(MASTER)
  IF GET_MTIME(MASTER) GT MTIME THEN INIT = 1 ELSE INIT = 0
  IF ~N_ELEMENTS(GLOBAL_STR) OR KEYWORD_SET(INIT) THEN BEGIN & GLOBAL_STR = CSV_READ(MASTER) & TIME = GET_MTIME(MASTER) & ENDIF 
  
  IF ~N_ELEMENTS(FILES) THEN FILES = DIALOG_PICKFILE(FILTER='*.SAV')
  
  IF ~N_ELEMENTS(TAGS_STAT) THEN TAGS_STAT = ['MEAN','NUM','GMEAN','LNUM','MED'] ELSE TAGS_STAT = STRUPCASE(TAGS_STAT) ; Tags to extract from the STAT files
  SD_TAGS =  [TAGS_STAT]
  IF N_ELEMENTS(PRODS) GE 1 THEN SD_TAGS =  [SD_TAGS,PRODS]

  IF (N_ELEMENTS(LONMIN) AND N_ELEMENTS(LONMAX) AND N_ELEMENTS(LATMIN) AND N_ELEMENTS(LATMAX)) OR N_ELEMENTS(SUBSET_MAP) THEN SUBSET = 1 ELSE SUBSET = 0

; ===> Loop through files
  IF KEYWORD_SET(REVERSE_FILES) THEN FILES = REVERSE(FILES)
  BADFILES = [] ; Set up a variable to contain any "bad" input files that are not able to be read
  
  FOR F=0,N_ELEMENTS(FILES)-1L DO BEGIN
    AFILE=FILES[F]
    FN=PARSE_IT(AFILE,/ALL)  ; Parse the file name
    IF STRUPCASE(FN.EXT) EQ 'NC' THEN SI = SENSOR_INFO(AFILE) ELSE SI = FN
    IF NONE(MAP_OUT) THEN MP = SI.MAP ELSE MP = MAP_OUT
 ;   IF IS_L3B(MP) THEN MESSAGE, 'ERROR: WRITE_NETCDF not equipped to work with L3B files'
    IF NONE(DIR_OUT) THEN DIR = REPLACE(SI.DIR,[SI.MAP,SI.L2SUB],[MP,'NETCDF']) ELSE DIR = DIR_OUT & DIR_TEST, DIR
      
    NCI = NETCDF_INFO(AFILE);, DIR_SUITE=NC_SUITE)
    NC_FILE = DIR + FN.PERIOD +'-' + FILE_LABEL_MAKE(AFILE, LST=['SENSOR','SATELLITE','SUITE']) + '-' + MP + '-' + NCI.PROD + '-' + NCI.ALG + '.nc'
    NC_FILE = REPLACE(NC_FILE,[';','-.','/-'],['','.','/'])
    IF N_ELEMENTS(NC_FILE) GT 1 THEN MESSAGE, 'ERROR: Check NC_FILE name.'

    IF FILE_MAKE(AFILE,NC_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    IF FILE_TEST(NC_FILE) THEN FILE_DELETE, NC_FILE, /VERBOSE ; Removed the old file
    IF NONE(OUTFILES) THEN OUTFILES = NC_FILE ELSE OUTFILES = [OUTFILES,NC_FILE]
    POF, F, FILES, OUTTXT=OUTTXT, /NOPRO, /QUIET
    
    TAGS = TAG_NAMES(NCI)
    CONTRIB = STRUCT_COPY(NCI,WHERE_STRING(TAGS,'CONTRIBUTOR')) & CTAGS = TAG_NAMES(CONTRIB)
    SOURCE  = STRUCT_COPY(NCI,WHERE_STRING(TAGS,'SOURCE_DATA')) & STAGS = TAG_NAMES(SOURCE)

     
; ===> Read the input file and get the PROD info
    IF STRUPCASE(FN.EXT EQ 'SAV') THEN BEGIN
      S = STRUCT_READ(AFILE,STRUCT=STRUCT,MAP_OUT=MP, BINS=DBINS)
      IF IDLTYPE(STRUCT) EQ 'STRING' THEN BEGIN
        BADFILES = [BADFILES,AFILE]
        PRINT, 'ERROR: Unable to read ' + AFILE
        CONTINUE
      ENDIF         
      IF NONE(SAV_PRODS) THEN APROD = VALIDS('PRODS',STRUCT.PROD) ELSE APROD = SAV_PRODS
      PRS = PRODS_READ(APROD)
      IF STRUCT.STATS EQ '' THEN BEGIN
        IF HAS(STRUCT,'DATA') THEN SD_TAGS = 'DATA' $
        ELSE BEGIN
         STRUCT_TAGS = TAG_NAMES(STRUCT)
         OK = WHERE_MATCH(STRUCT_TAGS,APROD,COUNT) 
         IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Data not found in structure'
         SD_TAGS = STRUCT_TAGS[OK]
         ENDELSE
      ENDIF
    ENDIF ELSE BEGIN
      IF ~H5F_IS_HDF5(AFILE) AND ~NCDF_IS_NCDF(AFILE) THEN BEGIN
        BADFILES = [BADFILES,AFILE]
        PRINT,'ERROR: ' + AFILE + ' is an unrecognized file type.'
        CONTINUE
      ENDIF    
      IF NONE(NC_PRODS) THEN NC_PRODS = STR_BREAK(SI.NC_PROD,';')
      NPRODS = STR_BREAK(SI.NC_PROD,';')
      D = READ_NC(AFILE,PROD=NC_PRODS,BINS=DBINS, GLOBAL=STRUCT) 
      IF IDLTYPE(D) EQ 'STRING' THEN BEGIN
        BADFILES = [BADFILES,AFILE]
        PRINT, 'ERROR: ' + D
        CONTINUE
      ENDIF
      IF HAS(D,'SD') THEN D = D.SD
      TAGS = STRUPCASE(TAG_NAMES(D))
      OK = WHERE_MATCH(STRUPCASE(STR_BREAK(SI.NC_PROD,';')), TAGS, COUNT, NINVALID=NINVALID) & IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + NC_PRODS + ' is not a recognized prod in ' + AFILE
      IF NINVALID GT 0 THEN MESSAGE, 'ERROR: Double check NC_PRODS and SI.PRODS'
      NPRODS = NPRODS[OK]
      
      SKIP_TAGS = ['LATITUDE','LONGITUDE']                                         ; Tags to ignore in the LOOP
      FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                         ; Loop through the STAT tags
        OKT = WHERE_MATCH(TAGS(T),SKIP_TAGS,COUNT_TAGS)                            ; Look for the tags to ignore
        IF COUNT_TAGS GT 0 THEN CONTINUE
        SUBIMG = []
        MAP_BINS = MAPS_L3B_BINS(FN.MAP)
        IF HAS(D.(T),'DATA') THEN SUBIMG = D.(T).DATA                              ; Get the data from the structure
        IF HAS(D.(T),'IMAGE') THEN SUBIMG = D.(T).IMAGE                            ; Or get the data from the IMAGE tag
        IF HAS(D.(T),'DATA') AND HAS(D.(T),'IMAGE') THEN MESSAGE, 'ERROR: Unable to determine which data tag to use'
        IF SUBIMG EQ [] THEN MESSAGE, 'ERROR: Unable to find data to remap'
        IF ~HAS(D,'BINS') THEN BINS = MAP_BINS ELSE IF ~N_ELEMENTS(DBINS) THEN BINS = D.(T).BINS ELSE BINS = DBINS       ; Get the BINS from the structure 
        IF N_ELEMENTS(BINS) NE N_ELEMENTS(SUBIMG) THEN MESSAGE,'ERROR: Number of BINS and DATA points must be the same'
        IF ~IS_L3B(MP) THEN SUBIMG = MAPS_REMAP(SUBIMG, MAP_IN=FN.MAP, MAP_OUT=MP, BINS=BINS)     ; Subset the data to be only those pixels where NUM great than 0 (and not MISSINGS)
        IF IDLTYPE(SUBIMG) EQ 'STRING' THEN MESSAGE, SUBIMG
        
        IF KEYWORD_SET(SUBSET) THEN BEGIN
          IF ~IS_L3B(FN.MAP) AND ~IS_GSMAP(FN.MAP) THEN MESSAGE, 'ERROR: The input data must be L3B or GS'
          SUBMAP = MAPS_L3B_SUBSET(SUBIMG, INPUT_MAP=FN.MAP, SUBSET_MAP=SUBSET_MAP, LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX, SUBSET_BINS=BINS)
          IF IS_L3B(FN.MAP) THEN SUBIMG = MAPS_L3BGS_SWAP(SUBMAP, L3BGS_MAP=FN.MAP)
          
       STOP ; nEED TO COMPLETE THE L3B SUBSET INFO   
          
        ENDIF
        
        STRUCT = CREATE_STRUCT(STRUCT,REPLACE(NPRODS(T),'-','_'),SUBIMG)           ; Add subset to the new stat structure
        PRS = PRODS_READ(VALIDS('PRODS',NPRODS))
      ENDFOR
      SD_TAGS = REPLACE(NPRODS,'-','_')
    ENDELSE 
    
    IF IDLTYPE(S) EQ 'STRING' THEN MESSAGE, S
    STRUCT = CREATE_STRUCT(STRUCT,'INPUT_FILE',SI.NAME) ; Add the input file to the structure
    IF HAS(STRUCT,'INFILES') THEN INFILES = STRJOIN((FILE_PARSE(STRUCT.INFILES)).NAME_EXT,'; ') ELSE INFILES = AFILE
    
    ; ===> Get the MAP info
    IF IS_L3B(MP) THEN MI = MAPS_INFO(MAPS_L3B_GET_GS(MP)) ELSE MI = MAPS_INFO(MP)
    MR = MAPS_READ(MP)
    LL = MAPS_2LONLAT(MP,LONS=LONS,LATS=LATS)
    SZLAT = SIZEXYZ(LATS,PX=PXLAT,PY=PYLAT)
    SZLON = SIZEXYZ(LONS,PX=PXLON,PY=PYLON)
    IF SAME(LATS[*,0]) AND SAME(LATS[*,-1]) AND SAME(LONS[0,*]) AND SAME(LONS[-1,*]) THEN BEGIN
      LATS = REFORM(LATS[0,*])
      LONS = REFORM(LONS[*,0])
      LONLAT_1D=1
    ENDIF ELSE LONLAT_1D=0
    IF KEY(LONLAT_1D) AND (N_ELEMENTS(LATS) NE PYLAT OR N_ELEMENTS(LONS) NE PXLON) THEN MESSAGE, 'ERROR: Check the lon/lat dimensions.'
    LONRES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT])/111.0,3)
    LATRES = ROUNDS(MEAN([MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3)
    SPARES = ROUNDS(MEAN([MI.V_SCALE_LEFT,MI.V_SCALE_MID,MI.V_SCALE_RIGHT,MI.H_SCALE_LOWER,MI.H_SCALE_MID,MI.H_SCALE_UPPER])/111.0,3)  
    
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||     
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||     
; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||   

    ; ===> Start the NCDF interface
    PFILE, NC_FILE[0], /M, _POFTXT=OUTTXT
    SD_ID = NCDF_CREATE(NC_FILE[0],/CLOBBER,/NETCDF4_FORMAT)
    IF SD_ID EQ -1 THEN MESSAGE, 'NCDF_CREATE FAILED'

    ; ===> Write the global attributes     
    NCDF_ATTPUT, SD_ID, 'title', NCI.TITLE, /GLOBAL, /CHAR

    FOR N=0, N_ELEMENTS(GLOBAL_STR)-1 DO IF GLOBAL_STR[N].VALUE NE MISSINGS(GLOBAL_STR[N].VALUE) THEN NCDF_ATTPUT, SD_ID, GLOBAL_STR[N].TAG, GLOBAL_STR[N].VALUE, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'date_netcdf_created', DATE_FORMAT(DATE_NOW(),/DAY), /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'date_input_file_created', DATE_FORMAT(GET_MTIME(AFILE,/DATE)), /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'original_file_name', FN.NAME_EXT, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'input_filenames', INFILES, /GLOBAL, /CHAR

    ; ===> Add the CONTRIBUTOR and SOURCE info
    FOR N=0, N_ELEMENTS(CTAGS)-1 DO IF CONTRIB.(N) NE '' THEN NCDF_ATTPUT, SD_ID, STRLOWCASE(CTAGS[N]), CONTRIB.(N), /GLOBAL, /CHAR
    FOR N=0, N_ELEMENTS(STAGS)-1 DO IF SOURCE.(N)  NE '' THEN NCDF_ATTPUT, SD_ID, STRLOWCASE(STAGS[N]), SOURCE.(N),  /GLOBAL, /CHAR

    ; ===> Add the SENSOR info
    NCDF_ATTPUT, SD_ID, 'platform', NCI.PLATFORM, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'sensor',   NCI.SHORT_NAME, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'source_data_version',   NCI.SOURCE_DATA_VERSION, /GLOBAL, /CHAR

    ; ===> Add the MAP info
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
    IF IS_L3B(SI.MAP) AND ~IS_L3B(MP) THEN NCDF_ATTPUT, SD_ID, 'map_notes', 'Level-3 binned data remapped using IDL', /GLOBAL, /CHAR
    
;   ===> Add the PRODUCT info
    IF NCI.LEVEL         NE '' THEN NCDF_ATTPUT, SD_ID, 'processing_level',    NCI.LEVEL,         /GLOBAL, /CHAR
    IF NCI.PROD          NE '' THEN NCDF_ATTPUT, SD_ID, 'product_name',        NCI.PROD,          /GLOBAL, /CHAR
    IF NCI.ALG_NAME      NE '' THEN NCDF_ATTPUT, SD_ID, 'product_algorithm',   NCI.ALG_NAME,      /GLOBAL, /CHAR
    IF NCI.ALG           NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_name',      NCI.ALG,           /GLOBAL, /CHAR
    IF NCI.ALG_REFERENCE NE '' THEN NCDF_ATTPUT, SD_ID, 'algorithm_reference', NCI.ALG_REFERENCE, /GLOBAL, /CHAR
    IF NCI.UNITS         NE '' THEN NCDF_ATTPUT, SD_ID, 'units',               NCI.UNITS,         /GLOBAL, /CHAR
    
;   ===> Add the TIME info
    NCDF_ATTPUT, SD_ID, 'time_coverage_start',    NCI.TIME_START,  /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'time_coverage_end',      NCI.TIME_END,    /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'time_period',            NCI.PERIOD_NAME, /GLOBAL, /CHAR
    NCDF_ATTPUT, SD_ID, 'time_coverage_duration', NCI.DURATION,    /GLOBAL, /CHAR
 
    
;   **********************************
;   *** CREATE A TIME VARIABLE ***
;   **********************************
    TID = NCDF_DIMDEF(SD_ID, 'time', /UNLIMITED) ; Create an "unlimited" variable for non-gridded variable information (e.g. time, crs)  
    TIME_ID = NCDF_VARDEF(SD_ID, 'time', TID, /FLOAT) ; Add the TIME varialbe to the file
    NCDF_ATTPUT, SD_ID, TIME_ID, '_CoordinateAxisType','Time', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'axis','T', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'long_name', 'reference time of the data field', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'standard_name','time', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'ioos_category', 'Time',/CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'coverage_content_type', 'coordinate', /CHAR 
    IF NCI.PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
      NCDF_ATTPUT, SD_ID, TIME_ID, 'climatology', 'climatology bounds', /CHAR
      NCDF_ATTPUT, SD_ID, TIME_ID, 'climatology period', NCI.CLIM_BOUNDS, /CHAR
      NCDF_ATTPUT, SD_ID, TIME_ID, 'method', NCI.CLIM_METHOD, /CHAR
    ENDIF 
    NCDF_ATTPUT, SD_ID, TIME_ID, 'comment', 'nominal time from the start of the time period', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'time_origin', '1970-01-01T00:00:00Z', /CHAR
    NCDF_ATTPUT, SD_ID, TIME_ID, 'units', 'seconds since 1970-01-01T00:00:00Z', /CHAR     
    NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
    NCDF_VARPUT,  SD_ID, TIME_ID, NCI.TIME ; Add the TIME information to the file
    
    IF NCI.PERIOD_CODE EQ 'CLIMATOLOGY' THEN BEGIN
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


;   **********************************
;   *** CREATE A LON/LAT VARIABLES ***
;   **********************************    
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

    ;   ===> ADD DATASET ATTRIBUTES
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


;   ****************************************************************
;   *** CREATE A CSR VARIABLE FOR THE MAP PROJECTION INFORMATION ***
;   ****************************************************************
;    IF ~IS_L3B(MAP_OUT) AND VALIDS('MAPS',MAP_OUT) NE '' THEN BEGIN
;      NCDF_CONTROL, SD_ID, /REDEF ; Put the open netcdf file into define mode
;      CRS_ID = NCDF_VARDEF(SD_ID, 'crs', TID, /STRING) ; Create the ID for the CRS variable
;      IF MR.CRS_GRID_MAPPING NE '' THEN NCDF_ATTPUT, SD_ID, CRS_ID, 'grid_mapping_name', MR.CRS_GRID_MAPPING, /CHAR
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'comment','This is a container variable describing the grid mapping used by the data file.  This varialbe does not contain any data; only information about the geographic coordinate system.', /CHAR
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'long_name','coordinate reference system', /CHAR
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'projected_crs_name', MR.PROJ4_CRS, /CHAR
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'epsg_code', MR.ELLPS_CRS, /CHAR
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'lat_0', MI.P0LAT
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'lon_0', MI.P0LON
;      NCDF_ATTPUT, SD_ID, CRS_ID, 'units', 'degrees', /CHAR
;      NCDF_CONTROL, SD_ID, /ENDEF ; Leave define mode and enter data mode.
;      NCDF_VARPUT,  SD_ID, CRS_ID, CRS; Add the CRS string
;    ENDIF  

 


;   **********************************
;   *** PROCESS ALL THE SD_TAGS ******
;   **********************************
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    
   ; XID = NCDF_DIMDEF(SD_ID, 'x', PXLON) ; Create the X dimensions for the gridded data
   ; YID = NCDF_DIMDEF(SD_ID, 'y', PYLAT) ; Create the Y dimensions for the gridded data
    
    SNAMES = [] ; Create a list of product names and look for duplicates
    FOR NTH=0, N_ELEMENTS(SD_TAGS)-1 DO BEGIN
      IF N_ELEMENTS(PRS) EQ 1 THEN PR = PRS ELSE PR = PRS[NTH]
      ATAG = SD_TAGS[NTH]
      ANAME = STRLOWCASE(PR.NC_PROD) & IF ANAME EQ '' THEN ANAME = STRLOWCASE(PR.PROD)
      RDATA = STRUCT_GET(STRUCT,ATAG)
      IF RDATA EQ [] THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      IF IDLTYPE(RDATA) EQ 'STRUCT' THEN BEGIN
        IF HAS(RDATA,'IMAGE') THEN RDATA = RDATA.IMAGE ELSE MESSAGE, 'ERROR: Unable to identify the image data'
      ENDIF
      IF IS_2D(RDATA) THEN SZ = SIZEXYZ(RDATA,PX=PX,PY=PY)
      
      FILL = []
      OK = WHERE(RDATA EQ MISSINGS(RDATA),COUNT)
      IF COUNT GT 0 THEN BEGIN
        CASE IDLTYPE(RDATA) OF
          'FLOAT' : FILL = -99999.0
          'LONG'  : FILL = -99999L
          'INT'   : FILL = -32767
          'DOUBLE': FILL = -99999.0D
          'STRING': FILL = 'NA'
          ELSE: MESSAGE, 'ERROR: Must add _FILLVALUE for the data type ' + IDLTYPE(RDATA)
        ENDCASE
        RDATA[OK] = FILL
      ENDIF
        
;        ;CCCCCCCCCCCCC
;      CASE (ATAG) OF
;        'GRAD_CHL':  ANAME = ATAG 
;        'GRAD_SST':  ANAME = ATAG 
;        'GRAD_X'  : BEGIN
;           IF STRUCT_HAS(STRUCT,'GRAD_CHL') THEN ANAME = 'GRAD_CHL_X'
;           IF STRUCT_HAS(STRUCT,'GRAD_SST') THEN ANAME = 'GRAD_SST_X'           
;         END;GRAD_X
;        'GRAD_Y'  : BEGIN
;           IF STRUCT_HAS(STRUCT,'GRAD_CHL') THEN ANAME = 'GRAD_CHL_Y'
;           IF STRUCT_HAS(STRUCT,'GRAD_SST') THEN ANAME = 'GRAD_SST_Y'
;         END;GRAD_Y
;        ELSE: BEGIN
;          IF STRUCT_HAS(STRUCT,'GRAD_CHL') EQ 0 AND STRUCT_HAS(STRUCT,'GRAD_SST') EQ 0 THEN ANAME = APROD+'_'+ATAG ELSE ANAME = ATAG
;        END;ELSE
;      ENDCASE
;            
      
;      IF IDLTYPE(GSTRUCT.UNITS) EQ 'STRING' THEN SUNIT = GSTRUCT.UNITS ELSE SUNIT = GSTRUCT.UNITS._DATA[0]
;      
;      ;===> DEFINE LONG_NAME,SHORT_NAME,UNITS,SMIN,SMAX FOR EACH STAT TYPE
      ANCILLARY_VARIABLES = []
      SCOMMENT = []
      IOOS = []
      CCTYPE = 'physicalMeasurement'
      METHOD = []
      SMIN = []
      SMAX = []
      SUNIT = PR.UNITS 
      STANDARD_NAME = PR.CF_STANDARD_NAME
      CR = VALIDS('PROD_CRITERIA',PR.PROD) 
      IF CR EQ '-Inf_Inf' THEN CR = [] ;MESSAGE, 'ERROR: Must add PROD_CRITERIA information to PRODS_MAIN for ' + ATAG
      IF CR EQ '' THEN CR = []
      IF N_ELEMENTS(CR) NE 1 THEN CR = [] ELSE CR = STRSPLIT(CR,'_',/EXTRACT)
      IF CR NE [] THEN SMIN = FLOAT(CR[0])
      IF CR NE [] THEN SMAX = FLOAT(CR[1])
      CASE (ATAG) OF
;        'ANOMALY': BEGIN
;          IF FN.MATH EQ 'RATIO' THEN BEGIN
;            LONG_NAME = 'ANOMALY RATIO' 
;            SHORT_NAME = 'RATIO'
;            SUNIT = STRUCT.DATA_UNITS
;            SMIN = 0.0
;            SMAX = 100.0
;          ENDIF ELSE BEGIN
;            LONG_NAME = 'ANOMALY DIFFERENCE'
;            SHORT_NAME = 'DIF'
;            SUNIT = STRUCT.DATA_UNITS
;            SMIN = -1*VMAX
;            SMAX = VMAX
;          ENDELSE
;        END  
        'NUM': BEGIN
          SNAME = ANAME + '_nobs'
          LONG_NAME = 'number of valid observations used to calculate the mean'
          STANDARD_NAME = 'number_of_observations'
          METHOD = 'time: number'
          SUNIT = ''
          ANCILLARY_VARIABLES = STRLOWCASE(APROD) 
          SMIN = 0L
          SMAX = N_ELEMENTS(STRUCT.INFILES)
          IOSS = 'Statistics'
          CCTYPE = 'qualityInformation'
       END;'NUM'
       
       'LNUM': BEGIN
         SNAME = ANAME + '_log_nobs'
         LONG_NAME = 'number of valid observations used to calculate the geometric mean'
         STANDARD_NAME = 'number_of_observations'
         METHOD = 'time: number'
         SUNIT = ''
         ANCILLARY_VARIABLES = STRLOWCASE(APROD)
         SMIN = 0L
         SMAX = N_ELEMENTS(STRUCT.INFILES)
         IOSS = 'Statistics'
         CCTYPE = 'qualityInformation'
       END;'NUM'
;        'MIN': BEGIN
;          LONG_NAME = 'MINIMUM'
;          SHORT_NAME = 'MIN'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = '' 
;        END;'MIN'
;        'MAX': BEGIN
;          LONG_NAME = 'MAXIMUM'
;          SHORT_NAME = 'MAX'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = '' 
;        END;'MAX'
;        'SPAN': BEGIN
;          LONG_NAME = 'SPAN'
;          SHORT_NAME = 'SPAN'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = ''
;        END;'SPAN'
;        'NEG': BEGIN
;          LONG_NAME = 'NEGATIVE'
;          SHORT_NAME = 'NEG'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = ''  
;        END;'NEG'
;        'WTS': BEGIN
;          LONG_NAME = 'WEIGHTS'
;          SHORT_NAME = 'WTS'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = ''
;        END;'WTS'
;        'SUM': BEGIN
;          LONG_NAME = 'SUM'
;          SHORT_NAME = 'SUM'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = ''
;        END;'SUM'
;        'SSQ': BEGIN
;          LONG_NAME = 'SUM OF SQUARES'
;          SHORT_NAME = 'SSQ'
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;          SUNIT = ''
;        END;'SSQ'
        'MEAN': BEGIN
          SNAME = ANAME + '_mean'
          LONG_NAME = PR.CF_LONG_NAME 
          METHOD = 'time: mean'
        END;'MEAN'
        
        'GMEAN': BEGIN
          SNAME = ANAME + '_geometric_mean'
          LONG_NAME = 'Geogmetric mean of ' + LONG_NAME
          SCOMMENT = 'The geometric mean was used to calculate the mean because of the log-normal distribution of the data.'
          METHOD = 'time: geometric mean'
        END;'GMEAN'
        
        'MED': BEGIN
          SNAME = ANAME + '_median'
          LONG_NAME = PR.CF_LONG_NAME
          METHOD = 'time: median'
        END;'MEAN'
        
        'STD': BEGIN
          SNAME = ANAME + '_std'
          LONG_NAME = PR.CF_LONG_NAME
          METHOD = 'time: standard_deviation'
        END;'STD'
;        'CV': BEGIN
;          LONG_NAME = 'COEFFICIENT OF VARIABILITY'
;          SHORT_NAME = 'CV'
;          SUNIT = ''
;          SMIN = MIN(RDATA,/NAN)
;          SMIN = MAX(RDATA,/NAN)
;        END;'CV'
        ELSE: BEGIN
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
        END
      ENDCASE
      
      NCDF_CONTROL, SD_ID, /REDEF;PUT THE OPEN NETCDF FILE INTO DEFINE MODE
      CASE IDLTYPE(RDATA) OF ; Define the variables to be used in the file based on the data type
        'FLOAT':  PROD_ID = NCDF_VARDEF(SD_ID, SNAME[0], [LONID,LATID], /FLOAT,  GZIP=9)
        'INT':    PROD_ID = NCDF_VARDEF(SD_ID, SNAME[0], [LONID,LATID], /LONG,   GZIP=9) 
        'LONG':   PROD_ID = NCDF_VARDEF(SD_ID, SNAME[0], [LONID,LATID], /FLOAT,  GZIP=9)
        'DOUBLE': PROD_ID = NCDF_VARDEF(SD_ID, SNAME[0], [LONID,LATID], /DOUBLE, GZIP=9)
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
      IF ANY(IOOS)                THEN IF IOOS                NE '' THEN NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', IOOS, /CHAR $
                                                                    ELSE NCDF_ATTPUT,  SD_ID, PROD_ID, 'ioos_category', NCI.IOOS_CATEGORY, /CHAR
      NCDF_ATTPUT, SD_ID, PROD_ID, 'coverage_content_type', CCTYPE, /CHAR 
      
      NCDF_CONTROL, SD_ID, /ENDEF;LEAVE DEFINE MODE AND ENTER DATA MODE. 
      NCDF_VARPUT,  SD_ID, PROD_ID, RDATA ; WRITE THE IMAGE DATA INTO THE DATASET
    
    ENDFOR;FOR NTH=0, N_ELEMENTS(SD_TAGS)-1 DO BEGIN
 
    
    ;===> CLOSE THE NCDF FILE
    NCDF_CLOSE,SD_ID
    CLOSE,/ALL,/FORCE
 
    GONE, XID
    GONE, YID
    GONE, SD_ID
   
    IF KEY(VERBOSE) THEN PFILE, NC_FILE
    
  ENDFOR;FOR _FILES=0,N_ELEMENTS(FILES)-1L DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  IF BADFILES NE [] THEN LI, [NUM2STR(N_ELEMENTS(BADFILES)) + ' files were not converted to netcdf.',BADFILES]

END; #####################  END OF ROUTINE ################################
