; $ID:	DWLD_GLOBCOLOUR.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_GLOBCOLOUR, YEARS=YEARS, DATERANGE=DATERANGE, PRODS=PRODS, METHODS=METHODS, VERSION=VERSION, LOGLUN=LOGLUN, LIMIT=LIMIT, RECENT=RECENT, RYEARS=RYEARS, CHECK_FILES=CHECK_FILES

;+
; NAME:
;   DWLD_GLOBCOLOUR
;
; PURPOSE:
;   Download files from the GlobColour ftp server
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_GLOBCOLOUR
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   YEARS.......... The Year(s) of files to download
;   DATERANGE...... Range of dates to download
;   PRODS.......... The name of the products to download
;   METHODS........ The name of the method to create the product (e.g. GSM)
;   VERSION........ Version of the files to download
;   LOGLUN......... The LUN for the logfile
;   
; KEYWORD PARAMETERS:
;   RECENT........ Get files from the current year and the previous year
;   RYEARS........ Reverse the order of years
;   CHECK_FILES... Rerun without the wget command to check the local files
;   LIMIT......... Limit the download rate of the files
;
; OUTPUTS:
;   New files downloaded into !S.OC/GLOBCOLOUR/L3/NC
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
;   Will need to be updated as new versions of the OCCCI data are released
;
; EXAMPLE:
;   DWLD_GLOBCOLOUR_CHL, YEARS='2020', PRODS='CHL1', METHODS='GSM' 
;
; NOTES:
;   User Guide - https://www.globcolour.info/CDR_Docs/GlobCOLOUR_PUG.pdf
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 11, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 11, 2021 - KJWH: Initial code written
;   Jan 10, 2022 - KJWH: Changed name from DWLD_HERMES_CHL to DWLD_GLOBCOLOUR_CHL
;   Jan 12, 2022 - KJWH: Added PAR as a default download product
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_GLOBCOLOUR'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  CURRENT_VERSION = 'VERSION_4.2.1'
  DP = DATE_PARSE(DATE_NOW())
  LOGDIR =  !S.LOGS + 'IDL_DOWNLOADS' + SL + 'GLOBCOLOUR' + SL & DIR_TEST, LOGDIR
  LOGFILE = LOGDIR + 'GLOBCOLOUR' + '_' + DATE_NOW(/DATE_ONLY) + '.log'
  
  SPAWN, 'echo $0', SHELL, ERR
  IF SHELL EQ 'zsh' THEN SPAWN, 'chsh -s $(which bash)'


  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  IF N_ELEMENTS(VERSION) EQ 0 THEN VERSION = '4.2.1'
  IF N_ELEMENTS(PRODS)   EQ 0 THEN PRODS = ['CHL1','PAR','POC','PIC'] 
  
  IF N_ELEMENTS(YEARS)   EQ 0 THEN YRS = YEAR_RANGE('1997',DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT) THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF KEYWORD_SET(LIMIT)  THEN LIMIT = '--limit-rate=500k' ELSE LIMIT = ' '
  IF N_ELEMENTS(DATERANGE) EQ 0 THEN DTR = GET_DATERANGE(MIN(YRS),MAX(YRS)) ELSE DTR = GET_DATERANGE(DATERANGE)

  
  IF IDLTYPE(VERSION) NE 'STRING' THEN MESSAGE, 'ERROR: Version input must be a string'
  IF HAS(VERSION,'VERSION_')      THEN VERSION = REPLACE(VERSION,'VERSION_','')
  DIRVER = 'VERSION_'+VERSION

  CASE VERSION OF
    '4.2.1': SFTP = 'ftp://ftp_gc_KHyde:KHyde_3859@ftp.hermes.acri.fr/GLOB/merged/day/'    
  ENDCASE

  SDATES = SENSOR_DATES('GLOBCOLOUR')                                                 ; Get the SENSOR daterange
  IF DTR[0] LT SDATES[0] THEN DTR[0] = SDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
  IF DTR[1] GT SDATES[1] THEN DTR[1] = SDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
  
  DATES   = CREATE_DATE(DTR[0],DTR[1])                                                ; Create list of dates
  DTPS    = DATE_PARSE(DATES)
  YRS     = STRMID(DATES,0,4) & UYEARS = YRS[UNIQ(YRS)]                               ; Find unique years in the DATERANGE

  
  FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    APROD = PRODS[R]
    IF N_ELEMENTS(METHODS) EQ 0 THEN BEGIN
      CASE APROD OF
        'CHL1': AMETHOD = ['GSM']
        'PAR': AMETHOD = 'AV'
        'PIC': AMETHOD = 'AV'
        'POC': AMETHOD = 'AV'
         ELSE: MESSAGE, 'ERROR: "Method" for ' + APROD + ' not found'
       ENDCASE   
     ENDIF ELSE AMETHOD = METHODS[R]
    FOR M=0, N_ELEMENTS(AMETHOD)-1 DO BEGIN
      METH = AMETHOD[M]
      IF N_ELEMENTS(AMETHOD) GT 1 THEN PLABEL = APROD + '_' + METH ELSE PLABEL = APROD
      IF KEYWORD_SET(RYEARS) THEN UYEARS = REVERSE(UYEARS)
      FOR Y=0, N_ELEMENTS(UYEARS)-1 DO BEGIN
        YR = UYEARS[Y]
        DPS = DTPS[WHERE(DTPS.YEAR EQ YR)]
        
        DIR = !S.GLOBCOLOUR_SOURCE + 'V0' + SL + 'SOURCE' + SL + PLABEL +SL & DIR_TEST, DIR
        CD, DIR
        FB = FILE_SEARCH(DIR + SL + 'L3b*' + YR + '*' + METH + '*' + APROD + '*_DAY_00.nc',COUNT=CB) 
        PLUN, LUN, 'Found ' + NUM2STR(CB) + ' LOCAL files for ' + YR
  
