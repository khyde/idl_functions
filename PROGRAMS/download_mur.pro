; $ID:	DOWNLOAD_MUR.PRO,	2020-07-09-08,	USER-KJWH	$
;+

PRO DOWNLOAD_MUR, INPUT_SWITCH, DATERANGE=DATERANGE, SKIP_PLOTS=SKIP_PLOTS, PLT_DATERANGE=PLT_DATERANGE, $
  LOGFILE=LOGFILE, PNG=PNG, FILES=FILES, EMAIL=EMAIL, ATTACHMENTS=ATTACHMENTS, BUFFER=BUFFER

; NAME: DOWNLOAD_MUR
;
; PURPOSE: This is a main BATCH program for downloading the subscription data
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
; MODIFICATION HISTORY:
;   

  ;*************************
  ROUTINE_NAME='DOWNLOAD_MUR'
  PRINT, 'Running: '+ROUTINE_NAME

  ; ===> PARAMETERS
  DATASET = 'MUR'

  ; ===> DELIMITERS
  SL    = PATH_SEP()
  ASTER ='*'
  DASH  ='-'

  ; ===> DATES & EMAIL
  MAILTO = 'kimberly.hyde@noaa.gov'
  DP = DATE_PARSE(DATE_NOW())              ; Parse today's date
  DAY90 = STRMID(JD_2DATE(JD_ADD(DP.JD,-90,/DAY)),0,8) ; Get the date 90 days prior to the current date
  DAY180 = JD_2DATE(JD_ADD(DP.JD,-180,/DAY)) ; Get the date 180 (6 months) prior to the current date

  ; ===> DIRECTORIES
  BATCH_LOG_DIR = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL & DIR_TEST, BATCH_LOG_DIR

  ; ===> KEYWORDS
  IF NONE(BUFFER)   THEN BUFFER = 1
  IF NONE(INPUT_SWITCH) THEN SWIS = 'Y' ELSE SWIS = SWITCHES ; By default, recheck the files from the last 90 days

  ; ===> REMOTE FTP LOCATIONS
  FTP   = 'https://podaac-tools.jpl.nasa.gov/drive/files/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/'; 'ftp://podaac-ftp.jpl.nasa.gov/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/';
  
  FTO = 'https://data.nodc.noaa.gov/ghrsst/GDS2/L4/GLOB/JPL/MUR/v4.1/' ; NODC file location (does not have the md5 file that the NASA site has, but there are no password requirements)
  PAT='-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc'
  
  PODAAC_URL = 'https://podaac-tools.jpl.nasa.gov/drive/files'
  MUR_USR = 'khyde' & MUR_PSW = 'FydOA4zodKWghvNRKH2P';'NASAPhyt0pl@nkt0nRS'

  ; ===> NARRAGANSETT 1KM BOUNDARIES
  LATMIN = 22.5 ; 17.92 (Updated 11/07/2016 by KHyde)
  LATMAX = 48.5 ; 55.4
  LONMIN = -82.5 ; -97.8
  LONMAX = -51.5 ; -43.8

  ; ===> INITIALIZE PARAMETERS
  NEW_FILES = 'Starting download at ' + SYSTIME()
  WGET_RESULT = ''


skip_plots = 1

  ; ===> INITIALIZE PLOT
  IF ~KEY(SKIP_PLOTS) THEN BEGIN
    IF N_ELEMENTS(DATASETS) EQ 1 THEN YDIM = 400 ELSE YDIM = 200*N_ELEMENTS(DATASETS)
    W = WINDOW(DIMENSIONS=[1000,YDIM],BUFFER=BUFFER)
  ENDIF ; ~KEY(SKIP_PLOTS)


  SWITCHES, SWIS,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,DATERANGE=DTR ; Get processing switches
