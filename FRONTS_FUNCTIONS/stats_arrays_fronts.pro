; $ID:	STATS_ARRAYS_FRONTS.PRO,	2023-09-21-13,	USER-KJWH	$
;#############################################################################################################
PRO STATS_ARRAYS_FRONTS, FILES, DIR_OUT=DIR_OUT, PERIOD_CODE_OUT=PERIOD_CODE_OUT, FILE_LABEL=FILE_LABEL,LOGLUN=LOGLUN,$
  DO_STATS=DO_STATS, KEY_STAT=KEY_STAT, MIN_GRAD=MIN_GRAD, DATERANGE=DATERANGE, REVERSE_FILES=REVERSE_FILES, $
  OVERWRITE=OVERWRITE, VERBOSE=VERBOSE, THUMBNAILS=THUMBNAILS
;+
; NAME:
;		STATS_ARRAYS_FRONTS
;
; PURPOSE: 
;   Compute statistics of fronts from multiple files
;
; CATEGORY:
;		FRONTS & STATS
;
; CALLING SEQUENCE: 
;   STATS_ARRAYS_FRONTS, FILES
;
; REQ!UIRTED INPUTS:
;		FILES.............. Files generated with FRONTS_BOA each containing a nested structure with:
;                         GRAD_MAG (gradient magnitude);
;                         GRAD_X (gradient in horizontal direction);
;                         GRAD_Y (gradient in vertical direction);
;                         GRAD_DIR (gradient direction, in degrees);
;                         FILTERED_PIXELS (pixels removed by MF3_1D_5PT).
;
; OPTIONAL INPUTS:
;   DIR_OUT............ Directory for statistical output files
;   PERIOD_CODES_OUT... Period codes for the output statistics
;   FILE_LABEL......... A string of key-identifying attributes in the output files [e.g. MAP-METHOD-PROD]
;   LOGLUN............. If provided, then lun for the log file
;   DO_STATS........... A list of stat types to calculate [e.g. DO_STATS = ['NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV']
;   KEY_STAT........... The stat type used to process for the next period [default = MEAN]
;   MIN_GRAD........... The lower gradient magnitude threshold value to represent a front (i.e. minimum gradient value) for the probability calculation
;   DATERANGE.......... To subset the files to a specified daterange		
;
; KEYWORDS:
;   REVERSE_FILES...... Reverse the processing order of the output files
;   OVERWRITE.......... Overwrite output sav files
;		VERBOSE............ Print program progress
;		THUMBNAILS......... Create thumbnail images
;
; OUTPUTS:
;   A sav file with the statistics in a nested structure
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
;   Input files must contain the GRAD_X and GRAD_Y variables
; 
; EXAMPLES:
;
;	NOTES:
;  Adapted from STATS_ARRAYS_PERIODS, STATS_ARRAYS_PERIODS_FRONTS and STATS_FRONTS
;
; COPYRIGHT:
; Copyright (C) 2016, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 22, 2016 by Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquires can be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;			AUG 22, 2016 - KJWH: Initial code adapted from STATS_ARRAYS_PERIODS, STATS_ARRAYS_PERIODS_FRONTS and STATS_FRONTS
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
;     AUG 16, 2018 - KJWH: Added THUMBNAILS keyword and code to produce a THUMBNAIL image of the GRAD_CHL or GRAD_SST stats 
;     JUL 22, 2019 - KJWH: Added LOGLUN keyword, changed PRINT to PLUN, LOG_LUN, and added LOGLUN to POF, PFILE commands                  
;     MAR 15, 2021 - KJWH: Updated documentation
;                          Added COMPILE_OPT IDL2
;                          Changed subscript () to []
;                          Added logical steps to find the correct GRAD_X and GRAD_Y tags in the structure
;                          Now outputing the GRAD_X and GRAD_Y data as GRAD_SSX/GRAD_CHLX and GRAD_SSTY/GRAD_CHLY
;                          Moved to FRONTS_FUNCTIONS
;-
;	*****************************************************************************************
  ROUTINE_NAME='STATS_ARRAYS_FRONTS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  IF KEY(OVERWRITE)  THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
  IF NONE(FILES)     THEN  MESSAGE,'ERROR: Input files must be provided'
  IF NONE(DATERANGE) THEN DATERANGE = ['19810101','21001231']
  
  IF NONE(DO_STATS)  THEN DO_STATS = ['MEAN','NUM']
  IF NONE(KEY_STAT)  THEN _KEY_STAT = 'MEAN' ELSE _KEY_STAT = KEY_STAT
  IF NONE(FILE_LABEL) THEN _FILE_LABEL=FILE_LABEL_MAKE(FILES[0]) ELSE _FILE_LABEL=FILE_LABEL
  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN

  DO_STATS = DO_STATS[UNIQ(DO_STATS,SORT(DO_STATS))] ; REMOVE REDUNDANT STATS
  
  FN = PARSE_IT(FILES,/ALL)
  NAMES = FN.NAME
  IF KEY(VERBOSE) THEN PLUN, LOG_LUN, NUM2STR(N_ELEMENTS(FILES)),'  STATS SAVE FILES IN: '+ FIRST(FN.DIR)
  IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FN[0].DIR,'SAVE','STATS') & DIR_TEST, DIR_OUT ; DEFAULT LOCATION FOR OUTPUT STATS
  DIR_THUMB = DIR_OUT + 'THUMBNAILS' + SL & DIR_TEST, DIR_THUMB
  IF SAME(FN.EXT) EQ 0 THEN MESSAGE, 'ERROR: ALL FILES MUST HAVE THE SAME EXTENSION'
  IF SAME(FN.PERIOD_CODE) EQ 0 THEN MESSAGE,'INPUT FILES ARE NOT FROM THE SAME PERIOD'
  
  MAPS = VALIDS('MAPS',NAMES)
  IF SAME(MAPS) THEN MP = MAPS[0] ELSE MESSAGE, 'ALL FILES MUST BE HAVE THE SAME MAP' 
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
  SETS=PERIOD_SETS(JULIAN,DATA=FILES,PERIOD_CODE=PERIOD_CODE_OUT,JD_START=DATE_2JD(DATERANGE[0]),JD_END=DATE_2JD(DATERANGE[1]),/NESTED) ; GET THE SETS FOR THIS PERIOD_CODE_OUT
  IF SETS EQ [] THEN BEGIN
    PLUN, LOG_LUN,' FOUND NO FILES TO PROCESS FOR PERIOD:   ', PERIOD_CODE_OUT
    GOTO,DONE
  ENDIF
  
  TAGNAMES =  TAG_NAMES(SETS)
  IF KEY(REVERSE_FILES) THEN TAGNAMES = REVERSE(TAGNAMES) ; Process the stat files in reverse order
  PLUN, LOG_LUN,TAGNAMES
  
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR TAG = 0,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
    TAGNAME=TAGNAMES[TAG] 
    TPOS = WHERE(TAG_NAMES(SETS) EQ TAGNAME,/NULL,COUNT_TAG) & IF COUNT_TAG NE 1 THEN STOP
  
    STAT_FILE = DIR_OUT + TAGNAME + '-' + _FILE_LABEL+ '-'+'STATS' + '.SAV'
    STAT_FILE = REPLACE(STAT_FILE,'--','-') ;====> REPLACE '--'
    INFILES   = STRING(SETS.(TPOS))
    NFILES    = N_ELEMENTS(INFILES)
  
    IF NFILES EQ 0 THEN CONTINUE
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 THEN GOTO, MAKE_THUMBNAIL         ; Skip if STAT_FILE is newer than the input files and INIT keyword is not set
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 1 AND EXISTS(STAT_FILE) THEN FILE_DELETE, STAT_FILE,/VERBOSE ; Delete STAT_FILE if newer files exist
  
    IF EXISTS(STAT_FILE) THEN BEGIN ; ===> If the STAT file exists, make sure the INPUT files match
      TMP = STRUCT_READ(STAT_FILE,STRUCT=TSTR)
      IF IDLTYPE(TMP) NE 'STRING' THEN BEGIN
        IF STRUCT_HAS(TSTR,'INFILES') THEN OK = WHERE_MATCH((PARSE_IT(INFILES)).NAME_EXT,(PARSE_IT(TSTR.INFILES)).NAME_EXT,COUNT) $
        ELSE stop ; FIX if INFILES not found in SAV OK = WHERE_MATCH((PARSE_IT(INFILES)).NAME_EXT,(PARSE_IT(TSTR.NCFILES)).NAME_EXT,COUNT)
      ENDIF ELSE COUNT = 0
      IF COUNT NE NFILES THEN FILE_DELETE, STAT_FILE, /VERBOSE
    ENDIF
    
    IF FILE_MAKE(INFILES,STAT_FILE,OVERWRITE=_OVERWRITE) EQ 0 THEN GOTO, MAKE_THUMBNAIL
    PLUN, LOG_LUN, '     Calculating stats for product:  '+ APROD +'  for period: '+TAGNAME
    IF KEY(VERBOSE) THEN PFILE,TAGNAME,/M, LOGLUN=LOG_LUN
    NOTES = []
  
    FOR NTH=0,N_ELEMENTS(INFILES) -1L DO BEGIN
      ; ===>SET KEYWORDS FOR STATS_ARRAYS
      START=0
      CALC=0
      IF NTH EQ 0         THEN START=1
      IF NTH EQ NFILES-1L THEN CALC=1
      IF KEY(VERBOSE) THEN POF,NTH,N_ELEMENTS(INFILES),LOGLUN=LOG_LUN
  
      PFILE,INFILES[NTH],/R, LOGLUN=LOG_LUN
      D = STRUCT_READ(INFILES[NTH], STRUCT=STR)
      IF IDLTYPE(D) EQ 'STRING' THEN MESSAGE, D
      
      CASE STR.PROD OF
        'GRAD_MAG': BEGIN & GRAD_XTAG = 'GRAD_X'    & GRAD_YTAG = 'GRAD_Y'    & MGRAD_XTAG = 'MEAN_GRAD_X'    & MGRAD_YTAG = 'MEAN_GRAD_Y'    & END
        'GRAD_SST': BEGIN & GRAD_XTAG = 'GRADX_SST' & GRAD_YTAG = 'GRADY_SST' & MGRAD_XTAG = 'MEAN_GRADX_SST' & MGRAD_YTAG = 'MEAN_GRADY_SST' & END
        'GRAD_CHL': BEGIN & GRAD_XTAG = 'GRADX_CHL' & GRAD_YTAG = 'GRADY_CHL' & MGRAD_XTAG = 'MEAN_GRADX_CHL' & MGRAD_YTAG = 'MEAN_GRADY_CHL' & END
      ENDCASE
      
      GTAGS = TAG_NAMES(STR)
      OKX = WHERE(GTAGS EQ GRAD_XTAG,COUNTX) & OKMX = WHERE(GTAGS EQ MGRAD_XTAG,COUNTMX) & IF COUNTX+COUNTMX NE 1 THEN MESSAGE, 'ERROR: Check the GRAD_X tags'
      OKY = WHERE(GTAGS EQ GRAD_YTAG,COUNTY) & OKMY = WHERE(GTAGS EQ MGRAD_YTAG,COUNTMY) & IF COUNTY+COUNTMY NE 1 THEN MESSAGE, 'ERROR: Check the GRAD_Y tags'
      
      IF COUNTX EQ 1 THEN GRAD_X = STR.(OKX) ELSE GRAD_X = STR.(OKMX)
      IF COUNTY EQ 1 THEN GRAD_Y = STR.(OKY) ELSE GRAD_Y = STR.(OKMY)
      
      IF IS_L3B(MP) THEN BEGIN
        GRAD_X = MAPS_L3B_2ARR(GRAD_X, MP=MP, BINS=STR.BINS)
        GRAD_Y = MAPS_L3B_2ARR(GRAD_Y, MP=MP, BINS=STR.BINS)
      ENDIF
        
      STAT = STATS_ARRAYS_XYZ(XDATA=GRAD_X,XTRANSFORM=TRANSFORM,XSTART=START,XCALC=CALC,XSTATS=DO_STATS,$
                              YDATA=GRAD_Y,YTRANSFORM=TRANSFORM,YSTART=START,YCALC=CALC,YSTATS=DO_STATS);,$
    ENDFOR ;FOR NTH=0,N_ELEMENTS(INFILES) -1L DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    
    IF TRANSFORM EQ 'ALOG' THEN GRAD_X = ALOG(STAT.X.MEAN) ELSE GRAD_X = STAT.X.MEAN ; NOTE - The data are untransformed in STATS_ARRAYS
    IF TRANSFORM EQ 'ALOG' THEN GRAD_Y = ALOG(STAT.Y.MEAN) ELSE GRAD_Y = STAT.Y.MEAN
  
    ; ===> CACLULATE MEAN GRAD_MAG
    GRAD_MAG = SQRT(GRAD_X^2 + GRAD_Y^2)
  
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
  
    CASE APROD OF
      'GRAD_SST': STRUCT = CREATE_STRUCT('GRADX_SST',GRAD_X, 'GRADY_SST',GRAD_Y, 'GRAD_SST',GRAD_MAG, 'GRAD_DIR',GRAD_DIR,'NUM',STAT.X.NUM)
      'GRAD_CHL': STRUCT = CREATE_STRUCT('GRADX_CHL',GRAD_X, 'GRADY_CHL',GRAD_Y, 'GRAD_CHL',GRAD_MAG, 'GRAD_DIR',GRAD_DIR,'NUM',STAT.X.NUM)
      ELSE: MESSAGE, 'ERROR: Unrecognized APROD'
    ENDCASE

    IF IS_L3B(MP) THEN BEGIN
      OK_NUM = WHERE(STRUCT.NUM GT 0 AND STRUCT.NUM NE MISSINGS(STRUCT.NUM),COUNT_BINS)        ; Find pixels where NUM is greater than 0 and not MISSINGS
      IF COUNT_BINS GE 1 THEN BEGIN
        TAGS = TAG_NAMES(STRUCT)                                                               ; Get the tag names of the structure
        STR  = CREATE_STRUCT('BINS',OK_NUM,'NBINS',COUNT_BINS,'TOTAL_BINS',MAPS_L3B_NBINS(MP)) ; Create a new stat structure with BIN info
        FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                                   ; Loop through the STRUCT tags
          SUBSET = STRUCT.(T)                                                                  ; Get the data from the tag
          SUBSET = SUBSET[OK_NUM]                                                              ; Subset the data to be only those pixels where NUM great than 0 (and not MISSINGS)
          STR = CREATE_STRUCT(STR,TAGS[T],SUBSET)                                              ; Add subset to the new structure
        ENDFOR
        STRUCT = STR & GONE, STR                                                               ; Rename the structure                                              
      ENDIF
    ENDIF
  
    STRUCT_WRITE, STRUCT, FILE=STAT_FILE, STATS=STRJOIN(DO_STATS,'_'), INFILES=INFILES
    
    ; ===> MAKE THUMBNAIL IMAGE
    MAKE_THUMBNAIL:
    IF KEY(THUMBNAILS) THEN BEGIN
      IF IS_L3B(MP) THEN OMAP = 'NWA' ELSE OMAP = MP
      PRODS_2PNG, STAT_FILE, /THUMBNAIL, DIR_OUT=DIR_THUMB, BUFFER=1, /ADD_CB, MAPP=OMAP
    ENDIF
  ENDFOR; FOR TAG = 0,N_ELEMENTS(TAGNAMES)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  DONE:
END; #####################  END OF ROUTINE ################################