;        IF YR EQ '1997' THEN DS = '0904' ELSE DS = '0101'
;        IF YR EQ DP.YEAR THEN DE = DP.MONTH + DP.DAY ELSE DE = '1231'
;        IF KEYWORD_SET(RYEARS) THEN DPS = DATE_PARSE(REVERSE(CREATE_DATE(YR+DS,YR+DE))) ELSE DPS = DATE_PARSE(CREATE_DATE(YR+DS,YR+DE))
;        IF N_ELEMENTS(DATES) GT 0 THEN DPS = DATE_PARSE(DATES)
;        PLUN, LUN, 'Downloading files from REMOTE SERVER for ' + METH + '_' + APROD + ' and YEAR ' + YR + '...'
        FOR D=0, N_ELEMENTS(DPS)-1 DO BEGIN
          IF HAS(!S.COMPUTER,'NECLNAMAC') THEN WCMD = '/usr/local/bin/wget' ELSE WCMD = 'wget'
          FILE = 'L3b*GLOB_4_' + METH + '*_' + APROD + '_DAY_00.nc '
          FTP = SFTP + DPS[D].YEAR + SL + DPS[D].MONTH + SL + DPS[D].DAY + SL
          CMD = WCMD + ' --progress=bar:force -c -N ' + LIMIT + FTP + FILE + ' -a ' + LOGFILE
          PLUN, LUN, CMD
          SPAWN, CMD, LOG, ERR
        ENDFOR
  
        FA = FILE_SEARCH(DIR + SL + 'L3b*' + YR + '*',COUNT=CA) & FP = FILE_PARSE(FA)
        IF CA GT CB THEN PLUN, LUN, NUM2STR(CA-CB) + ' files downloaded for ' + YR
        IF CA EQ CB THEN PLUN, LUN, 'No new files downloaded for ' + YR
        PLUN, LUN, ERR
      ENDFOR ; YEARS
    ENDFOR ; PRODS
  ENDFOR ; METHODS  

  CD, !S.FUNCTIONS


END ; ***************** End of DWLD_GLOBCOLOUR_CHL *****************
