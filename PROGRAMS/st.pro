; $ID:	ST.PRO,	2020-06-30-17,	USER-KJWH	$
;#############################################################################################################
	PRO ST,STRUCT
;###################################################################################################	
;  PRO ST
;+

;
; PURPOSE: THIS PROGRAM PRINTS STRUCTURE INFO
;
; CATEGORY:
;		STRUCT
;		 
;
; CALLING SEQUENCE: ST
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: PRINTS STRUCTURE INFO,NUMBER OF TAGS AND NUMBER OF ELEMENTS [RECORDS]
;		
;
; MODIFICATION HISTORY:
;     WRITTEN OCTOBER 02,2011,J. O'REILLY
;			MAR 14,2013 ,JOR, FORMATTING, REMOVED NTH,  IF N_TAGS(STRUCT) EQ 1 THEN STRUCT = STRUCT.(0)
;     AUG 24,2016 ,JOR, ADDED NUMBER OF TAGS AND ELEMENTS
;#################################################################################
;
;
;-
;*******************
ROUTINE_NAME  = 'ST'
;*******************

HELP,/STRUCTURE,STRUCT
PRINT,STRTRIM(N_TAGS(STRUCT)) + ' TAGS   ',STRTRIM(STR_COMMA(N_ELEMENTS(STRUCT))) + ' ELEMENTS/RECORDS'  

END; #####################  END OF ROUTINE ################################
