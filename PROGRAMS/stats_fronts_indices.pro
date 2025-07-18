; $ID:	STATS_FRONTS_INDICES.PRO,	2020-07-08-15,	USER-KJWH	$
;#############################################################################################################
PRO  STATS_FRONTS_INDICES, FILES, DIR_OUT=DIR_OUT, PERIOD_CODE_OUT=PERIOD_CODE_OUT, FILE_LABEL=FILE_LABEL,$
  DO_STATS=DO_STATS, KEY_STAT=KEY_STAT, MIN_GRAD, DATERANGE=DATERANGE, REVERSE_FILES=REVERSE_FILES, $
  INTI=INIT, MISSING=MISSING, OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
;+
; NAME:
;		STATS_ARRAYS_FRONTS
;
; PURPOSE: COMPUTE STATISTICS OF FRONTS FROM MULTIPLE FILES
;
; CATEGORY:
;		STATS
;
;
; CALLING SEQUENCE: STATS_ARRAYS_PERIODS_FRONTS,FILES
;
; INPUTS:
;		FILES..... FILES GENERATED WITH FRONTS_BOA EACH CONTAINING A NESTED STRUCTURE WITH:
;              GRAD_MAG (GRADIENT MAGNITUDE);
;              GRAD_X (GRADIENT IN HORIZONTAL DIRECTION);
;              GRAD_Y (GRADIENT IN VERTICAL DIRECTION);
;              GRAD_DIR (GRADIENT DIRECTION, IN DEGREES);
;              FILTERED_PIXELS (PIXELS REMOVED BY MF3_1D_5PT).
;
; OPTIONAL INPUTS:
;		NONE:
;
; KEYWORDS:
;   DIR_OUT............DIRECTORY FOR STATISTICAL OUTPUT FILES
;   STAT_PROD..........STANDARD PRODUCT NAME FOR THE NC FILES [E.G. 'CHLOR_A' OR 'SST' OR 'PAR']
;   PERIOD_CODES_OUT...PERIOD CODES FOR THE OUTPUT STATISTICS
;   FILE_LABEL.........A STRING OF KEY-IDENTIFYING ATTRIBUTES IN THE OUTPUT FILES [E.G. MAP-METHOD-PROD]
;   DATERANGE..........TO SUBSET THE FILES TO A SPECIFIED DATERANGE
;   DO_STATS...........A LIST OF STAT TYPES TO CALCULATE [DEFAULT = MEAN]
;                      DO_STATS = ['NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV']
;   MIN_GRAD...........THE LOWER GRADIENT MAGNITUDE THRESHOLD VALUE TO REPRESENT A FRONT (I.E. MINIMUM GRADIENT VALUE) FOR THE PROBABILITY CALCULATION
;   KEY_STAT...........THE STAT TYPE USED TO PROCESS FOR THE NEXT PERIOD [DEFAULT = MEAN]
;   MISSING............MISSING VALUE PASSED TO STATS_ARRAYS [DEFAULT = MISSINGS(DATA)]
;   OVERWRITE..........OVERWRITE OUTPUT SAV FILES
;		VERBOSE............PRINT PROGRAM PROGRESS
;
; OUTPUTS:
;   A SAV FILE WITH THE STATISTICS IN A NESTED STRUCTURE
;
; EXAMPLES:
;
;
;	NOTES:
;  Adapted from STATS_ARRAYS_PERIODS, STATS_ARRAYS_PERIODS_FRONTS and STATS_FRONTS
;
; MODIFICATION HISTORY:
;			Written AUG 22, 2016 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			AUG 23, 2016 - KJWH: Added SAME(MAPS) check
;			                     Added step to get the AZIMUTH angle
;			                     Added step to correct GRAD_DIR with the AZIMUTH angle
;     AUG 24, 2016 - KJWH: Corrected HAS() error - IF HAS(STR,'INFILE') THEN IFILE = [IFILE, STR.INFILE] \
;     SEP 09. 2016 - KJWH: Changed HAS() to STRUCT_HAS() - much quicker routine
;     SEP 14. 2016 - JEOR: Removed keyword STAT_TRANSFORM [No need to LOG-TRANSFORM at any time]
;                          Removed IF KEY(PROD_INFO.LOG)  THEN _STAT_TRANSFORM = 'ALOG'
;                          Removed PROD_INFO = PRODS_READ(APROD)
;                          Two separate for loops are required for STATS_ARRAYS to work properly [ONE FOR GRAD_X, ONE FOR GRAD_Y -otherwise data in memory (sums etc.) are corrupted]
;     SEP 15, 2016 - KJWH: Added a step to check that the INPUT files match those in the STAT file before skipping
;                          Now accumulating the list of original input files (i.e. the .nc files) and adding them to the structre as NCFILES
;     SEP 16, 2016 - KJHW: Now transforming the CHLOR_A (i.e. GRAD_MAG_RATIO) data prior to calculating the stats for GRAD_X and GRAD_y then untransforming the results before saving
;     SEP 19, 2016 - KJWH: Changed INFILES=IFILE to INFILES=INFILES in STRUCT_WRITE
;     SEP 27, 2916 - KJWH: Added a IDLTYPE() check for when reading the STAT_FILE to check the list of L2FILES.  If the file can't be read, delete and remake.
;     OCT 14, 2016 - KJWH: Now writing out GRAD_CHL and GRAD_SST in the structure instead of GRAD_MAG
;                          Added a check to make sure the product is either CHL or SST.  If there is a different input product, then will need to update the code accordingly.
;     OCT 18, 2016 - KJWH: Added keyword FORCE_STATS to force the program to check the input files in the STAT_FILES if all of the output STAT_FILES exist
;     MAR 21, 2018 - KJWH: Added REVERSE_FILES to reverse the order of the period sets output
;     MAY 16, 2018 - KJWH: Updated formatting and code to be consistent with STATS_ARRAYS_PERIODS
;                          Now using STATS_ARRAYS_XYZ to run the X stats and the Y stats at the same time.  This eliminates the need to open a file twice.
;                          Added JEOR's probability stat
;     AUG 09, 2019 - KJWH: Changed DATATYPE() to IDLTYPE()
;
;#################################################################################
;-
;	***********************************
  ROUTINE_NAME='STATS_ARRAYS_FRONTS'
