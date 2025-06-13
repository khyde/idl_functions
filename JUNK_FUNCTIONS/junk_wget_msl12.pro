; $ID:	JUNK_WGET_MSL12.PRO,	2022-08-17-14,	USER-KJWH	$
pro junk_wget_msl12, LOGLUN=LOGLUN, RECENT=RECENT
  SL = PATH_SEP()

  FTP = 'ftp://ftpcoastwatch.noaa.gov/pub/socd1/mecb/coastwatch/viirs/science/L2/'
  DIR_OUT = !S.OC + 'NVIIRS/L2/NC/' & DIR_TEST, DIR_OUT
  CD, DIR_OUT
  
  FILELIST = !S.SCRIPTS + 'DOWNLOADS/FILELISTS/OC-NVIIRS_1KM.txt'
  LDIR = !S.LOGS + 'IDL_BATCH_DOWNLOADS/NVIIRS/' & DIR_TEST, LDIR
  LOGFILE = LDIR + 'BATCH_DOWNLOADS-OC-NVIIRS-1KM' + '_' + DATE_NOW(/DATE_ONLY) + '.log'

  IF NONE(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
   
  CMD = 'wget' + ' --progress=bar:force --tries=3 --retry-connrefused -c -N' + ' -i ' + FILELIST + ' -a ' + LOGFILE
  PLUN, LOG_LUN, CMD, 0
  SPAWN, CMD, WLOG, WERR
  PLUN, LOG_LUN, WLOG, 0
  PLUN, LOG_LUN, WERR, 0

  CD, !S.PROGRAMS
  
END  
