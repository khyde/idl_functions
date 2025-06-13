; $ID:	GET_DISK.PRO,	2014-04-29	$
;#############################################################################################################
	FUNCTION GET_DISK
	
;  PRO GET_DISK
;+
; NAME:
;		GET_DISK
;
; PURPOSE: THIS FUNCTION RETURNS THE DISK [C:\ OR D:\] FOR THE CURRENT WORKING DIRECTORY
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = GET_DISK()
;
; INPUTS:
;		NONE 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:  C OR D
;		
;; EXAMPLES:
;  PRINT, GET_DISK()
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
ROUTINE_NAME  = 'GET_DISK'
;***********************

IF FILE_TEST('D:\IDL\PROGRAMS\') EQ 1 THEN DISK = 'D' ELSE DISK = 'C' 


RETURN,DISK


DONE:          
	END; #####################  END OF ROUTINE ################################
