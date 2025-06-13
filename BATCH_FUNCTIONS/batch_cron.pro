; $ID:	BATCH_CRON.PRO,	2023-09-21-13,	USER-KJWH	$

PRO BATCH_CRON, DATECRON

;+
; NAME:
;   BATCH_CRON
;   
; PURPOSE: 
;   This is a wrapper program to run BATCH_L2 and BATCH_L3 from the cron job.
;
; CATEGORY:
;   BATCH FUNCTIONS
;   
; CALLING SEQUENCE:
;   BATCH_CRON
;   
; REQUIRED INPUTS:
;   None
; 
; OPTIONAL INPUTS:
;   None
; 
; KEYWORD PARAMETERS:
;   None
; 
; OUTPUTS:
;   The outputs from the various batch processing steps
;   
; COMMON BLOCKS:
;   None
;   
; SIDE EFFECTS:
;   May need to be updated as other batch processing programs are updated
;   
; RESTRICTIONS:
;   This program runs daily and should be set up to based on the current processing needs
;   
; EXAMPLE:
; 
; NOTES:
;   The HAS logical function governs which processing steps to do and what to do in the step
;     '' = (DO NOT DO THE STEP)
;   Any one or any combination of these letters [in any order]:  Y, O, V, RD, RF, RM, S, E, F will start the step
;     Y  = YES do the step
;     O  = OVERWRITE any output
;     V  = VERBOSE [allow print statements]
;     RF = Reverse the processing order of the FILES in the step
;     RD = Reverse the processing order of the DATASETS in the step
;     RM = Reverse the processing order of the MAPS in the step
;     S  = STOP at the beginning of the step and step through each command in the step
;     E  = STOP the at the end of the step
;     F  = Process only the first four files
;
; COPYRIGHT:
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on Novemeber 16, 2015 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882

; MODIFICATION HISTORY:
;   APR 06, 2016 - KJWH: Added step to update the SeaDAS luts
;   OCT 04, 2016 - KJWH: Removed UPDATE_LUTS step (not necessary)
;   AUG 24, 2017 - KJWH: Added BATCH_L3, DO_D3 steps
;   NOV 15, 2018 - KJWH: Added L3_PAR (parallel) steps
;   NOV 19, 2018 - KJWH: Added a step in L3_PAR to determine if the dataset is currently being processed, if so skip in order to avoid duplicate processes on the same files
;   NOV 30, 2018 - KJWH: Now sending multiple BATCH_L3 commands to BATCH_L3_PARALLEL
;   DEC 03, 2019 - KJWH: Added PLOT_FILELIST to determine if new files were created and if so, include them in the attachments
;                        Now writing a temporary text file for the main body of the email message
;   NOV 15, 2021 - KJWH: Updated documentation and formatting
;                        Moved to BATCH_FUNCTIONS
;                        Removed ERROR_LOG keyword (not used)
;                        Removed DATE input (should use the current date)
;                        Added COMPILE_OPT IDL2
;                        Changed subscrtip () to []
;                        Updated defaults to reflect that there are fewer restrictions on downloading files
;                        Updated Downloading scripts
;                        Removed the steps to identify weekends and holidays (no longer needed)
;
;-
; *******************************************************************************************************************************
  ROUTINE_NAME='BATCH_CRON'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
; ===> Set up basic information  
  MAILTO = 'kimberly.hyde@noaa.gov'                               ; Email address(es) to send the output and error logs to
  SERVERS = ['satdata','luna'];,'modis']                          ; The servers to use for parallel processing
  ATTACH = []                                                     ; Create a null array for the attachements

  
; ===> Set up the date information  
  DP = DATE_PARSE(DATE_NOW()) & DOW = STRUPCASE(DP.DOW) & MON = STRUPCASE(DP.MON) & DAY = DP.DAY
  DATE = STRMID(DATE_NOW(),0,10)
;  IF DATE NE DATECRON THEN MESSAGE, 'ERROR: Check dates...'
  
