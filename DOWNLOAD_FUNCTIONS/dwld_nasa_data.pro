; $ID:	DWLD_NASA_DATA.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_NASA_DATA, DATASETS, DATERANGE=DATERANGE

;+
; NAME:
;   DWLD_NASA_DATA
;
; PURPOSE:
;   This program will download L1A and L2 files from the NASA OBPG website
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_NASA_DATA
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   DATASETS.......... The L1A ocean color dataset(s) (default = [SEAWIFS, MODISA, VIIRS, JPSS1, MODISA_SST, MODIST_SST])
;   DATERANGE......... A specified daterange (default = SENSOR_DATES(DATASET)
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Updated L1A and L2 NC databases
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
;   https://oceancolor.gsfc.nasa.gov/data/download_methods/
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 10, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 10, 2020 - KJWH: Initial code written
;   Apr 08, 2021 - KJWH: Updated to add the MODIS SST 11UM "dataset"
;   Sep 29, 2021 - KJWH: Updated code to delete the near-real time (NRT) files when new files are available
;   Dec 15, 2022 - KJWH: Changed name from DWLD_NASA_L1A to DWLD_NASA_DATA and adapted it to work with L3B files as well
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NASA_DATA'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  
  IF N_ELEMENTS(DATASETS) EQ 0 THEN DATASETS = 'SEAWIFS_PAR';['MODISA','MODIST','VIIRS','JPSS1','SMODISA','SMODIST','SMODISA_NRT','SMODIST_NRT','SEAWIFS']
  
; ===> Dates & Email
  MAILTO = 'kimberly.hyde@noaa.gov'
  DP = DATE_PARSE(DATE_NOW())              ; Parse today's date
  
; ===> Remote ftp locations
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/'
  OC_SEARCH = 'https://oceandata.sci.gsfc.nasa.gov/api/file_search.cgi'
  COOKIES   = ' --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --content-disposition' 
  
  NEW_FILES = []
    
; ===> Loop through datasets
  FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    LOGFILE = []
    COUNT_DOWNLOAD_LOOP = 0
    DATASET = STRUPCASE(DATASETS[N])
    TYPE = 'L1A'
    PROD = ''
    CASE DATASET OF
      'SEAWIFS':    DATDIR=!S.SEAWIFS
      'MODISA':     DATDIR=!S.MODISA
      'MODISA_CHL': BEGIN & DATDIR=!S.MODISA & TYPE='L3B4' & PROD='CHL' & END
      'MODISA_PAR': BEGIN & DATDIR=!S.MODISA & TYPE='L3B4' & PROD='PAR' & END
      'MODISA_RRS': BEGIN & DATDIR=!S.MODISA & TYPE='L3B4' & PROD='RRS' & END
      'SEAWIFS_CHL': BEGIN & DATDIR=!S.SEAWIFS & TYPE='L3B9' & PROD='CHL' & END
      'SEAWIFS_PAR': BEGIN & DATDIR=!S.SEAWIFS & TYPE='L3B9' & PROD='PAR' & END
      'SEAWIFS_RRS': BEGIN & DATDIR=!S.SEAWIFS & TYPE='L3B9' & PROD='RRS' & END
      'MODIST':      BEGIN & DATDIR=!S.MODIST & TYPE='L2' & END
      'SMODISA':     BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & END
      'SMODISA_NRT': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & END
      'SMODIST':     BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & END
      'SMODIST_NRT': BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & END
      'VIIRS':      DATDIR=!S.VIIRS
      'JPSS1':      DATDIR=!S.JPSS1
      ELSE: MESSAGE, 'ERROR: ' + DATASET + 'is not a recognized DATASET.'
    ENDCASE
    BATCH_LOG_DIR = !S.LOGS + 'IDL_DOWNLOADS' + SL + DATASET + SL 
    FDIR = DATDIR + TYPE + SL
    NDIR = FDIR + 'NC' + SL + PROD + SL                 & NDIR = REPLACE(NDIR,SL+SL,SL)
    CDIR = FDIR + 'CHECKSUMS' + SL + PROD + SL & CDIR = REPLACE(CDIR,SL+SL,SL)
    DIR_TEST, [BATCH_LOG_DIR,NDIR]
    DOWNLOAD_LIST = FDIR + 'DOWNLOAD_LIST.txt'                                            ; The file containing the list of files to download
    CHECKSUM_MASTER = FDIR + 'CHECKSUMS.sav'                                              ; The file containing checksums of the existing local files

; ===> Open dataset specific log file
    LOGFILE = BATCH_LOG_DIR + DATASET + '_' + DATE_NOW(/DATE_ONLY) + '.log'
    OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180
    PLUN,LUN,'*****************************************************************************************************',3
    PLUN,LUN,'WGET LOG FILE INITIALIZING on: ' + systime(),0
    PLUN,LUN,'Downloading files in ' + DATASET, 0
    
; ===> Check local files for duplicates
    DWLD_NASA_REMOVE_DUPLICATES, NDIR, LOGLUN=LUN

; ===> Determine dataset specific files and directories
    DLIST = DWLD_NASA_GET_DOWNLOAD_LIST(DATASET,DATERANGE=DATERANGE,LOGLUN=LUN,CKSUMFILE=CHECKSUM_MASTER,DWLD_LIST=DOWNLOAD_LIST,LOG_DIR=BATCH_LOG_DIR)         ; Get the list of (files in a structure) to download based on new files in the subscription and the master file list
    IF DLIST EQ [] THEN BEGIN
      PLUN, LUN, 'No files for ' + DATASET + ' were found to download.'
      PLUN, LUN, 'Closing WGET LOG FILE on: ' + systime(),0
      PLUN, LUN,'*****************************************************************************************************',3
      CLOSE, LUN & FREE_LUN, LUN   
      CONTINUE
    ENDIF
    DFILES = READ_TXT(DOWNLOAD_LIST) & NFILES = ROUNDS(N_ELEMENTS(DFILES))
    
    CMD = 'wget' + COOKIES + ' --progress=bar:force --tries=3 --retry-connrefused ' + ' -i ' + DOWNLOAD_LIST + ' -a ' + LOGFILE
    PLUN, LUN, CMD
    CD, NDIR
    PLUN, LUN, 'Downloading ' + NFILES + ' files...'

    SPAWN, CMD, WGET_RESULT, WGET_ERROR                                                   ; Spawn command to download new files
    CLOSE, LUN & FREE_LUN, LUN                                                            ; Close and reopen log file after downloading
    OPENW, LUN, LOGFILE,/APPEND,/GET_LUN,width=180 & FLUSH, LUN                           ; Close and reopen log file after downloading

; ===> Check the logfile to see if the wget was terminated
    WGET_LOG = READ_TXT(LOGFILE)                                                          ; Read the log file
    IF STRPOS(WGET_LOG[-1], 'Downloaded:') EQ -1 THEN WGET_RESULT = 'TERMINATED'          ; Look for the text string "TERMINATED"

    CL = COUNT_DOWNLOAD_LOOP
    IF WGET_RESULT EQ 'TERMINATED' THEN BEGIN
      PLUN, LUN, 'WGET terminated...'
      COUNT_DOWNLOAD_LOOP = 999                                                           ; If WGET was terminated, then do not repeat the download loop
    ENDIF

    IF WHERE_STRING(WGET_LOG,'Ending wget at') NE [] THEN PLUN, LUN, 'WGET terminated by killwget.sh'   ; Check to see if WGET was terminated by the killwget script or other means
    IF WHERE_STRING(WGET_LOG,'Connection reset by peer') NE [] THEN BEGIN                               ; Check to see if WGET was terminated by the killwget script or other means
      PLUN, LUN, 'WGET terminated by peer'
      COUNT_DOWNLOAD_LOOP = CL
    ENDIF

; ===> Look for duplicate files
    NFILES = FILE_SEARCH(NDIR + '*.*')
    FNP = FILE_PARSE(NFILES)
    FSP = STR_BREAK(REPLACE(FNP.NAME_EXT,'.',','),',')
    DUPS = WHERE_DUPS(FSP[*,0]+'-'+FSP[*,1],COUNT)
    OK = WHERE_DUPS(FNP.NAME,COUNT)
    IF COUNT GT 1 THEN MESSAGE, 'ERROR: Duplicate files found - need to figure out why files were downloaded again...'

; ===> Verify the CHKSUM of the newly downloaded files
    CKSUM_MASTER = DWLD_NASA_READ_CKSUM(DATASET)
    OK = WHERE(DLIST.LOCAL_FILES EQ '' AND FILE_TEST(NDIR+DLIST.SERVER_FILES) EQ 1, COUNT)
    IF COUNT GT 0 THEN BEGIN
      NEW_FILES = [NEW_FILES,DLIST[OK].SERVER_FILES]
      FOR I=0, COUNT-1 DO PLUN, LUN, 'Successfully downloaded ' + NEW_FILES[I] , 0
    ENDIF ELSE PLUN, LUN, 'No new files were downloaded for ' + DATASET  
    PLUN, LUN, 'Finished downloading files for ' + DATASET + '.'
    PLUN, LUN, 'Closing WGET LOG FILE on: ' + systime(),0
    PLUN,LUN,'*****************************************************************************************************',3
    CLOSE, LUN & FREE_LUN, LUN                                                            ; Close the log file 
  ENDFOR ; DATASETS


END ; ***************** End of DWLD_NASA_L1A *****************
