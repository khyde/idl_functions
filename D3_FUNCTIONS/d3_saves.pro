; $ID:	D3_SAVES.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO D3_SAVES, D3_FILE, DIR_SAV=DIR_SAV, DATERANGE=DATERANGE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGLUN=LOGLUN
;
; PURPOSE: WRITE SAV FILES DROM THE D3_INTERP FILE 
; 
; CATEGORY:	D3 FAMILY		 
;
; CALLING SEQUENCE: D3_SAVES,D3_FILE
;
; INPUTS: D3_FILE  [FROM D3_MAKE]
;
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;         DIR_SAV...... OUTPUT DIR FOR SAV FILES
;         VERBOSE...... KEYWORD TO PRINT OUT STATEMENTS
;         OVERWRITE.... OVERWRITE SAV FILE IF IT EXISTS
;         LOGLUN....... If provided, the LUN for the log file
;    
;
; OUTPUTS: SAV FILES FROM THE D3_INTERP FILE
;		
; EXAMPLES:
; 
;	NOTES:
;
;; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  Inquiries should be directed to kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;       Written March 30, 2015 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;       Modified:
;         JAN 24, 2017 - KJWH: ADDED VERBOSE KEYWORD
;                              FORMATTING
;                              UPDATED HOW FILE NAMES ARE REPLACED DEPENDING ON WHETHER THE INPUT IS THE ORIGINAL D3_FILE FOR THE MED_FILL FILE
;         JAN 31, 2017 - KJWH: CHANGED OPENR, D3_LUN, D3_INTER_FILE, /GET_LUN TO OPENR, D3_LUN, D3_FILE, /GET_LUN
;                              ADDED A STOP IF NAME = '' ===> NEED TO INVESTIGATE.  CAN POTENTIALLY CHANGE TO CONTINUE AND SKIP WRITING A BLANK FILE
;         FEB 02, 2017 - KWJH: CHANGED FILE_ALL TO PARSE_IT(D3_FILE,/ALL)
;                              LOOKING FOR L3B_MAP SUBSET FILES AND ADDING THE BINS TO THE OUTPUT SAVE      
;                              CHANGED -DATA.FLT TO -DAT.FLT TO AVOID ERRORS WHEN LOOKING FOR VALID PRODUCTS (DATA IS CONSIDERED A VALID PRODUCT AND -DATA.FLT INTERFERES WITH FINDING THE ACTUAL PRODUCT)               
;                              CHANGED THE FILE NAME IN SHMMAP, 'D3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=D3_FILE FROM D3_INTERP_FILE TO D3_FILE
;         FEB 02, 2017 - KJWH: ADDED A STEP TO CREATE NAMES FOR DAYS THAT DID NOT ORIGINALLY HAVE A FILE, BUT NOW COULD HAVE INTERPOLATED DATA    
;         FEB 10, 2017 - KJWH: ADDED DATERANGE KEYWORD - NOW CAN JUST WRITE OUT SAVE FILES FROM A SPECIFIED DATERANGE  
;         AUG 15, 2017 - KJWH: FIXED BUGS DEALING WITH SUBSETTING THE NAMES WITH DATERANGE
;                                NAMES = DATE_SELECT(NAMES,DATERANGE,COUNT=N_FILES)
;                                IF NAMES EQ [] THEN GOTO, DONE               
;         NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                              Added LOGFILE keyword
;         FEB 25, 2019 - KJWH: Updated LOG_LUN opening pring statements
;                              Added copyright info    
;         SEP 09, 2019 - KJWH: Removed LOGFILE and now using an input LOGLUN to record the log information                 
;#################################################################################
;-
;**************************
  ROUTINE_NAME  = 'D3_SAVES'
;**************************

  SL = PATH_SEP()