;    IF KEY(INIT) THEN RECHECK_CKSUMS = 1                                                            ; When downloading from the MASTER download list, recheck all of the checksums of the local files
;    ID = '' & PAT = '' & CHECK_SST = 0 & MD5CKSUM = 0 & LIST_ONLY = 0 & FTP_SUBDIR = '' & USR='' & PSW = ''  ; Set SUBID and PATTERN to null strings and CHECK_SST to 0
;    NASA=1 ; Default is that the dataset is from the NASA Ocean Color web
     SUBDIR='L4' & SENSOR='mur'     & PREFIX=''  & TYPE='L3b' & PAT='-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc' 
    
    IF DTR[0] EQ '19780101' AND DTR[1] EQ '21001231' AND ~KEY(LIST_ONLY) THEN DTR = [DAY90,STRMID(DATE_NOW(),0,8)]
    IF ANY(DATERANGE) THEN DTR = DATERANGE
    

    ; ===> Determine dataset specific files and directories
    DIR = !S.SST + DATASET + SL + SUBDIR + SL
    SDIR = DIR + 'NC' + SL
    LDIR = BATCH_LOG_DIR + DATASET + SL
    CDIR = DIR + 'CHECKSUMS' + SL
    CHECKSUMS = 'CHECKSUMS.txt'
    FILELIST_CHECKSUMS = 'FILELIST_CHECKSUMS.txt'
    DIR_TEST, [LDIR,CDIR,SDIR]

    ; ===> Open dataset specific log file
    IF NONE(LOGFILE) THEN LOGFILE = LDIR + DATASET  + '_' + DATE_NOW(/DATE_ONLY) + '.log'
    OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180 
    PLUN,LUN,'*****************************************************************************************************',3
    PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
    PLUN,LUN,'Downloading files in ' + DATASET, 0

    NEW_FILES = [NEW_FILES,'Downloading files to ' + DATASET + ' at ' + SYSTIME()]

    SDATES = SENSOR_DATES(DATASET)                                                      ; Get the SENSOR daterange
    IF DTR[0] LT SDATES[0] THEN DTR[0] = SDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
    IF DTR[1] GT SDATES[1] THEN DTR[1] = SDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
    DPS = DATE_PARSE(DTR[0]) & DPE = DATE_PARSE(DTR[1])                                 ; Parse start and end dates
    IF NONE(PLT_DATERANGE) THEN PLT_DATERANGE = DTR
    AX = DATE_AXIS(PLT_DATERANGE,/DAY,STEP_SIZE=10)

    ; ===> Determine the number of local files per day and plot
    IF ~KEY(SKIP_PLOTS) THEN BEGIN
      PLT_FILES = FILE_SEARCH(SDIR + PREFIX + '*' + PAT + '*' )       ; Find local files
      PLT_FILES = DATE_SELECT(PLT_FILES,PLT_DATERANGE,COUNT=COUNTP)   ; Subset files to the daterange
      IF COUNTP GE 1 THEN BEGIN
        FP = PARSE_IT(PLT_FILES)                                        ; Parse file names to get date info
        BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))  ; Determine the number of files per day
        PLT = PLOT(AX.JD,[0,MAX(BSET.N)],/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=5, /CURRENT,XRANGE=AX.JD,YRANGE=NICE_RANGE([0,MAX(BSET.N+2)]),LAYOUT=[1,N_ELEMENTS(DATASETS),N+1],TITLE=DATASET,MARGIN=[0.05,0.15,0.025,0.2])
        PLT = PLOT(YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3)),BSET.N,/CURRENT,/OVERPLOT,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='BLUE',THICK=2,SYM_SIZE=0.75)
      ENDIF ELSE PLT = PLOT(AX.JD,[0,20],/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=5, /CURRENT,XRANGE=AX.JD,YRANGE=NICE_RANGE([0,20]),LAYOUT=[1,N_ELEMENTS(DATASETS),N+1],TITLE=DATASET,MARGIN=[0.05,0.15,0.025,0.2])
    ENDIF ; ~KEY(SKIP_PLOTS)


    ; ===> Create NULL arrays to be filled in during the downloading process
    CKSUMS = []
    SNAMES = []
    URLS   = []

    ; ===> Get list of files and checksums for the MUR and AVHRR SST files
    DATES = CREATE_DATE(DTR[0],DTR[1],/DOY,/CURRENT_DATE)                                                           ; Create list of DOY dates
    YEARS = STRMID(DATES,0,4) & UYEARS = YEARS[UNIQ(YEARS)]                                                         ; Find unique years in the DATERANGE
    DOYS  = STRMID(DATES,4,3)
      
    MD5CKSUM = 1                                                                                                    ; Use MD5SUM to validate MUR checksum
    ADD_SUBDIR = 0

    DOYLIST = DOYS

    YURLS = []
    YNAMES = []
    FOR Y=0, N_ELEMENTS(UYEARS)-1 DO BEGIN                                                                        ; Loop through years to get the directory and file names
      AYEAR = UYEARS(Y)
      USER=' --user='+MUR_USR + ' --password='+MUR_PSW
      PSW =MUR_PSW
      YURLS = [YURLS, AYEAR + SL + DOYLIST]                                                                       ; Create a list of URLS
      YNAMES = [YNAMES, YDOY_2DATE(AYEAR, DOYLIST, 09, 00, 00)]                              ; Create a list of dates based on the year and doy (HH,MM,SS are specific to the MUR files and may change with subsequent versions)
      YNAMES = DATE_SELECT(YNAMES,DTR,SUBS=YSUBS)
      SNAMES = YNAMES + PAT                                                                                         ; Create a list of file names
      URLS   = FTP + YURLS + SL                                                                                     ; Create a list of full URL names
      URLS   = URLS(YSUBS)                                                                                          ; Susbset the URL names based on the DATERANGE
