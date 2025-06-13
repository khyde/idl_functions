; $ID:	IMG_MERGE_DEMO.PRO,	2014-04-29	$
;+
;#############################################################################################################
	PRO IMG_MERGE_DEMO

;
; PURPOSE: DEMO 
;
; CATEGORY:	IMG
;
; CALLING SEQUENCE: IMG_MERGE_DEMO
;
; INPUTS: NONE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			WRITTEN APR 6, 2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'IMG_MERGE_DEMO'
;********************************
DIR = GET_SMI()
FILES = FILE_SEARCH(DIR.STATS_PERIODS_PNGS,'Y*.PNG') &PL,FILES
IMG_MERGE,FILES,DIR_OUT=DIR_OUT,BUFFER=0,MARGIN = REPLICATE(0.0D,4), OVERWRITE=1

END; #####################  END OF ROUTINE ################################
