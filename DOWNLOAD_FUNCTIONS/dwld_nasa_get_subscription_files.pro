; $ID:	DWLD_NASA_GET_SUBSCRIPTION_FILES.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DWLD_NASA_GET_SUBSCRIPTION_FILES, DATASET, LOG_DIR=LOG_DIR, ORDER_LIST=ORDER_LIST, LOGLUN=LOGLUN, LOGFILE=LOGFILE

;+
; NAME:
;   DWLD_NASA_GET_SUBSCRIPTION_FILES
;
; PURPOSE:
;   Get the list of files and checksums from the NASA OBPG subscriptions
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DWLD_NASA_GET_SUBSCRIPTION_FILES(DATASET)
;
; REQUIRED INPUTS:
;   DATASET.......... The name of a NASA subscription dataset
;
; OPTIONAL INPUTS:
;   LOG_DIR.......... The output directory for the log file
;   ORDER_LIST....... The fullname of the file containing the master list of files to download
;   LOGLUN........... The LUN for the log file
;   LOGFILE.......... The name of the log file
;
; KEYWORD PARAMETERS:
;   
;
; OUTPUTS:
;   OUTPUT........... A structure containing the names and checksums of the subscription files
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
;   Dec 14, 2020 - KJWH: Added LOG_DIR and ORDER_LIST input variables
;   Dec 15, 2020 - KJHW: Now returning [] if DATASET is not recognized
;   Apr 08, 2021 - KJWH: Updated to add the MODIS SST 11UM "dataset"
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NASA_GET_SUBSCRIPTION_FILES'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  OC_SEARCH = 'https://oceandata.sci.gsfc.nasa.gov/api/file_search.cgi'                             ; Search location for the NASA files
  OC_GET    = 'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/'                                     ; Location of the files

  
  IF N_ELEMENTS(DATASET) NE 1 THEN MESSAGE, 'ERROR: Must provide a single DATASET input.'
  IF N_ELEMENTS(LOGLUN) NE 1 THEN LUN = [] ELSE LUN = LOGLUN
  
  DATASET = STRUPCASE(DATASET)
  CASE DATASET OF
    'MODISA':       IDS='1689'
    'MODIST':       IDS='2818'
    'SMODISA':      IDS=['1147','2847','2848']
    'SMODIST_NRT':  IDS=['2841','2842'] 
    'SMODIST':      IDS=['1148','2845','2846']
    'SMODIST_NRT':  IDS=['2843','2844']
    'VIIRS':        IDS='1690' 
    'JPSS1':        IDS='2297'
    ELSE: BEGIN
      PLUN, LUN, 'ERROR: ' + DATASET + ' is not a recognized DATASET.' 
      RETURN, []
    END  
  ENDCASE

; ===> Set up LOG directory and file names
  IF N_ELEMENTS(LOG_DIR) EQ 1 THEN BATCH_LOG_DIR = LOG_DIR ELSE BATCH_LOG_DIR = !S.LOGS + 'IDL_DOWNLOADS' + SL + DATASET + SL & DIR_TEST, BATCH_LOG_DIR  ; Output directory for the log files and temporary checksum files
  IF N_ELEMENTS(ORDER_LIST) EQ 1 THEN L1_ORDER_LIST = ORDER_LIST ELSE L1_ORDER_LIST = !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + DATASET + '.txt' ; Master file with the 1km list of files to download
  IF ~FILE_TEST(L1_ORDER_LIST) THEN MESSAGE, 'ERROR: ' + L1_ORDER_LIST + ' does not exist.'


  FILELIST_CHECKSUMS = 'FILELIST_CHECKSUMS.txt'
  IF N_ELEMENTS(LOGFILE) NE 1 THEN LOGFILE = BATCH_LOG_DIR + DATASET + '_' + DATE_NOW(/DATE_ONLY) + '.log'

; ===> Create a NASA OBPG specific wget search command based on the subscription ID
  SUBLIST = [] & SUBSUMS = []
  FOR N=0, N_ELEMENTS(IDS)-1 DO BEGIN
    ID = IDS[N]
    IF ID EQ '' THEN GOTO, SKIP_ID_SEARCH
    PATTERN = 'subID='+ID                                                                      
    CMD = 'wget --tries=3 --post-data="'+PATTERN+'&results_as_file=1&cksum=1&std_only=1" -O - '+OC_SEARCH+' > ' + FILELIST_CHECKSUMS + ' -a ' + LOGFILE
    CMD = CMD + ' | wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --no-check-certificate --content-disposition -i -'   ; Add NASA specifics to the CMD
  
    COUNTER = 0
    WHILE COUNTER LT 3 DO BEGIN                                                                                 ; Set up a loop to try the wget command 3 times before exiting
      IF COUNTER GT 0 THEN WAIT, 60*1                                                                           ; Wait 1 minute before trying again
      COUNTER = COUNTER + 1

; ===> Run the wget command that will search for the available files
      CD, BATCH_LOG_DIR                                                                                         ; Change the directory to the IDL_BATCH_DOWNLOADS sub directory
      PLUN, LUN, CMD
      SPAWN, CMD, RES, ERR                                                                                      ; "Spawn" the wget command
  
