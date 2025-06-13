; $ID:	GET_DIR.PRO,	MAY 11,2013 	$
;#############################################################################################################
	FUNCTION GET_DIR,DISK=DISK
	
;  PRO GET_DIR
;+
; NAME:
;		GET_DIR
;
; PURPOSE: THIS FUNCTION RETURNS THE COMPLETE PATH FOR THE CURRENT WORKING DIRECTORY
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = GET_DIR()
;
; INPUTS:
;		NONE 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, GET_DIR()
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN MAY 11,2013 J.O'REILLY
;#################################################################################
;
;
;-
;***********************
ROUTINE_NAME  = 'GET_DIR'
;***********************

 CD,CURR = DIR
 RETURN,DIR+ PATH_SEP()
 DISK = STRMID(DIR,0,1)


DONE:          
	END; #####################  END OF ROUTINE ################################
