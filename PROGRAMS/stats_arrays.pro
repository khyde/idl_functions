; $ID:	STATS_ARRAYS.PRO,	2020-08-04-17,	USER-KJWH	$
;#############################################################################################
 FUNCTION STATS_ARRAYS,	DAT, STAT_STRUCT=STAT_STRUCT, RETURN_STRUCT=RETURN_STRUCT, TRANSFORM=TRANSFORM, START=START,	CALC=CALC, RANGE=RANGE, OPER=OPER, CRITERIA_TXT=CRITERIA_TXT, MISSING=MISSING, DO_STATS=DO_STATS, SUBS=SUBS, ERROR=ERROR
;+
; NAME:
;   STATS_ARRAYS
;
; PURPOSE:
;	  Compute statistics [NUM, MIN, MAX, NEG, SUM, SPAN, SSQ, MEAN, STD, CV] for each pixel from a series of of 2D data arrays
;
; CATEGORY:
;   Statistics
;
; INPUTS:
;   DAT......... 2D array of data [data must be provided every call to STATS_ARRAYS]
;                   
; KEYWORDS:
;	  TRANSFORM....... Must provide 'ALOG' or 'ALOG10' each time START is used to initialize COMMON STATS_ARRAYS_TRANSFORM, but is not needed in subsequent calls to STATS_ARRAYS [assumes same transform applies]
; 	START........... Must provide /START or START=1 (and DATA) in the first call to STATS_ARRAYS to initialize the statistics arrays => Subsequent calls to STATS_ARRAYS should not use the START keyword
;		CALC............ Calculates statistics and returns them in a single structure => Note that if no data are provided and CALC keyword is set, then statistics are finalized based on all previous data inputs.
;		RANGE........... The allowable range [GE, LE] for the data to be used in the statistical arrays - DEFAULT RANGE IS [-INF,+INF] => NOTE: If TRANSFORM ='ALOG' or 'ALOG10' then data values LE to 0.0 will be ignored.
;		MISSING......... Value to be ignored in the statistics (e.g. -999) => NOTE: This routine will also ignore any data values equal to the operationally-defined missing data codes appropriate for the data data type (see MISSINGS.PRO)	
; 	DO_STATS........ The list of stats to calculate: STAT_TYPES = ['NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','GMEAN','STD','CV'] => NOTE: NUM will always be calculated even if not requested. To conserve memory memory arrays are made only for the stats requested in DO_STATS
;   RETURN_STRUCT... If set, copy the temp/final stat structure into STAT_STRUCT
;
; OUTPUTS:
;   Returns the cumulative number of calls to STATS_ARRAYS, an ERROR STRING if error is encountered, or a structure with statistical results when the CALC keyword is set
;
; OPTIONAL OUTPUTS:
;		STAT_STRUCT... A structure to hold a copy of the COMMON structure (used in STATS_ARRAYS_XYZ)
;		ERROR......... Any error messages are placed in ERROR and returned => If no errors then ERROR = ''
;		SUBS.......... The subscripts of the valid data used in the statistical calculations
;
; PROCEDURE:
;				The first call to stats_arrays should provide 1) DATA and 2) the START keyword
;				3) TRANSFORM if data should be 'ALOG' OR 'ALOG10' prior to calculating the stats => NOTE: stats are antilogged in the output structure
;				4) RANGE (if needed) default range is [-inf,+inf]
;				5) MISSING DATA CODE: (if needed) default is to use codes from missings.pro
;				6) Subsequent calls to stats_arrays only require the DATA => RANGE, MISSING, and TRANSFORM are ignored and assumed to be the same as in the initiallizing (START) call
;				7) Use the keyword CALC to return all stats [in DO_STATS] in a single structure
;				8) CALC may be used any time to see the results in the structure, even after the first call 
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly DOC/NOAA/NMFS/NEFSC Narragansett, RI, 
;       with updated by Kimberly Hyde DOC/NOAA/NMFS/NEFSC Narragansett, RI kimberly.hyde@noaa.gov
;			
;				
;
; MODIFICATION HISTORY:
;       Written:  August 6,  2004 by J.E. O'Reilly NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882
;				Modified: FEB 6,  2005 - JEOR: STREAMLINED, USE COMPOUND OPERATORS FOR EFFICIENCY
;				          FEB 21, 2007 - JEOR: REMOVED NUM_SHM,	 MIN_SHM,	MAX_SHM,	NEG_SHM,	SUM_SHM, 	SSQ_SHM,	WTS_SHM,	MEAN_SHM,		STD_SHM,	CV_SHM FROM COMMON
;				          FEB 12, 2013 - JEOR: CHANGED REMAINDER TO _REMAINDER TO AVOID CONFLICT WITH IDL'S REMAINDER [SCRABBLE]
;				                               ANTILOG ANY LOG-TRANSFORMED DATA [TAKEN FROM STATS_ARRAYS -DEC 14,2011] 
;                                      IF  KEYWORD_SET(CALC) THEN DO_STRUCT = 1 ELSE DO_STRUCT = 0  ;>>>>>>>>>
;                 MAR 10, 2013 - JEOR: FIXED WHEN ONLY NUM IS DONE AND NO MEAN :
;                                      IF WHERE(STATS_2DO EQ 'MEAN')  NE -1 THEN BEGIN
;                                      IF WHERE(STATS_2DO EQ 'NUM')  NE -1 THEN BEGIN
;                 MAR 14, 2013 - JEOR: REMOVED KEYWORD NAME[NOT USED];  STATS_ARRAYS_NAME = ROUTINE_NAME 
;                 APR 17, 2013 - JEOR: CHANGED  MAX_SIZE = 4320*2160UL 
;                 AUG 10, 2013 - JEOR: ADDED SPAN 
;                 AUG 11, 2013 - JEOR: FIXED LOGIC FOR COMMON STATS_ARRAYS_TRANSFORM
;                                      REMOVED KEYWORD STRUCT [NOT NEEDED SINCE /CALC ALWAYS FORCES AN OUTPUT STRUCTURE TO BE RETURNED]
;                 AUG 20, 2013 - JEOR: FIXED LOGIC FOR SPAN WHEN TRANSFORM =ALOG OR ALOG10
;                                      DELETED: IF WHERE(STATS_2DO EQ 'SPAN')  NE -1 THEN STRUCT.SPAN  = EXP(STRUCT.SPAN)
;                 NOV 11, 2013 - JEOR: MAJOR CHANGE TO RETURN ONLY THE STATS REQUESTED IN DO_STATS [TO SPEED UP READING AND WRITING LARGE GLOBAL ARRAYS]
;                 MAR 21, 2014 - JEOR: IF N_ELEMENTS(DO_STATS) EQ 0 OR FIRST(DO_STATS) EQ '' THEN BEGIN
;                 NOV 26, 2014 - KJWH: FIXED "COUNT" BUG AT LINE 398 (REPLACED COUNT WITH COUNT_1)
;                                      FIXED DO_STRUCT BUG AND MOVED "IF  KEYWORD_SET(CALC) THEN DO_STRUCT = 1 ELSE DO_STRUCT = 0 " TO AFTER "CALCULATE:"
;                 DEC 13, 2014 - JEOR  FORMATTING                                     
;                 SEP 13, 2016 - KJWH: When using the default "MISSINGS" range to determine the good data, make the STATS_ARRAYS_OPER = ['GT','LT'].  Otherwise it will return the MISSING values 
;                 OCT 07, 2016 - KJWH: Added SPAN_MEM to the COMMON_STATS_ARRAY
;                                        * This fixes a bug when there is no valid data in the last file read before doing the CALC step   
;                                          It should now retain the most recent SPAN_MEM
;                 JAN 04, 2016 - KJWH: Formatting
;                                      Changed instances of WHERE(xxx) NE -1 to HAS()
;                 MAR 11, 2019 - KJWH: Formatting    
;                 AUG 26, 2019 - KJWH: Updated formatting and comments   
;                                      Changed the DATA to DAT 
;                                      Changed the default MAX size to be the size of the 1 km MUR data (36000 x 17999) 
;                                      Now calculating the arithmetic mean and geometric mean separately so that both can be included in the structure          
;                 AUG 30, 2019 - KJWH: Overhauled STATS_ARRAYS
;                                        Now using a structure to hold the COMMON information
;                                        Calculating the LOG_STATS at the same time as the other stats
;                                        Streamlined code where possible using loops and CASE statements
;                                        Added documentation throughout
;                                      Added ,/EXACT to all HAS() calls   
;                 SEP 05, 2019 - KJWH: Added an option to input and output the temporary memory structure so that it will now work with STATS_ARRAYS_XYZ                                         
;                                        STAT_STRUCT contains the input temporary structure
;                                        RETURN_STRUCT will return the temporary structure to the calling program (i.e. STATS_ARRAYS_XYZ)                                                             
;                                      Now including LSUM and LNUM as output stats if SUM and NUM are requested and LOG_TRANSFORM is set 
;                 AUG 04, 2020 - KJWH: Added COMPILE_OPT IDL2
;                                      Changed subscript () to []                     
;#############################################################################################
;-
	ROUTINE_NAME='STATS_ARRAYS'
	COMPILE_OPT IDL2

