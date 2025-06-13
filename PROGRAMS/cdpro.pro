; $ID:	CDPRO.PRO,	2014-12-12	$
;#############################################################################################################
	PRO CDPRO
	
;  PRO CDPRO
;+
; NAME:
;		CDPRO
;
; PURPOSE: THIS PROGRAM CHANGES THE DIR TO THE DOWNLOADS DIRECTORY 
;
; CATEGORY:
;		FILE
;
; CALLING SEQUENCE:CDPRO
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS: NONE
;		

; OUTPUTS: PRINTS CURRENT DIR TO SCREEN
;		
;; EXAMPLE:  CDPRO
;  
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 1,2012 J.O'REILLY
;			FEB 26,2013,JOR ADDED KEYWORD DIR
;			SEP 20,2013,JOR, CHECK IF DISK = C OR D
;			NOV 15,2014,JOR SIMPLIFIED NOW USING !S.PROGRAMS
;#################################################################################
;
;-
;	******************
ROUTINE_NAME='CDPRO'
; ******************
;C:\USERS\PATOOT\DOWNLOADS
CLOSE,/ALL
DIR = !S.PROGRAMS
CD,DIR
IF NOT KEY(QUIET) THEN PRINT,'CURRENT DIRECTORY IS: > '+DIR
        
END; #####################  END OF ROUTINE ################################
