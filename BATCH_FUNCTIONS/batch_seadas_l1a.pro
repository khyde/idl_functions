; $ID:	BATCH_SEADAS_L1A.PRO,	2022-08-17-14,	USER-KJWH	$
;+

PRO BATCH_SEADAS_L1A, SENSORS, PROJECTS=PROJECTS, RUN_WGET=RUN_WGET, GET_ANC=GET_ANC, RUN_L2GEN=RUN_L2GEN, RFILES=RFILES, DATERANGE=DATERANGE, DIR_PROCESS=DIR_PROCESS,$
                      LOGFILE=LOGFILE, EMAIL_ALL=EMAIL_ALL, ATTACHMENTS=ATTACHMENTS, SERVERS=SERVERS, NPROCESS=NPROCESS

; NAME: BATCH_L1A
;
; PURPOSE: This is a main BATCH program for sequential evaluation of level-L1A and L2 satellite data files
;
;  OPTIONAL KEYWORDS:
;    SENSORS...... The sensor name for the databases (e.g. MODISA, SEAWIFS, VIIRS)
;    RUN_WGET..... Set to download thumbnails for files with processing errors or are considered OUT-OF-AREA
;    GET_ANC...... Set to verify and download any missing ancillary files
;    DATERANGE.... Daterange to subset the files
;    SERVERS...... The names of the servers to use for the various processes
;    NPROCESS..... The number of processes to start on each server (default=6)
;
;
; MODIFICATION HISTORY:
;   MAR 08, 2018 - KJWH: Adapted from BATCH_SEADAS 
;                        Updated the logic for several steps
;                        Added a CHECK_LUTS step to check the LUT files over the last 90 days for MODISA
;                        Removed the SEADAS and L2BIN steps 
;   APR 03, 2018 - KJWH: Added keyword SKIP_L2GEN to skip the L2GEN processing steps
;                        By default, SKIP_L2GEN = 1
;                        Added a block to run the process_xxx_L1A_L2_files.sh code (because it often isn't working when the script is called directly during the cron jobs)                     
;   APR 10, 2018 - KJWH: Consolidated all of the UNZIPPING and GET_ANC steps into single blocks
;                        If PARZIP does not work, then try individually unzipping the files
;                        Replaced FLUSH, LUN and PRINTF, LUN with PLUN (a new program that will write to the LUN log file and print in the console)
;                        Need to look into consolidating the WGET thumbnail steps
;   APR 19, 2018 - KJWH: Updated the WGET thumbnails steps
;   APR 23, 2018 - KJWH: Fixed some file search bugs that were not properly removing the L1A files if they were determined to be OUT_OF_AREA or had PERMANENT_ERROR
;                        Change SKIP_L2GEN keyword to RUN_L2GEN
;                        Added EMAIL_ALL keyword.  If not set, only email if new files were produced or there was a L2GEN error
;   JUN 08, 2018 - KJwH: Removed the step to update the MSL12 file.  SeaDAS 7.5 should automatically update the luts in the default msl12 file.   
;                        Added ATTACHMENTS keyword to return the name of the email attachement files (e.g. the log file)   
;   NOV 21, 2018 - KJWH: Added steps to determine the number of SERVERS and PROCESSES to run in parallel
;                          Added SERVER and NPROCESS keywords and defaults
;                          Using SERVER_PROCESSES(SERVERS,MAX_PROCESSES=MAXPROCESS) to determine the number of processes to run in parallel and on what servers          
;                          Updated the L1A to L2 processing command to be SCMD = './process_L1A_L2_all.sh -a ' + SENSOR + ' -s' + SERVER_PROCESSES(SERVERS,MAX_PROCESSES=MAXPROCESS)                          
;   NOV 26, 2018 - KJWH: Added steps to WAIT one hour if no servers are currently available and then recheck.  
;                          If after 4 hours, no servers are available, skip to the end of the processing loop.
;   FEB 25, 2019 - KJWH: Added GET_IDLPID to the logfile   
;   MAR 28, 2019 - KJWH: Added step to remove any blank L1S file names    
;   JUL 22, 2019 - KJWH: Changed IF NONE(LOGFILE) THEN LOGFILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log'
;                             to IF NONE(LOGFILE) THEN LOG_FILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log' ELSE LOG_FILE = LOGFILE
;                             so that new logfile is created for each dataset in the loop.     
;                        Changed the LOG directory to be !S.LOGS                
;-
; ***************************
  ROUTINE_NAME='BATCH_SEADAS_L1A'
  PRINT, 'Running: '+ROUTINE_NAME

  ; ===> EMAIL
  MAILTO = 'kimberly.hyde@noaa.gov'

  ; ===> DELIMITERS
  SL    = PATH_SEP()

  ; ===> PARALLEL PROCESSING DEFAULTS
  IF NONE(NPROCESS) THEN NPROCESS = 6 ELSE NPROCESS = 1 > FIX(NPROCESS) < 12 ; Maximum number of processes per server
  IF NONE(SERVERS)  THEN SERVERS = ['satdata','luna']

  ; ===> DEFAULTS
  IF NONE(SENSORS)    THEN SENSORS    = ['MODISA','VIIRS','JPSS1','SEAWIFS'] 
  IF NONE(RUN_WGET)   THEN RUN_WGET   = 0
  IF NONE(GET_ANC)    THEN GET_ANC    = 0 
  IF NONE(DATERANGE)  THEN DATERANGE  = ['1978','2100']
  IF NONE(RUN_L2GEN)  THEN RUN_L2GEN  = 0
  IF NONE(EMAIL_ALL)  THEN EMAIL_ALL  = 0
  IF NONE(PROJECTS)   THEN PROJECTS   = 'DEFAULT'
  
  ; ===> REMOTE FTP LOCATIONS
  OC_CGI    = 'https://oceancolor.gsfc.nasa.gov/cgi/'
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/'

  ; ===> ANCILLARY INFO
  SEADAS_VERSION = '7.4.1'
  OLD_SEADAS = 'seadas-7.2'
  DIR_ANC = !S.SCRIPTS + 'SEADAS/seadas_anc/'
  ANC_DB  = '/usr/local/seadas/ocssw/var/ancillary_data.db' 
  ANC_SCR = '/net/new_linsoft/CentOS7_64bit_local/seadas/ocssw/scripts/';'/usr/local/seadas/ocssw/scripts/'

  ; ===> MODISA LUTS INFO
  DIR_LUTS  = '/usr/local/seadas/ocssw/var/modisa/xcal/OPER/'
  DIR_PREV  = '/usr/local/seadas/ocssw/var/modisa/xcal/PREV/' & DIR_TEST, DIR_PREV
  ;MSL12 = '/usr/local/seadas/ocssw/run/data/hmodisa/msl12_defaults.par'
      
  ; ===> NEFSC 1KM PROCESSING BOUNDARIES
  LATMIN = 22.5 ; 17.92  (Updated 11/7/2016 - KHyde)
  LATMAX = 48.5 ; 55.4
  LONMIN = -82.5 ; -97.8
  LONMAX = -51.5; -43.8
  
  ; ===> DATES
  DT = DATE_NOW()
  D30 = JD_2DATE(JD_ADD(DATE_2JD(DT),-30,/DAY)) ;
  D90 = JD_2DATE(JD_ADD(DATE_2JD(DT),-90,/DAY)) ;

  

  ; ===> WORK WITH PROJECT SPECIFIC FILES
  PDIR2 = []
  L2FILES = []
  SCMDS = []
  FOR PTH=0, N_ELEMENTS(PROJECTS)-1 DO BEGIN
    PROJECT = PROJECTS(PTH)
    IF PROJECT EQ 1 THEN CONTINUE
    CASE PROJECT OF
      'JPSS': BEGIN
        PDIR2 = !S.PROJECTS + 'JPSS/DATA/SATDATA/'
        SENSORS = ['MODISA','JPSS1','VIIRS','SEAWIFS']
        L2FILES = READ_TXT(PDIR2 + 'NEC_SEABASS-L2GEN_SATSHIP_FILES.txt')
        L2FP = FILE_PARSE(L2FILES)
        L2NAMES = L2FP.FIRST_NAME
        DIR_PROCESS = PDIR2
        L2GEN_PAR = !S.SCRIPTS + 'SEADAS/L2GEN_PAR/L2GEN_JPSS_PROJECT.par'
      END
      ELSE: PROJECT=PROJECT ; If a PROJECT is not provided, then continue with the "DEFAULT" processing
    ENDCASE  
  
    ; ===> LOOP THROUGH SENSORS
    FOR STH=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
      SENSOR = STRUPCASE(SENSORS(STH))
      CASE SENSOR OF
        'MODISA':  BEGIN & PREFIX='A' & REPRO_DATE='20180301' & L1NAME = 'L1A_LAC'      & SUFFIX='L2_LAC_SUB_OC'  & THUMB='L2_LAC_OC'   & EXT='.bz2' & END
        'SEAWIFS': BEGIN & PREFIX='S' & REPRO_DATE='20160401' & L1NAME = 'L1A_MLAC'     & SUFFIX='L2_MLAC_OC'     & THUMB='L2_MLAC_OC'  & EXT='.bz2' & END
        'VIIRS':   BEGIN & PREFIX='V' & REPRO_DATE='20200101' & L1NAME = 'L1A_SNPP.nc'  & SUFFIX='L2_OC_SUB'      & THUMB='L2_SNPP_OC'  & EXT=''     & END
        'JPSS1':   BEGIN & PREFIX='V' & REPRO_DATE='20200101' & L1NAME = 'L1A_JPSS1.nc' & SUFFIX='L2_OC_SUB'      & THUMB='L2_JPSS1_OC' & EXT=''     & END
  
        'CZCS':    BEGIN & PREFIX='C' & REPRO_DATE='20160201' & L1NAME = ''             & SUFFIX=''               & THUMB='L2_MLAC_OC'  & EXT='.bz2' & END
        'OCTS':    BEGIN & PREFIX='O' & REPRO_DATE='20200101' & L1NAME = ''             & SUFFIX='' & EXT='' & END
        'MERIS':   BEGIN & PREFIX='M' & REPRO_DATE='20200101' & L1NAME = ''             & SUFFIX='' & EXT='' & END
      ENDCASE
      
  ; ===> SET UP DIRECTORIES    
      DATASET = 'OC-' + SENSOR + '-1KM'
      
      DIR     = !S.OC + SENSOR + SL
      LDIR    = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + SENSOR + SL ; Directory for the BATCH_L1A log
      DIR1    = DIR    + 'L1A'  + SL                     ; L1A direcotry
      L1A_DIR = DIR1 + 'NC' + SL                         ; Permanent directory for the L1A .nc files
      DIR2    = DIR    + 'L2'   + SL                     ; L2 directory
      IF PDIR2 NE [] THEN DIR2 = PDIR2 + SENSOR + SL     ; If a PROJECTS directory is set, then replace the DIR2 with the project specific directory
      
      L2_DIR  = DIR2   + 'NC'   + SL                     ; Permanent directory for the L2 NC files
      LOG_DIR = L2_DIR + 'LOGS' + SL                     ; Permanent directory for the L2GEN log files
      IF NONE(DIR_PROCESS) THEN L1A_PRO = DIR2 + 'PROCESS' + SL ELSE L1A_PRO = DIR_PROCESS + SENSOR + SL + 'PROCESS' + SL                ; Temporary directory to hold the files to be processed by L2GEN
      L1A_CLI = DIR2 + 'CLIMATOLOGY' + SL                ; Temporary directory for files processed with climatology ancillary data
      L1A_OZ  = DIR2 + 'OZONE_ERROR_2019' + SL
      L1A_L30 = DIR2 + 'LAST_30DAYS' + SL                ; Temporary directory for the files collected over the last 30 days
      L1A_L90 = DIR2 + 'CHECK_LUTS' + SL                 ; Temporary directory for the files waiting for refined LUTS (MODISA only)
      
      SUSPECT = DIR2 + 'SUSPECT' + SL                    ; Directory for suspect files
      ERR_DIR = SUSPECT + 'PROCESSING_ERROR' + SL        ; Direcotry for files with processing errors
      OOA_DIR = SUSPECT + 'OUT_OF_AREA' + SL             ; Direcotry for files with all data outside of the NEFSC boundaries
      CLI_DIR = SUSPECT + 'CLIMATOLOGY' + SL             ; Direcotry for files processed with CLIMATOLOGICAL ancillary files
      LUT_DIR = SUSPECT + 'OLD_LUTS'    + SL             ; Direcotry for files processed with out LUTS (MODISA only)
      THUMBS  = SUSPECT + 'THUMBNAILS'  + SL             ; Direcotry for files thumbnails of the suspect files
      PERMAN  = SUSPECT + 'PERMANENT_ERROR' + SL         ; Direcotry for files with permanent processing errors
      GEO_DIR = SUSPECT + 'GEO_ERROR' + SL               ; Direcotry for files with geolocation processing errors
  
      DIR_TEST, [LDIR,LOG_DIR,L2_DIR,ERR_DIR,OOA_DIR,CLI_DIR,THUMBS,PERMAN,GEO_DIR,L1A_CLI,L1A_OZ,L1A_L30,L1A_PRO]
      IF SENSOR EQ 'MODISA' THEN DIR_TEST, [L1A_L90,LUT_DIR]
      
      IF NONE(LOGFILE) THEN LOG_FILE = LDIR + SENSOR + '_' + DATE_NOW(/DATE_ONLY) + '.log' ELSE LOG_FILE = LOGFILE
      OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180
      PLUN, LUN, '******************************************************************************************************************',3
      PLUN, LUN, 'Initializing ' + ROUTINE_NAME + ' log file for: ' + SENSOR + ' at: ' + systime() + ' on ' + !S.COMPUTER, 0
      PLUN, LUN, 'PID=' + GET_IDLPID() ; ***** NOTE, may not be accurate with IDLDE sessions *****
      PLUN, LUN, '******************************************************************************************************************'
      
      PLUN, LUN, 'Checking ' + SENSOR + ' files...', 0
  
      ; ===> If the SeaDAS processing creates new files, recheck the files
      SECOND_CHECK = 0
      RERUN_CHECK_FILES:
      IF SECOND_CHECK EQ 1 THEN PLUN, LUN, 'Rechecking files after SeaDAS processing...'
  
      ; ===> Create NULL variables
      PROCESS_L1S       = []                                                             ; Create a list of files that need to be processed
      SUCCESSFUL_L2S    = []                                                             ; Create a list of files that were successfully processed
      CLIMATOLOGY       = [] & CLI_LOGS  = [] & SEADAS72 = []                            ; Create a list of climatologically, climatology logs and SeaDAS 7.2generated files
      PROCESSING_ERROR  = [] & GEO_ERROR = []                                            ; Create a list of suspect and geolocation error files
      OUT_OF_AREA       = [] & OOA_NAMES = []                                            ; Create a list of suspect out of area files
      L2GEN_OUT_OF_AREA = [] & L2O_NAMES = []
      THUMBNAILS        = []
      EMAIL_ATTACHMENTS = []
  
      ; ===> Look for accessory (GEO) files that should have been deleted after running l2gen
      GEOS = FILE_SEARCH(L2_DIR + '*GEO*', COUNT=COUNT_GEOS)
      IF COUNT_GEOS GE 1 THEN FILE_DELETE, GEOS, /VERBOSE
      
      ; ===> Look for GEO files in the L1A dir (common with the VIIRS data)
      GEOS = FILE_SEARCH(L1A_DIR + '*GEO*', COUNT=COUNT_GEOS)
      IF COUNT_GEOS GE 1 THEN FILE_DELETE, GEOS, /VERBOSE
  
      ; ===> Search for L1A files in the main L1 directory
      L1S = FILE_SEARCH(L1A_DIR + PREFIX + '*' + L1NAME + '*bz2', COUNT=COUNT_L1A)                          ; Only looking for .bz2 files in L1A_DIR
      IF PREFIX EQ 'V' THEN L1S = [L1S,FILE_SEARCH(L1A_DIR + PREFIX + '*' + L1NAME, COUNT=COUNT_L1A)]       ; VIIRS files are not zipped when downloaded so look for .nc files
      L1S = L1S[WHERE(L1S NE '',/NULL)]
      IF L1S EQ [] THEN CONTINUE
      
      IF L2FILES NE [] THEN BEGIN                 
        FP = FILE_PARSE(L1S)                                                                                ; Parse the file name
        OK = WHERE_MATCH(FP.FIRST_NAME,L2NAMES,COUNT_L1S,COMPLEMENT=COMPLEMENT,VALID=VALID)                 ; Find names that match the L2NAMES in the project file list  
        IF COUNT_L1S GE 1 THEN L1S = L1S[OK] ELSE CONTINUE                                                  ; Subset the files based on the project file list
      ENDIF ELSE L1S = DATE_SELECT(L1S, DATERANGE,COUNT=COUNT_L1S)                                          ; Subset the files based on the daterange
      
      FP = FILE_PARSE(L1S) & L1SUFFIX = STRMID(FP[0].NAME_EXT,STRPOS(FP[0].NAME_EXT,'.'))                   ; Parse the file names
      PLUN, LUN, 'Found ' + NUM2STR(COUNT_L1S) + ' L1A files'
      L30 = DATE_SELECT(L1S,[D30,DT],COUNT=COUNT30) &  FP30 = FILE_PARSE(L30)                               ; Create a list of files from the past 30 days
      IF SENSOR EQ 'MODISA' THEN BEGIN ; Create a list of files from the past 90 days to check for the most recent LUTS
        L90  = [FLS(L1A_L90 + PREFIX + '*' + L1NAME + '*'),DATE_SELECT(L1S,[D90,D30])] ; Find files currently in the L90 directory and additional files collected within the last 90 days
        FP90 = FILE_PARSE(L90)
        SFP = SORTED(FP90,TAG='FIRST_NAME') & UFP = UNIQ(SFP.FIRST_NAME)
        FP90 = SFP(UFP) & COUNT90 = N_ELEMENTS(FP90)    
        IF COUNT90 EQ 1 AND L90[0] EQ '' THEN COUNT90 = 0                     
      ENDIF ELSE COUNT90 = 0  
  
  
      ; ===> Find FILES that are in the PERMANENT_ERROR and OUT_OF_AREA directories and remove any L1As, LOGS, or L2s from the main directories and update the THUMBNAILS
      PDIRS = [OOA_DIR,PERMAN]
      FOR N=0, N_ELEMENTS(PDIRS)-1 DO BEGIN
        PDIR = PDIRS(N)
        PERRS = FLS(PDIR + PREFIX + '*.*',COUNT=COUNT_PERR) 
        IF COUNT_PERR GE 1 THEN BEGIN
          FL = FILE_PARSE(PERRS)
          PSETS = WHERE_SETS(FL.FIRST_NAME);, FL.FIRST_NAME, COUNT, COMPLEMENT=COMPLEMENT, VALID=VALID)
          PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(PSETS)) + ' file sets in ' + PDIR + '...'
          
          PL1 = L1A_DIR + PSETS.VALUE + '.' + L1NAME 
          PLZ = [PL1+'.x.hdf',PL1+'.x.hdf.bz2', PL1+'.bz2']                               ; Create zipped versions of the L1A files (including the SeaWiFS version with .x.hdf)
          PL2 = L2_DIR  + PSETS.VALUE + '.' + SUFFIX                                      ; Create L2 file names from the L1S
          PLG = L2_DIR  + PSETS.VALUE + '.LOG'                                            ; Create LOG file names for files in the L2_DIR
          PLF = LOG_DIR + PSETS.VALUE + '.LOG'  
          THUMBNAILS = [THUMBNAILS, PLG]
          
          PMFILES = [PLZ,PL1,PL2,PLG,PLF]
          PMFILES = PMFILES[WHERE(FILE_TEST(PMFILES) EQ 1,/NULL,COUNT_PMF)]
          FOR I=0, COUNT_PMF-1 DO PLUN, LUN, 'Moving ' + PMFILES(I) + ' to ' + PDIR, 0
          IF PMFILES NE [] THEN FILE_MOVE, PMFILES, PDIR, /OVERWRITE                      ; Move the files to the SUSPECT error directories
          
          PRZ = []
          TMP = [L1A_PRO,L1A_CLI,L1A_L30,L1A_L90]
          FOR T=0, N_ELEMENTS(TMP)-1 DO PRZ = [PRZ,TMP(T) + PSETS.VALUE + '.' +  L1NAME]  ; Create L1A file names for files in the TEMP directories
          PRZ = [PRZ,PRZ+'.x.hdf',PRZ+'.x.hdf.bz2',PRZ+'.bz2']
          PRZ = PRZ[WHERE(FILE_TEST(PRZ) EQ 1,/NULL,COUNT_PRZ)]
          FOR I=0, COUNT_PRZ-1 DO PLUN, LUN, 'Removing ' + PRZ(I), 0 
          IF PRZ NE [] THEN FILE_DELETE, PRZ                                              ; Remove the files from L1A PROCESS
          
          EFILES = THUMBS + PSETS.VALUE + '.' + THUMB + '.nc_CHLOR_A_BRS.png'  
          EFILES = EFILES[WHERE(FILE_TEST(EFILES) EQ 1,/NULL,COUNT_EFILES)]
          IF COUNT_EFILES GT 0 THEN FILE_UPDATE, EFILES, PDIR
        ENDIF ; IF OUT_OF_AREA NE [] THEN BEGIN
      ENDFOR ; PDIRS    
       
      
      ; ===> Create L2 and LOG file names and look for new LOG files that need to be checked
      L2S  = L2_DIR + FP.FIRST_NAME + '.' + SUFFIX                                      ; Create L2 file names from the L1S
      LOGS = L2_DIR + FP.FIRST_NAME + '.LOG'                                            ; Create LOG file names for files in the L2_DIR
      OK = WHERE(FILE_TEST(LOGS) EQ 0,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMP)    ; Find LOG files that need to be checked and moved (note, LOG files are initially in the NC directory and only moved once validated)
      IF NCOMP EQ 0 THEN GOTO, SKIP_LOGS                                                ; If no LOG files in the L2_DIR skip LOG check steps >>>>>>>>
      
      ; ===> Subset to only the LOG files that need to be checked
      LOGS = LOGS(COMPLEMENT)
      L2S = L2S(COMPLEMENT)
      L1S = L1S(COMPLEMENT)
      FP = FP(COMPLEMENT)
  
      ; ===> Read each LOG files and look for geolocation, climatology or processing ERRORS
      PLUN, LUN, 'Checking ' + ROUNDS(N_ELEMENTS(LOGS)) + ' LOG files...'
      FOR LTH=0, N_ELEMENTS(LOGS)-1 DO BEGIN
  if file_test(logs[LTH]) eq 0 then stop 
        LOG = READ_TXT(LOGS[LTH])                                                       ; Read the LOG file
  if file_test(logs[LTH]) eq 0 then stop    
        ; ===> Look for indications that the file was processed with the climatology ancillary files
        OK = [WHERE_STRING(LOG,'met_clim',COUNTM),WHERE_STRING(LOG,'ozone_clim',COUNTO),WHERE_STRING(LOG,'l2gen status: 0',COUNTL)]
        IF COUNTL GT 0 THEN IF COUNTM GT 0 OR COUNTO GT 0 THEN BEGIN                            ; Create list of files that were succefully created files, but were processed with CLIMATOLOGICAL met or ozone files
          CLIMATOLOGY = [CLIMATOLOGY,L2S[LTH]]
          CLI_LOGS    = [CLI_LOGS,LOGS[LTH]]
          CONTINUE
        ENDIF
  
        ; ===> Look for files that were processed with older versions of seadas
        OK = WHERE_STRING(LOG,OLD_SEADAS,COUNTS)                                                 ; Create a list of files created with an older version of SeaDAS (e.g. 7.2) 
        IF COUNTS GT 0 THEN BEGIN
          SEADAS72 = [SEADAS72,LOGS[LTH],L2S[LTH]]
          CONTINUE
        ENDIF
  
        ; ===> Look for files that were created successfully (l2gen status: 0)
        IF WHERE_STRING(LOG, 'l2gen status: 0') NE [] THEN BEGIN                                ; l2gen status: 0 = L2A file was successfully created
          SUCCESSFUL_L2S = [SUCCESSFUL_L2S,L2S[LTH]]                                            ; Compile a list of successful L2 files not created with climatology met or ozone files
          FILE_MOVE, LOGS[LTH], LOG_DIR, /VERBOSE, /OVERWRITE                                   ; Move the log files to the permanent log directory
          CONTINUE
        ENDIF
        
        ; ===> Create a list of thumbnail images to download for files that were either out of area or had some processing errors 
        THUMBNAILS = [THUMBNAILS,LOGS[LTH]]
        
        ; ===> Look for files that had a geolocation processing erro
        IF WHERE_STRING(LOG,'ERROR: MODIS geolocation processing failed.') NE [] THEN BEGIN
          GEO_ERROR = [GEO_ERROR,LOGS[LTH]]                                                     ; Geolocation error
          CONTINUE
        ENDIF
  
        ; ===> Look for files data are out of area [THIS SECTION STILL NEEDS WORK]
        IF WHERE_STRING(LOG,'No pixels in swath fall within the specified coordinates.') NE [] THEN BEGIN
          IF WHERE_STRING(LOG,'No such file or directory') NE [] THEN CONTINUE                 ; Geo file not created correctly or ancillary data is missing
          IF WHERE_STRING(LOG,'HDP ERROR') NE [] THEN CONTINUE                                 ; File not read correctly
          OUT_OF_AREA = [OUT_OF_AREA,LOGS[LTH],L2S[LTH]]                                       ; Error indicates there were no pixels in the area of interest
          CONTINUE
        ENDIF
        
        ; ===> Look for files data are out of area
        IF WHERE_STRING(LOG,'-E- l2gen: north, south, east, west box not in this file.') NE [] THEN BEGIN
          L2GEN_OUT_OF_AREA = [L2GEN_OUT_OF_AREA,LOGS[LTH],L2S[LTH]]
          CONTINUE
        ENDIF
  
        ; ===> Remaining files with unknown processing error
        PROCESSING_ERROR = [PROCESSING_ERROR,LOGS[LTH],L2S[LTH]]                               ; Other processing error
      ENDFOR ; FOR LTH=0, N_ELEMENTS(LOGS)-1 DO BEGIN
  
      ; ===> List the L2 files that successfully created
      PLUN, LUN, ROUNDS(N_ELEMENTS(SUCCESSFUL_L2S)) + ' files were successfully created.'
      IF SUCCESSFUL_L2S NE [] THEN FOR I=0, N_ELEMENTS(SUCCESSFUL_L2S)-1 DO PLUN, LUN, 'Successfully created ' + SUCCESSFUL_L2S(I), 0
  
      SKIP_LOGS: ; If no log files were found to analyze, jump to here
  
      ; ===> Remove L2 files that were processed with an older version of seadas 7.2 
      IF SEADAS72 NE [] THEN BEGIN
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(SEADAS72)) + ' files using SeaDAS 7.2 met and/or ozone ancillary files'
        FOR I=0, N_ELEMENTS(SEADAS72)-1 DO PLUN, LUN, 'Moving ' + SEADAS72(I) + ' to ' + SUSPECT
        FILE_MOVE, SEADAS72, SUSPECT, /OVERWRITE
      ENDIF
  
      ; ===> Get PROCESSING_ERROR thumbnails
      IF THUMBNAILS NE [] THEN BEGIN
        THUMBNAILS = THUMBNAILS[UNIQ(THUMBNAILS)]
        PRO_NAMES = (FILE_PARSE(THUMBNAILS)).FIRST_NAME
        TFILES = THUMBS    + PRO_NAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png'
    
        OKT = WHERE(FILE_TEST(TFILES) EQ 0, COUNT_TFILES)
        IF COUNT_TFILES GE 1 AND KEY(RUN_WGET) THEN BEGIN
          CD, THUMBS
          EFILES = OC_BROWSE + PRO_NAMES(OKT) + '.' + THUMB + '.nc_CHLOR_A_BRS.png?sub=l12image&file=' + PRO_NAMES(OKT) + '.' + THUMB + '.nc_CHLOR_A_BRS'
          PLUN, LUN, 'Downloading thumbnail ' + EFILES, 0      
          PLUN, LUN, 'Downloading ' + ROUNDS(COUNT_TFILES) + ' PROCESSING ERROR thumbnails...',0
          W = WGET(EFILES)
        ENDIF     
      ENDIF  
      CD, !S.PROGRAMS
  
      ; ===> Remove files that had processing errors
      IF PROCESSING_ERROR NE [] THEN BEGIN
        PROCESSING_ERROR = PROCESSING_ERROR[WHERE(FILE_TEST(PROCESSING_ERROR) EQ 1)]
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(PROCESSING_ERROR)) + ' files with processing errors.'
        FOR I=0, N_ELEMENTS(PROCESSING_ERROR)-1 DO PLUN, LUN, 'Moving ' + PROCESSING_ERROR(I) + ' to ' + ERR_DIR, 0
        FILE_MOVE, PROCESSING_ERROR, ERR_DIR, /OVERWRITE
        
        ; Update THUMBNAIILS
        TNAMES = (FILE_PARSE(FLS(ERR_DIR + PREFIX + '*LOG'))).FIRST_NAME
        EFILES = TNAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png'
        FILE_UPDATE, THUMBS+EFILES, ERR_DIR
        
      ENDIF ; IF PROCESSING_ERROR NE [] THEN BEGIN
  
      ; ===> Remove LOG files that had geolocation errors
      IF GEO_ERROR NE [] THEN BEGIN
        GEO_ERROR = GEO_ERROR[WHERE(FILE_TEST(GEO_ERROR) EQ 1)]
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(GEO_ERROR)) + ' files with geolocation errors.'
        FOR I=0, N_ELEMENTS(GEO_ERROR)-1 DO PLUN, LUN, 'Moving ' + GEO_ERROR(I) + ' to ' + GEO_DIR, 0
        FILE_MOVE, GEO_ERROR, GEO_DIR, /VERBOSE, /OVERWRITE
        
        ; Update THUMBNAIILS
        TNAMES = (FILE_PARSE(FLS(GEO_DIR + PREFIX + '*LOG'))).FIRST_NAME
        EFILES = TNAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png'
        FILE_UPDATE, THUMBS+EFILES, GEO_DIR
      ENDIF ; IF GEO_ERROR NE [] THEN BEGIN
  
      ; ===> Find L2 files that do not have a corresponding LOG file
      L2S = FILE_SEARCH(L2_DIR + PREFIX + '*' + SUFFIX, COUNT=COUNT_L2S) & FL2 = FILE_PARSE(L2S)
      OK = WHERE(FILE_TEST(LOG_DIR + FL2.NAME + '.LOG') EQ 0 AND FILE_TEST(L2_DIR + FL2.NAME + '.LOG') EQ 0, COUNT_LOGS)
      IF COUNT_LOGS GE 1 AND COUNT_L2S GT 0 THEN BEGIN
        FOR I=0, N_ELEMENTS(L2S[OK])-1 DO PLUN, LUN, ROUNDS(I+1) + ': Delete and reprocess ' + L2S(OK(I))
        FILE_DELETE, L2S[OK]
        PLUN, LUN, 'Found ' + ROUNDS(COUNT_LOGS) + ' L2 files without corresponding LOG files.  DELETE and REPROCESS...'
      ENDIF
  
      ; ===> Remove L1 files that are OUT-OF-AREA
      IF OUT_OF_AREA NE [] THEN OUT_OF_AREA = OUT_OF_AREA[WHERE(FILE_TEST(OUT_OF_AREA) EQ 1,/NULL)]
      IF OUT_OF_AREA NE [] THEN BEGIN
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(OUT_OF_AREA)) + ' files that do not contain data within the area of interest.'
        FOR I=0, N_ELEMENTS(OUT_OF_AREA)-1 DO PLUN, LUN, 'Moving ' + OUT_OF_AREA(I) + ' to ' + OOA_DIR, 0
        ; CAUTION ; SEVERAL FILES ARE BEING FLAGGED AS "OUT OF AREA", BUT THE ERROR IDENTIFICATION IS WRONG AND THESE FILES SHOULD NOT BE REMOVED FROM THE MAIN DATABASE
        FILE_MOVE, OUT_OF_AREA, OOA_DIR, /OVERWRITE
        
        TNAMES = (FILE_PARSE(FLS(OOA_DIR + PREFIX + '*LOG'))).FIRST_NAME
        EFILES = THUMBS + TNAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png'
        FILE_UPDATE, EFILES, OOA_DIR
      ENDIF ; IF OUT_OF_AREA NE [] THEN BEGIN
     
  
      ; ===> Find OUT-OF-AREA files in L1A & L1A_PROCESS that should be removed
      OOA = FILE_SEARCH(OOA_DIR + PREFIX + '*LOG',COUNT=COUNTO)
      IF COUNTO GE 1 THEN BEGIN
        FO = FILE_PARSE(OOA)
        L1R = [L1A_PRO + FO.NAME + L1SUFFIX, L1A_PRO + FO.NAME + L1SUFFIX + '.bz2']       ; Files in L1A_PROCESS
        L1R = [L1R, L1A_DIR + FO.NAME + L1SUFFIX, L1A_DIR + FO.NAME + L1SUFFIX + '.bz2']  ; Unzipped files on L1A_DIR
        L1R = L1R[WHERE(FILE_TEST(L1R) EQ 1,/NULL,COUNTR)]
        IF COUNTR GE 1 THEN BEGIN
          PLUN, LUN, 'Found ' + ROUNDS(COUNTR) + ' L1A files in L1A_PROCESS and L1A_DIR that correspond to OUT-OF-AREA files...'
          FOR I=0, COUNTR-1 DO PLUN, LUN, ROUNDS(I+1) + ': Deleting ' + L1R(I),0
          FILE_DELETE, L1R
        ENDIF   
      ENDIF
  
      ; ===> Check L2 files that were processed with climatology met or ozone files and remove if updated ancillary files are available
      IF CLIMATOLOGY NE [] THEN BEGIN
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(CLIMATOLOGY)) + ' L2 files using climatology met and/or ozone ancillary files'
        FOR I=0, N_ELEMENTS(CLIMATOLOGY)-1 DO BEGIN
          CLIM = CLIMATOLOGY(I)
          CLIM_LOG = CLI_LOGS(I) 
          CFP = FILE_PARSE(CLIM) 
          CFILE = L1A_CLI + CFP.FIRST_NAME + '.' + L1NAME
          LFILE = L1A_DIR + CFP.FIRST_NAME + '.' + L1NAME  
          ZFILE = L1A_DIR + CFP.FIRST_NAME + '.' + L1NAME + '.bz2'
          IF ~EXISTS(CFILE) AND ~EXISTS(CFILE + '.bz2') THEN BEGIN
            PLUN, LUN, 'Moving ' + LFILE + ' to ' + L1A_CLI, 0
            IF EXISTS(ZFILE) THEN FILE_COPY, ZFILE, L1A_CLI                              ; Copy the bz2 file to L1A_CLI
            IF ~EXISTS(CFILE + '.bz2') AND EXISTS(LFILE) THEN FILE_COPY, LFILE, L1A_CLI  ; Copy the unzipped file to L1A_CLI
          ENDIF
        ENDFOR  
      ENDIF ; IF CLIMATOLOGY NE [] then try to update the ancillary files 
      
      ; ===> Review the files collected within the last 30 days and update the ancillary files (to replace the climatology)    
      IF COUNT30 GT 0 THEN BEGIN
        PLUN, LUN, 'Found ' + ROUNDS(COUNT30) + ' files collected within the last 30 days'
        FOR L=0, COUNT30-1 DO BEGIN ; Move files from the last 30 days to L1A_L30
          F30 = FP30[L]   
          CFILE = L1A_L30 + F30.FIRST_NAME + '.' + L1NAME
          LFILE = L1A_DIR + F30.FIRST_NAME + '.' + L1NAME 
          ZFILE = L1A_DIR + F30.FIRST_NAME + '.' + L1NAME + '.bz2'
          IF ~EXISTS(CFILE) AND ~EXISTS(CFILE + '.bz2') THEN BEGIN
            PLUN, LUN, 'Moving ' + LFILE + ' to ' + L1A_L30, 0
            IF EXISTS(ZFILE) THEN FILE_COPY, ZFILE, L1A_L30                              ; Copy the bz2 file to L1A_L30
            IF ~EXISTS(CFILE + '.bz2') AND EXISTS(LFILE) THEN FILE_COPY, LFILE, L1A_L30  ; Copy the unzipped file to L1A_L3
          ENDIF
        ENDFOR  
      ENDIF ; IF COUNT30 GT 0  
            
      ; ===> Look for new LUTS files for the L90 MODISA files
      IF SENSOR EQ 'MODISA' AND SECOND_CHECK EQ 0 THEN BEGIN
        ; ===> Get current LUTS
        CHECK_LUTS = 0
        RECHECK_LUTS:
        CLUTS = FLS(DIR_LUTS + '*.*')
        LUTS = (FILE_PARSE(CLUTS)).NAME
        FOR L=0, N_ELEMENTS(LUTS)-1 DO LUTS[L] = STRMID(LUTS[L],0,STRPOS(LUTS[L],'_',/REVERSE_SEARCH))
        IF ~SAME(LUTS) THEN BEGIN
          LUTDATES = STRMID(GET_MTIME(CLUTS,/DATE),0,8)
          OK = WHERE(DATE_2JD(LUTDATES) NE MAX(DATE_2JD(LUTDATES)),COUNT_PREV,COMPLEMENT=COMP_LUT)
          IF COUNT_PREV GT 0 THEN BEGIN
            PLUN, LUN, 'Found more than 1 set of LUTS in ' + DIR_LUTS, 0
            PLUN, LUN, 'Removing old LUTS from ' + DIR_LUTS, 0
         ;   FILE_MOVE, CLUTS(OK), DIR_PREV 
          ENDIF ELSE MESSAGE, 'ERROR: Double check LUTS in ' + DIR_LUTS
        ENDIF ELSE COMP_LUT = 0
        LUT = LUTS(COMP_LUT[0])
        
        ; ===> Check for new LUTS
        PLUN, LUN, 'Checking for new MODISA LUTS'
        CMD = ANC_SCR + 'update_luts.py -v aqua'
        PLUN, LUN, CMD, 0
        SPAWN, CMD, LUTSLOG, LUTSERR
        CHECK_LUTS = CHECK_LUTS + 1
        WAIT, 10
        IF WHERE_STRING(LUTSLOG,'OPER:xcal') NE [] AND CHECK_LUTS LE 2 THEN BEGIN
          FOR L=0, N_ELEMENTS(LUTSLOG)-1 DO PLUN, LUN, LUTSLOG[L],0
          GOTO, RECHECK_LUTS
        ENDIF  
        
      ;  PARTXT = READ_TXT(MSL12)
      ;  OK = WHERE_STRING(PARTXT,'xcalfile',COUNT)
      ;  IF PARTXT(OK) NE 'xcalfile=$OCVARROOT/modisa/xcal/OPER/' + LUT THEN BEGIN
      ;    PARTXT(OK) = 'xcalfile=$OCVARROOT/modisa/xcal/OPER/' + LUT
      ;    FILE_COPY, MSL12, DIR_PREV+'msl12_defaults-replaced_'+DATE_NOW(/DATE_ONLY)+'.par',/VERBOSE
      ;    WRITE_TXT, MSL12, PARTXT
      ;    PLUN, LUN, 'Updated msl12_defaults.par file'
      ;  ENDIF
        
        FOR L=0, COUNT90-1 DO BEGIN ; Move files from the last 90 days to CHECK_LUTS if the LUTS are not current
          F90 = FP90[L]   
          CFILE = L1A_L90 + F90.FIRST_NAME + '.' + L1NAME
          LFILE = L1A_DIR + F90.FIRST_NAME + '.' + L1NAME 
          ZFILE = L1A_DIR + F90.FIRST_NAME + '.' + L1NAME + '.bz2'
          CL90  = L2_DIR  + F90.FIRST_NAME + '.' + SUFFIX
          CLOG  = LOG_DIR + F90.FIRST_NAME + '.LOG'
          SATDATE = SATDATE_2DATE(F90.FIRST_NAME)
          
          IF EXISTS(CLOG) THEN BEGIN
            L90 = READ_TXT(CLOG)
            OK = WHERE_STRING(L90,'Loading XCAL',COUNT)
            IF COUNT GE 1 THEN BEGIN
              XCAL = (FILE_PARSE(L90(OK[0]))).NAME
              XCAL = STRMID(XCAL,0,STRPOS(XCAL,'_',/REVERSE_SEARCH))
              IF XCAL EQ LUT THEN BEGIN 
                IF EXISTS(CFILE) AND DATE_2JD(SATDATE) LT DATE_2JD(D90) THEN FILE_DELETE, CFILE, /VERBOSE ; Remove the L1A file from the LUTS dir if it is older than 90 days and the LUTS are current
                CONTINUE
              ENDIF  
            ENDIF  
          ENDIF
          
          IF EXISTS(CL90) THEN FILE_MOVE, CL90, LUT_DIR, /VERBOSE, /OVERWRITE ; Move L2 file with the old LUTS so it can be recreated
          IF EXISTS(CLOG) THEN FILE_MOVE, CLOG, LUT_DIR, /VERBOSE, /OVERWRITE        
          IF ~EXISTS(CFILE) AND ~EXISTS(CFILE + '.bz2') THEN BEGIN
            PLUN, LUN, 'Moving ' + LFILE + ' to ' + L1A_L90, 0
            IF EXISTS(ZFILE) THEN FILE_COPY, ZFILE, L1A_L90                              ; Copy the bz2 file to L1A_L90
            IF ~EXISTS(CFILE + '.bz2') AND EXISTS(LFILE) THEN FILE_COPY, LFILE, L1A_L90  ; Copy the unzipped file to L1A_L90
          ENDIF
        ENDFOR  ; FOR L=0, COUNT90-1 DO BEGIN
          
        CD, !S.PROGRAMS
      ENDIF ; IF SENSOR EQ 'MODISA' (TO UPDATE LUTS)  
          
      ; ===> Search for L1A files in the main L1 directory
      L1S = FLS(L1A_DIR + PREFIX + '*' + L1NAME + '*bz2', COUNT=COUNT_L1A,DATERANGE=DATERANGE)                        ; Only looking for .bz2 files in L1A_DIR
      IF PREFIX EQ 'V' THEN L1S = [L1S,FLS(L1A_DIR + PREFIX + '*' + L1NAME, COUNT=COUNT_L1A,DATERANGE=DATERANGE)]     ; VIIRS files are not zipped when downloaded so look for .nc files
      IF L2FILES NE [] THEN BEGIN
        FP = FILE_PARSE(L1S)                                                                                         ; Parse the file name
        OK = WHERE_MATCH(FP.FIRST_NAME,L2NAMES,COUNT_L1S,COMPLEMENT=COMPLEMENT,VALID=VALID)                          ; Find names that match the L2NAMES in the project file list
        IF COUNT_L1S GE 1 THEN L1S = L1S[OK] ELSE CONTINUE                                                           ; Subset the files based on the project file list
      ENDIF ELSE L1S = DATE_SELECT(L1S, DATERANGE,COUNT=COUNT_L1S)                                                   ; Subset the files based on the daterange
      FP = FILE_PARSE(L1S) & L1SUFFIX = STRMID(FP[0].NAME_EXT,STRPOS(FP[0].NAME_EXT,'.'))                            ; Parse the file names
      
      ; ===> Create L2 file names and find files that are missing
      L2S = L2_DIR + FP.FIRST_NAME + '.' + SUFFIX                                                                    ; Create L2 file names from the L1S
      OK = WHERE(FILE_TEST(L2S) EQ 0, COUNT_PROCESS, COMPLEMENT=GOOD_L2S, NCOMP=NL2S)                                ; Look for L2 files that do not exist
      IF COUNT_PROCESS GE 1 THEN PROCESS_L1S = L1S[OK]                                                               ; Add the "missing" files to the process list   
          
      ; ===> Move files that still need to be processed   
      IF COUNT_PROCESS GE 1 THEN BEGIN
        L1A = L1A_PRO + (FILE_PARSE(PROCESS_L1S)).NAME_EXT
      ;  L1A = REPLACE(PROCESS_L1S, [SL+'L1A'+SL+'NC'+SL,'LAST_30DAYS','CHECK_LUTS','.bz2'],[SL+'L2'+SL+'PROCESS'+SL,'PROCESS','PROCESS',''])  ; Create unzipped file names in L1A_PROCESS
        OK  = WHERE(FILE_TEST(REPLACE(L1A,'.bz2','')) EQ 0 AND FILE_TEST(L1A) EQ 0, COUNT)                                               ; Find which L1A files are missing from L1A_PROCESS
        IF COUNT GE 1 THEN BEGIN
          PLUN, LUN, 'Moving ' + ROUNDS(COUNT) + ' files to PROCESS...'
          FOR I=0, COUNT-1 DO PLUN, LUN, ROUNDS(I+1) + ': Copying ' + PROCESS_L1S[OK[I]] + ' to ' + L1A_PRO, 0
          FILE_COPY, PROCESS_L1S[OK], L1A_PRO, /OVERWRITE                        ; Copy L1A.bz2 files to L1A_PROCESS
        ENDIF
      ENDIF
  
      ; ===> Look for duplicate files (zipped and unzipped) in L1A_PROCESS
      L1A_FILES = FLS(L1A_PRO + '*.*', COUNT=COUNT_L1A)     
      FP_L1A = FILE_PARSE(L1A_FILES)
      DPS = WHERE_DUPS(FP_L1A.FIRST_NAME,COUNT_DPS)
      IF COUNT_DPS GT 1 THEN PLUN, LUN, 'Found duplicate L1A files in L1A_PROCESS...'
      FOR ST=0, N_ELEMENTS(DPS)-1 DO BEGIN
        SUBS = WHERE_SETS_SUBS(DPS[ST])
        SET  = FP_L1A[SUBS]
        OK = WHERE(SET.EXT EQ 'bz2',COUNTB)
        IF COUNTB GE 1 THEN BEGIN
          FILE_DELETE, SET[OK].FULLNAME                      ; Removed duplicate zipped file if the unzipped file already exists
          PLUN, LUN, 'Removing duplicate file ' + SET[OK].FULLNAME + ' from L1A_PROCESS...',0
        ENDIF  
      ENDFOR
         
      ; ===> Zipped files
      BZ2 = FLS(L1A_PRO + '*.bz2', COUNT=COUNT_BZ2, DATERANGE=DATERANGE)    ; Create list of zipped files in L1A_PROCESS
      BZ2 = [BZ2,FLS(L1A_L90 + '*.bz2',COUNT=COUNT_NBZ2)]                   ; Add zipped files in L1A_L90
      BZ2 = [BZ2,FLS(L1A_L30 + '*.bz2',COUNT=COUNT_FBZ2)]                   ; Add zipped files in L1A_L30
      BZ2 = [BZ2,FLS(L1A_CLI + '*.bz2',COUNT=COUNT_CBZ2)]                   ; Add zipped files in L1A_CLI
      COUNT_BZ2 = TOTAL([COUNT_BZ2,COUNT_NBZ2,COUNT_FBZ2,COUNT_CBZ2])
      
      ; ===> Unzip files that are in L1A_PROCESS
      IF COUNT_BZ2 GE 1 THEN BEGIN
        BZ2 = BZ2[WHERE(BZ2 NE '')]
        UNZIP_FILE = DIR + 'UNZIP_FILES.txt'
        WRITE_TXT, UNZIP_FILE, BZ2
        PLUN, LUN, 'Unzipping L1A files...', 1
        FOR I=0, N_ELEMENTS(BZ2)-1 DO PLUN, LUN, ROUNDS(I+1) + ': Unzipping ' + BZ2(I), 0
        CD, !S.SCRIPTS
        CMD = 'parzip -d -F ' + UNZIP_FILE
        PLUN, LUN, CMD
        SPAWN, CMD, ZIPLOG, ZIPERR
        PLUN, LUN, ZIPLOG
        CD, !S.PROGRAMS
        WAIT, 30
        FT = WHERE(FILE_TEST(BZ2) EQ 1, COUNT_BZ2)
        IF COUNT_BZ2 GT 0 THEN BEGIN        
          PLUN, LUN, 'ERROR: Zipped files still exist in ' + L1A_PRO
          FOR I=0, N_ELEMENTS(FT)-1 DO PLUN, LUN, ROUNDS(I+1) + ': ERROR unzipping ' + BZ2(FT(I)), 0
          PLUN, LUN, ZIPERR
          ZIP_TEMP = !S.IDL_TEMP + 'ZIPERR.txt'
          WRITE_TXT, ZIP_TEMP, ZIPERR
          EMAIL_ATTACHMENTS = [EMAIL_ATTACHMENTS,ZIPERR]
        ;  SPAWN,'echo -e "PARZIP ERROR log from ' + DATE_NOW(/DATE_ONLY) + '" | mailx -s "PARZIP ERROR LOG ' + SYSTIME() + '" ' + ' -a ' + TEMP + ' ' + MAILTO
        ENDIF  
      ENDIF ELSE PLUN, LUN, 'No zipped files found'
      CD, !S.PROGRAMS
    
      ; ===> Remove successfully processed files from L1A_PROCESS
      L1FP = FILE_PARSE(FLS(L1A_PRO + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2','',COUNT=COUNT_L1FP))) ; Find all files currently in L1A_PROCESS
      L2S = L2_DIR + L1FP.FIRST_NAME + '.' + SUFFIX                               ; Find all of the successfully processed L2 files
      OK  = WHERE(EXISTS(L2S) EQ 1,COUNT_GOOD)                                    ; Compare the files in L1A_PRO and those in the L1A_PROCESS list
      IF COUNT_GOOD GT 0 THEN BEGIN
        PLUN, LUN, 'Removing successfully processed L1A files...'
        FOR I=0, COUNT_GOOD-1 DO PLUN, LUN, ROUNDS(I+1) + ': Deleting ' + L1FP[OK[I]].FULLNAME, 0
        FILE_DELETE, L1FP[OK].FULLNAME                                            ; Remove files from L1A_PRO that are not in the L1A_PROCESS list
      ENDIF
    
      ; ===> Get ancillary data for files in L1A_PROCESS, L1A_CLI, L1A_L30 and CHECK_LUTS
      L1P = FLS(L1A_PRO + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_L1P)
      CLI = FLS(L1A_CLI + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_CLI)
      F30 = FLS(L1A_L30 + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_L30)
      F90 = FLS(L1A_L90 + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_L90)
  
      AFP = FILE_PARSE([L1P,CLI,F30,F90])
      SFP = SORTED(AFP,TAG='NAME_EXT')
      UFP = UNIQ(SFP.NAME_EXT)
      LANC = SFP(UFP).FULLNAME
      LANC = DATE_SELECT(LANC, DATERANGE)
      COUNT_LANC = N_ELEMENTS(LANC)
      IF COUNT_LANC GE 1 AND GET_ANC EQ 1 AND SECOND_CHECK EQ 0 THEN BEGIN
        COUNTER = 0
  
        PLUN, LUN, 'Checking for (and downloading if missings) ancillary files for ' + NUM2STR(COUNT_LANC) + ' files...'
        FOR L=0, COUNT_LANC-1 DO BEGIN ; ===> Look for new ancillary files for the L90 files
          CFILE = LANC[L]
          CFP = FILE_PARSE(CFILE)
          SATDATE = DATE_PARSE(SATDATE_2DATE(CFP.FIRST_NAME))       ; Get date info
          TIMECHECK = JD_ADD(DATE_2JD(SATDATE.DATE),60,/DAY)        ; Date 30 days after the image was collected
          ANCFILE = DIR_ANC + CFP.FIRST_NAME + '.' + L1NAME + '.anc'
          ANCTIME = GET_MTIME(ANCFILE,/JD) ; Get the mtime of the corresponding .anc file
          IF SENSOR EQ 'MODISA' THEN ATTTIME = GET_MTIME(DIR_ANC + CFP.FIRST_NAME + '.' + L1NAME + '.atteph',/JD) ELSE ATTTIME = DATE_2JD(DATE_NOW()) ; Get the mtime of the corresponding .att file
  
          P1FILE = L1A_PRO + CFP.FIRST_NAME + '.' + L1NAME
          L1FILE = L1A_DIR + CFP.FIRST_NAME + '.' + L1NAME + '.bz2'
          L3FILE = L1A_L30 + CFP.FIRST_NAME + '.' + L1NAME
          L9FILE = L1A_L90 + CFP.FIRST_NAME + '.' + L1NAME
          CLIM1A = L1A_CLI + CFP.FIRST_NAME + '.' + L1NAME
          OZFILE = L1A_OZ  + CFP.FIRST_NAME + '.' + L1NAME
          P2FILE = L2_DIR  + CFP.FIRST_NAME + '.' + SUFFIX
          L2LOG  = L2_DIR  + CFP.FIRST_NAME + '.LOG'
          DLOG2  = LOG_DIR + CFP.FIRST_NAME + '.LOG'
          
          IF ANCTIME GT TIMECHECK AND ATTTIME GT TIMECHECK AND EXISTS(L3FILE) EQ 0 THEN CONTINUE ; If the .anc and .att files were created at least 30 days after the image was collected and the file does not exist in the L30 directory, can skip the looking for new ancillary files
                     
          CD, DIR_ANC
          PLUN, LUN, 'Checking ancillary files for ' + CFILE
          CMDANC = ANC_SCR + 'getanc.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
          SPAWN, CMDANC, ANC_TXT, ANC_ERR
          OK_ANC = WHERE_STRING(ANC_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ANC)
          OK_DANC = WHERE_STRING(ANC_TXT, 'Downloading',COUNT_DANC)
          OK_ERR = WHERE_STRING(ANC_ERR,'Traceback',COUNT_ERR)
          OK_OZ  = WHERE_STRING(ANC_TXT,'*** WARNING: The following ancillary data types were missing or are not optimal:  OZONE',COUNT_OZ)
          IF COUNT_OZ EQ 1 THEN BEGIN
            PLUN, LUN, 'OZONE ancillary file error...'
            WRITE_TXT, L1A_OZ + CFP.FIRST_NAME + '-ANC.txt', ANC_TXT
            IF ~EXISTS(OZFILE) THEN FILE_COPY, CFILE, L1A_OZ
          ENDIF
          IF COUNT_ERR GE 1 THEN BEGIN
            PLUN, LUN, 'Ancillary download error for ' + CFILE,0
            CONTINUE
          ENDIF
  
          COUNT_DATT = 0
          IF SENSOR EQ 'MODISA' THEN BEGIN ; Get attitude and ephemeris data for MODISA
            CMDATT = ANC_SCR + 'modis_atteph.py --refreshDB -v --ancdir=' + DIR_ANC + ' ' + CFILE
            SPAWN, CMDATT, ATT_TXT, ATT_ERR
            OK_ATT = WHERE_STRING(ATT_TXT, 'All optimal ancillary data files were determined and downloaded',COUNT_ATT)
            OK_DATT = WHERE_STRING(ANC_TXT, 'Downloading',COUNT_DATT)
          ENDIF ELSE COUNT_ATT = 1 ; If the sensor is not MODISA, then make COUNT_ATT=1
  
          IF COUNT_ANC EQ 1 AND COUNT_ATT EQ 1 AND COUNT_DANC EQ 0 AND COUNT_DATT EQ 0 THEN BEGIN ; If ancillary data are optimal and no new files were found
            PLUN, LUN, 'Ancillary files for ' + CFILE + ' (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT_LANC) + ') are optimal', 0         
            IF EXISTS(P2FILE) AND EXISTS(CLIM1A) THEN BEGIN ; If the ancillary files are optimal, but the P2FILE used the climatology, remove the L2 and make sure the L1A file is in L1A_PROCESS
              PLUN, LUN, 'Moving ' + P2FILE + ' to ' + CLI_DIR, 0
              FILE_MOVE, P2FILE, CLI_DIR, /OVERWRITE                                             ; Move the L2 file with the climatology ancillary data to the suspect climatology directory
              IF EXISTS(L2LOG)   THEN FILE_MOVE, L2LOG,  CLI_DIR, /VERBOSE, /OVERWRITE           ; Look for the L2 LOG file and remove to the suspect climatology directory
              IF EXISTS(DLOG2)   THEN FILE_MOVE, DLOG2,  CLI_DIR, /VERBOSE, /OVERWRITE           ; Look for the L2 LOG file and remove to the suspect climatology directory
              IF ~EXISTS(P1FILE) THEN FILE_MOVE, CFILE, L1A_PRO                                  ; Move the L1A file to L1A_PRO if it does not already exist.
              IF EXISTS(CLIM1A)  THEN FILE_DELETE, CLIM1A                                        ; Remove the L1A file from the CLIMATOLOGY directory
            ENDIF ; If the ancillary files are optimal, but the P2FILE used the climatology, remove the L2 and make sure the L1A file is in L1A_PROCESS
            IF SATDATE.JD LT DATE_2JD(D30) AND EXISTS(L3FILE) THEN FILE_DELETE, L3FILE, /VERBOSE ; Remove the file from the LAST_30 directory if older than 30 days
            IF SATDATE.JD LT DATE_2JD(D90) AND EXISTS(L9FILE) THEN FILE_DELETE, L9FILE, /VERBOSE ; Remove the file from the LAST_90 directory if older than 90 days
            CONTINUE
          ENDIF ; If ancillary data are optimal and no new files were found
  
          ANCFILES = FILE_SEARCH(DIR_ANC + SATDATE.YEAR + SL + SATDATE.IDOY + SL + '*')           ; Find the ancillary files
          IF COUNT_DANC EQ 1 OR COUNT_DATT EQ 1 OR FILE_MAKE(ANCFILES,P2FILE) EQ 1 THEN BEGIN     ; If new ancillary data are found
            PLUN, LUN, 'NEW Ancillary files for ' + CFILE + ' (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT_LANC) + ') were downloaded', 0  
            IF ANY(EXISTS([P2FILE,L2LOG,DLOG2])) THEN BEGIN
              PLUN, LUN, 'Moving ' + P2FILE + ' to ' + CLI_DIR, 0  
              IF EXISTS(P2FILE) THEN FILE_MOVE, P2FILE, CLI_DIR, /OVERWRITE                       ; Move the L2 file with the climatology ancillary data to the suspect climatology directory
              IF EXISTS(L2LOG)  THEN FILE_MOVE, L2LOG,  CLI_DIR, /OVERWRITE                       ; Move the L2 climatology file to the suspect climatology directory
              IF EXISTS(DLOG2)  THEN FILE_MOVE, DLOG2,  CLI_DIR, /OVERWRITE                       ; Move the L2 climatology log to the suspect climatology directory
            ENDIF ; EXISTS(P2FILE)
            CONTINUE
          ENDIF ; COUNT_LANC & COUNT_ATT          
          PLUN, LUN, 'Unable to update ancillary files to replace the climatology (' + ROUNDS(L+1) + ' of ' + ROUNDS(COUNT_LANC) + ') for: ' + CFILE, 0
        ENDFOR ; L1A loop to find updated ancillary files
      ENDIF ELSE BEGIN
        GCMD = './getanc_all.sh -d ' + SENSOR + ' -p ' + L1A_PRO
        CD, !S.SCRIPTS + 'SEADAS' + SL
        PLUN, LUN, 'Running GETANC_ALL.sh for ' + NUM2STR(N_ELEMENTS(PROCESS_L1S)) + ' files for ' + SENSOR + ' to quickly check for any missing ancillary files.'
        PLUN, LUN, GCMD, 0
        SPAWN, GCMD, GETANC_TXT, GETANC_ERR
        PLUN, LUN, 'Finished getting the ancillary files.', 0
        CD, !S.PROGRAMS  
      ENDELSE
      CD, !S.PROGRAMS
  
      ; ===> Remove SUSPECT MODISA L1A files from the download list
      IF SENSOR NE 'SEAWIFS' THEN BEGIN
        DOWNLOAD_LIST = !S.SCRIPTS + 'DOWNLOADS' + SL + 'FILELISTS' + SL + SENSOR + '.txt'
        IF FILE_TEST(DOWNLOAD_LIST) EQ 0 THEN PLUN, LUN, 'ERROR: ' + DOWNLOAD_LIST + ' was not found.'
        DLIST  = READ_TXT(DOWNLOAD_LIST)
        DP     = FILE_PARSE(DLIST)
        LNAMES = REPLACE(DP.NAME_EXT,'.bz2','')
    
        FILES  = FILE_SEARCH([PERMAN,OOA_DIR] + PREFIX + '*' + L1NAME + '*')
        FP     = FILE_PARSE(FILES)
        FNAMES = REPLACE(FP.NAME_EXT,'.bz2','')
    
        OK = WHERE_MATCH(LNAMES,FNAMES,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
        IF COUNT GE 1 AND NCOMPLEMENT GE 1 THEN BEGIN
          FILE_MOVE, DOWNLOAD_LIST, !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + 'REPLACED' + SL + SENSOR + '-REPLACED_' + DATE_NOW() + '.txt'
          PLUN, LUN, 'Removing PERMANENT ERROR and OUT-OF-AREA files fron the master download list...'
          FOR I=0, COUNT-1 DO PLUN, LUN, 'Removing ' + LNAMES[OK[I]] + ' from the download list', 0
          WRITE_TXT, DOWNLOAD_LIST, OC_GET + LNAMES[COMPLEMENT] + EXT
        ENDIF ; IF COUNT GE 1 AND NCOMPLEMENT GE 1 THEN BEGIN
      ENDIF ; IF SENSOR NE 'SEAWIFS' THEN BEGIN 
  
  
      PROCESS_L1S = FLS(L1A_PRO + PREFIX + '*' + REPLACE(L1SUFFIX,'.bz2',''), COUNT=COUNT_L1P)
      IF COUNT_L1P GT 0 THEN BEGIN
        PLUN, LUN, ROUNDS(COUNT_L1P) + ' L1A files remaining to process...'
        FOR I=0, COUNT_L1P-1 DO PLUN, LUN, ROUNDS(I+1) + ': Need to process ' + PROCESS_L1S(I), 0
      ENDIF ELSE PLUN, LUN, ' All files for ' + SENSOR + ' (' + STRJOIN(DATERANGE,' - ') + ') have been processed.'
      
      ; ===> Process the L1A to L2 files using SeaDAS
      IF COUNT_L1P GT 0 AND SECOND_CHECK EQ 0 THEN BEGIN
        SECOND_CHECK = 1
        SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NPROCESS)
        IF SVRS EQ [] THEN BEGIN
          FOR W=0, 4 DO BEGIN
            WAIT, 60*60 ; 1 HOUR
            SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NPROCESS)
            IF SVRS NE [] THEN GOTO, RUN_L2GEN_CMD
          ENDFOR
          PLUN, LUN, 'ERROR: No servers available to run "process_L1A_L2_all.sh" in parallel"
          GOTO, DONE
        ENDIF
        RUN_L2GEN_CMD:    
        SCMD = './process_L1A_L2_files.sh -d ' + SENSOR + ' -s ' + STRJOIN(SVRS,',')
        IF KEY(RFILES) THEN SCMD = SCMD + ' -r'
        IF KEY(DIR_PROCESS) THEN SCMD = SCMD + ' -p ' + L1A_PRO
        IF KEY(PDIR2) THEN SCMD = SCMD + ' -o ' + DIR2
        IF KEY(L2GEN_PAR) THEN SCMD = SCMD + ' -l ' + L2GEN_PAR
        IF SCMD NE '' THEN BEGIN
          FILESB = FLS(L2_DIR + PREFIX + '*' + SUFFIX, COUNT=FILES_BEFORE)
          PLUN, LUN, SCMD, 0
          SCMDS = [SCMDS,SCMD]
          IF KEY(RUN_L2GEN) THEN BEGIN 
            CD, !S.SCRIPTS + 'SEADAS' + SL
            PLUN, LUN, 'Running SeaDAS L2GEN for ' + NUM2STR(N_ELEMENTS(PROCESS_L1S)) + ' files for ' + SENSOR
            SPAWN, SCMD, L2GEN_TXT, L2GEN_ERR
            PLUN, LUN, 'Finished creating the L2 files.', 0
          
            ; ===> Save and email the L2GEN logs
            IF N_ELEMENTS(L2GEN_TXT) GE 1 AND L2GEN_TXT[0] NE '' THEN BEGIN
              L2TEMP = !S.IDL_TEMP + 'L2_TEMP_LOGTXT.txt'
              WRITE_TXT, L2TEMP, L2GEN_TXT
              IF KEY(EMAIL_ALL) THEN EMAIL_ATTACHMENTS = [EMAIL_ATTACHMENTS, L2TEMP]  
            ENDIF
            IF N_ELEMENTS(L2GEN_ERR) GE 1 AND L2GEN_ERR[0] NE '' THEN BEGIN
              L2ERR_TEMP = !S.IDL_TEMP + 'L2_TEMP_ERROR.txt'
              WRITE_TXT,L2ERR_TEMP, L2GEN_ERR
              EMAIL_ATTACHMENTS = [EMAIL_ATTACHMENTS, L2ERR_TEMP]
            ENDIF  
            CD, !S.PROGRAMS
          
          ; ===> Check for new L2 files
            FILESA = FILE_SEARCH(L2_DIR + PREFIX + '*' + SUFFIX, COUNT=FILES_AFTER)
            IF FILES_AFTER GT FILES_BEFORE THEN BEGIN
              PLUN, LUN, NUM2STR(FILES_AFTER-FILES_BEFORE) + ' new L2 files were created'  
              OK = WHERE_MATCH(FILESA,FILESB,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
              IF NCOMPLEMENT GT 0 THEN BEGIN
                PLUN, LUN, FILESB(COMPLEMENT)  + ' created on ' + DATE_NOW(/DATE_ONLY)
                L2FILES_TEMP = !S.IDL_TEMP + 'L2_TEMP_FILES.txt'
                WRITE_TXT,L2FILES_TEMP, FILESB(COMPLEMENT)
                EMAIL_ATTACHMENTS = [EMAIL_ATTACHMENTS, L2FILES_TEMP]
              ENDIF
              PLUN, LUN, 'Rechecking which L1A files need to be processed...'
              GOTO, RERUN_CHECK_FILES
            ENDIF  
          ENDIF ; IF SCMD NE '' 
        ENDIF ; KEY(RUN_L2GEN)   
      ENDIF ; IF KEY(RUN_SEADAS) AND N_ELEMENTS(PROCESS_L1S) GT 0 AND SECOND_CHECK EQ 0 THEN BEGIN
  
      DONE:
      PLUN, LUN, 'Closing BATCH_SEADAS_L1A log file for ' + SENSOR + ' on: ' + SYSTIME()
      FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
      IF KEYWORD_SET(EMAIL_ALL) THEN EMAIL_ATTACHMENTS = [EMAIL_ATTACHMENTS,LOG_FILE]
      ATTACH = []
      FOR I=0, N_ELEMENTS(EMAIL_ATTACHMENTS)-1 DO ATTACH = [ATTACH, ' -a ' + EMAIL_ATTACHMENTS(I)]
      IF ATTACH NE [] THEN BEGIN 
        SPAWN, 'echo -e "Finshed BATCH_SEADAS_L1A for ' + SENSOR + ' on: ' + SYSTIME() + '" | mailx -s "Finished BATCH_SEADAS_L1A ' + SYSTIME() + '" ' + ATTACH + ' ' + MAILTO
        TMP = EMAIL_ATTACHMENTS[WHERE(HAS(EMAIL_ATTACHMENTS,'TEMP') EQ 1,/NULL,COMPLEMENT=ECOMP,NCOMPLEMENT=NCOMP)]
        IF TMP NE [] THEN IF FILE_TEST(TMP) THEN FILE_DELETE, TMP
        IF NCOMP GT 0 THEN ATTACHMENTS = EMAIL_ATTACHMENTS[ECOMP] ELSE ATTACHMENTS = []
      ENDIF ; EMAIL_ATTACHMENTS  
    ENDFOR ; SENSORS
  ENDFOR ; PROJECTS
  
  LI, SCMDS, /NOSEQ

  PRINT,'END OF ' + ROUTINE_NAME
END; #####################  End of Routine ################################