; ===> Constants
  ERROR = ''
	NEG_INF = -MISSINGS(0.0)	
	POS_INF =  MISSINGS(0.0)
  MAX_SIZE = 36000*17999UL ; Changed from 4320*2160UL on 8/26/2019 by KJWH
  IF N_ELEMENTS(TRANSFORM) NE 1 THEN TRANSFORM = ''

; ===> Common memory structure  
  COMMON _STATS_ARRAYS, STRUCT
  IF KEY(START) THEN GONE, STRUCT ; Make sure to remove any structure in the COMMON when initializing a new struct

  IF ANY(STAT_STRUCT) THEN STRUCT = STAT_STRUCT

; ===> Allowable STAT_TYPES
  STAT_TYPES = ['NUM','LNUM','MIN','MAX','SPAN','NEG','WTS','SUM','LSUM','SSQ','LSSQ','MEAN','GMEAN','STD','GSTD','CV'] ; Added GMEAN on 8/26/2019 by KJWH
  LOG_STATS  = ['LNUM','LSUM','LSSQ','GMEAN','GSTD']
  
;	===> Check for requested DO_STATS, if none provided, calculate all stats (STAT_TYPES)
	IF NONE(DO_STATS) THEN BEGIN                    ; If no stats are requested, then calculate all stats
		STATS_2DO = STAT_TYPES                        ; STATS_2DO includes preliminary stats (e.g. SUM and SSQ) that are needed to calculate other stats (e.g. MEAN and STD)
		DO_STATS  = STAT_TYPES                        ; DO_STATS are the requested stats
		IF TRANSFORM EQ '' THEN TRANSFORM = 'ALOG'    ; Set TRANSFORM (default is ALOG) to calculate the "log" based statistics (i.e. geometric mean) 
	ENDIF ELSE BEGIN
		OK_STATS = WHERE_IN(STRUPCASE(DO_STATS),STAT_TYPES,COUNT_STATS, NCOMPLEMENT=NCOMPLEMENT, COMPLEMENT=COMPLEMENT) ; Find requested stats in the available list of stats
		IF NCOMPLEMENT GT 0 THEN BEGIN
		  ERROR = 'ERROR: The requested stats (' + DO_STATS(COMPLEMENT) + ') in DO_STATS are not a valid stat type.  Valid stats types are: ' + STRJOIN(STAT_TYPES,', ')
      PRINT,ERROR
		  RETURN,ERROR
		ENDIF 
		STATS_2DO = STRUPCASE(DO_STATS[OK_STATS])                       ; Removes any requested stats that are not in the allowed STAT_TYPES
		OK_LOG = WHERE_IN(LOG_STATS,STATS_2DO,COUNT_LOG)                ; Find if any "log" based statistics were requested
		IF COUNT_LOG GT 0 AND TRANSFORM EQ '' THEN TRANSFORM = 'ALOG'   ; If "log" based statistics (i.e. geometric mean) are requested, then make sure the TRANSFORM is set
	  		
