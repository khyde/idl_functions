; $ID:	STATS_WRITE.PRO,	2020-06-30-17,	USER-KJWH	$
;#############################################################################################################
	PRO STATS_WRITE,FILE,STRUCT,INFILE=INFILE,_EXTRA = _EXTRA
;+
; NAME:
;		STATS_WRITE
;
; PURPOSE: WRITE STATS TO A STANDARD STRUCTURE THAT MAY BE READ BY READ_STATS
;
; CATEGORY:
;		STATS
;		 
;
; CALLING SEQUENCE: STATS_WRITE,FILE
;
; INPUTS: FILE- COMPLETE NAME OF STATS SAVE FILE TO WRITE
;         STRUCT - THE OUTPUT STRUCTURE FROM STATS_ARRAYS
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		INFILE: NAMES OF INPUT FILES TO STATS_ARRAYS
;   _EXTRA: ANY OTHER ATTRIBUTES TO WRITE TO THE OUTPUT STRUCTURE
; OUTPUTS: A STANDARD STRUCTURE WHICH MAY BE READ BY READ_STATS
;		
;; EXAMPLES:
;;
; MODIFICATION HISTORY:
;			WRITTEN NOV  10,2013 J.O'REILLY	
;			NOV 15,2013,JOR : 
;			                ADDED KEY ATTRIBUTES FROM FILE_ALL(FILE) TO OUTPUT STRUCTURE
;			                RETURNS AN ERROR STRING IF STAT TARGETS NOT FOUND
;			                INFILE ADDED TO OUTPUT STRUCT
;     NOV 16,2013,JOR:ADDED KEYWORD _EXTRA
;                     ADD ANY INFO IN _EXTRA TO OUTPUT STRUCTURE IN SAVE
;                     IF NO PROD FOUND BY FILE_ALL(FILE) THEN PROD WILL BE 'NONE'
;   JAN 16,2014,JOR RENAMED READ_STATS 2 STATS_WRITE TO FOLLOW CONVENTION 
;                   THAT ALL STATS RELATED PROGRAMS BEGIN WITH 'STATS_'
;   APR 15,2015,JOR ADDED ERROR,CATCH, ENSURED KEY TAGS ARE SAME AS IN STRUCT_WRITE                
;			                 
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'STATS_WRITE'
;***************************

;#################################################
;===> ERROR HANDLER 
CATCH, ERRORSTATUS
IF (ERRORSTATUS NE 0) THEN BEGIN
  CATCH, /CANCEL
  ERROR = !ERROR_STATE.MSG
  RETURN
ENDIF;IF (ERRORSTATUS NE 0) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||

;##### EXTRACT SOME KEY ATTRIBUTES FROM THE INPUT FILE NAME  #####
FA = FILE_ALL(FILE)
NAMES = ['NAME','PERIOD','PERIOD_CODE','SENSOR','SATELLITE','METHOD','MAP','STAT','PROD','ALG']
ATTR  = STRUCT_COPY(FA,TAGNAMES = NAMES)
;### GET THE PROD FROM FA
PROD= FA.PROD
IF PROD EQ '' THEN PROD = 'NONE'

COMPUTER = GET_COMPUTER()
DATE = DATE_NOW()
ROUTINE_NAME = STRUPCASE(CALLER(2))
IF N_ELEMENTS(INFILE) EQ 0 THEN INFILE = FILE
;###  PLACE PROD AT THE TOP OF THE STRUCTURE
STRUCT = CREATE_STRUCT(PROD,PROD,STRUCT)
STRUCT = CREATE_STRUCT(STRUCT,ATTR,'INFILE',INFILE)

;###> ADD ANY INFO IN _EXTRA TO STRUCT
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0, N_TAGS(_EXTRA)-1  DO BEGIN
  TAGNAMES = TAG_NAMES(_EXTRA)
  NAME = TAGNAMES[NTH]
  VAL = _EXTRA.(NTH)
  ;===> DO NOT ADD NAME IF IT IS ALREADY PRESENT IN THE STRUCT
  IF WHERE(TAG_NAMES(STRUCT) EQ NAME) EQ -1 THEN STRUCT = CREATE_STRUCT(STRUCT,NAME,VAL)
ENDFOR;FOR NTH = 0, N_TAGS(_EXTRA)-1  DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF


SAVE,FILENAME = FILE,STRUCT,/COMPRESS & PFILE,FILE,/W

END; #####################  END OF ROUTINE ################################