; ===> Create the log directories and log files  
  LOG_DIR = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL
  YR_DIR  = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + STRMID(DATE,0,4) + SL 
  DAY_DIR = !S.LOGS + 'IDL_' + ROUTINE_NAME + SL + STRMID(DATE,0,4) + SL + STRMID(DATE,0,8) + SL & DIR_TEST, DAY_DIR
  
  CRON_LOG = LOG_DIR + 'cron_log-'   + DATE + '.log'
  CRON_TXT = LOG_DIR + 'cron_log-'   + DATE + '.txt'
  ERR_TEST = LOG_DIR + 'cron_error-' + DATE + '.txt'
  LUN    = []                                                     ; Create a null LUN for future PLUN calls
 
; ===> Write basic info to the log file  
  PLUN, LUN, '******************************************************************************************************************'
  PLUN, LUN, 'Starting ' + ROUTINE_NAME + ' log file: ' + CRON_LOG + ' on: ' + systime() + ' on ' + !S.COMPUTER, 0
  PLUN, LUN, 'PID=' + GET_IDLPID() ; ***** NOTE, may not be accurate with IDLDE sessions *****
  PLUN, LUN, '******************************************************************************************************************'    
  PLUN, LUN, 'Starting BATCH_CRON at ' + DP.DASH_DATE + ' ' + DP.TIME_HHMM
  FOR S=0, N_ELEMENTS(SERVERS)-1 DO PLUN, LUN, 'Processing on server: ' + SERVERS[S], 0
    
; ===> Check for any error files, if none exist, create a temporary place holder error file  
  PLUN, LUN, 'Checking for the ERROR file and if present, email...'
  IF FILE_TEST(ERR_TEST) AND FILE_TEST(CRON_LOG) THEN BEGIN    
    FILE_COPY, CRON_LOG, ERR_TEST, /OVERWRITE                                             ; Create a copy of log file and rename it the ERR_TEST name
    ERR = READ_TXT(ERR_TEST)                                                              ; Read the log file and add ERROR statements
    ERR = ['***** ERROR while running BATCH_CRON on ' + DATE + ' *****','','',ERR, '', '', '***** ERROR while running BATCH_CRON on ' + DATE + ' *****']
    IF N_ELEMENTS(ERR) GT 100 THEN ERR = [ERR[0:5],REPLICATE('.',10),ERR[-100:-1]]        ; Subset the log file so tht it only includes to bottom portion of the file that contains the error message
    WRITE_TXT, ERR_TEST, ERR                                                              ; Rewrite the updated log/error file
    CMD = 'echo "' + ERR[0] + ' Check log file - ' + CRON_LOG + '. ' + '" | mailx -s "ERROR - Cron processing "' + DATE_NOW() + ' -a ' + ERR_TEST + ' ' + MAILTO    
    SPAWN, CMD, LOG, ERROR                                                                ; Spawn the command to email the log/error file 
    FILE_DELETE, ERR_TEST
  ENDIF ELSE WRITE_TXT, ERR_TEST, 'Temp file to look for errors in the BATCH_CRON processing.  If the file exists, then an error occurred when running BATCH_CRON at ' + DATE
  
  
  