;		===> Update the list of stat variables if needed to calculate some of the requested stats 
		IF HAS(STATS_2DO, 'MEAN',/EXACT) THEN STATS_2DO = [STATS_2DO,'NUM','SUM']              ; If MEAN is requested then must have SUM and NUM
		IF HAS(STATS_2DO, 'STD', /EXACT) THEN STATS_2DO = [STATS_2DO,'NUM','SUM','SSQ']        ; STD needs NUM, SUM and SSQ
		IF HAS(STATS_2DO, 'CV',  /EXACT) THEN STATS_2DO = [STATS_2DO,'NUM','SUM','SSQ','STD']  ; CV needs, NUM, SUM, SSQ and STD
    IF HAS(STATS_2DO, 'SPAN',/EXACT) THEN STATS_2DO = [STATS_2DO,'MIN','MAX']              ; SPAN needs the MIN and MAX
		
;   ===> Update the list of stat variables if needed to calculate the geometric mean or standard deviation or if TRANSFORM is ALOG or ALOG10		
		IF TRANSFORM EQ 'ALOG' OR TRANSFORM EQ 'ALOG10' THEN BEGIN
		  IF HAS(STATS_2DO, 'MEAN',/EXACT)  AND ~HAS(DO_STATS,'GMEAN',/EXACT) THEN STATS_2DO = [STATS_2DO,'GMEAN','LNUM','LSUM']
		  IF HAS(STATS_2DO, 'STD',/EXACT)   AND ~HAS(DO_STATS,'GSTD',/EXACT)  THEN STATS_2DO = [STATS_2DO,'GSTD', 'LNUM','LSUM','LSSQ']
      IF HAS(STATS_2DO, 'GMEAN',/EXACT) AND ~HAS(DO_STATS,'GMEAN',/EXACT) THEN DO_STATS = [DO_STATS,'GMEAN']
      IF HAS(STATS_2DO, 'GSTD',/EXACT)  AND ~HAS(DO_STATS,'GSTD',/EXACT)  THEN DO_STATS = [DO_STATS,'GSTD']
      IF HAS(DO_STATS, 'SUM',/EXACT)    AND ~HAS(DO_STATS,'LSUM',/EXACT)  THEN DO_STATS = [DO_STATS,'LSUM']
      IF HAS(DO_STATS, 'NUM',/EXACT)    AND ~HAS(DO_STATS,'LNUM',/EXACT)  THEN DO_STATS = [DO_STATS,'LNUM']
		ENDIF	
		IF N_ELEMENTS(WHERE(STATS_2DO EQ 'GMEAN',/NULL)) GT 0 THEN STATS_2DO = [STATS_2DO,'LNUM','LSUM']
		IF N_ELEMENTS(WHERE(STATS_2DO EQ 'GSTD',/NULL))  GT 0 THEN STATS_2DO = [STATS_2DO,'LNUM','LSUM','LSSQ']
		
		STATS_2DO = [STATS_2DO,'NUM']                                                   ; NUM should always be calculated

;		===> Re-sort STATS_2DO in the same order as STAT_TYPES so that the output structure always looks the same (this will also remove any duplicates)
		S = WHERE_IN(STAT_TYPES,STATS_2DO)
		STATS_2DO = STAT_TYPES[S]  
	ENDELSE ; Check for requested DO_STATS,

; ##################################################################################################################################################  
;	===> If ready to calculate the stats and create the final structure skip to CALCULATE
	IF NONE(DAT) AND KEY(CALC) THEN GOTO, CALCULATE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; ===> Check to make sure DATA is provided (CALC does not require data)
  IF N_ELEMENTS(DAT) EQ 0 THEN BEGIN
    ERROR = 'ERROR: Data array must be provided'
    PRINT,ERROR
    RETURN,ERROR
  ENDIF ; Check for DATA

