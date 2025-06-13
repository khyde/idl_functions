; $ID:	DIR_PROJECT.PRO,	2014-05-10	$
;+
;;#############################################################################################################
	FUNCTION DIR_PROJECT,PROJECT,DIR=DIR

; PURPOSE: THIS FUNCTION RETURNS THE PATH TO THE PROJECT FOLDER
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = DIR_PROJECT(DIR)
;
; INPUTS: PROJECT [ E.G. 'UNEP'  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;         DIR: A FOLDER UNDER PROJECT

; OUTPUTS: THE PATH TO THE FOLDER
;		
;; EXAMPLES:
;  PRINT, DIR_PROJECT(DIR)
;	NOTES:

;
; MODIFICATION HISTORY:
;			MAY 10,2013 WRITTEN BY J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'DIR_PROJECT'
;****************************
IF NONE(PROJECT) THEN PROJECT = 'UNEP'
IF NONE(DIR) THEN DIR = 'FIGS'

DIR =  !S.PROJECTS +PROJECT + PATH_SEP() +  DIR + PATH_SEP()
DIR_TEST,DIR
RETURN,DIR
DONE:          
	END; #####################  END OF ROUTINE ################################
