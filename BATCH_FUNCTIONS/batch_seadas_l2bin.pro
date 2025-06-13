; $ID:	BATCH_SEADAS_L2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
PRO BATCH_SEADAS_L2BIN, DATASETS, SUITE=SUITE, RESOLUTION=RESOLUTION, DATERANGE=DATERANGE,$
  NLOOPS=NLOOPS, LOGFILE=LOGFILE, SERVERS=SERVERS, NPROCESS=NPROCESS, $
  RFILES=RFILES, RUN_L2BIN=RUN_L2BIN, SKIP_ATTRIBUTES=SKIP_ATTRIBUTES, EMAIL_ALL=EMAIL_ALL

;+
; NAME: 
;   BATCH_SEADAS_L2BIN
;
; PURPOSE: 
;   This is a main BATCH program to run SeaDAS's l2bin step on level 2 data files
;
; CATEGORY:
;   BATCH_FUNCTIONS
;   
; REQUIRED INPUTS:
;   None
;     
; OPTIONAL INPUTS:
;   DATASETS.......... The name of the datasets to process
;   SUITE............. The name of the product suite for L2BIN
;   RESOLUTION........ The resolution (1, 2, 4) for the output bined data
;   DATERANGE......... The daterange of the files to process
;   NLOOPS............ The number of times to loop through the processing code
;   LOGFILE........... The name of the logfile
;   SERVERS........... The names of the servers to use for the various processes
;   NPROCESS.......... The number of processes to start on each server (default=6)
;
; KEYWORD PARAMETERS:
;   RFILES............ To reverse the order of files for processing
;   RUN_L2BIN......... To spawn the L2BIN parallel processing program
;   SKIP_ATTRIBUTES... Skip the step to add the attributes to the final files
;   EMAIL_ALL......... To email the results of the processing
;   
; OUTPUTS:
;   A list of files that need to be processed through the L2BIN'ing program
;   
; OPTOINAL OUTPUS:
;   Updated L3B files
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
;   BATCH_SEADAS_L2BIN, 'MODISA'
; 
; NOTES:
;
; COPYRIGHT:
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 16, 2015 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   OCT 23, 2017 - KJWH: Now using PROCESS_L2_L3B_FILES_NEW.SH to process all of the files at once and removed the SET files loop
;   MAR 15, 2018 - KJWH: Overhauled program to include steps from BATCH_SEADAS
;   MAR 21, 2018 - KJWH: Added SKIP_L2BIN keyword to skip the L2BIN'ing step
;   APR 18, 2018 - KJWH: Updated the L2BIN log reporting
;                        Changed SENSOR_INFO to PARSE_IT to speed up the file loop
;                        Added SENSOR_INFO(SET) when updating the ADD_IFILES files
;   APR 19, 2018 - KJWH: Updated the WGET thumbnails steps
;   APR 24, 2018 - KJWH: Changed keyword SKIP_L2BIN to RUN_L2BIN
;                        Added keyword EMAIL_ALL to control what reports are emailed after processing
;                        Now compiling all of the log, file lists, and errors into single files to be emailed as multiple attachments
;   AUG 30, 2018 - KJWH: Added PFT (Phtyoplankton Functional Type) product suite   
;   NOV 21, 2018 - KJWH: Added steps to determine the number of SERVERS and PROCESSES to run in parallel
;                          Added SERVER and NPROCESS keywords and defaults
;                          Using SERVER_PROCESSES(SERVERS,MAX_PROCESSES=MAXPROCESS) to determine the number of processes to run in parallel and on what servers
;                          Updated the L1A to L2 processing command to be SCMD = './process_L1A_L2_all.sh -a ' + SENSOR + ' -s' + SERVER_PROCESSES(SERVERS,MAX_PROCESSES=MAXPROCESS)
;   NOV 26, 2018 - KJWH: Added steps to WAIT one hour if no servers are currently available and then recheck.
;                          If after 1 hour, no servers are available, skip to the end of the processing loop.
;   FEB 25, 2019 - KJWH: Added GET_IDLPID to the logfile
;   APR 12, 2019 - KJWH: Added LOGFILE keyword
;   JUL 22, 2019 - KJWH: Changed IF NONE(LOGFILE) THEN LOGFILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log' 
;                             to IF NONE(LOGFILE) THEN LOG_FILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log' ELSE LOG_FILE = LOGFILE
;                             so that new logfile is created for each dataset in the loop. 
;   AUG 06, 2019 - KJWH: Updated the steps to find the SOURCE/INPUT_FILE information in the L3B file and add it as an attribute
;                        Added H5_IS_CORRUPT to check and see if the file is corrupt.  If yes, then delete and rerun.
;   AUG 12, 2019 - KJWH: Added RFILES keyword to reverse the order of the dates when checking files and updating attributes.
;                          IF KEY(RFILES) THEN TAGS = REVERSE(TAGS)
;                          SET = SETS.([WHERE(TAG_NAMES(SETS) EQ TAGS(S),/NULL,COUNT_TAG)])
;   FEB 17, 2022 - KJWH: Updated the MODISA and MODIST SST processing.  
;                        Eliminated the SMODISA11D and SMODIST11D datasets
;                        Now looping through the SST suffixes to keep the SST and SST4 files separate
;                        Removed combined datasets such as AT, SAT, and SAV
;                        Added COMPILE_OPT IDL2
;                        Changed the input variable SENSORS to DATASET
;                        Updated documentation and formatting
;-
; ***************************
  ROUTINE_NAME='BATCH_SEADAS_L2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  ; ===> EMAIL
  MAILTO = 'kimberly.hyde@noaa.gov'

  ; ===> REMOTE FTP LOCATIONS
  OC_CGI    = 'https://oceancolor.gsfc.nasa.gov/cgi/'
  OC_BROWSE = 'https://oceancolor.gsfc.nasa.gov/cgi/browse.pl/'
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/'

  ; ===> PARALLEL PROCESSING DEFAULTS
  IF ~N_ELEMENTS(NPROCESS) THEN MAXPROCESS = 6 ELSE MAXPROCESS = 1 > FIX(NPROCESS) < 12 ; Maximum number of processes per server
  IF ~N_ELEMENTS(SERVERS)  THEN SERVERS = ['satdata','luna'];,'modis']

  ; ===> DEFAULTS
  IF ~N_ELEMENTS(DATASETS)    THEN DATASETS    = ['MODISA','VIIRS','JPSS1','SEAWIFS','SMODISA','SMODIST']
  IF ~N_ELEMENTS(RESOLUTION)  THEN RESOLUTION  = ['2']
  IF ~N_ELEMENTS(NLOOPS)      THEN NLOOPS      = 2
  IF ~N_ELEMENTS(RUN_L2BIN)   THEN RUN_L2BIN   = 0
  IF ~N_ELEMENTS(EMAIL_ALL)   THEN EMAIL_ALL   = 0