; ##################################################################################################################################################
; ##################################################################################################################################################
;	##################################################################################################################################################
  IF KEY(START) THEN BEGIN          ; ##### I N I T I A L I Z E    S T A T I S T I C A L    A R R A Y S  ######
;   ===> The first DAT array determines the acceptable size of arrays thereafter
    STATS_ARRAYS_SZ = SIZEXYZ(DAT,PX=PX,PY=PY)
		
;   ====> If DATA is not 2D then error
    IF STATS_ARRAYS_SZ.N_DIMENSIONS NE 2 THEN BEGIN
    	ERROR = 'ERROR: DAT must be a 2D array'
      PRINT,ERROR
      RETURN,ERROR
    ENDIF;IF STATS_ARRAYS_SZ.N_DIMENSIONS NE 2 THEN BEGIN        

;		===> If RANGE is not provided, then RANGE will be from GE -INF to LE +INF
    IF N_ELEMENTS(OPER)  EQ 2 THEN STATS_ARRAYS_OPER  = OPER  ELSE STATS_ARRAYS_OPER  = ['GE','LE']
    IF N_ELEMENTS(RANGE) EQ 2 THEN STATS_ARRAYS_RANGE = RANGE ELSE BEGIN
      STATS_ARRAYS_RANGE = [-MISSINGS(DAT),MISSINGS(DAT)]      ; Default RANGE
      STATS_ARRAYS_OPER  = ['GT','LT']                         ; Rewrite the STATS_ARRAYS_OPER, otherwise it will include the MISSINGS data
    ENDELSE
 		
;		===> Check on missing value if not provided then it will be !VALUES.F_INFINITY
		IF N_ELEMENTS(MISSING) NE 1 THEN STATS_ARRAYS_MISSING = MISSINGS(0.0) ELSE STATS_ARRAYS_MISSING = MISSING

;   ===> Check on validity of transform
    STATS_ARRAYS_TRANSFORM = ''  ; Default TRANSFORM
    IF N_ELEMENTS(TRANSFORM) EQ 1 THEN IF STRUPCASE(TRANSFORM) EQ 'ALOG' OR STRUPCASE(TRANSFORM) EQ 'ALOG10' THEN STATS_ARRAYS_TRANSFORM = TRANSFORM 

;   ===> Fill in COMMON structure with initialized info so it is the same for subsequent calls    
    STRUCT = CREATE_STRUCT('STATS_ARRAYS_NAME',ROUTINE_NAME,$         ; Records the ROUTINE_NAME in the structure
                           'STATS_ARRAYS_SZ', STATS_ARRAYS_SZ,$       ; Array size information
                           'TRANSFORM', STATS_ARRAYS_TRANSFORM,$
                           'MISSING',STATS_ARRAYS_MISSING,$
                           'RANGE',STATS_ARRAYS_RANGE,$
                           'OPER',STATS_ARRAYS_OPER,$
                           'N_SETS',0L)                               ; Keeps track of the number of times/calls data are passed to program (initialize to 0)
  	
;   ===> Create blank arrays to be in the COMMON structure for the different stat types    
  	FOR N=0, N_ELEMENTS(STAT_TYPES)-1 DO BEGIN
  	  IF HAS(STATS_2DO,STAT_TYPES[N],/EXACT) THEN BEGIN
  	    CASE STAT_TYPES[N] OF
           'MIN':   ARR = REPLICATE(POS_INF,PX,PY)
  	       'MAX':   ARR = REPLICATE(NEG_INF,PX,PY)    
  	       'SPAN':  ARR = REPLICATE(POS_INF,PX,PY) 
  	       'WTS':   ARR = REPLICATE(1.0,    PX,PY)
  	       'MEAN':  ARR = REPLICATE(POS_INF,PX,PY)
  	       'GMEAN': ARR = REPLICATE(POS_INF,PX,PY)
  	       'SSTD':  ARR = REPLICATE(POS_INF,PX,PY)
  	       'GSTD':  ARR = REPLICATE(POS_INF,PX,PY)
  	       'CV':    ARR = REPLICATE(POS_INF,PX,PY)
  	       ELSE :   ARR = FLTARR(PX,PY)
  	    ENDCASE
  	    STRUCT = CREATE_STRUCT(STRUCT,STAT_TYPES[N],ARR)
  	  ENDIF
  	ENDFOR    			
  ENDIF ; IF KEY(START) THEN BEGIN
    
; ##################################################################################################################################################
; ##################################################################################################################################################
; ##################################################################################################################################################
; ################################################# C H E C K    I N P U T   D A T A  ##############################################################

; ===> Make sure START keyword has been previously provided to initialize the COMMON structure statistical arrays
  IF NONE(STRUCT) THEN BEGIN
    ERROR = 'ERROR: Must use keyword START to initialize the statistical arrays'
    PRINT,ERROR
    RETURN,ERROR
  ENDIF ;IF NONE(N_SETS) THEN BEGIN

; ===> Make sure COMMON STRUCT been initialized and N_SETS is in the structure    
  IF NONE(STRUCT.N_SETS) THEN BEGIN
    ERROR = 'ERROR: Must use keyword START to initialize the statistical arrays'
    PRINT,ERROR
    RETURN,ERROR
  ENDIF ;IF NONE(N_SETS) THEN BEGIN  
    
; ===> Add 1 to N_SETS to count the number of iterations through STATS_ARRAYS
  STRUCT.N_SETS = STRUCT.N_SETS + 1L

