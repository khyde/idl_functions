; $ID:	DWLD_AVHRR_SST.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_AVHRR_SST, YEARS=YEARS, VERSION=VERSION, DAYNIGHT=DAYNIGHT, LOGLUN=LOGLUN, LIMIT=LIMIT, RECENT=RECENT, RYEARS=RYEARS, CHECK_

;+
; NAME:
;   DWLD_AVHRR_SST
;
; PURPOSE:
;   Download AVHRR Pathfinder SST files
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_AVHRR_SST
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   YEARS.......... The Year(s) of files to download
;   VERSION........ Version of the files to download
;   DAYNIGHT....... Option to download either the night or day time files (default='night')
;   LOGLUN......... The LUN for the logfile
;   
; KEYWORD PARAMETERS:
;   RECENT........ Get files from the current year and the previous year
;   RYEARS........ Reverse the order of years
;   CHECK_FILES... Rerun without the wget command to check the local files
;   LIMIT......... Limit the download rate of the files
;
; OUTPUTS:
;   New files downloaded into !S.SST/AVHRR/L3/NC
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
;   Will need to be updated as new versions of the AVHRR data are released
;
; EXAMPLE:
;   DWLD_AVHRR_SST, YEARS='2020'
;
; 
;
; NOTES:
;   $Citations or any other useful notes$
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
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_AVHRR_SST'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  CURRENT_VERSION = 'VERSION_5.3'
  DP = DATE_PARSE(DATE_NOW())
  LOGFILE = !S.LOGS + 'IDL_DOWNLOADS' + SL + 'AVHRR' + SL + 'SST-AVHRR-4KM' + '_' + DATE_NOW(/DATE_ONLY) + '.log'
  DIR_TEST, !S.LOGS + 'IDL_DOWNLOADS' + SL + 'AVHRR' + SL 


  IF N_ELEMENTS(LOGLUN)   NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  IF N_ELEMENTS(VERSION)  EQ 0 THEN VERSION = '5.3'
  IF N_ELEMENTS(DAYNIGHT) NE 1 THEN DAYNIGHT = 'night' ELSE DAYNIGHT = STRLOWCASE(DAYNIGHT)
  IF N_ELEMENTS(YEARS)    EQ 0 THEN YRS = YEAR_RANGE('1981',DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF KEYWORD_SET(RECENT)       THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  IF KEYWORD_SET(LIMIT)        THEN LIMIT = '--limit-rate=500k' ELSE LIMIT = ' '

  PAT = '20210930141556-NCEI-L3C_GHRSST-SSTskin-AVHRR_Pathfinder-PFV'+VERSION+'_NOAA19_G_2021273_'+DAYNIGHT+'-v02.0-fv01.0.nc'

  IF IDLTYPE(VERSION) NE 'STRING' THEN MESSAGE, 'ERROR: Version input must be a string'
  IF HAS(VERSION,'VERSION_')      THEN VERSION = REPLACE(VERSION,'VERSION_','')
  DIRVER = 'VERSION_'+VERSION

  CASE VERSION OF
    '5.3': SFTP = 'https://www.ncei.noaa.gov/data/oceans/pathfinder/Version5.3/L3C/';'ftp://ftp.nodc.noaa.gov/pub/data.nodc/pathfinder/Version5.3/L3C/'  ; https://www.ncei.noaa.gov/data/oceans/pathfinder/Version5.3/L3C/
  ENDCASE

  DIR = !S.AVHRR + 'L3/'
  NDIR = DIR + 'NC/SST/'
  CD, NDIR

  FOR N=0, N_ELEMENTS(YRS)-1 DO BEGIN
    YR = YRS[N]
    FTP = SFTP + YR + SL + 'data' + SL 
    FB = FILE_SEARCH(NDIR + YR + '*AVHRR_Pathfinder*' + DAYNIGHT +'*.nc',COUNT=CB)
    PLUN, LUN, 'Found ' + NUM2STR(CB) + ' LOCAL files for ' + YR

    PLUN, LUN, 'Searching REMOTE SERVER for AVHRR_Pathfinder files for ' + YR + '...', 0
    CMD = 'curl -l ' + FTP + ' -o doylist.txt'                                                                          ; Use CURL to get a list of directories on the remote server
    SPAWN, CMD, LOG, ERR
    FILELIST = READ_TXT('doylist.txt')
    DOYLIST = []
    FOR F=0, N_ELEMENTS(FILELIST)-1 DO BEGIN
      SPOS = STRPOS(FILELIST[F],'href="')
      EPOS = STRPOS(FILELIST[F],'.nc">')
      IF SPOS GT 0 AND EPOS GT 0 THEN DOYLIST = [DOYLIST,STRMID(FILELIST[F],SPOS,EPOS-SPOS+3)]
    ENDFOR
    DOYLIST = REPLACE(DOYLIST,['href="','">'+YR],['',''])
    FILE_DELETE, 'doylist.txt'
     
    OK = WHERE(STRPOS(DOYLIST,DAYNIGHT) GT 0, COUNT,/NULL)
    IF DOYLIST[0] EQ '' OR OK EQ [] THEN CONTINUE
    DOYLIST = DOYLIST[OK]
    PLUN, LUN,  'Found ' + ROUNDS(N_ELEMENTS(DOYLIST)) + ' files on REMOTE SERVER. ' + ROUNDS(N_ELEMENTS(DOYLIST)-CB) + ' files remaining to download...',0
    IF N_ELEMENTS(DOYLIST)-CB EQ 0 THEN CONTINUE
    OK = WHERE(FILE_TEST(DIR+DOYLIST) EQ 0, COUNT, COMPLEMENT=COMP)
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: Check DOYLIST (count should equal the number of missing files)'
    
    DWLDLIST = DOYLIST[OK]
    WRITE_TXT, DIR+'DOWNLOAD_LIST.txt', FTP+DWLDLIST
    
    PLUN, LUN, 'Downloading files...'
    FOR I=0, N_ELEMENTS(DWLDLIST)-1 DO PLUN, LUN, 'Downloading: ' + DWLDLIST[I], 0
    CMD = 'wget -c -N' + ' --progress=bar:force --tries=3 --retry-connrefused ' + ' -i ' + DIR + 'DOWNLOAD_LIST.txt -a ' + LOGFILE
    PLUN, LUN, CMD
    CD, NDIR
    SPAWN, CMD, WGET_RESULT, WGET_ERROR                                                   ; Spawn command to download new files

    


PRINT, 'Need to check the downloaded files and update the code below'    

    
    IF ~KEYWORD_SET(CHECK_FILES) THEN SPAWN, CMD, LOG, ERR
    FA = FILE_SEARCH(DIR + YR + '*AVHRR_Pathfinder*' + DAYNIGHT +'*.nc',COUNT=CA) & FP = FILE_PARSE(FA)
    IF CA GT CB THEN PLUN, LUN, NUM2STR(CA-CB) + ' files downloaded for ' + YR
    IF CA EQ CB THEN PLUN, LUN, 'No new files downloaded for ' + YR
    OK = WHERE_MATCH(DOYLIST,FP.NAME_EXT,COUNT,VALID=VALID,NCOMPLEMENT=NCOMP,COMPLEMENT=COMP,NINVALID=NINVALID,INVALID=INVALID)
    IF NCOMP NE 0 THEN BEGIN
      PLUN, LUN, NUM2STR(NCOMP) + ' files remaining to be downloaded'
      LI, DOYLIST[COMP]
    ENDIF ELSE PLUN, LUN, '0 files remaining to download for ' + YR
    PLUN, LUN, ERR

  ENDFOR

  CD, !S.PROGRAMS



END ; ***************** End of DWLD_AVHRR_SST *****************