; ===> Set up processing switches  
  
  DWLD_L2    = ''
  DWLD_L3    = ''
  L2GEN      = ''
  L2BIN      = ''
  L3_PAR     = ''
  WGET_OCCCI = ''

  CASE DP.HOUR OF
    '00': BEGIN
      DWLD_L3  = 'Y'
      DWLD_L2  = 'Y'
      L2GEN    = 'Y'
      L2BIN    = 'Y'
      L3_PAR   = ''
    END
    '06': BEGIN
      L3_PAR   = ''
    END
    '12': BEGIN
      DWLD_L3  = 'Y'
      L3_PAR   = ''
    END
    '18': BEGIN
      DWLD_L2  = 'Y'     
      L2GEN    = 'YRF'
      L2BIN    = 'YRF'
      L3_PAR   = ''
      WGET_OCCCI = 'Y'
    END
    ELSE: BEGIN
      DWLD_L2  = ''
      DWLD_L3  = ''
      L2GEN    = ''
      L2BIN    = 'Y'
      L3_PAR   = ''
      FULL_DATERANGE = 0
    END  
  ENDCASE  


  IF NONE(FULL_DATERANGE) THEN BEGIN
    CASE DOW OF 
      'TUE': FULL_DATERANGE = 1
      'THU': FULL_DATERANGE = 0
      'SAT': FULL_DATERANGE = 1 
      ELSE:  FULL_DATERANGE = 0
    ENDCASE  
  ENDIF ELSE FULL_DATERANGE = 0
  IF NONE(CLIMATOLOGY) THEN BEGIN
    IF KEY(FULL_DATERANGE) AND DOW EQ 'FRI' THEN CLIMATOLOGY = 1 ELSE CLIMATOLOGY = 0
  ENDIF ELSE CLIMATOLOGY = 0
  
  IF DOW NE 'FRI' THEN WGET_OCCCI = ''  ; Only look for the OCCCI files on Fridays
  IF ODD(DP.DAY) AND L3_PAR NE '' THEN L3_PAR = REPLACE(L3_PAR,'Y','YRY') 
  
  IF KEYWORD_SET(WGET_OCCCI) THEN BEGIN
    DWLD_ESA_OCCCI_1KM, /RECENT
    DWLD_ESA_OCCCI, /RECENT
    DWLD_AVHRR_SST, /RECENT
    DWLD_GLOBCOLOUR,/RECENT
    DWLD_MUR_SST,   /RECENT
  ENDIF
    
  IF KEYWORD_SET(DWLD_L2) OR KEYWORD_SET(DWLD_L3) THEN BEGIN ;'OC-JPSS1-1KM',
    PLUN, LUN, 'Starting BATCH_DOWNLOADS ' + SYSTIME()   
    LASTDAYS = JD_2DATE(JD_ADD(DP.JD,-180,/DAY))
    IF KEY(DWLD_L2) THEN DWLD_NASA_L1A, ['MODISA','VIIRS','JPSS1','SMODISA','SMODIST','SMODISA_NRT','SMODIST_NRT','MODIST'], DATERANGE=DATERANGE
    IF ANY(ATTACHMENTS) THEN ATTACH = [ATTACH,ATTACHMENTS]
    IF KEY(DWLD_L3) THEN DWLD_MUR_SST, /RECENT
    IF ANY(ATTACHMENTS) THEN ATTACH = [ATTACH,ATTACHMENTS]
    
    PLUN, LUN, 'Done runnig BATCH_DOWNLOADS ' + SYSTIME()  
    
  ENDIF
    

; ===> Create the L2 files
  IF KEYWORD_SET(L2GEN) THEN BEGIN 
    PLUN, LUN, 'Starting L2GEN step ' + SYSTIME()
    SW = L2GEN
    SWITCHES,SW,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,NPROCESS=NPROCESS,R_YEAR=R_YEAR,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    
    IF NONE(DATASETS) THEN DATASETS = ['MODISA VIIRS JPSS1 SEAWIFS'] ELSE DATASETS = STRJOIN(DATASETS,' ')
    BATCH_SEADAS_L1A, STRSPLIT(DATASETS,' ',/EXTRACT), /GET_ANC, RUN_L2GEN=0    ; Set up the files that need to be processed, but don't spawn the L2GEN processing step
    
    IF KEYWORD_SET(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    IF ~N_ELEMENTS(NPROCESS) THEN NP = 6 ELSE NP = NPROCESS
    SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NP,/VERBOSE)    ; Determine the number of processes to run on each server
    IF SVRS NE [] THEN BEGIN
      SCMD = './process_L1A_L2_files.sh -i -g -d ' + '"' + DATASETS + '"'+ ' -s ' + STRJOIN(SVRS,',')     ; Command to run the L
      IF KEYWORD_SET(R_FILES) THEN SCMD = SCMD + ' -r'
      IF SCMD NE '' THEN BEGIN
        CD, !S.SCRIPTS + 'SEADAS' + SL
        PLUN, LUN, 'Starting L2GEN processing...'
        PLUN, LUN, SCMD, 0
        SPAWN, SCMD, L2GEN_TXT, L2GEN_ERR
        PLUN, LUN, 'Finished L2GEN processing.'
        CD, !S.PROGRAMS
      ENDIF  
    ENDIF  
    
    BATCH_SEADAS_L1A, STRSPLIT(DATASETS,' ',/EXTRACT), GET_ANC=0, RUN_L2GEN=0    ; Check the files that were generated during the L2GEN processing step
    PLUN, LUN, 'Done runnig L2GEN step ' + SYSTIME()  
  ENDIF
  