; ===>  Make sure DAT is same dimensions as has been previously provided (during initialization of N,SUM,SSQ arrays).
 	SZ_CHECK = SIZE(DAT,/STRUCTURE)
  IF SZ_CHECK.TYPE NE STRUCT.STATS_ARRAYS_SZ.TYPE OR SZ_CHECK.N_ELEMENTS NE STRUCT.STATS_ARRAYS_SZ.N_ELEMENTS OR SZ_CHECK.N_DIMENSIONS NE STRUCT.STATS_ARRAYS_SZ.N_DIMENSIONS THEN BEGIN
    ERROR = 'ERROR: DAT dimensions do not agree with previous DAT dimensions'
    PRINT,ERROR
    RETURN,ERROR
  ENDIF
  
; ===> Find data within range and replace the data out of range with MISSINGS so that OK_NEG will work
	OK= WHERE_CRITERIA(DAT,OPERATORS=STRUCT.OPER,RANGE=STRUCT.RANGE,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,CRITERIA_TXT=CRITERIA_TXT,COUNT )
 	IF NCOMPLEMENT GE 1 THEN DAT[COMPLEMENT] = MISSINGS(DAT)   ; Make "BAD" data missings

; ===> Get the subscripts of the DATA within the allowable RANGE
  SUBS = WHERE(DAT NE STRUCT.MISSING AND FINITE(DAT) EQ 1 AND DAT NE MISSINGS(DAT),COUNT_GOOD,NCOMPLEMENT=NCOMP,COMPLEMENT=COMP)
	IF COUNT_GOOD EQ 0 AND NOT KEYWORD_SET(CALC) THEN RETURN, STRUCT.N_SETS ; If not "VALID" data are found exit and continue until the final stats are calculated
	IF COUNT_GOOD EQ 0 THEN GOTO, CALCULATE
	IF NCOMPLEMENT GE 1 THEN DAT[COMP] = MISSINGS(DAT)         ; Make "BAD" data missings
	
; ===> Transform the data to calculate the GMEAN and make sure the DAT array does not include values GE 0.0	
	IF STRUCT.TRANSFORM NE '' THEN BEGIN
	  LOGSUBS = WHERE(DAT NE STRUCT.MISSING AND FINITE(DAT) EQ 1 AND DAT NE MISSINGS(DAT) AND DAT GT 0,COUNT_LGOOD,NCOMPLEMENT=NLCOMP,COMPLEMENT=LCOMP) 
    IF STRUCT.TRANSFORM EQ 'ALOG'   THEN LDAT = ALOG(DAT)
    IF STRUCT.TRANSFORM EQ 'ALOG10' THEN LDAT = ALOG10(DAT)
    IF NLCOMP GE 1 THEN LDAT[LCOMP] = MISSINGS(DAT) ; Make "BAD" data missings
	ENDIF ELSE COUNT_LGOOD = 0

; ##################################################################################################################################################
; ##################################################################################################################################################
; ##################################################################################################################################################
; ####################################### A C C U M U L A T E    S T A T I S T I C A L    A R R A Y S  #############################################

;	===> If there are any valid DAT then accumulate the statistical SUMS
	IF COUNT_GOOD LE MAX_SIZE THEN BEGIN
		N_ITER = 1 & _MAX_SIZE = COUNT_GOOD & _REMAINDER = 0L
  ENDIF ELSE BEGIN
	 stop ; Need to figure out what is going on in this block. Is it necessary?
	  _MAX_SIZE = MAX_SIZE
		N_ITER = COUNT_GOOD/_MAX_SIZE 
		_REMAINDER = COUNT_GOOD MOD _MAX_SIZE 
		IF _REMAINDER NE 0 THEN N_ITER = N_ITER +1
	ENDELSE;IF COUNT LE MAX_SIZE THEN BEGIN

; ===> Loop through N_ITER
  FOR NTH = 0L,N_ITER -1L DO BEGIN
	  SS = NTH*_MAX_SIZE 
	  SF   = SS + _MAX_SIZE -1L
		IF NTH EQ N_ITER -1 AND _REMAINDER NE 0 THEN SF = SS + _REMAINDER -1L

 		IF HAS(STATS_2DO, 'NUM',/EXACT)  THEN STRUCT.NUM[SUBS[SS:SF]] += 	1.0														        ; NUM_MEM(SUBS) =  NUM_MEM(SUBS) + 	1L
 		IF HAS(STATS_2DO, 'MIN',/EXACT)  THEN STRUCT.MIN[SUBS[SS:SF]] <=  DAT[SUBS[SS:SF]]                      ; MIN_MEM(SUBS) =  MIN_MEM(SUBS) < 	DATA(SUBS)
		IF HAS(STATS_2DO, 'MAX',/EXACT)  THEN STRUCT.MAX[SUBS[SS:SF]] >=  DAT[SUBS[SS:SF]]                      ; MAX_MEM(SUBS) =  MAX_MEM(SUBS) > 	DATA(SUBS)
		IF HAS(STATS_2DO, 'SUM',/EXACT)  THEN STRUCT.SUM[SUBS[SS:SF]] +=  DAT[SUBS[SS:SF]] 	                    ; SUM_MEM(SUBS) =  SUM_MEM(SUBS) +  DATA(SUBS)
		IF HAS(STATS_2DO, 'SSQ',/EXACT)  THEN STRUCT.SSQ[SUBS[SS:SF]] +=  DAT[SUBS[SS:SF]] * DAT[SUBS[SS:SF]] 	; SSQ_MEM(SUBS) =  SSQ_MEM(SUBS) +  (DATA(SUBS) * DATA(SUBS))
    IF HAS(STATS_2DO, 'SPAN',/EXACT) THEN STRUCT.SPAN = STRUCT.MAX - STRUCT.MIN
  ENDFOR;FOR NTH = 0L,N_ITER -1L DO BEGIN