; ===> Check the output of the wget command  
      PLUN, LUN, 'Reading: ' + FILELIST_CHECKSUMS
      CLIST = READ_TXT(FILELIST_CHECKSUMS)                                                                      ; Read the output FILE_CHECKSUMS file
      IF CLIST NE [] THEN BEGIN
        IF STRMID(CLIST[0],0,2) EQ '<!' OR CLIST EQ [] THEN BEGIN                                               ; If no remote server files are found, the file will start with <!
          PLUN, LUN, 'ERROR: No valid files found on remote server'
          PLUN, LUN, CLIST, 0
          CONTINUE
        ENDIF
        IF STRMID(CLIST[0],0,10) EQ 'Your query' THEN BEGIN                                                     ; L3b searches return a text string as the first line that must be removed
          CLIST = CLIST[1:*]                                                                                    ; Remove the first text line from the list
          CLIST = CLIST[WHERE(CLIST NE '',/NULL)]                                                               ; Remove any blank lines
          IF CLIST NE [] THEN WRITE_TXT, FILELIST_CHECKSUMS, CLIST                                              ; Resave list
        ENDIF
  
        CLIST = READ_DELIMITED(FILELIST_CHECKSUMS,DELIM='SPACE',/NOHEADING)                                     ; Read the CHECKSUM as a delimited file
        IF N_TAGS(CLIST) EQ 1 THEN BEGIN                                                                        ; Look for empty files
          PLUN, LUN, 'ERROR: No valid files found on remote server ' 
          PLUN, LUN, CLIST, 0
          CONTINUE                                                                                              ; Continue to the next set of dates
        ENDIF
        
        OK = WHERE_STRING(CLIST.(1), '.GEO', COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT)                    ; Find any GEOLOCATION files (usually in the VIIRS subscription)
        IF NCOMPLEMENT GE 1 THEN CLIST = CLIST[COMPLEMENT]                                                      ; Remove any GEOLOCATION files from the list
        CKSUMS = CLIST.(0)                                                                                      ; Get the list of checksums
        SNAMES = CLIST.(1)                                                                                      ; Get the list of matching file names
        IF SNAMES EQ [] THEN CONTINUE                                                                           ; Make sure files exist
        SRT = SORT(SNAMES) & SNAMES = SNAMES[SRT] & CKSUMS = CKSUMS[SRT]                                        ; Sort files
        PLUN, LUN, ROUNDS(N_ELEMENTS(SNAMES)) + ' files found on remote server.'
        FOR I=0, N_ELEMENTS(SNAMES)-1 DO PLUN, LUN, SNAMES[I] + '     ' + CKSUMS[I],0                           ; Print the list of subscription files found
        SUBLIST = [SUBLIST,SNAMES]
        SUBSUMS = [SUBSUMS,CKSUMS]
                  
      ENDIF ELSE BEGIN
        FILE_DELETE, FILELIST_CHECKSUMS                                                                         ; Delete the FILEIST file and try again
        PLUN, LUN, 'ERROR: No valid files found on remote server'
        CONTINUE
      ENDELSE
    ENDWHILE  
  ENDFOR ; IDS loop
  
  ; ===> Add the subscription files to the master download list
  DLIST = READ_TXT(L1_ORDER_LIST) & NLIST = N_ELEMENTS(DLIST)                                                   ; Read the master list
  IF SUBLIST NE [] THEN DLIST = [DLIST,OC_GET+SUBLIST]                                                          ; Add new files to the list
  DLIST = REVERSE(DLIST[SORT(DLIST)])                                                                           ; Sort names to be in reverse order (newest first)
  DLIST = DLIST[UNIQ(DLIST)]                                                                                    ; Remove any duplicates
  DLIST = DLIST[WHERE(DLIST NE OC_GET,/NULL)]                                                                   ; Remove any files that don't include the file name
  IF NLIST NE N_ELEMENTS(DLIST) THEN BEGIN                                                                      ; Rename and move old file and save new list
    FILE_MOVE, L1_ORDER_LIST, !S.SCRIPTS + SL + 'DOWNLOADS' + SL + 'FILELISTS' + SL + 'REPLACED' + SL + REPLACE(DATASET,'-','_') + '-REPLACED_' + DATE_NOW() + '.txt'
    WRITE_TXT, L1_ORDER_LIST, DLIST                                                                             ; Write a new master download list
  ENDIF
  
  IF SUBLIST NE [] THEN BEGIN
    STRUCT = REPLICATE(CREATE_STRUCT('SUBSCRIPTION_NAMES','','CHECKSUMS',''),N_ELEMENTS(SUBLIST))                 ; Make a structure for the file names and checksums
    STRUCT.SUBSCRIPTION_NAMES = SUBLIST & STRUCT.CHECKSUMS = SUBSUMS                                              ; Fill in the structure
    RETURN, STRUCT
  ENDIF
  
  SKIP_ID_SEARCH:  
  PLUN, LUN, 'Skip ' + DATASET + '...', 0
  RETURN, []


END ; ***************** End of DWLD_NASA_GET_SUBSCRIPTION_FILES *****************
