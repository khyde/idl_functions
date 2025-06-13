; $ID:	BATCH_FRONTS.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO BATCH_FRONTS, DATASETS, PRODS=PRODS, DATERANGE=DATERANGE, LOGFILE=LOGFILE, MAPIN=MAPIN, D3MAP=D3MAP, NCMAP=NCMAP, PLTMAP=PLTMAP, INDICATOR_PERIOD=INDICATOR_PERIOD, $
                    DOWNLOAD=DOWNLOAD, L2GEN=L2GEN, L2BIN=L2BIN, GRADMAG=GRADMAG, MERGE=MERGE, FRONTS_STACK=FRONTS_STACK, NETCDF=NETCDF, INDICATORS=INDICATORS, COMPOSITES=COMPOSITES, $
                    NPROCESS=NPROCESS, SERVERS=SERVERS, PARALLEL=PARALLEL, OVERWRITE=OVERWRITE, BUFFER=BUFFER, VERBOSE=VERBOSE

;+
; NAME:
;   BATCH_FRONTS
;
; PURPOSE:
;   Run the processings steps to create the frontal indicators
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATCH_FRONTS
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATASETS........ The dataset(s) to process
;   PRODS........... The product(s) to process
;   DATERANGE....... The date range of files to process
;   LOGFILE......... The log file to record progress information
;   D3MAP........... The map to subset the L3B files to when creating the "stacked" D3 files
;   NCMAP........... The "gridded" map to use when creating the output netcdf files for the frontal indicators
;   PLTMAP.......... The map to use when creating the frontal composites 
;   NPROCESS........ The number of processing commands to run in parallel
;   SERVERS......... The names of the servers to use for parallel processing
;
;   DOWNLOAD........ Initiates the downloading program
;   L2GEN........... Initiates BATCH_SEADAS_L1A to use SeaDAS to generate L2 files from L1A
;   L2BIN........... Initiates BATCH_SEADAS_L2BIN to use SeaDAS to merge the daily L2 files into daily L3B2 files
;   FRONTS.......... Initiates SAVE_MAKE_FRONTS
;   MERGE........... Initiates SAVE_FRONTS_MERGE
;   FRONTS_STACKED.. Initiates steps to create the "stacked" frontal files
;   NETCDF.......... Initiates D3_2NETCDF step
;   INDICATORS...... Initiates SAVE_MAKE_FRONT_INDICATORS to create the frontal indicators
;   COMPOSITES...... Initiates FRONT_INDICATORS_COMPOSITE and FRONT_COINCIDENCE_COMPOSITE to create composite images of the frontal data
;   
; KEYWORD PARAMETERS:
;   PARALLEL........ Run the steps in parallel by year
;   OVERWRITE....... Overwrite existing files if they currently exist
;   BUFFER.......... To buffer the graphics windows (0=graphics will be displayed while being created, 1=graphics will be hidden)
;   VERBOSE......... Print out steps of the program
;
; OUTPUTS:
;   Downloads and processes satellite files to create frontal products
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 24, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 24, 2021 - KJWH: Initial code written
;   Nov 05, 2021 - KJWH: Added steps to run in parallel by year
;                        * Added PARALLEL keyword
;                        * Updated the "step" names
;                        * Added STEP_NAMES and STEPS parameter to create the parallel command
;   Nov 08, 2021 - KJWH: Removed the STACKED step and put into a separate BATCH_STACKED program
;                        Removed the EMAILS input parameter because the email step is not included in this program
;                        Moved the parallel processing set-up steps to BATCH_FRONTS_PARALLEL
;   Nov 14, 2022 - KJWH: Changed D3HASH_2NETCDF to STACKED_2NETCDF
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATCH_FRONTS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  
; ===> Set up Defaults
  IF N_ELEMENTS(DATASETS)         EQ 0 THEN DATASETS         = 'AT'
  IF N_ELEMENTS(PRODS)            EQ 0 THEN PRODS            = ['GRAD_CHL','GRAD_SST']+'-BOA'
  IF N_ELEMENTS(BUFFER)           EQ 0 THEN BUFFER           = 1
  IF N_ELEMENTS(VERBSOE)          EQ 0 THEN VERBOSE          = 0
  IF N_ELEMENTS(MAPIN)            EQ 0 THEN MAPIN            = 'L3B2'
  IF N_ELEMENTS(D3MAP)            EQ 0 THEN D3MAP            = 'NWA'
  IF N_ELEMENTS(NCMAP)            EQ 0 THEN NCMAP            = 'NESGRID'
  IF N_ELEMENTS(PLTMAP)           EQ 0 THEN PLTMAP           = 'NES'
  IF N_ELEMENTS(INDICATOR_PERIOD) EQ 0 THEN INDICATOR_PERIOD = ['M','W']
  IF N_ELEMENTS(OVERWRITE)        EQ 0 THEN OVERWRITE        = 0
  