; ===> If there are any valid LDAT (log data) then accumulate the statistical SUMS (the number of logged data may be different because negative values are removed)
  IF COUNT_LGOOD LE MAX_SIZE THEN BEGIN
    N_ITER = 1 & _MAX_SIZE = COUNT_LGOOD & _REMAINDER = 0L
  ENDIF ELSE BEGIN
  stop ; Need to find out what is going on in this block
    _MAX_SIZE = MAX_SIZE
    N_ITER = COUNT_LGOOD/_MAX_SIZE
    _REMAINDER = COUNT_LGOOD MOD _MAX_SIZE
    IF _REMAINDER NE 0 THEN N_ITER = N_ITER +1
  ENDELSE;IF COUNT LE MAX_SIZE THEN BEGIN

  ; ===> Loop through N_ITER
  FOR NTH = 0L,N_ITER -1L DO BEGIN
    SS = NTH*_MAX_SIZE
    SF   = SS + _MAX_SIZE -1L
    IF NTH EQ N_ITER -1 AND _REMAINDER NE 0 THEN SF = SS + _REMAINDER -1L
    IF HAS(STATS_2DO, 'LNUM',/EXACT) THEN STRUCT.LNUM[LOGSUBS[SS:SF]] +=   1.0   
    IF HAS(STATS_2DO, 'LSUM',/EXACT) THEN STRUCT.LSUM[LOGSUBS[SS:SF]] +=  LDAT[LOGSUBS[SS:SF]]  ; SUM_MEM(SUBS) =  SUM_MEM(SUBS) +  DATA(SUBS)
    IF HAS(STATS_2DO, 'LSSQ',/EXACT) THEN STRUCT.LSSQ[LOGSUBS[SS:SF]] +=  LDAT[LOGSUBS[SS:SF]] * LDAT[LOGSUBS[SS:SF]]  ;_MEM(SUBS) =  SSQ_MEM(SUBS) +  (DATA(SUBS) * DATA(SUBS))
  ENDFOR


; ===> Determine the number of negative values in the data array (often used for finding negative RRS values)
  OK_NEG = WHERE(FINITE(DAT) AND DAT LE 0,COUNT_NEG) ; Find any negative values
  IF HAS(STATS_2DO,'NEG',/EXACT) THEN BEGIN               ; If requested, add the NEG data to the COMMON structure
    IF COUNT_NEG LE MAX_SIZE THEN BEGIN
  		N_ITER = 1 & _MAX_SIZE = COUNT_NEG & _REMAINDER = 0L
  	ENDIF ELSE BEGIN
   stop ; Need to figure out what is going on in this step
  		_MAX_SIZE = MAX_SIZE
  		N_ITER = COUNT_NEG/_MAX_SIZE 
  		_REMAINDER = COUNT_NEG MOD _MAX_SIZE & IF _REMAINDER NE 0 THEN N_ITER = N_ITER +1 ;
  	ENDELSE ; IF COUNT_NEG LE MAX_SIZE THEN BEGIN

		FOR NTH = 0L,N_ITER -1L DO BEGIN
	    SS = NTH*_MAX_SIZE & SF = SS + _MAX_SIZE -1L
      IF NTH EQ N_ITER -1 AND _REMAINDER NE 0 THEN SUBS_FIN = SUBS_START + _REMAINDER -1L
			STRUCT.NEG[OK_NEG[SS:SF]] += 	1L
	  ENDFOR;FOR NTH = 0L,N_ITER -1L DO BEGIN
	ENDIF  ; IF WHERE(STATS_2DO EQ 'NEG') NE -1 THEN BEGIN

;	===> Null the DAT and LDAT variables
  GONE, DAT
  GONE, LDAT

; ===> Update the STAT_STRUCT with the new data if requested
  IF KEY(RETURN_STRUCT) THEN STAT_STRUCT = STRUCT ELSE STAT_STRUCT = []

; ===> If it is not time to calculate the final stats, just return the N_SETS   
	IF ~KEY(CALC) THEN RETURN,STRUCT.N_SETS 	; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
 
; ##################################################################################################################################################
; ##################################################################################################################################################
; ##################################################################################################################################################

	CALCULATE:

;	===> Check if STATS_ARRAYS has been used to accumulate statistics 
	IF N_ELEMENTS(STRUCT.N_SETS) LT 1 THEN BEGIN
	  ERROR = 'ERROR: THE FIRST CALL TO STATS_ARRAYS MUST USE /START TO INITIALIZE STATISTICAL ARRAYS'
	  PRINT, ERROR
    RETURN,ERROR
	ENDIF

