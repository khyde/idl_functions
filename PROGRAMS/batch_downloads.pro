; $ID:	BATCH_DOWNLOADS.PRO,	2020-07-09-08,	USER-KJWH	$
;+

PRO BATCH_DOWNLOADS, DATASETS, SWITCHES=SWITCHES, DATERANGE=DATERANGE, SKIP_PLOTS=SKIP_PLOTS, PLT_DATERANGE=PLT_DATERANGE, AREA_CHECK_ONLY=AREA_CHECK_ONLY, $
  LOGFILE=LOGFILE, PNG=PNG, FILES=FILES, EMAIL=EMAIL, ATTACHMENTS=ATTACHMENTS, BUFFER=BUFFER

;                     OC_MODISA_1KM   = OC_MODISA_1KM,  $
;                     OC_MODIST_1KM   = OC_MODIST_1KM,  $
;                     OC_VIIRS_1KM    = OC_VIIRS_1KM,   $
;                     OC_MERIS_FRS    = OC_MERIS_FRS,   $
;                     OC_SEAWIFS_1KM  = OC_SEAWIFS_1KM, $
;                     OC_CZCS_1KM     = OC_CZCS_1KM,    $
;                     SST_MODISA_1KM  = SST_MODISA_1KM, $
;                     SST_MODIST_1KM  = SST_MODIST_1KM, $
;                     OC_MODISA_4KM   = OC_MODISA_4KM,  $
;                     OC_MODIST_4KM   = OC_MODIST_4KM,  $
;                     SST_MODISA_4KM  = SST_MODISA_4KM, $
;                     SST_MODIST_4KM  = SST_MODIST_4KM, $
;                     SST_MUR_1KM     = SST_MUR_1KM,    $
;                     OC_VIIRS_4KM    = OC_VIIRS_4KM,   $
;                     SST_AVHRR_25DEG = SST_AVHRR_25DEG,$
;                     SST_AVHRR_4KM   = SST_AVHRR_4KM,  $
;                     SST_VIIRS_1KM   = SST_VIIRS_1KM,  $
; NAME: BATCH_DOWNLOADS
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
;   FEB 12, 2016 - K.J.W. HYDE
;   APR 05, 2016 - KJWH: Added INIT (a keyword in SWITCHES) option to check the files in the download list and see if any are missing on the local server
;   JUL 07, 2016 - KJWH: Updated a MASTER CHECKSUM list for the L2 files.
;                        Updated the DATERANGE to be the SENSOR DATES if none are provided
;   JUL 25, 2016 - KJWH: Updated LOGFILE output
;                        Now doing FILE_TEST before deleting any files
;   OCT 04, 2016 - KJWH: Added MODIST-1KM subscription (L2 Ocean Color Files)
;   OCT 31, 2016 - KJWH: Added SKIP_PLOTS keyword to supress the plotting steps
;   NOV 07, 2016 - KJWH: Updated the LON/LAT MIN/MAX coordinates
;                        Changed the name of the DOWNLOAD list to include _NEW_2016
;   DEC 05, 2016 - KJWH: Added a step to look for input DATASETS - If none, use defaults
;   DEC 19, 2016 - KJWH: Added PLT_DATERANGE keyword and changed default range to 6 months instead of 2
;   DEC 20, 2016 - KJWH: Updated the Ocean Color websites to HTTPS
;   JAN 03, 2017 - KJWH: Now checking the file size using FILE_INFO of FILELIST_CHECKSUMS.txt to see if it is a blank file
;   DEC 06, 2017 - KJWH: Updated DATASET names and directories to reflect changes made in !S.DATASETS
;   DEC 07, 2017 - KJWH: Added SST_VIIRS_1KM dataset
;   DEC 22, 2017 - KJWH: Added VERBOSE to the GET_CHECKSUMS call
;   FEB 15, 2018 - KJWH: Updated the L1A and L2 search patterns.
;   FEB 26, 2018 - KJWH: Updated plotting defaults
;                        Now looping through the file search 5 times if files are still missing and the process was terminated by killwget
;   MAR 30, 2018 - KJWH: Now recreating the final MUR URLS from the SNAMES
;                          SNAMES = CLIST[OK].(0)
;                          DP = DATE_PARSE((PARSE_IT(SNAMES)).DATE_START)
;                          URLS = FTP + DP.YEAR + SL + DP.IDOY + SL
;   APR 04, 2018 - KJWH: Added a step to delete files that were partially downloaded so that they don't crash subsequent processing
;   APR 23, 2018 - KJWH: Updated the mailx command to include both the list of files and plot (if available)
;   MAY 17, 2018 - KJWH: Added ATTACHMENTS as an optional output keyword to return the file name of the NEW_FILES_LIST and the NEW_FILES_PLOT
;   NOV 14, 2018 - KJWH: Changed MUR address from FTP to HTTPS
;   NOV 26, 2018 - KJWH: Updated LOG directory location and file names
;   DEC 12, 2018 - KJWH: Updated the DATERANGE parameter so that it isn't overwritten by SWITCHES.  Now listed as DTR after the call to SWITCHES
;   APR 12, 2019 - KJWH: Added OC-JPSS1-1KM dataset
;                        Added steps to just use the FILELIST if no files can be found during the search (currently unable to find the JPSS1 files)
;                        Now removing any geolocation (.GEO) files from the download list
;                        Added LOGLUN keyword to use the LUN from existing log file
;                        Changed LOG keyword to LOGFILE keyword
;   JUN 04, 2020 - KJWH: Change !S.MAIN + 'SCRIPTS' to !S.SCRIPTS                     
;-

  ;*************************
  ROUTINE_NAME='BATCH_DOWNLOADS'
  PRINT, 'Running: '+ROUTINE_NAME

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
  IF NONE(DATASETS) THEN DATASETS = ['OC-MODISA-1KM','OC-MODISA-4KM','OC-VIIRS-4KM','OC-VIIRS-1KM','OC-JPSS1-1KM','SST-MUR-1KM','SST-AVHRR-4KM','SST-MODISA-1KM','SST-MODIST-1KM'] $
                    ELSE DATASETS = STRUPCASE(DATASETS)
  IF NONE(SWITCHES) THEN SWIS = REPLICATE('Y',N_ELEMENTS(DATASETS)) ELSE SWIS = SWITCHES ; By default, recheck the files from the last 90 days
  IF N_ELEMENTS(SWIS) EQ 1 AND N_ELEMENTS(DATASETS) GT 1 THEN SWIS = REPLICATE(SWIS,N_ELEMENTS(DATASETS))
  IF N_ELEMENTS(SWIS) NE N_ELEMENTS(DATASETS) THEN MESSAGE, 'ERROR: Number of SWITCHES must equal number of DATASETS'

  ; ===> REMOTE FTP LOCATIONS
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/'
  OC_SEARCH = 'https://oceandata.sci.gsfc.nasa.gov/api/file_search.cgi'
  MUR_FTP   = 'https://podaac-tools.jpl.nasa.gov/drive/files/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/'; 'ftp://podaac-ftp.jpl.nasa.gov/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/';
  AVH25_FTP = 'ftp://podaac-ftp.jpl.nasa.gov/allData/ghrsst/data/GDS2/L4/GLOB/NCEI/AVHRR_OI/v2/'
  AVH4_FTP  = 'https://data.nodc.noaa.gov/pathfinder/Version5.3/L3C/';'ftp://ftp.nodc.noaa.gov/pub/data.nodc/pathfinder/Version5.3/L3C/' ; CURRENTLY NOT WORKING
  ;OCCCI_FTP = 'ftp://oceancolour.org/occci-v3.1/sinusoidal/netcdf/daily/'; 'ftp://ftp.rsg.pml.ac.uk/occci-v3.1/sinusoidal/netcdf/daily/'

  PODAAC_URL = 'https://podaac-tools.jpl.nasa.gov/drive/files'
  MUR_USR = 'khyde' & MUR_PSW = 'FydOA4zodKWghvNRKH2P';'NASAPhyt0pl@nkt0nRS'

  ; ===> NARRAGANSETT 1KM BOUNDARIES
  LATMIN = 22.5 ; 17.92 (Updated 11/07/2016 by KHyde)
  LATMAX = 48.5 ; 55.4
  LONMIN = -82.5 ; -97.8
  LONMAX = -51.5 ; -43.8

  ; ===> REPROCESSING INFO FOR CHECKING THE MODIS L2 SST FILES
  REPRO_DATE = '20190101'
  REPRO = 'R2018'

  ; ===> INITIALIZE PARAMETERS
  NEW_FILES = 'Starting download at ' + SYSTIME()
  WGET_RESULT = ''

  ; ===> INITIALIZE PLOT
  IF ~KEY(SKIP_PLOTS) THEN BEGIN
    IF N_ELEMENTS(DATASETS) EQ 1 THEN YDIM = 400 ELSE YDIM = 200*N_ELEMENTS(DATASETS)
    W = WINDOW(DIMENSIONS=[1000,YDIM],BUFFER=BUFFER)
  ENDIF ; ~KEY(SKIP_PLOTS)

  ; ===> LOOP THROUGH DATASETS
  FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    COUNT_DOWNLOAD_LOOP = 0
    DATASET = STRUPCASE(DATASETS(N))

    SWITCHES, SWIS(N),STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,DATERANGE=DTR ; Get processing switches
    IF KEY(INIT) THEN RECHECK_CKSUMS = 1                                                            ; When downloading from the MASTER download list, recheck all of the checksums of the local files
    ID = '' & PAT = '' & CHECK_SST = 0 & MD5CKSUM = 0 & LIST_ONLY = 0 & FTP_SUBDIR = '' & USR='' & PSW = ''  ; Set SUBID and PATTERN to null strings and CHECK_SST to 0
    NASA=1 ; Default is that the dataset is from the NASA Ocean Color web
    EXTRACTED=0; Default for the NASA Ocean Color web
    CASE DATASET OF                                                                                 ; Get dataset specific information
      'OC-CZCS-1KM':      BEGIN & SUBDIR='L2'    & SENSOR='czcs'    & PREFIX='C' & TYPE='L2'  & PAT='L2_MLAC_OC.nc' & LIST_ONLY = 1 & END
   ;   'OC-SEAWIFS-1KM':   BEGIN & SUBDIR='L1A'   & SENSOR='seawifs' & PREFIX='S' & TYPE='L1'  & PAT='L1A_MLAC.bz2'  & LIST_ONLY = 1 & END
   ;   'OC-MODISA-1KM':    BEGIN & SUBDIR='L1A'   & SENSOR='aqua'    & PREFIX='A' & TYPE='L1'  & PAT='L1A_LAC.bz2'   & ID='1689' & END
   ;   'OC-MODIST-1KM':    BEGIN & SUBDIR='L2'    & SENSOR='terra'   & PREFIX='T' & TYPE='L2'  & PAT='L2_LACOC.nc'   & ID='1743' & END
   ;   'OC-VIIRS-1KM':     BEGIN & SUBDIR='L1A'   & SENSOR='viirs'   & PREFIX='V' & TYPE='L1'  & PAT='L1A_SNPP.nc'   & ID='1690' & END
   ;   'OC-JPSS1-1KM':     BEGIN & SUBDIR='L1A'   & SENSOR='viirsj1' & PREFIX='V' & TYPE='L1'  & PAT='L1A_JPSS1.nc'  & ID='2297' & END
   ;   'OC-MERIS-FRS':     BEGIN & SUBDIR='L2'    & SENSOR='meris'   & PREFIX='M' & TYPE='L2'  & END ; PAT='L2_FRS_OC'
  ;    'OC-OCCCI-4KM':     BEGIN & SUBDIR='L3B4'  & SENSOR='occci'   & PREFIX=''  & TYPE='SIN' & PAT=+ 'ESACCI-OC-L3S-'+['CHLOR_A','RRS','IOP','K_490'] +'-MERGED-1D_DAILY_4km_SIN_PML_'+['OCx','RRS','OCx_QAA','KD490_Lee'] + '-*-fv3.1.nc' & FTP_SUBDIR=['chlor_a','rrs','iop','kd'] & USR='oc-cci-data' & PSW='ELaiWai8ae' & END
  ;    'SST-MODIST-N4UM':  BEGIN & SUBDIR='L2'    & SENSOR='terra'   & PREFIX='TERRA_MODIS' & TYPE='L2'  & PAT='L2.SST4.nc' &  ID='1148'  & EXTRACTED=1 & CHECK_SST=1 & END
  ;    'SST-MODISA-N4UM':  BEGIN & SUBDIR='L2'    & SENSOR='aqua'    & PREFIX='AQUA_MODIS'  & TYPE='L2'  & PAT='L2.SST4.nc' &  ID='1147'  & EXTRACTED=1 & CHECK_SST=1 & END
  ;    'SST-MODIST-N11UM': BEGIN & SUBDIR='L2'    & SENSOR='terra'   & PREFIX='TERRA_MODIS' & TYPE='L2'  & PAT='L2.SST.nc'  & LIST_ONLY=1 & EXTRACTED=1 & CHECK_SST=1 & END
  ;    'SST-MODISA-N11UM': BEGIN & SUBDIR='L2'    & SENSOR='aqua'    & PREFIX='AQUA_MODIS'  & TYPE='L2'  & PAT='L2.SST.nc'  & LIST_ONLY=1 & EXTRACTED=1 & CHECK_SST=1 & END
  ;    'SST-MODIST-D11UM': BEGIN & SUBDIR='L2'    & SENSOR='terra'   & PREFIX='TERRA_MODIS' & TYPE='L2'  & PAT='L2.SST.nc'  & LIST_ONLY=1 & EXTRACTED=1 & CHECK_SST=1 & END
  ;    'SST-MODISA-D11UM': BEGIN & SUBDIR='L2'    & SENSOR='aqua'    & PREFIX='AQUA_MODIS'  & TYPE='L2'  & PAT='L2.SST.nc' &  LIST_ONLY=1 & EXTRACTED=1 & CHECK_SST=1 & END
      'OC-SEAWIFS-9KM':   BEGIN & SUBDIR='L3B9'  & SENSOR='seawifs' & PREFIX='S' & TYPE='L3b' & PAT='DAY_'     +['CHL']+'.nc' & END ; 'RRS','IOP','PAR','KD490','POC'
      'OC-MODISA-4KM':    BEGIN & SUBDIR='L3B4'  & SENSOR='aqua'    & PREFIX='A' & TYPE='L3b' & PAT='DAY_'     +['CHL','RRS','IOP','PAR','KD490','POC']+'.nc' & END ; 'RRS','IOP','PAR','KD490','POC'
      'OC-MODIST-4KM':    BEGIN & SUBDIR='L3B4'  & SENSOR='terra'   & PREFIX='T' & TYPE='L3b' & PAT='DAY_'     +['CHL']+'.nc' & END ; ,'RRS','PAR'
      'OC-VIIRS-4KM':     BEGIN & SUBDIR='L3B4'  & SENSOR='viirs'   & PREFIX='V' & TYPE='L3b' & PAT='DAY_SNPP_'+['CHL','RRS','IOP','PAR','KD490','POC']+'.nc' & END
      'SST-MODIST-4KM':   BEGIN & SUBDIR='L3B4'  & SENSOR='terra'   & PREFIX='T' & TYPE='L3b' & PAT='DAY_'     +['SST4']+'.nc' & END
      'SST-MODISA-4KM':   BEGIN & SUBDIR='L3B4'  & SENSOR='aqua'    & PREFIX='A' & TYPE='L3b' & PAT='DAY_'     +['SST4']+'.nc' & END
      'SST-VIIRS-1KM':    BEGIN & SUBDIR='L2'    & SENSOR='viirs'   & PREFIX='V' & TYPE='L2'  & PAT='L2_SNPP_' +['SST3']+'.nc' & ID='1984' & CHECK_SST=1 & END
      'SST-MUR-1KM':      BEGIN & SUBDIR='L4'    & SENSOR='mur'     & PREFIX=''  & TYPE='L3b' & PAT='-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc' & NASA=0 & END
      'SST-AVHRR-25DEG':  BEGIN & SUBDIR='L25'   & SENSOR='avhrr'   & PREFIX=''  & TYPE='L3b' & PAT='-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.0.nc' & NASA=0 & END
   ;   'SST-AVHRR-4KM':    BEGIN & SUBDIR='L3'    & SENSOR='avhrr'   & PREFIX=''  & TYPE='L3'  & PAT='-NCEI-L3C_GHRSST-SSTskin-AVHRR_Pathfinder-PFV5.3_NOAA*night-v02.0-fv01.0.nc' & NASA=0 & END
      ELSE: BEGIN
        NEW_FILES = 'ERROR: Dataset - ' + DATASET + ' - not found in BATCH_DOWNLOADS'
        PRINT, NEW_FILES
        GOTO, SKIP_DATASET
      END
    ENDCASE
    
    IF DTR EQ [] AND ~KEY(LIST_ONLY) THEN DTR = [DAY90,STRMID(DATE_NOW(),0,8)]
    IF ANY(DATERANGE) THEN DTR = DATERANGE
    IF DTR EQ [] THEN DTR = SENSOR_DATES(VALIDS('SENSORS',DATASET))
    
    BRK = STR_BREAK(DATASET,'-')                                                                    ; Break up the DATASET string
    SERVER = !S.DATASETS + BRK[0] + SL                                                              ; Use the first string from BRK as the subdirectory in DATASETS
    DTSET = BRK[1]

    ; ===> Determine dataset specific files and directories
    L1_ORDER_LIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + REPLACE(DATASET,'-','_') + '.txt' ; File with the 1km list of files to download
    DIR = SERVER + DTSET + SL + SUBDIR + SL
    SDIR = DIR + 'NC' + SL
    LDIR = BATCH_LOG_DIR + DTSET + SL
    CDIR = DIR + 'CHECKSUMS' + SL
    SUSPECT = DIR + 'SUSPECT' + SL
    ERROR   = DIR + 'ERROR'   + SL
    CHECKSUMS = 'CHECKSUMS.txt'
    FILELIST_CHECKSUMS = 'FILELIST_CHECKSUMS.txt'
    DIR_TEST, [LDIR,CDIR,SDIR]

    ; ===> Open dataset specific log file
    IF NONE(LOGFILE) THEN LOGFILE = LDIR + DATASETS(N)  + '_' + DATE_NOW(/DATE_ONLY) + '.log'
    OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180 
    PLUN,LUN,'*****************************************************************************************************',3
    PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
    PLUN,LUN,'Downloading files in ' + DATASET, 0

    NEW_FILES = [NEW_FILES,'Downloading files to ' + DATASET + ' at ' + SYSTIME()]

    SDATES = SENSOR_DATES(DTSET)                                                        ; Get the SENSOR daterange
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
        IF N_ELEMENTS(BSET) GT 1 THEN PLT = PLOT(YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3)),BSET.N,/CURRENT,/OVERPLOT,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='BLUE',THICK=2,SYM_SIZE=0.75)
      ENDIF ELSE PLT = PLOT(AX.JD,[0,20],/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=5, /CURRENT,XRANGE=AX.JD,YRANGE=NICE_RANGE([0,20]),LAYOUT=[1,N_ELEMENTS(DATASETS),N+1],TITLE=DATASET,MARGIN=[0.05,0.15,0.025,0.2])
    ENDIF ; ~KEY(SKIP_PLOTS)

    IF KEY(AREA_CHECK_ONLY) THEN GOTO, AREA_CHECK

    ; ===> Create NULL arrays to be filled in during the downloading process
    CKSUMS = []
    SNAMES = []
    URLS   = []

    ; ===> Get list of files and checksums for the MUR and AVHRR SST files
    IF DATASET EQ 'SST-MUR-1KM' OR DATASET EQ 'SST-AVHRR-25DEG' OR DATASET EQ 'SST-AVHRR-4KM' OR DATASET EQ 'OC-OCCCI-4KM' THEN BEGIN
      DATES = CREATE_DATE(DTR[0],DTR[1],/DOY,/CURRENT_DATE)                                                           ; Create list of DOY dates
      YEARS = STRMID(DATES,0,4) & UYEARS = YEARS[UNIQ(YEARS)]                                                         ; Find unique years in the DATERANGE
      DOYS  = STRMID(DATES,4,3) & DOYS = DOYS[SORT(DOYS)] & DOYS = DOYS[UNIQ(DOYS)]
      
      MD5CKSUM = 1                                                                                                    ; Use MD5SUM to validate MUR checksum
      DO_DOY = 1
      ADD_SUBDIR = 0
      SKIP_DT = 0

      DOYLIST = []
      CASE DATASET OF
        'SST-MUR-1KM':      BEGIN & FTP=MUR_FTP & DOYLIST = DOYS & END
        'SST-AVHRR-25DEG':  FTP=AVH25_FTP
       ; 'SST-AVHRR-4KM':    BEGIN & FTP=AVH4_FTP  & SKIP_DT=1 & JUNK_WGET_AVHRR, LOGLUN=LUN & END
        ;'OC-OCCCI-4KM':     BEGIN & FTP=OCCCI_FTP & SKIP_DT=1 & JUNK_WGET_OCCCI & END ; Need to verify type of CHECKSUM
      ENDCASE

      IF KEY(SKIP_DT) THEN GOTO, SKIP_DATASET

      YURLS = []
      YNAMES = []
      IF KEY(DO_DOY) THEN BEGIN
        FOR Y=0, N_ELEMENTS(UYEARS)-1 DO BEGIN                                                                        ; Loop through years to get the directory and file names
          AYEAR = UYEARS(Y)
          IF HAS(DATASET,'MUR') THEN BEGIN
            USER=' --user='+MUR_USR + ' --password='+MUR_PSW
            PSW =MUR_PSW
          ENDIF ELSE USER = ''
       ;   CMD = 'curl -l ' + USER + FTP + SL + AYEAR + SL                                                             ; Use CURL to get a list of directories on the remote server 
       ;   SPAWN, CMD, DOYLIST, ERR
          IF DOYLIST[0] EQ '' THEN CONTINUE
          YURLS = [YURLS, AYEAR + SL + DOYLIST]                                                                       ; Create a list of URLS
          CASE DATASET OF
            'SST-MUR-1KM':     YNAMES = [YNAMES, YDOY_2DATE(AYEAR, DOYLIST, 09, 00, 00)]                              ; Create a list of dates based on the year and doy (HH,MM,SS are specific to the MUR files and may change with subsequent versions)
            'SST-AVHRR-25DEG': YNAMES = [YNAMES, YDOY_2DATE(AYEAR, DOYLIST, 12, 00, 00)]
            'SST-AVHRR-4KM':   YNAMES = [YNAMES, YDOY_2DATE(AYEAR, DOYLIST, 00, 00, 00)]
          ENDCASE
        ENDFOR
        YNAMES = DATE_SELECT(YNAMES,DTR,SUBS=YSUBS)
        SNAMES = YNAMES + PAT                                                                                         ; Create a list of file names
        URLS   = FTP + YURLS + SL                                                                                     ; Create a list of full URL names
        URLS   = URLS(YSUBS)                                                                                          ; Susbset the URL names based on the DATERANGE
        WRITE_TXT, DIR + 'CHECKSUMS_TO_DOWNLOAD.txt', URLS  + SNAMES + '.md5'                                         ; Create list of CHECKSUM files to download
        CMD = 'wget --tries=3 --retry-connrefused -c -N' + USER + ' -i ' + DIR + 'CHECKSUMS_TO_DOWNLOAD.txt -a ' + LOGFILE        ; Checksum download command
        PLUN, LUN, CMD
        CD, DIR + 'CHECKSUMS' + SL
        SPAWN, CMD, LOG, ERR
        IF LOG[0] NE '' THEN PLUN, LUN, LOG
        IF ERR[0] NE '' THEN PLUN, LUN, ERR
        CD, DIR
      ENDIF ELSE BEGIN ; DO_DOY
        FOR Y=0, N_ELEMENTS(UYEARS)-1 DO BEGIN
          YR = UYEARS(Y)
          CD, DIR
          FOR PTH=0, N_ELEMENTS(PAT)-1 DO BEGIN
            PATTERN = 'search='+PAT(PTH)
            IF KEY(ADD_SUBDIR) THEN _FTP = FTP+FTP_SUBDIR(PTH)+SL+YR+SL  ELSE _FTP = FTP+YR+SL

            IF KEY(USR) THEN _FTP = ' -u ' + USR + ':' + PSW + ' ' + _FTP

            ;  CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -O- ' + _FTP + ' > ' + FILELIST_CHECKSUMS + ' -a ' + LOGFILE + ' | md5sum'
            ;  CMD = 'wget --tries=3 --post -O- ' + URLS + ' > ' + FILELIST_CHECKSUMS + ' | md5sum'

            CMD = 'curl -l ' + _FTP
            PLUN, LUN, CMD
            SPAWN, CMD, FLIST, ERR

            CMD = 'curl -s ' + _FTP + FLIST[0] + ' | sha1sum'
            PLUN, LUN, CMD
            SPAWN, CMD, SH1, ERR
            ;             PATTERN = 'search=*'+PAT(PTH)+'&sensor='+SENSOR+'&sdate='+DPS.DASH_DATE+'&edate='+DPE.DASH_DATE+'&dtype='+TYPE
            ;            CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -O - '+OC_SEARCH+' > ' + FILELIST_CHECKSUMS + ' -a ' + LOGFILE
            ;            PLUN, LUN, CMD

            IF LOG[0] NE '' THEN PLUN, LUN, LOG
            IF ERR[0] NE '' THEN PLUN, LUN, ERR
          ENDFOR
          STOP
        ENDFOR
        CD, !S.PROGRAMS
      ENDELSE

      ; Skip reading the existing CHECKSUMS file because it often becomes corrupt and crashes the processing
      ;      IF FILE_TEST(DIR + CHECKSUMS) EQ 1 THEN BEGIN                                                                 ; Make a checksum list for the MUR dataset
      ;        PRINTF, LUN, 'Reading: ' + DIR + CHECKSUMS
      ;        CKSUMS = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
      ;        OK = WHERE_MATCH(SNAMES, CKSUMS.(0), COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, VALID=VALID)    ; Look for files that are already in the master checksum list
      ;        IF NCOMPLEMENT GT 0 THEN SNAMES = SNAMES(COMPLEMENT) ELSE SNAMES = []                                       ; Identify missing names
      ;        CKSUMS = READ_TXT(DIR + CHECKSUMS)                                                                          ; Read as a text array that can be appended with new checksum info
      ;      ENDIF ELSE

      CKSUMS = []
      FOR S=0, N_ELEMENTS(SNAMES)-1 DO BEGIN
        IF ~EXISTS(DIR + 'CHECKSUMS' + SL + SNAMES[S] + '.md5') THEN CONTINUE
        CK = READ_DELIMITED(DIR + 'CHECKSUMS' + SL + SNAMES[S] + '.md5',DELIM='SPACE',/NOHEADING)
        CK_TXT = CK.(1)+' '+CK.(0)                                                                                  ; Add missing checksums to the master file
        IF WHERE_STRING(CK_TXT,'{') NE [] THEN STOP
        CKSUMS = [CKSUMS,CK_TXT]
      ENDFOR
     ; IF EXISTS(DIR + CHECKSUMS) EQ 1 THEN FILE_MOVE, DIR+'CHECKSUMS.txt', DIR+'CHECKSUM_BACKUP'+SL+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'     ; Create a backup of the CKSUM MASTER
      WRITE_TXT, DIR+CHECKSUMS, CKSUMS                                                                             ; Write updated checksum file
      CLIST = READ_DELIMITED(DIR + CHECKSUMS, DELIM='SPACE',/NOHEADING)                                             ; Read as a structure to get the CHECKSUM values
      OK = WHERE_MATCH(CLIST.(0), YNAMES + PAT, COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, VALID=VALID) ; Find CHECKSUMS for matching SNAMES
      CKSUMS = CLIST[OK].(1)
      SNAMES = CLIST[OK].(0)
      DP = DATE_PARSE((PARSE_IT(SNAMES)).DATE_START)
      URLS = FTP + DP.YEAR + SL + DP.IDOY + SL
      PAT = []                                                                                                      ; Make PAT null to skip the PATTERN loop
    ENDIF ;  IF DATASET EQ 'SST-MUR-1KM' THEN BEGIN

    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    IF KEY(LIST_ONLY) THEN GOTO, SKIP_ORDERED_DATA

    ; ===> Get the list of files and checksums from the NASA server
    FOR PTH=0, N_ELEMENTS(PAT)-1 DO BEGIN ; Loop through the L3 Patterns (products)
      PLUN, LUN, 'Get CHECKSUMS.txt from remote server for ' + DATASET + ' ' + PAT(PTH)
      CD, DIR

   ;   IF KEY(NASA) THEN COOKIES = ' --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition' ELSE COOKIES=''
      IF KEY(EXTRACTED) THEN TYPE='2' ELSE TYPE='1'
      IF ID NE '' THEN PATTERN = 'subID='+ID $ ; +'&subType='+TYPE                                                                   ; Create a search pattern based on dataset specific info
                  ELSE PATTERN = 'search=*'+PAT(PTH)+'&sensor='+SENSOR+'&sdate='+DPS.DASH_DATE+'&edate='+DPE.DASH_DATE+'&dtype='+TYPE
      CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -O - '+OC_SEARCH+' > ' + FILELIST_CHECKSUMS + ' -a ' + LOGFILE
      IF KEY(NASA) THEN CMD = CMD + ' | wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --no-check-certificate --content-disposition -i -'

