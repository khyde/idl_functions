; $ID:	DWLD_ESA_OCCCI.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_ESA_OCCCI, YEARS=YEARS, PRODS=PRODS, VERSION=VERSION, LOGLUN=LOGLUN, LIMIT=LIMIT, RECENT=RECENT, RYEARS=RYEARS, GETMAPPED=GETMAPPED, MONTHLY=MONTHLY, CHECK_FILES=CHECK_FILES

;+
; NAME:
;   DWLD_ESA_OCCCI
;
; PURPOSE:
;   Download files from the ESA OC-CCI ftp site
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_ESA_OCCCI
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   YEARS.......... The Year(s) of files to downloand
;   PRODS.......... The name of the products to download
;   VERSION........ Version of the files to download
;   LOGLUN......... The LUN for the logfile
;   
; KEYWORD PARAMETERS:
;   RECENT........ Get files from the current year and the previous year
;   RYEARS........ Reverse the order of years
;   MONTHLY..... Download the monthly files instead of the daily
;   CHECK_FILES... Rerun without the wget command to check the local files
;   LIMIT......... Limit the download rate of the files
;
; OUTPUTS:
;   New files downloaded into !S.OC/OCCCI/[VERSION]/SIN
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
;   DWLD_ESA_OCCCI, YEARS='2020', PRODS='CHLOR_A' 
;
; NOTES:
;   Sathyendranath, S, Brewin, RJW, Brockmann, C, Brotas, V, Calton, B, Chuprin, A, Cipollini, P, Couto, AB, Dingle, J, Doerffer, R, Donlon, C, Dowell, M, Farman, A, Grant, M, Groom, S, Horseman, A, Jackson, T, Krasemann, H, Lavender, S, Martinez-Vicente, V, Mazeran, C, Mélin, F, Moore, TS, Mu?ller, D, Regner, P, Roy, S, Steele, CJ, Steinmetz, F, Swinton, J, Taberner, M, Thompson, A, Valente, A, Zu?hlke, M, Brando, VE, Feng, H, Feldman, G, Franz, BA, Frouin, R, Gould, Jr., RW, Hooker, SB, Kahru, M, Kratzer, S, Mitchell, BG, Muller-Karger, F, Sosik, HM, Voss, KJ, Werdell, J, and Platt, T (2019) An ocean-colour time series for use in climate studies: the experience of the Ocean-Colour Climate Change Initiative (OC-CCI). Sensors: 19, 4285. doi:10.3390/s19194285
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 10, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 10, 2021 - KJWH: Initial code written
;   Nov 09, 2021 - KJWH: Updated so that the CURRENT_VERSION is used as the default
;   Nov 01, 2022 - KJWH: Updated to download verion 6.0 and changed the version directory from VERSION_6.0 to V6.0
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_ESA_OCCCI'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  CURRENT_VERSION = '6.0'
  DP = DATE_PARSE(DATE_NOW()) 
  LOGFILE = !S.LOGS + 'IDL_DOWNLOADS' + SL + 'OCCCI' + SL + 'OCCCI-4KM' + '_' + DATE_NOW(/DATE_ONLY) + '.log'
 
  IF N_ELEMENTS(LOGLUN)  NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  IF N_ELEMENTS(VERSION) EQ 0 THEN VERSION = CURRENT_VERSION
  IF N_ELEMENTS(PRODS)   EQ 0 THEN PRODS = ['chlor_a','rrs','iop','kd'] ELSE PRODS = STRLOWCASE(PRODS) ;
  IF N_ELEMENTS(YEARS)   EQ 0 THEN YRS = YEAR_RANGE('1997',DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT) THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF KEYWORD_SET(LIMIT)  THEN LIMIT = '--limit-rate=500k' ELSE LIMIT = ' '


  IF IDLTYPE(VERSION) NE 'STRING' THEN MESSAGE, 'ERROR: Version input must be a string'
  IF HAS(VERSION,'VERSION_')      THEN VERSION = REPLACE(VERSION,'VERSION_','') 
  DIRVER = 'V'+VERSION 
  
  CASE VERSION OF
    '4.2': SFTP = 'ftp://oceancolour.org/occci-v4.0/sinusoidal/netcdf/daily/' 
    '5.0': SFTP = 'ftp://oc-cci-data:ELaiWai8ae@ftp.rsg.pml.ac.uk/occci-v5.0/sinusoidal/netcdf/daily/'
    '6.0': SFTP = 'ftp://oc-cci-data:ELaiWai8ae@ftp.rsg.pml.ac.uk/occci-v6.0/sinusoidal/netcdf/daily/'
  ENDCASE
  
  IF KEYWORD_SET(GETMAPPED) THEN SFTP = REPLACE(SFTP,'sinusoidal','geographic')
  
  IF KEYWORD_SET(MONTHLY) THEN SFTP = REPLACE(SFTP,'daily','monthly')
  
  FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
    APROD = PRODS[R]
    CASE STRUPCASE(APROD) OF
      'CHLOR_A': DR = 'CHL'
      'RRS':     DR = 'RRS'
      'IOP':     DR = 'IOP'
      'KD':      DR = 'KD490'
    ENDCASE

    IF KEY(RYEARS) THEN YRS = REVERSE(YRS)
    FOR N=0, N_ELEMENTS(YRS)-1 DO BEGIN
      YR = YRS[N]
      DIR = !S.OCCCI_SOURCE + DIRVER + SL +'SOURCE' + SL + DR +SL 
      IF KEYWORD_SET(GETMAPPED) THEN DIR = REPLACE(DIR,'SOURCE','SOURCE_MAPPED')
      DIR_TEST, DIR
      
      CD, DIR
      FB = FILE_SEARCH(DIR + SL + 'E*-' + YR + '*',COUNT=CB)
      PLUN, LUN, 'Found ' + NUM2STR(CB) + ' LOCAL files for ' + YR
      
      FTP = SFTP + APROD + SL + YR + SL

      PLUN, LUN, 'Searching REMOTE SERVER for ' + DR + ' files for ' + YR + '...'
      CMD = 'curl -l -u oc-cci-data:ELaiWai8ae ' + FTP + 'ESACCI*' + VERSION + '.nc'                                                                         ; Use CURL to get a list of directories on the remote server
      SPAWN, CMD, DOYLIST, ERR
      OK = WHERE(STRPOS(DOYLIST,'fv'+VERSION) GT 0, COUNT,/NULL)
      IF DOYLIST[0] EQ '' OR OK EQ [] THEN CONTINUE
      DOYLIST = DOYLIST[OK]
      PLUN, LUN,  'Found ' + ROUNDS(N_ELEMENTS(DOYLIST)) + ' files on REMOTE SERVER. ' + ROUNDS(N_ELEMENTS(DOYLIST)-CB) + ' files remaining to download...'

      CMD = 'wget --progress=bar:force -c -N ' + LIMIT + FTP + 'ESACCI*-fv'+VERSION+'.nc --user=oc-cci-data --password=ELaiWai8ae -a ' + LOGFILE
      IF ~KEYWORD_SET(CHECK_FILES) THEN SPAWN, CMD, LOG, ERR
      FA = FILE_SEARCH(DIR + SL + 'E*' + YR + '*',COUNT=CA) & FP = FILE_PARSE(FA)
      IF CA GT CB THEN PLUN, LUN, NUM2STR(CA-CB) + ' files downloaded for ' + YR
      IF CA EQ CB THEN PLUN, LUN, 'No new files downloaded for ' + YR
      OK = WHERE_MATCH(DOYLIST,FP.NAME_EXT,COUNT,VALID=VALID,NCOMPLEMENT=NCOMP,COMPLEMENT=COMP,NINVALID=NINVALID,INVALID=INVALID)
      IF NCOMP NE 0 THEN BEGIN
        PLUN, LUN, NUM2STR(NCOMP) + ' files remaining to be downloaded'
        LI, DOYLIST[COMP]
      ENDIF ELSE PLUN, LUN, '0 files remaining to download for ' + YR
      PLUN, LUN, ERR
    ENDFOR
  ENDFOR

  CD, !S.PROGRAMS


END ; ***************** End of DWLD_ESA_OCCCI *****************