; ===> Find the pixels with at least 1 value from all the data arrays passed and make all other pixels MISSINGS
	OK1 = WHERE(STRUCT.NUM GE 1 AND FINITE(STRUCT.NUM) EQ 1, COUNT_1, NCOMPLEMENT=NCOMPLEMENT_1, COMPLEMENT=COMPLEMENT_1)
	IF NCOMPLEMENT_1 GE 1 THEN BEGIN ; Make NCOMPLEMENT pixels MISSINGS 
	  FOR N=0, N_ELEMENTS(STAT_TYPES)-1 DO BEGIN
	    POS = WHERE(TAG_NAMES(STRUCT) EQ STAT_TYPES[N])
	    IF HAS(STATS_2DO, STAT_TYPES[N],/EXACT) THEN BEGIN
	      DT = STRUCT.(POS)
	      DT[COMPLEMENT_1] = MISSINGS(STRUCT.(POS))
	      STRUCT.(POS) = DT
	    ENDIF
	  ENDFOR
	ENDIF ; IF NCOMPLEMENT GE 1 THEN BEGIN

; ===> Find the pixels with at least 2 values (which are needed for the STD and CV calculations) from all the data arrays passed and make all other pixels MISSINGS
	OK2 = WHERE(STRUCT.NUM GE 2 AND FINITE(STRUCT.NUM) EQ 1,COUNT_2, NCOMPLEMENT=NCOMPLEMENT_2, COMPLEMENT=COMPLEMENT_2)
	IF NCOMPLEMENT_2 GE 1 THEN BEGIN ; Make NCOMPLEMENT pixels MISSINGS
	  IF HAS(STATS_2DO,'STD',/EXACT) THEN STRUCT.STD[COMPLEMENT_2] = MISSINGS(STRUCT.STD)
	  IF HAS(STATS_2DO,'CV',/EXACT)  THEN STRUCT.CV[COMPLEMENT_2]  = MISSINGS(STRUCT.CV)
	ENDIF ; IF NCOMPLEMENT_2 GE 1 THEN BEGIN

; ===> Find the pixels with at least 1 value for the LOG based stats
  IF HAS(STATS_2DO,'GMEAN',/EXACT) THEN BEGIN
    OKL1 = WHERE(STRUCT.LNUM GE 1 AND FINITE(STRUCT.LNUM) EQ 1, COUNT_L1, NCOMPLEMENT=NCOMPLEMENT_L1, COMPLEMENT=COMPLEMENT_L1)
    IF NCOMPLEMENT_L1 GE 1 THEN BEGIN ; Make NCOMPLEMENT pixels MISSINGS
      FOR N=0, N_ELEMENTS(LOG_STATS)-1 DO BEGIN
        POS = WHERE(TAG_NAMES(STRUCT) EQ LOG_STATS[N])
        IF HAS(STATS_2DO, LOG_STATS[N],/EXACT) THEN BEGIN
          DT = STRUCT.(POS)
          DT[COMPLEMENT_L1] = MISSINGS(STRUCT.(POS))
          STRUCT.(POS) = DT
        ENDIF
      ENDFOR
    ENDIF ; IF NCOMPLEMENT_L1 GE 1 THEN BEGIN
  ENDIF ; GMEAN    
    
; ===> Find the pixels with at least 2 values from all the data arrays passed and make all other pixels MISSINGS
  IF HAS(STATS_2DO,'GSTD',/EXACT) THEN BEGIN
    OKL2 = WHERE(STRUCT.LNUM GE 2 AND FINITE(STRUCT.LNUM) EQ 1, COUNT_L2, NCOMPLEMENT=NCOMPLEMENT_L2, COMPLEMENT=COMPLEMENT_L2)
    IF NCOMPLEMENT_L2 GE 1 THEN BEGIN ; Make NCOMPLEMENT pixels MISSINGS
      IF HAS(STATS_2DO,'GSTD',/EXACT) THEN STRUCT.GSTD[COMPLEMENT_L2] = MISSINGS(STRUCT.GSTD)
    ENDIF ; IF NCOMPLEMENT_L2 GE 1 THEN BEGIN
  ENDIF ; GSTD    
  
