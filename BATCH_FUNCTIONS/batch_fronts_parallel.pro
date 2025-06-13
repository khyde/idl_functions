; $ID:	BATCH_FRONTS_PARALLEL.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO BATCH_FRONTS_PARALLEL, DATASET=DATASET, DATERANGE=DATERANGE, LOGFILE=LOGFILE, STEP_NAMES=STEP_NAMES, STEPS=STEPS, PRODS=PRODS, $
                             MAPIN=MAPIN, D3MAP=D3MAP, NCMAP=NCMAP, PLTMAP=PLTMAP, INDICATOR_PERIOD=INDICATOR_PERIOD, $
                             LOGLUN=LOGLUN, OVERWRITE=OVERWRITE, BUFFER=BUFFER, VERBOSE=VERBOSE, $
                             SERVERS=SERVERS, N_PROCESSES=N_PROCESSES
                               

;+
; NAME:
;   BATCH_FRONTS_PARALLEL
;
; PURPOSE:
;   Set up the parallel processing for BATCH_FRONTS
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATCH_FRONTS_PARALLEL,
;
; REQUIRED INPUTS:
;   DATASET........... The dataset for processing
;   DATERANGE......... The daterange for the parallel processing (broken down by years)
;   STEP_NAMES........ The names of the batch_processing steps
;   STEPS............. The batch processing step values
;   PRODS............. The product names for the processing
;   MAPIN............. The name of the input map
;   D3MAP............. The name of the D3HASH map
;   NCMAP............. The name of the map for the netcdf files
;   PLTMAP............ The name of the map for plotting
;   INDICATOR_PERIOD.. The period code(s) for processing the indicators
;   LOGLUN............ The lun for writing out the log file
;   OVERWRITE......... The keyword to overwrite existing files
;   BUFFER............ To buffer the graphics windows (0=graphics will be displayed while being created, 1=graphics will be hidden)
;   VERBOSE........... Print out steps of the program
;
; OPTIONAL INPUTS:
;   SERVERS........... The names of the servers to use
;   N_PROCESSES....... The maximum number of processes to run in parallel
;   
; KEYWORD PARAMETERS:
;   None
;   
; OUTPUTS:
;   Creates a text file of commands and then runs the steps in parallel by year
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   All inputs are required and will need to be updated if changes are made to BATCH_FRONTS
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 08, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 08, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATCH_FRONTS_PARALLEL'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  IDL_CMD = '/usr/local_local/idl/idl87/bin/idl -e '
  
  IF N_ELEMENTS(LOGLUN) EQ 1 THEN LUN = LOGLUN ELSE MESSAGE, 'ERROR: LOGLUN must be provided.'
  
  
  YRS = YEAR_RANGE(DATERANGE,/STRING)
  CMDS = []
  FOR C=0, N_ELEMENTS(YRS)-1 DO BEGIN
    CMD = "BATCH_FRONTS, '" + DATASET + "', PRODS=["+STRJOIN("'"+PRODS+"'",",") + "]"+$
      ", DATERANGE='" + YRS[C] + "', LOGFILE='" + REPLACE(LOGFILE,".log","-"+YRS[C]+".log") + "', INDICATOR_PERIOD=["+STRJOIN("'"+INDICATOR_PERIOD+"'",",") + "]"+$
      ", MAPIN='" + MAPIN + "', D3MAP='"+D3MAP + "', NCMAP='"+NCMAP +"', PLTMAP='"+PLTMAP + "'"+ $
      ", PARALLEL=0, OVERWRITE="+NUM2STR(OVERWRITE) + ", BUFFER="+NUM2STR(BUFFER) + ", VERBOSE="+NUM2STR(VERBOSE)+", "

    FOR E=0, N_ELEMENTS(STEPS) -1 DO CMD = CMD + STEP_NAMES[E] + "='" + STEPS[E] + "',"
    CMD = STRMID(CMD,0,STRLEN(CMD)-1)
    CMDS = [CMDS,IDL_CMD + '"' + CMD + '"']
  ENDFOR
  FILE = !S.LOGS + 'IDL_BATCH_FRONTS' + SL + 'temp_batch_fronts_parallel_' + DATE_NOW() + '.txt'
  WRITE_TXT, FILE, CMDS

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
    CD, CURRENT=CURRENT_DIR
    CD, !S.SCRIPTS + 'IDL' + SL
    SPAWN, SCMD, SLOG, ERR
    IF N_ELEMENTS(ERR) GT 0 THEN PLUN, LUN, ERR
    CD, CURRENT_DIR
    PLUN, LUN, 'Finished runing ./idl_parallel.
  ENDIF ELSE PLUN, LUN, 'Unable to run ./idl_parallel - too many processors currening running.  Exiting BATCH_L3_PARALLEL...'

  PLUN, LUN, 'Deleting temp file ' + FILE
  IF FILE_TEST(FILE) THEN FILE_DELETE, FILE
  
  PLUN, LUN, 'Finished ' + ROUTINE_NAME + '. '
  PLUN, LUN, 'Closing log file: ' + LOGFILE + ' on: ' + systime(), 0
  PLUN, LUN, '******************************************************************************************************************'
  FLUSH, LUN & CLOSE, LUN & FREE_LUN, LUN

  

END ; ***************** End of BATCH_FRONTS_PARALLEL *****************