; ===> SET UP NULL VARIABLES TO HOLD LOG, ERROR, AND FILE INFORMATION  
  DLOGS = []
  DERRS = []
  DAFTR = []
  DSUSP = []
  EATT  = []
  TOTAL_TO_PROCESS = []
  
; ===> LOOP THROUGH DATASETS  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DSET = STRUPCASE(DATASETS[D])
    LOOP = 0
    RESO = []
    PRINT, 'Processing DATASET: ' + DSET
    CASE DSET OF
      'MODISA':   BEGIN & DIR=!S.MODISA + SL & PREFIX='A' & SUFFIX='L2_LAC_SUB_OC'  & DR=['2002','2030'] & SUITES=['CHL','RRS','PAR','PFT','KD490','POC','IOP','PIC'] & THUMB='L2_LAC_OC' & END ;
      'MODIST':   BEGIN & DIR=!S.MODIST + SL & PREFIX='T' & SUFFIX='L2_LAC_OC.nc'   & DR=['2000','2030'] & SUITES=['CHL'] & RESO='2' & END
      'SEAWIFS':  BEGIN & DIR=!S.SEAWIFS+ SL & PREFIX='S' & SUFFIX='L2_MLAC_OC'     & DR=['1997','2010'] & SUITES=['CHL','RRS','PAR','PFT','KD490','POC','IOP','PIC'] & THUMB='L2_MLAC_OC' & END
      'VIIRS':    BEGIN & DIR=!S.VIIRS  + SL & PREFIX='V' & SUFFIX='L2_OC_SUB'      & DR=['2012','2030'] & SUITES=['CHL','RRS','PAR','PFT'] & THUMB='L2_SNPP_OC' & END
      'JPSS1':    BEGIN & DIR=!S.JPSS1  + SL & PREFIX='V' & SUFFIX='L2_OC_SUB'      & DR=['2017','2030'] & SUITES=['CHL','RRS','PAR','PFT'] & THUMB='L2_JPSS1_OC' & END
      'SMODISA':  BEGIN & DIR=!S.MODISA + SL & PREFIX='A' & SUFFIX=['.L2.SST4.nc','.L2.SST.nc'] & DR=[] & SUITES=[] & THUMB='L2.SST' & END
      'SMODIST':  BEGIN & DIR=!S.MODIST + SL & PREFIX='T' & SUFFIX=['.L2.SST4.nc','.L2.SST.nc'] & DR=[] & SUITES=[] & THUMB='L2.SST' & END
      'CZCS':     BEGIN & DIR=!S.CZCS   + SL & PREFIX='C' & SUFFIX=''               & DR=['1978','1986'] & SUITES=['CHL','RRS','PAR'] & RESO='2'  & THUMB='L2_MLAC_OC'& END
    ENDCASE
    
    
    IF ANY(SUITE) THEN BEGIN
      OK = WHERE_MATCH(SUITES,SUITE,COUNT)
      IF COUNT GE 1 THEN SUITES = SUITES[OK]    
    ENDIF
    IF NONE(RESO) THEN RESO = RESOLUTION
    IF NONE(DR) AND NONE(DATERANGE) THEN DRANGE = ['1997','2100']
    IF ANY(DR) THEN DRANGE = DR
    IF ANY(DATERANGE) THEN DRANGE = DATERANGE
    
    IF HAS(SUFFIX,'SST') THEN DATASET = 'SST-' + STRMID(DSET,1)  $
                         ELSE DATASET = 'OC-' + DSET 

    LDIR    = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + DSET + SL
    DIR2    = DIR + 'L2'  + SL
    L2_DIR  = DIR2 + 'NC' + SL
    L2_BIN  = DIR2 + 'BIN_FILES' + SL
    PARDIR  = !S.SCRIPTS + 'SEADAS' + SL + 'L2BIN_PAR' + SL
    SUSPECT = DIR2 + 'SUSPECT' + SL                    ; Directory for suspect files
    THUMBS  = SUSPECT + 'THUMBNAILS'  + SL             ; Directory for files thumbnails of the suspect files
    L2_SUS  = SUSPECT + 'L2BIN_ERROR' + SL
    DIR_TEST, [LDIR,L2_BIN,THUMBS,L2_SUS]

    ; ===> Open dataset specific log file
    IF NONE(LOGFILE) THEN LOG_FILE = LDIR + REPLACE(DATASET,SL,'_') + '_' + DATE_NOW(/DATE_ONLY) + '.log' ELSE LOG_FILE = LOGFILE
    OPENW, LUN, LOG_FILE, /APPEND, /GET_LUN, WIDTH=180
    PLUN, LUN, '******************************************************************************************************************',3
    PLUN, LUN, 'Initializing ' + ROUTINE_NAME + ' log file for: ' + DATASET + ' at: ' + systime() + ' on ' + !S.COMPUTER, 0
    PLUN, LUN, 'PID=' + GET_IDLPID() ; ***** NOTE, may not be accurate with IDLDE sessions *****
    PLUN, LUN, '******************************************************************************************************************'   
    
    PLUN,  LUN, 'Checking ' + DSET + ' files...', 0

    FOR X=0, N_ELEMENTS(SUFFIX)-1 DO BEGIN      
      L2S = FILE_SEARCH(L2_DIR + PREFIX + '*' + SUFFIX[X])
      L2S = DATE_SELECT(L2S,DRANGE,COUNT=COUNT_L2S)
      IF COUNT_L2S EQ 0 THEN CONTINUE
      FL2 = PARSE_IT(L2S)
      SETS = PERIOD_SETS(PERIOD_2JD(FL2.PERIOD),DATA=L2S,PERIOD_CODE='D',/NESTED)
      TAGS = TAG_NAMES(SETS)
    
      PLUN, LUN, 'Creating L2BIN list files...'
      PLUN, LUN, 'Found ' + ROUNDS(N_ELEMENTS(L2S)) + ' L2 ' + DSET + ' files to be binned into ' + ROUNDS(N_ELEMENTS(TAGS)) + ' daily files', 0
  
      NIGHT=0
      QUAL_MAX=''
      FLAGS = "ATMFAIL,LAND,HIGLINT,HILT,HISATZEN,STRAYLIGHT,CLDICE,NAVFAIL,LOWLW"

      PROCESSING_LOOP = 0
      L2BIN_LOG = []
      L2BIN_ERR = []
      FILES_AFTER = []
      BSUSPECT = FLS(L2_SUS + PREFIX + '*' + SUFFIX[X],COUNT=SUSPECT_BEFORE)
      IF SUSPECT_BEFORE GT 0 THEN BEGIN
        PRO_NAMES = (FILE_PARSE(BSUSPECT)).FIRST_NAME
        IF HAS(SUITES,'SST') THEN TSUITE = '.nc_SST_BRS' ELSE TSUITE = '.nc_CHLOR_A_BRS'    
        WFILES = OC_BROWSE + PRO_NAMES + '.' + THUMB + TSUITE + '.png?sub=l12image&file=' + PRO_NAMES + '.' + THUMB + TSUITE 
        TFILES = THUMBS    + PRO_NAMES + '.' + THUMB + TSUITE + '.png'               
        OKT = WHERE(FILE_TEST(TFILES) EQ 0, COUNT_TFILES, /NULL, COMPLEMENT=TCOMP, NCOMPLEMENT=TNCOMP)