; ===> Create the L3B2 files  
  IF KEY(L2BIN) THEN BEGIN
    PLUN, LUN, 'Starting L2BIN step ' + SYSTIME()
    SW = L2GEN
    SWITCHES,SW,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,NPROCESS=NPROCESS,R_YEAR=R_YEAR,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF NONE(DATASETS) THEN DATASETS = ['MODISA MODIST VIIRS JPSS1 SEAWIFS SMODISA SMODIST SMODISA11D SMODIST11D'] ELSE DATASETS = STRJOIN(DATASETS,' ')
    BATCH_SEADAS_L2BIN,  STRSPLIT(DATASETS,' ',/EXTRACT)
    
    IF NONE(NPROCESS) THEN NP = 6 ELSE NP = NPROCESS
    SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NP,/VERBOSE)
    IF SVRS NE [] THEN BEGIN
      SCMD = './process_L2_L3B_files.sh ' + '-i -d ' + '"' + DATASETS + '" -s ' + STRJOIN(SVRS,',')     
      IF KEY(R_FILES) THEN SCMD = SCMD + ' -r'
      IF SCMD NE '' THEN BEGIN
        CD, !S.SCRIPTS + 'SEADAS' + SL
        PLUN, LUN, 'Starting L2BIN processing...'
        PLUN, LUN, SCMD, 0
        SPAWN, SCMD, L2BIN_TXT, L2GBIN_ERR
        PLUN, LUN, 'Finished L2BIN processing.'
        CD, !S.PROGRAMS
      ENDIF  
    ENDIF

    PLUN, LUN, 'Done running L2BIN step ' + SYSTIME()
  ENDIF
    
    
