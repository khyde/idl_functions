; $ID:	MAKE_ANOM_SAVES.PRO,	2020-06-30-17,	USER-KJWH	$
FUNCTION MAKE_ANOM_SAVES, DIR_OUT=DIR_OUT, FILEA=FILEA,FILEB=FILEB, ANOM=ANOM, DATARANGE=DATARANGE, LABEL_EXTRA=LABEL_EXTRA, RETURN_DATA=RETURN_DATA, RETURN_STRUCT=RETURN_STRUCT, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE

; NAME:
;   MAKE_ANOM_SAVES
;
; PURPOSE:
;   This function calculates anomalies (RATIO or DIFFERENCE) from two the data in two .SAV files and writes out a new ANOM file (can also just return the data if a .SAV file is not needed)
;
; CATEGORY:
;   Statistics
;
; CALLING SEQUENCE:
;
;   Result = MAKE_ANOM_SAVES(FILEA=FILEA, FILEB=FILEB)
;
; INPUTS:
;   FILEA.........  Filename of the first (top) file
;   FILEB.........  Filename of the second (bottom) file
;
; OPTIONAL INPUTS:
;   DIR_OUT.......  Output directory for the ANOMFILE
;   ANOM..........  Type of anomaly to calculate (RATIO and/or DIFFERENCE)
;   DATARANGE.....  Range of acceptable input data 
;   LABEL_EXTRA...  Extra info to include in the output ANOMFILE name
;
; KEYWORD PARAMETERS:
;   LOGLUN........ If provided, then lun for the log file
;   RETURN_DATA... Return just the anomaly DATA instead of saving the file
;   RETURN_STRUCT. Return the anomaly STRUCTURE instead of saving the file 
;   OVERWRITE..... Overwrite an existing ANOMFILE
;
; OUTPUTS:
;   This function returns anomaly data, structure or save an ANOMFILE
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   This routine was adapted from ANOM_SAVE_MAKE
;
; MODIFICATION HISTORY:
;     Written:  FEB 13, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Modified: FEB 13, 2017 - KJWH: Adpated from ANOM_SAVE_MAKE
;                                    Updated and overhauled the program to be consistent with updated routines
;                                    Can work with L3B data
;                                    Added documentation
;               FEB 15, 2017 - KJWH: Changed INFILE to INFILES to be consistent with info written out in other SAV structures (i.e. STATS.SAV) 
;               APR 19, 2017 - KJWH: Changed VALIDS('PRODS',PROD,/CRITERIA) to VALIDS('PROD_CRITERIA',PROD)         
;               FEB 07, 2018 - KJWH: Added MATH='ANOMALY_'+ANOM(N) to the output save structure     
;               JUL 17, 2018 - KJWH: Fixed bug - Changed IF ANOM(N) EQ 'DIF'  THEN ANOM_ARRAY(OK_DATA)=DATAA(OK_DATA)-DATAB[OK]
;                                                     to IF ANOM(N) EQ 'DIF'  THEN ANOM_ARRAY(OK_DATA)=DATAA(OK_DATA)-DATAB(OK_DATA)      
;               NOV 05, 2018 - KJWH: Added IF IDLTYPE(RETURN_STRUCT) EQ 'STRUCT' THEN RETURN, RETURN_STRUCT       
;               NOV 08, 2018 - KJWH: Added RETURN, ANOMFILE to return the last filename   
;               NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                                    Added LOGLUN keyword   
;               DEC 13, 2019 - KJWH: Hard coded SENSOR into the file name.  FILE_LABEL_MAKE was often chaning the order of the SENSORS       
;               DEC 17, 2019 - KJWH: Fixed bug with data extraction - was not using the GMEAN for log-transformed files
;                                      Now if ANOM = 'RATIO' then setting the tag to be GMEAN instead of the default MEAN                                   
;-
; *************************************************************************

  
  ROUTINE_NAME='MAKE_ANOM_SAVES'
	UL='_'
	DASH='-'
	IF N_ELEMENTS(FILEA) NE 1 OR N_ELEMENTS(FILEB) NE 1 THEN MESSAGE,'ERROR: Number of AFILES must equal BFILES'
	IF NONE(LABEL_EXTRA) THEN LABEL_EXTRA='' ELSE LABEL_EXTRA = DASH + LABEL_EXTRA
	IF N_ELEMENTS(ANOM) LT 1 THEN ANOM=['RATIO']
	IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
	
	FA=PARSE_IT(FILEA,/ALL)
	FB=PARSE_IT(FILEB,/ALL) 
	IF SAME([FA.MAP,FB.MAP]) THEN MP = FA.MAP ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same MAP projection' 
	MS = MAPS_SIZE(MP,PX=PX,PY=PY)
	
	IF SAME([FA.PROD,FB.PROD]) THEN PROD = FA.PROD ELSE MESSAGE, 'ERROR: AFILES and BFILES must have the same PROD'
	IF N_ELEMENTS(DATARANGE) NE 2 THEN DRANGE = VALIDS('PROD_CRITERIA',PROD) ELSE DRANGE=DATARANGE
	
	IF NONE(DIR_OUT) THEN DIR_OUT = REPLACE(FA[0].DIR,['SAVE','STATS','NC'],['ANOMS','ANOMS','ANOMS']) 
	
