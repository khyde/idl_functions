pro junk_wget_mur, YEARS, LOGLUN=LOGLUN, RECENT=RECENT
  SL = PATH_SEP()

  FTP = 'https://podaac-tools.jpl.nasa.gov/drive/files/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1'
  NDDIR = !S.SST + 'MUR/L4/NC/'
  CKDIR = !S.SST + 'MUR/L4/CHECKSUMS/' & DIR_TEST, CKDIR

  DP = DATE_PARSE(DATE_NOW())
  IF NONE(YEARS)  THEN YRS = YEAR_RANGE('2002',DP.YEAR,/STRING) ELSE YRS=NUM2STR(YEARS)
  IF KEY(RECENT)  THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF NONE(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
YRS = '2020'  
  FOR N=0, N_ELEMENTS(YRS)-1 DO BEGIN
    CD, CKDIR
    
    DFILE = '/nadata/DATASETS/SST/MUR/L4/CHECKSUMS_TO_DOWNLOAD.txt'
    CMD = 'wget --tries=3 --retry-connrefused -c -N --user=khyde --password=FydOA4zodKWghvNRKH2P -i ' + DFILE
    PLUN, LOG_LUN, CMD, 0
    SPAWN, CMD, WLOG, WERR
    PLUN, LOG_LUN, WERR
    PLUN, LOG_LUN, WLOG
 stop  
    DFILE = '/nadata/DATASETS/SST/MUR/L4/FILES_TO_DOWNLOAD.txt' 
    CMD = 'wget -r -np -nH -nd --user=khyde --password=FydOA4zodKWghvNRKH2P -i' + DFILE ; + FTP + SL + YRS(N) + SL + ' -R nc' ;  -c -nd -nH -np -r -N ; -P ' + CKDIR
    PLUN, LOG_LUN, CMD, 0
    SPAWN, CMD, WLOG, WERR
    PLUN, LOG_LUN, WERR
    PLUN, LOG_LUN, WLOG
  ENDFOR
  
  CD, !S.PROGRAMS
  
END  