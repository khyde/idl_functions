; $ID:	STRUCT_TAG_ADD_PROD.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION STRUCT_TAG_ADD_PROD,STRUCT

; PURPOSE: THIS FUNCTION ADDS THE PROD NAME TO EACH OF THE OTHER TAGS
; 
; 
; CATEGORY:	STRUCT;		 
;
; CALLING SEQUENCE: RESULT = STRUCT_TAG_ADD_PROD(STRUCT)
;
; INPUTS: STRUCT  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, STRUCT_TAG_ADD_PROD(STRUCT)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			APR 27,2014,  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;*************************************
ROUTINE_NAME  = 'STRUCT_TAG_ADD_PROD'
;*************************************
IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE,'ERROR: STRUCT MUST BE A STRUCTURE'

NAMES = TAG_NAMES(STRUCT)
OK = WHERE(NAMES EQ 'PROD',COUNT)
IF COUNT NE 1 THEN MESSAGE,'ERROR: PROD TAG NOT IN STRUCT'

PROD = FIRST(STRUCT.(OK))
NEW_NAMES =NAMES + '_'+ PROD

RETURN,STRUCT_RENAME(STRUCT,NAMES,NEW_NAMES)

DONE:          
	END; #####################  END OF ROUTINE ################################
