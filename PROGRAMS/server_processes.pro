; $ID:	SERVER_PROCESSES.PRO,	2020-06-30-17,	USER-KJWH	$

  FUNCTION SERVER_PROCESSES, SERVERS, MAX_PROCESSES=MAX_PROCESSES, N_PROCESSES=N_PROCESSES, PROGRAMS=PROGRAMS, VERBOSE=VERBOSE

;+
; NAME:
;   SERVER_PROCESSES
;
; PURPOSE:
;   This function determines the number of major processes (e.g. IDL and SeaDAS) that are currently running and determines how many jobs can be run on subsequent parallel processing calls
;
; CATEGORY:
;   Processing
;
; CALLING SEQUENCE:
;   RESULT = SERVER_PROCESSES(SERVERS)
;
; INPUTS:
;   SERVERS......... The name of the SERVERS to look at [default: satdata,seadas,modis,satbackup1,satbackup2]
;
; OPTIONAL INPUTS:
;   MAX_PROCESSES... The maximum number of processes for each server
;   N_PROCESSES..... The number of processes to run on each server if less than the max
;   PROGRAMS........ The names of programs to search for [default: idl, seadas, l2gen, l2bin, wget]
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns a list of server names with their respective number of processes to be sent to subsequent parallel processing calls
;
; OPTIONAL OUTPUTS:
;
; EXAMPLE:
;   PRINT, SERVER_PROCESSES()
;   PRINT, SERVER_PROCESSES(['satdata','modis','seadas'])
;   PRINT, SERVER_PROCESSES(['satdata','modis','seadas'],MAX_PROCESSES=6)
;   PRINT, SERVER_PROCESSES(MAX_PROCESSES=4)
;   PRINT, SERVER_PROCESSES(MAX_PROCESSES=4,PROGRAMS=['idl','wget'])
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
;         
;
; MODIFICATION HISTORY:
;			Written:  Nov 20, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 21, 2018 - KJHW: Tested and updated code
;			          Nov 26, 2018 - KJWH: Added VERBOSE keyword
;			          Nov 30, 2018 - KJWH: Created server specific maximum processes (MAXP)
;			          Jan 29, 2019 - KJWH: Added a "ping" check to make sure the server is accessible
;			          Jan 30, 2019 - KJWH: Updated output from "ping" check so that the server is not included in the final list if is unavailable
;			          FEB 25, 2019 - KJWH: Added step to exclude 'idl_parallel' and 'idl_daily_batch_jobs' programs from the list of JOBS
;			          JUL 02, 2019 - KJWH: Updated VERBOSE statements
;			                               Updated the list of servers and removing those that can not be pinged
;			          JUL 15, 2019 - KJWH: Added N_PROCESSES keyword to input the desired number of processes to run
;			                                  IF NONE(N_PROCESSES) THEN NPRO = MAXP ELSE NPRO = N_PROCESSES < MAXP    
;			                                  PJOBS = (MAXP-JOBS) < NPRO   
;			          JUL 19, 2019 - KJWH: Fixed bug when calculating the number of IDL jobs
;			                                 IF IDLJOBS GT 0 THEN LOG = REPLICATE(1,IDLJOBS) ELSE LOG = []                                     
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SERVER_PROCESSES'
	
	LOCAL = STRLOWCASE(!S.COMPUTER)
	IF NONE(PROGRAMS) THEN PRG = ['idl -x', 'seadas', 'l2gen', 'l2bin', 'wget','geolocate'] ELSE PRG = STRLOWCASE(PROGRAMS)
	IF NONE(SERVERS)  THEN SVR = ['satdata','luna','modis']  ELSE SVR = STRLOWCASE(SERVERS) 
	FOR S=0, N_ELEMENTS(SVR)-1 DO BEGIN
	  SV = SVR[S]
  	CMD = 'ping -c 2 ' + SV
  	SPAWN, CMD, LG, ER
  	IF (N_ELEMENTS(LG) EQ 1 AND LG[0] EQ '') OR HAS(LG, 'Destination Host Unreachable') THEN SVR[S] = '' ; If the server can not be accessed, then remove from list
  ENDFOR
  SVR = REMOVE(SVR,VALUES='')
	
	FOR S=0, N_ELEMENTS(SVR)-1 DO BEGIN
	  SV = SVR[S]
	  JOBS = 0
	  
	  CASE SV OF
	    'satdata':    IF NONE(MAX_PROCESSES) THEN MAXP = 12 ELSE MAXP = MAX_PROCESSES < 14
	    'luna':       IF NONE(MAX_PROCESSES) THEN MAXP = 10 ELSE MAXP = MAX_PROCESSES < 12
	    'modis':      IF NONE(MAX_PROCESSES) THEN MAXP = 12 ELSE MAXP = MAX_PROCESSES < 14
	    'satbackup1': IF NONE(MAX_PROCESSES) THEN MAXP = 10 ELSE MAXP = MAX_PROCESSES < 12
	    'satbackup2': IF NONE(MAX_PROCESSES) THEN MAXP = 10 ELSE MAXP = MAX_PROCESSES < 12
	    ELSE:         IF NONE(MAX_PROCESSES) THEN MAXP = 10 ELSE MAXP = MAX_PROCESSES < 12
	  ENDCASE
	  
	  IF NONE(N_PROCESSES) THEN NPRO = MAXP ELSE NPRO = N_PROCESSES < MAXP
	  
	  FOR R=0, N_ELEMENTS(PRG)-1 DO BEGIN
	    PR = PRG[R]
	    IF SV NE LOCAL THEN PCMD = 'ssh ' + SV + ' pgrep ' ELSE PCMD = 'pgrep ' 
	    SPAWN, PCMD + PR + ' -l', LOG, ERR 
	    IF N_ELEMENTS(LOG) EQ 1 AND LOG[0] EQ '' THEN LOG = []
	    IF KEY(VERBOSE) THEN PRINT, NUM2STR(N_ELEMENTS(LOG)) + ' processors on ' + SV + ' running ' + PR
	    IF PR EQ 'idl' AND LOG NE [] THEN BEGIN
	      IDLS = ['idl_parallel','idl_daily','idl_engine']
	      ILOGS = 0
	      FOR I=0, N_ELEMENTS(IDLS)-1 DO BEGIN
  	      SPAWN, PCMD + IDLS[I], LOGP, ERRP
	        IF N_ELEMENTS(LOGP) EQ 1 AND LOGP[0] EQ '' THEN LOGP = []
	        IF KEY(VERBOSE) AND LOGP NE [] THEN PRINT, '  ' + NUM2STR(N_ELEMENTS(LOGP)) + ' processors on ' + SV + ' running ' + IDLS[I] + ' ... remove from JOBS list'
	        ILOGS = ILOGS + N_ELEMENTS(LOGP)
	      ENDFOR
	      IDLJOBS = N_ELEMENTS(LOG)-ILOGS
	      IF IDLJOBS GT 0 THEN LOG = REPLICATE(1,IDLJOBS) ELSE LOG = []
	    ENDIF     
	    JOBS = JOBS + N_ELEMENTS(LOG)
	  ENDFOR  
    PJOBS = (MAXP-JOBS) < NPRO
	  IF PJOBS GT 0 AND SVR[S] NE '' THEN SVR[S] = NUM2STR(PJOBS) + '/' + SVR[S] ELSE SVR[S] = ''
	ENDFOR
	SVR = REMOVE(SVR,VALUES='')
	IF KEY(VERBOSE) THEN BEGIN
	  SPL = STR_BREAK(SVR,'/')
	  IF SPL NE [] THEN LI, 'Can process ' + SPL(*,0) + ' new job(s) on ' + SPL(*,1), /NOSEQ, /NOHEADING
	ENDIF
	RETURN, SVR
	 
	


END; #####################  End of Routine ################################
