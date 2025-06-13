; $ID:	DWLD_OISST.PRO,	2023-10-12-14,	USER-KJWH	$
  PRO DWLD_OISST, YEARS, DATERANGE=DATERANGE, VERSION=VERSION

;+
; NAME:
;   DWLD_OISST
;
; PURPOSE:
;   Download the OISST data
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_OISST,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
;   This program was written on October 12, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 12, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_OISST'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  IF HAS(!S.COMPUTER,'NECLNAMAC') THEN WCMD = '/usr/local/bin/wget' ELSE WCMD = 'wget'

  CURRENT_VERSION = 'V2'
  IF ~N_ELEMENTS(VERSION) THEN VER = CURRENT_VERSION ELSE VER = VERSION
  CASE VER OF
    'V2': BEGIN
      HTTP = 'https://downloads.psl.noaa.gov/Datasets/noaa.oisst.v2.highres/' 
      SPAT = 'sst.day.mean.'
      APAT = 'sst.day.anom.'
      EPAT = 'sst.day.err.'
      LPAT = 'sst.day.mean.ltm'
      LTMS = ['.1971-2000','.1982-2010','.1991-2020','']
    END
  ENDCASE

  DP = DATE_PARSE(DATE_NOW())
  LOGFILE = !S.LOGS + 'IDL_DOWNLOADS' + SL + 'OISST' + SL + 'OISST_' + DATE_NOW(/DATE_ONLY) + '.log'
  DIR_TEST, !S.LOGS + 'IDL_DOWNLOADS' + SL + 'OISST' + SL

  PRODS = ['SST','SST_ANOM','SST_ERROR','SST_LTM']
  
  ; ===> Open dataset specific log file
  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180
  PLUN,LUN,'*****************************************************************************************************',3
  PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
  PLUN,LUN,'Downloading Super Collated OISST files... ', 0

  SENDATES = SENSOR_DATES('OISST')     ; Get the SENSOR daterange

  IF ~N_ELEMENTS(VERSION)   THEN VERSION = CURRENT_VERSION
  IF ~N_ELEMENTS(YEARS)       THEN YRS = YEAR_RANGE(DATE_2YEAR(SENDATES[0]),DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT)    THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF N_ELEMENTS(DATERANGE) EQ 0 THEN DTR = GET_DATERANGE(MIN(YRS),MAX(YRS)) ELSE DTRS = GET_DATERANGE(DATERANGE)

  DIR = !S.OISST + VER + SL + 'SOURCE' + SL
  DOWNLOAD_FILE = DIR + 'DOWNLOAD_LIST.txt
  
  IF DTR[0] LT SENDATES[0] THEN DTR[0] = SENDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
  IF DTR[1] GT SENDATES[1] THEN DTR[1] = SENDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
  DPS = DATE_PARSE(DTR[0]) & DPE = DATE_PARSE(DTR[1])                                 ; Parse start and end dates

  NEW_FILES = ['Downloading OISST files at ' + SYSTIME()]

  FOR N=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    APROD = PRODS[N]
    NCDIR = DIR + 'NC' + SL + APROD + SL & DIR_TEST, NCDIR
    
    YRS   = YEAR_RANGE(DPS.YEAR,DPE.YEAR,/STRING)                               ; Create list of YEARS within the daterange
    CASE APROD OF
      'SST': PAT = SPAT
      'SST_ANOM': PAT = APAT
      'SST_ERROR': PAT = EPAT
      'SST_LTM': BEGIN & PAT = LPAT & YRS = LTMS & END
    ENDCASE

  ; ===> Create a list of file names and urls based on the year and day of year
    FB = FILE_SEARCH(NCDIR + PAT + '*.nc',COUNT=CB)
    PLUN, LUN, 'Found ' + NUM2STR(CB) + ' LOCAL files for ' ,0
    SNAMES = PAT + YRS + '.nc'
   
    PLUN, LUN, 'Creating the download list:'
    FOR I=0, N_ELEMENTS(SNAMES)-1 DO PLUN, LUN, 'Downloading: ' + SNAMES[I], 0
    WRITE_TXT, DOWNLOAD_FILE, HTTP + SNAMES
    
    CMD = WCMD + ' -c -N --progress=bar:force --tries=3 --retry-connrefused -i ' + DOWNLOAD_FILE + ' -a ' + LOGFILE
    PLUN, LUN, CMD
    CD, NCDIR
    SPAWN, CMD, WGET_RESULT, WGET_ERROR                                                   ; Spawn command to download new files

    WGET_LOG = READ_TXT(LOGFILE)                                                          ; Check log file to see if the downloads were terminated
    IF STRPOS(WGET_LOG[-1], 'Downloaded:') EQ -1 THEN WGET_RESULT = 'TERMINATED'

    IF WGET_RESULT[0] NE '' THEN PLUN, LUN, WGET_RESULT
    IF WGET_ERROR[0]  NE '' THEN PLUN, LUN, WGET_ERROR

    ; ===> Check if WGET was ended early
    IF WGET_RESULT EQ 'TERMINATED' THEN PLUN, LUN, 'WGET terminated...'
    IF WHERE_STRING(WGET_LOG,'Ending wget at') NE [] THEN PLUN, LUN, 'WGET terminated by killwget.sh'   ; Check to see if WGET was terminated by the killwget script or other means
    IF WHERE_STRING(WGET_LOG,'Connection reset by peer') NE [] THEN PLUN, LUN, 'WGET terminated by peer'                          ; Check to see if WGET was terminated by the killwget script or other means
      
  ENDFOR  

  CD, !S.PROGRAMS
   
  PLUN, LUN, 'Finished downloading OISST files ' + SYSTIME()
  IF LUN NE [] THEN BEGIN & CLOSE, LUN & FREE_LUN, LUN & ENDIF


END ; ***************** End of DWLD_OISST *****************
