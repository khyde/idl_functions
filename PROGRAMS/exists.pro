; $ID:	EXISTS.PRO,	2014-04-30	$
;+
;;#############################################################################################################
	FUNCTION EXISTS,FILE
;
; PURPOSE: THIS FUNCTION RETURNS 1 [TRUE] IF THE FILE EXISTS 0 [FALSE] IF FILE DOES NOT EXIST
; 
; 
; 
; CATEGORY:	LOGIC;		 
;
; CALLING SEQUENCE: RESULT = EXISTS(FILE)
;
; INPUTS: FILE  

; OPTIONAL INPUTS:
;			
;		
; EXISTSWORD PARAMETERS:
;   NONE

; OUTPUTS: 1=IF file EXISTS 0=IF  FILE DOES  NOT EXIST
;		
;; EXAMPLES:
;  PRINT,EXISTS('EXISTS.PRO') 

;	NOTES:;		
;
;
; MODIFICATION HISTORY:
;			APR 19,2014  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'EXISTS'
;***********************
IF IDLTYPE(FILE) NE 'STRING' THEN MESSAGE,'ERROR: FILENAME IS REQUIRED'
RETURN,FILE_TEST(FILE) EQ 1 
DONE:          
	END; #####################  END OF ROUTINE ################################
