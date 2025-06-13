; $ID:	JUNK_WGET_HERMES.PRO,	2022-08-17-14,	USER-KJWH	$
pro junk_wget_hermes, YEARS=YEARS, PRODS=PRODS, FTP=FTP
  SL = PATH_SEP()

  IF NONE(PRODS) THEN PRODS = ['AV//_CHL-OC5'];,'AV//_CHL1','GSM//_CHL1']
  
  IF NONE(FTP) THEN FTP_DIR = ['984907830'] ELSE FTP_DIR = STRING(FTP)

  LDIR = !S.DATASETS + 'OC/HERMES/LOGS/BATCH_DOWNLOADS/' & DIR_TEST, LDIR
  LOGFILE = !S.LOGS + 'IDL_BATCH_DOWNLOADS' + SL + 'HERMES' + SL + 'BATCH_DOWNLOADS-OC-HERMES-4KM' + '_' + DATE_NOW(/DATE_ONLY) + '.log'
  COUNTER = 0
  
  
  FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    CASE STRUPCASE(PRODS(R)) OF
      'AV//_CHL1': DR = 'AV_CHL1'
      'AV//_CHL-OC5':  DR = 'AV_CHL5'
      'GSM//_CHL1':    DR = 'GSM_CHL1'
    ENDCASE
    PRS = STR_BREAK(PRODS(R),'//')
    DIR = !S.DATASETS + 'OC/HERMES/SIN/NC/' + DR + SL & DIR_TEST, DIR
    CD, DIR
    
    TOTAL_FILES = 7966
    FTP = 'ftp://ftp.hermes.acri.fr/' + FTP_DIR + SL
    C_CMD = 'curl -l -u ftp_hermes:hermes% ' + FTP                     ; Use CURL to get a list of directories on the remote server
    SPAWN, C_CMD, FLIST, ERR
    FLIST = FLIST[SORT(FLIST)]
    NFILES = N_ELEMENTS(FLIST)
    P, NUM2STR(NFILES) + ' of ' + NUM2STR(TOTAL_FILES) + ' available, ' + NUM2STR(TOTAL_FILES-NFILES) + ' remaining to be added to ' + FTP

    
    RERUN_DOWNLOAD:
    DP = DATE_PARSE(DATE_NOW())
    IF NONE(YEARS) THEN YRS = YEAR_RANGE('1997',DP.YEAR,/STRING) ELSE YRS = STRTRIM(YEARS,2)
    FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
       
      FB = FLS(DIR + SL + 'L3b_' + YRS(Y) + '*' + PRS[0] + '*' + PRS[1] + '*.nc',COUNT=CB)
      P, 'Found ' + NUM2STR(CB) + ' files for ' + YRS(Y) + '-' + DR + ' in ' + DIR
      
      FL = FLIST[WHERE_STRING(FLIST,['L3b_'+YRS(Y), PRS[0], PRS[1]],COUNT_LIST,/MULTIPLE)]
      IF COUNT_LIST EQ 0 THEN CONTINUE
      P, 'Found ' + ROUNDS(COUNT_LIST) + ' files on remote server:  ' + ROUNDS(COUNT_LIST-CB) + ' files remaining to download...' 
      
      DP = DATE_PARSE(DATE_NOW())
      IF DP.HOUR GT '07' AND DP.HOUR LT '16' THEN LIMIT = ' ' ELSE LIMIT = ' '  ; '--limit-rate=500k ' 
      IF STRUPCASE(DP.DOW) EQ 'SAT' OR STRUPCASE(DP.DOW) EQ 'SUN' THEN LIMIT = ' '
          
      CMD = 'wget --progress=bar:force -c -N ' + LIMIT + FTP + 'L3b_' + YRS(Y) + '*' + PRS[0] + '*' + PRS[1] + '*_DAY_00.nc --user=ftp_hermes --password=hermes% -a ' + LOGFILE 
      SPAWN, CMD, LOG, ERR
      FA = FLS(DIR + SL + 'L3b_' + YRS(Y) + '*' + PRS[0] + '*' + PRS[1] + '*.nc',COUNT=CA)
      IF CA GT CB THEN P, NUM2STR(CA-CB) + ' files downloaded for ' + DR
      IF CA EQ CB THEN P, 'No new files downloaded for ' + YRS(Y)
      P, NUM2STR(COUNT_LIST-CA) + ' files remaining to be downloaded'
      P, ERR
    ENDFOR ; YEARS  
;    SPAWN, C_CMD, AFLIST, ERR
;    AFILES = N_ELEMENTS(AFLIST)
;    P, NUM2STR(AFILES) + ' of ' + NUM2STR(TOTAL_FILES) + ' available, ' + NUM2STR(TOTAL_FILES-AFILES) + ' remaining to be added to ' + FTP
;    FA = FLS(DIR + SL + 'L3b_' + '*' + DR + '*.nc',COUNT=CA)
;    COUNTER = COUNTER + 1
;    IF AFILES GT CA AND COUNTER LE 10 THEN BEGIN
;      P, NUM2STR(CA) + 'of ' + NUM2STR(AFILES) + ' available files downloaded, ' + NUM2STR(AFILES-CA) + ' remaining to be downloaded'
;      P, 'Rerunning file download...'
;      GOTO, RERUN_DOWNLOAD
;    ENDIF
  ENDFOR ; PRODS
  
  
  
  CD, !S.PROGRAMS
  
END  
