; $ID:	STRUCT_APPEND.PRO,	2014-04-29	$
;+
;#############################################################################################################
	PRO STRUCT_APPEND,STRUCT,ALL=ALL,FILE=FILE

;
; PURPOSE: APPEND A STRUCTURE TO A SIMILAR STRUCTURE 
;
; CATEGORY:	STRUCT
;
; CALLING SEQUENCE: STRUCT_APPEND,STRUCT
;
; INPUTS: STRUCTURE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		ALL:  CONTAINS THE ACUMULATED STRUCTURE

; OUTPUTS: 
;		
; EXAMPLES: STRUCT_APPEND,STRUCT
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 25,2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'STRUCT_APPEND'
;******************************

COMMON _STRUCT_APPEND,D,FIRST_TAGS
IF N_ELEMENTS(STRUCT) EQ 0 THEN MESSAGE,'ERROR: STRUCT IS REQUIRED'
;===> ENSURE TAGS EQUAL OLD_TAGS
IF NONE(FIRST_TAGS) THEN FIRST_TAGS = TAG_NAMES(STRUCT)
IF MIN(TAG_NAMES(STRUCT) EQ FIRST_TAGS) EQ 1 THEN BEGIN
IF N_ELEMENTS(D) EQ 0 THEN D = STRUCT ELSE D = [D,STRUCT]  
ALL = D
ENDIF;IF TAG_NAMES(D) EQ FIRST_TAGS THEN BEGIN

END; #####################  END OF ROUTINE ################################
