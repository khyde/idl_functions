; $ID:	IS_FILE.PRO,	2016-11-07,	USER-JOR	$
;+
;#############################################################################################################
	FUNCTION IS_FILE,FILE

; PURPOSE: THIS LOGICAL FUNCTION TESTS IF FILE IS A FILE NAME 
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_FILE(FILE)
;
; INPUTS: FILE TO CHECK  

; OUTPUTS: LOGICAL 1 OR 0
;		
; EXAMPLES:
;   PRINT,IS_FILE('JUNK.DAT'); = 1
;   PRINT,IS_FILE('IS_FILE.PRO'); = 1
;   PRINT,IS_FILE(''); = 0
;   PRINT,IS_FILE(1.0); = 0

;        
; MODIFICATION HISTORY:
;			WRITTEN NOV 06,2016 WRITTEN BY J.O'REILLY
;####################################################################################
;-
;************************
ROUTINE_NAME  = 'IS_FILE'
;************************
IF NONE(FILE) THEN MESSAGE,'ERROR: FILE IS REQUIRED'
IF IDLTYPE(FILE) NE 'STRING' THEN RETURN,0 
IF  (STRPOS(FILE,'.') NE -1 OR FILE_TEST(FILE) EQ 1) THEN RETURN,1 ELSE RETURN, 0



BADFILE:
RETURN,0

END; #####################  END OF ROUTINE ################################
