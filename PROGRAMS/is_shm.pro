; $ID:	IS_SHM.PRO,	2015-09-12	$
;+
;;#############################################################################################################
	FUNCTION IS_SHM,FILE

; PURPOSE: THIS FUNCTION TESTS IF THE SHARED MEMORY FILE IS IN MEMORY
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_SHM(FILE)
;
; INPUTS: FILE ... THE NAME OF THE SHARED MEMORY FILE  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;         

; OUTPUTS: LOGICAL 1 OR 0
;		
;; EXAMPLES:
;         
; MODIFICATION HISTORY:
;			WRITTEN FEB 19,2015 J.O'REILLY
;			JAN 16,2016,JOR : NAME_ = FIRST((FILE_PARSE(TXT)).NAME)

;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_SHM'
;***********************

IF NONE(FILE) THEN MESSAGE,'ERROR: THE NAME OF THE SHARED MEMORY FILE IS REQUIRED'
NAME = (FILE_PARSE(FILE)).NAME

HELP,/SHARED_MEMORY,OUTPUT = TXT
NAME_ = FIRST((FILE_PARSE(TXT)).NAME)

RETURN,NAME EQ NAME_

END; #####################  END OF ROUTINE ################################