; ===> GET FILE SPECIFIC INFORMATION TO CREATE THE OUTPUT FILE LABEL
	IF SAME([FA.PERIOD,FB.PERIOD])     THEN PERIOD   = FA.PERIOD   ELSE PERIOD   = FA.PERIOD   + DASH + FB.PERIOD
	IF SAME([FA.SENSOR,FB.SENSOR])     THEN SENSOR   = FA.SENSOR   ELSE SENSOR   = FA.SENSOR   + UL + FB.SENSOR
	IF SAME([FA.METHOD,FB.METHOD])     THEN METHOD   = FA.METHOD   ELSE METHOD   = FA.METHOD   + DASH + FB.METHOD
	IF SAME([FA.COVERAGE,FB.COVERAGE]) THEN COVERAGE = FA.COVERAGE ELSE COVERAGE = FA.COVERAGE + DASH + FB.COVERAGE
	IF SAME([FA.ALG,FB.ALG])           THEN ALG      = FA.ALG      ELSE ALG      = FA.ALG      + DASH + FB.ALG
  IF SAME([FA.STATS,FB.STATS])       THEN STAT     = FA.STATS    ELSE STAT     = FA.STATS    + DASH + FB.STATS	  
  FILE_LABEL = PERIOD + DASH + SENSOR + DASH + FILE_LABEL_MAKE(STRJOIN([METHOD,COVERAGE,MP,PROD,ALG,STAT],'-')+'.')
    
 ;  Check which ANOMs need saves made
  TARGETS=[]
  INFILES = [FILEA,FILEB]
  FOR A=0,N_ELEMENTS(ANOM)-1L DO BEGIN
    ANOMFILE = DIR_OUT+FILE_LABEL+DASH+'ANOM'+LABEL_EXTRA+'.SAV'    
    IF FILE_MAKE(INFILES,ANOMFILE,OVERWRITE=OVERWRITE) EQ 0 AND NOT KEYWORD_SET(RETURN_STRUCT) AND NOT KEYWORD_SET(RETURN_DATA) THEN CONTINUE
    TARGETS=[TARGETS,ANOM(A)]
  ENDFOR

  IF TARGETS EQ [] AND NOT KEYWORD_SET(RETURN_STRUCT) AND NOT KEYWORD_SET(RETURN_DATA) THEN GOTO, DONE
  ANOM=TARGETS
  
  IF ANOM EQ 'RATIO' AND FA.PERIOD_CODE NE 'D' THEN ATAG = 'GMEAN' ELSE ATAG = []
  IF ANOM EQ 'RATIO' AND FB.PERIOD_CODE NE 'D' THEN BTAG = 'GMEAN' ELSE BTAG = []

  DATAA = STRUCT_READ(FILEA,STRUCT=STRUCTA,TAG=ATAG,COUNT=COUNT_GOOD,SUBS=OK_GOOD,BINS=BINSA) 
  DATAB = STRUCT_READ(FILEB,STRUCT=STRUCTB,TAG=BTAG,COUNT=COUNT_GOOD,SUBS=OK_GOOD,BINS=BINSB) 
  
  IF ANY(BINSA) OR ANY(BINSB) THEN BEGIN
    IF N_ELEMENTS(BINSA) NE PY THEN BEGIN
      ADAT = FLTARR(PY) & ADAT(*,*) = MISSINGS(ADAT)
      ADAT(BINSA) = DATAA
      DATAA = FLTARR(1,PY)
      DATAA(0,*) = ADAT
      GONE, ADAT
    ENDIF
    IF N_ELEMENTS(BINSB) NE PY THEN BEGIN
      BDAT = FLTARR(PY) & BDAT(*,*) = MISSINGS(BDAT)
      BDAT(BINSB) = DATAB
      DATAB = FLTARR(1,PY)
      DATAB(0,*) = BDAT
      GONE, BDAT
    ENDIF
  ENDIF
  
	FOR N=0L,N_ELEMENTS(ANOM)-1L DO BEGIN
