pro junk_wget_avhrr, LOGLUN=LOGLUN, RECENT=RECENT
  SL = PATH_SEP()

  FTP = 'ftp://ftp.nodc.noaa.gov/pub/data.nodc/pathfinder/Version5.3/L3C/'
  
  ftp = 'https://www.ncei.noaa.gov/data/oceans/pathfinder/Version5.3/L3C/'
  
  CD, !S.SST + 'AVHRR/L3/NC/'

  DP = DATE_PARSE(DATE_NOW())
  YRS = YEAR_RANGE('1981',DP.YEAR,/STRING)
YRS = '2021'  
  IF KEY(RECENT) THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  
  IF NONE(LOGLUN) THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  
  FOR N=0, N_ELEMENTS(YRS)-1 DO BEGIN
    CMD = 'wget -c -N ' + FTP + YRS(N) + SL + 'data' + SL + '20210930141556-NCEI-L3C_GHRSST-SSTskin-AVHRR_Pathfinder-PFV5.3_NOAA19_G_2021273_day-v02.0-fv01.0.nc';'*night*.nc'
    PLUN, LOG_LUN, CMD, 0
    SPAWN, CMD, WLOG, WERR
    PLUN, LOG_LUN, WLOG
    PLUN, LOG_LUN, WERR
  ENDFOR
  
  CD, !S.PROGRAMS
  
END  