;===> DEFAULTS
  LAND_CODE = -999.0
  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  PLUN, LOG_LUN, 'Starting ' + ROUTINE_NAME

  IF N_ELEMENTS(DATERANGE) NE 2 THEN DATERANGE = ['19800101','21001231']
  IF NONE(D3_FILE) THEN MESSAGE,'ERROR: D3_FILE IS REQUIRED'

  REPLACENAME = '-DAT.FLT'
  IF HAS(D3_FILE,'-D3_MED_FILL') THEN REPLACENAME = '-D3_MED_FILL.FLT' 
  IF HAS(D3_FILE,'-D3_INTERP')   THEN REPLACENAME = '-D3_INTERP.FLT'
  D3_DB_FILE     = REPLACE(D3_FILE,REPLACENAME,'-D3_INTERP_DB.SAV')
  D3_BINS_FILE   = REPLACE(D3_FILE,REPLACENAME,'-D3_BINS.SAV')
  
  IF NONE(DIR_SAV) THEN  DIR_SAV = (FILE_PARSE(D3_FILE)).DIR + 'INTERP_SAV'  + PATH_SEP()
  DIR_TEST,DIR_SAV

;===> GET DIMENSIONS,MAP AND PROD FROM THE D3_FILE
  FA = PARSE_IT(D3_FILE,/ALL) & PX = FA.PX & PY = FA.PY & PZ = FA.PZ  & MAPP = FA.MAP & PROD = FA.PROD

;===> GET N_FILES AND FILE NAMES FROM THE DB
  DB = STRUCT_READ(D3_DB_FILE)  
  N_FILES = NOF(DB) & PLUN, LOG_LUN,'N_FILES: ' + NUM2STR(N_FILES), 1
  NAMES = DB.NAME
  
;===> FIND MISSING NAMES AND CREATE NEW NAME
  OK = WHERE(NAMES EQ '',COUNT_MISSING, COMPLEMENT=COMPLEMENT)
  IF COUNT_MISSING GE 1 THEN BEGIN
    IF COUNT_MISSING EQ N_ELEMENTS(NAMES) THEN MESSAGE, 'ERROR: NO VALID NAMES IN THE DB FILE'
    NAME = NAMES(COMPLEMENT[0])
    FN = PARSE_IT(NAME,/ALL)
    TAG = REPLACE(NAME,FN.PERIOD,'')
    NAMES[OK] = DB[OK].PERIOD + TAG
    UN = UNIQ(NAMES[SORT(NAMES)])
    IF N_ELEMENTS(UN) NE N_ELEMENTS(NAMES) THEN MESSAGE, 'ERROR: THERE IS AT LEAST ONE INSTANCE OF A REPEATED NAME IN THE LIST OF NAMES.'
  ENDIF
  
  NAMES = DATE_SELECT(NAMES,DATERANGE,COUNT=N_FILES)
  IF NAMES EQ [] THEN GOTO, DONE
  
  SAVEFILES = DIR_SAV + NAMES + '-INTERP.SAV'
  IF FILE_MAKE(D3_FILE,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, DONE

; ===> CHECK TO SEE IF THE FILE IS A L3B_MAP SUBSET
  IF HAS(D3_FILE,'L3B') THEN BINS = IDL_RESTORE(D3_BINS_FILE) ELSE BINS = []

  IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'

;===> OPEN THE D3_INTERP_FILE FOR READING 
  OPENR, D3_LUN, D3_FILE, /GET_LUN

;|||||||||||||||||||||||||||||||||||
;===> MAP THE D3 ARRAY TO THE D3_FILE
  SHMMAP, 'D3', /FLOAT, DIMENSION=[PX,PY,N_FILES], FILENAME=D3_FILE

;===> GET THE D3 ARR
  D3 = SHMVAR('D3')


;####################################################################################
;#####     WRITE EACH IMAGE ARRAY IN THE D3_INTERP FILE     #########################
;####################################################################################
 
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_FILES-1 DO BEGIN
    NAME = NAMES[NTH]
    IF NAME EQ '' THEN STOP; CONTINUE
    IF DATE_SELECT(NAME,DATERANGE) EQ [] THEN CONTINUE 
    FILE = DIR_SAV + NAME + '-INTERP.SAV'
    IF FILE_MAKE(D3_FILE,FILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    ARR  = D3(*,*,NTH)    
    STRUCT_WRITE, ARR, FILE=FILE, BINS=BINS, LOGLUN=LOG_LUN
  ENDFOR;FOR NTH = 0,N_FILES-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;===> CLEAN UP
  IF IS_SHM(D3_FILE) THEN SHMUNMAP,'D3'
  GONE,D3
    
  DONE: 
         
END; #####################  END OF ROUTINE ################################
