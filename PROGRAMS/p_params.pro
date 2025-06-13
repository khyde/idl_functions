; $ID:	P_PARAMS.PRO,	2020-06-30-17,	USER-KJWH	$
;#############################################################################################################
	PRO P_PARAMS,TXT
	
;  PRO P_PARAMS
;+
; NAME:
;		P_PARAMS
;
; PURPOSE: PRINT THE PARAMETERS OF STATSTRING FOR STATS OR STATS2
;
; CATEGORY:
;		PRINT
;		 
;
; CALLING SEQUENCE: P_PARAMS
;
; INPUTS: TXT  ['STATS' OR 'STATS2']
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES:
;
;  P_PARAMS
;
; MODIFICATION HISTORY:
;			WRITTEN SEP 22,2013 J.O'REILLY;			
;#################################################################################
;
;
;-
;**************************
ROUTINE_NAME  = 'P_PARAMS'
;**************************
IF N_ELEMENTS(TXT) NE 1 THEN TXT = 'STATS' 
IF TXT EQ 'STATS' THEN PLIST,TAG_NAMES(STATS[0])
IF TXT EQ 'STATS2' THEN PLIST,TAG_NAMES(STATS2(INDGEN(9),INDGEN(9)))

DONE:
END; #####################  END OF ROUTINE ################################
