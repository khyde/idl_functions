; $ID:	WGET_SUBSCRIPTION.PRO,	2020-07-01-12,	USER-KJWH	$

	PRO WGET_SUBSCRIPTION, FTP, DIR_OUT, EXT=EXT, REMOTE_FILES=REMOTE_FILES,GET_FILES=GET_FILES, LOCAL_FILES=LOCAL_FILES, LOOK=LOOK 

;+
; NAME:
;		WGET_SUBSCRIPTION
;
; PURPOSE:
;		This procedure downloads near-real time NASA satellite subscription files
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;  LOOK = Skip downloading files and just return the SERVER and GET files lists if requested
;
; OUTPUTS:
;	
; OPTIONAL OUTPUTS:
;   REMOTE_FILES = The list of files found on the server
;   GET_FILES    = The list of files to download (after comparing with local files)
;   LOCAL_FILES  = The list of files found locally
;   
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	PROCEDURE:
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jan 25, 2016 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			        Jan 27, 2016 - KJWH: Added REMOTE_FILES, GET_FILES and LOCAL_FILES output keywords to return lists of files 
;			                             Added LOOK keyword to just find the files on the server, but not download them
;			                     
;			                     
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'WGET_SUBSCRIPTION'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

	SL = PATH_SEP()

  IF NONE(FTP) THEN MESSAGE, 'ERROR: Must provide FTP location'
  IF NONE(EXT) THEN EXT = 'nc'
  IF NONE(DIR_OUT) THEN DIR = !S.DEMO + ROUTINE_NAME + SL ELSE DIR = DIR_OUT 
  DIR_LOG = DIR_OUT + 'LOG' + SL
  DIR_TEST, [DIR_OUT, DIR_LOG]

  WGET_CMD = 'wget -c -N --tries=3 --retry-connrefused --wait=5 --progress=dot:mega '
        
  CD, DIR
      
; ===> Remove any existing .listing or file_list.txt files      
  L = FILE_SEARCH(DIR + '.listing',COUNT=COUNT)      & IF COUNT GE 1 THEN FILE_DELETE, L
  F = FILE_SEARCH(DIR + 'file_list.txt',COUNT=COUNT) & IF COUNT GE 1 THEN FILE_DELETE, F
     
; ===> Use WGET to get a list of the files on the FTP server     
  URL = FTP 
  CMD = 'wget --spider --no-remove-listing --no-verbose ' + URL
  SPAWN, CMD

; ===> Read the .listing file and extract the file names and last modified date info      
  L  = DIR + '.listing'
  IF FILE_TEST(L) EQ 0 THEN GOTO, DONE
  TXT = READ_DELIMITED(L,DELIM='SPACE',/NOHEADING)
  NTAGS = N_ELEMENTS(TAG_NAMES(TXT))
  FP = FILE_PARSE(TXT.(NTAGS-1))
  OK = WHERE(FP.EXT EQ 'nc')
  REMOTE_FILES = FP[OK].FULLNAME  ; Remote server files
  
; ===> Generate the date modified for the files on the remote server --- NOTE: These tags may only work with NASA subscriptions      
  DP = DATE_PARSE(DATE_NOW(/GMT))
  MONTH = MONTH_2NUM(TXT.(5))
  DAY   = TXT.(6)
  TIME  = REPLACE(TXT.(7),':','') + '00'
  DATE  = DP.YEAR + MONTH + DAY + TIME                         ; No year is provided so assume the current year
  OK = WHERE(DATE GT DP.DATE,COUNT)                            ; Look for dates that are in the future and
  IF COUNT GE 1 THEN DATE[OK] = ROUNDS(DP.YEAR-1) + MONTH[OK] + DAY[OK] + TIME[OK] ; Subtract 1 from the year 
      
; ===> Find local files and compare time stamps to the remote server files      
  LOCAL_FILES = FILE_SEARCH(DIR + '*.nc*',COUNT=COUNT_BEFORE)
  FB = FILE_PARSE(LOCAL_FILES)
  OK = WHERE(FB.EXT NE 'nc',COUNT)
  IF COUNT GE 1 THEN LOCAL_FILES[OK] = FB[OK].DIR + FB[OK].NAME ; Remove any extension (i.e. bz2) that is not 'nc' to compare with the files on the server
            
  GET_FILES = []
  FOR N=0, N_ELEMENTS(REMOTE_FILES)-1 DO BEGIN
    AFILE = REMOTE_FILES(N)
    ADATE = DATE(N)
    OK = WHERE(FB.NAME_EXT EQ AFILE,COUNT)
    IF COUNT EQ 0 THEN GET_FILES = [GET_FILES,AFILE] ELSE BEGIN
      IF GET_MTIME(LOCAL_FILES[OK],/DATE) LT ADATE THEN GET_FILES = [GET_FILES,AFILE] 
    ENDELSE               
  ENDFOR
  IF GET_FILES EQ [] THEN GOTO, DONE ; No new files to download
  FL = DIR + 'file_list.txt'
  WRITE_TXT, FL, URL + GET_FILES

  IF KEY(LOOK) THEN GOTO, DONE

; ===> Create and open the log file
  LOGFILE = DIR_LOG + ROUTINE_NAME + '-' + DATE_NOW() + '.log'
  OPENW, LUN,LOGFILE,/APPEND,/GET_LUN,width=180
  PRINTF,LUN,'WGET LOG FILE INITIALIZING ON: ' + systime()
  FLUSH, LUN
        
; ===> WGET any new files                  
  CD, DIR
  CMD = WGET_CMD + '-c -N -a ' + LOGFILE + ' -i ' + FL       
  PRINT, CMD
  PRINTF, LUN, ' AT: ' + systime() + ' : Attempting to run command:' 
  PRINTF, LUN, CMD & PRINTF, LUN & PRINTF,LUN, GET_FILES & PRINTF, LUN
  FLUSH, LUN        
  SPAWN, CMD
      
; ===> Find new files and check that they are not corrupt
  AFILES = FILE_SEARCH(DIR + '*.nc',COUNT=COUNT_AFTER)
  OK = WHERE_MATCH(LOCAL_FILES,AFILES,COMPLEMENT=COMPLEMENT,VALID=VALID,INVALID=INVALID,NINVALID=NINVALID)
  IF NINVALID GT 0 THEN CHECK_FILES = AFILES(INVALID) ELSE CHECK_FILES = []
  
  FOR C=0, N_ELEMENTS(CHECK_FILES)-1 DO BEGIN   ; Check that newly downloaded files are not corrupt
    IF H5F_IS_HDF5(CHECK_FILES(C)) EQ 0 THEN BEGIN
      FILE_DELETE, CHECK_FILES(C), /VERBOSE
      CONTINUE
    ENDIF
    ID = NCDF_OPEN(CHECK_FILES(C))
    INFO = NCDF_INQUIRE(ID)
    NCDF_CLOSE, ID
    IF IDLTYPE(INFO) NE 'STRUCT' THEN FILE_DELETE, CHECK_FILES(C),/VERBOSE
  ENDFOR
  
  CLOSE, LUN
  FREE_LUN,LUN      
  CD, !S.PROGRAMS
 
  DONE:    
  

END; #####################  End of Routine ################################




