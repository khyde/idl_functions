; $ID:	FD.PRO,	2015-08-04	$
;#############################################################################################################
	PRO FD,FILE
	
;  PRO FD
;+
; NAME:
;		FD
;
; PURPOSE: THIS PROGRAM IS A SHORTCUT FOR FILE_DOC
;
; CATEGORY:
;		PROGRAMS
;		 
;
; CALLING SEQUENCE: FD
;
; INPUTS: FILE [AN IDL PRO FILE]
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: COPIES FILE TO BACKUP;UPDATES TIME STAMP USING FILE_DOC; AND ENSURES NEW FILE IS LOWER CASE
;		
;; EXAMPLES:
;  FD,'TEMPLATE_PRO'
;  FD,'FD'
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN DEC 29,2012 J.O'REILLY
;			AUG 24,2013,JOR ADDED CDPRO
;			DEC 10,2013,JOR REMOVED CDPRO
;#################################################################################
;-
;****************
ROUTINE_NAME='FD'
;****************
FILE_DOC,FILE
DONE:          
	END; #####################  END OF ROUTINE ################################
