; $ID:	BATCH_L3.PRO,	2022-08-17-14,	USER-KJWH	$

;##########################################################################
PRO BATCH_L3, LOGFILE          = LOGFILE         ,$ ; The name of an optional logfile
              DO_OCCCI         = DO_OCCCI        ,$ ; Convert the L3 OC-CCI files to mapped SAV files
              DO_GLOBCOLOUR    = DO_GLOBCOLOUR   ,$ ; Convert the L3 GLOBCOLOUR files to mapped SAV files
              DO_GHRSST        = DO_GHRSST       ,$ ; Convert the L3 files to mapped SAV files for the GRHSST data
              DO_MAKE_PRODS    = DO_MAKE_PRODS   ,$ ; Create new products
              DO_D3            = DO_D3           ,$ ; Run the D3 steps
              DO_PPD           = DO_PPD          ,$ ; Create productivity products
              DO_STATS         = DO_STATS        ,$ ; Run statistics
              DO_ANOMS         = DO_ANOMS        ,$ ; Run anomalies
              DO_DOY_MOVIES    = DO_DOY_MOVIES   ,$ ; Create day of the year composite movies
              DO_FRONTS        = DO_FRONTS       ,$ ; Create frontal products
              DO_STAT_FRONTS   = DO_STAT_FRONTS  ,$ ; Run statistics on the frontal data
              DO_BLEND_FRONTS  = DO_BLEND_FRONTS, $ ; Steps to create a gap-filed blended product - TEST
              DO_PNGS_FRONTS   = DO_PNGS_FRONTS  ,$ ; Create PNG files for the frontal data
              DO_NETCDF        = DO_NETCDF       ,$ ; Need to add a step to generate the netcdf files to be posted on ERRDAP
              DO_COMPARE_PLOTS = DO_COMPARE_PLOTS,$ ; Creates a series of plots to compare the data from 1 dataset to another
              DO_FILE_PLOTS    = DO_FILE_PLOTS   ,$ ; Needs to be updated so that the plots are more informative and can be used to identify dates that are missing files
              DO_L3_2SAV       = DO_L3_2SAV      ,$ ; Obsolete step to convert L3 files to mapped SAV files.  Typically we don't need mapped SAV files
              DO_MERGE_FRONTS  = DO_MERGE_FRONTS ,$ ; Merge the frontal data - PROBABLY OBSOLETE
              BATCH_DATERANGE  = BATCH_DATERANGE ,$ ; "Master" daterange to be used in multiple steps if provided
              BATCH_DATASET    = BATCH_DATASET   ,$ ; "Master" dataset to be used in multiple steps if provided
              CMD_STRING       = CMD_STRING         ; String used as the input to BATCH_L3 from BATCH_L3_PARALLEL (for testing purposes)
              
; NAME: BATCH_L3
; 
; PURPOSE: This is a main BATCH program for sequential processing of level-3 satellite data files
;
; NOTES: The SWITCHES logical function governs which processing steps to do and what to do in the step
;        '' (NULL STRING) = (DO NOT DO THE STEP)
;        Any one or any combination of these letters [in any order] :  Y, O, V, R, S, E, F
;        Where: Any letter will do the step
;          Y  = YES [DO THE STEP]
;          O  = OVERWRITE [ANY OUTPUT]
;          V  = VERBOSE [ALLOW PRINT STATEMENTS]
;          RF = REVERSE FILES [THE PROCESSING ORDER OF FILES IN THE STEP]
;          RD = REVERSE DATASETS [THE PROCESSING ORDER OF THE DATASETS IN THE STEP]
;          RP = REVERSE PRODS [THE PROCESSINGN ORDER OF THE PRODUCTS IN THE STEP]
;          S  = STOP AT THE BEGINNING OF THE STEP AND STEP THROUGH EACH COMMAND IN THE STEP
;          E  = STOP THE AT THE END OF THE STEP
;          F  = PROCESS ONLY THE FIRST FOUR FILES
;          [DATES] = DATERANGE FOR SUBSETTING THE FILES
;
;
; MODIFICATION HISTORY: K.J.W. HYDE - Copied and modified from L3_MAIN  
;   NOV 16, 2015 - KJWH: Added switch keywords so that BATCH_L3 can be called externally and run specific switches (i.e. cron jobs).  
;                        Only currently updated switches (DO_AVHRR_2SAVE, DO_L3_2SAV, DO_GHRSST_2SAV, DO_STATISTICS) were added
;   NOV 23, 2015 - KJWH: Added DO_CHECK_MTIMES to find the near-real time L3 files that have not been updated with the newer version of the L3 file        
;   DEC 14, 2015 - KJWH: Moved DO_CHECK_MTIMES to be after the DO_STATISTICS_STEP        
;   OCT 07, 2016 - KJWH: Moved DO_STATISTICS step to be before DO_FRONTS
;   OCT 13, 2016 - KJWH: Changed steps DO_FRONTS_STATS and DO_FRONTS_PNG to DO_STATS_FRONTS and DO_PNGS_FRONTS to avoid similar tag names
;   DEC 05, 2016 - KJWH: Updated the SWITCHES step - changed NONE() to ANY()
;   DEC 13, 2016 - KJWH: Changed the map NEC2 to NES
;   JAN 20, 2017 - KJWH: Added DO_D3 steps
;   JAN 31, 2017 - KJWH: Updated DO_D3 steps
;                        Changed DO_AVHRR_2SAVE to DO_AVHRR_2SAV
;   FEB 07, 2017 - KJWH: Added DO_PPD steps       
;   FEB 13, 2017 - KJWH: Added DIR_PRODS loop to 
;                        Updated DO_ANOMALIES steps
;                        Updated SWITCHES in DO_STATISTICS to include DPRODS and DMAPS (dataset specific products and maps)
;   FEB 16, 2017 - KJWH: Changed DO_STATISTICS and DO_ANOMALIES to DO_STATS and DO_ANOMS  
;   APR 05, 2017 - KJWH: Changed DO_GHRSST_2SAV to DO_MUR     
;   DEC 04, 2017 - KJWH: Made several updates to the DATASETS names to coincide with updates to the !S.DATASETS directory structure - NOT COMPLETE    
;   DEC 15, 2017 - KJWH: Added DO_PAR_FILLED step to create PAR files that have the missing data filled in with the climatology           
;   FEB 13, 2018 - KJWH: Removed DO_PAR_FILLED step
;   MAY 21, 2018 - KJWH: Changed DO_MUR to DO_GHRSST
;                        Removed the DO_AVHRR_2SAV step and combined it with the MUR step in DO_GHRSST
;   SEP 17, 2018 - KJWH: Added BATCH_DATERANGE to create a "MASTER" daterange for all steps if no step specific dateranges are provided
;                        Added IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE) to each step   
;   OCT 15, 2018 - KJWH: Added DO_HERMES step to work with the HERMES data   
;   OCT 25, 2018 - KJWH: Added BATCH_DATASET 
;   NOV 14, 2018 - KJWH: Added an option to record a LOGFILE    
;                        Changed PRINT commands to PLUN    
;   NOV 19, 2018 - KJWH: Added PLUN, LUN, 'PID=' + GET_IDLPID() to record the PID number ***** NOTE, may not be accurate with IDLDE sessions *****    
;   JAN 30, 2018 - KJWH: Added steps in DO_STATS to be able to handle individual products that are grouped into a larger file.  For example, can now create STATS for just the FUCO pigment using the PIGMENTS files                             
;   SEP 09, 2019 - KJWH: Removed the D3 LOGFILE keywords and now using an input LOGLUN to record the log information
;   JAN 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR to be consistent with the source of the data
;
;########################################################################################
;                 
;+
;**********************
  ROUTINE_NAME='BATCH_L3'
;**********************
 
;===> DEFAULTS
  SL    = PATH_SEP()
  ASTER ='*'
  DASH  ='-' 
  DEFAULT_DATERANGE = ['19000101','21001231']
  IF KEY(LOGFILE) THEN BEGIN
    LOGDIR = !S.LOGS + ROUTINE_NAME + SL & 
    IF IDLTYPE(LOGFILE) NE 'STRING' THEN BEGIN
      DIR_TEST, LOGDIR
      LOGFILE =  LOGDIR + ROUTINE_NAME + DATE_NOW() + '.log'
    ENDIF  
    OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Open log file
  ENDIF ELSE BEGIN
    LUN = []
    LOGFILE = ''
  ENDELSE
  PLUN, LUN, '******************************************************************************************************************'
  PLUN, LUN, 'Starting ' + ROUTINE_NAME + ' log file: ' + LOGFILE + ' on: ' + systime() + ' on ' + !S.COMPUTER, 0
  PLUN, LUN, 'PID=' + GET_IDLPID() + '(on ' + STRLOWCASE(!S.COMPUTER) + ')'; ***** NOTE, may not be accurate with IDLDE sessions *****
  IF ANY(CMD_STRING) THEN PLUN, LUN, CMD_STRING
  
  IF NONE(BATCH_DATASET)   THEN BATCH_DATASET   = []
  IF NONE(BATCH_DATERANGE) AND BATCH_DATASET NE [] THEN BATCH_DATERANGE = SENSOR_DATES(VALIDS('SENSORS',BATCH_DATASET)) 
  IF NONE(BATCH_DATERANGE) THEN BATCH_DATERANGE = DEFAULT_DATERANGE ELSE BATCH_DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
   
;#####   SWITCHES   #####################   
  ALL_SWITCHES = []
  IF KEY(DO_GLOBCOLOUR)    THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_GLOBCOLOUR=' + DO_GLOBCOLOUR]
  IF KEY(DO_OCCCI)         THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_OCCCI=' + DO_OCCCI]
  IF KEY(DO_GHRSST)        THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_GHRSST=' + DO_GHRSST]
  IF KEY(DO_MAKE_PRODS)    THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_MAKE_PRODS=' + DO_MAKE_PRODS]
  IF KEY(DO_D3)            THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_D3=' + DO_D3]
  IF KEY(DO_PPD)           THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_PPD=' + DO_PPD]
  IF KEY(DO_STATS)         THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_STATS=' + DO_STATS]
  IF KEY(DO_ANOMS)         THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_ANOMS=' + DO_ANOMS]
  IF KEY(DO_DOY_MOVIES)    THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_DOY_MOVIES=' + DO_DOY_MOVIES]
  IF KEY(DO_FRONTS)        THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_FRONTS=' + DO_FRONTS]
  IF KEY(DO_STAT_FRONTS)   THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_STAT_FRONTS=' + DO_STAT_FRONTS] 
  IF KEY(DO_PNGS_FRONTS)   THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_PNGS_FRONTS=' + DO_PNGS_FRONTS] 
  IF KEY(DO_NETCDF)        THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_NETCDF=' + DO_NETCDF] 
  IF KEY(DO_COMPARE_PLOTS) THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_COMPARE_PLOTS=' + DO_COMPARE_PLOTS] 
  IF KEY(DO_FILE_PLOTS)    THEN ALL_SWITCHES = [ALL_SWITCHES,'DO_FILE_PLOTS=' + DO_FILE_PLOTS] 

  IF ALL_SWITCHES EQ [] THEN BEGIN
    PLUN, LUN, 'No SWITCHES set...'
    GOTO, DONE
  ENDIF

  PLUN, LUN, 'Running SWITCHES: ' + STRJOIN(ALL_SWITCHES,', ') + ' for DATERANGE: ' + BATCH_DATERANGE
  
;||||||||||||||||||||||||||||||||||

  REPRO = 'R2015' ; The 2014 (but mostly 2015) NASA reprocessing


; *******************************************************************************************************************************************
  IF KEY(DO_OCCCI) THEN BEGIN
; *******************************************************************************************************************************************
    SNAME = 'DO_OCCCI'
    SWITCHES,DO_OCCCI,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DMAPS=D_MAPS,DPRODS=D_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    PLUN, LUN, 'Starting ' + SNAME + '...', 1
    
    IF NONE(D_PRODS)   THEN PRODS     = ['CHLOR_A-CCI'] ELSE PRODS = STR_BREAK(D_PRODS,',') ; ,'RRS','A_CDOM_443-QAA','KD_490-ZHANG','ADG-QAA','APH-QAA','ATOT-QAA','BBP-QAA'
    IF NONE(D_MAPS)    THEN MAPS_OUT  = ['L3B4']
    
    VERSION = ['6.0']
    
    FOR V=0, N_ELEMENTS(VERSION)-1 DO BEGIN
      IF VERSION[V] NE '' THEN VER = 'V'+VERSION[V] + SL ELSE VER = ''
      DIR = !S.OCCCI + VER + 'SIN' + SL + 'NC' + SL
      DIR_OUT = !S.OCCCI + SL + VER    
      SAVE_MAKE_OCCCI, DIR, PRODS=PRODS, DIR_OUT=DIR_OUT, DATERANGE=DATERANGE, MAPS_OUT=MAPS_OUT, REVERSE_FILES=R_FILES, LOGLUN=LOGLUN
 ;     OCCCI_1KM_2SAVE, DATERANGE=DATERANGE, MAP_OUT=['L3B2'], REVERSE_FILES=R_FILES, LOGLUN=LOGLUN
    ENDFOR
    
    PLUN, LUN, 'Finished ' + SNAME + '...', 1
    
  ENDIF ; DO_OCCCI


; *******************************************************************************************************************************************
  IF KEY(DO_GLOBCOLOUR) THEN BEGIN
; *******************************************************************************************************************************************
    SNAME = 'DO_GLOBCOLOUR'
    SWITCHES,DO_GLOBCOLOUR,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DMAPS=D_MAPS,DPRODS=D_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    PLUN, LUN, 'Starting ' + SNAME + '...', 1

    IF NONE(D_PRODS)   THEN PRODS     = ['CHLOR_A-GSM','CHLOR_A-AV','PAR','PIC','POC'] ELSE PRODS = STR_BREAK(D_PRODS,',') ; ,'RRS','A_CDOM_443-QAA','KD_490-ZHANG'
    IF NONE(D_MAPS)    THEN MAPS_OUT  = ['L3B4']

    DIR = !S.GLOBCOLOUR + 'L3' + SL + 'NC' + SL
    DIR_OUT = !S.GLOBCOLOUR 

    SAVE_MAKE_GLOBCOLOUR, DIR, PRODS=PRODS, DIR_OUT=DIR_OUT, DATERANGE=DATERANGE, MAPS_OUT=MAPS_OUT, REVERSE_FILES=R_FILES, OVERWRITE=OVERWRITE
    
    PLUN, LUN, 'Finished ' + SNAME + '...', 1

  ENDIF ; DO_GLOBCOLOUR


; *******************************************************************************************************************************************
  IF KEY(DO_GHRSST) THEN BEGIN
; *******************************************************************************************************************************************
    SNAME = 'DO_GHRSST'
    SWITCHES,DO_GHRSST,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DMAPS=D_MAPS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    IF DATASETS EQ [] THEN DATASETS = ['GEOPOLAR','GEOPOLAR_INTERPOLATED','MUR','AVHRR'] 
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    LOGLUN=LUN
        
    FOR NTH = 0L, N_ELEMENTS(DATASETS)-1 DO BEGIN     
      DATASET = DATASETS[NTH]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      SUBSET_MAP = ''
      CASE DATASET OF
        'G1SST':  BEGIN & SUBDIR='L4' & MAPS=['L3B4'] & TARGET='JPL_OUROCEAN-L4UHfnd-GLOB-v01-fv01_0-G1SST' & END
        'MUR':    BEGIN & SUBDIR='L4' & MAPS=['L3B2'] & SUBSET_MAP='NWA' & TARGET='JPL-L4*MUR'  & END ; 'L3B9','L3B4','NEC','NES','NWA'
        'AVHRR':  BEGIN & SUBDIR='L3' & MAPS=['L3B4'] & TARGET='GHRSST' &  QUALITY_LEVEL=3 & DATE_CHECK = '20170131120000' & CHECK_ALL=0 & END  
        'GEOPOLAR_INTERPOLATED': BEGIN & SUBDIR='L4' & MAPS='L3B5' & TARGET='Geo_Polar_Blended_Night-GLOB-v02.0-fv01.0' & END 
        'GEOPOLAR': BEGIN & SUBDIR='L4' & MAPS='L3B5' & TARGET='L4_GHRSST-SST-Geo_Polar_Blended' & END     
      ENDCASE
      
      IF ANY(D_MAPS) THEN IF D_MAPS[NTH]  NE [] THEN MAPS = STR_BREAK(D_MAPS[NTH],',')
      
      REPEAT_GHRSST_2SAVE:
      DIR_IN  = !S.DATASETS + DATASET + SL + SUBDIR + SL + 'NC' + SL  
      DIR_OUT = !S.DATASETS + DATASET + SL 
      FILES = FILE_SEARCH(DIR_IN+'*'+TARGET+'*.nc',COUNT=COUNT) 
      IF DATASET NE 'GEOPOLAR' THEN FILES = DATE_SELECT(FILES,DATERANGE,COUNT=COUNT)
      IF COUNT EQ 0 THEN CONTINUE
      
      IF KEY(R_FILES) THEN FILES = REVERSE(FILES)               
      CASE DATASET OF 
        'AVHRR': SAVE_MAKE_PATHFINDER, FILES,MAPS_OUT=MAPS,DIR_OUT=DIR_OUT,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN,QUALITY_LEVEL=QUALITY_LEVEL
        ELSE:    SAVE_MAKE_GHRSST,     FILES,MAPS_OUT=MAPS,MAP_SUBSET=SUBSET_MAP,DIR_OUT=DIR_OUT,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN
      ENDCASE
      
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR;FOR NTH = 0L, N_ELEMENTS(DATASETS)-1 DO BEGIN
  ENDIF ;   IF KEY(DO_GHRSST) THEN BEGIN
  ;||||||||||||||||||||||||||||||||||||||||||| 

; ********************************
  IF KEY(DO_MAKE_PRODS) THEN BEGIN
; ********************************

    SNAME = 'DO_MAKE_PRODS'
    SWITCHES,DO_MAKE_PRODS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,DPRODS=DPRODS,DMAPS=DMAPS,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    SST_4PIGMENTS = 'AVINTERP_MUR'
    PPD_ALG = 'VGPM2'
        
    IF NONE(DATASETS) THEN DATASETS = ['OCCCI','MODISA','SEAWIFS','VIIRS']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR NTH = 0L, N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[NTH]
      MPS = ['L3B2']
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      VERSION = ''
      CASE DATASET OF
        'MODISA':     BEGIN & PRODS=['PHYTO_SIZE-TURNER','CHLOR_A-PAN'] & MPS='L3B2' & END ; ,'PIGMENTS-PAN','PHYTO-PAN'
        'SEAWIFS':    BEGIN & PRODS=['CHLOR_A-PAN'] & MPS='L3B2' & END
        'VIIRS':      BEGIN & PRODS=['CHLOR_A-PAN']                            & MPS='L3B2' & END
        'JPSS1':      BEGIN & PRODS=['CHLOR_A-PAN']                            & MPS='L3B2' & END
        'OCCCI':      BEGIN & PRODS=['PHYTO_SIZE-TURNER'] & MPS=['L3B4'] & VERSION=['6.0'] & END ; 'PHYTO_SIZE-BREWIN_NES','PHYTO_SIZE-HIRATA_NES'
        'GLOBCOLOUR': BEGIN & PRODS=['PHYTO_SIZE-TURNER'] & MPS=['L3B4'] & END ; 'PHYTO_SIZE-BREWIN_NES','PHYTO_SIZE-HIRATA_NES'
      ENDCASE
      
      IF ANY(DMAPS)  THEN IF DMAPS[NTH]  NE [] THEN MPS   = STR_BREAK(DMAPS[NTH],',')
      IF ANY(DPRODS) THEN IF DPRODS[NTH] NE [] THEN PRODS = STR_BREAK(DPRODS[NTH],',')

      FOR MTH=0, N_ELEMENTS(MPS)-1 DO BEGIN
        AMAP = MPS[MTH]
        PERIOD_IN = 'D'
        MASK = []
        CASE [1] OF
          DATASET EQ 'SEAWIFS': BEGIN & IF AMAP EQ 'L3B9' THEN BEGIN & PERIOD_IN='M' & MASK = 'LME' & ENDIF & END  
          DATASET EQ 'MODISA':  BEGIN & IF AMAP EQ 'L3B4' THEN BEGIN & PERIOD_IN='M' & MASK = 'LME' & ENDIF & END
          DATASET EQ 'VIIRS':   BEGIN & IF AMAP EQ 'L3B4' THEN BEGIN & PERIOD_IN='M' & MASK = 'LME' & ENDIF & END
          DATASET EQ 'JPSS1':   BEGIN & IF AMAP EQ 'L3B4' THEN BEGIN & PERIOD_IN='M' & MASK = 'LME' & ENDIF & END
          DATASET EQ 'GLOBCOLOUR': MASK = 'NWA'
          DATASET EQ 'OCCCI':   BEGIN 
            IF AMAP EQ 'L3B4' THEN BEGIN & PERIOD_IN='D' & MASK = 'NWA' & ENDIF & END
        ENDCASE
        
        SAVE_MAKE_PRODS, DATASET, PROD=PRODS, SENSOR_VERSION=VERSION, COMPOSITE=COMPOSITE, MPS=AMAP, PERIOD=PERIOD_IN, MASK=MASK, SST_GR=SST_4PIGMENTS, PPD_ALG=PPD_ALG, R_FILES=R_FILES, DATERANGE=DATERANGE, LOGLUN=LOGLUN
      ENDFOR  
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1    
    ENDFOR ; DATASETS
  ENDIF ; DO_MAKE_PRODS

; ********************************
  IF KEY(DO_D3) THEN BEGIN