; ===> Set up parallel processing defaults
  IF N_ELEMENTS(NPROCESS)         EQ 0 THEN NPROCESS = 6 ELSE NPROCESS = 1 > FIX(NPROCESS) < 8 ; Maximum number of processes per server
  IF N_ELEMENTS(SERVERS)          EQ 0 THEN SERVERS = ['satdata','luna']
  
; ===> Manually adjust the default fronts program steps as needed
  IF N_ELEMENTS(DOWNLOAD)         EQ 0 THEN DOWNLOAD         = ''
  IF N_ELEMENTS(L2GEN)            EQ 0 THEN L2GEN            = ''
  IF N_ELEMENTS(L2BIN)            EQ 0 THEN L2BIN            = ''
  IF N_ELEMENTS(GRADMAG)          EQ 0 THEN GRADMAG          = ''
  IF N_ELEMENTS(MERGE)            EQ 0 THEN MERGE            = ''
  IF N_ELEMENTS(FRONTS_STACK)     EQ 0 THEN FRONTS_STACK     = 'Y'
  IF N_ELEMENTS(NETCDF)           EQ 0 THEN NETCDF           = 'Y'
  IF N_ELEMENTS(INDICATORS)       EQ 0 THEN INDICATORS       = 'Y'
  IF N_ELEMENTS(COMPOSITES)       EQ 0 THEN COMPOSITES       = 'Y'
  
  STEP_NAMES = ['DOWNLOAD','L2GEN','L2BIN','GRADMAG','MERGE','FRONTS_STACK','NETCDF','INDICATORS','COMPOSITES']
  STEPS      = [ DOWNLOAD,  L2GEN,  L2BIN,  GRADMAG,  MERGE,  FRONTS_STACK,  NETCDF,  INDICATORS,  COMPOSITES]
  
  
; ===> Get date information
  DP = DATE_PARSE(DATE_NOW())
  DATE = STRMID(DP.DATE,0,8)  

; ===> Loop through DATASETS   
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS[D]
    MERGE_DATASET = 1
    CASE DATASET OF                                                                               ; Get the sensor and product specific information for the "merged" data products
      'AT':  BEGIN & DSETS=['MODISA','MODIST']                   & DPRODS=PRODS          & END
      'ATV': BEGIN & DSETS=['MODISA','MODIST','VIIRS']           & DPRODS='GRAD_CHL-BOA' & END
      'AV':  BEGIN & DSETS=['MODISA','VIIRS']                    & DPRODS='GRAD_CHL-BOA' & END
      'AVHRR': BEGIN & DSETS = 'AVHRR'                           & DPRODS='GRAD_SST-BOA' & END
      'SA':  BEGIN & DSETS=['SEAWIFS','MODISA']                  & DPRODS='GRAD_CHL-BOA' & END
      'SAT': BEGIN & DSETS=['SEAWIFS','MODISA','MODIST']         & DPRODS='GRAD_CHL-BOA' & END
      'SATV':BEGIN & DSETS=['SEAWIFS','MODISA','MODIST','VIIRS'] & DPRODS='GRAD_CHL-BOA' & END
      'SAV': BEGIN & DSETS=['SEAWIFS','MODISA','VIIRS']          & DPRODS='GRAD_CHL-BOA' & END
     ELSE:   BEGIN & DSETS=DATASET & MERGE_DATASET=0             & DPRODS=PRODS          & END
    ENDCASE
    
