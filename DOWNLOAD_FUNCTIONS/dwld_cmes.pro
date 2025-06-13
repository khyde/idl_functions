; $ID:	DWLD_CMES.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_CMES, PRODS, DATERANGE=DATERANGE, DEPTH=DEPTH, $
                 LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN, LATMAX=LATMAX,$
                 RUN_WGET=RUN_WGET

;+
; NAME:
;   DWLD_CMES_SEALEVEL
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_CMES_SEALEVEL,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
;   PHY - Operational Mercator global ocean analysis and forecast system
;     DOI (product): https://doi.org/10.48670/moi-00016
;     https://resources.marine.copernicus.eu/product-detail/GLOBAL_ANALYSIS_FORECAST_PHY_001_024/INFORMATION
;     
;   GLORYS12V1
;     DOI (product): https://doi.org/10.48670/moi-00021
;     https://resources.marine.copernicus.eu/product-detail/GLOBAL_MULTIYEAR_PHY_001_030/INFORMATION
;   
; COPYRIGHT: 
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on June 03, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jun 03, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_CMES'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  DP = DATE_PARSE(DATE_NOW())
  
  USER = ' --user=khyde'
  PASS = ' --password=qbq-REH0dyb_nkv5xyx '
  PWD  = ' --pwd=qbq-REH0dyb_nkv5xyx '
  MOTU = ' -m motuclient'
  LINK = ' https://nrt.cmems-du.eu/motu-web/Motu'
  
  IF HAS(!S.COMPUTER,'NECLNAMAC') THEN WCMD = '/usr/local/bin/wget' ELSE WCMD = 'wget'
  IF HAS(!S.COMPUTER,'NECLNAMAC') THEN PCMD = 'python3'             ELSE PCMD = 'python'

  LOGDIR  = !S.LOGS + 'IDL_DOWNLOADS' + SL + 'CMES' + SL & DIR_TEST, LOGDIR
  LOGFILE = LOGDIR + 'CMES' + '_' + DATE_NOW(/DATE_ONLY) + '.log'

  ; ===> Open dataset specific log file
  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180
  PLUN,LUN,'*****************************************************************************************************',3
  PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
  PLUN,LUN,'Downloading CMES files... ', 0

  IF KEYWORD_SET(LIMIT)     THEN LIMIT = '--limit-rate=500k' ELSE LIMIT = ' '
  IF ~N_ELEMENTS(PRODS)     THEN PRODS = ['SEALEVEL_NRT','OCEAN_NRT','SEALEVEL_RA','OCEAN_RA','SALINITY_RA']
  
  IF ~N_ELEMENTS(YEARS)     THEN YRS = YEAR_RANGE('1993',DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT)    THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF ~N_ELEMENTS(DATERANGE) THEN DTR = GET_DATERANGE(MIN(YRS),MAX(YRS)) ELSE DTR = GET_DATERANGE(DATERANGE)
  IF DTR[1] GT DATE_NOW()   THEN DTR[1] = DATE_NOW()
  
  IF ~N_ELEMENTS(LONMIN) THEN LONMIN = '-82.5' 
  IF ~N_ELEMENTS(LONMAX) THEN LONMAX = '-51.5'
  IF ~N_ELEMENTS(LATMIN) THEN LATMIN = '22.5'
  IF ~N_ELEMENTS(LATMAX) THEN LATMAX = '48.5'
  LONLAT = ' --longitude-min ' + LONMIN + ' --latitude-min ' + LATMIN + ' --longitude-max ' + LONMAX + ' --latitude-max ' + LATMAX 
  
  FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    PROD = PRODS[R]
    DIR = !S.CMES + 'L4' + SL + 'NC' + SL + PROD + SL & DIR_TEST, DIR
    DEPTHMIN = 0.4 & DEPTHMAX = 0.5 ; Default depths

    CASE PROD OF
      'SEALEVEL_NRT': BEGIN
        DIR = !S.CMES + 'L4' + SL + 'NC' + SL + 'SEALEVEL_NRT' + SL & DIR_TEST, DIR
        CURRENT_VERSION = 'V4.1'
        RESOLUTION = '25KM'
        HTTPS = 'https://nrt.cmems-du.eu/motu-web/Motu'
        SERVICE_ID = 'SEALEVEL_GLO_PHY_L4_NRT_OBSERVATIONS_008_046-TDS'
        PRODUCT_ID = 'dataset-duacs-nrt-global-merged-allsat-phy-l4'
        VPRODS = ['adt','crs','err_sla','err_ugosa','err_vgosa','sla','ugos','ugosa','vgos','vgosa','lat_bnds','lon_bnds','nv'] 
      END ; SEALEVEL_NRT
      'OCEAN_NRT': BEGIN
        DIR = !S.CMES + 'L4' + SL + 'NC' + SL + 'OCEAN_NRT' + SL & DIR_TEST, DIR
        HTTPS = 'https://nrt.cmems-du.eu/motu-web/Motu'
        CURRENT_VERSION = 'NEMO3.1'
        RESOLUTION = '5KM'
        SERVICE_ID = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS'
        PRODUCT_ID = 'global-analysis-forecast-phy-001-024'
        VPRODS = ['bottomT','mlotst','thetao','uo','vo','zos']
      END    
      'SEALEVEL_RA': BEGIN    
        HTTPS = 'https://my.cmems-du.eu/motu-web/Motu'
        CURRENT_VERSION = ''
        SERVICE_ID = 'SEALEVEL_GLO_PHY_L4_MY_008_047-TDS'
        PRODUCT_ID = 'cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D'
        VPRODS = ['adt','crs','err_sla','err_ugosa','err_vgosa','sla','ugos','ugosa','vgos','vgosa','lat_bnds','lon_bnds','nv']
      END      
      'OCEAN_RA': BEGIN   
        HTPPS = 'https://my.cmems-du.eu/motu-web/Motu'
        CURRENT_VERSION = '12V1'
        RESOLUTION = '5KM'
        SERVICE_ID = 'GLOBAL_MULTIYEAR_PHY_001_030-TDS'
        PRODUCT_ID = 'cmems_mod_glo_phy_my_0.083_P1D-m'   
        VPRODS = ['bottomT','mlotst','thetao','uo','vo','zos']
      END ; GLORYS OCEAN
      'SALINITY_RA': BEGIN
        HTPPS = 'https://my.cmems-du.eu/motu-web/Motu'
        CURRENT_VERSION = '12V1'
        RESOLUTION = '5KM'
        SERVICE_ID = 'GLOBAL_MULTIYEAR_PHY_001_030-TDS'
        PRODUCT_ID = 'cmems_mod_glo_phy_my_0.083_P1D-m'
        VPRODS = ['so']
        DEPTHMIN = 0.4
        DEPTHMAX = 223
      END  
    ENDCASE ; PRODS
        
    DATES = CREATE_DATE(DTR[0],DTR[1])
    DP = DATE_PARSE(DATES)
    UN = UNIQ(STRMID(DATES,0,8))
    YRMTS = STRMID(DATES[UN],0,8)
    
    VARIABLE = ''
    FOR V=0, N_ELEMENTS(VPRODS)-1 DO VARIABLE = VARIABLE + ' --variable ' + VPRODS[V]
  
    FOR N=0, N_ELEMENTS(DATES)-1 DO BEGIN
      DA = DATE_PARSE(DATES[N])
      MINDATE = ' --date-min ' + '"'+DA.DASH_DATE+ ' 00:00:00"'
      MAXDATE = ' --date-max ' + '"'+DA.DASH_DATE+ ' 23:59:59"'
      IF DEPTHMIN GT 0.0 THEN MINDEPTH = ' --depth-min ' + NUM2STR(DEPTHMIN) ELSE MINDEPTH = ' --depth-min 0.0'
      IF DEPTHMAX GT 0.0 THEN MAXDEPTH = ' --depth-max ' + NUM2STR(DEPTHMAX) ELSE MAXDEPTH = ' --depth-max 0.5'
      PERIOD = 'D_' + STRMID(DA.DATE,0,8)
      OUTFILE = PERIOD + '-CMES-' + CURRENT_VERSION + '-5KM-CMES_GRID-' + PROD + '.nc' & OUTFILE = REPLACE(OUTFILE,'--','-')
      IF FILE_TEST(DIR + OUTFILE) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
      
      OUTPUT = ' --out-dir ' + DIR + ' --out-name ' + OUTFILE
      CMD = PCMD + MOTU + ' --motu ' + HTTPS + ' --service-id ' + SERVICE_ID + ' --product-id ' + PRODUCT_ID + LONLAT + MINDATE + MAXDATE + MINDEPTH + MAXDEPTH + VARIABLE + OUTPUT + USER + PWD
      PLUN, LUN, CMD    
      SPAWN, CMD, LOG, ERR
    ENDFOR ; DATES
  ENDFOR ; PROD





END ; ***************** End of DWLD_CMES_SEALEVEL *****************
