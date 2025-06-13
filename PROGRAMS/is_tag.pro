; $ID:	IS_TAG.PRO,	2015-02-14	$
;+
;;#############################################################################################################
	FUNCTION IS_TAG,STRUCT,TAG,COUNT
;
; PURPOSE: THIS LOGICAL FUNCTION RETURNS A 1  IF THE TAG IS PRESENT IN A STRUCTURE
 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_TAG(STRUCT,TAG)
;
; INPUTS: STRUCT A STRUCTURE
;         TAG: TARGET TAGNAME TO FIND

; OPTIONAL INPUTS:  NONE:	
;		
; KEYWORD PARAMETERS:  NONE
;        

; OUTPUTS: LOGICAL 1 OR 0
;		
; EXAMPLES:
; DB = GET_LME_DB() & P, IS_TAG(DB,'MAP')
; DB = GET_LME_DB() & P, IS_TAG(DB,'JUNK')
;	NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 14,2015 BY J.O'REILLY
;     SEP 12,2015,JOR RENAMED ISTAG TO IS_TAG TO CONFORM TO NAMING IN THE IS_ FAMILY

;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_TAG'
;***********************

IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE,'ERROR: STRUCT MUST BE A STRUCTURE'
IF IDLTYPE(TAG) NE 'STRING' THEN MESSAGE,'ERROR: NAME MUST BE A STRING'

IF WHERE_MATCH( TAG_NAMES(STRUCT),TAG,COUNT)NE [] THEN RETURN,1 ELSE RETURN,0
  
DONE:          
	END; #####################  END OF ROUTINE ################################