; ===> Set up the DATERANGE
    IF N_ELEMENTS(DATERANGE) EQ 0 THEN DR = GET_DATERANGE(SENSOR_DATES(DATASET,/YEAR)) ELSE DR = GET_DATERANGE(DATERANGE)

    IF KEYWORD_SET(LOGFILE) OR KEYWORD_SET(PARALLEL) THEN BEGIN
      LOGDIR = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + DATE + SL                      ; Date-stamped working directory for the LOG files
      LDIR   = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + DP.YEAR + SL & DIR_TEST, LDIR  ; Final (year-based) log directory for the date-stamped direcotories after processing (the entire directory is moved into this directory)
      FDIR   = LDIR + DATE + SL                                                        ; Name of the date-stamped directory in the final directory location
      
      IF FILE_TEST(FDIR) THEN FILE_MOVE, FDIR, !S.LOGS + 'IDL_' + ROUTINE_NAME + SL  ; If the date-stamp directory exists in the final directory, then move it out to the parent directory so that it won't be replicated
      DIR_TEST, LOGDIR

      IF IDLTYPE(LOGFILE) NE 'STRING' THEN LOGFILE = LOGDIR + ROUTINE_NAME + '-' + DATASET + '.log'
      OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Open log file

    ENDIF ELSE BEGIN
      LUN = []
      LOGFILE = ''
    ENDELSE
    
    PLUN, LUN, '******************************************************************************************************************'
    PLUN, LUN, 'Starting ' + ROUTINE_NAME + ' log file: ' + LOGFILE + ' on: ' + systime() + ' on ' + !S.COMPUTER, 0
    PLUN, LUN, 'PID=' + GET_IDLPID() + '(on ' + STRLOWCASE(!S.COMPUTER) + ')'; ***** NOTE, may not be accurate with IDLDE sessions *****
    IF ANY(CMD_STRING) THEN PLUN, LUN, CMD_STRING
    
    IF KEYWORD_SET(PARALLEL) THEN BEGIN
      BATCH_FRONTS_PARALLEL, DATASET=DATASET, DATERANGE=DR, LOGFILE=LOGFILE, STEP_NAMES=STEP_NAMES, STEPS=STEPS, PRODS=PRODS, $
      MAPIN=MAPIN, D3MAP=D3MAP, NCMAP=NCMAP, PLTMAP=PLTMAP, INDICATOR_PERIOD=INDICATOR_PERIOD, $
      SERVERS=SERVERS, N_PROCESSES=N_PROCESSES, LOGLUN=LUN, OVERWRITE=OVERWRITE, BUFFER=BUFFER, VERBOSE=VERBOSE

      IF FILE_TEST(LDIR) AND FILE_TEST(LOGDIR) THEN FILE_MOVE, LOGDIR, LDIR
      LOGFILE = LDIR + DATE + SL + ROUTINE_NAME + '-' + DATASET + '.log'
      IF LUN NE [] THEN BEGIN & FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
      IF LOGFILE NE '' THEN OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen log file
    ENDIF

; ===> Loop through the individual datasets (DSETS)
    FOR S=0, N_ELEMENTS(DSETS)-1 DO BEGIN   
      FOR R=0, N_ELEMENTS(DPRODS)-1 DO BEGIN
        CASE DPRODS[R] OF
          'GRAD_SST-BOA': BEGIN 
            SUITE = 'SST' 
            CASE DSETS[S] OF 
              'MODISA': LSETS = ['SMODISA','SMODISA_NRT']
              'MODIST': LSETS = ['SMODIST','SMODIST_NRT']
              ELSE:     LSETS = DSETS[S]
            ENDCASE
          END
          'GRAD_CHL-BOA': BEGIN
            SUITE = 'CHL'
            LSETS = DSETS[S]
          END    
        ENDCASE ; PRODS

; ===> Download the original data
        IF KEYWORD_SET(DOWNLOAD) THEN DWLD_NASA_L1A, LSETS, DATERANGE=DR

; ===> Use L2GEN to process the L1A files to L2
        IF KEYWORD_SET(L2GEN) AND PRODS[R] EQ 'GRAD_CHL-BOA' THEN BEGIN
          OK = WHERE(LSETS NE 'MODIST',COUNT)
          IF COUNT GT 0 THEN BATCH_SEADAS_L1A, LSETS[OK], /GET_ANC, /RUN_L2GEN, LOGFILE=LOGFILE, DATERANGE=DR
        ENDIF

; ===> Use L2BIN to process the L2 files to L3B2
        IF KEYWORD_SET(L2BIN) THEN BATCH_SEADAS_L2BIN, LSETS, SUITE=SUITE, DATERANGE=DR, /RUN_L2BIN
              
      ENDFOR ; PRODS
    ENDFOR ; DSETS
    
; ===> Generate the fronts data    
    IF KEYWORD_SET(GRADMAG) THEN BATCH_L3, DO_FRONTS='Y['+STRJOIN(DSETS,',')+']', BATCH_DATERANGE=DR
    
; ===> Merge the frontal data
    IF KEYWORD_SET(MERGE) AND KEYWORD_SET(MERGE_DATASET) THEN SAVE_FRONT_MERGE, DATASET, PRODS=DPRODS, DATERANGE=DATERANGE
    
; ===> Create the "stacked" D3 files 
    IF KEYWORD_SET(FRONTS_STACK) THEN FRONTS_STACKED_FILES, DATASET, DATERANGE=DR, PRODS=DPRODS, L3BMAP=D3MAP, LOGLUN=LUN, OVERWRITE=OVERWRITE
    IF LUN NE [] THEN BEGIN & FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
    IF LOGFILE NE '' THEN OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen log file
    
