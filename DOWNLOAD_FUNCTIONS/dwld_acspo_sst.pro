; $ID:	DWLD_ACSPO_SST.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_ACSPO_SST, YEARS, DATERANGE=DATERANGE, VERSION=VERSION, DAYNIGHT=DAYNIGHT, DATASETS=DATASETS, NRT=NRT, $
    LOGLUN=LOGLUN, LIMIT=LIMIT, RECENT=RECENT, RYEARS=RYEARS


;+
; NAME:
;   DWLD_ACSPO_SST
;
; PURPOSE:
;   Download the near real-time and reanalysis SST from the ACSPO data source
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_ACSPO_SST,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 12, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 12, 2023 - KJWH: Initial code written
;   Oct 11, 2023 - KJWH: Changed the current version to V2.81
;                                      Updated the Checksum steps
;                                      Fixed a bug (and extra ".nc") in the search string pattern (PAT)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_ACSPO_SST'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF HAS(!S.COMPUTER,'NECLNAMAC') THEN WCMD = '/usr/local/bin/wget' ELSE WCMD = 'wget'
  
  CURRENT_VERSION = 'V2.81'
  IF ~N_ELEMENTS(VERSION) THEN VER = CURRENT_VERSION ELSE VER = VERSION
  CASE VER OF
    'V2.80': VERPAT = '-ACSPO_V2.80-v02.0-fv01.0.nc'
    'V2.81': VERPAT = '-ACSPO_V2.81-v02.0-fv01.0.nc'
  ENDCASE
  
  DP = DATE_PARSE(DATE_NOW())
  LOGFILE = !S.LOGS + 'IDL_DOWNLOADS' + SL + 'ACSPO' + SL + 'ACSPO_SST_' + DATE_NOW(/DATE_ONLY) + '.log'
  DIR_TEST, !S.LOGS + 'IDL_DOWNLOADS' + SL + 'ACSPO' + SL + VER + SL
  
  MAIN_HTTP = 'https://coastwatch.noaa.gov/pub/socd2/coastwatch/sst/'

  ; ===> Open dataset specific log file
  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180
  PLUN,LUN,'*****************************************************************************************************',3
  PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
  PLUN,LUN,'Downloading Super Collated ASPCO SST files... ', 0

  SENDATES = SENSOR_DATES('ACSPO')
  
  IF ~N_ELEMENTS(VERSION)   THEN VERSION = CURRENT_VERSION
  IF ~N_ELEMENTS(DAYNIGHT) THEN DAYNIGHT = 'DAILY' ELSE DAYNIGHT = STRLOWCASE(DAYNIGHT)
  IF ~N_ELEMENTS(YEARS)       THEN YRS = YEAR_RANGE(DATE_2YEAR(SENDATES[0]),DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT)    THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF KEYWORD_SET(LIMIT)        THEN LIMIT = '--limit-rate=500k' ELSE LIMIT = ' '
  IF N_ELEMENTS(DATERANGE) EQ 0 THEN DTRS = GET_DATERANGE(MIN(YRS),MAX(YRS)) ELSE DTRS = GET_DATERANGE(DATERANGE)
  NRTDATES = GET_DATERANGE(JD_2DATE(JD_ADD(DP.JD,-90,/DAY)),DP.DATE)

  IF ~N_ELEMENTS(DATASETS) THEN TYPES = ['RAN','NRT']  ELSE TYPES = STRUPCASE(DATASETS); 'Near Real Time, Reananlysis'
  IF KEYWORD_SET(NRT) THEN TYPES = 'NRT'
  
  FOR T=0, N_ELEMENTS(TYPES)-1 DO BEGIN
    TYP = TYPES[T]
    
    CASE TYP OF 
      'RAN': BEGIN & DDIR = !S.ACSPO_SOURCE & DTR = DTRS & IF DATE_2JD(DTR[0]) LT DATE_2JD(SENDATES[0]) THEN DTR[0] = SENDATES[0] & END
      'NRT': BEGIN & DDIR = !S.ACSPONRT_SOURCE  & IF ~N_ELEMENTS(DATERANGE) THEN DTR = NRTDATES ELSE DTR=DTRS & END
    ENDCASE  
    
    DIR = DDIR + VER + SL + 'SOURCE_DATA' + SL + 'MAPPED_2KM_DAILY' + SL
    CKDIR = DIR + 'CHECKSUMS' + SL
    
    FOR DT=0, N_ELEMENTS(DAYNIGHT)-1 DO BEGIN
      DN = DAYNIGHT[DT]
      ADIR = STRUPCASE(STRJOIN(['SST',TYP,DAYNIGHT],'_'))
      
      NO_CHECKSUMS=0
      PAT = '120000-STAR-L3S_GHRSST-SSTsubskin-' 
      CASE ADIR OF
        'SST_NRT_NIGHT': BEGIN & HTTP='nrt/l3s/leo/pm'    & PAT=PAT + 'LEO_PM_N' & END
        'SST_NRT_DAY':   BEGIN & HTTP='nrt/l3s/leo/am'    & PAT=PAT + 'LEO_AM_N' & END
        'SST_NRT_DAILY': BEGIN & HTTP='nrt/l3s/leo/daily' & PAT=PAT + 'LEO_Daily' & NO_CHECKSUMS=1 & ADIR = 'SST' & END
        'SST_RAN_NIGHT': BEGIN & HTTP='ran/l3s/leo/pm'    & PAT=PAT + 'LEO_PM_N' & END
        'SST_RAN_DAY':   BEGIN & HTTP='nrt/ran/leo/am'    & PAT=PAT + 'LEO_AM_N' & END
        'SST_RAN_DAILY': BEGIN & HTTP='ran/l3s/leo/daily' & PAT=PAT + 'LEO_Daily' & NO_CHECKSUMS=0 & ADIR = 'SST' & END
      ENDCASE                                       
      PAT = PAT + VERPAT
      HTTP = MAIN_HTTP + HTTP + SL
  
      NDIR = DIR + ADIR + SL
      CDIR = CKDIR + ADIR + SL
      DIR_TEST, NDIR
      IF ~KEYWORD_SET(NO_CHECKSUMS) THEN DIR_TEST, CDIR ELSE CDIR = []
      
      DOWNLOAD_FILE = DIR + 'DOWNLOAD_LIST.txt
      CHECKSUMS = DIR +'CHECKSUMS.txt'
      
      SDATES = SENSOR_DATES('ACSPO')                                                        ; Get the SENSOR daterange
      IF DTR[0] LT SDATES[0] THEN DTR[0] = SDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
      IF DTR[1] GT SDATES[1] THEN DTR[1] = SDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
      DPS = DATE_PARSE(DTR[0]) & DPE = DATE_PARSE(DTR[1])                                 ; Parse start and end dates

      DATES   = CREATE_DATE(DTR[0],DTR[1],/DOY,/CURRENT_DATE)                               ; Create list of DOY dates
      YRS     = STRMID(DATES,0,4) & UYEARS = YRS[UNIQ(YRS)]                                 ; Find unique years in the DATERANGE
      DOYLIST = STRMID(DATES,4,3) & DOYLIST = DOYLIST[SORT(DOYLIST)] & DOYLIST = DOYLIST[UNIQ(DOYLIST)]
      DOYHTTP = YRS + SL + STRMID(DATES,4,3) & DOYCKSUM = DOYHTTP
      NEW_FILES = ['Downloading SuperCollated SST files at ' + SYSTIME()]
      
      ; ===> Create a list of file names and urls based on the year and day of year
      YURLS = []
      YNAMES = []
      CKSUMS = []
      MISSING_CKFILE = []
      FOR Y=0, N_ELEMENTS(UYEARS)-1 DO BEGIN                                                                        ; Loop through years to get the directory and file names
        YR = UYEARS[Y]
        DATES   = DATE_PARSE(CREATE_DATE(YR+'0101',YR+'1231'))
        CD, DIR
        FB = FILE_SEARCH(NDIR +  YR + '*' + PAT,COUNT=CB)
        PLUN, LUN, 'Found ' + NUM2STR(CB) + ' LOCAL files for ' + YR,0
        IF DOYLIST[0] EQ '' THEN CONTINUE
        YNAMES = [YNAMES,  STRMID(DATES.DATE,0,8)]
        YURLS = [YURLS, REPLICATE(YR,N_ELEMENTS(DATES))]                                                                       ; Create a list of URLS
      ENDFOR
      YNAMES = DATE_SELECT(YNAMES,DTR,SUBS=YSUBS)
      SNAMES = YNAMES + PAT

      ; ===> Get the checksums for the files                                                                                         ; Create a list of file names
      IF ~KEYWORD_SET(NO_CHECKSUMS) THEN BEGIN
        PLUN, LUN, 'Getting list of CHECKSUMS ...'                                                                                    ; Susbset the URL names based on the DATERANGE
        WRITE_TXT, DIR + 'CHECKSUMS_TO_DOWNLOAD.txt', HTTP + DOYHTTP + SL + SNAMES + '.md5'                                         ; Create list of CHECKSUM files to download
        CMD = WCMD + ' --tries=3 --retry-connrefused -c -N'  + ' -i ' + DIR + 'CHECKSUMS_TO_DOWNLOAD.txt -a ' + LOGFILE        ; Checksum download command
        PLUN, LUN, CMD
        CD, CDIR
        SPAWN, CMD, LOG, ERR
        IF LOG[0] NE '' THEN PLUN, LUN, LOG
        IF ERR[0] NE '' THEN PLUN, LUN, ERR
        CD, DIR
      ENDIF  

      ; ===> Extract the checksum information
      IF ~KEYWORD_SET(NO_CHECKSUMS) THEN BEGIN
        FOR S=0, N_ELEMENTS(SNAMES)-1 DO BEGIN
          CFILE = CDIR + SNAMES[S] + '.md5'
          IF ~FILE_TEST(CFILE) THEN BEGIN
            PLUN, LUN, CFILE + ' does not exist.',0
            MISSING_CKFILE = [MISSING_CKFILE,CFILE]
            CONTINUE
          ENDIF
          CK = READ_DELIMITED(CFILE,DELIM='SPACE',/NOHEADING)
          IF CK EQ [] THEN BEGIN
            PLUN, LUN, 'Unable to read ' + SNAMES[S] + '.md5'
            PLUN, LUN, 'Deleting ' + SNAMES[S] + '.md5',0
            FILE_DELETE, CFILE
            CONTINUE
          ENDIF
          CK_TXT = CK.(1)+' '+CK.(0)                                                                                  ; Add missing checksums to the master file
          IF WHERE_STRING(CK_TXT,'{') NE [] THEN STOP
          CKSUMS = [CKSUMS,CK_TXT]
        ENDFOR
  
        WRITE_TXT, CHECKSUMS, CKSUMS                                                                             ; Write updated checksum file
        CLIST = READ_DELIMITED(CHECKSUMS, DELIM='SPACE',/NOHEADING)                                             ; Read as a structure to get the CHECKSUM values
        OK = WHERE_MATCH(CLIST.(0), YNAMES + PAT, COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT, VALID=VALID) ; Find CHECKSUMS for matching SNAMES
        CKSUMS = CLIST[OK].(1)
        SNAMES = CLIST[OK].(0)
        DOYCKSUM = DOYHTTP[VALID]
        DP = DATE_PARSE((PARSE_IT(SNAMES)).DATE_START)
  
        IF SNAMES NE [] THEN BEGIN & SRT = SORT(SNAMES) & SNAMES = SNAMES[SRT] & CKSUMS = CKSUMS[SRT] & ENDIF         ; Sort files
        PLUN, LUN, ROUNDS(N_ELEMENTS(SNAMES)) + ' files on remote server.'
  
        IF SNAMES EQ [] THEN BEGIN ; IF CLIST NE [] THEN BEGIN
          PLUN, LUN, 'ERROR: No CHECKSUMS were downloaded.'
          stop;CONTINUE
        ENDIF
      ENDIF ELSE CKSUMS = ''

      ; ===> Determine if additional files are requested based on the DATERANGE
      IF ANY(SNAMES) THEN BEGIN
        SFP = PARSE_IT(SNAMES)
        MINDATE = MIN(DATE_2JD(SFP.DATE_START))
      ENDIF ELSE  MINDATE = DATE_2JD(SDATES[1])
      IF DTR[0] NE SDATES[0] OR DATE_2JD(DTR[1]) LT MINDATE THEN INIT = 1

      ; ===> Create structure to compare the remote and local files
      STR = REPLICATE(CREATE_STRUCT('REMOTE_FILES','','REMOTE_CKSUM','','URL','','LOCAL_FILES','','LOCAL_CKSUM','','NEW_CKSUM','','NAMES',''), N_ELEMENTS(SNAMES))
      STR.REMOTE_FILES = SNAMES
      STR.REMOTE_CKSUM = CKSUMS
      STR.URL = HTTP + DOYCKSUM + SL
      STR.NAMES = STR.REMOTE_FILES

      ; ===> Get CHECKSUMS of the local files
      LOCAL_FILES = NDIR + SNAMES
      LOCAL_FILES = LOCAL_FILES[WHERE(FILE_TEST(LOCAL_FILES) EQ 1,COUNT,/NULL)]                                       ; Determine if local files exist
      PLUN, LUN, 'Looking for local matching local files...'

      IF COUNT GE 1 THEN BEGIN                                                                                        ; If local files exist, get the checksum
        PLUN, LUN, ROUNDS(N_ELEMENTS(LOCAL_FILES)) + ' matching files found on local server.',0
        FP = FILE_PARSE(LOCAL_FILES)
        OK_LOCAL = WHERE_MATCH(SNAMES,FP.NAME_EXT,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
        STR[OK_LOCAL].LOCAL_FILES = FP[VALID].NAME_EXT

        IF FILE_TEST(CHECKSUMS) EQ 1 AND NOT KEY(RECHECK_CKSUMS) THEN BEGIN                                       ; Use the MASTER checksum list
          PLUN, LUN, 'Reading: ' + CHECKSUMS, 0
          CKSUMS = READ_DELIMITED(CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
          IF CKSUMS EQ [] THEN BEGIN
            PLUN, LUN, CHECKSUMS + ' is blank.  Deleting...'
            FILE_DELETE, CHECKSUMS, /VERBOSE
            GOTO, SKIP_READ_CKSUMS
          ENDIF
          CKTXT  = READ_TXT(CHECKSUMS)
          OK_FILE = WHERE(FILE_TEST(NDIR + CKSUMS.(0)) EQ 0, COUNT_MISSING, COMPLEMENT=COMPLEMENT)                 ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
          IF COUNT_MISSING GE 1 THEN BEGIN
            CKTXT = CKTXT[COMPLEMENT]                                                                               ; Remove missing files from the MASTER CHECKSUMS list
            IF EXISTS(CHECKSUMS) THEN FILE_MOVE, CHECKSUMS, CDIR+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'                        ; Create a backup of the MASTER CKSUM list
            WRITE_TXT,CHECKSUMS, CKTXT                                                                         ; Rewrite MASTER CHECKSUMS list
            CKSUMS = READ_DELIMITED(CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
          ENDIF

          OK_MATCH = WHERE_MATCH(SNAMES,CKSUMS.(0),COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID)   ; Look for files that are already in the master checksum list
          IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_FILES = CKSUMS[VALID].(0)
          IF COUNT GE 1 THEN STR[OK_MATCH].LOCAL_CKSUM = CKSUMS[VALID].(1)

          IF NCOMPLEMENT GT 0 THEN SNAMES = SNAMES[COMPLEMENT] ELSE SNAMES = []                                       ; Identify missing names
          CKSUMS = READ_TXT(CHECKSUMS)                                                                          ; Read as a text array that can be appended with new checksum info
        ENDIF ELSE CKSUMS = []
        SKIP_READ_CKSUMS:

        OK_LOCAL = WHERE(STR.LOCAL_FILES NE '' AND STR.LOCAL_CKSUM EQ '', COUNT_LOCAL)                                ; Look for missing CHECKSUMS
        IF COUNT_LOCAL GE 1 THEN BEGIN
          STR[OK_LOCAL].LOCAL_CKSUM = GET_CHECKSUMS(NDIR + STR[OK_LOCAL].LOCAL_FILES,/MD5CKSUM,/VERBOSE)   ; Get CHECKSUMS that are missing in the structure and MASTER list
          CKSUMS = [CKSUMS,STR[OK_LOCAL].LOCAL_FILES+' '+STR[OK_LOCAL].LOCAL_CKSUM]          ; Create checksum string
          IF HAS(CKSUMS,'{') EQ 1 OR HAS(CKSUMS,'}') EQ 1 THEN CKSUMS = REPLACE(CKSUMS,['{ ','}'],['',''])            ; Remove any { or } from the CKSUM strings
          CKSUMS = CKSUMS[SORT(CKSUMS)]                                                                               ; Sort by file name
          CKSUMS = CKSUMS[UNIQ(CKSUMS)]
          WRITE_TXT, CHECKSUMS, CKSUMS                                                                            ; Write new MASTER CHECKSUMS list
        ENDIF

      ENDIF ELSE PLUN, LUN, 'No matching files found on the local server.'

      ; ===> Compare the checksums of the remote and local files and download files if checksums do not match
      PLUN, LUN, 'Comparing checksums of remote and local files...'
      OK = WHERE((STR.REMOTE_CKSUM NE '' AND STR.REMOTE_CKSUM NE STR.LOCAL_CKSUM) OR STR.LOCAL_FILES EQ '',COUNT)                               ; Find non-matching checksums
      COUNT_DOWNLOAD_LOOP = 0
      IF COUNT GE 1 THEN BEGIN
        D = STR[OK]                                                                                                  ; Subset structure to be just those with unmatching checksums
        REPEAT_DOWNLOAD:
        PLUN, LUN, 'Creating the download list:'
        FOR I=0, COUNT-1 DO PLUN, LUN, D[I].REMOTE_FILES, 0
        WRITE_TXT, DOWNLOAD_FILE, D.URL + D.REMOTE_FILES                                                 ; Create a list of remote files to download

        OK = WHERE(D.LOCAL_FILES NE '' AND D.REMOTE_CKSUM NE '',COUNT)                                               ; Find "bad" local files
        IF COUNT GE 1 THEN BEGIN
          PLUN, LUN, 'Removing local files with unmatching checksum...'
          FOR I=0, COUNT-1 DO PLUN, LUN, 'Removing ' + D[OK[I]].LOCAL_FILES, 0

          PLUN, LUN, 'READING: ' + CHECKSUMS
          CKSUMS = READ_DELIMITED(CHECKSUMS, DELIM='SPACE',/NOHEADING)                                          ; Read as a structure to compare the file names
          OK_FILE = WHERE_MATCH(CKSUMS.(0), D[OK].LOCAL_FILES, COUNTR, COMPLEMENT=COMPLEMENT)                         ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
          IF N_ELEMENTS(COMPLEMENT) GE 1 THEN WRITE_TXT, CHECKSUMS, CKSUMS[COMPLEMENT]                          ; Rewrite the MASTER CKSUM file, removing the CKSUMS of files that will be deleted
          REMOVE_FILES = NDIR + D[OK].LOCAL_FILES                                                                     ; Files to be removed because they do not have matching CKSUMS
          OK = WHERE(FILE_TEST(REMOVE_FILES) EQ 1,COUNTR)                                                             ; Make sure the file exists
          IF COUNTR GE 1 THEN FILE_DELETE, REMOVE_FILES[OK], /VERBOSE                                                 ; Remove "bad" local files
        ENDIF

        PLUN, LUN, 'Downloading files...'
        FOR I=0, N_ELEMENTS(D)-1 DO PLUN, LUN, 'Downloading: ' + D[I].REMOTE_FILES, 0
        IF NONE(USER) THEN USER = ''
        CMD = WCMD + ' -c -N --progress=bar:force --tries=3 --retry-connrefused ' + USER + ' -i ' + DOWNLOAD_FILE + ' -a ' + LOGFILE
        PLUN, LUN, CMD
        CD, NDIR
        SPAWN, CMD, WGET_RESULT, WGET_ERROR                                                   ; Spawn command to download new files

        WGET_LOG = READ_TXT(LOGFILE)                                                          ; Check log file to see if the downloads were terminated
        IF STRPOS(WGET_LOG[-1], 'Downloaded:') EQ -1 THEN WGET_RESULT = 'TERMINATED'

        IF WGET_RESULT[0] NE '' THEN PLUN, LUN, WGET_RESULT
        IF WGET_ERROR[0]  NE '' THEN PLUN, LUN, WGET_ERROR

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
        IF ~KEYWORD_SET(NO_CHECKSUMS) THEN BEGIN
          D.NEW_CKSUM = GET_CHECKSUMS(NDIR + D.REMOTE_FILES, /MD5CKSUM,/VERBOSE)
          OK = WHERE(D.REMOTE_CKSUM NE D.NEW_CKSUM AND D.REMOTE_CKSUM NE '',COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
          IF NCOMPLEMENT GT 0 THEN BEGIN
            NEW_FILES = [NEW_FILES,D[COMPLEMENT].REMOTE_FILES]
  
            ; ===> Add the new CHKSUMS to the MASTER list
            CKSUMS = READ_TXT(CHECKSUMS)                                                                         ; Read as a text array that can be appended with new checksum info
            CKSUMS = [CKSUMS,D[COMPLEMENT].NAMES + ' ' + D[COMPLEMENT].NEW_CKSUM]                                      ; Create checksum string
            CKSUMS = CKSUMS[SORT(CKSUMS)]                                                                              ; Sort by file name
            CKSUMS = CKSUMS[UNIQ(CKSUMS)]                                                                              ; Remove any duplicates
            IF HAS(CKSUMS,'{') EQ 1 OR HAS(CKSUMS,'}') EQ 1 THEN CKSUMS = REPLACE(CKSUMS,['{ ','}'],['',''])           ; Remove any { or } from the CKSUM strings
            IF EXISTS(CHECKSUMS) EQ 1 THEN FILE_MOVE, CHECKSUMS, CDIR+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.txt'
            WRITE_TXT,CHECKSUMS, CKSUMS                                                                           ; Save the file
  
            FP = PARSE_IT(D[COMPLEMENT].REMOTE_FILES)
            BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))
            YDOY = YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3))
          ENDIF ELSE NEW_FILES = [NEW_FILES,'*** No new files']
  
          IF COUNT GE 1 THEN BEGIN
            PLUN, LUN, NUM2STR(COUNT) + ' Files FAILED to download completely'
            FOR I=0, COUNT-1 DO PLUN, LUN, 'Download of ' + D[I].REMOTE_FILES + ': FAILED', 0
            D = D[OK]
            COUNT_DOWNLOAD_LOOP = COUNT_DOWNLOAD_LOOP + 1
            IF COUNT_DOWNLOAD_LOOP LE 5 THEN GOTO, REPEAT_DOWNLOAD
            FP = PARSE_IT(D.REMOTE_FILES)
            BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))
            YDOY = YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3))
            F = WHERE(FILE_TEST(D.REMOTE_FILES) EQ 1,COUNTF)
            IF COUNTF GE 1 THEN FILE_DELETE, D[F].REMOTE_FILES, /VERBOSE    ; Remove files that were partially downloaded so that they do not crash subsequent processing
          ENDIF
        ENDIF ; ~NO_CHECKSUMS  

        CD, !S.FUNCTIONS
      ENDIF ELSE PLUN, LUN, 'No new files to download.'
      
      ENDFOR
      ENDFOR
      
      PLUN, LUN, 'Finished downloading ACSPO SST files ' + SYSTIME()

      IF LUN NE [] THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF


  


END ; ***************** End of DWLD_ACSPO_SST *****************