; ===> Create a blank data array
		ANOM_ARRAY=DATAA
		ANOM_ARRAY(*)=MISSINGS(ANOM_ARRAY)	

; ===> Find the VALID data for each file and create a simple byte array to determine where both arrays have VALID data			
		BIMAGE = BYTARR(PX,PY)
		BIMAGE(*,*) = 0
		VA = VALID_DATA(DATAA,PROD=FA.PROD,RANGE=DRANGE,SUBS=SUBA,COUNT=COUNTA) & IF COUNTA EQ 0 THEN CONTINUE & BIMAGE[SUBA] = BIMAGE[SUBA] + 1 
		VB = VALID_DATA(DATAB,PROD=FB.PROD,RANGE=DRANGE,SUBS=SUBB,COUNT=COUNTB) & IF COUNTB EQ 0 THEN CONTINUE & BIMAGE[SUBB] = BIMAGE[SUBB] + 1 
		
; ===> Find subscripts where both images have valid data and calculate the anomaly		
		OK_DATA = WHERE(BIMAGE EQ 2,COUNT_DATA) & IF COUNT_DATA EQ 0 THEN CONTINUE
		IF ANOM(N) EQ 'RATIO' THEN ANOM_ARRAY(OK_DATA)=DATAA(OK_DATA)/DATAB(OK_DATA)
		IF ANOM(N) EQ 'DIF' 	THEN ANOM_ARRAY(OK_DATA)=DATAA(OK_DATA)-DATAB(OK_DATA)

    IF KEYWORD_SET(RETURN_DATA) THEN RETURN, ANOM_ARRAY

    NOTES = PROD + ' Range: ' + REPLACE(DRANGE,'_',' to ')
    IF ANOM(N) EQ 'RATIO' THEN DATA_UNITS=''
    IF ANOM(N) EQ 'DIF'   THEN DATA_UNITS=UNITS(FA.PROD)
    
    IF HAS(MP,'L3B') THEN BEGIN
      ANOM_ARRAY = ANOM_ARRAY(0,OK_DATA)
      STR = CREATE_STRUCT('BINS',OK_DATA,'NBINS',COUNT_DATA,'TOTAL_BINS',MS.PY,'ANOMALY',ANOM_ARRAY,'DATA_UNITS',DATA_UNITS) ; Add BIN info to the PPD structure
    ENDIF ELSE STR = CREATE_STRUCT('ANOMALY',ANOM_ARRAY,'DATA_UNITS',DATA_UNITS)

    MISSING_CODE=MISSINGS(ANOM_ARRAY)
    
    NOTES=ANOM(N) +' OF FILES:'+FILEA+' AND '+FILEB
    ANOMFILE = DIR_OUT+FILE_LABEL+DASH+'ANOM'+LABEL_EXTRA+'.SAV'
    ;PLUN, LOG_LUN, 'Creating anomaly for ' + ANOMFILE, 0
    STRUCT_WRITE, STR, DATA=STR.ANOMALY, FILE=ANOMFILE, PROD=PROD, MATH='ANOMALY_'+ANOM(N),MISSING_CODE=MISSING_CODE, ALG=ALG, DATA_UNITS=DATA_UNITS, SENSOR=SENSOR, INFILES=INFILES, NOTES=NOTES, LOGLUN=LOG_LUN, RETURN_STRUCT=RETURN_STRUCT
    IF IDLTYPE(RETURN_STRUCT) EQ 'STRUCT' THEN RETURN, RETURN_STRUCT 
   
  ENDFOR; FOR N=0L,N_ELEMENTS(ANOM)-1L DO BEGIN
  
	GONE,DATAA
	GONE,DATAB
	GONE,STRUCTA
	GONE,STRUCTB
	GONE,ANOM_ARRAY

  DONE:
  RETURN, ANOMFILE
END; #####################  End of Routine ################################