; ********************************

    SNAME = 'DO_D3'
    PRINT, 'Running: ' + SNAME
    SWITCHES,DO_D3,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,DPRODS=DPRODS,DMAPS=DMAPS,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    CYR = DATE_NOW(/YEAR)
    
    IF NONE(DATASETS) THEN DATASETS = ['MODISA','VIIRS','OCCCI','SEAWIFS','AVHRR']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = STRUPCASE(DATASETS[N])
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      PREFIX = ''
      PERIODS = ['D']
      SPAN = []
      MEDFILE = 1 ; Default is to run D3_MED_FILL
      INTERP = 1 ; Default is to run D3_INTERP
      SUBDIR = GET_DATASET_DIR(DATASET)
      NC = 1
      VERSION = ''
      CASE DATASET OF
        'MODISA':     BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI']  & PREFIX='A' & END
        'MODIST':     BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI']                & PREFIX='T' & END
        'SEAWIFS':    BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI','CHLOR_A-PAN']  & PREFIX='S' & END
        'SA':         BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI','CHLOR_A-PAN']  & PREFIX='Z' & PERIODS=['M','A'] & END
        'SAV':        BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI','CHLOR_A-PAN']  & PREFIX='W' & PERIODS=['M','A'] & END
        'VIIRS':      BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI','CHLOR_A-PAN']  & PREFIX='V' & END
        'JPSS1':      BEGIN & MPS=['L3B2'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-OCI','CHLOR_A-PAN']  & PREFIX='V' & END
        'GLOBCOLOUR': BEGIN & MPS=['L3B4'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-GSM','CHLOR_A-AV']   & PREFIX='*' & END

        'MODISA-4KM':  BEGIN & MPS=['L3B4'] & SUBMAPS=[''] & PRODS=['CHLOR_A-OCI'] & PREFIX='A' & END
        'SEAWIFS-9KM': BEGIN & MPS=['L3B9'] & SUBMAPS=[''] & PRODS=['CHLOR_A-OCI'] & PREFIX='S' & END
        'OCCCI':       BEGIN & MPS=['L3B4'] & SUBMAPS=['NWA'] & PRODS=['CHLOR_A-CCI'] & PREFIX='E' & NC=0 & VERSION='6.0' & END ;,'CHLOR_A-PAN'

        'AVHRR':  BEGIN & MPS=['L3B4','L3B9'] & SUBMAPS=['',''] & PRODS=['SST'] & PREFIX='*' & SPAN=10 & SUBDIR=!S.SST & END
        'MUR':    BEGIN & MPS=['L3B2']        & SUBMAPS=['NWA'] & PRODS=['SST'] & PREFIX='*' & SPAN=10 & MEDFILL=[] & INTERP=0 & SUBDIR=!S.SST & END ; MEDFILL and INTERP not necessary on the MUR SST data
      ENDCASE
      
      IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATE_RANGE = SENSOR_DATES(DATASET,/YEAR) ELSE DATE_RANGE = DATERANGE
     
      IF ANY(DMAPS)  THEN IF DMAPS[N]  NE [] THEN MPS   = DMAPS[N] 
      IF ANY(DPRODS) THEN IF DPRODS[N] NE [] THEN PRODS = DPRODS[N]
      IF KEY(R_MAPS) THEN MPS = REVERSE(MPS)
      FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
        AMAP = MPS[M]
        IF SUBMAPS[M] EQ '' THEN L3BMAP = 0 ELSE L3BMAP = SUBMAPS[M]
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          CASE PRODS[P] OF
            'CHLOR_A-OCI': BEGIN & IF KEY(NC) THEN APROD = 'CHL' ELSE APROD = 'CHLOR_A-OCI' & END
            'CHLOR_A-CCI': APROD = 'CHLOR_A-CCI'
            'CHLOR_A-PAN': APROD = 'CHLOR_A-PAN'
            'PAR':         APROD = 'PAR'
            'SST-4UM':     APROD = 'SST4'
            'SST-11UM':    APROD = 'SST'
            'SST':         APROD = 'SST'
            ELSE:          APROD = PRODS[P]
          ENDCASE

          IF NONE(MEDFILL) THEN MEDFILL = 1 
          IF HAS(AMAP, 'L3B')  THEN MEDFILL = []  ; Can not run MED_FILL on 1D arrays
          IF PRODS[P] EQ 'PAR' THEN MEDFILL = []  ; Not necessary to run MED_FILL on the PAR data
          FIXNOISE = MEDFILL                      ; If not runningn MED_FILL then also skip FIXNOISE
      
          VER = ''
          IF VERSION NE '' THEN IF ~HAS(VERSION,'V') THEN VER='V'+VERSION + SL
            
      
          DIR_NC   = SUBDIR  + VER + AMAP + SL + 'NC'   + SL + APROD + SL
          DIR_SAV  = SUBDIR + VER + AMAP + SL + 'SAVE' + SL + APROD + SL
          DIR_OUT  = SUBDIR + VER + AMAP + SL + 'D3' + SL + PRODS[P] + SL & DIR_TEST, DIR_OUT
          DIR_ISAV = SUBDIR + VER + AMAP + SL + 'INTERP_SAVE' + SL + PRODS[P] + SL & IF KEY(INTERP) THEN DIR_TEST, DIR_SAV

          FILES = FILE_SEARCH(DIR_SAV + '*' + AMAP + '*' + APROD + '*.SAV',COUNT=COUNTF)
          COUNTD = 0 & COUNTN = 0
          IF HAS(AMAP,'L3B') AND COUNTF EQ 0 THEN BEGIN
            FILES = FILE_SEARCH(DIR_NC  + PREFIX + '*.' + AMAP + '_DAY_' + APROD + '.nc',COUNT=COUNTN)
            IF COUNTN EQ 0 THEN IF AMAP EQ 'L3B4' OR AMAP EQ 'L3B9' THEN FILES = FILE_SEARCH(REPLACE(DIR_NC,SL+APROD+SL,SL) + PREFIX + '*.' + 'L3b_DAY_' + APROD + '.nc',COUNT=COUNTD)
          ENDIF 

          YEARS = YEAR_RANGE(STRMID(DATE_RANGE[0],0,4),STRMID(DATE_RANGE[1],0,4),/STRING)
          YEARS = NUM2STR([YEARS[0]-1,YEARS,YEARS(-1)+1])
          DP = DATE_PARSE(DATE_NOW())
          FOR Y=1, N_ELEMENTS(YEARS)-2 DO BEGIN
            DTRANGE    = [YEARS[Y-1]+'1201',YEARS[Y+1]+'0131']
            SDATERANGE = [YEARS[Y]+'0101',  YEARS[Y]+'1231']

            YFILES = DATE_SELECT(FILES, DTRANGE, COUNT=COUNT_BEFORE)
            IF COUNT_BEFORE EQ 0 THEN BEGIN
              PLUN, LUN, 'D3 steps for ' + DATASETS[N] + ' (' + AMAP + ') - ' + YEARS[Y] + ' are complete.',0
              CONTINUE
            ENDIF
            SI = []
            IF COUNTD GT 0 OR COUNTN GT 0 THEN SI = SENSOR_INFO(YFILES,PROD=APROD) ELSE FP = FILE_PARSE(YFILES) 
            IF ANY(SI) THEN IFLS=DIR_ISAV+SI.INAME+'-'+PRODS[P]+'-INTERP.SAV' ELSE IFLS=DIR_ISAV+FP.NAME+'-INTERP.SAV'
            IF FILE_MAKE(YFILES,DATE_SELECT(IFLS,SDATERANGE,COUNT=COUNTI),OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
            IF COUNTI EQ 0 THEN GOTO, RUN_D3_MAKE ; CONTINUE ; ===> IFLS ARE OUTSIDE OF THE DATERANGE
            IF N_ELEMENTS(YFILES) LT 90 THEN CONTINUE ; ===> NEED AT LEAST 90 DAYS WORTH OF FILES TO RUN
            IF YEARS(Y) EQ DP.YEAR AND MAX(GET_MTIME(DATE_SELECT(IFLS,SDATERANGE),/JD)) GT JD_ADD(DP.JD,-7,/DAY) THEN CONTINUE ; ===> ONLY RUN IF INTERP-FILES ARE MORE THAN 7 DAYS OLD

            RUN_D3_MAKE:
            PLUN, LUN, 'MAKING D3 FILE FOR ' + DATASETS[N] + ' (' + AMAP + ') - ' + YEARS[Y]
            D3_MAKE, YFILES, D3_PROD=PRODS[P], DATERANGE=DTRANGE, VERBOSE=VERBOSE, DIR_OUT=DIR_OUT, OUTFILE=D3_FILE, INIT=INIT, L3BMAP=L3BMAP, MED_FILL=MEDFILL, FIXNOISE=FIXNOISE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
            IF KEY(INTERP) THEN BEGIN
              D3_INTERP, D3_FILE, SPAN=SPAN, D3_INTERP_FILE=D3_INTERP_FILE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
              D3_SAVES, D3_INTERP_FILE, DIR_SAV=DIR_ISAV, DATERANGE=SDATERANGE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
            ENDIF
            PLUN, LUN, 'Finished D3 steps for ' + DATASETS[N] + ' (' + AMAP + ') - ' + YEARS(Y)
            
          ENDFOR ; YEARS
        ENDFOR ; MAPS
      ENDFOR ; PRODS
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; DATASETS
  ENDIF ; DO_D3


; ********************************
  IF KEY(DO_PPD) THEN BEGIN
; ********************************

    SNAME = 'DO_PPD'
    PRINT, 'Running: ' + SNAME
    SWITCHES,DO_PPD,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DMAPS=DMAPS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    IF DATASETS EQ [] THEN DATASETS = ['MODISA','SEAWIFS','OCCCI','VIIRS']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    DATASETS = REPLACE(DATASETS,'PP-','')
      
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      PERIOD = 'D'
      INTERP_CHL = 1
      INTERP_PAR = 0
      SST = 'AVINTERP_MUR' ; 'AVHRR_MUR'
      VERSIONS = ''
      CASE DATASET OF
        'MODISA':     BEGIN & MAPS=['L3B2'] & MODELS=['VGPM2'] & CHL_ALG=['OCI'] & ADG_ALG=[] & PREFIX='A' & END
        'SEAWIFS':    BEGIN & MAPS=['L3B2'] & MODELS=['VGPM2'] & CHL_ALG=['OCI'] & ADG_ALG=[] & PREFIX='S' & END
        'OCCCI':      BEGIN & MAPS=['L3B4','L3B2'] & MODELS=['VGPM2'] & CHL_ALG=['CCI'] & ADG_ALG=[] & PREFIX=''  & VERSIONS = ['5.0'] & END
        'VIIRS':      BEGIN & MAPS=['L3B2'] & MODELS=['VGPM2'] & CHL_ALG=['OCI'] & ADG_ALG=[] & PREFIX='V' & END
        'JPSS1':      BEGIN & MAPS=['L3B2'] & MODELS=['VGPM2'] & CHL_ALG=['OCI'] & ADG_ALG=[] & PREFIX='V' & END
        'GLOBCOLOUR': BEGIN & MAPS=['L3B4'] & MODELS=['VGPM2'] & CHL_ALG=['GSM'] & ADG_AGL=[] & PREFIX='*' & END
      ENDCASE
      IF DATERANGE[0] EQ '19810101' AND DATERANGE[1] EQ '21001231' THEN DATE_RANGE = SENSOR_DATES(DATASET,/YEAR) ELSE DATE_RANGE = DATERANGE
      
      IF ANY(DMAPS)  THEN IF DMAPS[N]  NE [] THEN MAPS   = DMAPS[N]
      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
      
      FOR V=0, N_ELEMENTS(VERSIONS)-1 DO BEGIN
        VER = VERSIONS[V]
        IF VER NE '' THEN IF ~HAS(VER,'VERSION') THEN VER = 'VERSION_'+VER
        IF VER NE '' THEN DIRVER = VER+SL ELSE DIRVER = ''
        FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
          AMAP = MAPS[M]
          IF KEY(R_PRODS) THEN CHL_ALG = REVERSE(CHL_ALG)
          FOR P=0, N_ELEMENTS(CHL_ALG)-1 DO BEGIN
            IF CHL_ALG[P] EQ 'PAN' THEN PDATASET = DATASET + '_' + CHL_ALG[P] ELSE PDATASET = DATASET
            CHL_PROD = []
            IF KEYWORD_SET(INTERP_CHL) THEN CHL_TYPE='INTERP' ELSE CHL_TYPE='NC'
            IF KEYWORD_SET(INTERP_PAR) THEN PAR_TYPE='INTERP' ELSE PAR_TYPE='NC'
            
            CASE CHL_ALG[P] OF
              'CCI': BEGIN & SPROD = 'CHLOR_A-CCI' & NPROD = 'CHL' & CHL_PROD = 'chlor_a' & END
              'OCI': BEGIN & SPROD = 'CHLOR_A-OCI' & NPROD = 'CHL' & CHL_PROD = 'chlor_a' & END
              'OCX': BEGIN & SPROD = 'CHLOR_A-OCX' & NPROD = 'CHL' & CHL_PROD = 'chl_ocx' & END
              'PAN': BEGIN & SPROD = 'CHLOR_A-PAN' & NPROD = 'CHL_PAN' & IF CHL_TYPE EQ 'NC' THEN CHL_TYPE = 'SAV' & END
              'GSM': BEGIN & SPROD = 'CHLOR_A-GSM' & IF PAR_TYPE EQ 'NC' THEN PAR_TYPE = 'SAV' & END
              'AV' : BEGIN & SPROD = 'CHLOR_A-AV'  & IF PAR_TYPE EQ 'NC' THEN PAR_TYPE = 'SAV' & END
            ENDCASE
            
            DIR_NC     = !S.OC + DATASET + SL + DIRVER + AMAP + SL + 'NC' + SL  
            DIR_SAV    = !S.OC + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL
            DIR_INTERP = !S.OC + DATASET + SL + DIRVER + AMAP + SL + 'INTERP_SAVE' + SL 
            DIR        = DIR_NC ; DEFAULTS
            IF FILE_TEST(DIR_SAV + SPROD + SL,/DIR) EQ 1 THEN DIR = DIR_SAV ; OVERWRITE DEFAULT IF SAVE DIRECTORY IS PRESENT
            
            CFILES = GET_FILES(DATASET, PRODS=SPROD, MAPS=AMAP, PERIOD=PERIOD, FILE_TYPE=CHL_TYPE, COUNT=CNUM)
            
            
       ;       IF CHL_ALG[P] EQ 'PAN' THEN CFILES = FLS(DIR_SAV + SPROD + SL + PERIOD + '*' + SPROD + '*.SAV',DATERANGE=DATERANGE,COUNT=CNUM) $ 
       ;                              ELSE CFILES = FLS(DIR_NC  + 'CHL' + SL + PREFIX + '*' + NPROD + '.*',   DATERANGE=DATERANGE,COUNT=CNUM)
       ;     ENDIF ELSE CFILES = FLS(DIR_INTERP + SPROD + SL + PERIOD + '*' + SPROD + '*INTERP.SAV',DATERANGE=DATERANGE,COUNT=CNUM)  ; CHL FILES
                
            
    
                      
;            IF ~KEY(INTERP_PAR) THEN BEGIN
;              PFILES = FLS(DIR_NC     + 'PAR' + SL + PREFIX + '*PAR.*',DATERANGE=DATERANGE,COUNT=PNUM) 
;              IF PNUM EQ 0 THEN PFILES = FLS(DIR_NC + SL + PREFIX + '*PAR.*',DATERANGE=DATERANGE,COUNT=PNUM) 
;            ENDIF ELSE PFILES = FLS(DIR_INTERP + 'PAR' + SL + PERIOD + '*PAR*INTERP.SAV',DATERANGE=DATERANGE,COUNT=PNUM)  ; PAR FILES                   
   
            IF DATASET EQ 'OCCCI' THEN BEGIN ; Need to use the PAR files from SeaWiFS and MODISA because PAR is not an OCCCI product
              IF AMAP EQ 'L3B2' THEN BEGIN
                SFILES = GET_FILES('SEAWIFS',PRODS='PAR',FILE_TYPE='NC', MAPS=AMAP,PERIOD=PERIOD)
                MFILES = GET_FILES('MODISA',PRODS='PAR',FILE_TYPE='NC', MAPS=AMAP,PERIOD=PERIOD)
                SP = PARSE_IT(SFILES)
                MP = PARSE_IT(MFILES)
                AFILES = [SFILES,MFILES] & AFILES = AFILES[WHERE(AFILES NE '')]
                FP = [SP,MP]
                SETS = WHERE_SETS(FP.PERIOD)
                OK = WHERE(SETS.N GT 1, COUNT2, COMPLEMENT=POK, NCOMPLEMENT=COUNT1)
                IF COUNT1 GT 0 THEN PFILES = AFILES[WHERE_SETS_SUBS(SETS(POK))]
                IF COUNT2 GT 0 THEN BEGIN
                  SETS = SETS[OK]
                  SOK = WHERE(PERIOD_2JD(SETS.VALUE) LE DATE_2JD('200612315959'),SCOUNT,COMPLEMENT=MOK,NCOMPLEMENT=MCOUNT)
                  IF SCOUNT GT 0 THEN SPERS = WHERE_MATCH(SP.PERIOD,SETS[SOK].VALUE,COUNTS) ELSE COUNTS = 0
                  IF MCOUNT GT 0 THEN MPERS = WHERE_MATCH(MP.PERIOD,SETS[MOK].VALUE,COUNTM) ELSE COUNTM = 0
                  IF COUNTS GT 0 THEN PFILES = [PFILES,SFILES[SPERS]]
                  IF COUNTM GT 0 THEN PFILES = [PFILES,MFILES[MPERS]]
                ENDIF   
                FP = PARSE_IT(PFILES)
                PFILES = PFILES[SORT(PERIOD_2JD(FP.PERIOD))]
                PNUM = N_ELEMENTS(PFILES)
                SETS = WHERE_SETS(FP.PERIOD) & OK = WHERE(SETS.N GT 1, COUNT_CHECK)
                IF COUNT_CHECK GT 0 THEN MESSAGE, 'ERROR: More than 1 file per period found'
              ENDIF ELSE PFILES = GET_FILES('GLOBCOLOUR', PRODS='PAR', PERIOD=PERIOD, FILE_TYPE='SAV', COUNT=PNUM)  
            ENDIF ELSE PFILES = GET_FILES(DATASET, PRODS='PAR', PERIOD=PERIOD, FILE_TYPE=PAR_TYPE, COUNT=PNUM) ; OCCCI
            
            AFILES = [] ; FLS(DIR + APROD + SL + PERIOD + '*' + APROD + '*INTERP.SAV',DATERANGE=DATERANGE,COUNT=CNUM) ; A_CDOM FILES
            IF CNUM EQ 0 OR PNUM EQ 0 THEN CONTINUE ; IF NO CHL OR PAR FILES THEN CONTINUE (DO NOT NEED A_CDOM FILES FOR ALL ALGS)
         
            CASE SST OF
              'AVINTERP_MUR': BEGIN ; USE INTERPOLATED AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = FLS(!S.SST + 'AVHRR' + SL + 'L3B4' + SL + 'INTERP_SAVE' + SL + 'SST' + SL + PERIOD + '*SST*INTERP.SAV',DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = FLS(!S.SST + 'MUR'   + SL + AMAP   + SL +        'SAVE' + SL + 'SST' + SL + PERIOD + '*SST*.SAV',      DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES) 
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SFILES = MFILES
              END
              'AVHRR_MUR': BEGIN ; USE AVHRR UNTIL MUR DATA IS AVAILABLE IN 2002
                VFILES = FLS(!S.SST + 'AVHRR' + SL + 'L3B4' + SL + 'SAVE' + SL + 'SST' + SL + PERIOD + '*SST.SAV',DATERANGE=DATERANGE,COUNT=VNUM) & VFP = PARSE_IT(VFILES)
                MFILES = FLS(!S.SST + 'MUR'   + SL + AMAP + SL + 'SAVE' + SL + 'SST' + SL + PERIOD + '*SST.SAV',      DATERANGE=DATERANGE,COUNT=MNUM) & MFP = PARSE_IT(MFILES)
                IF DATE_2JD(DATERANGE[0]) LT DATE_2JD('20020601') THEN SFILES = [DATE_SELECT(VFILES,[DATERANGE[0],'20020531']),MFILES] ELSE SFILES = MFILES
              END ; ADD OTHER SST COMBOS AS NEEDED  
            ENDCASE
            SFILES = SFILES[WHERE(SFILES NE '',COUNT_SFILES,/NULL)] & IF SFILES EQ [] THEN STOP 
            
            IF KEY(R_FILES) THEN CFILES = REVERSE(CFILES) 
            DIR_OUT = !S.PP + PDATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL & DIR_TEST, DIR_OUT
            
            MAKE_PP_SAVES,PP_MODELS=MODELS,CHL_FILES=CFILES,SST_FILES=SFILES,PAR_FILES=PFILES,ACD_FILES=AFILES,CHL_PROD=CHL_PROD,$
                        DIR_PP=DIR_OUT,REVERSE_FILES=R_FILES,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN
            
          ENDFOR ; CHL_ALG
        ENDFOR ; MAPS
        PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
      ENDFOR ; VERSIONS  
    ENDFOR ; DATASETS    
  ENDIF ; DO_PPD
  
; ********************************
  IF KEY(DO_STATS) THEN BEGIN
; ********************************

    SNAME = 'DO_STATS'
    SWITCHES,DO_STATS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    ; *********  Set DIR_PRODS to be NC_PRODS if you want to use the .nc files  *********
    NC_PP    = ['CHLOR_A-OCI','CHLOR_A-OCX','CHLOR_A-CCI','PAR','A_CDOM_443-GIOP','APH_443-GIOP','BBP_443-GIOP','KD_490']
    NC_CHL   = ['CHLOR_A-OCI'];,'CHLOR_A-OCX'];,'POC','PAR']
    NC_POC   = ['POC','PIC']
    NC_PAR   = ['PAR']
    NC_SST   = ['SST-N_4UM'] ; 'SST-N_11UM'
    NC_RRS   = ['RRS_410','RRS_412','RRS_443','RRS_486','RRS_488','RRS_490','RRS_510','RRS_551','RRS_555','RRS_667','RRS_670','RRS_671']
    NC_KD    = ['KD_490']
    NC_PHYTO = ['MICRO_PERCENTAGE-UITZ','NANO_PERCENTAGE-UITZ','PICO_PERCENTAGE-UITZ','MICRO_PERCENTAGE-HIRATA','NANO_PERCENTAGE-HIRATA','PICO_PERCENTAGE-HIRATA','DIATOM_PERCENTAGE-HIRATA']
    CHLS     = ['CHLOR_A-PAN','CHLOR_A-CCI']
    MIN_OC   = ['CHLOR_A-OCI','PAR','CHLOR_A-PAN'];,'ACDOM_443_GIOP']
    MIN_CCI  = ['CHLOR_A-CCI'] ; 'CHLOR_A-PAN'
    MIN_GLB  = ['CHLOR_A-GSM'];,'CHLOR_A-AV']
    PPD      = ['PPD-VGPM2','PPD-OPAL']
    ZEU      = ['ZEU-VGPM2']
    RRS      = ['RRS_412','RRS_443','RRS_488','RRS_490','RRS_510','RRS_547','RRS_555','RRS_667','RRS_670']
    PIGMENTS = ['CHLA','CHLB','CHLC','CARO','ALLO','FUCO','PERID','NEO','VIOLA','DIA','LUT','ZEA']+'-PAN'
    PHYTO    = ['DIATOM*','GREEN*','BROWN*','CRYPTO*','CYANO*','DINOFLAGELLATE-PAN','DINOFLAGELLATE_PER*-PAN']
    PSIZET   = ['MICRO','NANO','NANOPICO','PICO']+'-TURNER'
    PSIZEB   = ['MICRO','NANO','NANOPICO','PICO']+'-BREWIN_NES'
    PSIZES   = ['MICRO','NANO','NANOPICO','PICO']+'-BREWINSST_NES'
    PSIZEH   = ['MICRO','NANO','NANOPICO','PICO']+'-HIRATA_NES'
    PSIZEHG  = ['MICRO','NANO','NANOPICO','PICO','DIATOM','DINOFLAGELLATE']+'-HIRATA' 
    PHYPERT  = ['MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE']+'-TURNER'
    PHYPERB  = ['MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE']+'-BREWIN_NES'
    PHYPERS  = ['MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE']+'-BREWINSST_NES'
    PHYPERH  = ['MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE']+'-HIRATA_NES'
    PHYPERHG = ['MICRO_PERCENTAGE','NANO_PERCENTAGE','NANOPICO_PERCENTAGE','PICO_PERCENTAGE','DIATOM_PERCENTAGE','DINOFLAGELLATE_PERCENTAGE']+'-HIRATA_NES'
    PHSIZE   = ['DIATOM','DIATOM_PERCENTAGE','MICRO','MICRO_PERCENTAGE','NANO','NANO_PERCENTAGE','NANOPICO','NANOPICO_PERCENTAGE','PICO','PICO_PERCENTAGE']+'-PAN'
    PPSIZE   = ['MICROPP','NANOPICOPP','MICROPP_PERCENTAGE','NANOPICOPP_PERCENTAGE']

    IF DATASETS EQ [] THEN DATASETS = ['MODISA','VIIRS','SEAWIFS','OCCCI','SAV','SA','AVHRR','MUR','PP-MODISA','PP-SEAWIFS','PP-VIIRS','PP-OCCCI','PP-SA','PP-SAV']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      REP = '' ; REPRO
      PREFIX = ''
      DR = DATERANGE
      ODATASET = DATASET ; Output DATASET (needed if the input and output DATASETS are different (e.g. the merged PP-SA-1KM dataset)
      PERIODS = []
      BADFILES = []
      IF ANY(D_PERIODS) THEN BEGIN
        IF N_ELEMENTS(D_PERIODS) GT 1 THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',') 
        IF N_ELEMENTS(D_PERIODS) EQ 1 THEN IF D_PERIODS[0] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[0],',')        
      ENDIF
      FILE_LABEL = []
      LTM = []
      DIR = !S.DATASETS
      VERSION = ''
      CASE DATASET OF
        'CZCS':       BEGIN & MAPS=['L3B4'] & DIR_PRODS=['MIN_OC'] & END
        'OCTS':       BEGIN & MAPS=['L3B4'] & DIR_PRODS=['MIN_OC'] & END
        'SEAWIFS':    BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','MIN_OC','PSIZET','NC_PHYTO'] & END
        'MODISA':     BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','PSIZET','PHYPERT'] & END ; 'NC_PHYTO'
        'MODIST':     BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL'] & END
        'MERIS':      BEGIN & MAPS=['L3B2'] & DIR_PRODS=['MIN_OC'] & END
        'VIIRS':      BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','MIN_OC','PSIZET','NC_PHYTO'] & END
        'JPSS1':      BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','MIN_OC','PSIZET','NC_PHYTO'] & END
        'SA':         BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','CHLOR_A-PAN'] & DATASET=['MODISA','SEAWIFS'] & END
        'SAV':        BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','CHLOR_A-PAN'] & DATASET=['SEAWIFS','MODISA','VIIRS'] & END
        'SAVJ':       BEGIN & MAPS=['L3B2'] & DIR_PRODS=['NC_CHL','CHLOR_A-PAN'] & DATASET=['SEAWIFS','MODISA','VIIRS','JPSS1'] &  END
        'OCCCI':      BEGIN & MAPS=['L3B2','L3B4'] & DIR_PRODS=['MIN_CCI','PSIZET','PHYPERT'] & VERSION = ['5.0'] & END
        'GLOBCOLOUR': BEGIN & MAPS=['L3B4'] & DIR_PRODS=['MIN_GLB'] & END

        'SST-MODISA': BEGIN & MAPS=['L3B2'] & DIR_PRODS='NC_SST'  & END
        'SST-MODIST': BEGIN & MAPS=['L3B2'] & DIR_PRODS='NC_SST'  & END
        'AVHRR':      BEGIN & MAPS=['L3B4'] & DIR_PRODS='SST'     & LTM=['19800101','20101231'] & END ; 'NES','NWA','NEC','L3B9',
        'MUR':        BEGIN & MAPS=['L3B2'] & DIR_PRODS='SST'     & END ; 'NES','NWA','NEC','L3B9','L3B4',
        'SST-AT':     BEGIN & MAPS=['L3B2'] & DIR_PRODS='NC_SST'  & DATASET=['SST-MODISA','SST-MODIST'] & PREFIX='X' &  MERGE=1 & END

        'PP-MODISA':      BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & END
        'PP-SEAWIFS':     BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & END
        'PP-OCCCI':       BEGIN & MAPS=['L3B2','L3B4']  & DIR_PRODS=['PPD']  & VERSION = ['5.0'] & END
        'PP-GLOBCOLOUR':  BEGIN & MAPS=['L3B4']  & DIR_PRODS=['PPD'] & END
        'PP-VIIRS':       BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & END
        'PP-JPSS1':       BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & END
        'PP-SA':          BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & DATASET=['SEAWIFS','MODISA'] & DIR=!S.PP & END
        'PP-SAV':         BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & DATASET=['SEAWIFS','MODISA','VIIRS'] & DIR=!S.PP & END
        'PP-SAVJ':        BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD'] & DATASET=['SEAWIFS','MODISA','VIIRS','JPSS1'] & DIR=!S.PP & END
        'PP-MODISA_PAN':  BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPSIZE','PPD'] & END
        'PP-SEAWIFS_PAN': BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPSIZE','PPD'] & END
        'PP-SA_PAN':      BEGIN & MAPS=['L3B2']  & DIR_PRODS=['PPD']          & DATASET=['PP-SEAWIFS_PAN-1KM','PP-MODISA_PAN-1KM'] & DIR=!S.PP &  MERGE=1 & END

        ELSE: DATASET = ''
      ENDCASE
      IF DATASET[0] EQ '' THEN CONTINUE
      
      FOR VTH=0, N_ELEMENTS(VERSION)-1 DO BEGIN
        VER = VERSION[VTH]
        IF VER NE '' THEN DIRVER = VER + SL ELSE DIRVER = ''
        IF DIRVER NE '' AND ~HAS(DIRVER,'V') THEN DIRVER = 'V' + DIRVER
        DSENSOR = VALIDS('SENSORS',DATASET)
              
        IF HAS(DATASET,'KM') THEN MESSAGE, 'ERROR: Check DATASET name'
        DATASET = REPLACE(DATASET,['SST-','PP-'],['',''])
        ODATASET = REPLACE(ODATASET,['SST-','PP-'],['',''])
        
        IF ANY(D_MAPS)  THEN BEGIN
          IF N_ELEMENTS(D_MAPS) GE N+1 THEN IF D_MAPS[N] NE [] THEN MAPS = STR_BREAK(D_MAPS[N],',')
          IF N_ELEMENTS(D_MAPS) EQ 1   THEN IF D_MAPS[0] NE [] THEN MAPS = STR_BREAK(D_MAPS[0],',')
        ENDIF
        
        IF ANY(D_PRODS) THEN BEGIN
          IF N_ELEMENTS(D_PRODS) GT N+1 THEN IF D_PRODS[N] NE [] THEN DIR_PRODS = STR_BREAK(D_PRODS[N],',')
          IF N_ELEMENTS(D_PRODS) EQ 1   THEN IF D_PRODS[0] NE [] THEN DIR_PRODS = STR_BREAK(D_PRODS[0],',')
          PDIMS = SIZEXYZ(DIR_PRODS)
          IF PDIMS.PX EQ 1 AND PDIMS.N_DIMENSIONS EQ 2 THEN DIR_PRODS = REFORM(DIR_PRODS)
        ENDIF
        
        DRS = [] & FOR SEN=0, N_ELEMENTS(DSENSOR)-1 DO DRS = [DRS,SENSOR_DATES(DSENSOR[SEN])]
        IF STRJOIN(DR,'_') EQ '19780101_21001231' THEN DR = MINMAX(S)
        
        IF NONE(PERIODS)  THEN PERIODS = 'STD'
        IF KEY(R_PERIODS) THEN PERIODS = REVERSE(PERIODS)  
        IF KEY(R_MAPS)    THEN MAPS    = REVERSE(MAPS)
        
        FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
          AMAP = MAPS[M]
          FOR PR=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APERIODS = PERIODS[PR]
            IF APERIODS EQ 'MIN' AND STRJOIN(STRMID(DR,0,4),'_') NE STRJOIN(STRMID(MINMAX(DRS),0,4),'_') THEN APERIODS = 'TEMP' ; Overwrite if the daterange is a subset of files instead of the full dataset
            CASE APERIODS OF
              'D8':    PERIOD_CODES_OUT = ['D','D8']
              'WK':    PERIOD_CODES_OUT = ['W','WEEK']
              'D':     PERIOD_CODES_OUT = ['D','D3','D8','DOY']
              'MON':   PERIOD_CODES_OUT = ['M','MONTH']
              'M3':    PERIOD_CODES_OUT = ['M','M3','MONTH','MONTH3']
              'ANN':   PERIOD_CODES_OUT = ['A','ANNUAL']
              'TEMP':  PERIOD_CODES_OUT = ['M','A']
              'FULL':  PERIOD_CODES_OUT = ['D','D3','D8','W','M','A','Y','DOY','WEEK','MONTH','ANNUAL','MANNUAL','YEAR','STUDY','SS','DD','MM','M3','YY','ALL']
              'CLIM':  PERIOD_CODES_OUT = ['MONTH','ANNUAL','MANNUAL','MONTH3','WEEK']
              'STD':   PERIOD_CODES_OUT = ['M','A','W']
              'MIN':   PERIOD_CODES_OUT = ['M','MONTH','A','ANNUAL','MANNUAL']
              ELSE:    PERIOD_CODES_OUT = APERIODS  ; DEFUALT PERIODS FOR STATS
            ENDCASE
            IF DATE_2YEAR(DR[0]) GT DATE_2YEAR(MIN(DRS)) OR DATE_2YEAR(DR(1)) LT DATE_2YEAR(MAX(DRS)) THEN BEGIN
              CLIM_PERIODS = ['WEEK','DOY','MONTH3','ANNUAL','MONTH','MANNUAL','YEAR','STUDY']
              OK = WHERE_MATCH(PERIOD_CODES_OUT,CLIM_PERIODS,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
              IF NCOMPLEMENT GE 1 THEN PERIOD_CODES_OUT = PERIOD_CODES_OUT(COMPLEMENT) ELSE CONTINUE
            ENDIF
    
            IF KEY(R_PRODS) THEN DIR_PRODS = REVERSE(DIR_PRODS)
            FOR RTH=0, N_ELEMENTS(DIR_PRODS)-1 DO BEGIN
              DIR_PROD = DIR_PRODS(RTH)
              DPRODS = []
              NC_PRODS = 0
              GR_PRODS = 0
              CASE DIR_PROD OF
                'ALL':       DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + '*',     /TEST_DIRECTORY, /MARK_DIRECTORY)
                'CHLS':      DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + CHLS,    /TEST_DIRECTORY, /MARK_DIRECTORY)
                'MIN_OC':    DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + MIN_OC,  /TEST_DIRECTORY, /MARK_DIRECTORY)
                'MIN_CCI':   DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + MIN_CCI, /TEST_DIRECTORY, /MARK_DIRECTORY)
                'MIN_GLB':   DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + MIN_GLB, /TEST_DIRECTORY, /MARK_DIRECTORY)
                'FULL_OC':   DPRODS = FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + 'SAVE' + SL + FULL_OC, /TEST_DIRECTORY, /MARK_DIRECTORY)
                'PPD':       FOR D=0, N_ELEMENTS(DATASET)-1 DO DPRODS = [DPRODS,FILE_SEARCH(DIR + DATASET[D] + SL + DIRVER + AMAP + SL + 'SAVE' + SL + PPD, /TEST_DIRECTORY, /MARK_DIRECTORY)] ; LOOP THROUGH DATASETS SO THAT PP DATABASES CAN BE COMBINED
                'NC_PAR':    BEGIN & DPRODS = NC_PAR    & NC_PRODS = 1 & END
                'NC_PP':     BEGIN & DPRODS = NC_PP     & NC_PRODS = 1 & END
                'NC_CHL':    BEGIN & DPRODS = NC_CHL    & NC_PRODS = 1 & END
                'NC_SST':    BEGIN & DPRODS = NC_SST    & NC_PRODS = 1 & END
                'NC_POC':    BEGIN & DPRODS = NC_POC    & NC_PRODS = 1 & END
                'NC_KD':     BEGIN & DPRODS = NC_KD     & NC_PRODS = 1 & END
                'NC_RRS':    BEGIN & DPRODS = NC_RRS[WHERE_MATCH(NC_RRS,GET_RRS(DSENSOR))]     & NC_PRODS = 1 & END
                'NC_PHYTO':  BEGIN & DPRODS = NC_PHYTO  & NC_PRODS = 1 & END
                'RRS_443':   BEGIN & DPRODS = 'RRS_443' & GR_PRODS = 1 & SEARCH_PROD = 'RRS' & END
                'RRS_555':   BEGIN & DPRODS = 'RRS_555' & GR_PRODS = 1 & SEARCH_PROD = 'RRS' & END
                'ADG_443':   BEGIN & DPRODS = 'ADG_443-QAA' & GR_PRODS = 1 & SEARCH_PROD = 'ADG-QAA' & END
                'PIGMENTS':  BEGIN & DPRODS = PIGMENTS  & GR_PRODS = 1 & SEARCH_PROD = 'PIGMENTS-PAN' & END
                'PSIZEB':    BEGIN & DPRODS = PSIZEB    & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-BREWIN_NES' & END
                'PSIZES':    BEGIN & DPRODS = PSIZES    & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-BREWINSST_NES' & END
                'PSIZET':    BEGIN & DPRODS = PSIZET    & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-TURNER' & END
                'PSIZEH':    BEGIN & DPRODS = PSIZEH    & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-HIRATA_NES' & END
                'PSIZEHG':   BEGIN & DPRODS = PSIZEHG   & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-HIRATA' & END
                'PHYPERB':   BEGIN & DPRODS = PHYPERB   & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-BREWIN_NES' & END
                'PHYPERS':   BEGIN & DPRODS = PHYPERS   & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-BREWINSST_NES' & END
                'PHYPERT':   BEGIN & DPRODS = PHYPERT   & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-TURNER' & END
                'PHYPERH':   BEGIN & DPRODS = PHYPERH   & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-HIRATA_NES' & END
                'PHYPERHG':  BEGIN & DPRODS = PHYPERHG  & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO_SIZE-HIRATA' & END
                'PHYTO':     BEGIN & DPRODS = PHYTO     & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO' & END
                'PHSIZE':    BEGIN & DPRODS = PHSIZE    & GR_PRODS = 1 & SEARCH_PROD = 'PHYTO-PAN' & END
                'ZEA-PAN':   BEGIN & DPRODS = 'ZEA-PAN' & GR_PRODS = 1 & SEARCH_PROD = 'PIGMENTS-PAN' & END
                'RRS':       BEGIN & DPRODS = RRS[WHERE_MATCH(RRS,GET_RRS(DSENSOR))] & GR_PRODS = 1  & SEARCH_PROD = 'RRS' & END
                'ZEU-VGPM2': BEGIN & DPRODS = 'ZEU'     & GR_PRODS = 1 & SEARCH_PROD = 'PPD-VGPM2' & END
                ELSE: BEGIN
                  SPRODS = []
                  FOR DP=0L, N_ELEMENTS(DIR_PROD)-1 DO BEGIN
                    OK_PIGMENT = WHERE_MATCH(PIGMENTS,DIR_PROD(DP),COUNT_PIGMENT) & IF COUNT_PIGMENT GT 0 THEN BEGIN & DPRODS=[DPRODS,PIGMENTS(OK_PIGMENT)] & SEARCH_PROD = 'PIGMENTS-PAN' & ENDIF
                    OK_PHYTO   = WHERE_MATCH(PHYTO,   DIR_PROD(DP),COUNT_PHYTO)   & IF COUNT_PHYTO   GT 0 THEN BEGIN & DPRODS=[DPRODS,PHYTO(OK_PHYTO)]      & SEARCH_PROD = 'PHYTO'        & ENDIF
                    OK_PHSIZE  = WHERE_MATCH(PHSIZE,  DIR_PROD(DP),COUNT_PHSIZE)  & IF COUNT_PHSIZE  GT 0 THEN BEGIN & DPRODS=[DPRODS,PHSIZE(OK_PHSIZE)]    & SEARCH_PROD = 'PHYTO-PAN'    & ENDIF
                    OK_PPSIZE  = WHERE_MATCH(PPSIZE,  DIR_PROD(DP),COUNT_PPSIZE)  & IF COUNT_PPSIZE  GT 0 THEN BEGIN & DPRODS=[DPRODS,PPSIZE(OK_PPSIZE)]    & SEARCH_PROD = 'PIGMENTS-PAN' & ENDIF
                    IF TOTAL([COUNT_PIGMENT,COUNT_PHYTO,COUNT_PHSIZE,COUNT_PPSIZE]) GT 0 THEN BEGIN
                      SRCH = 'STATS' 
                      GR_PRODS = 1
                    ENDIF ELSE SRCH = 'SAVE'
                    SPRODS = [SPRODS,FILE_SEARCH(DIR + DATASET + SL + DIRVER + AMAP + SL + SRCH + SL + DIR_PROD(DP) + '*',/TEST_DIRECTORY,/MARK_DIRECTORY)]
                  ENDFOR
                END  
              ENDCASE
      
              IF SPRODS NE [] THEN BEGIN
                FP_DIR = FILE_PARSE(SPRODS)
                PRODS = FP_DIR.SUB
              ENDIF
              IF DPRODS NE [] THEN BEGIN
                DPRODS = DPRODS[WHERE(DPRODS NE '')]
                PRODS = DPRODS
              ENDIF
              IF HAS(DPRODS,PATH_SEP()) THEN BEGIN
                FP_DIR = FILE_PARSE(DPRODS)
                PRODS = FP_DIR.SUB
              ENDIF
   ;  if none(prods) or prods(0) eq '' then stop      
              
              PRODS = PRODS[SORT(PRODS)]
              PRODS = PRODS[UNIQ(PRODS)]
              IF R_PRODS EQ 1 THEN PRODS = REVERSE(PRODS)
              FOR P=0,N_ELEMENTS(PRODS)-1L DO BEGIN
                PROD = PRODS[P]
                APROD = VALIDS('PRODS',PROD)
                AALG  = VALIDS('ALGS',PROD)
                DIR_NC    = DIR + DATASET  + SL + DIRVER + AMAP + SL + 'NC'        + SL
                DIR_SAVE  = DIR + DATASET  + SL + DIRVER + AMAP + SL + 'SAVE'      + SL + PROD + SL
                DIR_ISTAT = DIR + DATASET  + SL + DIRVER + AMAP + SL + 'STATS'     + SL + PROD + SL  ; DIR_ISTAT is the location of the input STATS, which may be different from DIR_STATS for combo sensors
                DIR_STATS = DIR + ODATASET + SL + DIRVER + AMAP + SL + 'STATS'     + SL + PROD + SL  ; ODATASET is the location of the output DATASET, which may be different from DATASET for combo sensors
                DIR_LTM   = DIR + ODATASET + SL + DIRVER + AMAP + SL + 'STATS_LTM' + SL + PROD + SL  
                DIR_OLD   = DIR + ODATASET + SL + DIRVER + AMAP + SL + 'OLD_STATS' + SL + PROD + SL
                
                STATS_LOOP = 1
                RESTART_STATS:
                FOR S=0, N_ELEMENTS(PERIOD_CODES_OUT)-1 DO BEGIN
                  FILES = []
                  PCO = PERIOD_CODES_OUT[S]
                  PERIOD_CODE_IN  = PERIOD_CODES_STATS(PCO)
                  IF PCO EQ 'D' AND HAS(AMAP,'L3B') THEN CONTINUE ; ===> L3B FILES ARE DAILY FILES
                  CASE PCO OF
                    'D'  : STAT_TYPES = ['MEAN','NUM']
                    'DOY': STAT_TYPES = ['MEAN','NUM','STD']
                    'D3' : STAT_TYPES = ['MEAN','NUM','STD']
                    'D8' : STAT_TYPES = ['MEAN','NUM','STD']
                    'W'  : STAT_TYPES = ['MEAN','NUM','STD']
                    'M3' : STAT_TYPES = ['MEAN','NUM','STD']
                    ELSE:  STAT_TYPES = ['MEAN','NUM','MIN','MAX','STD','SPAN','SUM']
                  ENDCASE
      
                  KEY_STAT = []
                  IF PERIOD_CODE_IN EQ 'S' OR PERIOD_CODE_IN EQ 'D' THEN BEGIN
                    IF KEY(GR_PRODS) THEN DIR_SAVE = REPLACE(DIR_SAVE,PROD,SEARCH_PROD) ELSE SEARCH_PROD = PROD
                    IF KEY(NC_PRODS) THEN BEGIN
                      NC_PROD = ''
                      IF HAS(PROD,'CHLOR_A') THEN NC_PROD = 'CHL'
                      IF HAS(PROD,'PAR')     THEN NC_PROD = 'PAR'
                      IF HAS(PROD,'RRS')     THEN NC_PROD = 'RRS'
                      IF HAS(PROD,'IOP')     THEN NC_PROD = 'IOP'
                      IF HAS(PROD,'ADG')     THEN NC_PROD = 'IOP'
                      IF HAS(PROD,'POC')     THEN NC_PROD = 'POC'
                      IF HAS(PROD,'PIC')     THEN NC_PROD = 'PIC'
                      IF HAS(PROD,'KD_490')  THEN NC_PROD = 'KD490'
                      IF HAS(PROD,'N_11UM')  THEN NC_PROD = 'NSST'
                      IF HAS(PROD,'N_4UM')   THEN NC_PROD = 'SST4'
                      IF HAS(PROD,'UITZ')    THEN NC_PROD = 'PFT'
                      IF HAS(PROD,'HIRATA')  THEN NC_PROD = 'PFT'
                      IF NC_PROD EQ '' THEN CONTINUE ; ===> CONTINUE IF NONE OF THE ABOVE PRODS ARE LISTED
                      FOR NC=0, N_ELEMENTS(DIR_NC)-1 DO FILES = [FILES,FILE_SEARCH(DIR_NC(NC)+NC_PROD+SL+PREFIX+'*.L3*_DAY_*'+NC_PROD+'*')]
                    ENDIF ELSE FOR SF=0, N_ELEMENTS(DIR_SAVE)-1 DO FILES = [FILES,FILE_SEARCH(DIR_SAVE(SF)+['S','D']+'_*'+ '*' + SEARCH_PROD+'*.SAV',COUNT=BFILES)] ; IF DIR_PROD EQ 'NC_PRODS'...
                  ENDIF ELSE FILES = FILE_SEARCH(DIR_STATS+PERIOD_CODE_IN+'_*'+VALIDS('SENSORS',DATASETS[N])+'*'+PROD+'*.SAV',COUNT=BFILES) ; IF PERIOD_CODE_IN EQ 'D'...
                  
                  IF N_ELEMENTS(FILES) EQ 0 AND HAS(DIR_PROD,'PPSIZE') AND PERIOD_CODE_IN EQ 'M' THEN FILES = FILE_SEARCH(REPLACE(DIR_STATS,PROD,SEARCH_PROD) + 'M_*' + SEARCH_PROD + '*.SAV')
                  IF N_ELEMENTS(FILES) EQ 0 AND HAS(DIR_PROD,'PHSIZE') AND PERIOD_CODE_IN EQ 'M' THEN FILES = FILE_SEARCH(REPLACE(DIR_STATS,PROD,SEARCH_PROD) + 'M_*' + SEARCH_PROD + '*.SAV')
  
                  FILES = FILES[WHERE(FILES NE '',COUNT_FILES)] 
                  IF COUNT_FILES EQ 0 AND N_ELEMENTS(DATASET) GT 1 THEN BEGIN
                    IF PCO EQ 'DOY' OR PCO EQ 'WEEK' OR PCO EQ 'MONTH' OR PCO EQ 'ANNUAL' OR PCO EQ 'MONTH3' THEN $
                      FOR NS=0, N_ELEMENTS(DIR_ISTAT)-1 DO FILES = [FILES,FILE_SEARCH(DIR_ISTAT(NS)+PERIOD_CODE_IN+'_*'+VALIDS('SENSORS',DATASET(NS))+'*'+PROD+'*.SAV')]             
                  FILES = FILES[WHERE(FILES NE '')]
                  ENDIF
                  
                  CLIM = 0
                  CASE PCO OF
                    'M':      BEGIN & DR[0] = STRMID(DR[0],0,6) + '01'   & DR[1] = STRMID(DR[1],0,6) + DAYS_MONTH(STRMID(DR[1],4,2),/STRING) & END
                    'M3':     BEGIN & DR[0] = STRMID(DR[0],0,6) + '01'   & DR[1] = STRMID(DR[1],0,6) + DAYS_MONTH(STRMID(DR[1],4,2),/STRING) & END
                    'MONTH':  BEGIN & DR[0] = STRMID(DR[0],0,6) + '01'   & DR[1] = STRMID(DR[1],0,6) + DAYS_MONTH(STRMID(DR[1],4,2),/STRING) & CLIM=1 & END
                    'WEEK':   BEGIN & DR[0] = STRMID(DR[0],0,6) + '01'   & DR[1] = STRMID(DR[1],0,6) + DAYS_MONTH(STRMID(DR[1],4,2),/STRING) & CLIM=1 & END
                    'DOY':    BEGIN & DR[0] = STRMID(DR[0],0,4) + '0101' & DR[1] = STRMID(DR[1],0,4) + '1231' & CLIM=1 & END
                    'A':      BEGIN & DR[0] = STRMID(DR[0],0,4) + '0101' & DR[1] = STRMID(DR[1],0,4) + '1231' & END
                    'ANNUAL': BEGIN & DR[0] = STRMID(DR[0],0,4) + '0101' & DR[1] = STRMID(DR[1],0,4) + '1231' & CLIM=1 & END
                    'MONTH3': CLIM=1
                    ELSE: DR = DR
                  ENDCASE
                  
                  FILES = DATE_SELECT(FILES,DR,COUNT=BFILES)
                  IF BFILES EQ 0 THEN CONTINUE ; ===> CONTINUE IF NO FILES ARE FOUND
      
                  FP = PARSE_IT(FILES)
                  IF ~SAME(FP.PERIOD_CODE) THEN MESSAGE, 'ERROR: Input PERIOD_CODES must be the same'
                  IF PCO EQ FP[0].PERIOD_CODE THEN CONTINUE ; INPUT PERIODS EQ PERIOD_CODE_OUT
      
                  DIR_TEST,[DIR_STATS,DIR_OLD]
      
                  RERUN_STATS:
                  PLUN, LUN, 'Making ' + PCO + ' stats for: ' + ODATASET + SL + AMAP + ' (' + PROD + ')' + ' ' + STRJOIN(DR,'-')
                  DN = DATE_NOW(/GMT)
                                  
                  IF KEY(NC_PRODS) THEN FILE_LABEL = (SENSOR_INFO(FILES[0])).FILELABEL+'-'+PROD ELSE FILE_LABEL = FILE_LABEL_MAKE(FILES[0])
                  IF N_ELEMENTS(DATASET) GT 1 THEN FILE_LABEL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),VALIDS('SENSORS',DATASETS[N])) ELSE FILE_LABEL = []
                  IF KEY(GR_PRODS) THEN FILE_LABEL = FILE_LABEL_MAKE(FILES[0],LST=['SENSOR','SATELLITE','SAT_EXTRA','METHOD','MAP']) + '-' + PROD 
                  IF FILE_LABEL NE [] THEN IF VALIDS('PRODS',FILE_LABEL,/VALID) NE 1 THEN STOP
                    
                  STATS_ARRAYS_PERIODS, FILES, STAT_PROD=PROD, DIR_OUT=DIR_STATS, PERIOD_CODE_OUT=PCO, FILE_LABEL=FILE_LABEL, DATERANGE=DR, LOGLUN=LOGLUN, $
                                        DO_STATS=STAT_TYPES, ERROR_STOP=0, REVERSE_FILES=R_FILES, KEY_STAT=KEY_STAT, BAD_FILES=BAD_FILES, INIT=INIT, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
                  
                  IF KEY(LTM) THEN BEGIN
                    IF CLIM EQ 0 THEN CONTINUE
                    DIR_TEST, DIR_LTM
                    FILES = DATE_SELECT(FILES,LTM)
                    STATS_ARRAYS_PERIODS, FILES, STAT_PROD=PROD, DIR_OUT=DIR_LTM, PERIOD_CODE_OUT=PCO, FILE_LABEL=FILE_LABEL, DATERANGE=LTM, LOGLUN=LOGLUN, $
                      DO_STATS=STAT_TYPES, ERROR_STOP=0, REVERSE_FILES=R_FILES, KEY_STAT=KEY_STAT, BAD_FILES=BAD_FILES, INIT=INIT, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
  
                  ENDIF  
                  
                  GONE, FILES
                  
                  IF ANY(BAD_FILES) THEN BEGIN
                    LI, BAD_FILES
                    PLUN, LUN, 'Found ' + NUM2STR(N_ELEMENTS(BAD_FILES)) + ' "BAD" files when running STATS_ARRAYS_PERIODS, further action needed...'
                    STATS_LOOP = STATS_LOOP + 1
                    FILE_DELETE, BAD_FILES, /VERBOSE
                    IF STATS_LOOP LT 4 THEN GOTO, RESTART_STATS  ; Restart stats at the period loop to try and recreate any "BAD" stats files.  
                  ENDIF  
                  STATS_CLEANUP,DIR_STATS=DIR_STATS,DIR_OUT=DIR_OLD,/MOVE_FILES,DATERANGE=DR
                ENDFOR ; PERIOD_CODES_OUT             
              ENDFOR ; PRODS  
            ENDFOR ; DIR_PRODS
          ENDFOR ; PERIODS
        ENDFOR ; MAPS
      ENDFOR ; VERSION  
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
      
     
      
    ENDFOR ; DATASET
  ENDIF ; IF KEY(DO_STATS)THEN BEGIN
 
  