;	===> Calculate the MEANs, STD, and CV for the pixels with valid data 
  CSTATS = ['MEAN','GMEAN','STD','GSTD','CV']
  FOR C=0, N_ELEMENTS(CSTATS)-1 DO BEGIN
	  IF HAS(STATS_2DO, CSTATS[C],/EXACT) THEN BEGIN
      CASE CSTATS[C] OF ; Be sure to use the stat specific COUNT 
        'MEAN':  CNT=COUNT_1  
        'GMEAN': CNT=COUNT_L1 
        'STD':   CNT=COUNT_2  
        'GSTD':  CNT=COUNT_L2 
        'CV':    CNT=COUNT_2  
      ENDCASE
      
      IF CNT GE 1 THEN BEGIN  
        POS = WHERE(TAG_NAMES(STRUCT) EQ CSTATS[C],/NULL)      ; Find the STAT in the STRUCTURE
        CSTAT = STRUCT.SUM & CSTAT[*] = MISSINGS(STRUCT.(POS)) ; Create a blank array and make it MISSINGS
        
   			IF CNT LE MAX_SIZE THEN BEGIN
  				N_ITER = 1 & _MAX_SIZE = CNT & _REMAINDER = 0L
  			ENDIF ELSE BEGIN
  	stop ; Need to figure out what this block is for...		
  				_MAX_SIZE = MAX_SIZE
  				N_ITER = CNT/_MAX_SIZE & _REMAINDER = CNT MOD _MAX_SIZE & IF _REMAINDER NE 0 THEN N_ITER = N_ITER +1
  			ENDELSE

  			FOR NTH = 0L,N_ITER -1L DO BEGIN
  				SS = NTH*_MAX_SIZE & SF = SS + _MAX_SIZE -1L
  				IF NTH EQ N_ITER -1 AND _REMAINDER NE 0 THEN SF = SS + _REMAINDER -1L
  				CASE CSTATS[C] OF ; Calculate the stats
  				  'MEAN' : STRUCT.MEAN[OK1[SS:SF]]   = STRUCT.SUM[OK1[SS:SF]]/STRUCT.NUM[OK1[SS:SF]]
  				  'GMEAN': STRUCT.GMEAN[OKL1[SS:SF]] = STRUCT.LSUM[OKL1[SS:SF]]/STRUCT.LNUM[OKL1[SS:SF]]
  				  'STD'  : STRUCT.STD[OK2[SS:SF]]    = (((STRUCT.SSQ[OK2[SS:SF]]  -((STRUCT.SUM[OK2[SS:SF]]  *STRUCT.SUM[OK2[SS:SF]])/  STRUCT.NUM[OK2[SS:SF]]))^0.5)/  ((STRUCT.NUM[OK2[SS:SF]]-1)^0.5)) 
  				  'GSTD' : STRUCT.GSTD[OKL2[SS:SF]]  = (((STRUCT.LSSQ[OKL2[SS:SF]]-((STRUCT.LSUM[OKL2[SS:SF]]*STRUCT.LSUM[OKL2[SS:SF]])/STRUCT.LNUM[OKL2[SS:SF]]))^0.5)/((STRUCT.LNUM[OKL2[SS:SF]]-1)^0.5))
  				  'CV'   : STRUCT.CV[OK2[SS:SF]]     = 100D*(STRUCT.STD[OK2[SS:SF]])/(STRUCT.SUM[OK2[SS:SF]]/STRUCT.NUM[OK2[SS:SF]])  				  
  				ENDCASE
  		  ENDFOR;FOR NTH = 0L,N_ITER -1L DO BEGIN

;       ===> Make previously identified "bad" (COMPLEMENT) data MISSINGS and convert NaN to 0   
        OK_NAN = WHERE(FINITE(STRUCT.(POS))EQ 0,COUNT_NAN)                    ; Check for values of NAN
        IF COUNT_NAN GE 1 THEN STRUCT.(POS)[OK_NAN] =  MISSINGS(STRUCT.(POS)) ; which should be set to zero because of imprecision and rounding errors in the above equation
        CASE CSTATS[C] OF ; Use stat specific COMPLEMENT
          'MEAN' : IF NCOMPLEMENT_1  GE 1 THEN STRUCT.MEAN[COMPLEMENT_1]   = MISSINGS(STRUCT.MEAN)
          'GMEAN': IF NCOMPLEMENT_L1 GE 1 THEN STRUCT.GMEAN[COMPLEMENT_1] = MISSINGS(STRUCT.GMEAN)
          'STD'  : IF NCOMPLEMENT_2  GE 1 THEN STRUCT.STD[COMPLEMENT_1]    = MISSINGS(STRUCT.STD)
          'GSTD' : IF NCOMPLEMENT_L2 GE 1 THEN STRUCT.GSTD[COMPLEMENT_1]  = MISSINGS(STRUCT.GSTD)
          'CV'   : IF NCOMPLEMENT_2  GE 1 THEN STRUCT.CV[COMPLEMENT_1]     = MISSINGS(STRUCT.CV)
        ENDCASE
      ENDIF ; IF CNT GE 1  
	  ENDIF ; CSTATS 
  ENDFOR ; CSTATS Loop

; ===> Remove tags that were not originally requested from the final structure
  TAGS = TAG_NAMES(STRUCT)
  OK = WHERE_MATCH(TAGS,DO_STATS,COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)      ; Find requested stats in the structure
  IF COUNT GE 1 THEN TAGS = ['N_SETS','RANGE','MISSING','TRANSFORM',TAGS[OK]]  ; Be sure to include some additional information in the output structure
  OUTSTRUCT = STRUCT_COPY(STRUCT,TAGNAMES=TAGS)                                ; Copy requested stats into a new structure
  
; ===> Convert transformed stats in the OUTSTRUCT (but not the COMMON struct) back to real unit
  LSTATS = ['LSUM','LSSQ','GMEAN','GSTD']
  FOR L=0, N_ELEMENTS(LSTATS)-1 DO BEGIN
    OK = WHERE(TAG_NAMES(OUTSTRUCT) EQ LSTATS[L],COUNT)
    IF COUNT EQ 0 THEN CONTINUE
    IF STRUCT.TRANSFORM EQ 'ALOG'   THEN OUTSTRUCT.(OK) = EXP(OUTSTRUCT.(OK))
    IF STRUCT.TRANSFORM EQ 'ALOG10' THEN OUTSTRUCT.(OK) = 10^(OUTSTRUCT.(OK))
  ENDFOR
  
; ===> Update the STAT_STRUCT with the new data if requested
  IF KEY(RETURN_STRUCT) THEN STAT_STRUCT = OUTSTRUCT ELSE STAT_STRUCT = []    
	RETURN, OUTSTRUCT

END; #####################  END OF ROUTINE ################################