;;      WRITE_TXT, DIR + 'CHECKSUMS_TO_DOWNLOAD.txt', URLS  + SNAMES + '.md5'                                         ; Create list of CHECKSUM files to download
;      CMD = 'wget --tries=3 --retry-connrefused -c -N' + USER + ' -i ' + DIR + 'CHECKSUMS_TO_DOWNLOAD.txt -a ' + LOGFILE        ; Checksum download command
;      PLUN, LUN, CMD
;      CD, DIR + 'CHECKSUMS' + SL
;      SPAWN, CMD, LOG, ERR
;      IF LOG[0] NE '' THEN PLUN, LUN, LOG
;      IF ERR[0] NE '' THEN PLUN, LUN, ERR
;      CD, DIR
    ENDFOR
    
;      ; Skip reading the existing CHECKSUMS file because it often becomes corrupt and crashes the processing
;     IF FILE_TEST(DIR + CHECKSUMS) EQ 1 THEN BEGIN                                                                 ; Make a checksum list for the MUR dataset
;       PRINTF, LUN, 'Reading: ' + DIR + CHECKSUMS
;       CKSUMS = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
;       OK = WHERE_MATCH(SNAMES, CKSUMS.(0), COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, VALID=VALID)    ; Look for files that are already in the master checksum list
;       IF NCOMPLEMENT GT 0 THEN SNAMES = SNAMES(COMPLEMENT) ELSE SNAMES = []                                       ; Identify missing names
;       CKSUMS = READ_TXT(DIR + CHECKSUMS)                                                                          ; Read as a text array that can be appended with new checksum info
;     ENDIF