; *******************************************************************************************************************************************
  IF KEY(DO_ANOMS) THEN BEGIN
; *******************************************************************************************************************************************
    SNAME = 'DO_ANOMS'
    SWITCHES,DO_ANOMS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
     
    RATIO_PRODS     = ['CHLOR_A','PPD','CHLOR_A-EUPHOTIC','POC','A_CDOM_443','A_CDOM_355','MICRO','NANO','PICO','NANOPICO']
    RATIO_CODES_TOP = ['A',     'M', 'M',    'M',      'M','M3',    'Y',    'Y','MONTH', 'ANNUAL', 'W',   'D']
    RATIO_CODES_BOT = ['ANNUAL','A', 'MONTH','ANNUAL', 'Y','MONTH3','YEAR', 'A','ANNUAL','MANNUAL','WEEK','DOY']
    
    MIN_OC = ['CHLOR_A-OCI']
    PHYTO  = [MIN_OC,'DIATOM-PAN','MICRO-PAN','NANO-PAN','PICO-PAN','NANOPICO-PAN','DIATOM-HIRATA','MICRO-HIRATA','NANO-HIRATA','PICO-HIRATA','MICRO-UITZ','NANO-UITZ','PICO-UITZ']
    TURNER = ['MICRO','NANO','PICO','NANOPICO','MICRO_PERCENTAGE','NANO_PERCENTAGE','PICO_PERCENTAGE','NANOPICO_PERCENTAGE']+'-TURNER'

    MIN_PP = ['PPD-VGPM2']
  
    IF DATASETS EQ [] THEN DATASETS = ['MODISA','SEAWIFS','SA','SAV','SAVJ','MUR','AVHRR','OCCCI',$
                                       'PP-MODISA','PP-SEAWIFS','PP-VIIRS','PP-JPSS1','PP-OCCCI','PP-SA','PP-SAV','PP-SAVJ'] ; 'VIIRS','SAV','SEA_SAV','MOD_SAV','VIR_SAV','PP-SAV','PP-SEA_SAV','PP-MOD_SAV','PP-VIR_SAV'
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      DR=DATERANGE
      PERIODS = []
      TOP_SETS=DATASET
      BOT_SET =DATASET
      DIR = !S.DATASETS
      LTM = 0
      VERSION = ''
      CASE DATASET OF
        'CZCS':       BEGIN & MAPS=['L3B4'] & PRODS=MIN_OC & PERIODS=['MIN'] & DR=[SENSOR_DATES('CZCS')] & END
        'OCTS':       BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & DR=[SENSOR_DATES('OCTS')] & END
        'SEAWIFS':    BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & END
        'MODISA':     BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & END
        'MERIS':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & END
        'VIIRS':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & END
        'JPSS1':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & END
        'OCCCI':      BEGIN & MAPS=['L3B2'] & PRODS=['CHLOR_A-CCI',TURNER] & PERIODS=['MIN'] & VERSION=['5.0'] & END
        'GLOBCOLOUR': BEGIN & MAPS=['L3B4'] & PRODS=['CHLOR_A-GSM'] & PERIODS=['MIN'] & END
        'SA':         BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & TOP_SETS=['SA'] & BOT_SET='SA' & END
        'SAV':        BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & TOP_SETS=['SAV'] & BOT_SET='SAV' & END
        'SAVJ':       BEGIN & MAPS=['L3B2'] & PRODS=MIN_OC & PERIODS=['MIN'] & TOP_SETS=['SAVJ'] & BOT_SET='SAVJ' & END
        
        'AVHRR':        BEGIN & MAPS=['L3B4'] & REP=''       & PRODS=['SST']    & PERIODS=['MIN']  & LTM=1 & END
        'SST-MODIS':    BEGIN & MAPS=['L3B4']        & REP='_R2015' & DIR_PRODS=['NC_SST'] & PERIODS=['MIN']   & END
        'MUR':          BEGIN & MAPS=['L3B2','L3B4','L3B9'] & REP=''       & PRODS=['SST']    & PERIODS=['MIN'] &  END
        'SST-MODISA':   BEGIN & MAPS=['L3B2'] & REP='' & DIR_PRODS='NC_SST' & PERIODS='MIN' & DATASET='SST-MODIS' & PREFIX='A' & END
        'SST-MODIST':   BEGIN & MAPS=['L3B2'] & REP='' & DIR_PRODS='NC_SST' & PERIODS='MIN' & DATASET='SST-MODIS' & PREFIX='T' & END
        'SST-AT':       BEGIN & MAPS=['L3B2'] & REP='' & DIR_PRODS='NC_SST' & PERIODS='MIN' & DATASET='SST-MODIS' & PREFIX='X' & END

        'PP-MODISA':     BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-SEAWIFS':    BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-VIIRS':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-JPSS1':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-OCCCI':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-GLOBCOLOUR': BEGIN & MAPS=['L3B4'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-SA':         BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & TOP_SETS=['PP-SA'] & BOT_SET='PP-SA'  & DIR=!S.PP & END
        'PP-SAV':        BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & TOP_SETS=['PP-SAV'] & BOT_SET='PP-SAV' & DIR=!S.PP & END
        'PP-SAVJ':       BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & TOP_SETS=['PP-SAVJ'] & BOT_SET='PP-SAVJ' & DIR=!S.PP & END
        
        'PP-MODISA_PAN':  BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-SEAWIFS_PAN': BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & END
        'PP-SA_PAN':      BEGIN & MAPS=['L3B2'] & PRODS=MIN_PP & PERIODS=['MIN'] & TOP_SETS=['PP-SA_PAN'] & BOT_SET='PP-SA_PAN' & END
      ENDCASE
  
      
      IF ANY(D_MAPS)    THEN IF D_MAPS[N]    NE [] THEN MAPS    = STR_BREAK(D_MAPS[N],',')
      IF ANY(D_PRODS)   THEN IF D_PRODS[N]   NE [] THEN PRODS   = STR_BREAK(D_PRODS[N],',')
      IF ANY(D_PERIODS) THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',')

      IF NONE(PERIODS)  THEN PERIODS = 'MIN'
      IF KEY(R_PERIODS) THEN PERIODS = REVERSE(PERIODS)
      IF KEY(R_MAPS)    THEN MAPS    = REVERSE(MAPS)
      
      FOR VTH=0, N_ELEMENTS(VERSION)-1 DO BEGIN
        VER = VERSION[VTH]
        IF VER NE '' THEN DIRVER = VER + SL ELSE DIRVER = ''
        IF DIRVER NE '' AND ~HAS(DIRVER,'VERSION') THEN DIRVER = 'VERSION_' + DIRVER
      
        CASE PERIODS OF 
          'MIN': BEGIN & RCTS = ['A','M','M','W','M3'] & RCBS = ['ANNUAL','MONTH','A','WEEK','MONTH3'] & END
          'WM' : BEGIN & RCTS = ['W','M']              & RCBS = ['WEEK','MONTH']              & END
          'A'  : BEGIN & RCTS = ['A']                  & RCBS = ['ANNUAL']                    & END
          'MA' : BEGIN & RCTS = ['M']                  & RCBS = ['A']                         & END
          'M'  : BEGIN & RCTS = ['M']                  & RCBS = ['MONTH']                     & END
          'MON': BEGIN & RCTS = ['M']                  & RCBS = ['A']                         & END
          'W'  : BEGIN & RCTS = ['W']                  & RCBS = ['WEEK']                      & END
          'M3' : BEGIN & RCTS = ['M3']                 & RCBS = ['MONTH3']                    & END
          ELSE: BEGIN
            OK = WHERE_MATCH(RATIO_CODES_TOP,PERIODS,COUNT)
            IF COUNT EQ 0 THEN MESSAGE, 'ERROR: PERIOD CODE PAIR NOT FOUND'
            RCTS = RATIO_CODES_TOP[OK]
            RCBS = RATIO_CODES_BOT[OK]
          END    
        ENDCASE   
  
        IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
        FOR M=0,N_ELEMENTS(MAPS)-1 DO BEGIN
          AMAP = MAPS[M]
          YS = DATE_2YEAR(DR[0])
          YE = DATE_2YEAR(DR[1])
          FOR P=0,N_ELEMENTS(PRODS)-1L DO BEGIN
            PROD = PRODS[P]
            APROD = VALIDS('PRODS',PROD)
            AALG  = VALIDS('ALGS',PROD)
            IF WHERE(APROD EQ RATIO_PRODS) GE 0 THEN ANOM = 'RATIO' ELSE ANOM = 'DIF'
            
            FOR TS=0, N_ELEMENTS(TOP_SETS)-1 DO BEGIN
              TOP_SET = TOP_SETS[TS]
              TOP_SET = REPLACE(TOP_SET,'PP-','') ; Remove the PP- label from the dataset
              BOT_SET = REPLACE(BOT_SET,'PP-','')
              
              TOP_SAVE  = DIR + TOP_SET + SL + DIRVER + AMAP + SL + 'SAVE'  + SL + PROD + SL
              TOP_STATS = DIR + TOP_SET + SL + DIRVER + AMAP + SL + 'STATS' + SL + PROD + SL
              BOT_STATS = DIR + BOT_SET + SL + DIRVER + AMAP + SL + 'STATS' + SL + PROD + SL
              LTM_STATS = DIR + BOT_SET + SL + DIRVER + AMAP + SL + 'STATS_LTM' + SL + PROD + SL
              DIR_ANOMS = DIR + BOT_SET + SL + DIRVER + AMAP + SL + 'ANOMS' + SL + PROD + SL     & DIR_TEST,DIR_ANOMS
              DIR_LTM   = DIR + BOT_SET + SL + DIRVER + AMAP + SL + 'ANOMS_LTM' + SL + PROD + SL  
              DIR_OLD   = DIR + BOT_SET + SL + DIRVER + AMAP + SL + 'OLD_ANOMS' + SL + PROD + SL & DIR_TEST,DIR_OLD
    
              FOR R=0,N_ELEMENTS(RCTS)-1 DO BEGIN
                RCT = RCTS[R]
                RCB = RCBS[R]
      
                IF RCB EQ 'D' THEN BEGIN
                  TOP_FILES = FILE_SEARCH(TOP_SAVE+RCT+'_*'+PROD+'*.SAV',COUNT=COUNTD)
                  IF COUNTD EQ 0 THEN BEGIN
                  ;  STOP ; IF USING .NC FILES FOR D STATS THEN NEED TO LOOK FOR THE NC FILES      
                   ; TOP_FILES = FILE_SEARCH(DIR_SAVE+RCT+'_*'+PROD+'*.SAV*',COUNT=COUNTD)
                  ENDIF
                ENDIF ELSE TOP_FILES = FILE_SEARCH(TOP_STATS+RCT+'_*'+PROD+'*' + '-STATS.SAV*',COUNT=COUNTD)
                IF COUNTD EQ 0 THEN CONTINUE
                TOP_FILES = DATE_SELECT(TOP_FILES,[YS,YE])
                IF TOP_FILES EQ [] THEN CONTINUE
                IF KEY(R_FILES) THEN TOP_FILES = REVERSE(TOP_FILES)
                FP = PARSE_IT(TOP_FILES)
      
                PLUN, LUN, 'Running ' + DATASET + ' ANOMS for ' + RCB, 1
                CASE RCB OF
                  'DOY': BEGIN
                    SET = WHERE_SETS(DATE_2IDOY(PERIOD_2DATE(FP.PERIOD)))
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      BF = FILE_SEARCH(BOT_STATS + RCB + '_*' + SET[S].VALUE + '_*' + SET[S].VALUE + '*' + PROD + '*' + '-STATS.SAV*')
                      IF BF[0] NE '' THEN FOR B=0, N_ELEMENTS(BF)-1 DO FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BF[B],ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                     ELSE PRINT, BOT_STATS + RCB + '_*' + SET[S].VALUE + '_*' + SET[S].VALUE + '*' + PROD + '*' + '-STATS.SAV' + ' not found'
                    ENDFOR
                  END
                  'A': BEGIN
                    SET = WHERE_SETS(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      BF = FILE_SEARCH(BOT_STATS + RCB + '_' + SET[S].VALUE + '*' + PROD + '*' + '-STATS.SAV*')
                      IF BF NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BF,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                  ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' + ' not found'
                    ENDFOR
                  END 
                  'Y': BEGIN
                    SET = WHERE_SETS(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      BF = FILE_SEARCH(BOT_STATS + RCB + '_' + SET[S].VALUE + '*' + PROD + '*' + '-STATS.SAV*')
                      IF BF NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BF,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                   ELSE PRINT, BOT_STATS + RCB + '_' + SET[S].VALUE + '*' + PROD + '*' + '-STATS.SAV' + ' not found'
                    ENDFOR
                  END
                  'WEEK': BEGIN
                    WK = STRMID(FP.PERIOD,6,2)
                    SET  = WHERE_SETS(WK)
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV*',COUNT=COUNTB)
                      IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                        ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' + ' not found'
                    ENDFOR
                  END
                  'MONTH': BEGIN
                    SET  = WHERE_SETS(DATE_2MONTH(PERIOD_2DATE(FP.PERIOD)))
                    YMIN = MIN(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    YMAX = MAX(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      
                      IF KEY(LTM) THEN BEGIN
                        BOT_FILE = FILE_SEARCH(LTM_STATS + RCB + '_'+SET[S].VALUE+'_*' + PROD + '*' + '-STATS.SAV',COUNT=COUNTL)
                        IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_LTM,FILEA=TF[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                          ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' +  ' not found'
                      ENDIF
                      
                      BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV',COUNT=COUNTB)
                      IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                        ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' + ' not found'
                    ENDFOR
                  END
                  'MONTH3': BEGIN
                    M3 = STRMID(FP.PERIOD,7,2) + '_' + STRMID(FP.PERIOD,14,2)
                    SET  = WHERE_SETS(M3)
                    IF KEY(R_FILES) THEN SET = STRUCT_REVERSE(SET)
                    FOR S=0L, N_ELEMENTS(SET)-1 DO BEGIN
                      TF = TOP_FILES(WHERE_SETS_SUBS(SET[S]))
                      
                      IF KEY(LTM) THEN BEGIN
                        BOT_FILE = FILE_SEARCH(LTM_STATS + RCB + '_'+SET[S].VALUE+'_*' + PROD + '*' + '-STATS.SAV*',COUNT=COUNTL)
                        IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_LTM,FILEA=TF[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                          ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' +  ' not found'
                      ENDIF                    
                      
                      BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV*',COUNT=COUNTB)
                      IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TF)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TF[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                        ELSE PRINT, BOT_STATS + RCB+'_'+SET[S].VALUE+'_'+'*'+PROD+'*' + '-STATS.SAV' +  ' not found'
                      
                    ENDFOR
                  END
                  'YEAR': BEGIN
                    YMIN = MIN(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    YMAX = MAX(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_'+YMIN+'*_'+YMAX+'*'+PROD+'*' + '-STATS.SAV*')
                    IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TOP_FILES)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TOP_FILES[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                      ELSE PRINT, BOT_STATS + RCB+'_'+YMIN+'*_'+YMAX+'*'+PROD+'*' + '-STATS.SAV' +  ' not found'
                  END
                  'ANNUAL': BEGIN
                    YMIN = MIN(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    YMAX = MAX(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_*'+PROD+'*' + '-STATS.SAV*',COUNT=COUNTB)
                    
                    IF COUNTB GT 1 THEN STOP ; (CAN POSSIBLY RUN STATS_CLEANUP TO REMOVE THE EXTRA FILES)
                    IF COUNTB EQ 1 THEN FOR F=0,N_ELEMENTS(TOP_FILES)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_ANOMS,FILEA=TOP_FILES[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                   ELSE PRINT, BOT_STATS + RCB+'_'+'*'+PROD+'*'+ '-STATS.SAV' +  ' not found'               
                    IF KEY(LTM) THEN BEGIN
                      BOT_FILE = FILE_SEARCH(LTM_STATS + RCB + '_*' + PROD + '*' + '-STATS.SAV*',COUNT=COUNTL)
                      IF COUNTL NE 1 THEN STOP
                      FOR F=0,N_ELEMENTS(TOP_FILES)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_LTM,FILEA=TOP_FILES[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN)
                    ENDIF
                  END
                  'MANNUAL': BEGIN
                    YMIN = MIN(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    YMAX = MAX(DATE_2YEAR(PERIOD_2DATE(FP.PERIOD)))
                    BOT_FILE = FILE_SEARCH(BOT_STATS + RCB+'_'+YMIN+'*_'+YMAX+'*'+PROD+'*' + '-STATS.SAV*')
                    IF BOT_FILE NE '' THEN FOR F=0,N_ELEMENTS(TOP_FILES)-1 DO RESULT = MAKE_ANOM_SAVES(DIR_OUT=DIR_LTM,FILEA=TOP_FILES[F],FILEB=BOT_FILE,ANOM=ANOM,OVERWRITE=OVERWRITE,LOGLUN=LOGLUN) $
                                      ELSE PRINT, BOT_STATS + RCB+'_'+YMIN+'*_'+YMAX+'*'+PROD+'*' + '-STATS.SAV' +  ' not found'
                  END
                ENDCASE
              ENDFOR
            ENDFOR  
            ANOMS_CLEANUP,DIR_ANOMS=DIR_ANOMS,DIR_OUT=DIR_OLD,/MOVE_FILES
          ENDFOR
        ENDFOR  
      ENDFOR
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ;
  ENDIF ; DO_ANOMS


  
; ********************************
  IF KEY(DO_DOY_MOVIES) THEN BEGIN
; ********************************
    SNAME = 'DO_DOY_MOVIES'
    SWITCHES,DO_DOY_MOVIES,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    BUFFER = 1
    
    IF NONE(DATASETS) THEN DATASETS = ['SEAWIFS','VIIRS','JPSS1','MODISA']
    IF NONE(D_PRODS) THEN PRODS = ['CHLOR_A-OCI','CHLOR_A-PAN','PAR','PPD-VGPM2'] ELSE PRODS = D_PRODS
    DIRS = ['NC','INTERP_SAVE','SAVE']

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    IF KEY(R_PRODS)    THEN PRODS = REVERSE(PRODS)
    IF KEY(R_FILES)    THEN DIRS = REVERSE(DIRS)
    
    MAPIN = 'L3B2'
    MAPOUT = 'NEC'
    DIM = 200
    BLK = MAPS_BLANK(MAPOUT)
    LAND = READ_LANDMASK(MAPOUT,/STRUCT)
    BLK[LAND.OCEAN] = 252
    BLK[LAND.LAND] = 251
    BLK[LAND.COAST] = 0

    PAL = 'PAL_DEFAULT'
    RGB_TABLE = RGBS([0,255],PAL=PAL)

    FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PREFIX = ''
      CASE DATASET OF
        'SEAWIFS': BEGIN & DR=['1998','2009'] & PREFIX='S' & STITLE='SeaWiFS'                 & END
        'MODISA':  BEGIN & DR=['2002','2019'] & PREFIX='A' & STITLE='MODIS-Aqua'              & END
        'VIIRS':   BEGIN & DR=['2012','2019'] & PREFIX='V' & STITLE='VIIRS'                   & END
        'JPSS1':   BEGIN & DR=['2018','2019'] & PREFIX='V' & STITLE='JPSS1'                   & END
        'SA':      BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua'                 & END
        'SAV':     BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua + VIIRS'         & END
        'SAVJ':    BEGIN & DR=['1998','2019'] & STITLE='SeaWiFS + MODIS-Aqua + VIIRS + JPSS1' & END
      ENDCASE

      YRS = YEAR_RANGE(DR[0],DR[1],/STRING) & NYRS = N_ELEMENTS(YRS)
      CASE NYRS OF
        2:  BEGIN & NROW = 1 & NCOL = 2 & END
        8:  BEGIN & NROW = 2 & NCOL = 4 & END
        12: BEGIN & NROW = 2 & NCOL = 6 & END
        18: BEGIN & NROW = 3 & NCOL = 6 & END
        22: BEGIN & NROW = 4 & NCOL = 6 & END
      ENDCASE

      DIM  = 200
      SP   = 5
      CSP  = 15
      TOP  = 15
      BOT  = 80
      XDIM = DIM*NCOL + SP*(NCOL+2)
      YDIM = DIM*NROW + SP*(NROW+3) + TOP + BOT
      XPOS = [] & FOR A=0, NROW-1 DO XPOS = [XPOS,SP+INDGEN(NCOL)*(DIM+SP)]
      YP = BOT+REVERSE(SP+INDGEN(NROW)*(DIM+SP)) & YPOS=[] & FOR A=0, NROW-1 DO YPOS = [YPOS,REPLICATE(YP(A),NCOL)]
      CPOS = [XDIM/2+CSP, BOT/2+CSP, XDIM-CSP, MIN(YPOS)-CSP]
      CPOS = FLOAT(CPOS)/FLOAT([XDIM,YDIM,XDIM,YDIM]) ; Convert the DEVICE units into NORMAL units
      DPOS = [CSP,CSP,XDIM/2-CSP,MIN(YPOS)-CSP]

      FOR I=0, N_ELEMENTS(PRODS)-1 DO BEGIN
        PROD = PRODS(I)
        APROD = VALIDS('PRODS',PROD)
        AALG  = VALIDS('ALGS',PROD)
        CASE APROD OF
          'CHLOR_A': BEGIN & DIN = !S.OC & SCL = 'CHLOR_A_0.1_30' & TITLE=UNITS('CHLOROPHYLL') & END
          'PPD': BEGIN & DIN = !S.PP & SCL = 'PPD_0.1_10' & NDIR = '' & TITLE='Primary Productivity ' + UNITS('PPD',/NO_NAME) & END
          'PAR': BEGIN & DIN = !S.OC & SCL = 'PAR' & NDIR = 'PAR' & TITLE='Photosynthetic Available Radiation ' + UNITS('PAR',/NO_NAME) & END
        ENDCASE
        
        CASE AALG OF
          'PAN': NDIR = ''
          'OCI': NDIR = 'CHL'
          ELSE: NDIR=NDIR
        ENDCASE

        FOR R=0, N_ELEMENTS(DIRS)-1 DO BEGIN
          DIR = DIRS(R)
          CASE DIR OF
            'NC':          BEGIN & PER = PREFIX & EXT = 'nc'  & DPROD=NDIR & TTITLE=' (Daily)' & END
            'SAVE':        BEGIN & PER = 'D'    & EXT = 'SAV' & DPROD=PROD & TTITLE=' (Daily)' & END
            'INTERP_SAVE': BEGIN & PER = 'D'    & EXT = 'SAV' & DPROD=PROD & TTITLE=' (Interpolated)' & END
          ENDCASE

          FS = FLS(DIN + DATASET + SL + MAPIN + SL + DIR + SL + DPROD + SL + PER + '*' + EXT, DATERANGE=DR, COUNT=CT)
          IF CT EQ 0 THEN CONTINUE
          DIRMOV = DIN + DATASET + SL + MAPIN + SL + 'MOVIES' + SL + PROD  + SL
          DIROUT = DIRMOV + DIR + SL & DIR_TEST, DIROUT 
          
          FP = PARSE_IT(FS)
          DP = DATE_PARSE(PERIOD_2DATE(FP.PERIOD))
          DOYS = (DATE_PARSE(CREATE_DATE('19990101','19991231'))).IDOY
          PNGS = []
          FOR S=0, N_ELEMENTS(DOYS)-1 DO BEGIN
            DOY = DOYS[S]
            FF = FS[WHERE(DP.IDOY EQ DOY,CNT,/NULL)]
            IF CNT EQ 0 THEN CONTINUE
            PNG = DIROUT + 'DOY_' + DOY + '-' + DATASET + '-' + MAPOUT + '-' + PROD + '-' + DIR + '.PNG'
            PNGS = [PNGS,PNG]
            IF FILE_MAKE(FF,PNG,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

            W = IMAGE(REPLICATE(255B,DIM,DIM),DIMENSIONS=[XDIM,YDIM],BUFFER=BUFFER)
            STXT = TEXT(XDIM-SP,YDIM-TOP+SP, STITLE + TTITLE, FONT_STYLE='BOLD',FONT_SIZE=16,ALIGNMENT=1.0,VERTICAL_ALIGNMENT=1,/DEVICE)
            TTXT = TEXT(SP,YDIM-TOP+SP,'Day of Year ' + DOY,FONT_STYLE='BOLD',FONT_SIZE=16,ALIGNMENT=0.0,VERTICAL_ALIGNMENT=1,/DEVICE)
            CBAR, SCL, IMG=W, CB_POS=CPOS, CB_TITLE=TITLE, CB_TYPE=3, PAL=PAL
            DB = DATE_BAR(YDOY_2DATE('1999',DOY),BKG='WHITE',DB_FONT_SIZE=14,DB_COLOR='RED',DB_THICK=4,FRAME_COLOR='BLACK',NO_YEAR=1,/DEVICE,DB_POS=DPOS)

            FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
              F = FLS[WHERE(DP.IDOY EQ DOY AND DP.YEAR EQ YRS(Y),COUNT,/NULL)]
              POS = [XPOS(Y),YPOS(Y),XPOS(Y)+DIM,YPOS(Y)+DIM]

              IF COUNT EQ 0 THEN IM = IMAGE(BLK, RGB_TABLE=RGB_TABLE, POSITION=POS,MARGIN=0,/DEVICE, /CURRENT) ELSE $
                PRODS_2PNG, F, MAPP=MAPOUT, PROD=SCL, IMG_POS=POS,/DEVICE, /CURRENT
              TXT = TEXT(POS[0]+SP, POS(3)-(SP*4), YRS(Y), FONT_STYLE='BOLD', FONT_SIZE=12, /DEVICE)
            ENDFOR ; YRS
            PFILE, PNG
            W.SAVE, PNG
            W.CLOSE
          ENDFOR ; DOYS

          MOVIE_FILE = 'A_' + YRS[0] + '_' + YRS(-1) + '-' + DATASET + '-' + MAPOUT + '-' + PROD + '-' + DIR + '.MP4'
          IF FILE_MAKE(PNGS,DIRMOV+MOVIE_FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          MAKE_FF_MOVIE,FILES=PNGS,DIR_OUT=DIRMOV,PAL=PAL,KBPS=KBPS,FPS=10,MAP=MAPOUT,YOFFSET=YOFFSET,TITLE_SLIDE=0,END_SLIDE=0,MOVIE_FILE=MOVIE_FILE

        ENDFOR ; DIRS
      ENDFOR ; PRODS
    ENDFOR ; DATASETS
  ENDIF ; DO_DOY_MOVIES


; ********************************
  IF KEY(DO_FRONTS) THEN BEGIN
; ********************************
    SNAME = 'DO_FRONTS'
    SWITCHES,DO_FRONTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
     
    IF DATASETS EQ [] THEN DATASETS = ['MODISA','MODIST','MUR','SEAWIFS','VIIRS','JPSS1','OCCCI','AVHRR']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
 
    FRONTS_ALG = 'BOA'

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      PREFIX = ''
      VERSION = ''
      PERIODS = ['D']
      CASE DATASET OF
        'MODISA':   BEGIN & MAPS=['L3B1'] & MAPS_OUT=['L3B1'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-OCI','SST-11UM','SST-N_4UM'] & SDIR='NC' & PREFIX='A' & END
        'MODIST':   BEGIN & MAPS=['L3B2'] & MAPS_OUT=['L3B2'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-OCI','SST-11UM','SST-N_4UM'] & SDIR='NC' & PREFIX='T' & END
        'SEAWIFS':  BEGIN & MAPS=['L3B2'] & MAPS_OUT=['L3B2'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-OCI']             & SDIR='NC' & PREFIX='S' & END
        'VIIRS':    BEGIN & MAPS=['L3B2'] & MAPS_OUT=['L3B2'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-OCI']             & SDIR='NC' & PREFIX='V' & END
        'JPSS1':    BEGIN & MAPS=['L3B2'] & MAPS_OUT=['L3B2'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-OCI']             & SDIR='NC' & PREFIX='V' & END
        'OCCCI':    BEGIN & MAPS=['L3B1'] & MAPS_OUT=['L3B1'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-CCI']             & SDIR='SAVE' & PREFIX='O' & END
        'GLOBCOLOUR': BEGIN & MAPS=['L3B4'] & MAPS_OUT=['L3B4'] & MAPS_SUBSET = ['NWA'] & PRODS=['CHLOR_A-GSM']           & SDIR='SAVE' & PREFIX='O' & END
        'AVHRR':    BEGIN & MAPS=['L3B4'] & MAPS_OUT=['L3B4'] & MAPS_SUBSET = ['NWA'] & PRODS=['SST']                     & SDIR='SAVE' & PREFIX='*' & END
        'MUR':      BEGIN & MAPS=['L3B2'] & MAPS_OUT=['L3B2'] & MAPS_SUBSET = ['NWA'] & PRODS=['SST']                     & SDIR='SAVE' & PREFIX='*' & END
        'GEOPOLAR': BEGIN & MAPS=['L3B5'] & MAPS_OUT=['L3B5'] & MAPS_SUBSET = ['NWA'] & PRODS=['SST']                     & SDIR='SAVE' & PREFIX='*' & END
        'GEOPOLAR_INTERPOLATED': BEGIN & MAPS=['L3B5'] & MAPS_OUT=['L3B5'] & MAPS_SUBSET = ['NWA'] & PRODS=['SST']        & SDIR='SAVE' & PREFIX='*' & END                 
      ENDCASE
      IF DATERANGE[0] EQ '19780101' AND DATERANGE[1] EQ '21001231' THEN DATE_RANGE = SENSOR_DATES(DATASET) ELSE DATE_RANGE = DATERANGE
      
      IF ANY(D_MAPS)  THEN IF D_MAPS[N]  NE [] THEN MAPS_OUT = STR_BREAK(D_MAPS[N],',')
      IF ANY(D_PRODS) THEN IF D_PRODS[N] NE [] THEN PRODS    = STR_BREAK(D_PRODS[N],',')
      IF ANY(D_PERIODS) THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',')
      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        AMAP = MAPS[M]
        IF KEY(R_PRODS) THEN PRODS = REVERSE(PRODS)
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          APROD = PRODS[P]
    ;      IF VALIDS('PRODS',APROD) NE 'CHLOR_A' AND VALIDS('PRODS',APROD) NE 'SST' THEN STOP
          MDIR = !S.(WHERE(TAG_NAMES(!S) EQ DATASET))
          CASE APROD OF
            'CHLOR_A-OCI': BEGIN & NPROD = 'CHL'  & END
            'CHLOR_A-CCI': BEGIN & NPROD = 'CHL'  & END
            'CHLOR_A-GSM': BEGIN & NPROD = 'CHL'  & END
            'SST-N_4UM':   BEGIN & NPROD = 'SST4' & END
            'SST-11UM':    BEGIN & NPROD = 'SST'  & END
            'SST':         BEGIN & NPROD = 'SST'  & END
            'SST4': BEGIN & NPROD = 'SST4' & END
          ENDCASE
          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APER = PERIODS(R)
            RERUN_SAVE_MAKE_FRONTS:
            IF APER EQ 'D' THEN BEGIN    
              CASE DATASET OF
                'OCCCI': FILES = GET_FILES(DATASET,PRODS=APROD,MAPS=AMAP,VERSION=VERSION)
                'GLOBCOLOUR': FILES = GET_FILES(DATASET,PRODS=APROD)
                ELSE: FILES = FILE_SEARCH(MDIR + AMAP + SL + SDIR + SL + NPROD + SL + PREFIX + '*' + AMAP + '*' + NPROD + '*.*') 
              ENDCASE
            ENDIF ELSE FILES = FILE_SEARCH(MDIR + AMAP + SL + 'STATS' + SL + APROD + SL + APER + '_*' + AMAP + '*' + APROD + '*STATS.SAV')                 
            FILES = DATE_SELECT(FILES, DATE_RANGE, COUNT=COUNT_BEFORE)
            IF COUNT_BEFORE EQ 0 THEN BEGIN
              PLUN, LUN, 'No files found for ' + DATASET + SL + AMAP + SL + 'NC' + SL + NPROD + SL + PREFIX + '* (' + DATE_RANGE + ')'
              CONTINUE
            ENDIF  
            DIR_OUT = MDIR 
            IF KEY(R_FILES) THEN FILES = REVERSE(FILES)
            IF MAPS_OUT EQ [] THEN OMAP = AMAP ELSE OMAP = MAPS_OUT
            IF MAPS_SUBSET EQ [] THEN SMAP = [] ELSE SMAP = MAPS_SUBSET[M]
            PLUN, LUN, 'MAKING ' + APER + ' FRONTS FILES FOR ' + DATASETS[N] + ' (' + AMAP + ')'
            
            SAVE_MAKE_FRONTS, FILES, FRONTS_ALG=FRONTS_ALG, DIR_OUT=DIR_OUT, MAP_OUT=OMAP, MAP_SUBSET=SMAP, PROD=PRODS[P], OVERWRITE=OVERWRITE, LOGLUN=LOGLUN;, /THUMBNAILS
            
          ENDFOR ; PERIODS  
        ENDFOR ; PRODS
      ENDFOR ; MAPS
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; DATASETS
  ENDIF ; DO_FRONTS     

; ********************************
  IF KEY(DO_STAT_FRONTS) THEN BEGIN
; ********************************

    SNAME = 'DO_STAT_FRONTS'
    SWITCHES,DO_STAT_FRONTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE EQ [] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    FORCE_STATS = 0
    LOGLUN=LUN
    
    IF DATASETS EQ [] THEN DATASETS = ['MODISA','MODIST','MUR','SEAWIFS','AVHRR','OCCCI','VIIRS','JPSS1']
    L3B4_DATASETS = ['AVHRR','OCCCI','GLOBCOLOUR']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)    
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      CASE DATASET OF
        'SA': SENSOR=['SEAWIFS','MODISA'] 
        'SAT':SENSOR=['SEAWIFS','MODISA','MODIST'] 
        'AT': SENSOR=['AT'];'MODISA','MODIST'] 
        ELSE: SENSOR=DATASET
      ENDCASE
      
      PRODS = ['GRAD_CHL','GRAD_SST'] + '-BOA'
      IF ANY(D_PRODS) THEN IF D_PRODS[N] NE [] THEN PRODS = STR_BREAK(D_PRODS[N],',')
      IF KEY(R_PRODS) THEN PRODS = REVERSE(PRODS)

      MAPS  = 'L3B2' ; ['NWA','NES'] 
      OK = WHERE_MATCH(DATASETS,L3B4_DATASETS,COUNT)
      IF COUNT EQ 1 THEN MAPS = 'L3B4'      
      IF ANY(D_MAPS)  THEN IF D_MAPS[N]  NE [] THEN MAPS = STR_BREAK(D_MAPS[N],',')
      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
      
      PERIODS = 'MIN'
      IF ANY(D_PERIODS) THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',')

      DR = DATERANGE
      IF STRJOIN(DR,'_') EQ '19780101_21001231' THEN DR = SENSOR_DATES(DATASET)
      
      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        AMAP = MAPS[M]
        FOR PR=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
          APERIODS = PERIODS(PR)
          IF APERIODS EQ 'MIN' AND STRJOIN(DR,'_') NE STRJOIN(SENSOR_DATES(DATASET),'_') THEN APERIODS = 'TEMP' ; Overwrite if the daterange is a subset of files instead of the full dataset
  
          CASE APERIODS OF
            'D8':    PERIOD_CODES_OUT = ['D8']
            'DAILY': PERIOD_CODES_OUT = ['D']
            'DOY':   PERIOD_CODES_OUT = ['DOY']
            'TEMP':  PERIOD_CODES_OUT = ['M','A']
            'FULL':  PERIOD_CODES_OUT = ['D','D3','D8','W','M','A','Y','DOY','WEEK','MONTH','ANNUAL','MANNUAL','YEAR','STUDY','SS','DD','MM','M3','YY','ALL']
            'MIN':   PERIOD_CODES_OUT = ['M','MONTH','A','ANNUAL','MANNUAL']
            ELSE:    PERIOD_CODES_OUT = APERIODS  ; DEFUALT PERIODS FOR STATS
          ENDCASE        
  
          IF R_PRODS EQ 1 THEN PRODS = REVERSE(PRODS)
          FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
            PROD = PRODS[P]
            APROD = VALIDS('PRODS',PROD)
            AALG  = VALIDS('ALGS',PROD)
            IF VALIDS('PRODS',PROD) NE 'GRAD_CHL' AND VALIDS('PRODS',PROD) NE 'GRAD_SST' THEN STOP
            
            DIR_SAVE  = GET_DATASET_DIR(DATASET) + AMAP + SL + 'SAVE'      + SL + PROD + SL
            DIR_STATS = GET_DATASET_DIR(DATASET) + AMAP + SL + 'STATS'     + SL + PROD + SL
            DIR_OLD   = GET_DATASET_DIR(DATASET) + AMAP + SL + 'OLD_STATS' + SL + PROD + SL
            
            FOR S=0, N_ELEMENTS(PERIOD_CODES_OUT)-1 DO BEGIN
              FILES = []
              PERIOD_CODE_OUT = PERIOD_CODES_OUT[S]
              PERIOD_CODE_IN  = PERIOD_CODES_STATS(PERIOD_CODE_OUT)
               
              FILES = FILE_SEARCH(DIR_SAVE+PERIOD_CODE_IN+'_*'+SENSOR+'*'+PROD+'*.SAV',COUNT=BFILES)  
              IF BFILES EQ 0 AND PERIOD_CODE_IN EQ 'S' THEN BEGIN
                IF PERIOD_CODE_OUT EQ 'D' THEN CONTINUE
                FILES = FILE_SEARCH(DIR_SAVE+'D'+'_*'+SENSOR+'*'+PROD+'*.SAV',COUNT=BFILES)  ; ===> Look for 'D' files if no 'S' files are found
              ENDIF
              IF BFILES EQ 0 THEN FILES = FILE_SEARCH(DIR_STATS+PERIOD_CODE_IN+'_*'+PROD+'*.SAV',COUNT=BFILES) 
  
              FILES = DATE_SELECT(FILES,DR,COUNT=BFILES)
              IF BFILES EQ 0 THEN CONTINUE ; ===> CONTINUE IF NO FILES ARE FOUND
  
              PLUN, LUN, 'MAKING ' + PERIOD_CODE_OUT + ' STATS FOR ' + STRJOIN(SENSOR,'_') + ' - ' + AMAP + ' (' + PROD + ')' + ' ' + STRJOIN(DR,'-')
              DN = DATE_NOW(/GMT)
  
              FILE_LABEL=FILE_LABEL_MAKE(FILES[0], LST=['SENSOR','SATELLITE','COVERAGE','SAT_EXTRA',  'METHOD','MAP','PROD','ALG']) 
              IF SENSOR EQ 'SA' THEN FILE_LABEL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),'SA')
              DIR_TEST,[DIR_STATS,DIR_OLD]
              STATS_ARRAYS_FRONTS, FILES, DIR_OUT=DIR_STATS, PERIOD_CODE_OUT=PERIOD_CODE_OUT, FILE_LABEL=FILE_LABEL, DO_STATS=STAT_TYPES, REVERSE_FILES=R_FILES, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, LOGLUN=LOGLUN;, /THUMBNAILS
                        
            ENDFOR ; PERIOD_CODES
          ENDFOR ; MAPS  
        ENDFOR ; PRODS
        STATS_CLEANUP,DIR_STATS=DIR_STATS,DIR_OUT=DIR_OLD,/MOVE_FILES,DATERANGE=DR
      ENDFOR ; MAPS
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; DATASETS
  ENDIF ; DO_STAT_FRONTS   
  
  
; ********************************
  IF KEY(DO_BLEND_FRONTS) THEN BEGIN
; ********************************

    SNAME = 'DO_BLEND_FRONTS'
    SWITCHES,DO_BLEND_FRONTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    SENSORS = []
    IF DATASETS EQ [] THEN DATASETS = ['SST-TAM']
     

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      DR = DATERANGE
      SENSOR  = VALIDS('SENSORS',DATASET)
      SERVER = !S.DATASETS
      PERIODS = 'D8'
      CASE DATASET OF
        'SST-TAM': BEGIN & MAPS=['NES'] & PRODS=['GRAD_SST-BOA'] & SENSORS=['MODIST', 'MODISA','MUR'] & END
      ENDCASE

      BRK = STR_BREAK(DATASET,'-')
      DATASET = BRK[1]

      IF ANY(D_MAPS)  THEN IF D_MAPS[N]  NE [] THEN MAPS = STR_BREAK(D_MAPS[N],',')
      IF ANY(D_PRODS) THEN IF D_PRODS[N] NE [] THEN PRODS = STR_BREAK(D_PRODS[N],',')
      IF ANY(D_PERIODS) THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',')
      IF STRJOIN(DR,'_') EQ '19780101_21001231' THEN DR = SENSOR_DATES(VALIDS('SENSORS',DATASET))

      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        AMAP = MAPS[M]
        IF R_PRODS EQ 1 THEN PRODS = REVERSE(PRODS)
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          PROD = PRODS[P]
          PROD = PRODS[P]
          APROD = VALIDS('PRODS',PROD)
          AALG  = VALIDS('ALGS',PROD)

          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            APER = PERIODS(R)
            IF APER EQ 'D' THEN FILES = FILE_SEARCH(!S.FRONTS + SENSORS + SL + AMAP + SL + 'SAVE'  + SL + PRODS[P] + SL + '*' + AMAP + '*' + APROD + '*.SAV') $
                           ELSE FILES = FILE_SEARCH(!S.FRONTS + SENSORS + SL + AMAP + SL + 'STATS' + SL + PRODS[P] + SL + APER + '_*' + AMAP + '*' + PRODS[P] + '*STATS.SAV')
            FILES = DATE_SELECT(FILES,DR,COUNT=BFILES)
            IF BFILES EQ 0 THEN CONTINUE ; ===> CONTINUE IF NO FILES ARE FOUND

            FP = FILE_PARSE(FILES)
            IF SAME(FP.DIR) EQ 1 THEN CONTINUE ; ===> CONTINUE BECAUSE THERE ARE ONLY ONE SET OF FILES

            ;DIR_SAVE = !S.FRONTS + [SENSORS] + SL + AMAP + SL + 'SAVE'      + SL + PROD + SL
            DIR_OUT  = !S.FRONTS + DATASET   + SL + AMAP + SL + 'SAVE'      + SL + PROD + SL
            DIR_OLD  = !S.FRONTS + DATASET   + SL + AMAP + SL + 'OLD_STATS' + SL + PROD + SL
            DIR_TEST,[DIR_OUT,DIR_OLD]

            PRINT, 'MAKING MERGED DAILY FRONTS FILES FROM ' + STRJOIN(SENSORS,' & ') + ' - ' + AMAP + ' (' + PROD + ')' + ' ' + STRJOIN(DR,'-')
            DN = DATE_NOW(/GMT)

            FILE_LABEL=FILE_LABEL_MAKE(FILES[0])
            FILE_LABEL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),SENSOR)
            FORCE_STATS = 0
            STATS_ARRAYS_FRONTS, FILES, DIR_OUT=DIR_OUT, PERIOD_CODE_OUT='D', FILE_LABEL=FILE_LABEL, FORCE_STATS=FORCE_STATS,  DO_STATS=STAT_TYPES, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE

          ENDFOR ; PERIODS
          STATS_CLEANUP,DIR_STATS=DIR_OUT,DIR_OUT=DIR_OLD,/MOVE_FILES,DATERANGE=DR
        ENDFOR ; PRODS
      ENDFOR ; MAPS
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; SENSORS

  ENDIF ; DO_BLEND_FRONTS

; ********************************
  IF KEY(DO_PNGS_FRONTS) THEN BEGIN
; ********************************

    SNAME = 'DO_PNGS_FRONTS'
    SWITCHES,DO_PNGS_FRONTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    DO_COMPOSITES = 0
    DO_DAILY = 1

    IF DATASETS EQ [] THEN DATASETS = ['OC-MODISA-1KM','OC-SEAWIFS-1KM','SST-MODISA-1KM','SST-MODIST-1KM','SST-AT-1KM']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
      

    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[N]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      SERVER = !S.DATASETS
      CASE DATASET OF
        'MODISA':    BEGIN & MAPS=['NES'] & PERIODS=['W','D3','M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA'] & IPRODS=['GRAD_SST'] & DR=DATERANGE & END
        'OC-SEAWIFS-1KM':   BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['D','M','MONTH','A','ANNUAL'] & PRODS=['GRAD_CHL-BOA'] & IPRODS=['GRAD_CHL'] & DR=DATERANGE & END
        'OC-SA-1KM':        BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['M','MONTH','A','ANNUAL'] & PRODS=['GRAD_CHL-BOA'] & IPRODS=['GRAD_CHL'] & DR=DATERANGE & END
       
        'SST-MODISA-1KM':   BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA'] & IPRODS=['GRAD_SST'] & DR=['2002','2020'] & END
        'SST-MODIST-1KM':   BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA'] & IPRODS=['GRAD_SST'] & DR=['2000','2020'] & END
        'SST-AT-1KM':       BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA'] & IPRODS=['GRAD_SST'] & DR=['2000','2020'] & END

        'SST-AVHRR-4KM':    BEGIN & MAPS=['NWA','NES','NEC'] & PERIODS=['M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA']     & IPRODS=['GRAD_SST'] & DR=['1980','2020'] & END
        'SST-MUR-1KM':      BEGIN & MAPS=['NES','NWA','NEC'] & PERIODS=['D','W','D3','M','MONTH','A','ANNUAL'] & PRODS=['GRAD_SST-BOA']     & IPRODS=['GRAD_SST'] & DR=['2000','2020'] & END
      ENDCASE

      IF N_ELEMENTS(MAPS) GT 1 AND N_ELEMENTS(PERIODS) EQ 1 THEN PERIODS = REPLICATE(PERIODS[0],N_ELEMENTS(MAPS))
      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
      MAPIN = 'L3B2'
      FOR R=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        AMAP = MAPS(R)
        IF R_PRODS EQ 1 THEN PRODS = REVERSE(PRODS)
        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          PROD = PRODS[P]
          PROD = PRODS[P]
          APROD = VALIDS('PRODS',PROD)
          AALG  = VALIDS('ALGS',PROD)
          IF PROD NE 'GRAD_CHL-BOA' AND PROD NE 'GRAD_SST-BOA' THEN MESSAGE, 'ERROR: Invalid input product for PNGS_MAKE_FRONTS'
          
          DIR_SAVE  = !S.FRONTS + DATASET + SL + MAPIN + SL + 'SAVE'   + SL + PROD + SL
          DIR_STATS = !S.FRONTS + DATASET + SL + MAPIN + SL + 'STATS'  + SL + PROD + SL
          DIR_PNGS  = !S.FRONTS + DATASET + SL + AMAP  + SL + 'PNGS'   + SL + PROD + SL
          DIR_COMPS = !S.FRONTS + DATASET + SL + AMAP  + SL + 'COMPOSITES'   + SL + PROD + SL
          DIR_DAILY = !S.FRONTS + DATASET + SL + AMAP  + SL + 'DAILY_COMPOSITES'   + SL + PROD + SL
          DIR_TEST,[DIR_STATS,DIR_PNGS]
  
          FOR S=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
            FILES = []
            PERIOD = PERIODS[S]
            
            FILES = FILE_SEARCH(DIR_SAVE+PERIOD+'_*'+'*'+PROD+'*.SAV',COUNT=BFILES)
            IF BFILES EQ 0 AND PERIOD EQ 'S' THEN  FILES = FILE_SEARCH(DIR_SAVE+'D'+'_*'+'*'+PROD+'*.SAV',COUNT=BFILES)  ; ===> Look for 'D' files if no 'S' files are found
            IF BFILES EQ 0 THEN FILES = FILE_SEARCH(DIR_STATS+PERIOD+'_*'+'*'+PROD+'*.SAV',COUNT=BFILES)
  
            FILES = DATE_SELECT(FILES,DR,COUNT=BFILES)
            IF BFILES EQ 0 THEN CONTINUE ; ===> CONTINUE IF NO FILES ARE FOUND
  
            PRINT, 'MAKING ' + PERIOD + ' PNGS FOR ' + STRJOIN(DATASET,'_') + ' - ' + AMAP + ' (' + PROD + ')' + ' ' + STRJOIN(DR,'-')
            DN = DATE_NOW(/GMT)
  
            FILE_LABEL=FILE_LABEL_MAKE(FILES[0])
            IF DATASET EQ 'OC-SA-1KM' THEN FILE_LABEL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),'SA')
            
            IF PERIOD EQ 'D' OR PERIOD EQ 'S' THEN DIR_OUT = DIR_DAILY ELSE DIR_OUT=DIR_COMPS
            IF PERIOD EQ 'M' THEN BEGIN
              YRS = YEAR_RANGE('2002','2016')
              FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
                YF  = DATE_SELECT(FILES,YEAR=YRS(Y))
                PNGS_MAKE_FRONTS, YF, PRODS=IPRODS,DIR_OUT=DIR_OUT, BUFFER=1, DELAY=0, COMPOSITE=1, OVERWRITE=OVERWRITE 
              ENDFOR
            ENDIF    
            
            IF KEY(DO_COMPOSITES) THEN PNGS_MAKE_FRONTS, FILES, PRODS=IPRODS,DIR_OUT=DIR_OUT, BUFFER=1, DELAY=0, COMPOSITE=1, OVERWRITE=OVERWRITE 
            IF PERIOD EQ 'D' OR PERIOD EQ 'S' AND ~KEY(DO_DAILY) THEN CONTINUE ; DON'T NEED TO MAKE INDIVIDUAL DAILY GRAD_MAG IMAGES
            PNGS_MAKE_FRONTS, FILES, PRODS=IPRODS, DIR_OUT=DIR_PNGS, MAP_OUT=AMAP, BUFFER=0, DELAY=0, OVERWRITE=OVERWRITE
                                  
          ENDFOR ; PERIODS
        ENDFOR ; PRODS
      ENDFOR ; MAPS
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; SENSORS
  ENDIF ; DO_PNGS_FRONTS         
     
     
; *******************************************************
  IF KEY(DO_COMPARE_PLOTS) THEN BEGIN
; *******************************************************
    SNAME = DO_COMPARE_PLOTS
    SWITCHES,DO_COMPARE_PLOTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,BUFFER=BUFFER,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    FILE_PERIODS = ['D','W','M','A']
    TITLE_PERIODS = ['Daily', 'Weekly', 'Monthly', 'Annual']
    WINX = 790
    WINY = 1024
    CTITLE = ' '
    YMINOR=1
    FONTSIZE = 8.5
    SYMSIZE = 0.45
    THICK = 2
    FONT = 0
    YMARGIN = [0.3,0.3]
    XMARGIN = [4,1]
    COLORA = 'ORANGE_RED'
    COLORB = 'DARK_BLUE'
    COLORXY = !COLOR.(WHERE(TAG_NAMES(!COLOR) EQ COLORB))

    IF DATASETS EQ [] THEN DATASETS = ['OC-MODISA','OC-SEAWIFS','OC-OCCCI','PP-MODISA','PP-SEAWIFS','PP-OCCCI','OC-VIIRS','SST-MODIS','SST-MODISA','SST-MODIST','OC-MODISA','OC-VIIRS']
    IF BATCH_DATASET NE [] THEN DATASETS = BATCH_DATASET
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
   
    FOR NTH=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[NTH]
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      SERVER = !S.DATASETS
      REP = '' ; REPRO
      PREFIX = ''
      DR = DATERANGE
      CASE DATASET OF
        'OC-CZCS':        BEGIN & MAPS=['NEC'] & DIR_PRODS=['MIN_OC'] & END
        'OC-OCTS':        BEGIN & MAPS=['NEC'] & DIR_PRODS=['MIN_OC'] & END
        'OC-SEAWIFS':     BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_CHL','MIN_OC'] & END
        'OC-MODISA':      BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_CHL','MIN_OC'] & END
        'OC-MODIST':      BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_CHL'] & END
        'OC-MERIS':       BEGIN & MAPS=['NEC'] & DIR_PRODS=['MIN_OC'] & END
        'OC-VIIRS':       BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_CHL'] & END
        'OC-SA':          BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_CHL','CHLOR_A-PAN'] & OSERVER=!S.DATASETS & DATASET=['SEAWIFS','MODISA'] & END

        'SST-MODIS':      BEGIN & MAPS=['NEC'] & DIR_PRODS=['NC_SST'] & END
        'SST-AVHRR':      BEGIN & MAPS=['NEC'] & DIR_PRODS=['SST']    & END
        'SST-MUR':        BEGIN & MAPS=['NEC'] & DIR_PRODS=['SST']    & END
        'SST-MODISA':     BEGIN & MAPS=['NEC'] & DIR_PRODS='NC_SST' & DATASET='SST-MODIS-1KM' & PREFIX='A' & END
        'SST-MODIST':     BEGIN & MAPS=['NEC'] & DIR_PRODS='NC_SST' & DATASET='SST-MODIS-1KM' & PREFIX='T' & END
        'SST-AT':         BEGIN & MAPS=['NEC'] & DIR_PRODS='NC_SST' & DATASET='SST-MODIS-1KM' & PREFIX='X' & END

        'PP-MODISA':      BEGIN & MAPS=['NEC'] & DATASETA=[''] & DATASETB=[''] & REPROA=['C'] & REPROB=['C'] & PRODSA=LIST(['PPD-VGPM2','PPD-VGPM2','PPD-VGPM2_PAR','PPD-VGPM2_PAR','PPD-VGPM2_INTPAR']) & PRODSB=LIST(['PPD-VGPM2_INTPAR','PPD-VGPM2_FILLED','PPD-VGPM2_INTPAR','PPD-VGPM2_FILLED','PPD-VGPM2_FILLED']) & END
        'PP-SEAWIFS':     BEGIN & MAPS=['NEC'] & DATASETA=[''] & DATASETB=[''] & REPROA=['C'] & REPROB=['C'] & PRODSA=LIST(['PPD-VGPM2','PPD-VGPM2','PPD-VGPM2_PAR','PPD-VGPM2_PAR','PPD-VGPM2_INTPAR']) & PRODSB=LIST(['PPD-VGPM2_INTPAR','PPD-VGPM2_FILLED','PPD-VGPM2_INTPAR','PPD-VGPM2_FILLED','PPD-VGPM2_FILLED']) & END
        'PP-SA':          BEGIN & MAPS=['NEC'] & DIR_PRODS=['PPD']          & OSERVER=!S.PP & DATASET=['PP-SEAWIFS-1KM','PP-MODISA-1KM'] & END
        'PP-MODISA_PAN':  BEGIN & MAPS=['NEC'] & DIR_PRODS=['PPSIZE','PPD'] & END
        'PP-SEAWIFS_PAN': BEGIN & MAPS=['NEC'] & DIR_PRODS=['PPSIZE','PPD'] & END
        'PP-SA_PAN':      BEGIN & MAPS=['NEC'] & DIR_PRODS=['PPD']          & OSERVER=!S.PP & DATASET=['PP-SEAWIFS_PAN-1KM','PP-MODISA_PAN-1KM'] & END

;     
;          'SEAWIFS15':  BEGIN & DATASETA='OC-SEAWIFS-1KM'          & DATASETB='OC-SEAWIFS-1KM'     & YEARS=[1997,2010] & PROD=LIST(['CHLOR_A-OCI', 'CHLOR_A-OCX'],['CHLOR_A-OCI', 'CHLOR_A-PAN'],['CHLOR_A-OCX','CHLOR_A-PAN']) & END
;          'MODISA15':   BEGIN & DATASETA='OC-MODISA-1KM'           & DATASETB='OC-MODISA-1KM'      & YEARS=[2002,2017] & PROD=LIST(['CHLOR_A-OCI', 'CHLOR_A-OCX'],['CHLOR_A-OCI', 'CHLOR_A-PAN'],['CHLOR_A-OCX','CHLOR_A-PAN']) & END
;          'SEAWIFSD3':  BEGIN & DATASETA='OC-SEAWIFS-MLAC'         & DATASETB='OC-SEAWIFS-1KM'     & YEARS=[1997,2010] & PROD=LIST(['CHLOR_A-OC4', 'CHLOR_A-OCI'],'CHLOR_A-PAN','PAR') & END
;          'MODISAD3':   BEGIN & DATASETA='OC-MODIS-LAC'            & DATASETB='OC-MODISA-1KM'      & YEARS=[2002,2017] & PROD=LIST(['CHLOR_A-OC3M','CHLOR_A-OCI'],'CHLOR_A-PAN','PAR') & END
;          'SEAWIFS':    BEGIN & DATASETA='OC-SEAWIFS-MLAC'         & DATASETB='OC-SEAWIFS-1KM'     & YEARS=[1997,2010] & PROD=LIST('MICRO-PAN',['CHLOR_A-OC4', 'CHLOR_A-OCI'],['CHLOR_A-OC4', 'CHLOR_A-OCX'],'MICRO-PAN','MICRO_PERCENTAGE-PAN','NANOPICO-PAN','NANOPICO_PERCENTAGE-PAN','CHLOR_A-PAN','PAR') & END
;          'MODISA':     BEGIN & DATASETA='OC-MODIS-LAC'            & DATASETB='OC-MODISA-1KM'      & YEARS=[2002,2017] & PROD=LIST(['CHLOR_A-OC3M','CHLOR_A-OCI'],['CHLOR_A-OC3M','CHLOR_A-OCX'],'MICRO-PAN','MICRO_PERCENTAGE-PAN','NANOPICO-PAN','NANOPICO_PERCENTAGE-PAN','CHLOR_A-PAN','PAR') & END
;          'SA':         BEGIN & DATASETA='OC-SEAWIFS-1KM'          & DATASETB='OC-MODISA-1KM'      & YEARS=[1997,2017] & PROD=['CHLOR_A-OCI','PAR','CHLOR_A-PAN'] & END
;          'SAD3':       BEGIN & DATASETA='OC-SEAWIFS-1KM'          & DATASETB='OC-MODISA-1KM'      & YEARS=[1997,2017] & PROD=['CHLOR_A-OCI','PAR','CHLOR_A-PAN'] & END
;          'AVHRR':      BEGIN & DATASETA='SST-AVHRR-5.2'           & DATASETB='SST-AVHRR-4KM'      & YEARS=[1981,2014] & PROD=['SST'] & END
;          'SST':        BEGIN & DATASETA='SST-AVHRR-4KM'           & DATASETB='SST-MUR-1KM'        & YEARS=[1997,2017] & PROD=LIST(['SST-N_11UM','SST']) & END
;          'SSTD3':      BEGIN & DATASETA='SST-PAT-4'               & DATASETB='SST-MUR-1KM'        & YEARS=[1997,2017] & PROD=LIST(['SST-N_11UM','SST']) & END
;          'PP-SEAWIFS': BEGIN & DATASETA='PP-SEAWIFS-PAT-MLAC'     & DATASETB='PP-SEAWIFS-1KM'     & YEARS=[1997,2010] & PROD=LIST(['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE'],'PPD-VGPM2') & END
;          'PP-SEAPAN':  BEGIN & DATASETA='PP-SEAWIFS_PAN-PAT-MLAC' & DATASETB='PP-SEAWIFS_PAN-1KM' & YEARS=[1997,2010] & PROD=LIST('PPD-VGPM2',['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE']) & END
;          'PP-MODIS':   BEGIN & DATASETA='PP-MODIS-PAT-LAC'        & DATASETB='PP-MODISA-1KM'      & YEARS=[2002,2017] & PROD=LIST('PPD-VGPM2',['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE']) & END
;          'PP-MODPAN':  BEGIN & DATASETA='PP-MODIS_PAN-PAT-LAC'    & DATASETB='PP-MODISA_PAN-1KM'  & YEARS=[2002,2017] & PROD=LIST('PPD-VGPM2',['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE']) & END
;          'PP-SEA15':   BEGIN & DATASETA='PP-SEAWIFS_PAN-1KM'      & DATASETB='PP-SEAWIFS-1KM'     & YEARS=[1997,2010] & PROD=['PPD-VGPM2','MICROPP','MICROPP_PERCENTAGE','NANOPICOPP','NANOPICOPP_PERCENTAGE'] & END
;          'PP-MOD15':   BEGIN & DATASETA='PP-MODISA_PAN-1KM'       & DATASETB='PP-MODISA-1KM'      & YEARS=[2002,2017] & PROD=['PPD-VGPM2','MICROPP','MICROPP_PERCENTAGE','NANOPICOPP','NANOPICOPP_PERCENTAGE'] & END
;          'PP-SA':      BEGIN & DATASETA='PP-SEAWIFS-1KM'          & DATASETB='PP-MODISA-1KM'      & YEARS=[1997,2017] & PROD=['PPD-VGPM2','MICROPP','MICROPP_PERCENTAGE','NANOPICOPP','NANOPICOPP_PERCENTAGE'] & END
;          'PP-SAP':     BEGIN & DATASETA='PP-SEAWIFS_PAN-1KM'      & DATASETB='PP-MODISA_PAN-1KM'  & YEARS=[1997,2017] & PROD=['PPD-VGPM2','MICROPP','MICROPP_PERCENTAGE','NANOPICOPP','NANOPICOPP_PERCENTAGE'] & END
;          'PP-SEA18':   BEGIN & DATASETA='PP/R2017/SEAWIFS'        & DATASETB='PP/SEAWIFS'         & YEARS=[1997,2010] & PROD=LIST(['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE'],'PPD-VGPM2') & END
;          'PP-MOD18':   BEGIN & DATASETA='PP/R2017/MODISA'         & DATASETB='PP/MODISA'          & YEARS=[1997,2010] & PROD=LIST(['MICROPP-MARMAP_PAN_VGPM2','MICROPP'],['MICROPP_PERCENTAGE-MARMAP_PAN_VGPM2','MICROPP_PERCENTAGE'],['NANOPICOPP-MARMAP_PAN_VGPM2','NANOPICOPP'],['NANOPICOPP_PERCENTAGE-MARMAP_PAN_VGPM2','NANOPICOPP_PERCENTAGE'],'PPD-VGPM2') & END
;          'PP-MINTERP': BEGIN & DATASETA='PP-MODISA'               & DATASETB='PP-MODISA'          & YEARS=[2002,2017] & PROD=LIST(['PPD-VGPM2_PAR','PPD-VGPM2_INTPAR']) & END
;          'PP-SINTERP': BEGIN & DATASETA='PP-SEAWIFS'              & DATASETB='PP-SEAWIFS'         & YEARS=[1997,2010] & PROD=LIST(['PPD-VGPM2_PAR','PPD-VGPM2_INTPAR']) & END
        
        ELSE: DATASET = ''
      ENDCASE
      IF DATASET[0] EQ '' THEN CONTINUE
      
      DSENSOR = VALIDS('SENSORS',DATASET)
      IF ANY(D_MAPS)  THEN IF D_MAPS[NTH]  NE [] THEN MAPS = STR_BREAK(D_MAPS[NTH],',')
      IF KEY(R_MAPS)    THEN MAPS    = REVERSE(MAPS)
      IF STRJOIN(DR,'_') EQ '19780101_21001231' THEN DR = SENSOR_DATES(DSENSOR,/YEAR)
      X  = DATE_2JD(STRMID(DR,0,4)) & AX  = DATE_AXIS(X,/MONTH, /YY_YEAR,STEP_SIZE=4) & AYR = DATE_AXIS(X,/YEAR)
      XTICKNAMES = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))
      
      BRK = STR_BREAK(DATASET,'-')
      CASE BRK[0] OF
        'OC':  OUTDIR = !S.OC
        'SST': OUTDIR = !S.SST
        'PP':  OUTDIR = !S.PP
        ELSE:  OUTDIR = !S.DATASETS
      ENDCASE
      
        
      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
        MP = MAPS[M]
        CASE MP OF
          'NEC': BEGIN & SUBAREA = 'NES_EPU_NOESTUARIES' & NAMES = ['SS','GOM','GB','MAB'] & SUBTITLES = ['Scotian Shelf','Gulf of Maine','Georges Bank','Mid-Atlantic Bight'] & END
        ENDCASE
        SHP_FILES = FLS(!S.IDL_SHAPEFILES + SUBAREA + SL + REGION + '.shp')
        STRUCT = READ_SHPFILE(SUBAREA, MAPP=MP, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
        SHPS=STRUCT.(0)
        OUTLINE = []
        FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
          POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES[F]),/NULL)
          IF POS EQ [] THEN CONTINUE
          OUTLINE = [OUTLINE,SHPS.(POS).OUTLINE]
        ENDFOR

DATASETA = ''
DATASETB = ''
        
        FOR DTH=0, N_ELEMENTS(DATASETA)-1 DO BEGIN
          IF DATASETA(DTH) EQ '' THEN SETA = DATASET ELSE SETA = DATASETA(DTH)
          IF DATASETB(DTH) EQ '' THEN SETB = DATASET ELSE SETB = DATASETB(DTH)
          PRODA = PRODSA(DTH) & PRODB = PRODSB(DTH)
          REPA  = REPROA(DTH) & REPB  = REPROB(DTH)
          BRKA = STR_BREAK(SETA,'-') & BRKB = STR_BREAK(SETB,'-')
          IF N_ELEMENTS(BRKA) EQ 1 THEN SDATASETA = DATASETA ELSE SDATASETA = BRKA[1] 
          IF N_ELEMENTS(BRKB) EQ 1 THEN SDATASETB = DATASETB ELSE SDATASETB = BRKB[1]
          
          FOR PTH=0, N_ELEMENTS(PRODA)-1 DO BEGIN
            PRODS = [PRODA(PTH),PRODB(PTH)]
            OPRODS = PRODS
    
            CASE VALIDS('PRODS',PRODS[0]) OF
              'CHLOR_A'             : BEGIN & DYRANGE='0,10'   & WYRANGE='0,3'    & MYRANGE='0,3'   & AYRANGE='0,2'    & SCALE='NARROW' & LOG=1 & TPROD='Chlorophyll'          & ANOM='RATIO' & END
              'MICRO'               : BEGIN & DYRANGE='0,5'    & WYRANGE='0,3'    & MYRANGE='0,3'   & AYRANGE='0,2'    & SCALE='NARROW' & LOG=1 & TPROD='Micro Chlorophyll'    & ANOM='RATIO' & END
              'NANOPICO'           : BEGIN & DYRANGE='0,8'    & WYRANGE='0,3'    & MYRANGE='0,3'   & AYRANGE='0,2'    & SCALE='NARROW' & LOG=1 & TPROD='NanoPico Chlorophyll' & ANOM='RATIO' & END
              'MICRO_PERCENTAGE'    : BEGIN & DYRANGE='0,40'   & WYRANGE='0,40'   & MYRANGE='O,40'  & AYRANGE='0,40'   & SCALE=''       & LOG=0 & TPROD='Micro CHL (%)' & ANOM = 'DIF' & END
              'NANOPICO_PERCENTAGE': BEGIN & DYRANGE='0,80'   & WYRANGE='0,80'   & MYRANGE='O,80'  & AYRANGE='0,80'   & SCALE=''       & LOG=0 & TPROD='NanoPico CHL (%)' & ANOM = 'DIF' & END
              'PAR'                 : BEGIN & DYRANGE='0,80'   & WYRANGE='0,80'   & MYRANGE='0,80'  & AYRANGE='30,40'  & SCALE=''       & LOG=0 & TPROD='PAR'                  & ANOM='DIF'   & END
              'PPD'                 : BEGIN & DYRANGE='0,4'    & WYRANGE='0,4'    & MYRANGE='0,4'   & AYRANGE='0,2'    & SCALE='NARROW' & LOG=1 & TPROD='Primary Production'   & ANOM='RATIO' & END
              'MICROPP'           : BEGIN & DYRANGE='0,1'    & WYRANGE='0,1'    & MYRANGE='0,1'   & AYRANGE='0,0.5'  & SCALE='NARROW' & LOG=1 & TPROD='Microplankton PP'     & ANOM='RATIO' & END
              'NANOPICOPP'        : BEGIN & DYRANGE='0,3'    & WYRANGE='0,3'    & MYRANGE='0,3'   & AYRANGE='0,1'    & SCALE='NARROW' & LOG=1 & TPROD='NanoPico PP'          & ANOM='RATIO' & END
              'MICROPP_PERCENTAGE'       : BEGIN & DYRANGE='0,40'   & WYRANGE='0,40'   & MYRANGE='O,40'  & AYRANGE='0,40'   & SCALE=''       & LOG=0 & TPROD='Micro PP (%)' & ANOM = 'DIF' & END
              'NANOPICOPP_PERCENTAGE'    : BEGIN & DYRANGE='0,80'   & WYRANGE='0,80'   & MYRANGE='O,80'  & AYRANGE='0,80'   & SCALE=''       & LOG=0 & TPROD='NanoPico PP (%)' & ANOM = 'DIF' & END
              'SST'                 : BEGIN & DYRANGE='-1,30'  & WYRANGE='-1,30'  & MYRANGE='-1,30' & AYRANGE='-1,30'  & SCALE='LOW'    & LOG=0 & TPROD='Temperature'          & ANOM='DIF'   & END
              'RRS_443'             : BEGIN & DYRANGE='0,.008' & WYRANGE='0,.004' & MYRANGE='0,.004'& AYRANGE='0,.004' & SCALE=''       & LOG=0 & TPROD='RRS 443'              & ANOM='DIF'   & END
            ENDCASE

            DSETS = [SETA,SETB]
            SSETS = [SDATASETA,SDATASETB]
            REPS  = [REPA,REPB]
            NPROD = PRODS

            FOR D=0, N_ELEMENTS(DSETS)-1 DO BEGIN
              NDIR = []
              RDSET = REPS[D] + '_' + DSETS[D]
              CASE RDSET OF
                'R2012_OC-SEAWIFS-MLAC':         BEGIN & LEGEND='SeaWiFS 2010'     & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=[]                          & STARGET='MEAN'  & END
                'R2012_OC-MODIS-LAC':            BEGIN & LEGEND='MODISA 2010'      & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=[]                          & STARGET='MEAN'  & END
                'C_OC-SEAWIFS':                  BEGIN & LEGEND='SeaWiFS 2015'     & DIR=!S.OC     +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & NDIR=REPLACE(DIR,'STATS'+SL+PRODS[D],'NC') & END
                'C_OC-MODISA':                   BEGIN & LEGEND='MODISA 2015'      & DIR=!S.OC     +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & NDIR=REPLACE(DIR,'STATS'+SL+PRODS[D],'NC') & END
                'R2012_PP-SEAWIFS-PAT-MLAC':     BEGIN & LEGEND='SeaWiFS 2010'     & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='MEAN'  & END
                'R2012_PP-SEAWIFS_PAN-PAT-MLAC': BEGIN & LEGEND='SeaWiFS Pan 2010' & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='MEAN'  & END
                'C_PP-SEAWIFS':                  BEGIN & LEGEND='SeaWiFS 2015'     & DIR=!S.PP    +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_PP-SEAWIFS_PAN-1KM':          BEGIN & LEGEND='SeaWiFS Pan 2015' & DIR=!S.PP    +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_PP-SEAWIFS':                  BEGIN & LEGEND='SeaWiFS 2015'     & DIR=!S.ARCHIVE+SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'R2012_PP-MODIS_PAN-PAT-LAC':    BEGIN & LEGEND='MODISA Pan 2010'  & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='MEAN'  & END
                'R2012_PP-MODIS-PAT-LAC':        BEGIN & LEGEND='MODISA OCx 2010'  & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='MEAN'  & END
                'C_PP-MODISA':                   BEGIN & LEGEND='MODISA 2015'      & DIR=!S.PP    +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_PP-MODISA_PAN':               BEGIN & LEGEND='MODISA Pan 2015'  & DIR=!S.PP    +SSETS[D]+SL+'L3B2'+SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_SST-MUR-1KM':                 BEGIN & LEGEND='MUR 2016'         & DIR=!S.SST    +SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_SST-AVHRR':                   BEGIN & LEGEND='AVHRR 2016'       & DIR=!S.SST    +SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='STATS' & END
                'C_SST-PAT-4':                   BEGIN & LEGEND='SST PAT'          & DIR=!S.ARCHIVE+SSETS[D]+SL+MP    +SL+'STATS'+SL+PRODS[D]+SL & SDIR=REPLACE(DIR,'STATS','SAVE') & STARGET='MEAN'  & END
              ENDCASE

              IF DSETS[D] EQ 'OC-SEAWIFS'      AND PRODS[D] EQ 'CHLOR_A-OCI' THEN NPROD[D] = 'CHL'
              IF DSETS[D] EQ 'OC-MODIS-LAC'    AND PRODS[D] EQ 'CHLOR_A-OCI' THEN NPROD[D] = 'CHL'
              IF DSETS[D] EQ 'OC-SEAWIFS'      AND PRODS[D] EQ 'CHLOR_A-OCX' THEN NPROD[D] = 'CHL'
              IF DSETS[D] EQ 'OC-MODIS-LAC'    AND PRODS[D] EQ 'CHLOR_A-OCX' THEN NPROD[D] = 'CHL'
              IF DSETS[D] EQ 'OC-SEAWIFS'      AND PRODS[D] EQ 'PAR'         THEN NPROD[D] = 'PAR'
              IF DSETS[D] EQ 'OC-MODIS-LAC'    AND PRODS[D] EQ 'PAR'         THEN NPROD[D] = 'PAR'
              IF DSETS[D] EQ 'OC-SEAWIFS'      AND HAS(PRODS[D],'RRS')       THEN NPROD[D] = 'RRS'
              IF DSETS[D] EQ 'OC-MODISA'       AND HAS(PRODS[D],'RRS')       THEN NPROD[D] = 'RRS'
              IF DSETS[D] EQ 'OC-SEAWIFS-MLAC' AND PRODS[D] EQ 'CHLOR_A-OCI' THEN DIR = REPLACE(DIR,PRODS[D],'CHLOR_A-OC4')
              IF DSETS[D] EQ 'OC-SEAWIFS-MLAC' AND PRODS[D] EQ 'CHLOR_A-OCX' THEN DIR = REPLACE(DIR,PRODS[D],'CHLOR_A-OC4')
              IF DSETS[D] EQ 'OC-MODIS-LAC'    AND PRODS[D] EQ 'CHLOR_A-OCI' THEN DIR = REPLACE(DIR,PRODS[D],'CHLOR_A-OC3M')
              IF DSETS[D] EQ 'OC-MODIS-LAC'    AND PRODS[D] EQ 'CHLOR_A-OCX' THEN DIR = REPLACE(DIR,PRODS[D],'CHLOR_A-OC3M')
              
              IF HAS(DATASET,'D3') THEN BEGIN
                STARGET = 'INTERP*'
                SDIR = []
                NDIR = []
                IF DSETS[D] EQ 'OC-SEAWIFS-MLAC' THEN DIR = REPLACE(DIR,'STATS'+SL+PRODS[D],'TS_IMAGES'+SL+PRODS[D]+SL+'SAVE')
                IF DSETS[D] EQ 'OC-SEAWIFS'      THEN DIR = REPLACE(DIR,'STATS','INTERP_SAVE')
                IF DSETS[D] EQ 'OC-MODIS-LAC'    THEN DIR = REPLACE(DIR,'STATS'+SL+PRODS[D],'TS_IMAGES'+SL+PRODS[D]+SL+'SAVE')
                IF DSETS[D] EQ 'OC-MODISA'       THEN DIR = REPLACE(DIR,'STATS','INTERP_SAVE')
                IF DSETS[D] EQ 'SST-PAT-4'       THEN DIR = REPLACE(DIR,'STATS'+SL+PRODS[D],'TS_IMAGES'+SL+PRODS[D]+SL+'SAVE')
                IF DSETS[D] EQ 'SST-MUR-1KM'     THEN SDIR = REPLACE(DIR,'STATS','SAVE')
                PNGTAG = '-INTERP_D3'
              ENDIF ELSE PNGTAG = ''

              IF NPROD[D] EQ 'MICRO-PAN' OR NPROD[D] EQ 'NANOPICO-PAN' OR NPROD[D] EQ 'MICRO_PERCENTAGE' OR NPROD[D] EQ 'NANOPICO_PERCENTAGE' THEN SDIR = REPLACE(SDIR,NPROD[D],'PHYTO')
              IF NPROD[D] EQ 'MICROPP' OR NPROD[D] EQ 'NANOPICOPP' OR NPROD[D] EQ 'MICROPP_PERCENTAGE' OR NPROD[D] EQ 'NANOPICOPP_PERCENTAGE' THEN SDIR = REPLACE(SDIR,['SAVE',NPROD[D]],['STATS','PPD_SIZE-MAR'])

              FILES = FLS(DIR+[FILE_PERIODS]+'_*'+STARGET+'.SAV*',DATERANGE=YEARS)
              IF NDIR NE [] THEN FILES = [FILES,FLS(NDIR+'*'+NPROD[D]+'.nc',DATERANGE=YEARS)]
              IF SDIR NE [] THEN FILES = [FILES,FLS(SDIR+[FILE_PERIODS]+'_*.SAV*',DATERANGE=YEARS)]
    
              IF D EQ 0 THEN FILESA = FILES  ELSE FILESB = FILES
              IF D EQ 0 THEN LEGA   = LEGEND ELSE LEGB   = LEGEND
              IF D EQ 0 THEN DIRA   = REPLACE(DIR,['STATS',PRODS[D]+SL],['SUBAREAS','']) ELSE DIRB = REPLACE(DIR,['STATS',PRODS[D]+SL],['SUBAREAS',''])
    
              CASE PRODS[D] OF
                'PPD-VGPM2_INTPAR': PRODS[D] = 'PPD-VGPM2'
                'PPD-VGPM2_FILLED': PRODS[D] = 'PPD-VGPM2'
                'PPD-VGPM2_PAR':    PRODS[D] = 'PPD-VGPM2'
                ELSE: PRODS[D] = PRODS[D]
              ENDCASE

              ANN = FLS(DIR+'ANNUAL_*' + ['MEAN','STATS']+'.SAV*')
              IF D EQ 0 THEN ANNA = ANN ELSE ANNB = ANN
              IF DSETS[D] EQ 'OC-SEAWIFS-1KM' OR DATASET EQ 'OC-MODISA-1KM' THEN PRODS[D] = REPLACE(PRODS[D],['MICRO-PAN','NANOPICO-PAN'],['MICRO','NANO'])
            ENDFOR ; DSETS
            IF SAME(DSETS) AND ~SAME(OPRODS) THEN BEGIN & LEGA = OPRODS[0] & LEGB = OPRODS[1] & ENDIF
            IF (PRODS_READ(PRODS[1])).LOG EQ 1 THEN LOGLOG = 1 ELSE LOGLOG = 0 & IF KEY(LOGLOG) THEN ANOM='RATIO' ELSE ANOM='DIF'

            FA = PARSE_IT(FILESA[0],/ALL) & FB = PARSE_IT(FILESB[0],/ALL)
            PRINT, 'Extracting data for DATASET: ' + DATASET + ' (PROD = ' + PRODS[0] + ')'
            SAVEFILEA = DIRA + INAME_MAKE(SENSOR=FA[0].SENSOR, SATELLITE=FA[0].SATELLITE, METHOD=FA[0].METHOD, COVERAGE=FA[0].COVERAGE, MAP=FA[0].MAP) + '-' + OPRODS[0] + '-SUBAREAS.SAV'
            SAVEFILEB = DIRB + INAME_MAKE(SENSOR=FB[0].SENSOR, SATELLITE=FB[0].SATELLITE, METHOD=FB[0].METHOD, COVERAGE=FB[0].COVERAGE, MAP=FB[0].MAP) + '-' + OPRODS[1] + '-SUBAREAS.SAV'
            SUBAREAS_EXTRACT,FILESA,PROD=PRODS[0],SUBREGIONS=SUBREGIONS,SHP_FILES=SHP_FILES,DIR_OUT=DIR_OUT,DIR_SHP=DIR_SHP,SAVEFILE=SAVEFILEA,INIT=INIT,VERBOSE=VERBOSE
            SUBAREAS_EXTRACT,FILESB,PROD=PRODS[1],SUBREGIONS=SUBREGIONS,SHP_FILES=SHP_FILES,DIR_OUT=DIR_OUT,DIR_SHP=DIR_SHP,SAVEFILE=SAVEFILEB,INIT=INIT,VERBOSE=VERBOSE
    
   ;         IF FILE_MAKE(SAVEFILEA,REPLACE(SAVEFILEA,[DIRA,'.SAV'],[DIR_OUT,'.CSV'])) EQ 1 THEN FILE_COPY, REPLACE(SAVEFILEA,'.SAV','.CSV'), DIR_OUT, /OVERWRITE
   ;         IF FILE_MAKE(SAVEFILEB,REPLACE(SAVEFILEB,[DIRB,'.SAV'],[DIR_OUT,'.CSV'])) EQ 1 THEN FILE_COPY, REPLACE(SAVEFILEB,'.SAV','.CSV'), DIR_OUT, /OVERWRITE
    
            ADATA = IDL_RESTORE(SAVEFILEA) & OKA = WHERE(TAG_NAMES(ADATA) EQ 'AMEAN')
            BDATA = IDL_RESTORE(SAVEFILEB) & OKB = WHERE(TAG_NAMES(BDATA) EQ 'AMEAN')
            ;    OUTLINE_SUBS = STRUCT.(0).(WHERE(TAG_NAMES(STRUCT.(0)) EQ SUBAREA + '_OUTLINE',/NULL))
            
            
            DIR_PLOTS = OUTDIR + SSETS[0] + SL + MP + SL + 'COMPARE_PLOTS' + SL + PRODS[0] + SL  ; ODATASET is the location of the output DATASET, which may be different from DATASET
            DIR_OLD   = OUTDIR + SSETS[0] + SL + MP + SL + 'COMPARE_PLOTS' + SL + 'REPLACED' + SL + PRODS[0] + SL
            DIR_TEST, [DIR_PLOTS,DIR_OLD]
            
            FOR CTH=0, N_ELEMENTS(NAMES)-1 DO BEGIN
              ANAME = STRUPCASE(NAMES(CTH))
              SHP = STRUCT_GET(SHPS,ANAME)
              IF SHP EQ [] THEN STOP
              SHP_BINS = SHP.SUBS
              SHP_OUTLINE = SHP.OUTLINE
              ADAT = ADATA[WHERE(ADATA.SUBAREA EQ ANAME)]
              BDAT = BDATA[WHERE(BDATA.SUBAREA EQ ANAME)]
              PERIODS = [ADAT.PERIOD,BDAT.PERIOD] & PERIODS = PERIODS[SORT(PERIODS)] & PERIODS = PERIODS[UNIQ(PERIODS)]
              IF SAME([SETA,SETB]) THEN TDATASET = SETA ELSE TDATASET = SETA + '_' + SETB
              IF SAME(OPRODS) THEN TPRODS = OPRODS[0] ELSE TPRODS = OPRODS[0] + '_' + OPRODS[1]
              PNGFILE = DIR_PLOTS + TDATASET + '-' + MP + '-NES_ECOREGIONS-' + ANAME + '-' + TPRODS + PNGTAG + '.PNG'
    
              IF FILE_MAKE([SAVEFILEA,SAVEFILEB],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
              IF FILE_TEST(PNGFILE) THEN FILE_COPY,PNGFILE, DIR_OLD+TDATASET+'-'+MP+'-NES_ECOREGIONS-'+ANAME+'-'+TPRODS+PNGTAG+'-REPLACED_'+DATE_NOW(/DATE_ONLY)+'.PNG',/VERBOSE,/OVERWRITE
              
              XTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODA) + ' Algorithm (' + VALIDS('SENSORS',DATASETA) + ')'
              YTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODB) + ' Algorithm (' + VALIDS('SENSORS',DATASETB) + ')'
    
              CDATA = REPLICATE(STRUCT_2MISSINGS(CREATE_STRUCT('PERIOD','','PERIOD_CODE','','DATA_A',0.0,'DATA_B',0.0)),N_ELEMENTS(PERIODS))
              CDATA.PERIOD = PERIODS
              CDATA.PERIOD_CODE = VALIDS('PERIOD_CODES',PERIODS)
              OK = WHERE_MATCH(CDATA.PERIOD,ADAT.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT) & CDATA[OK].DATA_A = ADAT(VALID).(OKB)
              OK = WHERE_MATCH(CDATA.PERIOD,BDAT.PERIOD,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT) & CDATA[OK].DATA_B = BDAT(VALID).(OKB)
    
              W = WINDOW(DIMENSIONS=[WINX,WINY],BUFFER=BUFFER)
              TITLE = SUBTITLES(CTH) + ' ' + TPROD
              TXT = TEXT(0.5,0.97,TITLE,ALIGNMENT=0.5,FONT_SIZE=14)
              OK = WHERE(CDATA.PERIOD_CODE EQ 'D',COUNTD)
    
              PLOT_PERIODS = ['D','W','M','A']
              POSITION = LIST([0.08,0.81,0.96,0.96],$
                [0.08,0.65,0.96,0.80],$
                [0.08,0.49,0.96,0.64],$
                [0.08,0.33,0.96,0.48])
              TPOS = [.940,.780,.620,460]
              RANGES = [DYRANGE,WYRANGE,MYRANGE,AYRANGE]
              FOR N=0, N_ELEMENTS(PLOT_PERIODS)-1 DO BEGIN
                AA = CDATA[WHERE(CDATA.PERIOD_CODE EQ PLOT_PERIODS[N] AND CDATA.DATA_A NE MISSINGS(0.0),/NULL)]
                BB = CDATA[WHERE(CDATA.PERIOD_CODE EQ PLOT_PERIODS[N] AND CDATA.DATA_B NE MISSINGS(0.0),/NULL)]
                YRANGE = STR_SEP(RANGES[N],','); NICE_RANGE(MINMAX([AA.DATA_A,BB.DATA_B]))
                IF N EQ N_ELEMENTS(PLOT_PERIODS)-1 THEN XTICKNAME=AX.TICKNAME ELSE XTICKNAME=XTICKNAMES
                PD = PLOT(AX.JD,YRANGE,YTITLE=UNITS(TPROD,/NO_NAME),FONT_SIZE=FONTSIZE,YMINOR=YMINOR,XMAJOR=AX.TICKS,XMINOR=3,XTICKNAME=XTICKNAME,XTICKVALUES=AX.TICKV,POSITION=POSITION[N],/NODATA,/CURRENT)
                POS = PD.POSITION
                XTICKV = PD.XTICKVALUES & OK = WHERE(JD_2MONTH(XTICKV) EQ '01',COUNT)
                FOR G=1,COUNT-1 DO GR = PLOT([XTICKV(OK(G)),XTICKV(OK(G))],YRANGE,COLOR='GREY',/OVERPLOT,XRANGE=AX.JD,YRANGE=YRANGE)
                IF AA NE [] THEN P1 = PLOT(PERIOD_2JD(AA.PERIOD),AA.DATA_A,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=6,COLOR=COLORA,SYMBOL='CIRCLE',SYM_SIZE=0.45,/SYM_FILLED)
                IF BB NE [] THEN P2 = PLOT(PERIOD_2JD(BB.PERIOD),BB.DATA_B,XRANGE=AX.JD,YRANGE=YRANGE,/OVERPLOT,/CURRENT,LINESTYLE=6,COLOR=COLORB,SYMBOL='CIRCLE',SYM_SIZE=0.45)
                TD = TEXT(.095,POS(3)-0.02,TITLE_PERIODS[N],FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
                TA = TEXT(.095,POS(3)-0.035,LEGA,FONT_COLOR=COLORA,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
                TB = TEXT(.095,POS(3)-0.05,LEGB,FONT_COLOR=COLORB,FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD')
              ENDFOR
    
              POS = LIST([0.095, 0.175,0.2675,0.295],$
                [0.3175,0.175,0.49,  0.295],$
                [0.54,  0.175,0.7125,0.295],$
                [0.7625,0.175,0.935, 0.295])
              XTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODA) + '!C(' + VALIDS('SENSORS',DATASETA) + ')'
              YTITLE = UNITS(TPROD) + ' - ' + VALIDS('ALGS',PRODB) + '!C(' + VALIDS('SENSORS',DATASETB) + ')'
              PERIOD_CODES = ['D','W','M','A']
              FOR LTH=0, N_ELEMENTS(PERIOD_CODES)-1 DO BEGIN
                PAL_36
                APOS = POS(LTH)
                STATS_POS = [APOS[0]-0.01 + 0.012, APOS(3)+0.005 - 0.06]
                OKXY = WHERE(CDATA.PERIOD_CODE EQ PERIOD_CODES(LTH) AND CDATA.DATA_A NE MISSINGS(0.0) AND CDATA.DATA_B NE MISSINGS(0.0),COUNTXY)
                IF COUNTXY EQ 0 THEN CONTINUE
                RANGE = NICE_RANGE(MINMAX([CDATA(OKXY).DATA_A,CDATA(OKXY).DATA_B]))
                P = PLOTXY_NG(CDATA(OKXY).DATA_A,CDATA(OKXY).DATA_B,DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[5,6,7,11],POSITION=APOS,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
                  XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=NICE_RANGE(RANGE),YRANGE=NICE_RANGE(RANGE),/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
                  STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE,BUFFER=BUFFER) ; XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,
                TD = TEXT(APOS(2)-0.005,.18,TITLE_PERIODS(LTH),FONT_SIZE=FONTSIZE+2,FONT_STYLE='BOLD',ALIGNMENT=1.0)
              ENDFOR
              TX = TEXT(0.5, 0.16,  LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
              TY = TEXT(0.065,0.23, LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)
    
              PAL='PAL_BR'
              IPOSITIONS = LIST([0.09,0.0,0.27,0.15],$
                [0.31,0.0,0.49,0.15],$
                [0.53,0.0,0.71,0.15],$
                [0.7625,0.025,0.935,0.15])
    
              IF ANNA EQ [] OR ANNB EQ [] THEN GOTO, SKIP_IMAGES
    
              DA = STRUCT_READ(ANNA,STRUCT=ASTRUCT,MAP_OUT=MP) & IF N_TAGS(ASTRUCT) EQ 1 THEN ASTRUCT=ASTRUCT.(0)
              DB = STRUCT_READ(ANNB,STRUCT=BSTRUCT,MAP_OUT=MP) & IF N_TAGS(BSTRUCT) EQ 1 THEN BSTRUCT=BSTRUCT.(0)
    
              ADAT = MAPS_BLANK(ASTRUCT.MAP) & BDAT = ADAT & RDAT = ADAT
              ADAT(SHP_BINS) = DA(SHP_BINS) & BDAT(SHP_BINS) = DB(SHP_BINS)
              OKXY = WHERE(ADAT NE MISSINGS(0.0) AND BDAT NE MISSINGS(0.0))
              IF KEY(LOGLOG) THEN RDAT(OKXY) = ADAT(OKXY)/BDAT(OKXY) ELSE RDAT(OKXY) = ADAT(OKXY) - BDAT(OKXY)
    
              ABYT = PRODS_2BYTE(ADAT,PROD=ASTRUCT.PROD,MP=ASTRUCT.MAP,/ADD_COAST)        ; & ABYT(OUTLINE_SUBS) = 0
              BBYT = PRODS_2BYTE(BDAT,PROD=BSTRUCT.PROD,MP=BSTRUCT.MAP,/ADD_COAST)        ; & BBYT(OUTLINE_SUBS) = 0
              RBYT = PRODS_2BYTE(RDAT,PROD=ANOM,MP=ASTRUCT.MAP,/ADD_COAST,LAND_COLOR=254) ; & RBYT(OUTLINE_SUBS) = 0
    
              POSITION = IPOSITIONS[0] & PX = WINX*(POSITION[0]-0.01) & PY = WINY*(POSITION(3)-0.005)
              APNG = IMAGE(ABYT,RGB_TABLE=CPAL_READ('PAL_BR'),POSITION=POSITION,/CURRENT)
              PRODS_COLORBAR, ASTRUCT.PROD, IMG=APNG, LOG=LOGLOG, ORIENTATION=1, TITLE=CTITLE, FONT_SIZE=8, POSITION=[PX,PY-140,PX+5,PY], TEXTPOS=0, /DEVICE, PAL='PAL_BR'
    
    
              POSITION = IPOSITIONS[1] & PX = WINX*(POSITION[0]-0.01) & PY = WINY*(POSITION(3)-0.005)
              BPNG = IMAGE(BBYT,RGB_TABLE=CPAL_READ('PAL_BR'),POSITION=POSITION,/CURRENT)
              PRODS_COLORBAR, BSTRUCT.PROD, IMG=BPNG, LOG=LOGLOG, ORIENTATION=1, TITLE=CTITLE, FONT_SIZE=8, POSITION=[PX,PY-140,PX+5,PY], TEXTPOS=0, /DEVICE, PAL='PAL_BR'
    
              POSITION = IPOSITIONS(2) & PX = WINX*(POSITION[0]-0.01) & PY = WINY*(POSITION(3)-0.005)
              RPNG = IMAGE(RBYT,RGB_TABLE=CPAL_READ('PAL_ANOMG'),POSITION=POSITION,/CURRENT)
              PRODS_COLORBAR, ANOM, IMG=RPNG, LOG=LOGLOG, ORIENTATION=1, TITLE=CTITLE, FONT_SIZE=8, POSITION=[PX,PY-140,PX+5,PY], TEXTPOS=0, /DEVICE, PAL='PAL_ANOMG'
    
              TX = TEXT(0.095,0.14,LEGA,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0)
              TY = TEXT(0.315,0.14,LEGB,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0)
              TA = TEXT(0.535,0.14,'Anomaly !C'+ANOM,FONT_SIZE=FONTSIZE+1,VERTICAL_ALIGNMENT=1.0)
    
              POSITION=IPOSITIONS(3)
              STATS_POS = [POSITION[0] + 0.012, POSITION(3) - 0.06]
              OKXY = WHERE(ADAT NE MISSINGS(0.0) AND BDAT NE MISSINGS(0.0))
              XSCALE = FLOAT([(PRODS_READ(ASTRUCT.PROD)).LOWER,(PRODS_READ(ASTRUCT.PROD)).UPPER])
              YSCALE = FLOAT([(PRODS_READ(BSTRUCT.PROD)).LOWER,(PRODS_READ(BSTRUCT.PROD)).UPPER])
              P = PLOTXY_NG(ADAT(OKXY),BDAT(OKXY),DECIMALS=3,LOGLOG=LOGLOG,/QUIET,/CURRENT,MODEL='RMA',PARAMS=[5,6,7,11],POSITION=POSITION,CHARSIZE=FONTSIZE,PSYM='CIRCLE',$
                XTITLE='',YTITLE='',SYM_COLOR=COLORXY,SYMSIZE=SYMSIZE,THICK=THICK,XRANGE=XSCALE,YRANGE=YSCALE,/GRID_NONE,MARGIN=MARGIN,STATS_CHARSIZE=STATS_CHARSIZE,$
                STATS_POS=STATS_POS,/ONE2ONE,ONE_COLOR=253,ONE_THICK=ONE_THICK,ONE_LINESTYLE=ONE_LINESTYLE)
              GONE, ADAT
              GONE, BDAT
              TX = TEXT(0.85,0.002,LEGA,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE)
              TY = TEXT(0.73,0.085,LEGB,ALIGNMENT=0.5,FONT_SIZE=FONTSIZE,ORIENTATION=90)
    
              SKIP_IMAGES:
              P, 'Writing ' + PNGFILE
              W.SAVE,PNGFILE,RESOLUTION=600
              W.CLOSE
            ENDFOR ; NAMES   
          ENDFOR ; PRODA 
        ENDFOR ; DATASETA
      ENDFOR ; MAPS    
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR ; DATASETS    
  ENDIF ; DO_COMPARE_PLOTS
     
     
  ;*******************************
  IF KEY(DO_FILE_PLOTS) THEN BEGIN
    ;*******************************
    SNAME = 'DO_FILE_PLOTS'
    SWITCHES,DO_FILE_PLOTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
    LOGLUN=LUN
    
    DATASETS = ['OC-SEAWIFS-9KM','OC-MODISA-4KM','OC-MERIS-4KM','OC-VIIRS-4KM','SST-MODIS-4KM','SST-MUR-1KM','SST-AVHRR-4KM']
    SUBDIR   = ['L3B9',          'L3B4',         'L3B4',        'L3B4',        'L3B4',         'L4B4',       'L3B4']
    PRODS    = LIST(['CHL','RRS','PAR','IOP','KD490'],['CHL','RRS','PAR','IOP','KD_490'],['CHL','RRS','PAR','IOP','KD_490'],['CHL','RRS','PAR','IOP','KD_490'],['T2*NSST','T2*SST4','A2*NSST','A2*SST4'],['MUR'],['SST'])

    BUFFER = 0
    AX = YEAR_RANGE(1997,2020)
    XRANGE = MM(AX)
    YRANGE = [0,400]
    COLORS = ['RED','BLUE','GREEN','ORANGE','CYAN']
    HT = 140
    SP = 20
    DIMS=[800,HT*N_ELEMENTS(DATASETS)+(SP*2)]
    W = WINDOW(DIMENSIONS=DIMS,BUFFER=BUFFER)
    FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      DIR = !S.DATASETS + DATASETS[N] + SL + SUBDIR[N] + SL + 'NC' + SL
      DATASET = STRSPLIT(DATASETS[N],'-',/EXTRACT)
      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
      LABEL = DATASET[1]
      BOT = DIMS[1]-((N+1)*HT)-SP
      POSITION = [50, BOT, DIMS[0]-50, BOT+HT]
      PROD = PRODS[N]
      PL = BARPLOT([1997,2020],[0,2],YRANGE=YRANGE,XRANGE=XRANGE,/NODATA,POSITION=POSITION,/CURRENT,/DEVICE,NBARS=N_ELEMENTS(PROD))
      FOR P=0, N_ELEMENTS(PROD)-1 DO BEGIN
        FILES = FILE_SEARCH(DIR + '*' + PROD[P] + '*',COUNT=COUNT)
        IF COUNT EQ 0 THEN CONTINUE
        FP = PARSE_IT(FILES)
        IF DATASETS[N] EQ 'SST-AVHRR-4KM' OR DATASETS[N] EQ 'SST-MUR-1KM' THEN FP.YEAR_START = STRMID(FP.NAME,0,4)
        SETS = WHERE_SETS(FP.YEAR_START)
        PP = BARPLOT(FIX(SETS.VALUE),SETS.N,INDEX=P,NBARS=N_ELEMENTS(PROD),/OVERPLOT,/CURRENT,FILL_COLOR=COLORS[P],POSITION=POSITION,/DEVICE,XRANGE=XRANGE,YRANGE=YRANGE)
        P, 'Number of ' + PROD[P] + ' files in ' + DIR
        FOR Y=0, N_ELEMENTS(SETS)-1 DO P, SETS[Y].VALUE + '-' + NUM2STR(SETS[Y].N)
      ENDFOR
      PLUN, LUN, 'Finished ' + SNAME + ' for ' + DATASET + '...', 1
    ENDFOR
    WAIT, 10
    W.CLOSE
  ENDIF ; DO_FILE_PLOTS    
     
     
  GOTO, DONE
; DONE WITH UPDATED CODE BLOCKS - GOTO END




; *******************************************************************************************************************************************
  IF DO_SST_MERGE GE 1 THEN BEGIN
; *******************************************************************************************************************************************
    PRINT, 'Running: DO_SST_MERGE'
    OVERWRITE = DO_SST_MERGE EQ 2

    
    DATE_CHECK    = JD_2DATE(JD_ADD(DATE_2JD(DATE_NOW()),-30,/DAY)) ; Date when the merged maps were made.  Use this date to "check" only the more recent files.
    CHECK_ALL     = 0                ; IF CHECK_ALL EQUALS 1 THEN "CHECK" ALL OF THE FILES.
    
    
    IF KEY(L3_REVERSE_MAPS)  THEN REVERSE_MAPS = 1      
    IF N_ELEMENTS(L3_DATE_RANGE) EQ 2 THEN DATERANGE = L3_DATE_RANGE ELSE DATERANGE=['19960101','20201231']
    IF DATERANGE[0] LT '19960101' THEN DATERANGE[0] = '19960101'
    IF DATERANGE[1] LT '19960101' THEN DATERANGE[1] = '19960101'
    DP = DATE_PARSE(DATERANGE)
    
    AT_MAP_IN      =  LIST(['L3B4'],     ['L3B4'],     ['L3B4','L3B4','L3B4','L3B4'], ['L3B4'])
    PATH_MAP_IN    =  LIST(['GEQ'],      ['GEQ'],      ['GEQ', 'NEC', 'NAFO', 'EC'],  ['GEQ'])    
    MAP_OUT        =  LIST(['L3B4'],     ['L3B4'],     ['GEQ', 'NEC', 'NAFO', 'EC'],  ['GEQ'])
    DIRS_OUT       =  !S.DATASETS+['SST-MODIS-4','SST-MODIS-4','SST-PAT-4',                   'SST-PAT-4']+SL         
    SENSORS_OUT    =       ['AT11',       'AT4',        'PAT11',                       'PAT4']      
    DO_MERGE       =       [ 1,            0,            1,                            0]
    
    FOR N=0, N_ELEMENTS(DO_MERGE)-1 DO BEGIN
      IF DO_MERGE[N] EQ 0 AND NOT KEY(OVERWRITE) THEN CONTINUE
      IF DATERANGE[0] EQ DATERANGE[1] THEN CONTINUE 
      IF KEY(REVERSE_MAPS) THEN AT_MAP   = REVERSE(AT_MAP_IN[N])   ELSE AT_MAP   = AT_MAP_IN[N]
      IF KEY(REVERSE_MAPS) THEN PATH_MAP = REVERSE(PATH_MAP_IN[N]) ELSE PATH_MAP = PATH_MAP_IN[N]      
      IF KEY(REVERSE_MAPS) THEN MAPS_OUT = REVERSE(MAP_OUT[N])     ELSE MAPS_OUT = MAP_OUT[N]
      FOR M=0, N_ELEMENTS(MAP_OUT[N])-1 DO BEGIN
        ATMAP = AT_MAP[M]
        PMAP  = PATH_MAP[M]        
        OMAP  = MAPS_OUT[M]
        
        DIR_PATHFINDER = DISK+'SST-AVHRR-4'+SL+PMAP +SL+'SAVE'+SL
        DIR_AQUA_TERRA = DISK+'SST-MODIS-4'+SL+ATMAP+SL+'SAVE'+SL
        DIR_OUT        = DIRS_OUT[N] + OMAP + SL
        SST_MERGE,DIR_PATHFINDER=DIR_PATHFINDER,DIR_AQUA_TERRA=DIR_AQUA_TERRA,DATE_RANGE=DATERANGE,SENSOR_OUT=SENSORS_OUT[N],DIR_OUT=DIR_OUT,MAP_OUT=OMAP,OVERWRITE=OVERWRITE    
      
        FILES = FILE_SEARCH(DIR_OUT + 'SAVE' + SL + 'SST-N_11UM' + SL + 'D_*'+STRMID(SENSORS_OUT[N],0,2)+'*.SAVE')        
        FILES = DATE_SELECT(FILES,DATERANGE[0],DATERANGE[1])        
        IF FILES EQ [] THEN CONTINUE
        IF KEY(REVERSE_FILES) THEN FILES = REVERSE(FILES)        
        IF NOT KEY(CHECK_ALL) THEN BEGIN
          MTIME_FILES = GET_MTIME(FILES,/JD)
          MTIME_CHECK = DATE_2JD(DATE_CHECK)
          FILES = FILES[WHERE(MTIME_FILES GT MTIME_CHECK,COUNT)] ; Only check the files created after the DATE_CHECK date
          IF COUNT EQ 0 THEN CONTINUE
        ENDIF
        FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
          AFILE = FILES[F]
          PRINT, 'Checking : ' + AFILE
          D = STRUCT_READ(AFILE,STRUCT=S,ERROR=ERROR)
          IF ERROR EQ 1 THEN BEGIN
            PRINT, 'ERROR GETTING DATA FROM FILE, DELETING ...', AFILE
            FILE_DELETE, AFILE
            CONTINUE
          ENDIF
          IF VALIDS('MAPS',AFILE) NE OMAP  THEN STOP
          IF S.MAP               NE OMAP  THEN STOP
          IF S.FILE_NAME         NE AFILE THEN STOP
          
          FP = PARSE_IT(AFILE)
          IF FP.PERIOD NE S.PERIOD THEN STOP
          DP = VALIDS('PERIODS',FP.PERIOD)
          FI = PARSE_IT(S.INFILE)
          IF WHERE(FI.PERIOD NE S.PERIOD) GE 0 THEN STOP              
        ENDFOR          
      ENDFOR
    ENDFOR
  
  ENDIF ;IF DO_SST_MERGE GE 1 THEN BEGIN
 
;; *******************************************************************************************************************************************
;  IF DO_OC_MERGE GE 1 THEN BEGIN
;; *******************************************************************************************************************************************
;    , 'DO_OC_MERGE'
;    OVERWRITE = DO_OC_MERGE EQ 2    
;    MAP_OUTS  = ['GEQ','NEC','EC']
;    DO_MAP    = [1,     0,    0]
;    
;    IF N_ELEMENTS(L3_DATE_RANGE) EQ 2 THEN DATERANGE = L3_DATE_RANGE ELSE DATERANGE=['19970101','20201231']
;    DP = DATE_PARSE(DATERANGE)
;        
;    FOR MTH = 0, N_ELEMENTS(MAP_OUTS)-1 DO BEGIN
;      IF DO_MAP(MTH) EQ 0 THEN CONTINUE
;      MAP_OUT = MAP_OUTS(MTH)
;      CASE MAP_OUT OF 
;        'GEQ': BEGIN        
;          DIRS_OUT      = DISK+['OC-SEA_AQU-9_4','OC-SAM-9_4']+SL         
;          SENSORS_OUT   =      ['SEA_AQU',       'SAM'       ]      
;          DO_MERGE      =      [ 1,               0          ]
;        
;          DIR_SEAWIFS   = DISK+'OC-SEAWIFS-9'  +SL+'L3B' +SL+'SAVE'+SL
;          DIR_MODIS     = DISK+'OC-MODIS-4'    +SL+'L3B4'+SL+'SAVE'+SL
;          DIR_MERIS     = DISK+'OC-MERIS-4'    +SL+'L3B4'+SL+'SAVE'+SL
;          PRODS         = ['CHLOR_A-OC','CHLOR_A-GSM','PAR','A_CDOM_443-GSM']
;          COVERAGE      = '9_4'
;          MAP_OUT       = 'GEQ'
;        END                    
;        'NEC': BEGIN
;          DIRS_OUT      = DISK+['OC-SEA_AQU-LAC','OC-SAM-LAC','OC-AQU_MER-LAC']+SL         
;          SENSORS_OUT   =      ['SEA_AQU',       'SAM',       'AQU_MER']      
;          DO_MERGE      =      [ 0,               0,           0]
;                            
;          DIR_SEAWIFS   = DISK+'OC-SEAWIFS-MLAC'+SL+'NEC'+SL+'STATS'+SL
;          DIR_MODIS     = DISK+'OC-MODIS-LAC'   +SL+'NEC'+SL+'STATS'+SL
;          PRODS         = ['CHLOR_A-PAN','CHLOR_A-OC','CHLOR_A-GSM','PAR','A_CDOM_443-GSM']
;          COVERAGE      = 'LAC'
;          MAP_OUT       = 'NEC'
;        END
;        'EC': BEGIN
;          DIRS_OUT      = DISK+['OC-SEA_AQU-LAC','OC-SAM-LAC','OC-AQU_MER-LAC']+SL         
;          SENSORS_OUT   =      ['SEA_AQU',       'SAM',       'AQU_MER']      
;          DO_MERGE      =      [ 0,               0,           0]
;                  
;          DIR_SEAWIFS   = DISK+'OC-SEAWIFS-MLAC'+SL+'EC'+SL+'STATS'+SL
;          DIR_MODIS     = DISK+'OC-MODIS-LAC'   +SL+'EC'+SL+'STATS'+SL
;          PRODS         = ['CHLOR_A-OC','CHLOR_A-PAN','CHLOR_A-GSM','PAR','A_CDOM_443-GSM']
;          COVERAGE      = 'LAC'
;          MAP_OUT       = 'EC'
;        END
;      ENDCASE  
;          
;      FOR N=0, N_ELEMENTS(DO_MERGE)-1 DO IF DO_MERGE[N] GE 1 THEN $       
;      SEA_AQU_MERGE,DIR_SEAWIFS=DIR_SEAWIFS,DIR_MODIS=DIR_MODIS,DIR_MERIS=DIR_MERIS,DIR_OUT=DIRS_OUT[N],SENSOR_OUT=SENSORS_OUT[N],COVERAGE=COVERAGE,MAP_OUT=MAP_OUT,DATE_RANGE=DATERANGE,PRODS=PRODS,OVERWRITE=OVERWRITE
;    ENDFOR  
;    , 'DO_OC_MERGE'
;  
;  ENDIF ;IF DO_OC_MERGE GE 1 THEN BEGIN
;  
;
;;*******************************
;  IF KEY(DO_SUBAREAS) THEN BEGIN
;;*******************************
;    SNAME = 'DO_SUBAREAS'
;    PRINT, 'Running: ' + SNAME
;    SWITCHES,DO_SUBAREAS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DATERANGE=DATERANGE,DATASETS=DATASETS
;    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
;    
;    DATASETS = ['OC_OCTS','OC-MODIS-4', 'OC-SEAWIFS-9','SST-MODIS-4','OC-CZCS-4','OC-MERIS-4']
;    PROD = 'CHLOR_A' 
;    AMAP = 'SMI'
;    FOR NTH = 0,N_ELEMENTS(DATASETS)-1 DO BEGIN
;      DATASET = DATASETS[NTH]
;      DIR_STATS = DISK + DATASET + SL + AMAP + SL + 'STATS'     + SL + PROD + SL
;      DIR_OUT = DIR_STATS  + 'SUBAREA' + SL
;      DIR_TEST,DIR_OUT
;      FILES = FLS(DIR_STATS,'M_*.SAV')
;      MAPS = 'NEC'
;      OUT = DIR_OUT + 'SUBAREAS_EXTRACT.CSV'
;      IF FILE_MAKE(FILES,OUT,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE 
;     
;      SUBAREAS_EXTRACT,FILES,MAPS=MAPS,DIR_SHP=DIR_SHP,DIR_OUT=DIR_OUT,AROUND=AROUND     
;      SUBAREAS_PLOT ;,FILES,MAPS=MAPS,DIR_SHP=DIR_SHP,DIR_OUT=DIR_OUT,AROUND=AROUND
;      
;    ENDFOR ; FOR NTH = 0,N_ELEMENTS(DATASETS)-1 DO BEGIN
;  ENDIF ; DO_SUBAREAS
;  
;  
;  ; ********************************
;  IF KEY(DO_MERGE_FRONTS) THEN BEGIN
;    ; ********************************
;
;    SNAME = 'DO_MERGE_FRONTS'
;    SWITCHES,DO_MERGE_FRONTS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,R_PRODS=R_PRODS,DPRODS=D_PRODS,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
;    IF DATERANGE[0] EQ DEFAULT_DATERANGE[0] AND DATERANGE[1] EQ DEFAULT_DATERANGE[1] THEN DATERANGE = GET_DATERANGE(BATCH_DATERANGE)
;
;    SENSORS = []
;    IF DATASETS EQ [] THEN BEGIN
;      DO_SA_1        = 1 & IF KEY(DO_SA_1)       THEN DATASETS = [DATASETS,'SA']
;      DO_SAT_1       = 1 & IF KEY(DO_SAT_1)      THEN DATASETS = [DATASETS,'SAT']
;      DO_MODIS_SST   = 1 & IF KEY(DO_MODIS_SST)  THEN DATASETS = [DATASETS,'AT']
;    ENDIF
;
;    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
;    FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
;      DATASET = DATASETS[N]
;      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
;      DR = DATERANGE
;      SENSOR  = VALIDS('SENSORS',DATASET)
;      SERVER = !S.DATASETS
;      PERIODS = 'D'
;      CASE DATASET OF
;        'OC-SA':  BEGIN & MAPS=['NWA','NES'] & PRODS=['GRAD_CHL-BOA'] & SENSORS=['SEAWIFS','MODISA']  & END
;        'OC-AT':  BEGIN & MAPS=['NWA','NES'] & PRODS=['GRAD_CHL-BOA'] & SENSORS=['MODISA', 'MODIST'] & END
;        'OC-SAT': BEGIN & MAPS=['NWA','NES'] & PRODS=['GRAD_CHL-BOA'] & SENSORS=['SEAWIFS','MODISA','MODIST']  & END
;        'SST-AT': BEGIN & MAPS=['NWA','NES'] & PRODS=['GRAD_SST-BOA'] & SENSORS=['MODISA', 'MODIST'] & END
;      ENDCASE
;
;      BRK = STR_BREAK(DATASET,'-')
;      DATASET = BRK[1]
;
;      IF ANY(D_MAPS)  THEN IF D_MAPS[N]  NE [] THEN MAPS = STR_BREAK(D_MAPS[N],',')
;      IF ANY(D_PRODS) THEN IF D_PRODS[N] NE [] THEN PRODS = STR_BREAK(D_PRODS[N],',')
;      IF ANY(D_PERIODS) THEN IF D_PERIODS[N] NE [] THEN PERIODS = STR_BREAK(D_PERIODS[N],',')
;      IF STRJOIN(DR,'_') EQ '19780101_21001231' THEN DR = SENSOR_DATES(VALIDS('SENSORS',DATASET))
;
;      IF KEY(R_MAPS) THEN MAPS = REVERSE(MAPS)
;      FOR M=0, N_ELEMENTS(MAPS)-1 DO BEGIN
;        AMAP = MAPS[M]
;        IF R_PRODS EQ 1 THEN PRODS = REVERSE(PRODS)
;        FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
;          PROD = PRODS[P]
;          PROD = PRODS[P]
;          APROD = VALIDS('PRODS',PROD)
;          AALG  = VALIDS('ALGS',PROD)
;          ;      IF VALIDS('PRODS',PROD) NE 'CHLOR_A_BOA' AND VALIDS('PRODS',PROD) NE 'GRAD_SST-BOA THEN STOP
;
;
;          FOR R=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
;            APER = PERIODS(R)
;            IF APER EQ 'D' THEN FILES = FILE_SEARCH(!S.FRONTS + SENSORS + SL + AMAP + SL + 'SAVE'  + SL + PRODS[P] + SL + '*' + AMAP + '*' + APROD + '*.SAV') $
;            ELSE FILES = FILE_SEARCH(!S.FRONTS + SENSORS + SL + AMAP + SL + 'STATS' + SL + PRODS[P] + SL + APER + '_*' + AMAP + '*' + PRODS[P] + '*STATS.SAV')
;            FILES = DATE_SELECT(FILES,DR,COUNT=BFILES)
;            IF BFILES EQ 0 THEN CONTINUE ; ===> CONTINUE IF NO FILES ARE FOUND
;
;            FP = FILE_PARSE(FILES)
;            IF SAME(FP.DIR) EQ 1 THEN CONTINUE ; ===> CONTINUE BECAUSE THERE ARE ONLY ONE SET OF FILES
;
;            ;DIR_SAVE = !S.FRONTS + [SENSORS] + SL + AMAP + SL + 'SAVE'      + SL + PROD + SL
;            DIR_OUT  = !S.FRONTS + DATASET   + SL + AMAP + SL + 'SAVE'      + SL + PROD + SL
;            DIR_OLD  = !S.FRONTS + DATASET   + SL + AMAP + SL + 'OLD_STATS' + SL + PROD + SL
;            DIR_TEST,[DIR_OUT,DIR_OLD]
;
;            PRINT, 'MAKING MERGED DAILY FRONTS FILES FROM ' + STRJOIN(SENSORS,' & ') + ' - ' + AMAP + ' (' + PROD + ')' + ' ' + STRJOIN(DR,'-')
;            DN = DATE_NOW(/GMT)
;
;            FILE_LABEL=FILE_LABEL_MAKE(FILES[0])
;            FILE_LABEL = REPLACE(FILE_LABEL,VALIDS('SENSORS',FILE_LABEL),SENSOR)
;            FORCE_STATS = 0
;            STATS_ARRAYS_FRONTS, FILES, DIR_OUT=DIR_OUT, PERIOD_CODE_OUT='D', FILE_LABEL=FILE_LABEL, FORCE_STATS=FORCE_STATS,  DO_STATS=STAT_TYPES, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
;
;          ENDFOR ; PERIODS
;          STATS_CLEANUP,DIR_STATS=DIR_OUT,DIR_OUT=DIR_OLD,/MOVE_FILES,DATERANGE=DR
;        ENDFOR ; PRODS
;      ENDFOR ; MAPS
;      PLUN, LUN, 'Starting ' + SNAME + ' for ' + DATASET + '...', 1
;    ENDFOR ; SENSORS
;
;  ENDIF ; DO_MERGE_FRONTS
;


  ;*********************************
  IF KEY(DO_MOVIES) THEN BEGIN
  ;*********************************
    SNAME = 'DO_MOVIES'
    PRINT,'THIS STEP MAKES A MOVIE FROM THE DAILY SAV FILES FOR QUICK INSPECTION & QA'
    
    DATASETS = ['OC_OCTS','OC-MODIS-4', 'OC-SEAWIFS-9','SST-MODIS-4','OC-CZCS-4','OC-MERIS-4']
    PROD = 'CHLOR_A' & AMAP = 'ROBINSON'
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,N_ELEMENTS(DATASETS)-1 DO BEGIN
      DATASET = DATASETS[NTH]
      PFILE,'DATASET ' + DATASET,/U
      DIR_IN = DISK + DATASET + SL + AMAP + SL + 'SAVE' + SL  + PROD + SL +'PSERIES' +SL+ 'INTERP_SAVE' 
      DIR_OUT = DIR_IN +SL + 'MOVIE' + SL
      DIR_TEST,DIR_OUT
      FILES = FLS(DIR_IN,'*.SAV')
      MOVIE_FILE = DIR_OUT + DATASET + '.AVI'
      IF NONE(FILES) THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      PNGS = FLS(DIR_OUT,'*.PNG')
     
      IF FILE_MAKE(FILES,PNGS,OVERWRITE=OVERWRITE) THEN $
        FILE_LOOP,FILES,'PRODS_2PNG',DIR_OUT=DIR_OUT,/BUFFER,/ADD_DATE_BAR
        
      IF FILE_MAKE(FILES,MOVIE_FILE,OVERWRITE=OVERWRITE) THEN BEGIN
        MOVIE,FILES,MOVIE_FILE=MOVIE_FILE
      ENDIF;IF FILE_MAKE(FILES,MOVIE_FILE,OVERWRITE=OVERWRITE) THEN BEGIN
    ENDFOR;FOR NTH = 0,N_ELEMENTS(DATASETS)-1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
   ; ,'DO_INTERP_MOVIE
  ENDIF;IF KEY(DO_INTERP_MOVIE) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||




  DONE:
  PLUN,  LUN, 'Finished ' + ROUTINE_NAME + ': ' + ' on: ' + systime() + ' on ' + !S.COMPUTER, 2
  IF ANY(LUN) THEN BEGIN
    FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
  ENDIF  
END; #####################  END OF ROUTINE ################################