; ===> Steps to run BATCH_L3 in parallel      
  IF KEY(L3_PAR) THEN BEGIN 
    PLUN, LUN, 'Starting BATCH_L3  ' + SYSTIME()
    SW = L3_PAR
    SWITCHES,SW,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,NPROCESS=NPROCESS,R_PRODS=R_PRODS,DPRODS=D_PRODS,R_YEAR=R_YEAR,DMAPS=D_MAPS,DPERIODS=D_PERIODS,DATERANGE=DATERANGE,DATASETS=DATASETS
    IF NONE(DATASETS) THEN BEGIN
      DATASETS = ['MODISA','MODIST','SEAWIFS','VIIRS','JPSS1','MUR'];'SST-MODISA','SST-MODIST','AT','PP-MODISA','PP-SEAWIFS','PP-VIIRS','PP-JPSS1','SA','PP-SA','SAV','SAVJ','PP-SAV','PP-SAVJ','MUR'] ; 'PP-VIIRS','SAV','PP-SAV', 
      IF DOW EQ 'SAT' THEN DATASETS = [DATASETS,'OCCCI','GLOBCOLOUR','PP-OCCCI','AVHRR'] ; 'OCCCI',; ONLY RUN AVHRR, SEAWIFS & OCCCI ONCE A WEEK
    ENDIF ; DATASETS
    IF KEY(R_DATASETS) THEN DATASETS = REVERSE(DATASETS)
    CMDS = []
    MAXYR = 0
    FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
      DT = DATASETS(D)
      IF KEY(FULL_DATERANGE) THEN SD = STRMID(SENSOR_DATES(REPLACE(DT,['PP-','SST-'],['',''])),0,4) $
                             ELSE SD = [NUM2STR(DP.YEAR-1),DP.YEAR] ; Only process the previous and current year
      DR = STRJOIN([SD[0],SD[1]],'_')
      YR = N_ELEMENTS(YEAR_RANGE(SD[0],SD[1]))
      IF YR GT MAXYR THEN MAXYR = YR
      
      MAKE_PRODS = "DO_MAKE_PRODS=''"
      PPD        = "DO_PPD=''"
      OCCCI      = "DO_OCCCI=''"
      GHRSST     = "DO_GHRSST=''"
      CD3        = "DO_D3=''"
      D3         = ''

      CASE DT OF
        'VIIRS':      BEGIN & SPRODS=['NC_CHL','PSIZET','PHYPERT','NC_PHYTO','NC_PAR']  & MAKE_PRODS="DO_MAKE_PRODS='"+SW+"["+DT+"]'" & END
        'JPSS1':      BEGIN & SPRODS=['NC_CHL','PSIZET','PHYPERT','NC_PHYTO','NC_PAR']  & MAKE_PRODS="DO_MAKE_PRODS='"+SW+"["+DT+"]'" & END
        'OCCCI':      BEGIN & SPRODS=['NC_CHL','PSIZET','PHYPERT','NC_PHYTO','NC_PAR']  & MAKE_PRODS="DO_MAKE_PRODS='"+SW+"["+DT+"]'" & OCCCI="DO_OCCCI='Y'" & END
        'GLOBCOLOUR': BEGIN & SPRODS=['CHLS'] & GLOBCOLOUR="DO_GLOBCOLOUR='Y'" & END
        'MODISA':     BEGIN & SPRODS=['CHLS','NC_CHL','PHSIZE','NC_PHYTO','NC_PAR']  & MAKE_PRODS="DO_MAKE_PRODS='"+SW+"["+DT+"]'" & END
        'SST-MODISA': BEGIN & SPRODS=['NC_SST'] & END
        'SST-MODIST': BEGIN & SPRODS=['NC_SST'] & END
        'SEAWIFS':    BEGIN & SPRODS=['CHLS','NC_CHL','PSIZET','PHYPERT','NC_PHYTO','NC_PAR']  & MAKE_PRODS="DO_MAKE_PRODS='"+SW+"["+DT+"]'" & END
        'SA':         BEGIN & SPRODS=['CHLS','NC_CHL','NC_PHYTO'] & END
        'SAV':        BEGIN & SPRODS=['CHLS','NC_CHL','NC_PHYTO'] & END
        'SAVJ':       BEGIN & SPRODS=['CHLS','NC_CHL','NC_PHYTO'] & END
        'MUR':        BEGIN & GHRSST="DO_GHRSST='Y[MUR]'"    & SPRODS=['SST'] & END
        'AVHRR':      BEGIN & GHRSST="DO_GHRSST='Y[AVHRR]'"  & SPRODS=['SST'] & IF KEY(DO_D3) THEN D3='Y' & END
        'PP-SEAWIFS': BEGIN & PPD="DO_PPD='"+SW+"[SEAWIFS]'" & SPRODS=['PPD'] & END
        'PP-MODISA':  BEGIN & PPD="DO_PPD='"+SW+"[MODISA]'"  & SPRODS=['PPD'] & END
        'PP-VIIRS':   BEGIN & PPD="DO_PPD='"+SW+"[VIIRS]'"   & SPRODS=['PPD'] & END
        'PP-JPSS1':   BEGIN & PPD="DO_PPD='"+SW+"[JPSS1]'"   & SPRODS=['PPD'] & END
        'PP-OCCCI':   BEGIN & PPD="DO_PPD='"+SW+"[OCCCI]'"   & SPRODS=['PPD'] & END
        'PP-SA':      BEGIN & SPRODS=['PPD'] & END
        'PP-SAV':     BEGIN & SPRODS=['PPD'] & END
        'PP-SAVJ':    BEGIN & SPRODS=['PPD'] & END
        ELSE:    SPRODS = ['']
      ENDCASE
      IF KEY(R_PRODS) THEN SPRODS = REVERSE(SPRODS)
      FOR R=0, N_ELEMENTS(SPRODS)-1 DO BEGIN
        SPROD = SPRODS(R)
        ANOM  = "DO_ANOMS=''"
        FRONT = "DO_FRONTS=''"
        STATF = "DO_STAT_FRONTS=''"
        CASE SPROD OF
          'NC_RRS':   BEGIN & PERS='PER=MIN.WK' & END
          'NC_PAR':   BEGIN & PERS='PER=MIN.WK.DOY.D8' & END
          'NC_CHL':   BEGIN & PERS='PER=STD'    & ANOM="DO_ANOMS='"+SW+"["+DT+";P=CHLOR_A-OCI]'" & FRONT="DO_FRONTS='"+SW+"["+DT+"]'" & STATF="DO_STAT_FRONTS='"+SW+"["+DT+"]'" & END
          'NC_PHYTO': BEGIN & PERS='PER=MIN.WK' & ANOM="DO_ANOMS='"+SW+"["+DT+";P=PHYTO]'"                   & END
          'PHSIZE':   BEGIN & PERS='PER=MIN.WK' & ANOM="DO_ANOMS='"+SW+"["+DT+";P=PHYTO]'"                   & END
          'CHLS':     BEGIN & PERS='PER=STD'    & ANOM="DO_ANOMS='"+SW+"["+DT+";P=MIN_CHL]'"                 & END
          'PPD':      BEGIN & PERS='PER=STD'    & ANOM="DO_ANOMS='"+SW+"["+DT+";P=MIN_PP]'"                  & END
          'SST':      BEGIN & PERS='PER=STD'    & ANOM="DO_ANOMS='"+SW+"["+DT+";P=SST]'"  & FRONT="DO_FRONTS='"+SW+"["+DT+"]'" & STATF="DO_STAT_FRONTS='"+SW+"["+DT+"]'" & END
          'NC_SST':   BEGIN & FRONT="DO_FRONTS='"+SW+"["+DT+"]'" & END
          ELSE:       BEGIN & PERS='PER=MIN' & END
        ENDCASE
 