;      CKSUMS = []
;      FOR S=0, N_ELEMENTS(SNAMES)-1 DO BEGIN
;        IF ~EXISTS(DIR + 'CHECKSUMS' + SL + SNAMES(S) + '.md5') THEN CONTINUE
;        CK = READ_DELIMITED(DIR + 'CHECKSUMS' + SL + SNAMES(S) + '.md5',DELIM='SPACE',/NOHEADING)
;        CK_TXT = CK.(1)+' '+CK.(0)                                                                                  ; Add missing checksums to the master file
;        IF WHERE_STRING(CK_TXT,'{') NE [] THEN STOP
;        CKSUMS = [CKSUMS,CK_TXT]
;      ENDFOR
;     ; IF EXISTS(DIR + CHECKSUMS) EQ 1 THEN FILE_MOVE, DIR+'CHECKSUMS.txt', DIR+'CHECKSUM_BACKUP'+SL+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'     ; Create a backup of the CKSUM MASTER
;      WRITE_TXT, DIR+CHECKSUMS, CKSUMS                                                                             ; Write updated checksum file
;      CLIST = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                             ; Read as a structure to get the CHECKSUM values
;      OK = WHERE_MATCH(CLIST.(0), YNAMES + PAT, COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, VALID=VALID) ; Find CHECKSUMS for matching SNAMES
;      CKSUMS = CLIST[OK].(1)
;      SNAMES = CLIST[OK].(0)
;      DP = DATE_PARSE((PARSE_IT(SNAMES)).DATE_START)
      URLS = FTP + DP.YEAR + SL + DP.IDOY + SL

    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

 ;   IF KEY(LIST_ONLY) THEN GOTO, SKIP_ORDERED_DATA

    ; ===> Get the list of files and checksums from the NASA server
     
    ; ===> Determine if additional files are requested based on the DATERANGE
    IF ANY(SNAMES) THEN BEGIN
      SFP = PARSE_IT(SNAMES)
      MINDATE = MIN(DATE_2JD(SFP.DATE_START))
    ENDIF ELSE  MINDATE = DATE_2JD(SDATES[1])
    IF DTR[0] NE SDATES[0] OR DATE_2JD(DTR[1]) LT MINDATE THEN INIT = 1

    ; ===> Check the entire list of files on the NASA server (within the date range) and not just the new files on the subscription server to make sure no files were missed in the subscription downloads
    IF KEY(LIST_ONLY) THEN INIT = 1
    IF KEY(INIT) AND TYPE NE 'L3b' THEN BEGIN
      PLUN, LUN, 'Searching the NASA server for files that match the complete (or partial based on date range) list of files in the MASTER download list'
      FCKSUMS = []
      FNAMES  = []

      CD, DIR
      DATES = CREATE_DATE(DPS.DATE, DPE.DATE)
      LOOPS = ROUND(N_ELEMENTS(DATES)/60)+1
      IF N_ELEMENTS(DATES) MOD 60 EQ 0 THEN LOOPS = LOOPS-1

      SDATES = []
      EDATES = []
      FOR Y=0, LOOPS-2 DO BEGIN
        SDATES = [SDATES,DATES(Y*60)]
        EDATES = [EDATES,DATES(Y*60+59)]
      ENDFOR
      SDATES = [SDATES,DATES(Y*60)]
      EDATES = [EDATES,DATES(-1)]
      SD = DATE_PARSE(SDATES)
      ED = DATE_PARSE(EDATES)

      FLIST_ERROR = 0 
      FOR Y=0, N_ELEMENTS(SDATES)-1 DO BEGIN
        PATTERN = 'search=*'+PAT+'&sensor='+SENSOR+'&sdate='+SD(Y).DASH_DATE+'&edate='+ED(Y).DASH_DATE+'&dtype='+TYPE
        CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -q -O - '+OC_SEARCH+' > ' + FILELIST_CHECKSUMS
        PLUN, LUN, CMD
        SPAWN, CMD

        FI = FILE_INFO(FILELIST_CHECKSUMS)
        IF FI.SIZE EQ 0 THEN BEGIN
          PLUN, 'No checksum file found, retrying...'
          SPAWN, CMD
          FI = FILE_INFO(FILELIST_CHECKSUMS)
          IF FI.SIZE EQ 0 THEN CONTINUE
        ENDIF

        FLIST = READ_TXT(FILELIST_CHECKSUMS)                                                                        ; Read the output CHECKSUMS file
        IF STRMID(FLIST[0],0,2) EQ '<!' OR FLIST EQ [] THEN BEGIN                                                   ; If no remote server files are found, the file will start with <!
          PLUN, LUN, 'ERROR: No valid files found on remote server from ' + SD(Y).DASH_DATE + ' to ' + ED(Y).DASH_DATE
          PLUN, LUN, FLIST, 0
          FLIST_ERROR = 1
          CONTINUE
        ENDIF
        IF STRMID(FLIST[0],0,10) EQ 'Your query' THEN BEGIN                                                         ; Some searches return a text string as the first line that must be removed
          FLIST = FLIST(1:*)
          FLIST = FLIST[WHERE(FLIST NE '',/NULL)]                                                                   ; Remove any blank lines
          IF FLIST NE [] THEN WRITE_TXT, FILELIST_CHECKSUMS, FLIST                                                  ; Resave list
        ENDIF

        FLIST = READ_DELIMITED(FILELIST_CHECKSUMS,DELIM='SPACE',/NOHEADING)                                         ; Read the CHECKSUM as a delimited file
        FCKSUMS = [FCKSUMS,FLIST.(0)]                                                                               ; Get the list of checksums
        FNAMES  = [FNAMES,FLIST.(1)]                                                                                ; Get the list of matching file names
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(FLIST)) + ' files on the remote server'
      ENDFOR

      ; ===> Find files that match the master download list
      IF ANY(FNAMES) THEN OK = WHERE_MATCH(DLIST, OC_GET+FNAMES,COUNT, VALID=VALID) ELSE COUNT = 0
      IF COUNT GE 1 THEN BEGIN
        FNAMES  = FNAMES(VALID)
        FCKSUMS = FCKSUMS(VALID)
        PLUN, LUN, 'Found ' + ROUNDS(COUNT) + ' files on the remote server that match the MASTER download list'
      ENDIF ELSE BEGIN
        IF KEY(FLIST_ERROR) THEN BEGIN                                                                              ; If there was an error finding the files on the remote server, just use the download list.
          FNAMES = REPLACE(DLIST, OC_GET, '')
          FCKSUMS = REPLICATE('',N_ELEMENTS(FNAMES))
        ENDIF  
      ENDELSE
      FILE_DELETE, FILELIST_CHECKSUMS                                                                               ; Remove the FILELIST_CHECKSUM file to avoid accidently reading the file in the future
      IF SNAMES EQ [] AND FNAMES EQ [] THEN BEGIN 
        IF ANY(DLIST) THEN BEGIN
          SNAMES = REPLACE(DLIST,OC_GET,'')
          URLS = REPLICATE(OC_GET, N_ELEMENTS(DLIST))
          CKSUMS = REPLICATE('',N_ELEMENTS(DLIST))
        ENDIF
      ENDIF ELSE BEGIN
        SNAMES = [SNAMES,FNAMES]                                                                                    ; Combine SUBSCRIPTION file names and SEARCH file names
        CKSUMS = [CKSUMS,FCKSUMS]                                                                                   ; Combine SUBSCRIPTION checksums and SEARCH checksums
        SRT = SORT(SNAMES) & SNAMES = SNAMES(SRT) & CKSUMS = CKSUMS(SRT)                                            ; Sort files
        UNI = UNIQ(SNAMES) & SNAMES = SNAMES(UNI) & CKSUMS = CKSUMS(UNI)                                            ; Remove any duplicates
        URLS = REPLICATE(OC_GET,N_ELEMENTS(SNAMES))
      ENDELSE
    ENDIF ; IF KEY(INIT) AND  TYPE NE 'L3b' THEN BEGIN


    ; ===> Create structure to compare the remote and local files
    STR = CREATE_STRUCT('SERVER_FILES','','SERVER_CKSUM','','URL','','LOCAL_FILES','','LOCAL_CKSUM','','NEW_CKSUM','','NAMES','','LOCATION','')

    STR = REPLICATE(STR, N_ELEMENTS(SNAMES))
    STR.SERVER_FILES = SNAMES
  ;  STR.SERVER_CKSUM = CKSUMS
    STR.URL = URLS
    STR.NAMES = STR.SERVER_FILES
    STR.LOCATION = 'SUBSCRIPTION_LIST'  

  ; ===> Get CHECKSUMS of the local files
    LOCAL_FILES = SDIR[0] + SNAMES
    LOCAL_FILES = LOCAL_FILES[WHERE(FILE_TEST(LOCAL_FILES) EQ 1,COUNT,/NULL)]                                       ; Determine if local files exist
    PLUN, LUN, 'Looking for local matching local files...'

    IF COUNT GE 1 THEN BEGIN                                                                                        ; If local files exist, get the checksum
      PLUN, LUN, ROUNDS(N_ELEMENTS(LOCAL_FILES)) + ' matching files found on local server.',0
      FP = FILE_PARSE(LOCAL_FILES)
      OK_LOCAL = WHERE_MATCH(SNAMES,FP.NAME_EXT,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
      STR(OK_LOCAL).LOCAL_FILES = FP(VALID).NAME_EXT

      IF FILE_TEST(DIR+CHECKSUMS) EQ 1 AND NOT KEY(RECHECK_CKSUMS) THEN BEGIN                                       ; Use the MASTER checksum list
        PLUN, LUN, 'Reading: ' + DIR + CHECKSUMS, 0
        CKSUMS = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
        IF CKSUMS EQ [] THEN BEGIN
          PLUN, LUN, DIR+CHECKSUMS + ' is blank.  Deleting...'
          FILE_DELETE, DIR + CHECKSUMS, /VERBOSE
          GOTO, SKIP_READ_CKSUMS
        ENDIF  
        CKTXT  = READ_TXT(DIR + CHECKSUMS)
        OK_FILE = WHERE(FILE_TEST(SDIR[0] + CKSUMS.(0)) EQ 0, COUNT_MISSING, COMPLEMENT=COMPLEMENT)                 ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
        IF COUNT_MISSING GE 1 THEN BEGIN
          CKTXT = CKTXT(COMPLEMENT)                                                                               ; Remove missing files from the MASTER CHECKSUMS list
          IF EXISTS(DIR + CHECKSUMS) THEN FILE_MOVE, DIR+CHECKSUMS, DIR+'CHECKSUMS'+SL+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'                        ; Create a backup of the MASTER CKSUM list
          WRITE_TXT,DIR + CHECKSUMS, CKTXT                                                                         ; Rewrite MASTER CHECKSUMS list
          CKSUMS = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
        ENDIF

        OK_MATCH = WHERE_MATCH(SNAMES,CKSUMS.(0),COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID)   ; Look for files that are already in the master checksum list
        IF COUNT GE 1 THEN STR(OK_MATCH).LOCAL_FILES = CKSUMS(VALID).(0)
        IF COUNT GE 1 THEN STR(OK_MATCH).LOCAL_CKSUM = CKSUMS(VALID).(1)

        IF NCOMPLEMENT GT 0 THEN SNAMES = SNAMES(COMPLEMENT) ELSE SNAMES = []                                       ; Identify missing names
        CKSUMS = READ_TXT(DIR + CHECKSUMS)                                                                          ; Read as a text array that can be appended with new checksum info
      ENDIF ELSE CKSUMS = []
      SKIP_READ_CKSUMS:

      OK_LOCAL = WHERE(STR.LOCAL_FILES NE '' AND STR.LOCAL_CKSUM EQ '', COUNT_LOCAL)                                ; Look for missing CHECKSUMS
      IF COUNT_LOCAL GE 1 THEN BEGIN
        STR(OK_LOCAL).LOCAL_CKSUM = GET_CHECKSUMS(SDIR[0] + STR(OK_LOCAL).LOCAL_FILES,MD5CKSUM=MD5CKSUM,/VERBOSE)   ; Get CHECKSUMS that are missing in the structure and MASTER list
        CKSUMS = [CKSUMS,STR(OK_LOCAL).LOCAL_FILES+' '+STR(OK_LOCAL).LOCAL_CKSUM]          ; Create checksum string
        IF HAS(CKSUMS,'{') EQ 1 OR HAS(CKSUMS,'}') EQ 1 THEN CKSUMS = REPLACE(CKSUMS,['{ ','}'],['',''])            ; Remove any { or } from the CKSUM strings
        CKSUMS = CKSUMS[SORT(CKSUMS)]                                                                               ; Sort by file name
        CKSUMS = CKSUMS[UNIQ(CKSUMS)]
        WRITE_TXT, DIR+CHECKSUMS, CKSUMS                                                                            ; Write new MASTER CHECKSUMS list
      ENDIF

    ENDIF ELSE PLUN, LUN, 'No matching files found on the local server.'
      

    ; ===> Compare the checksums of the remote and local files and download files if checksums do not match
    PLUN, LUN, 'Comparing checksums of remote and local files...'
    OK = WHERE((STR.SERVER_CKSUM NE '' AND STR.SERVER_CKSUM NE STR.LOCAL_CKSUM) OR STR.LOCAL_FILES EQ '',COUNT)                               ; Find non-matching checksums
    COUNT_DOWNLOAD_LOOP = 0
    IF COUNT GE 1 THEN BEGIN
      D = STR[OK]                                                                                                  ; Subset structure to be just those with unmatching checksums
      REPEAT_DOWNLOAD:
      PLUN, LUN, 'Creating the download list:'
      FOR I=0, COUNT-1 DO PLUN, LUN, D(I).SERVER_FILES, 0
      WRITE_TXT, DIR + 'DOWNLOAD_LIST.txt', D.URL + D.SERVER_FILES                                                 ; Create a list of remote files to download

      OK = WHERE(D.LOCAL_FILES NE '' AND D.SERVER_CKSUM NE '',COUNT)                                               ; Find "bad" local files
      IF COUNT GE 1 THEN BEGIN
        PLUN, LUN, 'Removing local files with unmatching checksum...'
        FOR I=0, COUNT-1 DO PLUN, LUN, 'Removing ' + D(OK(I)).LOCAL_FILES, 0

        PLUN, LUN, 'READING: ' + DIR + CHECKSUMS
        CKSUMS = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
        OK_FILE = WHERE_MATCH(CKSUMS.(0), D[OK].LOCAL_FILES, COUNTR, COMPLEMENT=COMPLEMENT)                         ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
        IF N_ELEMENTS(COMPLEMENT) GE 1 THEN WRITE_TXT, DIR + CHECKSUMS, CKSUMS(COMPLEMENT)                          ; Rewrite the MASTER CKSUM file, removing the CKSUMS of files that will be deleted
        REMOVE_FILES = SDIR + D[OK].LOCAL_FILES                                                                     ; Files to be removed because they do not have matching CKSUMS
        OK = WHERE(FILE_TEST(REMOVE_FILES) EQ 1,COUNTR)                                                             ; Make sure the file exists
        IF COUNTR GE 1 THEN FILE_DELETE, REMOVE_FILES[OK], /VERBOSE                                                 ; Remove "bad" local files
      ENDIF

      PLUN, LUN, 'Downloading files...'
      FOR I=0, N_ELEMENTS(D)-1 DO PLUN, LUN, 'Downloading: ' + D(I).SERVER_FILES, 0
      IF NONE(USER) THEN USER = ''
      IF KEY(NASA) THEN COOKIES = ' --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition' ELSE COOKIES=''
      CMD = 'wget' + COOKIES + ' --progress=bar:force --tries=3 --retry-connrefused -c -N' + USER + ' -i ' + DIR + 'DOWNLOAD_LIST.txt -a ' + LOGFILE
      PLUN, LUN, CMD
      CD, SDIR
      SPAWN, CMD, WGET_RESULT, WGET_ERROR                                                   ; Spawn command to download new files
      ;      CLOSE, LUN & FREE_LUN, LUN                                                           ; Close and reopen log file after downloading

      WGET_LOG = READ_TXT(LOGFILE)                                                          ; Check log file to see if the downloads were terminated
      IF STRPOS(WGET_LOG(-1), 'Downloaded:') EQ -1 THEN WGET_RESULT = 'TERMINATED'

      ;      OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN                          ; Close and reopen log file after downloading


      IF WGET_RESULT[0] NE '' THEN PLUN, LUN, WGET_RESULT
      IF WGET_ERROR[0] NE '' THEN PLUN, LUN, WGET_ERROR

      ; ===> If WGET was terminated, then skip to DONE
      CL = COUNT_DOWNLOAD_LOOP
      IF WGET_RESULT EQ 'TERMINATED' THEN BEGIN
        PLUN, LUN, 'WGET terminated...'
        COUNT_DOWNLOAD_LOOP = 999
      ENDIF

      IF WHERE_STRING(WGET_LOG,'Ending wget at') NE [] THEN PLUN, LUN, 'WGET terminated by killwget.sh'   ; Check to see if WGET was terminated by the killwget script or other means

      IF WHERE_STRING(WGET_LOG,'Connection reset by peer') NE [] THEN BEGIN                          ; Check to see if WGET was terminated by the killwget script or other means
        PLUN, LUN, 'WGET terminated by peer'
        COUNT_DOWNLOAD_LOOP = CL
      ENDIF


      ; ===> Verify the CHKSUM of the newly downloaded files
      D.NEW_CKSUM = GET_CHECKSUMS(SDIR + D.SERVER_FILES, MD5CKSUM=MD5CKSUM,/VERBOSE)
      OK = WHERE(D.SERVER_CKSUM NE D.NEW_CKSUM,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
      IF NCOMPLEMENT GT 0 THEN BEGIN
        NEW_FILES = [NEW_FILES,D(COMPLEMENT).SERVER_FILES]

        ; ===> Add the new CHKSUMS to the MASTER list
        CKSUMS = READ_TXT(DIR + CHECKSUMS)                                                                         ; Read as a text array that can be appended with new checksum info
        CKSUMS = [CKSUMS,D(COMPLEMENT).NAMES + ' ' + D(COMPLEMENT).NEW_CKSUM]                                      ; Create checksum string
        CKSUMS = CKSUMS[SORT(CKSUMS)]                                                                              ; Sort by file name
        CKSUMS = CKSUMS[UNIQ(CKSUMS)]                                                                              ; Remove any duplicates
        IF HAS(CKSUMS,'{') EQ 1 OR HAS(CKSUMS,'}') EQ 1 THEN CKSUMS = REPLACE(CKSUMS,['{ ','}'],['',''])           ; Remove any { or } from the CKSUM strings
        IF EXISTS(DIR + CHECKSUMS) EQ 1 THEN FILE_MOVE, DIR+CHECKSUMS, DIR+'CHECKSUMS'+SL+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'
        WRITE_TXT,DIR + CHECKSUMS, CKSUMS                                                                           ; Save the file

        FP = PARSE_IT(D(COMPLEMENT).SERVER_FILES)
        BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))
        YDOY = YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3))
        IF ~KEY(SKIP_PLOTS) THEN IF N_ELEMENTS(BSET) GT 1 THEN PLT = PLOT(YDOY,BSET.N,/CURRENT,/OVERPLOT,SYMBOL='SQUARE',/SYM_FILLED,COLOR='BLACK',FILL_COLOR='RED',SYM_SIZE=1.0,THICK=2) $
        ELSE SYM = SYMBOL(YDOY,BSET.N,/CURRENT,SYMBOL='SQUARE',/SYM_FILLED,SYM_FILL_COLOR='RED',SYM_COLOR='BLACK',/DATA, SYM_SIZE=1.0)
      ENDIF ELSE NEW_FILES = [NEW_FILES,'*** No new files']

      IF COUNT GE 1 THEN BEGIN
        PLUN, LUN, NUM2STR(COUNT) + ' Files FAILED to download completely'
        FOR I=0, COUNT-1 DO PLUN, LUN, 'Download of ' + D(I).SERVER_FILES + ': FAILED', 0
        D = D[OK]
        COUNT_DOWNLOAD_LOOP = COUNT_DOWNLOAD_LOOP + 1
        IF COUNT_DOWNLOAD_LOOP LE 5 THEN GOTO, REPEAT_DOWNLOAD
        FP = PARSE_IT(D.SERVER_FILES)
        BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))
        YDOY = YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3))
        IF ~KEY(SKIP_PLOTS) THEN IF N_ELEMENTS(BSET) GT 1 THEN PLT = PLOT(YDOY,BSET.N,/CURRENT,/OVERPLOT,SYMBOL='STAR',/SYM_FILLED,SYM_COLOR='BLACK',SYM_FILL_COLOR='YELLOW',SYM_SIZE=1.5,THICK=2) $
        ELSE SYM = SYMBOL(YDOY,BSET.N,/CURRENT,SYMBOL='STAR',/SYM_FILLED,SYM_COLOR='BLACK',SYM_FILL_COLOR='YELLOW',SYM_SIZE=1.5,/DATA)
        F = WHERE(FILE_TEST(D.SERVER_FILES) EQ 1,COUNTF)
        IF COUNTF GE 1 THEN FILE_DELETE, D(F).SERVER_FILES, /VERBOSE    ; Remove files that were partially downloaded so that they do not crash subsequent processing
      ENDIF

      CD, !S.PROGRAMS
    ENDIF ELSE PLUN, LUN, 'No new files to download.'
    PLUN, LUN, 'Finished downloading files for ' + DATASETS(N) + ' ' + SYSTIME()

    
    SKIP_DATASET:
    IF ANY(LUN) THEN BEGIN
      CLOSE, LUN
      FREE_LUN, LUN
    ENDIF
    NEW_FILES = [NEW_FILES, 'Finished downloading ' + DATASET + ' at ' + SYSTIME(), ' ']
    IF COUNT_DOWNLOAD_LOOP GT 900 THEN GOTO, END_DOWNLOADS  ; If the wget downloads were canceled, then jump out of the DATASET loop
