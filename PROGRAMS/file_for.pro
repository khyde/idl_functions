; $ID:	FILE_FOR.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO FILE_FOR,FILES,PROG,_EXTRA=_EXTRA

;
; PURPOSE: LOOPS ON FILES TO PROCESS A PROGRAM
;
; CATEGORY:	FILE
;
; CALLING SEQUENCE: FILE_FOR,FILES,PROG
;
; INPUTS: FILES
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		PROG: NAME OF PROGRAM TO USE TO PROCESS THE FILES

; OUTPUTS: 
;		
; EXAMPLES: 
;    FILES = 
;    FILE_FOR,
;
; MODIFICATION HISTORY:
;			 MAR 29,2014 WRITTEN BY J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;*****************************
ROUTINE_NAME  = 'FILE_FOR'
;*****************************

IF N_ELEMENTS(FILES) EQ 0  THEN MESSAGE,'FILES ARE REQUIRED'


;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
  FILE = FILES[NTH]
  CALL_PROCEDURE,PROG,FILE,_EXTRA=_EXTRA
  
ENDFOR;FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

END; #####################  END OF ROUTINE ################################