;CMD='wget "https://oceandata.sci.gsfc.nasa.gov/api/file_search?subID=1148&subType=1&format=txt&addurl=1" -O - | wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --no-check-certificate --content-disposition -i -'
      
      PLUN, LUN, CMD
      SPAWN, CMD, RES, ERR

      PLUN, LUN, 'Reading: ' + FILELIST_CHECKSUMS
      CLIST = READ_TXT(FILELIST_CHECKSUMS)                                                                        ; Read the output FILE_CHECKSUMS file
      IF CLIST NE [] THEN BEGIN
        IF STRMID(CLIST[0],0,2) EQ '<!' OR CLIST EQ [] THEN BEGIN                                                 ; If no remote server files are found, the file will start with <!
          PLUN, LUN, 'ERROR: No valid files found on remote server'
          PLUN, LUN, CLIST,0
          GOTO, SKIP_ORDERED_DATA
        ENDIF
        IF STRMID(CLIST[0],0,10) EQ 'Your query' THEN BEGIN                                                       ; L3b searches return a text string as the first line that must be removed
          CLIST = CLIST[1:*]
          CLIST = CLIST[WHERE(CLIST NE '',/NULL)]                                                                 ; Remove any blank lines
          IF CLIST NE [] THEN WRITE_TXT, FILELIST_CHECKSUMS, CLIST                                                ; Resave list
        ENDIF

        CLIST = READ_DELIMITED(FILELIST_CHECKSUMS,DELIM='SPACE',/NOHEADING)                                       ; Read the CHECKSUM as a delimited file
        OK = WHERE_STRING(CLIST.(1), '.GEO', COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT)                      ; Find any GEOLOCATION files (usually in the VIIRS subscription)
        IF NCOMPLEMENT GE 1 THEN CLIST = CLIST(COMPLEMENT)                                                        ; Remove any GEOLOCATION files from the list
        CKSUMS = [CKSUMS,CLIST.(0)]                                                                               ; Get the list of checksums
        SNAMES = [SNAMES,CLIST.(1)]                                                                               ; Get the list of matching file names
        URLS   = [URLS,REPLICATE(OC_GET,N_ELEMENTS(CLIST))]                                                       ; Generate list of URLS
      ENDIF
      FILE_DELETE, FILELIST_CHECKSUMS
      PLUN, LUN, 'ERROR: No valid files found on remote server'
      GOTO, SKIP_ORDERED_DATA
    ENDFOR ; FOR PTH=0, N_ELEMENTS(PAT)-1 DO BEGIN - Loop through the WGET patterns (e.g. DAY_CHL, DAY_RRS)

    IF SNAMES NE [] THEN BEGIN & SRT = SORT(SNAMES) & SNAMES = SNAMES[SRT] & CKSUMS = CKSUMS[SRT] & ENDIF         ; Sort files
    PLUN, LUN, ROUNDS(N_ELEMENTS(SNAMES)) + ' files found on remote server.'
    FOR I=0, N_ELEMENTS(SNAMES)-1 DO PLUN, LUN, SNAMES[I] + '     ' + CKSUMS[I],0

    IF SNAMES EQ [] THEN BEGIN ; IF CLIST NE [] THEN BEGIN
      PLUN, LUN, 'ERROR: No CHECKSUMS were downloaded.'
      PLUN, LUN, 'Skip ' + DATASET + '...', 0
      CONTINUE
    ENDIF

    SKIP_ORDERED_DATA:

    ; ===> Add the files found on the NASA server to the DOWNLOAD list (there are no download lists for the L3 or MUR files)
    IF FILE_TEST(L1_ORDER_LIST) EQ 1 THEN BEGIN
      DLIST = READ_TXT(L1_ORDER_LIST) & NLIST = N_ELEMENTS(DLIST)
      IF SNAMES NE [] THEN DLIST = [DLIST,OC_GET+SNAMES]                                                          ; Add new files to the list
      DLIST = REVERSE(DLIST[SORT(DLIST)])                                                                         ; Sort names
      DLIST = DLIST[UNIQ(DLIST)]                                                                                  ; Remove any duplicates
      IF NLIST NE N_ELEMENTS(DLIST) THEN BEGIN                                                                    ; Rename and move old file and save new list
        FILE_MOVE, L1_ORDER_LIST, !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + 'REPLACED' + SL + REPLACE(DATASET,'-','_') + '-REPLACED_' + DATE_NOW() + '.txt'
        WRITE_TXT, L1_ORDER_LIST, DLIST
      ENDIF
    ENDIF

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
        PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(FLIST)) + ' files on the remote server for daterange: ' + SD(Y).DASH_DATE + ' to ' + ED(Y).DASH_DATE
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
    STR.SERVER_CKSUM = CKSUMS
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
      STR[OK_LOCAL].LOCAL_FILES = FP[VALID].NAME_EXT

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
        IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_FILES = CKSUMS[VALID].(0)
        IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_CKSUM = CKSUMS[VALID].(1)

        IF NCOMPLEMENT GT 0 THEN SNAMES = SNAMES[COMPLEMENT] ELSE SNAMES = []                                       ; Identify missing names
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
      IF KEY(NASA) THEN COOKIES = ' --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition' ELSE COOKIES=' -c -N'
      CMD = 'wget' + COOKIES + ' --progress=bar:force --tries=3 --retry-connrefused ' + USER + ' -i ' + DIR + 'DOWNLOAD_LIST.txt -a ' + LOGFILE
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

    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ;  ===> Check the L2 SST files to make sure they open and are within the area of interest
    AREA_CHECK:
    IF CHECK_SST EQ 1 THEN BEGIN
      PLUN, LUN, 'Verifying the SST files are not corrupt and within the area of interest...'

      DIR_TEST, [SUSPECT, ERROR]
      SUFFIX = 'L2.SST*'
      L2 = FILE_SEARCH(SDIR + PREFIX + '*' + SUFFIX + '.nc', COUNT=COUNT_L2)  ; Find the L2 files
      OK  = WHERE(GET_MTIME(L2,/JD) LT DATE_2JD(REPRO_DATE),COUNT_L2)         ; Find L2 files that are older than the REPRO_DATE
      IF COUNT_L2 GE 1 THEN STOP                                              ; ERROR - MTIME is older than the REPRO date

      ; ===> Create a list of files that have been confirmed to be within the East Coast domain
      L2S = []
      L2LIST = DIR + 'VERIFIED_L2_AREA_FILES.txt'
      IF FILE_TEST(L2LIST) EQ 1 THEN BEGIN
        VERIFIED_L2S  = READ_TXT(L2LIST)
        OK = WHERE_MATCH(L2, VERIFIED_L2S,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)   ; Find files that have already been verified
        IF NCOMPLEMENT GE 1 THEN BEGIN
          OPENU, VLUN, L2LIST, /GET_LUN, /APPEND                                                 ; Open text file
          L2S = L2(COMPLEMENT)                                                                   ; Subset files that have not been verified
        ENDIF
      ENDIF ELSE BEGIN
        OPENW, VLUN, L2LIST, /GET_LUN
        L2S = L2
      ENDELSE

      RERUN_SST_FILE_CHECK:
      SUSPECT_FILES = [] & ERROR_FILES = []                                                      ; Setup NULL arrays
      SUSPECT_NAMES = [] & ERROR_NAMES = []
      COUNTER = 0
      FOR NTH=0L, N_ELEMENTS(L2S)-1 DO BEGIN                                                     ; Loop through files not in the verified list
        AFILE = L2S[NTH]
        FP = FILE_PARSE(AFILE)
        PLUN, LUN, 'Checking: ' + FP.NAME_EXT
        NC = READ_NC(AFILE,PRODS='GLOBAL')                                                       ; Read the GLOBAL information in the nc file
        IF IDLTYPE(NC) EQ 'STRING' THEN BEGIN                                                    ; Look for any errors opening the file
          PLUN,LUN, '*** ERROR: ' + NC
          ERROR_FILES = [ERROR_FILES,AFILE]
          ERROR_NAMES = [ERROR_NAMES,FP.NAME_EXT]
          CONTINUE
        ENDIF

        GLOBAL  = NC.GLOBAL
        IF STRMID(GLOBAL.PROCESSING_VERSION[0],0,5) NE 'R2019' THEN STOP                       ; 2019.0 is the most recent processing as of January 1, 2016
        SLATMIN = GLOBAL.GEOSPATIAL_LAT_MIN                                                      ; Get the LON and LAT coordinates
        SLATMAX = GLOBAL.GEOSPATIAL_LAT_MAX
        SLONMIN = GLOBAL.GEOSPATIAL_LON_MIN
        SLONMAX = GLOBAL.GEOSPATIAL_LON_MAX

        ; ===> Look for files that are out-of-region (i.e. SUSPECT)
        IF SLATMAX LT LATMIN OR SLATMIN GT LATMAX OR SLONMAX LT LONMIN OR SLONMIN GT LONMAX THEN BEGIN
          PLUN, LUN, '*** ERROR: ' + AFILE + ' bounds are not within the east coast boundaries ===> Moving to L2_SUSPECT...'
          SUSPECT_FILES = [SUSPECT_FILES,AFILE]
          SUSPECT_NAMES = [SUSPECT_NAMES,FP.FIRST_NAME]
          CONTINUE
        ENDIF
        PLUN, VLUN, AFILE                                                                      ; If within the Narragansett Lab boundaries, add to the verified list
      ENDFOR
      IF L2S NE [] THEN BEGIN & CLOSE, VLUN & FREE_LUN, VLUN & ENDIF

      ; ===> Move the SUSPECT files and download the thumbnails
      IF SUSPECT_NAMES NE [] THEN BEGIN
        PLUN, LUN, 'Removing out-of-area suspect files...'
        FOR I=0, N_ELEMENTS(SUSPECT_NAMES)-1 DO PLUN, LUN, SUSPECT_FILES(I), 0
        FILE_MOVE, SUSPECT_FILES, SUSPECT, /VERBOSE, /OVERWRITE
        CD, SUSPECT
        SUSPECT_NAMES = SUSPECT_NAMES[UNIQ(SUSPECT_NAMES)] ; Remove redundant names (only need to download one SST file to determine if it is out-of-region)
        SFILES =  OC_BROWSE +  SUSPECT_NAMES + '.L2_LAC_SST.nc_SST_BRS.png?sub=l12image&file='+ SUSPECT_NAMES +'.L2_LAC_SST.nc_SST_BRS'; + ' -O ' + OOA_NAMES + '.L2_THUMBNAIL.png'
        WRITE_TXT, 'WGET_SUSPECT.TXT', SFILES
        PRINTF, LUN
        PRINTF, LUN, 'Downloading thumbnails for suspect files...'
        CMD = 'wget -c -N -a ' + LOGFILE + ' -i WGET_SUSPECT.TXT'
        PRINTF, LUN, CMD
        SPAWN, CMD

        ; ===> Remove SUSPECT MODIS L2 files from the download list
        DLIST = READ_TXT(L1_ORDER_LIST)
        DP     = FILE_PARSE(DLIST)
        LNAMES = DP.NAME_EXT
        SFILES = FILE_SEARCH(SUSPECT + PREFIX + '*' + SUFFIX + '.nc', COUNT=COUNT_SUSPECT)
        FP     = FILE_PARSE(SFILES)
        SNAMES = FP.NAME_EXT
        OK = WHERE_MATCH(LNAMES,SNAMES,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
        IF COUNT GE 1 AND NCOMPLEMENT GE 1 THEN BEGIN
          FILE_MOVE, L1_ORDER_LIST, !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + 'REPLACED' + SL + REPLACE(DATASET,'-','_') + '-REPLACED_' + DATE_NOW() + '.txt' ,/VERBOSE
          WRITE_TXT, L1_ORDER_LIST, OC_GET + LNAMES(COMPLEMENT)
        ENDIF
      ENDIF
      CD, !S.PROGRAMS


      ; ===> Move ERROR files out of the L2 directory and re-download the bad files
      IF ERROR_FILES   NE [] THEN BEGIN
        PLUN, LUN, 'Removing possible corrupt files...'
        FOR I=0, N_ELEMENTS(ERROR_FILES)-1 DO PLUN, LUN, ERROR_FILES(I), 0
        FILE_MOVE, ERROR_FILES,   ERROR,   /VERBOSE, /OVERWRITE
        WRITE_TXT, ERROR + 'WGET_ERROR.txt', OC_GET + ERROR_NAMES
        CD, SDIR
        CMD = 'wget -c -N -a ' + LOGFILE + ' -i ' + ERROR + 'WGET_ERROR.txt'
        PLUN, LUN, CMD
        SPAWN, CMD
        L2S = SDIR + ERROR_NAMES                              ; Names of the L2 files that were re-downloaded
        L2S = L2S[WHERE(FILE_TEST(L2S) EQ 1, COUNT_L2,/NULL)] ; Make sure the files exist before rerunning
        COUNTER = COUNTER + 1                                 ; Use counter to avoid getting stuck in an infinite loop if the file is always bad.
        IF COUNT_L2 GE 1 AND COUNTER LE 3 THEN GOTO, RERUN_SST_FILE_CHECK
      ENDIF
      CD, !S.PROGRAMS
      PLUN, LUN, 'Finished checking ' + DATASET + ' files at ' + SYSTIME()
    ENDIF ; IF CHECK_SST EQ 1 THEN BEGIN
    ; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    SKIP_DATASET:
    IF ANY(LUN) THEN BEGIN
      CLOSE, LUN
      FREE_LUN, LUN
    ENDIF
    NEW_FILES = [NEW_FILES, 'Finished downloading ' + DATASET + ' at ' + SYSTIME(), ' ']
    IF COUNT_DOWNLOAD_LOOP GT 900 THEN GOTO, END_DOWNLOADS  ; If the wget downloads were canceled, then jump out of the DATASET loop
  ENDFOR
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
