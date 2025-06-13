; $ID:	DWLD_NASA_GET_DOWNLOAD_LIST.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DWLD_NASA_GET_DOWNLOAD_LIST, DATASETS, DATERANGE=DATERANGE, FULL_SEARCH=FULL_SEARCH, $
    CKSUMFILE=CKSUMFILE,DWLD_LIST=DWLD_LIST,LOG_DIR=LOG_DIR, LOGLUN=LOGLUN, LOGFILE=LOGFILE

;+
; NAME:
;   DWLD_NASA_GET_DOWNLOAD_LIST
;
; PURPOSE:
;   This function will create a list of L1A files to download from the NASA OBPG website
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_NASA_GET_DOWNLOAD_LIST
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   DATASETS......... The L1A ocean color dataset(s) (default = [SEAWIFS, MODISA, VIIRS, JPSS1])
;   DATERANGE........ A specified daterange (default = SENSOR_DATES(DATASET)
;   CKSUMFILE........ The file containing the master list of checksums
;   DWLD_LIST........ The file containing the list of files to download
;   DIR_LOG.......... The output directory for the log files
;   LOGLUN........... The LUN for the log file
;   LOGFILE.......... The name of the log file
;
; KEYWORD PARAMETERS:
;   FULL_SEARCH...... Search for files within the entire time series (i.e. SENSOR_DATES)
;
; OUTPUTS:
;   CHECKSUM_MASTER.. Creates a .SAV structure with the checksums of the local files (to avoid  text file with the list of files to download and returns the name
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
;   https://oceancolor.gsfc.nasa.gov/data/download_methods/
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 10, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 10, 2020 - KJWH: Initial code written
;   Dec 14, 2020 - KJWH: Added CKSUMFILE,DWND_LIST, and LOG_DIR inputs to indicate the checksum file, download list and log directory respectively
;   Apr 08, 2021 - KJWH: Updated to add the MODIS SST 11UM "dataset"
;   Dec 15, 2022 - KJWH: Changed name from DWLD_NASA_GET_L1A_LIST to DWLD_NASA_GET_DOWNLOAD_LIST
;                                       Now about to download L3B prod specific products
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NASA_GET_DOWNLOAD_LIST'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DATASETS) EQ 0 THEN DATASETS = ['MODISA','SMODISA','SMODIST','SMODISA_NRT','SMODIST_NRT','VIIRS','JPSS1','SEAWIFS']
  
; ===> DATES & EMAIL
  MAILTO = 'kimberly.hyde@noaa.gov'
  DP = DATE_PARSE(DATE_NOW())              ; Parse today's date
  DAY90 = STRMID(JD_2DATE(JD_ADD(DP.JD,-90,/DAY)),0,8) ; Get the date 90 days prior to the current date
  DAY180 = JD_2DATE(JD_ADD(DP.JD,-180,/DAY)) ; Get the date 180 (6 months) prior to the current date
  DAY365 = JD_2DATE(JD_ADD(DP.JD,-365,/DAY)) ; Get the date 365 (1 year) prior to the current date
  
; ===> REMOTE FTP LOCATIONS
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/'
  OC_SEARCH = 'https://oceandata.sci.gsfc.nasa.gov/api/file_search.cgi'

    
; ===> LOOP THROUGH DATASETS
  FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    COUNT_DOWNLOAD_LOOP = 0
    DATASET = STRUPCASE(DATASETS[N])
    SENSOR = DATASET
    TYPE = 'L1A'
    OLIST = DATASET
    PAT = ''
    PROD = ''
    CASE DATASET OF
      'SEAWIFS':    DATDIR=!S.SEAWIFS 
      'MODISA':     DATDIR=!S.MODISA
      'MODISA_CHL': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='CHL' & PAT='L3b.DAY.'+PROD+'*' & END
      'MODISA_PAR': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
      'MODISA_RRS': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
      'SEAWIFS_CHL': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='CHL' & PAT='L3b.DAY.'+PROD+'*' & END
      'SEAWIFS_PAR': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
      'SEAWIFS_RRS': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='RRS' & PAT='L3b.DAY.'+PROD+'*' & END
      'MODIST':      BEGIN & DATDIR=!S.MODIST                     & TYPE='L2' & END
      'SMODISA':     BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & OLIST = 'SMODISA'     & PAT='L2.SST.nc' & END
      'SMODISA_NRT': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & OLIST = 'SMODISA_NRT' & PAT='L2.SST.NRT.nc' & END
      'SMODIST':     BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & OLIST = 'SMODIST'     & PAT='L2.SST.nc' & END
      'SMODIST_NRT': BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & OLIST = 'SMODIST_NRT' & PAT='L2.SST.NRT.nc' & END
      'VIIRS':      DATDIR=!S.VIIRS
      'JPSS1':      DATDIR=!S.JPSS1
      ELSE: MESSAGE, 'ERROR: ' + DATASET + 'is not a recognized DATASET.'
    ENDCASE
    DATASET_DATES = SENSOR_DATES(SENSOR) ; Get the sensor specific daterange
    CASE SENSOR OF
      'MODISA': NSENSOR='aqua'
      'MODIST': NSENSOR='terra'
      'JPSS1':  NSENSOR='viirsj1'
      ELSE: NSENSOR=STRLOWCASE(SENSOR)
    ENDCASE
    
    IF TYPE EQ 'L3B4' OR TYPE EQ 'L3B9' THEN SEARCH_TYPE = 'L3B' ELSE SEARCH_TYPE = TYPE
    
    ; ===> Determine dataset specific files and directories
    IF N_ELEMENTS(LOG_DIR) EQ 1 THEN BATCH_LOG_DIR = LOG_DIR ELSE BATCH_LOG_DIR = !S.LOGS + 'IDL_DOWNLOADS' + SL + DATASET + SL 
    L1ADIR = DATDIR +  TYPE + SL
    SDIR   = L1ADIR + 'NC' + SL + PROD + SL & SDIR = REPLACE(SDIR,SL+SL,SL)
    CDIR   = L1ADIR + 'CHECKSUMS' + SL + PROD + SL & CDIR = REPLACE(SDIR,SL+SL,SL)  
    DIR_TEST, [BATCH_LOG_DIR,CDIR,SDIR]
    
    IF N_ELEMENTS(CKSUMFILE) EQ 1 THEN CHECKSUM_MASTER=CKSUMFILE ELSE CHECKSUM_MASTER=L1ADIR+'CHECKSUMS.sav'   ; The file containing checksums of the existing local files
    IF N_ELEMENTS(DWLD_LIST) EQ 1 THEN DOWNLOAD_LIST=DWLD_LIST   ELSE DOWNLOAD_LIST=L1ADIR+'DOWNLOAD_LIST.txt' ; The file containing the list of files to download
    IF FILE_TEST(DOWNLOAD_LIST) THEN FILE_DELETE, DOWNLOAD_LIST                                                ; Delete the download list if it exists
    
    FILELIST_CHECKSUMS = BATCH_LOG_DIR + 'FILELIST_CHECKSUMS.txt'                                              ; Temporary file written during the wget file search
    IF TYPE NE 'L3B4' AND TYPE NE 'L3B9' THEN BEGIN
      L1_ORDER_LIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + OLIST + '.txt'                     ; The master file with the 1km list of files to download
      IF ~FILE_TEST(L1_ORDER_LIST) THEN MESSAGE, 'ERROR: ' + L1_ORDER_LIST + ' does not exist.'                  ; Check that the master file exists
      DLIST = READ_TXT(L1_ORDER_LIST) & NLIST = N_ELEMENTS(DLIST)                                                ; Read the master list
      FP_DLIST = PARSE_IT(DLIST)                                                                                 ; Parse the download list files
    ENDIF ELSE FP_DLIST = []
    
    IF NONE(DATERANGE) THEN DTR = [DAY365,STRMID(DATE_NOW(),0,8)] ELSE DTR = GET_DATERANGE(DATERANGE)          ; If a daterange is not provided, only look for files within the past 365 days
    IF DTR[0] LT DATASET_DATES[0] THEN DTR[0] = DATASET_DATES[0]                                               ; Make sure the daterange is within the sensor dates
    IF DTR[1] GT DATASET_DATES[1] THEN DTR[1] = DATASET_DATES[1]
    IF DTR[0] GT DTR[1] THEN DTR[0] = DATASET_DATES[0]
    IF KEYWORD_SET(FULL_SEARCH) THEN DTR = DATASET_DATES                                                       ; If searching for the entire time series, use the sensor dates for the daterange
    DPS = DATE_PARSE(DTR[0]) & DPE = DATE_PARSE(DTR[1])                                                        ; Parse the start and end dates

; ===> Get the list of subscription files    
    IF TYPE NE 'L3B4' AND TYPE NE 'L3B9' THEN SUBFILES = DWLD_NASA_GET_SUBSCRIPTION_FILES(DATASET, LOGLUN=LUN, LOGFILE=LOGFILE, ORDER_LIST=L1_ORDER_LIST) ELSE SUBFILES = []
    IF SUBFILES NE [] THEN FNAMES = SUBFILES.SUBSCRIPTION_NAMES ELSE FNAMES = []                           
    IF SUBFILES NE [] THEN CKSUMS = SUBFILES.CHECKSUMS                  ELSE CKSUMS = []
    
    PLUN, LUN, 'Searching the NASA server for files that match the complete (or partial based on date range) list of files in the MASTER download list'
      
    DATES = CREATE_DATE(DPS.DATE, DPE.DATE)                                                                  ; Create a complete list of dates based on the date range
    LOOPS = ROUND(N_ELEMENTS(DATES)/60)+1                                                                    ; Divide the dates into groups of 60 (due to limitations from the NASA server)
    IF N_ELEMENTS(DATES) MOD 60 EQ 0 THEN LOOPS = LOOPS-1                                                    ; Determine the number of date groups

    SDATES = []                                                                                              ; Null start date variable
    EDATES = []                                                                                              ; Null end date variable
    FOR Y=0, LOOPS-2 DO BEGIN
      SDATES = [SDATES,DATES[Y*60]]                                                                          ; Create a list of start dates
      EDATES = [EDATES,DATES[Y*60+59]]                                                                       ; Create a list of end dates
    ENDFOR
    SDATES = [SDATES,DATES[Y*60]]
    EDATES = [EDATES,DATES[-1]]
    SD = DATE_PARSE(SDATES)                                                                                  ; Parse the start dates
    ED = DATE_PARSE(EDATES)                                                                                  ; Parse the end dates

    FOR Y=0, N_ELEMENTS(SDATES)-1 DO BEGIN                                                                   ; Loop on the number of start dates
      CD, BATCH_LOG_DIR                                                                                      ; Change directories to the LOG diriectory
      IF FILE_TEST(FILELIST_CHECKSUMS) THEN FILE_DELETE, FILELIST_CHECKSUMS, /VERBOSE                        ; Delete the FILELIST_CHECKSUMS if it exists
      PATTERN = '&sensor='+NSENSOR+'&sdate='+SD[Y].DASH_DATE+'&edate='+ED[Y].DASH_DATE+'&dtype='+SEARCH_TYPE        ; Create the wget search pattern 
      IF PAT NE '' THEN PATTERN = 'search=*'+PAT+PATTERN                                                     ; Add the dataset specific search pattern if provided
      CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -q -O - '+OC_SEARCH+' > ' + FILELIST_CHECKSUMS
      PLUN, LUN, CMD
      SPAWN, CMD, RES, ERR                                                                                             ; SPAWN the wget command

      FI = FILE_INFO(FILELIST_CHECKSUMS)                                                                     ; Check the file size of the filelist_checksums file
      IF FI.SIZE EQ 0 THEN BEGIN                                                                             ; If the file size is 0
        PLUN, LUN, 'No checksum file found, retrying...'
        SPAWN, CMD                                                                                           ; Try the wget command again
        FI = FILE_INFO(FILELIST_CHECKSUMS)                                                                   ; Check the file size again
        IF FI.SIZE EQ 0 THEN CONTINUE                                                                        ; If the file size is still 0 go to the next set of dates
      ENDIF

      FLIST = READ_TXT(FILELIST_CHECKSUMS)                                                                   ; Read the output CHECKSUMS file  
      IF STRMID(FLIST[0],0,2) EQ '<!' OR FLIST EQ [] THEN BEGIN                                              ; If no remote server files are found, the file will start with <!
        PLUN, LUN, 'ERROR: No valid files found on remote server from ' + SD[Y].DASH_DATE + ' to ' + ED[Y].DASH_DATE
        PLUN, LUN, FLIST, 0
        CONTINUE                                                                                             ; Continue to the next set of dates
      ENDIF
      
      IF STRMID(FLIST[0],0,10) EQ 'Your query' THEN BEGIN                                                    ; Some searches return a text string as the first line that must be removed
        FLIST = FLIST[1:*]
        FLIST = FLIST[WHERE(FLIST NE '',/NULL)]                                                              ; Remove any blank lines
        IF FLIST NE [] THEN WRITE_TXT, FILELIST_CHECKSUMS, FLIST                                             ; Resave list
      ENDIF

      FLIST = READ_DELIMITED(FILELIST_CHECKSUMS,DELIM='SPACE',/NOHEADING)                                    ; Read the CHECKSUM as a delimited file
      IF N_TAGS(FLIST) EQ 1 THEN BEGIN                                                                       ; Look for empty files
        PLUN, LUN, 'ERROR: No valid files found on remote server from ' + SD[Y].DASH_DATE + ' to ' + ED[Y].DASH_DATE
        PLUN, LUN, FLIST, 0
        CONTINUE                                                                                             ; Continue to the next set of dates
      ENDIF
      CKSUMS = [CKSUMS,FLIST.(0)]                                                                            ; Get the list of checksums
      FNAMES = [FNAMES,FLIST.(1)]                                                                            ; Get the list of matching file names
      PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(FLIST)) + ' files on the remote server for daterange: ' + SD[Y].DASH_DATE + ' to ' + ED[Y].DASH_DATE
    ENDFOR ; SDATES
    FILE_DELETE, FILELIST_CHECKSUMS                                                                          ; Remove the temporary FILELIST_CHECKSUM file to avoid accidently reading the file in the future
    CD, !S.IDL
    
    ; ===> Find files that match the master download list
    OK = WHERE(FNAMES NE '' AND CKSUMS NE '',/NULL,COUNT)
    IF COUNT GT 0 AND FNAMES NE [] THEN BEGIN    
      FNAMES = FNAMES[OK] & CKSUMS = CKSUMS[OK]
      SRT = SORT(FNAMES) & FNAMES = FNAMES[SRT] & CKSUMS = CKSUMS[SRT]                                       ; Sort files
      UNQ = UNIQ(FNAMES) & FNAMES = FNAMES[UNQ] & CKSUMS = CKSUMS[UNQ]                                       ; Remove any duplicates
      IF FP_DLIST NE [] THEN BEGIN
        OK = WHERE_MATCH(FP_DLIST.NAME_EXT, FNAMES, COUNT, VALID=VALID)                                        ; Find files that match those in the download list
        IF COUNT GE 1 THEN BEGIN
          FNAMES = FNAMES[VALID]                                                                               ; Reduce the FNAMES to be just those that match the download list
          CKSUMS = CKSUMS[VALID]                                                                               ; Reduce the checksums to just those that match the download list
          PLUN, LUN, 'Found ' + ROUNDS(COUNT) + ' files on the remote server that match the MASTER download list'
        ENDIF ELSE GOTO, REPLACE_LIST
      ENDIF  
    ENDIF ELSE BEGIN  
      REPLACE_LIST:
      IF ANY(DLIST) THEN BEGIN                                                                               ; If no files were found, then use the master download list
        FNAMES = REPLACE(DLIST,OC_GET,'')                                                                    ; Remove the OC_GET url from the file name
        CKSUMS = REPLICATE('',N_ELEMENTS(DLIST))                                                             ; Make a blank array of checksums
      ENDIF
    ENDELSE    

; ===> Create structure to compare the remote and local files
    STR = CREATE_STRUCT('SERVER_FILES','','SERVER_CKSUM','','URL','','LOCAL_FILES','','LOCAL_CKSUM','','LOCAL_MTIME',0LL,'NEW_FILES','','NEW_CKSUM','','NAMES','')
    STR = REPLICATE(STR, N_ELEMENTS(FNAMES))
    STR.SERVER_FILES = FNAMES
    STR.SERVER_CKSUM = CKSUMS
    STR.URL = REPLICATE(OC_GET, N_ELEMENTS(STR))          
    STR.NAMES = STR.SERVER_FILES
    
; ===> Read the master checksum list or create it if it doesn't exist
    CKSUM_MASTER = DWLD_NASA_READ_CKSUM(DATASET)
    
; ===> Get CHECKSUMS of the local files
    PLUN, LUN, 'Looking for local files that match the files found on the NASA server...'
    LOCAL_FILES = SDIR[0] + FNAMES                                                                            ; Create a list of files using the names found on the server
    LOCAL_FILES = LOCAL_FILES[WHERE(FILE_TEST(LOCAL_FILES) EQ 1,COUNT,/NULL)]                                 ; Determine if local files exist

    IF COUNT GE 1 THEN BEGIN                                                                                  ; If local files exist, get the checksum
      PLUN, LUN, ROUNDS(N_ELEMENTS(LOCAL_FILES)) + ' matching files found on local server.',0
      FP = FILE_PARSE(LOCAL_FILES)                                                                            ; Parse the local files
      OK_LOCAL = WHERE_MATCH(FNAMES,FP.NAME_EXT,COUNT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)         ; Look for matching file names
      STR[OK_LOCAL].LOCAL_FILES = FP[VALID].NAME_EXT                                                          ; Fill in the structure with the local file names
      STR[OK_LOCAL].LOCAL_MTIME = GET_MTIME(STR[OK_LOCAL].LOCAL_FILES)                                        ; Get the MTIME of the local files
      
    ;  IF CKSUM_MASTER EQ [] THEN GOTO, SKIP_READ_CKSUMS                                                      ; Use the MASTER checksum list if it exists
      OK_MATCH = WHERE_MATCH(STR.SERVER_FILES,CKSUM_MASTER.LOCAL_FILES,COUNT,VALID=VALID)                     ; Look for files that are already in the master checksum list
      IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_CKSUM = CKSUM_MASTER[VALID].LOCAL_CKSUM                          ; Add the LOCAL_CKSUMS from the master list to the structure
      IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_MTIME = CKSUM_MASTER[VALID].LOCAL_MTIME                          ; Add the LOCAL_MTIME from the master list to the structure
    ENDIF
       
    ; ===> Compare the checksums of the remote and local files and download files if checksums do not match
    PLUN, LUN, 'Comparing checksums of remote and local files...'
    OK = WHERE((STR.SERVER_CKSUM NE '' AND STR.SERVER_CKSUM NE STR.LOCAL_CKSUM) OR STR.LOCAL_FILES EQ '',COUNT); Find files to download based on non-matching checksums or missing local files
    IF COUNT GE 1 THEN BEGIN
      D = STR[OK]                                                                                             ; Subset structure to be just those with unmatching checksums
      PLUN, LUN, 'Creating the download list:'
      FOR I=0, COUNT-1 DO PLUN, LUN, 'Adding ' + D[I].SERVER_FILES + ' to the download list', 0
      PLUN, LUN, ROUNDS(COUNT) + ' files to be downloaded...'
      WRITE_TXT, DOWNLOAD_LIST, D.URL + D.SERVER_FILES                                                        ; Create a list of remote files to download

      OK = WHERE(D.LOCAL_FILES NE '' AND D.SERVER_CKSUM NE '',COUNT)                                          ; Look for "bad" local files (i.e. the checksums do not match what is on the NASA server)
      IF COUNT GE 1 THEN BEGIN
        PLUN, LUN, 'Removing local files with unmatching checksum...'
        FOR I=0, COUNT-1 DO PLUN, LUN, 'Removing ' + D[OK[I]].LOCAL_FILES, 0
        CKSUMS = IDL_RESTORE(CHECKSUM_MASTER)                                                                 ; Read the MASTER CHECKSUM file to compare the file names
        OK_FILE = WHERE_MATCH(CKSUMS.LOCAL_FILES, D[OK].LOCAL_FILES, COUNTR, COMPLEMENT=COMPLEMENT)           ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
        IF N_ELEMENTS(COMPLEMENT) GE 1 THEN BEGIN
          CKSUMS = CKSUMS[COMPLEMENT]
          SAVE, CKSUMS, FILENAME=CHECKSUM_MASTER                                                              ; Rewrite the MASTER CKSUM file, removing the CKSUMS of files that will be deleted
        ENDIF ELSE MESSAGE, 'ERROR: Check CHECKSUM Master file.
        REMOVE_FILES = SDIR + D[OK].LOCAL_FILES                                                               ; Files to be removed because they do not have matching CKSUMS
        OK = WHERE(FILE_TEST(REMOVE_FILES) EQ 1,COUNTR)                                                       ; Make sure the file exists
        IF COUNTR GE 1 THEN FILE_DELETE, REMOVE_FILES[OK], /VERBOSE                                           ; Remove "bad" local files
      ENDIF
      RETURN, D
    ENDIF   
    RETURN, []                                                                                                  ; If a download list was not created then return a null value
  ENDFOR ; DATASETS


END ; ***************** End of DWLD_NASA_GET_DOWNLOAD_LIST *****************