;  ENDFOR
  END_DOWNLOADS:

  ; ===> Save and email the list of new files that were downloaded
  LI, NEW_FILES
  PRINT, NUM2STR(N_ELEMENTS(NEW_FILES)) + ' new files were downloaded.'
  NEW_FILES_LIST = BATCH_LOG_DIR + 'NEW_DOWNLOADS' + SL + DATE_NOW(/DATE_ONLY) + '.log'
  WRITE_TXT, NEW_FILES_LIST, [NEW_FILES, ' ', 'Finished BATCH_DOWNLOADS at ' + SYSTIME()]
  ATTACHMENTS = NEW_FILES_LIST

  ; ===> Send email with the list and plot of new files
  ; CMD = 'echo "Files downloaded on ' + DATE_NOW(/DATE_ONLY) + '" | mailx -s "Nightly downloads ' + SYSTIME() + '" ' + ' -a ' + NEW_FILES_LIST + ' ' + NEW_FILES_PLOT + ' ' + MAILTO
  ; ===> Save and email the new files plot
  IF ~KEY(SKIP_PLOTS) THEN BEGIN
    NEW_FILES_PLOT = BATCH_LOG_DIR + 'NEW_DOWNLOADS' + SL + DATE_NOW(/DATE_ONLY) + '.png'
    W.SAVE, NEW_FILES_PLOT
    W.CLOSE
    ATTACHMENTS = [ATTACHMENTS,NEW_FILES_PLOT]
    CMD = 'echo "Files downloaded on ' + DATE_NOW(/DATE_ONLY) + '" | mailx -s "Nightly downloads ' + SYSTIME() + '" ' + ' -a ' + NEW_FILES_LIST +  ' -a ' + NEW_FILES_PLOT + ' ' + MAILTO
    PNG   = NEW_FILES_PLOT
  ENDIF ELSE CMD = 'echo "Files downloaded on ' + DATE_NOW(/DATE_ONLY) + '" | mailx -s "Nightly downloads ' + SYSTIME() + '" ' + ' -a ' + NEW_FILES_LIST + ' ' + MAILTO
  IF KEY(EMAIL) THEN SPAWN, CMD

  FILES = NEW_FILES_LIST
  


  DONE:
  PRINT,'END OF ' + ROUTINE_NAME
END; #####################  End of Routine ################################
