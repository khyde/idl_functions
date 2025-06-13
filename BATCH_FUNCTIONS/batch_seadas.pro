; $ID:	BATCH_SEADAS.PRO,	2022-08-17-14,	USER-KJWH	$
;+

PRO BATCH_SEADAS, SENSORS, RUN_WGET=RUN_WGET, GET_ANC=GET_ANC, RUN_L1S=RUN_L1S, RUN_SEADAS=RUN_SEADAS, RUN_L2BIN=RUN_L2BIN, SKIP_L2S=SKIP_L2S, DATERANGE=DATERANGE

; NAME: BATCH_SEADAS
;
; PURPOSE: This is a main BATCH program for sequential evaluation of level-L1A and L2 satellite data files
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
;  OPTIONAL KEYWORDS:
;    OC_SENSORS: The sensor name for the databases (e.g. MODISA, SEAWIFS, VIIRS)
;    RUN_WGET:   Set to download thumbnails for files with processing errors or are considered OUT-OF-AREA
;    GET_ANC:    Set to verify and download any missing ancillary files
;
; MODIFICATION HISTORY:
;   DEC 14, 2015 - K.J.W. HYDE - Copied and modified from ANALYSES_BATCH_L2
;   DEC 14, 2015 - KJWH: Added CHECK_FILE_LISTS step to make sure files found in the download lists are in the directories
;   APR 18, 2016 - KJWH: Added several updates and currently using to check the L2 LOG files, remove "bad" files, create processing lists, and update ancillary files
;   APR 19, 2016 - KJWH: Updated SeaWiFS ancillary check
;                        Fixed block to remove successfully created files from L1A_PROCESS
;   APR 20, 2016 - KJWH: Updated documentation
;                        Removed unnecessary blocks of code
;   MAY 10, 2016 - KJWH: Updated INIT block for the L1A files to loop through 60 days worth of files (longer searches resulted in errors).
;   MAY 11, 2016 - KWJH: Added option to run SEADAS from BATCH_SEADAS
;   JUL 22, 2016 - KJWH: Added steps to run the SEADAS l2bin program
;   JUL 25, 2016 - KJWH: Updated the LOGFILE output
;                        Added RUN_L2BIN keyword option
;   AUG 04, 2016 - KJWH: Added steps to add the list of input files as a GLOBAL attribute to the L3Bx files
;   AUG 18, 2016 - KJWH: Updated L3B directories
;   AUG 22, 2016 - KJWH: Now looking for errors when running the L2BIN step.  
;                        Will read the error log, move the bad file, and rerun the L2BIN step  
;   AUG 23, 2016 - KJWH: Read the l2log to see if any input files are missing, remove the missing file from the input list, and rerun the L2BIN step                      
;   AUG 24, 2016 - KJWH: Added steps to update the ATTRIBUTE information in the SA files
;                        Now using the "source" attribute to fill in the "input_files" variable
;   SEP 23, 2016 - KJWH: Updated L1A, L2 and L3 directories
;                        Now writing out an L3 ERROR file if unable to successfully create the L3B files (and now skips the L2BIN step if the L3 ERROR file is present)                     
;   OCT 04, 2016 - KJWH: Added DATERANGE keyword
;                        Updated the SENSORS names
;                        Added MODISA, MODIST, and AT sensor information
;                        Updated the TITLE, INSTRUMENT, and PLATFORM information that is written to the .nc files for the SA and AT sensors
;   NOV 08, 2016 - KJWH: Added steps to make sure old files are removed before moving the newly created files to the permanent directories 
;   NOV 10, 2016 - KJWH: Added SEAWIFS OUT-OF-AREA error catch       
;   DEC 06, 2016 - KJWH: Added SKIP_L2S keyword to skip the L2BIN block in order to quickly determine which L1A files need to be processed     
;   DEC 20, 2016 - KJWH: Updated the Ocean Color websites to HTTPS      
;   OCT 23, 2016 - KJWH: Now using  
;-
; ***************************
  ROUTINE_NAME='BATCH_SEADAS'
  PRINT, 'Running: '+ROUTINE_NAME

  ; ===> DELIMITERS
  SL    = PATH_SEP()

  ; ===> DEFAULTS
  IF NONE(SENSORS)    THEN SENSORS    = ['MODISA','MODIST','VIIRS','SEAWIFS','SMODIST','SMODISA'];,'SA','AT','SAT'] 
  IF NONE(RUN_L1S)    THEN RUN_L1S    = 1
  IF NONE(RUN_WGET)   THEN RUN_WGET   = 0
  IF NONE(GET_ANC)    THEN GET_ANC    = 0 
  IF NONE(RUN_SEADAS) THEN RUN_SEADAS = 0 
  IF NONE(RUN_L2BIN)  THEN RUN_L2BIN  = 0
  IF NONE(SKIP_L2S)   THEN SKIP_L2S   = 1
  IF NONE(DATERANGE)  THEN DATERANGE  = ['1978','2020']
  
  ; ===> REMOTE FTP LOCATIONS
  OC_CGI    = 'https://oceancolor.gsfc.nasa.gov/cgi/'
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/'

  ; ===> ANCILLARY INFO
  SEADAS_VERSION = '7.4.1'
  DIR_ANC = !S.SCRIPTS + 'SEADAS/seadas_anc/'
  ANC_DB  = '/usr/local/seadas/ocssw/run/var/ancillary_data.db' 
  ANC_SCR = '/usr/local/seadas/ocssw/run/scripts/'


  ; ===> MODISA LUTS INFO
  DIR_LUTS  = '/usr/local/seadas/ocssw/run/var/modisa/xcal/OPER/'
  DIR_PREV  = '/usr/local/seadas/ocssw/run/var/modisa/xcal/PREV/' & DIR_TEST, DIR_PREV
  MSL12 = '/usr/local/seadas/ocssw/run/data/hmodisa/msl12_defaults.par'
  
  
  ; ===> PARFILES
  PARDIR = !S.SCRIPTS + 'SEADAS/L2BIN_PAR/'
  
  ; ===> NARRAGANSETT 1KM PROCESSING BOUNDARIES
  LATMIN = 22.5 ; 17.92  (Updated 11/7/2016 - KHyde)
  LATMAX = 48.5 ; 55.4
  LONMIN = -82.5 ; -97.8
  LONMAX = -51.5; -43.8

  ; ===> LOOP THROUGH SENSORS
  FOR STH=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
    SENSOR = STRUPCASE(SENSORS(STH))
    SK_L1S=0 
    SUITES = ['CHL','RRS','PAR','KD490','IOP','POC']
    RESO = []
    CASE SENSOR OF
      'SA':      BEGIN & DATASET='OC/SA'      & PREFIX='Z' & REPRO_DATA='20150701' & L1NAME = 'L1A_LAC'     & SUFFIX='L2*OX'          & SUITES=['CHL','PAR'] & SK_L1S=1 & RESO=['2'] & END
      'SAT':     BEGIN & DATASET='OC/SAT'     & PREFIX='Y' & REPRO_DATA='20150701' & L1NAME = 'L1A_LAC'     & SUFFIX='L2*OX'          & SUITES=['CHL'] & SK_L1S=1 & RESO=['2','1'] & END
      'MODISA':  BEGIN & DATASET='OC/MODISA'  & PREFIX='A' & REPRO_DATE='20150701' & L1NAME = 'L1A_LAC'     & SUFFIX='L2_LAC_SUB_OC'  & SUITES=['CHL','POC','PIC','PAR','RRS','IOP'] & RESO='2' & THUMB = 'L2_LAC_OC'  & END
      'MODIST':  BEGIN & DATASET='OC/MODIST'  & PREFIX='T' & REPRO_DATE='20150701' & L1NAME = 'L1A_LAC'     & SUFFIX='L2_LAC_OC.nc'   & THUMB = 'L2_LAC_OC'  & SUITES=['CHL'] & SK_L1S=1 & RESO=['2'] & END
      'SEAWIFS': BEGIN & DATASET='OC/SEAWIFS' & PREFIX='S' & REPRO_DATE='20160401' & L1NAME = 'L1A_MLAC'    & SUFFIX='L2_MLAC_OC'     & SUITES=['CHL','POC','PAR','RRS','IOP'] & RESO='2' & THUMB = 'L2_MLAC_OC' & END
      
      'SMODISA': BEGIN & DATASET='SST/MODISA' & PREFIX='A' & REPRO_DATA='20150101' & L1NAME = ''            & SUFFIX='L2_LAC_SST4.nc' & SUITES='SST4' & SK_L1S=1 & SKIP_L2S=0 & END
      'SMODIST': BEGIN & DATASET='SST/MODIST' & PREFIX='T' & REPRO_DATA='20150101' & L1NAME = ''            & SUFFIX='L2_LAC_SST4.nc' & SUITES='SST4' & SK_L1S=1 & SKIP_L2S=0 & END
      'AT':      BEGIN & DATASET='SST/MODIS'  & PREFIX='X' & REPRO_DATA='20150101' & L1NAME = ''            & SUFFIX='L2_LAC_SST4.nc' & SUITES='SST4' & SK_L1S=1 & RESO=['2'] & END
       
      'CZCS':    BEGIN & DATASET='OC/CZCS'    & PREFIX='C' & REPRO_DATE='20160201' & L1NAME = ''            & SUFFIX=''               & SUITES = ['CHL','RRS','PAR'] & SK_L1S=1 & THUMB='L2_MLAC_OC' & END
      'OCTS':    BEGIN & DATASET='OC/OCTS'    & PREFIX='O' & REPRO_DATE='20200101' & L1NAME = ''            & SUFFIX='' & END
      'VIIRS':   BEGIN & DATASET='OC/VIIRS'   & PREFIX='V' & REPRO_DATE='20200101' & L1NAME = 'L1A_SNPP.nc' & SUFFIX='L2_OC_SUB'      & SUITES = ['CHL','RRS','PAR','PIC','POC','IOP'] & RESO='2' & THUMB='L2_SNPP_OC' & END
      'MERIS':   BEGIN & DATASET='OC/MERIS'   & PREFIX='M' & REPRO_DATE='20200101' & L1NAME = ''            & SUFFIX='' & END
    ENDCASE
    
    ; ===> DATES
    DT = DATE_NOW()
    D30 = JD_2DATE(JD_ADD(DATE_2JD(DT),-30,/DAY)) ;
    D90 = JD_2DATE(JD_ADD(DATE_2JD(DT),-90,/DAY)) ;

    DIR     = !S.DATASETS + DATASET + SL
    LDIR    = DIR + 'LOGS' + SL + ROUTINE_NAME + SL
    DIR1    = DIR + 'L1A' + SL
    DIR2    = DIR + 'L2'  + SL
    L2_DIR  = DIR2 + 'NC' + SL
    L2_TEMP = DIR2 + 'TEMP' + SL
    L2_BIN  = DIR2 + 'BIN_FILES' + SL 
    DIR_TEST, [LDIR,L2_BIN,L2_TEMP]

    ; ===> Open dataset specific log file
    LOGFILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log'
    OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180
    PRINTF, LUN & PRINTF, LUN, '******************************************************************************************************************'
    PRINTF,LUN,'Initializing BATCH_SEADAS log file for ' + DATASET + ' on: ' + systime()
    PRINTF, LUN, 'Checking ' + SENSOR + ' files...'

    IF KEY(RUN_L1S) EQ 0 OR SK_L1S EQ 1 THEN GOTO, L2BIN_CHECK
    
    ANC_DIR = DIR + 'ANCILLARY_LISTS' + SL         
    ANCLIST = ANC_DIR + 'ANCILLARY_VERIFIED.TXT'
    L1A_DIR = DIR1 + 'NC' + SL                     ; Permanent directory for the L1A .nc files
    L1A_PRO = DIR1 + 'PROCESS' + SL                ; Temporary directory to hold the files to be processed by L2GEN
    L1A_CLI = DIR1 + 'CLIMATOLOGY' + SL            ; Temporary directory for files processed with climatology ancillary data
    L1A_L30 = DIR1 + 'LAST_30DAYS' + SL            ; Temporary directory for the files collected over the last 30 days
    L1A_L90 = DIR1 + 'CHECK_LUTS' + SL             ; Temporary directory for the files waiting for refined LUTS (MODISA only)
    LOG_DIR = L2_DIR + 'LOGS'     + SL             ; Permanent directory for the L2GEN log files
    SUSPECT = DIR1 + 'SUSPECT' + SL                ; Directory for suspect files
    ERR_DIR = SUSPECT + 'PROCESSING_ERROR' + SL
    OOA_DIR = SUSPECT + 'OUT_OF_AREA' + SL
    CLI_DIR = SUSPECT + 'CLIMATOLOGY' + SL
    LUT_DIR = SUSPECT + 'OLD_LUTS'    + SL
    ANC_ERR = SUSPECT + 'ANCILLARY'   + SL
    THUMBS  = SUSPECT + 'THUMBNAILS'  + SL
    PERMAN  = SUSPECT + 'PERMANENT_ERROR' + SL
    GEO_DIR = SUSPECT + 'GEO_ERROR' + SL
    DIR_TEST, [ANC_DIR,ANC_DIR+'REPLACED'+SL,LOG_DIR,ERR_DIR,OOA_DIR,CLI_DIR,THUMBS,PERMAN,GEO_DIR,L2_BIN,L1A_CLI,ANC_ERR,L1A_L30,L1A_PRO]
    IF SENSOR EQ 'MODISA' THEN DIR_TEST, [L1A_L90,LUT_DIR]

    ; ===> If the SeaDAS processing creates new files, recheck the files
    SECOND_CHECK = 0
    RERUN_CHECK_FILES:
    IF SECOND_CHECK EQ 1 THEN PRINTF, LUN, 'Rechecking files after SeaDAS processing...'

    ; ===> Create NULL variables
    PROCESS_L1S       = []                                                             ; Create a list of files that need to be processed
    SUCCESSFUL_L2S    = []                                                             ; Create a list of files that were successfully processed
    CLIMATOLOGY       = [] & CLI_LOGS  = [] & SEADAS72 = []                            ; Create a list of climatologically, climatology logs and SeaDAS 7.2generated files
    PROCESSING_ERROR  = [] & GEO_ERROR = []                                            ; Create a list of suspect and geolocation error files
    OUT_OF_AREA       = [] & OOA_NAMES = []                                            ; Create a list of suspect out of area files
    L2GEN_OUT_OF_AREA = [] & L2O_NAMES = []

    ; ===> Look for accessory (GEO) files that should have been deleted after running l2gen
    GEOS = FILE_SEARCH(L2_DIR + '*GEO*', COUNT=COUNT_GEOS)
    IF COUNT_GEOS GE 1 THEN FILE_DELETE, GEOS, /VERBOSE
    
    ; ===> Look for GEO files in the L1A dir (common with the VIIRS data)
    GEOS = FILE_SEARCH(L1A_DIR + '*GEO*', COUNT=COUNT_GEOS)
    IF COUNT_GEOS GE 1 THEN FILE_DELETE, GEOS, /VERBOSE

    ; ===> Search for L1A files in the main L1 directory
    L1S = FILE_SEARCH(L1A_DIR + PREFIX + '*' + L1NAME + '*bz2', COUNT=COUNT_L1A)                          ; Only looking for .bz2 files in L1A_DIR
    IF SENSOR EQ 'VIIRS' THEN L1S = [L1S,FILE_SEARCH(L1A_DIR + PREFIX + '*' + L1NAME, COUNT=COUNT_L1A)]   ; VIIRS files are not zipped when downloaded so look for .nc files
    L1S = DATE_SELECT(L1S, DATERANGE,COUNT=COUNT_L1S)                                                     ; Subset the files based on the daterange
    FP = FILE_PARSE(L1S) & L1SUFFIX = STRMID(FP[0].NAME_EXT,STRPOS(FP[0].NAME_EXT,'.'))
    PRINTF, LUN, 'Found ' + NUM2STR(COUNT_L1S) + ' L1A files'
    L30 = DATE_SELECT(L1S,[D30,DT],COUNT=COUNT30) &  FP30 = FILE_PARSE(L30)                               ; Create a list of files from the past 30 days
    LOGS30 = L2_DIR + FP30.FIRST_NAME + '.LOG'                                                            ; Create LOG file names for the files from the past 30 days
    IF SENSOR EQ 'MODISA' THEN BEGIN
      L90 = DATE_SELECT(L1S,[D90,D30],COUNT=COUNT90) &  FP90 = FILE_PARSE(L90)                            ; Create a list of files from the past 90 days to check for the most recent LUTS
      LOGS90 = L2_DIR + FP90.FIRST_NAME + '.LOG'                                                          ; Create LOG file names for the files from the past 90 days
    ENDIF ELSE COUNT90 = 0  

    ; ===> Find LOGS that are in the PERMANENT_ERROR directory and remove any L1As from the main L1 directory
    PLOGS = FILE_SEARCH(PERMAN + PREFIX + '*.LOG') & FL = FILE_PARSE(PLOGS)
    OK = WHERE_MATCH(FP.FIRST_NAME, FL.FIRST_NAME, COUNT, COMPLEMENT=COMPLEMENT, VALID=VALID)
    IF COUNT GE 1 THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(COUNT) + ' L1A files to be removed to the PERMANENT_ERROR directory...'
      FOR I=0, COUNT-1 DO PRINTF, LUN, 'Moving ' + L1S(OK(I)) + ' to ' + PERMAN
      FLUSH, LUN
      FILE_MOVE, L1S[OK], PERMAN, /OVERWRITE, /VERBOSE
      L1S = L1S(COMPLEMENT)
      FP  = FP(COMPLEMENT)
    ENDIF

    ; ===> Create L2 file names and find files that are missing
    L2S = L2_DIR + FP.FIRST_NAME + '.' + SUFFIX                                       ; Create L2 file names from the L1S
    OK = WHERE(FILE_TEST(L2S) EQ 0, COUNT_MISS)
    IF COUNT_MISS GE 1 THEN PROCESS_L1S = L1S[OK]

    ; ===> Create L2 LOG file names
    LOGS = L2_DIR + FP.FIRST_NAME + '.LOG'                                            ; Create LOG file names for files in the L2_DIR
    OK = WHERE(FILE_TEST(LOGS) EQ 0,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMP)    ; Find LOG files that need to be checked and moved
    IF NCOMP EQ 0 THEN GOTO, SKIP_LOGS                                                ; If no LOG files in the L2_DIR skip LOG check steps >>>>>>>>
    LOGS = LOGS(COMPLEMENT)
    L1S = L1S(COMPLEMENT)
    FP = FP(COMPLEMENT)
    L2S = L2S(COMPLEMENT)

    ; ===> Read each LOG files and look for geolocation, climatology or processing ERRORS
    PRINTF, LUN, 'Checking ' + ROUNDS(N_ELEMENTS(LOGS)) + ' LOG files...'
    FLUSH, LUN
    FOR LTH=0, N_ELEMENTS(LOGS)-1 DO BEGIN
      LOG = READ_TXT(LOGS(LTH))
      OK = [WHERE_STRING(LOG,'met_clim',COUNTM),WHERE_STRING(LOG,'ozone_clim',COUNTO),WHERE_STRING(LOG,'l2gen status: 0',COUNTL)]
      IF COUNTL GT 0 THEN IF COUNTM GT 0 OR COUNTO GT 0 THEN BEGIN                            ; Remove succefully created files that were processed with CLIMATOLOGICAL met or ozone files
        CLIMATOLOGY = [CLIMATOLOGY,L2S(LTH)]
        CLI_LOGS    = [CLI_LOGS,LOGS(LTH)]
        CONTINUE
      ENDIF

      OK = WHERE_STRING(LOG,'seadas-7.2',COUNTS)                                              ; Remove files created with SeaDAS 7.2 
      IF COUNTS GT 0 AND SENSOR EQ 'SEAWIFS' THEN BEGIN
        SEADAS72 = [SEADAS72,LOGS(LTH),L2S(LTH)]
        PROCESS_L1S = [PROCESS_L1S,L1S(LTH)]
        CONTINUE
      ENDIF

      IF WHERE_STRING(LOG, 'l2gen status: 0') NE [] THEN BEGIN                                ; l2gen status: 0 = L2A file was successfully created
        SUCCESSFUL_L2S = [SUCCESSFUL_L2S,L2S(LTH)]                                            ; Compile a list of successful L2 files not created with climatology met or ozone files
        FILE_MOVE, LOGS(LTH), LOG_DIR, /VERBOSE, /OVERWRITE
        CONTINUE
      ENDIF
      
      IF WHERE_STRING(LOG,'ERROR: MODIS geolocation processing failed.') NE [] THEN BEGIN
        GEO_ERROR = [GEO_ERROR,LOGS(LTH)]                                                    ; Geolocation error
        CONTINUE
      ENDIF

      IF WHERE_STRING(LOG,'No pixels in swath fall within the specified coordinates.') NE [] THEN BEGIN
        IF WHERE_STRING(LOG,'No such file or directory') NE [] THEN CONTINUE ; Geo file not created correctly or ancillary data is missing
        IF WHERE_STRING(LOG,'HDP ERROR') NE [] THEN STOP                     ; File not read correctly
        OUT_OF_AREA = [OUT_OF_AREA,LOGS(LTH),L2S(LTH)]                       ; Error indicates there were no pixels in the area of interest
        CONTINUE
      ENDIF
      
      IF WHERE_STRING(LOG,'-E- l2gen: north, south, east, west box not in this file.') NE [] THEN BEGIN
        L2GEN_OUT_OF_AREA = [L2GEN_OUT_OF_AREA,LOGS(LTH),L2S(LTH)]
        CONTINUE
      ENDIF

      PROCESSING_ERROR = [PROCESSING_ERROR,LOGS(LTH),L2S(LTH)]                               ; Other processing error

    ENDFOR ; FOR LTH=0, N_ELEMENTS(LOGS)-1 DO BEGIN

    ; ===> List the L2 files that successfully created
    PRINTF, LUN
    PRINTF, LUN, ROUNDS(N_ELEMENTS(SUCCESSFUL_L2S)) + ' files were successfully created.'
    IF SUCCESSFUL_L2S NE [] THEN FOR I=0, N_ELEMENTS(SUCCESSFUL_L2S)-1 DO PRINTF, LUN, 'Successfully created ' + SUCCESSFUL_L2S(I)
    FLUSH, LUN

    SKIP_LOGS:

    ; ===> Remove L2 files that were processed with seadas 7.2 met or ozone files
    IF SEADAS72 NE [] THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(SEADAS72)) + ' files using SeaDAS 7.2 met and/or ozone ancillary files'
      FOR I=0, N_ELEMENTS(SEADAS72)-1 DO PRINTF, LUN, 'Moving ' + SEADAS72(I) + ' to ' + SUSPECT
      FLUSH, LUN
      FILE_MOVE, SEADAS72, SUSPECT, /VERBOSE, /OVERWRITE
    ENDIF

    ; ===> Check L2 files that were processed with climatology met or ozone files and remove if updated ancillary files are available
    IF CLIMATOLOGY NE [] THEN BEGIN
      PRINTF, LUN & PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(CLIMATOLOGY)) + ' files using climatology met and/or ozone ancillary files'
      PRINTF, LUN & PRINTF, LUN, 'Checking for updated ancillary files for ' + ROUNDS(N_ELEMENTS(CLIMATOLOGY)) + ' CLIMATOLOGY files...'
      FOR I=0, N_ELEMENTS(CLIMATOLOGY)-1 DO BEGIN
        CLIM = CLIMATOLOGY(I)
        CLIM_LOG = CLI_LOGS(I) 
        CFP = FILE_PARSE(CLIM) 
        AFILE = L1A_PRO + REPLACE(CFP.NAME_EXT,CFP.EXT,L1NAME) 
        CFILE = L1A_CLI + REPLACE(CFP.NAME_EXT,CFP.EXT,L1NAME) 
        LFILE = L1A_DIR + REPLACE(CFP.NAME_EXT,CFP.EXT,L1NAME + '.bz2')
        
        IF EXISTS(CFILE) EQ 0 THEN BEGIN
          IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(LFILE) EQ 1 THEN FILE_COPY, LFILE, L1A_CLI, /VERBOSE  ; Copy the bz2 file to L1A_CLI
          IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(REPLACE(LFILE,'.bz2','')) EQ 1 THEN FILE_COPY, REPLACE(LFILE,'.bz2',''), L1A_CLI, /VERBOSE  ; Copy the unzipped file to L1A_CLI
        ENDIF
      ENDFOR  
      
      CBZ2 = FILE_SEARCH(L1A_CLI + '*.bz2',COUNT=COUNT_BZ2)
      IF COUNT_BZ2 GT 0 THEN BEGIN
        PRINTF, LUN, 'Unzipping ' + NUM2STR(COUNT_BZ2) + ' files in ' + L1A_CLI
        CD, L1A_CLI
        CMD = 'pbzip2 -dv *.bz2'
        PRINT, CMD
        SPAWN, CMD, CBZLOG, CBZERR
      ENDIF ; COUNT_BZ2

      IF KEY(GET_ANC) THEN BEGIN  ; Get ancillary data
        FLUSH, LUN
        CLI_FILES = FILE_SEARCH(L1A_CLI + '*.*',COUNT=COUNT_CLI)
        
        CD, DIR_ANC
        IF EXISTS(ANC_DB) THEN FILE_DELETE, ANC_DB ; Delete the ancillary database
        
        FOR L=0, COUNT_CLI-1 DO BEGIN ; ===> Look for new ancillary files for the L30 files  
          CFILE = CLI_FILES(L)
          CFP = FILE_PARSE(CFILE)
          AFILE = L1A_PRO + CFP.FIRST_NAME + '.' + L1NAME
          LFILE = L1A_DIR + CFP.FIRST_NAME + '.' + L1NAME + '.bz2'
          CLIM  = L2_DIR  + CFP.FIRST_NAME + '.' + SUFFIX
          CLOG  = L2_DIR  + CFP.FIRST_NAME + '.LOG'
          LOG2  = LOG_DIR + CFP.FIRST_NAME + '.LOG'
          
          CMDANC = ANC_SCR + 'getanc.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
          SPAWN, CMDANC, ANC_TXT
          OK_ANC = WHERE_STRING(ANC_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ANC)
  
          IF SENSOR EQ 'MODISA' THEN BEGIN
            CMDATT = ANC_SCR + 'modis_atteph.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
            SPAWN, CMDATT, ATT_TXT
            OK_ATT = WHERE_STRING(ATT_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ATT)
          ENDIF ELSE COUNT_ATT = 1 ; SENSOR EQ 'MODISA'
          
          IF COUNT_ANC EQ 1 AND COUNT_ATT EQ 1 THEN BEGIN ; If new ancillary data are found
            CLIM_ANC_TXT = 'Successfully updated the ancillary files to replace the climatology (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT_CLI) + ') for: ' + AFILE
            PRINTF, LUN, CLIM_ANC_TXT  & FLUSH,LUN & PRINT, CLIM_ANC_TXT  
            PRINTF, LUN, 'Moving ' + CLIM + ' to ' + CLI_DIR  & FLUSH, LUN
            IF EXISTS(CLIM) THEN FILE_MOVE, CLIM, CLI_DIR, /VERBOSE, /OVERWRITE ; Move the climatology file to the suspect climatology directory
            IF EXISTS(CLOG) THEN FILE_MOVE, CLOG, CLI_DIR, /VERBOSE, /OVERWRITE
            IF EXISTS(LOG2) THEN FILE_MOVE, LOG2, CLI_DIR, /VERBOSE, /OVERWRITE
            IF EXISTS(AFILE) THEN FILE_DELETE, CFILE ELSE FILE_MOVE, CFILE, L1A_PRO     ; Move the unzipped L1A file to L1A_PRO and remove from the L1A climatology directory
            PROCESS_L1S = [PROCESS_L1S,CFILE]               ; Add L1A file to the PROCESS_LIST
            CONTINUE
          ENDIF ; COUNT_ANC & COUNT_ATT   
          CLIM_ANC_TXT = 'Unable to update ancillary files to replace the climatology (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT_CLI) + ') for: ' + AFILE 
          PRINTF, LUN, CLIM_ANC_TXT & FLUSH,LUN & PRINT, CLIM_ANC_TXT    
          IF EXISTS(AFILE) THEN FILE_DELETE, AFILE, /VERBOSE   ; Remove the L1A file from the PROCESS directory & leave the L2 file and LOG in the L2 directory
        ENDFOR ; N_ELEMENTS(CLIMATOLOGY)
      ENDIF  
      CD, !S.PROGRAMS
    ENDIF ; CLIMATOLOGY
    
    ; ===> Review the files collected within the last 30 days and update the ancillary files (to replace the climatology)
    FOR L=0, COUNT30-1 DO BEGIN ; Move files from the last 30 days to L1A_L30
      F30 = FP30(L)   
      CFILE = L1A_L30 + F30.FIRST_NAME + '.' + L1NAME
      LFILE = L1A_DIR + F30.FIRST_NAME + '.' + L1NAME + '.bz2'
      
      IF EXISTS(CFILE) EQ 0 THEN BEGIN
        IF EXISTS(CFILE+'.bz2') EQ 0 THEN PRINTF, LUN, 'Moving ' + LFILE + ' to ' + L1A_L30
        IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(LFILE) EQ 1 THEN FILE_COPY, LFILE, L1A_L30, /VERBOSE  ; Copy the bz2 file to L1A_30
        IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(REPLACE(LFILE,'.bz2','')) EQ 1 THEN FILE_COPY, REPLACE(LFILE,'.bz2',''), L1A_L30, /VERBOSE  ; Copy the unzipped file to L1A_30
      ENDIF
    ENDFOR  
    
    FBZ2 = FILE_SEARCH(L1A_L30 + '*.bz2',COUNT=COUNT_BZ2)
    IF COUNT_BZ2 GT 0 THEN BEGIN
      PRINTF, LUN, 'Unzipping ' + NUM2STR(COUNT_BZ2) + ' files in ' + L1A_L30
      PRINT, 'Unzipping ' + NUM2STR(COUNT_BZ2) + ' files in ' + L1A_L30
      CD, L1A_L30
      CMD = 'pbzip2 -dv *.bz2'
      PRINT, CMD
      SPAWN, CMD, PBZLOG, PBZERR
    ENDIF ; COUNT_BZ2
    
    IF KEY(GET_ANC) THEN BEGIN  ; Get ancillary data
      FLUSH, LUN
      L30_FILES = FILE_SEARCH(L1A_L30 + '*.*',COUNT=COUNT30)
      FOR L=0, COUNT30-1 DO BEGIN ; ===> Look for new ancillary files for the L30 files   
        CD, DIR_ANC
        CFILE = L30_FILES(L)
        F30 = FILE_PARSE(CFILE)
        AFILE = L1A_PRO + F30.FIRST_NAME + '.' + L1NAME
        LFILE = L1A_DIR + F30.FIRST_NAME + '.' + L1NAME + '.bz2'
        CL30  = L2_DIR  + F30.FIRST_NAME + '.' + SUFFIX
        CLOG  = L2_DIR  + F30.FIRST_NAME + '.LOG'
        SATDATE = SATDATE_2DATE(F30.FIRST_NAME)
        
        PRINTF, LUN, 'Checking ancillary files for ' + CFILE
        CMDANC = ANC_SCR + 'getanc.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
        SPAWN, CMDANC, ANC_TXT
        OK_ANC = WHERE_STRING(ANC_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ANC)
  
        IF SENSOR EQ 'MODISA' THEN BEGIN ; Get attitude and ephemeris data for MODISA
          CMDATT = ANC_SCR + 'modis_atteph.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
          SPAWN, CMDATT, ATT_TXT
          OK_ATT = WHERE_STRING(ATT_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ATT)         
        ENDIF ELSE COUNT_ATT = 1 ; If the sensor is not MODISA, then make COUNT_ATT=1
  
        IF COUNT_ANC EQ 1 AND COUNT_ATT EQ 1 THEN BEGIN ; If new ancillary data are found
          CLIM_ANC_TXT = 'Ancillary files for ' + AFILE + ' (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT30) + ') are optimal
          PRINTF, LUN, CLIM_ANC_TXT  & FLUSH,LUN & PRINT, CLIM_ANC_TXT
          PRINTF, LUN, 'Moving ' + CL30 + ' to ' + CLI_DIR  & FLUSH, LUN 
          IF EXISTS(CL30) EQ 1 THEN FILE_MOVE, CL30, CLI_DIR, /VERBOSE, /OVERWRITE ; Move the L2 climatology file to the suspect climatology directory
          IF EXISTS(CLOG) EQ 1 THEN FILE_MOVE, CLOG, CLI_DIR, /VERBOSE, /OVERWRITE ; Move the L2 climatology log to the suspect climatology directory
          PROCESS_L1S = [PROCESS_L1S,CFILE]                                        ; Add the L1A.bz2 file to the PROCESS_LIST
          IF DATE_2JD(SATDATE) LT DATE_2JD(D30) THEN FILE_DELETE, CFILE, /VERBOSE  ; Remove the file from the LAST_30 directory if older than 30 days
          CONTINUE
        ENDIF ; COUNT_ANC & COUNT_ATT
        CLIM_ANC_TXT = 'Unable to update ancillary files to replace the climatology (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT30) + ') for: ' + AFILE
        PRINTF, LUN, CLIM_ANC_TXT & FLUSH,LUN & PRINT, CLIM_ANC_TXT
        IF EXISTS(AFILE) THEN FILE_DELETE, AFILE, /VERBOSE   ; Remove the L1A file from the PROCESS directory & leave the L2 file and LOG in the L2 directory
      ENDFOR ; L30 loop to find updated ancillary files
    ENDIF ; KEY(GET_ANC) - Get the ancillary files for the files from the last 30 days
    CD, !S.PROGRAMS
        
    ; ===> Look for new LUTS files for the L90 MODISA files
    IF SENSOR EQ 'MODISA' THEN BEGIN
      ; ===> Get current LUTS
      CHECK_LUTS = 0
      RECHECK_LUTS:
      CLUTS = FLS(DIR_LUTS + '*.*')
      LUTS = (FILE_PARSE(CLUTS)).NAME
      FOR L=0, N_ELEMENTS(LUTS)-1 DO LUTS(L) = STRMID(LUTS(L),0,STRPOS(LUTS(L),'_',/REVERSE_SEARCH))
      IF ~SAME(LUTS) THEN BEGIN
        LUTDATES = STRMID(GET_MTIME(CLUTS,/DATE),0,8)
        OK = WHERE(DATE_2JD(LUTDATES) NE MAX(DATE_2JD(LUTDATES)),COUNT_PREV,COMPLEMENT=COMP_LUT)
        IF COUNT_PREV GT 0 THEN BEGIN
          PRINT, 'Found more than 1 set of LUTS in ' + DIR_LUTS
          PRINTF, LUN
          PRINTF, LUN, 'Removing old LUTS from ' + DIR_LUTS
          PRINTF, LUN & FLUSH, LUN
          FILE_MOVE, CLUTS[OK], DIR_PREV, /VERBOSE 
        ENDIF ELSE MESSAGE, 'ERROR: Double check LUTS in ' + DIR_LUTS
      ENDIF ELSE COMP_LUT = 0
      LUT = LUTS(COMP_LUT[0])
      
      ; ===> Check for new LUTS
      FLUSH, LUN & PRINTF, LUN & PRINTF, LUN, 'Checking for new MODISA LUTS'
      CMD = 'update_luts.py aqua -v'
      P, CMD
      SPAWN, CMD, LUTSLOG, LUTSERR
      CHECK_LUTS = CHECK_LUTS + 1
      IF WHERE_STRING(LUTSLOG,'OPER:xcal') NE [] AND CHECK_LUTS LE 2 THEN BEGIN
        LI, LUTSLOG
        PRINTF, LUN
        FOR L=0, N_ELEMENTS(LUTSLOG) DO PRINTF, LUN, LUTSLOG(L)
        PRINTF, LUN & FLUSH, LUN
        GOTO, RECHECK_LUTS
      ENDIF  
      
      PARTXT = READ_TXT(MSL12)
      OK = WHERE_STRING(PARTXT,'xcalfile',COUNT)
      IF PARTXT[OK] NE 'xcalfile=$OCVARROOT/modisa/xcal/OPER/' + LUT THEN BEGIN
        PARTXT[OK] = 'xcalfile=$OCVARROOT/modisa/xcal/OPER/' + LUT
        FILE_COPY, MSL12, DIR_PREV+'msl12_defaults-replaced_'+DATE_NOW(/DATE_ONLY)+'.par',/VERBOSE
        WRITE_TXT, MSL12, PARTXT
        PRINTF, LUN, 'Updated msl12_defaults.par file'
      ENDIF
      
      FOR L=0, COUNT90-1 DO BEGIN ; Move files from the last 90 days to CHECK_LUTS if the LUTS are not current
        F90 = FP90(L)   
        CFILE = L1A_L90 + F90.FIRST_NAME + '.' + L1NAME
        LFILE = L1A_DIR + F90.FIRST_NAME + '.' + L1NAME + '.bz2'
        CL90  = L2_DIR  + F90.FIRST_NAME + '.' + SUFFIX
        CLOG  = LOG_DIR + F90.FIRST_NAME + '.LOG'
        SATDATE = SATDATE_2DATE(F90.FIRST_NAME)
        
        IF EXISTS(CLOG) THEN BEGIN
          L90 = READ_TXT(CLOG)
          OK = WHERE_STRING(L90,'xcal',COUNT)
          IF COUNT GE 1 THEN BEGIN
            XCAL = (FILE_PARSE(L90(OK[0]))).NAME
            XCAL = STRMID(XCAL,0,STRPOS(XCAL,'_',/REVERSE_SEARCH))
            IF XCAL EQ LUT THEN BEGIN 
              IF EXISTS(CFILE) AND DATE_2JD(SATDATE) LT DATE_2JD(D90) THEN FILE_DELETE, CFILE, /VERBOSE ; Remove the L1A file from the LUTS dir if it is older than 90 days and the LUTS are current
              CONTINUE
            ENDIF  
          ENDIF  
        ENDIF
        
        IF EXISTS(CL90) THEN FILE_MOVE, CL90, LUT_DIR, /VERBOSE ; Move L2 file with the old LUTS so it can be recreated
        IF EXISTS(CLOG) THEN FILE_MOVE, CLOG, LUT_DIR, /VERBOSE
        PROCESS_L1S = [PROCESS_L1S,CFILE]                ; Add the L1A file to the PROCESS_LIST
        
        IF EXISTS(CFILE) EQ 0 THEN BEGIN
          IF EXISTS(CFILE+'.bz2') EQ 0 THEN PRINTF, LUN, 'Moving ' + LFILE + ' to ' + L1A_L90
          IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(LFILE) EQ 1 THEN FILE_COPY, LFILE, L1A_L90, /VERBOSE  ; Copy the bz2 file to L1A_30
          IF EXISTS(CFILE + '.bz2') EQ 0 AND EXISTS(REPLACE(LFILE,'.bz2','')) EQ 1 THEN FILE_COPY, REPLACE(LFILE,'.bz2',''), L1A_L90, /VERBOSE  ; Copy the unzipped file to L1A_30
        ENDIF
      ENDFOR  ; FOR L=0, COUNT90-1 DO BEGIN
    
      FBZ2 = FILE_SEARCH(L1A_L90 + '*.bz2',COUNT=COUNT_BZ2)
      IF COUNT_BZ2 GT 0 THEN BEGIN
        PRINTF, LUN, 'Unzipping ' + NUM2STR(COUNT_BZ2) + ' files in ' + L1A_L90
        CD, L1A_L90
        CMD = 'pbzip2 -dv *.bz2'
        PRINT, CMD
        SPAWN, CMD, PBZLOG, PBZERR
      ENDIF ; COUNT_BZ2
      CD, !S.PROGRAMS
    ENDIF ; IF SENSOR EQ 'MODISA' (TO UPDATE LUTS)  
    
    ; ===> Remove files that had processing errors
    IF PROCESSING_ERROR NE [] THEN BEGIN
      PROCESSING_ERROR = PROCESSING_ERROR[WHERE(FILE_TEST(PROCESSING_ERROR) EQ 1)]
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(PROCESSING_ERROR)) + ' files with processing errors.'
      FOR I=0, N_ELEMENTS(PROCESSING_ERROR)-1 DO PRINTF, LUN, 'Moving ' + PROCESSING_ERROR(I) + ' to ' + ERR_DIR
      FLUSH, LUN
      FILE_MOVE, PROCESSING_ERROR, ERR_DIR, /VERBOSE, /OVERWRITE
    ENDIF ; IF PROCESSING_ERROR NE [] THEN BEGIN

    ; ===> Get PROCESSING_ERROR thumbnails
    PFILES = FILE_SEARCH(ERR_DIR + PREFIX + '*LOG',COUNT=COUNT_PFILES) & PP = FILE_PARSE(PFILES) & PRO_NAMES = PP.FIRST_NAME
    EFILES = PRO_NAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png?sub=l12image&file='+PRO_NAMES+'.' + THUMB + '.nc_CHLOR_A_BRS'
    OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 0, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
    IF COUNT_PFILES GE 1 AND COUNT_EFILES GE 1 AND RUN_WGET EQ 1 THEN BEGIN
      CD, THUMBS
      WRITE_TXT, 'WGET_ERR.TXT', OC_BROWSE + EFILES(OKE)
      CMD = 'wget -c -N -a ' + LOGFILE + ' -i WGET_ERR.TXT'
      P, CMD
      PRINTF, LUN, 'Downloading PROCESSING ERROR thumbnails...' & PRINT, 'Downloading ' + ROUNDS(COUNT_EFILES) + ' PROCESSING ERROR thumbnails'
      FOR I=0, COUNT_EFILES-1 DO PRINTF, LUN, ROUNDS(I) + ': Downloading thumbnail for ' + EFILES(OKE(I))
      FLUSH, LUN
      SPAWN, CMD
      CLOSE, LUN & FREE_LUN, LUN & OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN
      OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 1, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
      IF COUNT_EFILES GT 0 THEN FILE_UPDATE, THUMBS+EFILES(OKE), ERR_DIR
    ENDIF ELSE BEGIN ; IF COUNT_EFILES GE 1 THEN BEGIN
      IF ENCOMP GE 1 THEN FILE_UPDATE, THUMBS+EFILES(ECOMP), ERR_DIR
    ENDELSE

    ; ===> Remove LOG files that had geolocation errors
    IF GEO_ERROR NE [] THEN BEGIN
      GEO_ERROR = GEO_ERROR[WHERE(FILE_TEST(GEO_ERROR) EQ 1)]
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(GEO_ERROR)) + ' files with geolocation errors.'
      FOR I=0, N_ELEMENTS(GEO_ERROR)-1 DO PRINTF, LUN, 'Moving ' + GEO_ERROR(I) + ' to ' + GEO_DIR
      FLUSH, LUN
      FILE_MOVE, GEO_ERROR, GEO_DIR, /VERBOSE, /OVERWRITE
    ENDIF ; IF GEO_ERROR NE [] THEN BEGIN

    ; ===> Get GEO_ERROR thumbnails
    GFILES = FILE_SEARCH(GEO_DIR + PREFIX + '*LOG',COUNT=COUNT_GFILES) & GP = FILE_PARSE(GFILES) & GEO_NAMES = GP.FIRST_NAME
    EFILES = GEO_NAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png?sub=l12image&file='+GEO_NAMES+'.' + THUMB + '.nc_CHLOR_A_BRS'
    OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 0, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
    IF COUNT_GFILES GE 1 AND COUNT_EFILES GE 1 AND RUN_WGET EQ 1 THEN BEGIN
      CD, THUMBS
      WRITE_TXT, 'WGET_GEO.TXT', OC_BROWSE + EFILES(OKE)
      CMD = 'wget -c -N -a ' + LOGFILE + ' -i WGET_GEO.TXT'
      P, CMD
      PRINTF, LUN, 'Downloading GEOLOCATION ERROR thumbnails...' & PRINT, 'Downloading ' + ROUNDS(COUNT_EFILES) + ' GEOLOCATION ERROR thumbnails'
      FOR I=0, COUNT_EFILES-1 DO PRINTF, LUN, ROUNDS(I) + ': Downloading thumbnail for ' + EFILES(OKE(I))
      FLUSH, LUN
      SPAWN, CMD
      CLOSE, LUN & FREE_LUN, LUN & OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN
      OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 1 AND FILE_TEST(ERR_DIR+EFILES) EQ 0, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
      IF COUNT_EFILES GT 0 THEN FILE_UPDATE, THUMBS+EFILES(OKE),GEO_DIR
    ENDIF ELSE BEGIN ; IF COUNT_EFILES GE 1 THEN BEGIN
      IF ENCOMP GE 1 THEN FILE_UPDATE, THUMBS+EFILES(ECOMP), GEO_DIR
    ENDELSE

    ; ===> Remove L1 files that are OUT-OF-AREA
    IF OUT_OF_AREA NE [] THEN OUT_OF_AREA = OUT_OF_AREA[WHERE(FILE_TEST(OUT_OF_AREA) EQ 1,/NULL)]
    IF OUT_OF_AREA NE [] THEN BEGIN      
      PRINTF, LUN & FLUSH, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(OUT_OF_AREA)) + ' files that do not contain data within the area of interest.'
      FOR I=0, N_ELEMENTS(OUT_OF_AREA)-1 DO PRINTF, LUN, 'Moving ' + OUT_OF_AREA(I) + ' to ' + OOA_DIR    
  ; CAUTION ; SEVERAL FILES ARE BEING FLAGGED AS "OUT OF AREA", BUT THE ERROR IDENTIFICATION IS WRONG AND THESE FILES SHOULD NOT BE REMOVED FROM THE MAIN DATABASE
      FILE_MOVE, OUT_OF_AREA, OOA_DIR, /VERBOSE, /OVERWRITE
    ENDIF ; IF OUT_OF_AREA NE [] THEN BEGIN

    ; ===> Download OUT-OF-AREA thumbnails
    AFILES = FILE_SEARCH(OOA_DIR + PREFIX + '*.L1A_*.bz2',COUNT=COUNT_AFILES) & AP = FILE_PARSE(AFILES) & OOA_NAMES = AP.FIRST_NAME
    OFILES = OOA_NAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png?sub=l12image&file='+ OOA_NAMES +'.' + THUMB + '.nc_CHLOR_A_BRS'
    OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 0, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
    IF COUNT_AFILES GE 1 AND COUNT_EFILES GE 1 AND RUN_WGET EQ 1 THEN BEGIN
      CD, THUMBS
      WRITE_TXT, 'WGET_OOA.TXT', OC_BROWSE + EFILES(OKE)
      CMD = 'wget -c -N -a ' + LOGFILE + ' -i WGET_OOA.TXT'
      P, CMD
      PRINTF, LUN, 'Downloading OUT-OF-AREA thumbnails...' & PRINT, 'Downloading ' + ROUNDS(COUNT_EFILES) + ' OUT-OF-AREA thumbnails'
      FOR I=0, COUNT_EFILES-1 DO PRINTF, LUN, ROUNDS(I) + ': Downloading thumbnail for ' + EFILES(OKE(I))
      FLUSH, LUN
      SPAWN, CMD
      CLOSE, LUN & FREE_LUN, LUN & OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN
      OKE = WHERE(FILE_TEST(THUMBS+EFILES) EQ 1 AND FILE_TEST(ERR_DIR+EFILES) EQ 0, COUNT_EFILES, /NULL, COMPLEMENT=ECOMP, NCOMPLEMENT=ENCOMP)
      IF COUNT_EFILES GT 0 THEN FILE_UPDATE, THUMBS+EFILES(OKE),GEO_DIR    
    ENDIF ELSE BEGIN ; IF COUNT_OFILES GE 1 THEN BEGIN
      IF ENCOMP GE 1 THEN FILE_UPDATE, THUMBS+EFILES(ECOMP), OOA_DIR
    ENDELSE
    CD, !S.PROGRAMS
    
    ; ===> Find L2 files that do not have a corresponding LOG file
    L2S = FILE_SEARCH(L2_DIR + PREFIX + '*' + SUFFIX, COUNT=COUNT_L2S) & FL2 = FILE_PARSE(L2S)
    OK = WHERE(FILE_TEST(LOG_DIR + FL2.NAME + '.LOG') EQ 0 AND FILE_TEST(L2_DIR + FL2.NAME + '.LOG') EQ 0, COUNT_LOGS)
    IF COUNT_LOGS GE 1 AND COUNT_L2S GT 0 THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(COUNT_LOGS) + ' L2 files without corresponding LOG files...'
      FOR I=0, N_ELEMENTS(L2S[OK])-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Delete and reprocess ' + L2S(OK(I))
      FLUSH, LUN
      PROCESS_L1S = [PROCESS_L1S,L1A_DIR+FL2[OK].NAME+L1SUFFIX]
      FILE_DELETE, L2S[OK], /VERBOSE
      PRINT, 'Found ' + ROUNDS(COUNT_LOGS) + ' L2 files without corresponding LOG files.  DELETE and REPROCESS...'
    ENDIF

    ; ===> Find OUT-OF-AREA files in L1A & L1A_PROCESS that should be removed
    OOA = FILE_SEARCH(OOA_DIR + PREFIX + '*LOG',COUNT=COUNTO)
    IF COUNTO GE 1 THEN BEGIN
      FO = FILE_PARSE(OOA)
      L1R = L1A_PRO + FO.NAME + L1SUFFIX     ; Zipped files in L1A_PROCESS
      L1R = [L1R, REPLACE(L1R,'.bz2','')]    ; Unzipped files on L1A_PROCESS
      OK = WHERE(FILE_TEST(L1R) EQ 1,COUNTR)
      IF COUNTR GE 1 THEN BEGIN
        PRINTF, LUN
        PRINTF, LUN, 'Found ' + ROUNDS(COUNTR) + ' L1A files in L1A_PROCESS that correspond to OUT-OF-AREA files...'
        FOR I=0, COUNTR-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Deleting ' + L1R(OK(I))
        FLUSH, LUN
        FILE_DELETE, L1R[OK], /VERBOSE
      ENDIF
      L1R = L1A_DIR + FO.NAME + L1SUFFIX    ; Zipped files on L1A_PROCESS
      OK = WHERE(FILE_TEST(L1R) EQ 1,COUNTR)
      IF COUNTR GE 1 THEN BEGIN
        PRINTF, LUN
        PRINTF, LUN, 'Found ' + ROUNDS(COUNTR) + ' L1A files in L1A that correspond to OUT-OF-AREA files...'
        FOR I=0, COUNTR-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Removing ' + L1R(OK(I))
        FLUSH, LUN      
        FILE_MOVE, L1R[OK], OOA_DIR, /OVERWRITE, /VERBOSE     ; Move original L1A files to the OUT-OF-AREA directory
      ENDIF
    ENDIF

    ; ===> Add files that still need to be processed   
    IF PROCESS_L1S NE [] THEN PROCESS_L1S = PROCESS_L1S[WHERE(FILE_TEST(PROCESS_L1S) EQ 1, /NULL, COUNT_PROCESS)] ELSE COUNT_PROCESS = 0 ; Remove missing files that may have been moved in the OUT-OF-AREA test
    IF COUNT_PROCESS GE 1 THEN BEGIN
      L1A = REPLACE(PROCESS_L1S, [SL+'NC'+SL,'LAST_30DAYS','CHECK_LUTS','.bz2'],[SL+'PROCESS'+SL,'PROCESS','PROCESS',''])              ; Create unzipped file names in L1A_PROCESS
      OK  = WHERE(FILE_TEST(L1A+'.bz2') EQ 0 AND FILE_TEST(L1A) EQ 0, COUNT)            ; Find missing L1A files in L1A_PROCESS
      IF COUNT GE 1 AND PROCESS_L1S NE [] THEN BEGIN
        PRINTF, LUN, 'Moving ' + ROUNDS(COUNT) + ' files to PROCESS...'
        FOR I=0, COUNT-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Copying ' + PROCESS_L1S(OK(I)) + ' to L1A_PROCESS'
        FLUSH, LUN
        FILE_COPY, PROCESS_L1S[OK], L1A_PRO, /VERBOSE, /OVERWRITE                        ; Copy L1A.bz2 files to L1A_PROCESS
      ENDIF
    ENDIF

    ; ===> Look for duplicate files (zipped and unzipped) in L1A_PROCESS
    L1A_FILES = FILE_SEARCH(L1A_PRO + '*.*', COUNT=COUNT_L1A)
    FP_L1A = FILE_PARSE(L1A_FILES)
    DPS = WHERE_SETS(FP_L1A.FIRST_NAME)
    OK = WHERE(DPS.N GT 1, COUNT_DPS)
    IF COUNT_DPS GT 1 THEN BEGIN
      SETS = DPS[OK]
      FOR ST=0, N_ELEMENTS(SETS)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(SETS(ST))
        SET  = FP_L1A(SUBS)
        OK = WHERE(SET.EXT EQ 'bz2',COUNTB)
        IF COUNTB GE 1 THEN FILE_DELETE, SET[OK].FULLNAME, /VERBOSE                    ; Removed duplicate zipped file if the unzipped file already exists
      ENDFOR
    ENDIF  

    ; ===> Unzip files that are in L1A_PROCEDSS
    BZ2 = FILE_SEARCH(L1A_PRO + '*.bz2', COUNT=COUNT_BZ2)                                ; Find zipped files in L1A_PROCESS
    IF COUNT_BZ2 GE 1 THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Unzipping L1A files...'
      FOR I=0, N_ELEMENTS(BZ2)-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Unzipping ' + BZ2(I)
      FLUSH, LUN
      CD, L1A_PRO
      CMD = 'pbzip2 -dv *.bz2'
      PRINT, CMD
      SPAWN, CMD, PBZIP_LOG, PBZIP_ERR
      CD, !S.PROGRAMS
    ENDIF

    ; ===> Remove successfully processed files from L1A_PROCESS
    L1P = FILE_SEARCH(L1A_PRO + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''))    ; Find all files currently in L1A_PROCESS
    OK  = WHERE_MATCH(L1P, L1A, COUNT, COMPLEMENT=COMP, NCOMPLEMENT=NCOMP)     ; Compare the files in L1A_PRO and those in the L1A_PROCESS list
    IF NCOMP GE 1 AND L1P(COMP[0]) NE '' THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Removing successfully processed L1A files...'
      FOR I=0, N_ELEMENTS(L1P(COMP))-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Deleting ' + L1P(COMP(I))
      FLUSH, LUN
      
      FILE_DELETE, L1P(COMP), /VERBOSE                                          ; Remove files from L1A_PRO that are not in the L1A_PROCESS list
    ENDIF

    ; ===> Get ancillary data for files in L1A_PROCESS
    L1P = FILE_SEARCH(L1A_PRO + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_L1P)
    IF COUNT_L1P GE 1 AND GET_ANC EQ 1 THEN BEGIN
      COUNTER = 0
      FLUSH, LUN
      PRINTF, LUN
      PRINTF, LUN, 'Checking for (and downloading if missings) ancillary files for ' + ROUNDS(N_ELEMENTS(L1P)) + ' files...'
      FOR L=0, COUNT_L1P-1 DO BEGIN ; ===> Look for new ancillary files for the L90 files
        CD, DIR_ANC
        CFILE = L1P(L)
        PRINTF, LUN, 'Checking ancillary files for ' + CFILE
        CMDANC = ANC_SCR + 'getanc.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
        SPAWN, CMDANC, ANC_TXT
        OK_ANC = WHERE_STRING(ANC_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ANC)

        IF SENSOR EQ 'MODISA' THEN BEGIN ; Get attitude and ephemeris data for MODISA
          CMDATT = ANC_SCR + 'modis_atteph.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
          SPAWN, CMDATT, ATT_TXT
          OK_ATT = WHERE_STRING(ATT_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ATT)
        ENDIF ELSE COUNT_ATT = 1 ; If the sensor is not MODISA, then make COUNT_ATT=1

        IF COUNT_ANC EQ 1 AND COUNT_ATT EQ 1 THEN BEGIN ; If new ancillary data are found
          CLIM_ANC_TXT = 'Ancillary files for ' + AFILE + ' (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNTL1A) + ') are optimal
          PRINTF, LUN, CLIM_ANC_TXT  & FLUSH,LUN & PRINT, CLIM_ANC_TXT
          CONTINUE
        ENDIF ; COUNT_ANC & COUNT_ATT
        CLIM_ANC_TXT = 'Unable to update ancillary files to replace the climatology (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNTL1A) + ') for: ' + AFILE
        PRINTF, LUN, CLIM_ANC_TXT & FLUSH,LUN & PRINT, CLIM_ANC_TXT
      ENDFOR ; L1A loop to find updated ancillary files
    ENDIF
    CD, !S.PROGRAMS

    ; ===> Remove SUSPECT MODISA L1A files from the download list
    IF SENSOR EQ 'SEAWIFS' THEN GOTO, SKIP_UPDATE_DOWNLOAD_LIST
    DOWNLOAD_LIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + REPLACE(DATASET,'-','_') + '.txt'
    DLIST  = READ_TXT(DOWNLOAD_LIST)
    DP     = FILE_PARSE(DLIST)
    LNAMES = REPLACE(DP.NAME_EXT,'.bz2','')

    FILES  = FILE_SEARCH([PERMAN,OOA_DIR] + PREFIX + '*' + L1NAME + '*')
    FP     = FILE_PARSE(FILES)
    FNAMES = REPLACE(FP.NAME_EXT,'.bz2','')

    OK = WHERE_MATCH(LNAMES,FNAMES,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
    IF COUNT GE 1 AND NCOMPLEMENT GE 1 THEN BEGIN
      FILE_MOVE, DOWNLOAD_LIST, !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + 'REPLACED' + SL + REPLACE(DATASET,'-','_') + '-REPLACED_' + DATE_NOW() + '.txt'
      PRINTF, LUN
      PRINTF, LUN, 'Removing SUSPECT OUT-OF-AREA files fron the master download list...'
      FOR I=0, COUNT-1 DO PRINTF, LUN, 'Removing ' + LNAMES(OK(I)) + ' from the download list'
      FLUSH, LUN
      WRITE_TXT, DOWNLOAD_LIST, OC_GET + LNAMES(COMPLEMENT) + '.bz2'
    ENDIF
    SKIP_UPDATE_DOWNLOAD_LIST:

    IF PROCESS_L1S EQ [] THEN BEGIN
      PRINTF, LUN & PRINTF, LUN, ' All files for ' + SENSOR + ' (' + STRJOIN(DATERANGE,' - ') + ') have been processed.'
      PRINT & PRINT, ' All files for ' + SENSOR + ' (' + STRJOIN(DATERANGE, ' - ') + ') have been processed.'
    ENDIF ELSE BEGIN
      PROCESS_L1S =  PROCESS_L1S[SORT(PROCESS_L1S)]
      PRINTF, LUN & PRINT & LI, ' Need to process ' + PROCESS_L1S
      FOR I=0, N_ELEMENTS(PROCESS_L1S)-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Need to process ' + PROCESS_L1S(I)
      PRINTF, LUN, ROUNDS(N_ELEMENTS(PROCESS_L1S)) + ' L1A files remaining to process...'
      PRINT,       ROUNDS(N_ELEMENTS(PROCESS_L1S)) + ' L1A files remaining to process...'
    ENDELSE
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    
; ===> Process the L1A to L2 files using SeaDAS
    IF KEY(RUN_SEADAS) AND N_ELEMENTS(PROCESS_L1S) GT 0 AND SECOND_CHECK EQ 0 THEN BEGIN
      SECOND_CHECK = 1
      CASE SENSOR OF
        'MODISA':  SCMD = './process_L1A_L2_modis_files.sh'
        'SEAWIFS': SCMD = './process_L1A_L2_seawifs_files.sh'
        'VIIRS':   SCMD = './process_L1A_L2_viirs_files.sh'
        ELSE: SCMD = ''
      ENDCASE
      IF SCMD EQ '' THEN CONTINUE
      FILES2 = FILE_SEARCH(L2_DIR + '*', COUNT=FILES_BEFORE)
      CD, !S.SCRIPTS + 'SEADAS' + SL
      FLUSH, LUN
      PRINTF, LUN, 'Running SeaDAS for ' + NUM2STR(N_ELEMENTS(PROCESS_L1S)) + ' files for ' + SENSOR
      PRINTF, LUN, CMD
      PRINT, SCMD
      SPAWN, SCMD, L2GEN_TXT
      PRINTF, LUN
      CD, !S.PROGRAMS
      FILES2 = FILE_SEARCH(L2_DIR + '*', COUNT=FILES_AFTER)
      IF FILES_AFTER GT FILES_BEFORE THEN GOTO, RERUN_CHECK_FILES
    ENDIF ; IF KEY(RUN_SEADAS) AND N_ELEMENTS(PROCESS_L1S) GT 0 AND SECOND_CHECK EQ 0 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; ===> Create L2BIN list files and process L2 to L3B
    L2BIN_CHECK:
    CLOSE, LUN & FREE_LUN, LUN & OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN
    IF KEY(SKIP_L2S) THEN CONTINUE ; Skip the steps to process the L2BIN files    
    CASE SENSOR OF
      'SA': BEGIN
        L2S =      FILE_SEARCH(!S.MODIS  + 'OC' + SL + 'MODISA'  + SL + 'L2' + SL + 'NC' + SL + 'A*L2_LAC_SUB_OC')
        L2S = [L2S,FILE_SEARCH(!S.SEADAS + 'OC' + SL + 'SEAWIFS' + SL + 'L2' + SL + 'NC' + SL + 'S*L2_MLAC_OC')]
        L2S = DATE_SELECT(L2S,['20020101','20101231'])
      END 
      'SAT': BEGIN
        L2S =      FILE_SEARCH(!S.MODIS  + 'OC' + SL + 'MODISA'  + SL + 'L2' + SL + 'NC' + SL + 'A*L2_LAC_SUB_OC')
        L2S = [L2S,FILE_SEARCH(!S.MODIS  + 'OC' + SL + 'MODIST'  + SL + 'L2' + SL + 'NC' + SL + 'T*L2_LAC_OC.nc')]
        L2S = [L2S,FILE_SEARCH(!S.SEADAS + 'OC' + SL + 'SEAWIFS' + SL + 'L2' + SL + 'NC' + SL + 'S*L2_MLAC_OC')]
        L2S = DATE_SELECT(L2S,['20000101','20201231'])
      END
      'AT' :  L2S = FILE_SEARCH(L2_DIR + ['A','T'] + '*' + SUFFIX, COUNT=COUNT_L2S)   
      ELSE:  L2S = FILE_SEARCH(L2_DIR + PREFIX + '*' + SUFFIX)
    ENDCASE
    L2S = DATE_SELECT(L2S,DATERANGE,COUNT=COUNT_L2S)
    IF COUNT_L2S EQ 0 THEN CONTINUE
    FL2 = PARSE_IT(L2S)
    SETS = PERIOD_SETS(PERIOD_2JD(FL2.PERIOD),DATA=L2S,PERIOD_CODE='D',/NESTED)
    TAGS = TAG_NAMES(SETS)

    PRINTF, LUN
    PRINTF, LUN, 'Creating L2BIN list files...'
    PRINTF, LUN, 'Found ' + ROUNDS(N_ELEMENTS(L2S)) + ' L2 files'
    PRINTF, LUN, 'Binning into ' + ROUNDS(N_ELEMENTS(TAGS)) + ' daily files'
    FLUSH, LUN

    IF RESO EQ [] THEN RES = ['2'] ELSE RES = RESO
    NIGHT=0
    QUAL_MAX=''
    FLAGS = "ATMFAIL,LAND,HIGLINT,HILT,HISATZEN,STRAYLIGHT,CLDICE,NAVFAIL,LOWLW"
    PROCESS_L3 = []

    PRINT & PRINT, 'Checking to see which L3B ' + SENSOR + ' files need to be processed...'
    FOR S=0, N_ELEMENTS(TAGS)-1 DO BEGIN
      SET = SETS.(S)
      RERUN_L2BIN:

      SI = SENSOR_INFO(SET)
      CASE SENSOR OF
         'AT':  SATNAME = 'X'+STRMID(SI[0].SATNAME,1,7)
         'SAT': SATNAME = 'Y'+STRMID(SI[0].SATNAME,1,7)
         'SA':  SATNAME = 'Z'+STRMID(SI[0].SATNAME,1,7)
         ELSE:  SATNAME = STRMID(SI[0].SATNAME,0,8)
       ENDCASE  
      L2BIN_LISTFILE = L2_BIN + SATNAME + '-L2BIN.txt'
      IF FILE_MAKE(SET,L2BIN_LISTFILE,OVERWRITE=OVERWRITE) EQ 1 THEN WRITE_TXT, L2BIN_LISTFILE, SET ; Remake list file in case the list of input files changes

      FOR R=0, N_ELEMENTS(RES)-1 DO BEGIN ; Loop through resolution
        L3D    = DIR + 'L3B' + RES(R) + SL
        L3_BOA = L3D + 'NC_BOA' + SL
        L3_PRO = L3D + 'PROCESS' + SL 
        L3_ERR = L3D + 'SUSPECT' + SL 
        IF S EQ 0 THEN DIR_TEST, [L3_PRO, L3_ERR, L3_BOA] ; Only need to DIR_TEST during the first loop
        FOR T=0, N_ELEMENTS(SUITES)-1 DO BEGIN ; Loop through suites
          OUTNAME = SUITES(T)
          
          L3_DIR = L3D + 'NC'  + SL + OUTNAME + SL
          L3_LOG = L3_DIR + 'LOGS' + SL
          L3_AIF = L3_DIR + 'ADD_IFILES' + SL 
          DIR_TEST,[L3_DIR,L3_LOG,L3_AIF]
          
          L3B_FILE = L3_DIR + SATNAME + '.L3B' + RES(R) + '_DAY_' + OUTNAME + '.nc'
          L3B_AIF  = L3_AIF + SATNAME + '.L3B' + RES(R) + '_DAY_' + OUTNAME + '.nc'
          L3B_ALG  = L3_AIF + SATNAME + '-' + OUTNAME + '.LOG'
          L3B_PROCESS = L3_PRO + SATNAME + '-L2BIN-' + OUTNAME + '.txt'
          L3B_ERROR   = L3_ERR + SATNAME + '-L2BIN-' + OUTNAME + '.txt'
          L3B_TEMP    = L3_PRO + SATNAME + '.L3B' + RES(R) + '_DAY_' + OUTNAME + '.nc'
         
          IF OUTNAME EQ 'CHL_BOA' THEN BEGIN
            L3B_FILE = REPLACE(L3B_FILE,SL+'NC'+SL,SL+'NC_BOA'+SL)
            L3B_AIF  = REPLACE(L3B_AIF, SL+'NC'+SL,SL+'NC_BOA'+SL)
            L3B_ALG  = REPLACE(L3B_ALG, SL+'NC'+SL,SL+'NC_BOA'+SL)
          ENDIF
         
          IF FILE_MAKE(L2BIN_LISTFILE,L3B_ERROR,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE  ; Skip if the ERROR file is present and was created after the L2BIN_LISTFILE
          IF FILE_MAKE(L2BIN_LISTFILE,L3B_FILE,OVERWRITE=OVERWRITE) EQ 0 OR FILE_MAKE(L2BIN_LISTFILE,L3B_AIF,OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN
            IF FILE_TEST(L3B_PROCESS) EQ 1 THEN FILE_DELETE, L3B_PROCESS, /VERBOSE
            
            ; ===> Update the attributes
            RERUN_ATTRIBUTES:
            IF FILE_TEST(L3B_AIF) EQ 1 THEN BEGIN
              PRINT, 'Updating the attributes in ' + L3B_AIF
              IF H5_HAS_GROUP(L3B_AIF,'processing_control') EQ 0 THEN BEGIN
                PRINTF, LUN, 'ERROR: ' + L3B_AIF + ' is not a complete file. Deleting...'
                FILE_DELETE, L3B_AIF, /VERBOSE
                GOTO, RERUN_L2BIN
              ENDIF
              PRINTF, LUN, 'Editing: ' + L3B_AIF
              PRINT & PRINT, 'Editing: ' + L3B_AIF
              FID = H5F_OPEN(L3B_AIF,/WRITE)                             ; Get the FILE ID
              GID = H5G_OPEN(FID,'processing_control')                   ; Get the GROUP ID for the "source" attribute
              SID = H5A_OPEN_NAME(GID,'source')                          ; Get the "source" ATTRIBUTE ID
              SRC = H5A_READ(SID)                                        ; Read the "source" files
              H5A_CLOSE, SID                                             ; Close the ATTRIBUTE ID
              H5G_CLOSE, GID                                             ; Close the GROUP ID
              
              ; ===> Add the list of input files to the attributes 
              IF H5_HAS_ATTRIBUTE(FID, 'input_files') EQ 1 THEN H5_EDIT_ATTRIBUTE, FID, 'input_files', SRC $
                                                           ELSE H5_ADD_ATTRIBUTE,  FID, 'input_files', SRC
              
              IF SAME(SI.SENSOR) EQ 0 THEN BEGIN ; Change the TITLE, PLATFORM and INSTRUMENT in the netcdf file when it includes data from multiple sensors
                SET_SENSORS = SI(UNIQ(SI.SENSOR)).SENSOR
                TITLE = [] & INSTR = [] & PLAT = []
                FOR SS=0, N_ELEMENTS(SET_SENSORS)-1 DO BEGIN
                  CASE SET_SENSORS(SS) OF
                    'SEAWIFS': BEGIN & TITLE=[TITLE,'SeaWiFS'] & INSTR=[INSTR,'SeaWiFS'] & PLAT=[PLAT,'Orbview-2'] & END
                    'MODISA' : BEGIN & TITLE=[TITLE,'MODISA']  & INSTR=[INSTR,'MODIS']   & PLAT=[PLAT,'Aqua']      & END
                    'MODIST' : BEGIN & TITLE=[TITLE,'MODIST']  & INSTR=[INSTR,'MODIS']   & PLAT=[PLAT,'Terra']     & END
                  ENDCASE
                ENDFOR ; SET_SENSORS  
                H5_EDIT_ATTRIBUTE, FID, 'title',       STRJOIN(TITLE, ', ') + ' Level-3 Binned Data'
                H5_EDIT_ATTRIBUTE, FID, 'instrument',  STRJOIN(INSTR, ', ')
                H5_EDIT_ATTRIBUTE, FID, 'platform',    STRJOIN(PLAT,  ', ')
              ENDIF
              IF H5_HAS_ATTRIBUTE(FID, 'modification_history') EQ 1 THEN H5_EDIT_ATTRIBUTE, FID, 'modification_history', 'File edited by K. Hyde @ NOAA/Fisheries/Narragansett on ' + SYSTIME() $
                                                                    ELSE H5_ADD_ATTRIBUTE,  FID, 'modification_history', 'File edited by K. Hyde @ NOAA/Fisheries/Narragansett on ' + SYSTIME()
              H5F_CLOSE, FID
              IF FILE_TEST(L3B_FILE) EQ 1 THEN FILE_DELETE, L3B_FILE, /VERBOSE ; Delete the original file if it exists to be recreated (FILE_MOVE,/OVERWRITE does not always replace the file)
              FILE_MOVE, L3B_AIF, L3_DIR, /VERBOSE, /OVERWRITE
              IF EXISTS(L3B_ALG) THEN FILE_MOVE, L3B_ALG, L3_LOG, /VERBOSE, /OVERWRITE
            ENDIF  ; FILE_TEST(L3B_AIF)
          ENDIF ELSE BEGIN ; FILE_MAKE       
            PROCESS_L3 = [PROCESS_L3,L3B_PROCESS]
            IF FILE_TEST(L3B_PROCESS) EQ 0 THEN FILE_COPY, L2BIN_LISTFILE, L3B_PROCESS, /VERBOSE
            IF FILE_TEST(L3B_FILE)    EQ 1 THEN FILE_DELETE, L3B_FILE, /VERBOSE ; Delete the L3B final file if it needs to be recreated (FILE_MOVE,/OVERWRITE does not always replace the file)
            NEW_SET = SET
            ERR_TXT = 'Error creating ' + L3B_FILE                      ; Create information that will be written to an ERROR file if necessary
            ERR_TXT = [ERR_TXT,'Initial input files: ',SET]             ; Add the list of input L2 files to the ERROR text
            RERUN_L3BPROCESS:
            IF KEY(RUN_L2BIN) THEN BEGIN ; Create the L3BIN file using SeaDAS's l2bin program
              FLUSH, LUN & PRINTF, LUN, 'Creating ' + L3B_AIF
              POF, S, TAGS, OUTTXT=OUTTXT,/QUIET
              PFILE, L3B_AIF, /W, _POFTXT=OUTTXT
              PARFILE = PARDIR + SENSOR + SL + 'l2bin_defaults_' + OUTNAME + '.par' & IF ~EXISTS(PARFILE) THEN STOP
              IF HAS(OUTNAME,'SST') THEN CMD = 'l2bin infile='+L3B_PROCESS + ' ofile='+L3B_TEMP + ' resolve='+RES(R) + ' suite='+OUTNAME + ' prodtype=Regional' + ' qual_max=2' + ' night=1' + ' parfile='+parfile $
                                    ELSE CMD = 'l2bin infile='+L3B_PROCESS + ' ofile='+L3B_TEMP + ' resolve='+RES(R) + ' suite='+OUTNAME + ' prodtype=Regional' + ' flaguse='+FLAGS + ' parfile='+parfile 
              P, CMD
              SPAWN, CMD, L2LOG, L2ERR
              IF FILE_TEST(L3B_TEMP) EQ 0 THEN BEGIN ; Figure out why the L3B file was not created
                ERRFILE = ''
                IF KEY(L2ERR) THEN BEGIN ; Processing error
                  IF HAS(L2ERR[1],'Consider QC fail for file:') EQ 0 THEN STOP ; Need to look for a different error string.
                  PRINT, 'ERROR: l2bin processing of ' + L3B_PROCESS + ' failed'
                  ERRSTR = STRSPLIT(L2ERR[1],' ',/EXTRACT)
                  ERRFILE = ERRSTR(-1)    
                  ERR_TXT = [ERR_TXT,L2ERR]            
                ENDIF
                IF HAS(L2LOG(3), '-E- File') AND HAS(L2LOG(3),'does not exist') THEN BEGIN ; Incidents of missing files will be in the L2LOG
                  ERRSTR = STRSPLIT(L2LOG(3),' ',/EXTRACT)
                  POS = WHERE(ERRSTR EQ 'File')
                  ERRFILE = ERRSTR(POS+1)
                  ERR_TXT = [ERR_TXT, L2LOG]
                ENDIF   
                IF HAS(L2LOG(-1), 'not found in L2 dataset') THEN BEGIN
                  PRINTF, LUN, L2LOG(-1)
                  ERRTXT = STRSPLIT(L2LOG(-1),'"',/EXTRACT)
                  ERRFILE = ERRTXT(-2)
                  ERR_TXT = [ERR_TXT, L2LOG]
                ENDIF
                IF HAS(L2LOG(-4), 'total_filled_bins: 0')  THEN BEGIN
                  PRINTF, LUN, 'Unable to create ' + L3B_FILE  
                  ERR_TXT = [ERR_TXT, L2LOG, 'Unable to create ' + L3B_FILE]
                  WRITE_TXT, L3B_ERROR, ERR_TXT
                  FILE_DELETE, L3B_PROCESS, /VERBOSE
                  CONTINUE               
                ENDIF
                NEW_SET = NEW_SET[WHERE(NEW_SET NE ERRFILE,/NULL,COUNT_SET)]
                IF COUNT_SET GT 0 THEN WRITE_TXT, L3B_PROCESS, NEW_SET ELSE BEGIN
                  ERR_TXT = [ERR_TXT, 'No valid files to create ' + L3B_FILE]
                  WRITE_TXT, L3B_ERROR, ERR_TXT
                  FILE_DELETE, L3B_PROCESS, /VERBOSE
                  CONTINUE
                ENDELSE
                GOTO, RERUN_L3BPROCESS ; >>> Recreate the L2BIN step              
              ENDIF ELSE BEGIN
                IF FILE_TEST(L3B_AIF) EQ 1 THEN FILE_DELETE, L3B_AIF, /VERBOSE ; Delete any old files that need to be replaced (FILE_MOVE,/OVERWRITE does not always overwrite the file)
                FILE_MOVE, L3B_TEMP, L3_AIF, /OVERWRITE, /VERBOSE
                WRITE_TXT, L3B_ALG, L2LOG
                GOTO, RERUN_ATTRIBUTES
              ENDELSE
            ENDIF ; RUN_L2BIN
          ENDELSE ; FILE_MAKE()
        ENDFOR ; PRODS
      ENDFOR ; RES
    ENDFOR ; TAGS

    IF ANY(PROCESS_L3) THEN BEGIN
      PROCESS_L3 =  PROCESS_L3[SORT(PROCESS_L3)]
      PRINT & LI, ' Need to process ' + PROCESS_L3
      FOR I=0, N_ELEMENTS(PROCESS_L3)-1  DO PRINTF, LUN, ROUNDS(I+1) + ': Need to process ' + PROCESS_L3(I)  
      FOR I=0, N_ELEMENTS(PROCESS_L1S)-1 DO PRINTF, LUN, ROUNDS(I+1) + ': Need to process ' + PROCESS_L1S(I)
    ENDIF
    PRINTF, LUN, ROUNDS(N_ELEMENTS(PROCESS_L3)) + ' L2BIN files remaining to process...'
    PRINT,       ROUNDS(N_ELEMENTS(PROCESS_L3)) + ' L2BIN files remaining to process...'

    PRINTF, LUN, 'Closing BATCH_SEADAS log file for ' + DATASET + ' on: ' + systime()
    FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
  ENDFOR ; DATASETS

  PRINT,'END OF ' + ROUTINE_NAME
END; #####################  End of Routine ################################