; ===> Loop through periods
    FOR N=0, N_ELEMENTS(INDICATOR_PERIOD)-1 DO BEGIN
      CASE INDICATOR_PERIOD[N] OF
        'W': SPER='WW'
        'M': SPER='MM'
      ENDCASE
      
; ===> Loop through products
      FOR R=0, N_ELEMENTS(DPRODS)-1 DO BEGIN
        APROD = PRODS[R]
        CASE APROD OF
          'GRAD_SST-BOA': GPROD='GRADSST_INDICATORS-MILLER'
          'GRAD_CHL-BOA': GPROD='GRADCHL_INDICATORS-MILLER'
        ENDCASE
        PLUN, LUN, 'Working on ' + GPROD + ' data for ' + SPER + ' period'
        
        GFILES = GET_FILES(DATASET, PRODS=APROD, DATERANGE=DR, FILE_TYPE='STACKED', PERIOD='DD')
        IF KEYWORD_SET(NETCDF) THEN FOR N=0, N_ELEMENTS(INDICATOR_PERIOD)-1 DO STACKED_2NETCDF, GFILES, PERIOD_OUT=INDICATOR_PERIOD[N], MAP_OUT=NCMAP
      
; ===> Create the frontal indicators
        IF KEYWORD_SET(INDICATORS) THEN BEGIN
          FOR N=0, N_ELEMENTS(INDICATOR_PERIOD)-1 DO BEGIN
            D3HASH_FRONT_INDICATORS, GFILES, /INIT, PERIOD_CODE=INDICATOR_PERIOD[N], NC_MAP=NCMAP, LOGLUN=LUN
            IF LUN NE [] THEN BEGIN & FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
            IF LOGFILE NE '' THEN OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen log file
          ENDFOR
        ENDIF
              
; ===> Create composite figures of the data
        IF KEYWORD_SET(COMPOSITES) THEN BEGIN
        
          WFILES = GET_FILES(DATASET, PRODS=GPROD, PERIOD=SPER, FILE_TYPE='STACKED', DATERANGE=DR, COUNT=COUNT)
          MPRODS = ['FCLEAR','FVALID','GRAD_MAG','FMEAN','FSTD','FPROB','FINTENSITY','FPERSIST','FPERSISTPROB','FPERSISTCUM','MASK']
          IF COUNT GT 0 THEN FRONT_INDICATORS_COMPOSITE, WFILES, PRODS=MPRODS, MAP_OUT=PLTMAP, BUFFER=BUFFER, BATHY=200, LOGLUN=LUN
          IF LUN NE [] THEN BEGIN & FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
          IF LOGFILE NE '' THEN OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen log file

          ; ===> Add daily input images
          NFILES = GET_FILES(DATASET, PRODS=GPROD, PERIOD=SPER, FILE_TYPE='STACKED', DATERANGE=DR, COUNT=COUNT)
       ;   FRONT_INDICATORS_COMPOSITE, NFILES, PRODS = ['FCLEAR','FVALID','FMEAN','FPROB','FSTD','FPERSIST'], MAP_OUT=PLTMAP, BUFFER=BUFFER, BATHY=200, DIR_OUT=DOUT, /ADD_DAILY
          IF LUN NE [] THEN BEGIN & FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN & ENDIF
          IF LOGFILE NE '' THEN OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Reopen log file
       
        ENDIF ; COMPOSITES
      ENDFOR ; PRODS

; ===> Create the coincident composite figures
;      IF KEYWORD_SET(COMPOSITES) THEN BEGIN
;        SFILES = GET_FILES(DATASET, PRODS='GRADSST_INDICATORS-MILLER', FILE_TYPE='STACKED', PERIOD=SPER, DATERANGE=DR)
;        CFILES = GET_FILES(DATASET, PRODS='GRADCHL_INDICATORS-MILLER', FILE_TYPE='STACKED', PERIOD=SPER, DATERANGE=DR)
;        FRONT_COINCIDENCE_COMPOSITE, CHLFILES=CFILES, SSTFILES=SFILES, MAP_OUT=PLTMAP, /ADD_BATHY, BATHY_DEPTHS=200, BUFFER=BUFFER, OVERWRITE=OVERWRITE
;      ENDIF ; COINCIDENT COMPOSITES    

    ENDFOR ; PERIODS

  ENDFOR ; DATASETS


END ; ***************** End of BATCH_FRONTS *****************