; ***********************************
  SL = PATH_SEP()

  IF KEY(OVERWRITE)  THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
  IF NONE(FILES)     THEN  MESSAGE,'ERROR: INPUT FILES MUST BE PROVIDED'
  IF NONE(DATERANGE) THEN DATERANGE = ['19810101','21001231']
  
  IF NONE(DO_STATS)  THEN DO_STATS = ['MEAN','NUM']
  IF NONE(KEY_STAT)  THEN _KEY_STAT = 'MEAN' ELSE _KEY_STAT = KEY_STAT
  IF NONE(FILE_LABEL) THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0]) ELSE _FILE_LABEL=FILE_LABEL
  DO_STATS = DO_STATS[UNIQ(DO_STATS,SORT(DO_STATS))] ; REMOVE REDUNDANT STATS
  
  FN = PARSE_IT(FILES,/ALL)
  NAMES = FN.NAME
  IF KEY(VERBOSE) THEN PN, FILES,'  STATS SAVE FILES IN: '+ FIRST(FN.DIR)
  IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FN[0].DIR,'SAVE','STATS') & DIR_TEST, DIR_OUT ; DEFAULT LOCATION FOR OUTPUT STATS
  IF SAME(FN.EXT) EQ 0 THEN MESSAGE, 'ERROR: ALL FILES MUST HAVE THE SAME EXTENSION'
  IF SAME(FN.PERIOD_CODE) EQ 0 THEN MESSAGE,'INPUT FILES ARE NOT FROM THE SAME PERIOD'
  
  
  MAPS = VALIDS('MAPS',NAMES)
  IF SAME(MAPS) THEN MP = MAPS[0] ELSE MESSAGE, 'ALL FILES MUST BE HAVE THE SAME MAP'
  IF HAS(MP,'L3B') THEN MESSAGE, 'ERROR: L3B FILES ARE NOT COMPATIBLE WITH STATS_ARRAYS_FRONTS'  ; Need to update code to work with L3B files LEVEL = 'L3' ELSE LEVEL = '' ; DETERMINE IF THE FILES ARE L3B TO LOOK FOR BINS
  AREA  = MAPS_PIXAREA(MP, WIDTHS=WIDTH, HEIGHTS=HEIGHT, AZIMUTH=AZIMUTH) ; Get the pixel distances and azimuth angle
  
  APROD = VALIDS('PRODS',NAMES[0])
  IF SAME(VALIDS('PRODS',NAMES)+VALIDS('ALGS',NAMES)) EQ 0 THEN  MESSAGE, 'PROD-ALG NAME NOT CONSISTENT IN ALL FILES'
  IF APROD NE 'GRAD_CHL' AND APROD NE 'GRAD_SST' THEN MESSAGE, 'ERROR: UNRECOGNIZED INPUT PRODUCT (' + APROD +')'
  
  CASE APROD OF
    'GRAD_CHL': BEGIN & TRANSFORM='ALOG' & MIN_GRAD_PROB=1.09 & END 
    'GRAD_SST': BEGIN & TRANSFORM=''     & MIN_GRAD_PROB=0.10 & END 
    ELSE: MESSAGE, 'ERROR: Unrecognized input product'
  ENDCASE
  IF NONE(MIN_GRAD) THEN MIN_GRAD = MIN_GRAD_PROB
  
  JULIAN = PERIOD_2JD(FN.PERIOD)
  SETS=PERIOD_SETS(JULIAN,DATA=FILES,PERIOD_CODE=PERIOD_CODE_OUT,LABEL=LABEL,JD_START=DATE_2JD(DATERANGE[0]),JD_END=DATE_2JD(DATERANGE[1]),DEC=START_DECEMBER,/NESTED) ; GET THE SETS FOR THIS PERIOD_CODE_OUT
  IF SETS EQ [] THEN BEGIN
    PRINT,' FOUND NO FILES TO PROCESS FOR PERIOD:   ', PERIOD_CODE_OUT
    GOTO,DONE
  ENDIF
  
  TAGNAMES =  TAG_NAMES(SETS)
  IF KEY(REVERSE_FILES) THEN TAGNAMES = REVERSE(TAGNAMES) ; Process the stat files in reverse order
  P,TAGNAMES
  
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR TAG = 0,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
    TAGNAME=TAGNAMES(TAG) 
    TPOS = WHERE(TAG_NAMES(SETS) EQ TAGNAME,/NULL,COUNT_TAG) & IF COUNT_TAG NE 1 THEN STOP
  
    STAT_FILE = DIR_OUT + TAGNAME + '-' + _FILE_LABEL+ '-'+'STATS' + '.SAV'
    STAT_FILE = REPLACE(STAT_FILE,'--','-') ;====> REPLACE '--'
    INFILES   = STRING(SETS.(TPOS))
    NFILES    = N_ELEMENTS(INFILES)
  
    IF NFILES EQ 0 THEN CONTINUE
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 AND ~KEY(INIT) THEN CONTINUE         ; Skip if STAT_FILE is newer than the input files and INIT keyword is not set
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 1 AND EXISTS(STAT_FILE) THEN FILE_DELETE, STAT_FILE,/VERBOSE ; Delete STAT_FILE if newer files exist
  
    IF EXISTS(STAT_FILE) THEN BEGIN ; ===> If the STAT file exists, make sure the INPUT files match
      TMP = STRUCT_READ(STAT_FILE,STRUCT=TSTR)
      IF IDLTYPE(TMP) NE 'STRING' THEN BEGIN
        IF STRUCT_HAS(TSTR,'INFILES') THEN OK = WHERE_MATCH((PARSE_IT(INFILES)).NAME_EXT,(PARSE_IT(TSTR.INFILES)).NAME_EXT,COUNT) $
        ELSE stop ; FIX if INFILES not found in SAV OK = WHERE_MATCH((PARSE_IT(INFILES)).NAME_EXT,(PARSE_IT(TSTR.NCFILES)).NAME_EXT,COUNT)
      ENDIF ELSE COUNT = 0
      IF COUNT NE NFILES THEN FILE_DELETE, STAT_FILE, /VERBOSE
    ENDIF
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 THEN CONTINUE
    PRINT, '     Calculating stats for product:  ', APROD ,'  for period: ',TAGNAME
    IF KEY(VERBOSE) THEN PFILE,TAGNAME,/M
    NOTES = []
  
    FOR NTH=0,N_ELEMENTS(INFILES) -1L DO BEGIN
      ; ===>SET KEYWORDS FOR STATS_ARRAYS
      START=0
      CALC=0
      IF NTH EQ 0         THEN START=1
      IF NTH EQ NFILES-1L THEN CALC=1
      IF KEY(VERBOSE) THEN POF,NTH,N_ELEMENTS(INFILES)
  
      PFILE,INFILES[NTH],/R
      D = STRUCT_READ(INFILES[NTH], STRUCT=STR)
      IF IDLTYPE(D) EQ 'STRING' THEN MESSAGE, D
      
      IF HAS(STR,'GRAD_X',/EXACT) THEN GRAD_X = STR.GRAD_X ELSE GRAD_X = STR.MEAN_GRAD_X
      IF HAS(STR,'GRAD_Y',/EXACT) THEN GRAD_Y = STR.GRAD_Y ELSE GRAD_Y = STR.MEAN_GRAD_Y
        
      IF NTH EQ 0 THEN BEGIN
        SZ = SIZEXYZ(D,PX=PX,PY=PY)
        COUNT_VALID = FLTARR(PX,PY)
        COUNT_PROB  = FLTARR(PX,PY)
      ENDIF
      
      OK_VALID = WHERE(D NE MISSINGS(D),/NULL)
      COUNT_VALID(OK_VALID) = COUNT_VALID + 1
      
      OK_GOOD = WHERE(D NE MISSINGS(D) AND D GE MIN_GRAD,/NULL,COUNT_GOOD,COMPLEMENT=OK_BAD)
      COUNT_PROB(OK_GOOD)  = COUNT_PROB  + 1
      GRAD_X(OK_BAD) = MISSINGS(GRAD_X)
      GRAD_Y(OK_BAD) = MISSINGS(GRAD_Y)
      
      STAT = STATS_ARRAYS_XYZ(XDATA=GRAD_X,XTRANSFORM=TRANSFORM,XSTART=START,XCALC=CALC,XSTATS=DO_STATS,$
                              YDATA=GRAD_Y,YTRANSFORM=TRANSFORM,YSTART=START,YCALC=CALC,YSTATS=DO_STATS);,$
                            ;  ZDATA=GRAD_P,ZTRANSFORM='',       ZSTART=START,ZCALC=CALC,ZSTATS=DO_STATS) ; THE Z DATA ARE THE PROBABILITY DATA (GRAD_P)
    ENDFOR ;FOR NTH=0,N_ELEMENTS(INFILES) -1L DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  
    IF TRANSFORM EQ 'ALOG' THEN GRAD_X = ALOG(STAT.X.MEAN) ELSE GRAD_X = STAT.X.MEAN ; NOTE - The data are untransformed in STATS_ARRAYS
    IF TRANSFORM EQ 'ALOG' THEN GRAD_Y = ALOG(STAT.Y.MEAN) ELSE GRAD_Y = STAT.Y.MEAN
    
    ; ===> CALCULATE FRONTAL PROBABILITY
    PROB = COUNT_PROB/COUNT_VALID
    PROB(WHERE(COUNT_PROB EQ 0.0,/NULL)) = MISSINGS(0.0)
  
    ; ===> CACLULATE MEAN GRAD_MAG
    GRAD_MAG = SQRT(GRAD_X^2 + GRAD_Y^2)
    
    ; ===> CALCULATE FRONTAL PERSISTENCE (WEIGHTED GRAD_MAG)
    PERSIST = GRAD_MAG*PROB
  
    ; ===> CALCULATE AND CORRECT MEAN GRAD_DIR
    GRAD_DIR = ATAN(INFINITY_2NAN(GRAD_Y), INFINITY_2NAN(GRAD_X))
  
    ; ===> CHANGE RADIANS TO DEGREES
    GRAD_DIR = (GRAD_DIR)*!RADEG
    OK = WHERE(GRAD_DIR LT 0,COUNT)
  
    ;===> ADJUST TO A 0-360 DEGREES SCHEME (I.E. MAKE NEGATIVE DEGREES POSITIVE)
    IF COUNT GE 1 THEN GRAD_DIR[OK] = 360 - ABS(GRAD_DIR[OK])
  
    ;===> CORRECT GRAD_DIR FOR THE AZIMUTH ANGLE
    GRAD_DIR = GRAD_DIR - AZIMUTH
  
    IF TRANSFORM EQ 'ALOG' THEN BEGIN
      GRAD_X = EXP(GRAD_X)
      GRAD_Y = EXP(GRAD_Y)
      GRAD_MAG = EXP(GRAD_MAG)
    ENDIF
  
    STRUCT = CREATE_STRUCT('GRAD_X',GRAD_X, 'GRAD_Y',GRAD_Y, 'GRAD_MAG',GRAD_MAG, 'GRAD_DIR',GRAD_DIR,'GRAD_PROB',GRAD_P,'NUM',STAT.X.NUM)
    STRUCT = STRUCT_RENAME(STRUCT,'GRAD_MAG',APROD) ; RENAME THE GRADIENT MAGNITUDE TO EITHER GRAD_CHL OR GRAD_SST
  
    STRUCT_WRITE, STRUCT, FILE=STAT_FILE, STATS=STRJOIN(DO_STATS,'_'), INFILES=INFILES
  ENDFOR; FOR TAG = 0,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  DONE:
END; #####################  END OF ROUTINE ################################
