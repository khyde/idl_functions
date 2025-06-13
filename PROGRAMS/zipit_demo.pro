; $ID:	ZIPIT_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;+
; ######################################################################### 
  PRO ZIPIT_DEMO

;  PURPOSE:  THIS IS A DEMO FOR ZIPIT

; CATEGORY: FILE
  

; MODIFICATION HISTORY:
;     JAN 1, 2015 WRITTEN BY: J.E. O'REILLY
;     JAN 9,2015,JOR ADDED SWITCHES ZP=0&GZ=1&BZ=0

;     
;-
; #########################################################################

;****************************
ROUTINE_NAME  = 'ZIPIT_DEMO'
;****************************
 SL = PATH_SEP()
 DIR_DEMO = !S.DEMO + ROUTINE_NAME + SL & DIR_TEST,DIR_DEMO

;===> #####   SWITCHES 
  ZP=0 & GZ=1 & BZ=0 ; SET ONLY ONE AT A TIME
  DO_ZIP_ALL_2ONE	=	'' ; DO NOT RUN WITH /GZ SET [USE DO_ZIP_EACH FOR GZ]
  DO_ZIP_EACH     = ''
  DO_UNZIP        = ''
  DO_UNZIP_ONLY   = 'SV' 
;||||||||||||||||||||||


;*************************************************
IF NOT KEY(GZ) AND KEY(DO_ZIP_ALL_2ONE) THEN BEGIN
;*************************************************
  VERBOSE = HAS(DO_ZIP_ALL_2ONE,'V')
  FILES = FLS(!S.PROGRAMS,'maps_*.pro')
  DIR_OUT = DIR_DEMO
  ZFILE = DIR_OUT+ ROUTINE_NAME + '.ZIP'
  IF HAS(DO_ZIP_ALL_2ONE,'S') THEN STOP,DO_ZIP_EACH
  ZIPIT,FILES, ZFILE =ZFILE,DIR_OUT=DIR_OUT,VERBOSE=VERBOSE,ZP=ZP,GZ=GZ,BZ=BZ
 
  , 'DO_ZIP_ALL_2ONE'
ENDIF ; IF NOT KEY(GZ) AND KEY(DO_ZIP_ALL_2ONE) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; 

;*****************************
IF KEY(DO_ZIP_EACH) THEN BEGIN
;*****************************
  VERBOSE = HAS(DO_ZIP_EACH,'V')
  IF KEY(ZP) THEN FILES = FLS(!S.PROGRAMS,'maps_*.pro')
  IF KEY(GZ) THEN FILES = FLS(!S.PROGRAMS,'maps_*.pro')
  IF KEY(BZ) THEN FILES = FLS(!S.IDL_TEMP + 'S1997247.L3m_DAY_CHL_chlor_a_9km')
  DIR_OUT = DIR_DEMO
  IF HAS(DO_ZIP_EACH,'S') THEN STOP,DO_ZIP_EACH

  ZIPIT,FILES,DIR_OUT=DIR_OUT,VERBOSE=VERBOSE,ZP=ZP,GZ=GZ,BZ=BZ
  , 'DO_ZIP_EACH'
ENDIF ; IF KEY(DO_ZIP_EACH) THEN BEGIN
; ||||||||||||||||||||||||||||||||||
;
;***************************
IF KEY(DO_UNZIP) THEN BEGIN
;***************************
  VERBOSE = HAS(DO_UNZIP,'V')
  IF KEY(ZP) THEN FILES = FLS(DIR_DEMO ,'ZIPIT_DEMO.ZIP')
  IF KEY(GZ) THEN FILES = FLS(DIR_DEMO ,'maps*.gz')
  
  IF KEY(BZ) THEN FILES = FLS(!S.DATASETS + 'OC-SEAWIFS-9\L3\','*.bz2')
  IF HAS(DO_UNZIP,'S') THEN STOP,DO_UNZIP
  ZIPIT,FILES,DIR_OUT=DIR_DEMO,ZP=ZP,GZ=GZ,BZ=BZ,VERBOSE =VERBOSE
  , 'DO_UNZIP'
ENDIF ; IF KEY(DO_UNZIP) THEN BEGIN
; ||||||||||||||||||||||||||||||||||

;*****************************
IF KEY(DO_UNZIP_ONLY) THEN BEGIN
;*****************************

  VERBOSE = HAS(DO_UNZIP,'V')
  FILES = FILE_SEARCH(DIR_DEMO + 'S*')
  IF HAS(DO_UNZIP_ONLY,'S') THEN STOP,DO_UNZIP_ONLY
  ZIPIT, FILES, DIR_OUT=DIR_DEMO, VERBOSE=VERBOSE 


ENDIF ; DO_UNZIP_ONLY

END; #####################  END OF ROUTINE ################################