;        IF COUNT_TFILES GE 1 THEN BEGIN
;          CD, THUMBS
;          PLUN, LUN, 'Downloading thumbnail ' + WFILES, 0
;          PLUN, LUN, 'Downloading ' + ROUNDS(COUNT_TFILES) + ' PROCESSING ERROR thumbnails...'
;          W = WGET(WFILES[OKT])
;        ENDIF
        CD, !S.PROGRAMS
        TFILES = TFILES[WHERE(FILE_TEST(TFILES) EQ 1,/NULL,COUNT_TFILES)]
        IF COUNT_TFILES GT 0 THEN FILE_UPDATE, TFILES, L2_SUS
      ENDIF

      RERUN:
      PROCESS_L3 = []
      IF KEY(RFILES) THEN TAGS = REVERSE(TAGS)
      FOR S=0, N_ELEMENTS(TAGS)-1 DO BEGIN
        SET = SETS.([WHERE(TAG_NAMES(SETS) EQ TAGS[S],/NULL,COUNT_TAG)]) & IF COUNT_TAG NE 1 THEN STOP
        RERUN_L2BIN:
  
        PI = PARSE_IT(SET[0])
        SI = SENSOR_INFO(SET[0])
        BINPROD=''
        IF DSET EQ 'SMODISA' OR DSET EQ 'SMODIST' THEN BEGIN
          IF STRPOS(SUFFIX[X],'SST4') GE 0 THEN BINPROD = '-SSTN4' ELSE BINPROD = '-SSTD11'
          IF STRPOS(SUFFIX[X],'SST4') GE 0 THEN SUITES  = 'SST4'   ELSE SUITES  = 'SST'
        ENDIF
        CASE DSET OF
          'SMODISA': SATNAME = STRMID(PI.FIRST_NAME,0,1) + DATE_2YEAR(PERIOD_2DATE(SI.PERIOD)) + DATE_2DOY(PERIOD_2DATE(SI.PERIOD),/PAD)
          'SMODIST': SATNAME = STRMID(PI.FIRST_NAME,0,1) + DATE_2YEAR(PERIOD_2DATE(SI.PERIOD)) + DATE_2DOY(PERIOD_2DATE(SI.PERIOD),/PAD)
          ELSE:  SATNAME = STRMID(PI.FIRST_NAME,0,8)
        ENDCASE
        L2BIN_LISTFILE = L2_BIN + SATNAME + BINPROD + '-L2BIN.txt'
        IF FILE_MAKE(SET,L2BIN_LISTFILE,OVERWRITE=OVERWRITE) EQ 1 THEN WRITE_TXT, L2BIN_LISTFILE, SET ELSE BEGIN ; Remake list file in case the list of input files changes
          SETLIST = READ_TXT(L2BIN_LISTFILE)
          OK = WHERE_MATCH(SETLIST, SET, VALID=VALID, COUNT)
          IF COUNT NE N_ELEMENTS(SETLIST) OR N_ELEMENTS(SET) NE N_ELEMENTS(SETLIST) THEN WRITE_TXT, L2BIN_LISTFILE, SET
        ENDELSE  
  
        FOR R=0, N_ELEMENTS(RESO)-1 DO BEGIN ; Loop through resolution
          RES = RESO[R]
          L3D    = DIR + 'L3B' + RES + SL
          L3_PRO = L3D + 'PROCESS' + SL
          L3_DIR = L3D + 'NC'  + SL + SUITES + SL
          L3_LOG = L3_DIR + 'LOGS' + SL
          L3_AIF = L3_DIR + 'ADD_IFILES' + SL
          L3_THB = L3D + 'THUMBNAILS' + SL
          IF S EQ 0 THEN DIR_TEST, [L3_PRO, L3_LOG, L3_AIF, L3_THB] ; Only need to DIR_TEST during the first loop
  
          FOR T=0, N_ELEMENTS(SUITES)-1 DO BEGIN ; Loop through suites
            OUTNAME = SUITES[T]
            L3_DIR = L3D + 'NC'  + SL + OUTNAME + SL
            L3_LOG = L3_DIR + 'LOGS' + SL
            L3_AIF = L3_DIR + 'ADD_IFILES' + SL
            L3_THS = L3_THB + OUTNAME + SL & IF OUTNAME EQ 'CHL' OR OUTNAME EQ 'SST' THEN DIR_TEST, L3_THS
            DIR_TEST,[L3_DIR,L3_LOG,L3_AIF]
  
            L3B_FILE = L3_DIR + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.nc'
            L3B_AIF  = L3_AIF + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.nc'
            L3B_LOG  = L3_LOG + SATNAME + '-' + OUTNAME + '.LOG'
            L3B_ALG  = L3_AIF + SATNAME + '-' + OUTNAME + '.LOG'
            L3B_PROCESS = L3_PRO + SATNAME + '-L2BIN-' + OUTNAME + '.txt'
            L3B_ERROR   = L2_SUS + SATNAME + '-L2BIN-' + OUTNAME + '.txt'
            L3B_TEMP    = L3_PRO + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.nc'
            
            IF FILE_MAKE(L2BIN_LISTFILE,L3B_ERROR,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE  ; Skip if the ERROR file is present and was created after the L2BIN_LISTFILE
            IF FILE_MAKE(L2BIN_LISTFILE,[L3B_FILE,L3B_LOG],OVERWRITE=OVERWRITE) EQ 0 THEN BEGIN ; Skip if the L3B file exists
              IF EXISTS(L3B_PROCESS) THEN FILE_DELETE, L3B_PROCESS, /VERBOSE ; Remove the PROCESS file
;              IF OUTNAME EQ 'CHL' OR OUTNAME EQ 'SST' THEN BEGIN
;                L3B_THUMB   = L3_THS + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.png'
;                IF OUTNAME EQ 'CHL' THEN PROD = 'CHLOR_A' ELSE PROD = OUTNAME
;          ;      IF FILE_MAKE(L3B_FILE,L3B_THUMB,OVERWRITE=OVERWRITE) EQ 1 THEN PRODS_2PNG, L3B_FILE, PROD=PROD, MAPP='NWA', /THUMBNAIL, DIR_OUT=DIR_THS, PNGFILE=L3B_THUMB, BUFFER=1, /ADD_CB
;           ;     PFILE, _L3B_THUMB, /W
;              ENDIF
              CONTINUE
            ENDIF
            IF EXISTS(L3B_FILE) THEN FILE_DELETE, L3B_FILE, /VERBOSE ; Delete the L3B final file and the LOG file if it needs to be recreated (FILE_MOVE,/OVERWRITE does not always replace the file)
            IF EXISTS(L3B_LOG)  THEN FILE_DELETE, L3B_LOG,  /VERBOSE
            IF FILE_MAKE(L2BIN_LISTFILE,L3B_AIF,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
              PROCESS_L3 = [PROCESS_L3,L3B_PROCESS]
              IF FILE_TEST(L3B_PROCESS) EQ 0 AND FILE_TEST(L2BIN_LISTFILE) EQ 1 THEN FILE_COPY, L2BIN_LISTFILE, L3B_PROCESS, /VERBOSE
            ENDIF ELSE IF EXISTS(L3B_PROCESS) THEN FILE_DELETE, L3B_PROCESS, /VERBOSE
            IF PROCESSING_LOOP EQ 0 AND KEY(RUN_L2BIN) THEN CONTINUE ; If the first time through the processing loop, skip the "add attributes" step until after the L2B processing step (unless the L2BIN step will be skipped)
            
            ; ===> Read the log file and make sure the file was created successfully
            IF EXISTS(L3B_ALG) THEN BEGIN
              BLOG = READ_TXT(L3B_ALG)
              OK_GOOD = WHERE_STRING(BLOG,'Read Error:')
              IF OK_GOOD NE [] THEN BEGIN
                PLUN, LUN, 'ERROR: ' + L3B_AIF + ' L2BIN processing error. Deleting... '
                IF EXISTS(L3B_AIF) THEN FILE_DELETE, L3B_AIF, /VERBOSE
                FILE_DELETE, L3B_ALG, /VERBOSE
                GOTO, RERUN_L2BIN
              ENDIF
              GONE, BLOG
            ENDIF ; EXISTS(L3B_ALG)           
            
            ; ===> Update the attributes
            RERUN_ATTRIBUTES:
            IF FILE_TEST(L3B_AIF) EQ 1 AND ~KEY(SKIP_ATTRIBUTES) THEN BEGIN
              SI = SENSOR_INFO(SET)
              PLUN, LUN, '***** Working on ' + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.nc *****',1
              PLUN, LUN, 'Checking to see if the file is corrupt...',0
              IF H5_IS_CORRUPT(L3B_AIF,/VERBOSE) EQ 1 THEN BEGIN
                PLUN, LUN, L3B_AIF + 'is corrupt, deleting...'
                FILE_DELETE, L3B_AIF
                GOTO, RERUN_L2BIN
              ENDIF 
              
              PLUN, LUN, 'Updating the attributes...', 0
              IF H5_HAS_GROUP(L3B_AIF,'processing_control') EQ 0 THEN BEGIN
                PLUN, LUN, 'ERROR: ' + L3B_AIF + ' is not a complete file. Deleting...'
                FILE_DELETE, L3B_AIF, /VERBOSE
                GOTO, RERUN_L2BIN
              ENDIF
              
              ; ===> Get list of input/source files
              PLUN, LUN, 'Reading the input files...', 0
              NCID = NCDF_OPEN(L3B_AIF,/NOWRITE)
              GRID = NCDF_NCIDINQ(NCID, 'processing_control')
              NCDF_ATTGET, GRID, 'source', ATTR,/GLOBAL
              NCDF_CLOSE, NCID
              SRC = STRING(ATTR)
              
              PLUN, LUN, 'Editing the file...',0
              FID = H5F_OPEN(L3B_AIF,/WRITE)                             ; Get the FILE ID
          ;    GID = H5G_OPEN(FID,'processing_control')                   ; Get the GROUP ID for the "source" attribute
          ;    SID = H5A_OPEN_NAME(GID,'source')                          ; Get the "source" ATTRIBUTE ID
            ;  SRC = H5A_READ(SID)                                        ; Read the "source" files
          ;    SRC = 'Error reading SRC files from ' + L3B_AIF + '. Will need to update once issue with SeaDAS 7.5 is resolved.'
          ;    H5A_CLOSE, SID                                             ; Close the ATTRIBUTE ID
          ;    H5G_CLOSE, GID                                             ; Close the GROUP ID
  
              ; ===> Add the list of input files to the attributes
              IF H5_HAS_ATTRIBUTE(FID, 'input_files') EQ 1 THEN H5_EDIT_ATTRIBUTE, FID, 'input_files', SRC $
                                                           ELSE H5_ADD_ATTRIBUTE,  FID, 'input_files', SRC
  
              IF SAME(SI.SENSOR) EQ 0 THEN BEGIN ; Change the TITLE, PLATFORM and INSTRUMENT in the netcdf file when it includes data from multiple sensors
                SET_SENSORS = SI[UNIQ(SI.SENSOR)].SENSOR
                TITLE = [] & INSTR = [] & PLAT = []
                FOR SS=0, N_ELEMENTS(SET_SENSORS)-1 DO BEGIN
                  CASE SET_SENSORS(SS) OF
                    'SEAWIFS': BEGIN & TITLE=[TITLE,'SeaWiFS'] & INSTR=[INSTR,'SeaWiFS'] & PLAT=[PLAT,'Orbview-2'] & END
                    'MODISA' : BEGIN & TITLE=[TITLE,'MODISA']  & INSTR=[INSTR,'MODIS']   & PLAT=[PLAT,'Aqua']      & END
                    'MODIST' : BEGIN & TITLE=[TITLE,'MODIST']  & INSTR=[INSTR,'MODIS']   & PLAT=[PLAT,'Terra']     & END
                  ENDCASE
                ENDFOR ; SET_SENSORS
                H5_EDIT_ATTRIBUTE, FID, 'title',       STRJOIN(TITLE, ', ') + ' Level-3 Binned Data'
                H5_EDIT_ATTRIBUTE, FID, 'instrument',  STRJOIN(INSTR, ', ')
                H5_EDIT_ATTRIBUTE, FID, 'platform',    STRJOIN(PLAT,  ', ')
              ENDIF
              IF H5_HAS_ATTRIBUTE(FID, 'modification_history') EQ 1 THEN H5_EDIT_ATTRIBUTE, FID, 'modification_history', 'File edited by K. Hyde @ NOAA/Fisheries/Narragansett on ' + SYSTIME() $
                                                                    ELSE H5_ADD_ATTRIBUTE,  FID, 'modification_history', 'File edited by K. Hyde @ NOAA/Fisheries/Narragansett on ' + SYSTIME()
              H5F_CLOSE, FID
              IF FILE_TEST(L3B_FILE) EQ 1 THEN FILE_DELETE, L3B_FILE, /VERBOSE ; Delete the original file if it exists to be recreated (FILE_MOVE,/OVERWRITE does not always replace the file)
              PLUN, LUN, 'Moving file to ' + L3_DIR, 0 & FILE_MOVE, L3B_AIF, L3_DIR, /OVERWRITE
              PLUN, LUN, 'Moving log file to ' + L3_LOG, 0
              IF EXISTS(L3B_ALG) THEN FILE_MOVE, L3B_ALG, L3_LOG, /OVERWRITE
              PLUN, LUN, 'Finished updating ' + SATNAME + '.L3B' + RES + '_DAY_' + OUTNAME + '.nc', 0
              CONTINUE
            ENDIF ;ELSE CONTINUE ; FILE_TEST(L3B_AIF)
  
            IF ~KEY(RUN_L2BIN) THEN CONTINUE                            ; Only run if the original L2BIN processing step was run
            NEW_SET = SET
            PREV_SET = N_ELEMENTS(SET)
            ERR_TXT = 'Error creating ' + L3B_FILE                      ; Create information that will be written to an ERROR file if necessary
            ERR_TXT = [ERR_TXT,'Initial input files: ',SET]             ; Add the list of input L2 files to the ERROR text
  
            RERUN_L3BPROCESS:
  
       ;     FILES = FLS(L3_PRO + PREFIX + '*' + OUTNAME + '.txt',DATERANGE=DRANGE, COUNT=COUNTL2)
       ;     IF COUNTL2 NE 1 THEN stop
  
            IF EXISTS(L3B_ALG) THEN FILE_DELETE, L3B_ALG ; Remove old LOG file
            CD, !S.SCRIPTS + 'SEADAS' + SL
            PROCESS_FILE = SATNAME + '-L2BIN-' + OUTNAME + '.txt'
            CMD = './process_L2_L3B_file.sh ' + PROCESS_FILE + ' ' + REMOVE_LAST_SLASH(L3_PRO) + ' ' + REPLACE(L3_PRO,'PROCESS/','TEMP') + ' ' + REMOVE_LAST_SLASH(L3_AIF) + ' ' + RES + ' ' + FLAGS + ' ' + OUTNAME + ' ' + PREFIX + ' ' + PARDIR + DSET + SL 
            POF, S, TAGS, OUTTXT=OUTTXT,/QUIET,/NOPRO
            PLUN, LUN, 'Running ' + CMD + ' for ' + L3B_AIF + ' ' + OUTTXT
            SPAWN, CMD, L2LOG, L2ERR
            
  ;          PARFILE = PARDIR + DSET + SL + 'l2bin_defaults_' + OUTNAME + '.par' & IF ~EXISTS(PARFILE) THEN STOP
  ;          IF HAS(OUTNAME,'SST') THEN CMD = 'l2bin infile='+L3B_PROCESS + ' ofile='+L3B_TEMP + ' resolve='+RES + ' suite='+OUTNAME + ' prodtype=Regional' + ' qual_max=2' + ' night=1' + ' parfile='+parfile $
  ;                                ELSE CMD = 'l2bin infile='+L3B_PROCESS + ' ofile='+L3B_TEMP + ' resolve='+RES + ' suite='+OUTNAME + ' prodtype=Regional' + ' flaguse='+FLAGS + ' parfile='+parfile
  ;          PLUN, LUN, CMD
  ;          SPAWN, CMD, L2LOG, L2ERR
            CD, !S.PROGRAMS
  
            ERRFILE = []
            IF ~FILE_TEST(L3B_AIF) THEN BEGIN ; Figure out why the L3B file was not created
              IF KEY(L2ERR) THEN BEGIN ; Processing error
                IF HAS(L2ERR[1],'Consider QC fail for file:') EQ 0 THEN STOP ; Need to look for a different error string.
                PLUN, LUN, 'ERROR: l2bin processing of ' + L3B_PROCESS + ' failed'
                ERRSTR = STRSPLIT(L2ERR[1],' ',/EXTRACT)
                ERRFILE = ERRSTR(-1)
                ERR_TXT = [ERR_TXT,L2ERR]
              ENDIF
              IF HAS(L2LOG, '-E- File') AND HAS(L2LOG,'does not exist') THEN BEGIN ; Incidents of missing files will be in the L2LOG
                ERRSTR = STRSPLIT(L2LOG(3),' ',/EXTRACT)
                POS = WHERE(ERRSTR EQ 'File')
                ERRFILE = ERRSTR(POS+1)
                ERR_TXT = [ERR_TXT, L2LOG]
              ENDIF
              IF HAS(L2LOG, 'not found in L2 dataset') THEN BEGIN
                stop
                PLUN, LUN, L2LOG(-1)
                ERRTXT = STRSPLIT(L2LOG(-1),'"',/EXTRACT)
                ERRFILE = ERRTXT(-2)
                ERR_TXT = [ERR_TXT, L2LOG]
              ENDIF
              IF HAS(L2LOG, 'total_filled_bins: 0')  THEN BEGIN
                ;stop
                PLUN, LUN, 'Unable to create ' + L3B_FILE
                FOR I=0, N_ELEMENTS(NEW_SET)-1 DO PLUN, LUN, 'Moving ' + NEW_SET(I) + ' to L2BIN SUSPECT directory',0
                ERR_TXT = [ERR_TXT, L2LOG, 'Unable to create ' + L3B_FILE]
                WRITE_TXT, L3B_ERROR, ERR_TXT
                MOVE_FILES = [L2BIN_LISTFILE,L3B_ALG,NEW_SET] & MOVE_FILES = MOVE_FILES[WHERE(FILE_TEST(MOVE_FILES) EQ 1, /NULL)]
                IF MOVE_FILES NE [] THEN FILE_MOVE, MOVE_FILES , L2_SUS, /OVERWRITE
                CONTINUE
              ENDIF
            ENDIF ELSE BEGIN ; ~FILE_TEST(L3B_AIF)
              IF HAS(L2LOG,'Read Error:') THEN BEGIN
                POS = WHERE(STRPOS(L2LOG,'Read Error:') EQ 0,COUNT)
                IF COUNT NE 1 THEN STOP
                RERR = L2LOG(POS)
                P1 = STRPOS(RERR,'(') & P2 = STRPOS(RERR,')')
                ERRFILE = STRMID(RERR,P1+1,P2-P1-1)
                ERR_TXT = [ERR_TXT, L2LOG, 'ERROR reading ' + ERRFILE]
              ENDIF ELSE GOTO, RERUN_ATTRIBUTES 
            ENDELSE  
            
            IF ANY(ERRFILE) THEN BEGIN
              OKSET = WHERE_MATCH(NEW_SET,ERRFILE,COUNT_SET,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=COUNT_SET)
              IF COUNT_SET GT 0 THEN NEW_SET = NEW_SET(COMPLEMENT) ELSE COUNT_SET = 0
            ENDIF ELSE COUNT_SET = N_ELEMENTS(NET_SET)
            IF COUNT_SET EQ 1 AND PREV_SET EQ 1 THEN COUNT_SET = 0
            PREV_SET = COUNT_SET
            IF COUNT_SET GT 0 THEN WRITE_TXT, L3B_PROCESS, NEW_SET ELSE BEGIN
              ERR_TXT = [ERR_TXT, 'No valid files to create ' + L3B_FILE]
              WRITE_TXT, L3B_ERROR, ERR_TXT
              IF EXISTS(L3B_PROCESS) THEN FILE_DELETE, L3B_PROCESS, /VERBOSE
              CONTINUE
            ENDELSE
            GOTO, RERUN_L3BPROCESS ; >>> Recreate the L2BIN step
          ENDFOR ; PRODS
        ENDFOR ; RES
      ENDFOR ; TAGS
  
      PROCESSING_LOOP = PROCESSING_LOOP + 1
      SCMDS = []
      IF ANY(PROCESS_L3) THEN BEGIN
        PLUN, LUN, ROUNDS(N_ELEMENTS(PROCESS_L3)) + ' L2BIN files for ' + DSET + ' remaining to process...'
        PROCESS_L3 =  PROCESS_L3[SORT(PROCESS_L3)]
        TOTAL_TO_PROCESS = [TOTAL_TO_PROCESS, PROCESS_L3]
        FOR I=0, N_ELEMENTS(PROCESS_L3)-1  DO PLUN, LUN, ROUNDS(I+1) + ': Need to process ' + PROCESS_L3[I], 0
        
        FOR R=0, N_ELEMENTS(RESO)-1 DO BEGIN
          RES = RESO[R]
          FOR S=0, N_ELEMENTS(SUITES)-1 DO BEGIN
  
            CD, !S.SCRIPTS + 'SEADAS' + SL
            SUITE = SUITES[S]
            DIR_TEST, DIR + 'L3B' + RES + SL + 'TEMP' + SL
  
            FILES = FLS(L3_PRO + PREFIX + '*' + SUITE + '.txt',COUNT=COUNTL2)
            IF COUNTL2 EQ 0 THEN CONTINUE
            L3_DIR = L3D + 'NC'  + SL + SUITE + SL
            L3_LOG = L3_DIR + 'LOGS' + SL
            L3_AIF = L3_DIR + 'ADD_IFILES' + SL
            FILESB = FLS([L3_AIF,L3_DIR] + PREFIX + '*.L3B' + RES + '_DAY_*.nc',COUNT=COUNT_BEFORE)
  
            COUNTER = 0
            IF !S.COMPUTER NE 'NECLNAMAC94512.LOCAL' THEN BEGIN
              REPEAT BEGIN
                PLUN, LUN, 'Checking servers...'
                SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NPROCESS,VERBOSE=COUNTER)
                IF SVRS EQ [] THEN BEGIN
                  PLUN, LUN, 'Unable to run ' + './process_L2_L3B_files.sh because too many  processes are currently running on all servers. (' + SYSTIME() + ')'
                  PLUN, LUN, 'Waiting 1 hour...',0
                  WAIT, 60*60
                  COUNTER = COUNTER + 1
                ENDIF ELSE COUNTER = 3     
              ENDREP UNTIL COUNTER GE 3
              
              IF SVRS EQ [] THEN BEGIN
                PLUN, LUN, 'ERROR: No servers available to run "process_L2_L3B_files.sh" in parallel"
                CD, !S.PROGRAMS
                CONTINUE
              ENDIF
              SERVER_STRING = ' -s ' + STRJOIN(SVRS,',')  
            ENDIF ELSE SERVER_STRING = ''
  
            RUN_L2BIN_CMD:
            SCMD = './process_L2_L3B_files.sh ' + '-d ' + DSET + ' -p ' + SUITE + ' -v ' + RES + SERVER_STRING 
            PLUN, LUN, 'Creating ' + ROUNDS(N_ELEMENTS(FILES)) + ' ' + SUITE + ' L3B files'
            PLUN, LUN, SCMD, 0
            SCMDS = [SCMDS,SCMD]
            IF KEY(RUN_L2BIN) THEN BEGIN  
              SPAWN, SCMD, L2LOG, L2ERR
              PLUN, LUN, 'Finished running the L2BIN step.', 0
  
              IF N_ELEMENTS(L2ERR) EQ 1 THEN IF HAS(L2ERR, 'too many arguments') THEN L2ERR = ''
  
              ; ===> Compile the L2BIN logs and error files
              IF N_ELEMENTS(L2LOG) GE 1 AND L2LOG[0] NE '' THEN L2BIN_LOG = [L2BIN_LOG,'','L2BIN log for '       + SUITE + ' at resolution ' + RES, L2LOG]
              IF N_ELEMENTS(L2ERR) GE 1 AND L2ERR[0] NE '' THEN L2BIN_ERR = [L2BIN_ERR,'','L2BIN error log for ' + SUITE + ' at resolution ' + RES, L2ERR]
  
              FILESA = FLS([L3_AIF,L3_DIR] + PREFIX + '*.L3B' + RES + '_DAY_*.nc',COUNT=COUNT_AFTER)
              IF COUNT_AFTER GT COUNT_BEFORE THEN BEGIN
                PLUN, LUN, NUM2STR(COUNT_AFTER-COUNT_BEFORE) + ' new L3B files were created for ' + SUITE
                OK = WHERE_MATCH(FILESA,FILESB,COUNT_MATCH,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
                IF NCOMPLEMENT GT 0 THEN BEGIN
                  PLUN, LUN, FILESA(COMPLEMENT)  + ' created on ' + DATE_NOW(/DATE_ONLY),0
                  FILES_AFTER = [FILES_AFTER, FILESA(COMPLEMENT)]
                ENDIF
              ENDIF ELSE PLUN, LUN, 'No new L3B files were created for ' + SUITE
              CD, !S.PROGRAMS
            ENDIF ; ~KEY(RUN_L2BIN)
          ENDFOR ; SUITES
        ENDFOR ; RESOLUTION
        IF PROCESSING_LOOP LE 2 AND KEYWORD_SET(RUN_L2BIN) THEN GOTO, RERUN                 ; Rerun if new files were created so that files in the ADD_IFILES directory can be updated
        IF FILES_AFTER EQ [] THEN PLUN, LUN, 'No new L3B files were created'  
      
      ENDIF ELSE BEGIN ; ANY(L3_PROCESS)
        PLUN, LUN, 'No files to process through L2BIN ...' ; ANY(PROCESS_L3)
        FILESA = FLS(L3_AIF + PREFIX + '*.L3B' + RES + '_DAY_*.nc',COUNT=COUNT_AFTER)
        IF COUNT_AFTER GT 1 AND PROCESSING_LOOP LE 2 THEN GOTO, RERUN
      ENDELSE

      ASUSPECT = FILE_SEARCH(L2_SUS + PREFIX + '*' + SUFFIX[X],COUNT=SUSPECT_AFTER)
      IF SUSPECT_AFTER GT SUSPECT_BEFORE THEN BEGIN
        PLUN, LUN, NUM2STR(COUNT_AFTER-COUNT_BEFORE) + ' L2 files were identified as "SUSPECT" '
        OK = WHERE_MATCH(ASUSPECT,BSUSPECT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
        IF NCOMPLEMENT GT 0 THEN BEGIN
          PLUN, LUN, 'Check new suspect file: ' + BSUSPECT(COMPLEMENT)
          DSUSP = [DSUSP, BSUSPECT(COMPLEMENT)]
        ENDIF
      ENDIF
      
      ; ===> Compile the L2BIN logs and error files for each DATASET/SENSOR
      IF L2BIN_LOG NE []   THEN DLOGS = [DLOGS,'','L2BIN logs for '       + DSET, L2BIN_LOG]
      IF L2BIN_ERR NE []   THEN DERRS = [DERRS,'','L2BIN error logs for ' + DSET, L2BIN_ERR]
      IF FILES_AFTER NE [] THEN DAFTR = [DAFTR,'','New files for '        + DSET, FILES_AFTER]  
      
      ENDFOR ; SUFFIX
      
      PLUN, LUN, 'Closing BATCH_SEADAS log file for ' + DATASET + ' on: ' + systime()
      FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
      IF KEY(EMAIL_ALL) THEN EATT = [EATT,LOG_FILE]
      CD, !S.PROGRAMS
    
  ENDFOR ; DATASETS
  LUN = []
  
  ; Set up files to be emailed
  IF DLOGS NE [] AND KEY(EMAIL_ALL) THEN BEGIN
    L2TEMP_LOG = !S.IDL_TEMP + 'TEMP_L2BIN.txt'
    WRITE_TXT,L2TEMP_LOG, DLOGS
    EATT = [EATT,L2TEMP_LOG]
  ENDIF
  IF DERRS NE [] THEN BEGIN
    L2TEMP_ERR = !S.IDL_TEMP + 'TEMP_L2ERR.txt'
    WRITE_TXT,L2TEMP_ERR, DERRS
    EATT = [EATT,L2TEMP_ERR]
  ENDIF
  IF DAFTR NE [] THEN BEGIN
    L3BTEMP_FILES = !S.IDL_TEMP + 'TEMP_L3B_FILES.txt'
    WRITE_TXT,L3BTEMP_FILES, DAFTR
    EATT = [EATT, L3BTEMP_FILES]
  ENDIF
  IF NSUSP NE [] THEN BEGIN
    L3BTEMP_SUS = !S.IDL_TEMP + 'TEMP_L2_SUSPECT.txt'
    WRITE_TXT, L3BTEMP_SUS, DSUSP
    EATT = [EATT, L3BTEMP_SUS]
  ENDIF
  
  ATT = []
  FOR I=0, N_ELEMENTS(EATT)-1 DO ATT = [ATT, ' -a ' + EATT(I)]
  IF ATT NE [] THEN BEGIN
    SPAWN, 'echo -e "Finshed BATCH_SEADAS_L2BIN for on: ' + SYSTIME() + '" | mailx -s "Finished BATCH_SEADAS_L2BIN ' + SYSTIME() + '" ' + ATT + ' ' + MAILTO
    TMP = EATT[WHERE(HAS(EATT,'TEMP') EQ 1,/NULL)]
    IF TMP NE [] THEN FILE_DELETE, TMP ; Delete temporary files
  ENDIF ; EMAIL_ATTACHMENTS
  
  FOR I=0, N_ELEMENTS(TOTAL_TO_PROCESS)-1  DO PLUN, LUN, ROUNDS(I+1) + ': Need to process ' + TOTAL_TO_PROCESS[I], 0
  IF ~KEY(RUN_L2BIN) THEN PLUN, LUN, SCMDS
  
END
