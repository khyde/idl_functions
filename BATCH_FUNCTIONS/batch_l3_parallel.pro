; $ID:	BATCH_L3_PARALLEL.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO BATCH_L3_PARALLEL, CMDS, SERVERS=SERVERS, NPROCESS=NPROCESS, R_YEAR=R_YEAR, IDL88=IDL88, LOGDIR=LOGDIR, SPWN=SPWN

;+
; NAME:
;   PARALLEL
;
; PURPOSE:
;   This procedure will "LOOP" through the DATERANGE years and run BATCH_L3 in parallel on multiple servers
;
; CATEGORY:
;   Processing
;
; CALLING SEQUENCE:
;   BATCH_L3_PARALLEL, CMD, SERVERS=SERVERS, NPROCESS=NPROCESS
;
; INPUTS:
;   CMD.......... The IDL command that will be run in parallel
;   
; OPTIONAL INPUTS:
;   SERVERS...... The names of the servers to use for the various processes
;   NPROCESS..... The number of processes to start on each server (default=6)
;   LOGDIR....... The directory for the log file
;
; KEYWORD PARAMETERS:
;   R_YEAR....... Keyword to reverse the order of the years in the output file
;   SPWN......... Keyword to run the SPAWN command (default = 1)
;
; OUTPUTS:
;   The output is dependent on the input CMD
;
; OPTIONAL OUTPUTS:
;
; EXAMPLE:
;   BATCH_L3_PARALLEL, "BATCH_L3,DO_STATS='Y'"
;   BATCH_L3_PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'"
;   BATCH_L3_PARALLEL, "BATCH_L3,DO_STATS='Y',DO_ANOMS='Y[SEAWIFS]',BATCH_DATERANGE='2000_2012'"
;   BATCH_L3_PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", SERVERS=['satdata','satbackup1']
;   BATCH_L3_PARALLEL, "BATCH_L3,DO_STATS='Y',BATCH_DATERANGE='2000_2012'", SERVERS=['satdata','satbackup1'], NPROCESS=6
;
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;    
;
; MODIFICATION HISTORY:
;			Written:  Oct 31, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 07, 2018 - KJWH: Added R = EXECUTE(CMD) after the parallel processing step to rerun the BATCH_L3 command with the full DATERANGE (mainly for STATS processing) 
;			          Nov 19, 2018 - KJWH: Added steps to check the number of IDL processes currently running and adjust the total number of processes to run on each server to be less than 6
;			                               If all servers are "maxed out" at 6 IDL sessions, then skip the parallel step and just the entire command locally
;			          Nov 26, 2108 - KJWH: Changed the default location of the LOG files to be !S.LOGS
;			          NOV 27, 2018 - KJWH: Added steps to wait 1 hour then try SERVER_PROCESSES again if no processes are available.
;			          NOV 30, 2018 - KJWH: Now can input multiple "COMMANDS" and the program will compile them into a single file to be used by the parallel processing script
;			                                 This way you can set up multiple BATCH_L3 calls (see BATCH_CRON) and not have to wait for the first set to be completed before starting the next set starts
;			                               After the processing has completed, the LOG directory will be moved to a year-based directory.  This makes it easier to find and track the log files from the command line  
;               FEB 25, 2019 - KJWH: Added R_YEAR and SPWN keywords
;                                    Added steps to parse out the "DO_STATS" step.  Now only rerunning the entire time series if DO_STATS is in the CMD
;                                      Also reversing the file order (RF) in order to avoid duplicate processing on the same files
;               JUL 19, 2019 - KJWH: Added a step to create a special command for runing the DO_STATS_FRONTS step                
;               JUL 22, 2019 - KJWH: Comparing the number of years in the DATERANGE to the number of years from SENSOR_DATES and only running the extra DO_STATS, DO_ANOMS and DO_STATS_FRONTS steps if the daterange matches the sensor dates       
;               DEC 11, 2019 - KJWH: Fixed bug in the DO_STATS, DO_ANOMS and DO_STAT_FRONTS steps -> Changed YEARS to YRS
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'BATCH_L3_PARALLEL'
	SL = PATH_SEP()
	IDL_CMD = '/usr/local_local/idl/idl87/bin/idl -e'
	IF KEYWORD_SET(IDL88) THEN IDL_CMD = '/usr/local_local/idl/idl88/bin/idl -e'
	
	DP = DATE_PARSE(DATE_NOW()) 
	DATE = STRMID(DP.DATE,0,8)
	DR = ['1997',STRMID(DATE,0,4)]
	
	IF NONE(SPWN)     THEN SPWN = 1 ; Default keyword to run the SPAWN command
	IF NONE(CMDS)     THEN CMDS = 'BATCH_L3' ELSE CMDS = STRUPCASE(CMDS)
	IF NONE(NPROCESS) THEN NPROCESS = 6 ELSE NPROCESS = 1 > FIX(NPROCESS) < 8 ; Maximum number of processes per server
	IF NONE(SERVERS)  THEN SERVERS = ['satdata','luna','modis']
	IF NONE(LOGDIR)   THEN BEGIN
	  LOGDIR = !S.LOGS + 'IDL_BATCH_L3_PARALLEL' + SL + DATE + SL                      ; Date-stamped working directory for the LOG files
	  LDIR   = !S.LOGS + 'IDL_BATCH_L3_PARALLEL' + SL + DP.YEAR + SL & DIR_TEST, LDIR  ; Final (year-based) log directory for the date-stamped direcotories after processing (the entire directory is moved into this directory)
	  FDIR   = LDIR + DATE + SL                                                        ; Name of the date-stamped directory in the final directory location
	  IF FILE_TEST(FDIR) THEN FILE_MOVE, FDIR, !S.LOGS + 'IDL_BATCH_L3_PARALLEL' + SL  ; If the date-stamp directory exists in the final directory, then move it out to the parent directory so that it won't be replicated
	  DIR_TEST, LOGDIR
	ENDIF ELSE LDIR = ''
		
	LOG = LOGDIR + ROUTINE_NAME + '.log'
	OPENW, LUN, LOG, /APPEND, /GET_LUN, WIDTH=180 ;  ===> Open log file
	PLUN, LUN, '******************************************************************************************************************'
	PLUN, LUN, 'Starting ' + ROUTINE_NAME + ' log file: ' + LOG + ' on: ' + systime(), 0
	
	SCMDS = []
	FOR C=0, N_ELEMENTS(CMDS)-1 DO BEGIN
		CMD = CMDS[C]
		PLUN, LUN, 'Input CMD = ' + CMD
		WHILE HAS(CMD,', ') DO CMD = REPLACE(CMD,', ',',') ; Remove excess spaces between parts of the command
  	SDATES = []
  	IF HAS(CMD,'BATCH_DATASET') THEN BEGIN
  	  MID = STRMID(CMD,STRPOS(CMD,'BATCH_DATASET='))
  	  IF HAS(MID,',') THEN MID = STRMID(MID,0,STRPOS(MID,','))
  	  DTS = REPLACE(MID,["BATCH_DATASET=","'"],['',''])
  	  SDATES = SENSOR_DATES(VALIDS('SENSORS',DTS))	  
  	  MAXYRS = N_ELEMENTS(YEAR_RANGE(DATE_2YEAR(SDATES[0]),DATE_2YEAR(SDATES[1])))
  	ENDIF ELSE DTS = ''
  	
  	IF HAS(CMD,'BATCH_DATERANGE') THEN BEGIN
  	  MID = STRMID(CMD,STRPOS(CMD,'BATCH_DATERANGE='))
  	  BRM = REPLACE(MID,"BATCH_DATERANGE='",'')
  	  DR = STRMID(BRM,0,STRPOS(BRM,"'"))
  	  BDR = ",BATCH_DATERANGE='" + DR + "'"
  	  IF HAS(CMD,BDR) THEN CMD = REPLACE(CMD,BDR,'') ELSE MESSAGE, 'ERROR: Double check the BATCH_DATERANGE in the CMD'
  	ENDIF ELSE BDR = ''
  	
  	IF SDATES EQ [] AND BDR EQ '' THEN BEGIN
  	  QT1 = STRPOS(CMD,"'")
  	  IF QT1 GE 0 THEN BEGIN
  	    SUBCMD = STRMID(CMD,QT1+1)
  	    QT2 = STRPOS(SUBCMD,"'")
  	    IF QT2 GT 0 THEN SRCCMD = STRMID(SUBCMD,0,QT2)
    	  IF STRLEN(SUBCMD) GT QT2 THEN BEGIN
    	    ENDCMD = STRMID(SUBCMD,QT2+1)
    	    WHILE ENDCMD NE '' AND STRPOS(ENDCMD,"'") NE -1 DO BEGIN
      	    QT1 = STRPOS(ENDCMD,"'")
      	    SUBCMD = STRMID(ENDCMD,QT1+1)
      	    QT2 = STRPOS(SUBCMD,"'")
    	      IF QT2 EQ -1 THEN BREAK
    	      SRCCMD = [SRCCMD,STRMID(SUBCMD,0,QT2)]
    	      IF STRLEN(SUBCMD) GT QT2+1 THEN ENDCMD = STRMID(SUBCMD,QT2+1) ELSE ENDCMD = ''
    	    ENDWHILE  
    	  ENDIF
    	ENDIF
    	FOR I=0, N_ELEMENTS(SRCCMD)-1 DO BEGIN
  	    SWITCHES, SRCCMD[I], DATASETS=SENSOR
  	    IF SENSOR NE [] THEN SDATES = [SDATES,SENSOR_DATES(VALIDS('SENSORS',SENSOR))]
  	  ENDFOR
  	  DR = STRJOIN([MIN(SDATES),MAX(SDATES)],'_')
  	ENDIF
  	
  	WHILE HAS(CMD,' ') DO CMD=REPLACE(CMD,' ','')
  	PLUN, LUN, 'BATCH_L3 Command: ' + CMD, 2
  	
  	IF HAS(DR,'_') THEN BEGIN
  	  DRS = STR_BREAK(DR,'_')
  	  YRS = YEAR_RANGE(DRS[0],DRS[1],/STRING)
  	  IF DTS EQ '' THEN MAXYRS = N_ELEMENTS(YRS)
  	ENDIF ELSE YRS = YEAR_RANGE(DR[0],DR[1],/STRING)
  	IF KEY(R_YEAR) THEN YRS = REVERSE(YRS)
  	 	
  	FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
  	  LOGFILE = LOGDIR + 'BATCH_L3' + '-' + DTS + '_' + YRS(Y) + '.log'
  	  IF HAS(LOGFILE,'-_') THEN LOGFILE = REPLACE(LOGFILE,'-_','-')
  	  SCMD = IDL_CMD + ' "' + CMD + ',LOGFILE=' + "'" + LOGFILE + "'" + ',BATCH_DATERANGE=' + "'" + YRS(Y) + "'" + '"'
  	  PLUN, LUN, SCMD, 0
  	  SCMDS = [SCMDS,SCMD]
  	ENDFOR ; N_ELEMENTS(YRS)
  	PLOG = LOGDIR + ROUTINE_NAME + '-' + DTS + '-' + DR + '-' + '.log'
  	WHILE HAS(PLOG,'--') DO PLOG=REPLACE(PLOG,'--','-')
  	PLOG=REPLACE(PLOG,'-.','.')
  	
  	IF HAS(CMD,"DO_STATS='Y") AND N_ELEMENTS(YRS) EQ MAXYRS THEN BEGIN
  	  MID = STRMID(CMD,STRPOS(CMD,"DO_STATS='")) 
  	  WS  = STRPOS(REPLACE(MID,"DO_STATS='",""),"'")
  	  MID = STRMID(MID,0,STRLEN("DO_STATS='")+WS+1)
  	  IF HAS(MID,'RF') THEN MID = REPLACE(MID,'RF','') ELSE MID = REPLACE(MID,"='Y","='YRF")
  	  SLOG = LOGDIR + ROUTINE_NAME + '-DO_STATS-' + DTS + '-' + STRJOIN(DR,'_') + '-' + '.log'
  	  WHILE HAS(SLOG,'--') DO SLOG=REPLACE(SLOG,'--','-') & SLOG=REPLACE(SLOG,'-.','.')
  	  STAT_CMD = IDL_CMD + ' "' + 'BATCH_L3,' + MID + ",LOGFILE='" + SLOG + "'" + '"' 
  	  PLUN, LUN, STAT_CMD, 0
  	  SCMDS = [SCMDS,STAT_CMD]
  	ENDIF
  	
  	IF HAS(CMD,"DO_ANOMS='Y") AND N_ELEMENTS(YRS) EQ MAXYRS THEN BEGIN
  	  MID = STRMID(CMD,STRPOS(CMD,"DO_ANOMS='"))
  	  WS  = STRPOS(REPLACE(MID,"DO_ANOMS='",""),"'")
  	  MID = STRMID(MID,0,STRLEN("DO_ANOMS='")+WS+1)
  	  IF HAS(MID,'RF') THEN MID = REPLACE(MID,'RF','') ELSE MID = REPLACE(MID,"='Y","='YRF")
  	  SLOG = LOGDIR + ROUTINE_NAME + '-DO_ANOMS-' + DTS + '-' + STRJOIN(DR,'_') + '-' + '.log'
  	  WHILE HAS(SLOG,'--') DO SLOG=REPLACE(SLOG,'--','-') & SLOG=REPLACE(SLOG,'-.','.')
  	  ANOM_CMD = IDL_CMD + ' "' + 'BATCH_L3,' + MID + ",LOGFILE='" + SLOG + "'" + '"'
  	  PLUN, LUN, STAT_CMD, 0
  	  SCMDS = [SCMDS,ANOM_CMD]
  	ENDIF
   
    IF HAS(CMD,"DO_STAT_FRONTS='Y") AND N_ELEMENTS(YRS) EQ MAXYRS THEN BEGIN
  	  MID = STRMID(CMD,STRPOS(CMD,"DO_STAT_FRONTS='"))
  	  WS  = STRPOS(REPLACE(MID,"DO_STAT_FRONTS='",""),"'")
  	  MID = STRMID(MID,0,STRLEN("DO_STAT_FRONTS='")+WS+1)
  	  IF HAS(MID,'RF') THEN MID = REPLACE(MID,'RF','') ELSE MID = REPLACE(MID,"='Y","='YRF")
  	  SLOG = LOGDIR + ROUTINE_NAME + '-DO_STAT_FRONTS-' + DTS + '-' + DR + '-' + '.log'
  	  WHILE HAS(SLOG,'--') DO SLOG=REPLACE(SLOG,'--','-') & SLOG=REPLACE(SLOG,'-.','.')
  	  STAT_FRONT_CMD = IDL_CMD + ' "' + 'BATCH_L3,' + MID + ",LOGFILE='" + SLOG + "'" + '"'
  	  PLUN, LUN, STAT_FRONT_CMD, 0
  	  SCMDS = [SCMDS,STAT_FRONT_CMD]
  	ENDIF
   
  ENDFOR ; N_ELEMENTS(CMDS)
    
  FILE = !S.LOGS + 'IDL_BATCH_L3_PARALLEL' + SL + 'temp_batch_l3_parallel_' + DATE_NOW() + '.txt'
  WRITE_TXT, FILE, SCMDS
    
  COUNTER = 0
  REPEAT BEGIN
    SVRS = SERVER_PROCESSES(SERVERS,N_PROCESSES=NPROCESS,VERBOSE=COUNTER)
    IF SVRS EQ [] THEN BEGIN
      PLUN, LUN, 'Unable to run ' + './idl_parallel.sh ' + FILE + ' because too many IDL processes are currently running on all servers. (' + SYSTIME() + ')'
      PLUN, LUN, 'Waiting 1 hour...',0
      WAIT, 60*60
      COUNTER = COUNTER + 1
    ENDIF ELSE COUNTER = 3     
  ENDREP UNTIL COUNTER GE 3
  
  IF SVRS NE [] AND N_ELEMENTS(SVRS) GE 1  THEN BEGIN
    SCMD = './idl_parallel.sh ' + FILE + ' ' + STRJOIN(SVRS,',') + ' ' ;+ NUM2STR(NPROCESS)
    PLUN, LUN, SCMD
    CD, !S.SCRIPTS + 'IDL' + SL
    IF KEY(SPWN) THEN SPAWN, SCMD, SLOG, ERR ELSE STOP
    CD, !S.PROGRAMS
    PLUN, LUN, 'Finished runing ./idl_parallel.
    IF EXISTS(FILE) THEN FILE_DELETE, FILE 
  ENDIF ELSE PLUN, LUN, 'Unable to run ./idl_parallel - too many processors currening running.  Exiting BATCH_L3_PARALLEL...'
  
  PLUN, LUN, 'Finished ' + ROUTINE_NAME + '. '
  PLUN, LUN, 'Closing log file: ' + LOG + ' on: ' + systime(), 0
  PLUN, LUN, '******************************************************************************************************************'
  FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN
  
  IF KEY(SPWN) THEN IF FILE_TEST(LDIR) AND FILE_TEST(LOGDIR) THEN FILE_MOVE, LOGDIR, LDIR 
    
END; #####################  End of Routine ################################