FRONT = "DO_FRONTS=''"
STATF = "DO_STAT_FRONTS=''"
   
        IF KEY(CLIMATOLOGY) THEN BEGIN
          PLUN, 'Adding CLIMATOLOGY stats and ANOMS to batch command'
          PERS = PERS + '.CLIM'
        ENDIF ELSE ANOM = "DO_ANOMS=''"  ; Only run DO_ANOMS step after running the climatology stats
   
        STAT = "DO_STATS='"+SW+"[" + DT + ";" + PERS + ";P=" + SPROD+"]'"
        IF KEY(D3) THEN IF HAS(SPROD,'CHL') THEN CD3="DO_D3='"+SW+"["+DT + "]'"
        IF KEY(D3) THEN IF DT EQ 'AVHRR'    THEN CD3="DO_D3='"+SW+"["+DT + "]'"
        
        IF R GT 0 THEN BEGIN
          MAKE_PRODS = "DO_MAKE_PRODS=''"
          PPD        = "DO_PPD=''"
          OCCCI      = "DO_OCCCI=''"
          GHRSST     = "DO_GHRSST=''"
          CD3        = "DO_D3=''"
        ENDIF
        
        CMD = "BATCH_L3," + STRJOIN([OCCCI,GHRSST,MAKE_PRODS,CD3,PPD,STAT,ANOM,FRONT,STATF],',') + ",BATCH_DATASET='" + DT + "',BATCH_DATERANGE='" + DR + "'"
        CMD = REPLACE(CMD,["DO_MAKE_PRODS=''","DO_PPD=''","DO_OCCCI=''","DO_GHRSST=''","DO_D3=''","DO_STATS=''","DO_ANOMS=''","DO_FRONTS=''","DO_STAT_FRONTS=''"],['','','','','','','','',''])
        WHILE HAS(CMD,',,') DO CMD=REPLACE(CMD,',,',',')
        CMDS = [CMDS,CMD]
      ENDFOR ; PRODS
      PLUN, [], 'Running BATCH_L3 for ' + DT + ': ' + DR, 0
    ENDFOR ; DATASETS
    
    NP = 1
    WHILE NP*N_ELEMENTS(SERVERS) LT MAXYR DO NP = NP + 1  
    IF ANY(NPROCESS) THEN NP = NPROCESS
    PLUN, [], 'Starting BATCH_L3_PARALLEL at ' + SYSTIME(),1         
    IF CMDS NE [] THEN BATCH_L3_PARALLEL, CMDS, SERVERS=SERVERS, NPROCESS=NP, R_YEAR=R_YEAR      
    PLUN, [], 'Finished BATCH_L3_PARALLEL at ' + SYSTIME(),1   
    CLOSE,/ALL 
  ENDIF
  
  PLUN, LUN, 'Starting PLOT_FILELIST step ' + SYSTIME()
  PLOT_FILELIST, LOGLUN=LUN, PLT_FILES=PLT_FILES, TXT_FILES=TXT_FILES
  IF ANY(PLT_FILES) THEN ATTACH = [ATTACH,PLT_FILES] 
  IF ANY(TXT_FILES) THEN ATTACH = [ATTACH,TXT_FILES]

  IF EXISTS(CRON_LOG) THEN BEGIN
    FILE_COPY, CRON_LOG, CRON_TXT
    ATT = ' -a ' + CRON_TXT
  ENDIF ELSE ATT = []  
  
  FOR A=0, N_ELEMENTS(ATTACH)-1 DO ATT = [ATT, ' -a ' + ATTACH[A]]
  TXT = 'BATCH_CRON finished on ' + DATE_NOW(/DATE_ONLY) 
  TXT = [TXT, '']
  TXT = [TXT, 'ATTACHMENTS (n=' + NUM2STR(N_ELEMENTS(ATTACH)) + ')']
  IF ANY(ATTACH) THEN TXT = [TXT,ATTACH]
  TEMP_FILE = !S.IDL_TEMP + 'TEMP_CRON_TEXT.txt'
  WRITE_TXT, TEMP_FILE, TXT
  
;  CMD = 'echo "BATCH_CRON finished on ' + DATE_NOW(/DATE_ONLY) + '" | mailx -s "Cron processing ' + SYSTIME() + '" ' + ATT + ' ' + MAILTO
  IF ANY(ATT) THEN CMD = 'cat ' + TEMP_FILE + ' | mailx -s "Cron processing ' + SYSTIME() + '" ' + STRJOIN(ATT,' ') + ' ' + MAILTO $
              ELSE CMD = 'cat ' + TEMP_FILE + ' | mailx -s "Cron processing ' + SYSTIME() + '" ' + MAILTO

  SPAWN, CMD
  IF EXISTS(CRON_TXT) THEN FILE_DELETE, CRON_TXT
  IF EXISTS(TEMP_FILE) THEN FILE_DELETE, TEMP_FILE


  PRINT, '**** BATCH_CRON FINISHED ON ' + DATE_NOW(/DATE_ONLY) + ' *****'
  IF EXISTS(ERR_TEST) THEN FILE_DELETE, ERR_TEST
  IF EXISTS(CRON_LOG) THEN FILE_MOVE, CRON_LOG, DAY_DIR

  DONE:
    
END      
