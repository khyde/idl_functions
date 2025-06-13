; $ID:	JUNK_REMOVE_FILES.PRO,	2022-08-17-14,	USER-KJWH	$
PRO JUNK_REMOVE_FILES

  ROUTINE_NAME = 'JUNK_REMOVE_FILES'
  SL = PATH_SEP()
  
  RUN_WGET = 0
  OC_BROWSE = 'http://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  
  SENSORS = ['SEAWIFS','OMODISA','VIIRS','SMODISA','SMODIST']
  
  
  FOR N=0, N_ELEMENTS(SENSORS)-1 DO BEGIN
    SENSOR = SENSORS(N)
    PRINT, 'Looking for files for ' + SENSOR
    CASE SENSOR OF
      'OMODISA': BEGIN & SERVER='modis'  & DATASET='OC-MODISA-1KM'  & PREFIX='A' & SUFFIX='L2_LAC_SUB_OC'  & THUMB = 'L2_LAC_OC'  & END
      'OMODIST': BEGIN & SERVER='modis'  & DATASET='OC-MODIST-1KM'  & PREFIX='T' & SUFFIX='L2_LAC_OC.nc'   & THUMB = 'L2_LAC_OC'  & END
      'SEAWIFS': BEGIN & SERVER='seadas' & DATASET='OC-SEAWIFS-1KM' & PREFIX='S' & SUFFIX='L2_MLAC_OC'     & THUMB = 'L2_MLAC_OC' & END
      'SMODISA': BEGIN & SERVER='nadata' & DATASET='SST-MODISA-1KM' & PREFIX='A' & SUFFIX=['L2_LAC_SST4.nc','L2_LAC_SST.nc'] & THUMB = 'L2_LAC_SST' & END
      'SMODIST': BEGIN & SERVER='nadata' & DATASET='SST-MODIST-1KM' & PREFIX='T' & SUFFIX=['L2_LAC_SST4.nc','L2_LAC_SST.nc'] & THUMB = 'L2_LAC_SST' & END
      'VIIRS':   BEGIN & SERVER='nadata' & DATASET='OC-VIIRS-1KM'   & PREFIX='V' & SUFFIX='L2_SNAPP_OC.nc' & THUMB = 'L2_SNAPP_OC' & END
      
    ENDCASE

    DIR     = SL + SERVER + SL + 'DATASETS' + SL + DATASET + SL
    DIR = REPLACE(DIR,['SST-MODISA-','SST-MODIST-'],['SST-MODIS-','SST-MODIS-'])
    L1A     = DIR + 'L1A' + SL + 'NC' + SL
    L1P     = DIR + 'L1A' + SL + 'PROCESS' + SL
    L2      = DIR + 'L2'  + SL + 'NC' + SL
    LDIR    = DIR + 'LOGS' + SL
    RDIR    = DIR + 'FILES_TO_REMOVE' + SL
    RL1     = RDIR + 'L1' + SL
    RL2     = RDIR + 'L2' + SL
    RTN     = RDIR + 'THUMBNAILS' + SL
    DIR_TEST, [RL1,RL2,RTN]
    
    ; ===> Open dataset specific log file
    LOGFILE = LDIR + ROUTINE_NAME + '_' + DATASET + '_' + DATE_NOW(/DATE_ONLY) + '.log'
    OPENW, LUN, LOGFILE, /APPEND, /GET_LUN, WIDTH=180
    PRINTF, LUN & PRINTF, LUN, '******************************************************************************************************************'
    PRINTF,LUN,'Initializing ' + ROUTINE_NAME + ' log file for ' + DATASET + ' on: ' + systime()
    PRINTF, LUN, 'Checking ' + SENSOR + ' files...'
    
    
    ; ===> Get the Original download list
    OLIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + REPLACE(DATASET,'-','_') + '_ORIGINAL_2016.txt'
    IF EXISTS(OLIST) EQ 0 THEN CONTINUE
    DLIST  = READ_TXT(OLIST) & DLIST = DLIST[SORT(DLIST)]
  
    ; ===> Get the New download list
    NLIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + REPLACE(DATASET,'-','_') + '_NEW_2016.txt'
    IF EXISTS(NLIST) EQ 0 THEN CONTINUE
    KLIST = READ_TXT(NLIST) & KLIST = KLIST[SORT(KLIST)] 
      
    ; ===> Find matching file names
    OK = WHERE_MATCH(DLIST,KLIST,COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,VALID=VALID,INVALID=INVALID, NINVALID=NINVALID)
    IF NCOMPLEMENT GE 1 THEN BEGIN
      PRINTF, LUN
      PRINTF, LUN, 'Found ' + ROUNDS(NCOMPLEMENT) + ' non-matching files in the ORIGINAL download list.'
      DP     = FILE_PARSE(DLIST(COMPLEMENT))
      FNAMES = DP.FIRST_NAME 

      ; ===> Find L1A files to delete
      L1FILES = L1A + DP.NAME_EXT
      OK = WHERE(FILE_TEST(L1FILES) EQ 1,COUNT)
      PRINT, 'Removing ' + ROUNDS(COUNT) + ' L1 files...' 
      IF COUNT GE 1 THEN BEGIN & PRINTF, LUN & PRINTF, LUN, 'Removing ' + ROUNDS(COUNT) + ' L1A files...' & ENDIF
      IF COUNT GE 1 THEN FILE_MOVE, L1FILES[OK], RL1, /VERBOSE, /OVERWRITE
      
      ; ===> Find L2 files to delete
      FOR S=0, N_ELEMENTS(SUFFIX)-1 DO BEGIN
        L2FILES = L2 + DP.FIRST_NAME + '.' + SUFFIX(S)
        L2FILES = L2FILES[UNIQ(L2FILES)]
        OK = WHERE(FILE_TEST(L2FILES) EQ 1, COUNT)
        PRINT, 'Removing ' + ROUNDS(COUNT) + ' L2 files...' 
        IF COUNT GE 1 THEN BEGIN & PRINTF, LUN & PRINTF, LUN, 'Removing ' + ROUNDS(COUNT) + ' L2 files...' & ENDIF
        IF COUNT GE 1 THEN FILE_MOVE, L2FILES[OK], RL2, /VERBOSE, /OVERWRITE
      ENDFOR
      
      ; ===> Find L1A files in PROCESS
      L1 = L1P + DP.NAME_EXT
      LFILES = [L1,REPLACE(L1,'.bz2','')]
      OK = WHERE(FILE_TEST(LFILES) EQ 1, COUNT)
      PRINT, 'Removing ' + ROUNDS(COUNT) + ' L1A process files...' 
      IF COUNT GE 1 THEN BEGIN & PRINTF, LUN & PRINTF, LUN, 'Deleteing ' + ROUNDS(COUNT) + ' L1A files to be processed...' & ENDIF
      IF COUNT GE 1 THEN FILE_DELETE, LFILES[OK], /VERBOSE

      ; ===> Get THUMBNAILS of files to be deleted
      IF KEY(RUN_WGET) THEN BEGIN
        EFILES = FNAMES + '.' + THUMB + '.nc_CHLOR_A_BRS.png?sub=l12image&file='+FNAMES+'.' + THUMB + '.nc_CHLOR_A_BRS'
        IF HAS(THUMB,'SST') THEN EFILES = REPLACE(EFILES,'CHLOR_A','SST')
        EFILES = EFILES[UNIQ(EFILES)]
        RERUN_WGET_THUMBNAILS:
        COUNTER = 1
        OKE = WHERE(FILE_TEST(RTN + EFILES) EQ 0, COUNT_EFILES)
        IF COUNT_EFILES GE 1 THEN BEGIN
          PRINT, 'Running WGET_THUMBNAILS for the ' + COUNTER + 'th time'
          CD, RTN
          IF COUNT_EFILES GT 100 THEN TFILES = EFILES(OKE(0:99)) ELSE TFILES = EFILES(OKE)
          WRITE_TXT, 'WGET_ERR.TXT', OC_BROWSE + TFILES
          CMD = 'wget -c -N -a ' + LOGFILE + ' -i WGET_ERR.TXT'
          P, CMD
          PRINTF, LUN, 'Downloading thumbnails of files to be deleted...' & PRINT, 'Downloading ' + ROUNDS(N_ELEMENTS(TFILES)) + ' thumbnails of files to be deleted'
          FOR I=0, N_ELEMENTS(TFILES)-1 DO PRINTF, LUN, ROUNDS(I) + ': Downloading thumbnail for ' + TFILES(I)
          FLUSH, LUN
          SPAWN, CMD, WGET_RESULT, WGET_ERROR
          CLOSE, LUN & FREE_LUN, LUN & OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN
          WAIT, 30
          COUNTER = COUNTER + 1
          GOTO, RERUN_WGET_THUMBNAILS
        ENDIF
      ENDIF ; KEY(WGET)  
      CLOSE, LUN & FREE_LUN, LUN
    ENDIF
    
  ENDFOR

END
