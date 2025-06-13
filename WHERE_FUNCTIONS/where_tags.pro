; $ID:	WHERE_TAGS.PRO,	2018-03-23-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION WHERE_TAGS,STRUCT,NAMES
;
;
;
;
; PURPOSE: THIS FUNCTION RETURNS THE LOCATIONS FOR TAGS IN A STRUCTURE
; 
; 
; 
; CATEGORY:	STRUCTURES;		 
;
; CALLING SEQUENCE: RESULT = WHERE_TAGS(STRUCT)
;
; INPUTS: STRUCT A STRUCTURE
;         NAMES: TARGET TAGNAMES TO FIND

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;        

; OUTPUTS: 
;		
; EXAMPLES:
; DB = CSV_READ(!S.DATA +'LMES67_DBF_MASTER.CSV') & OK = WHERE_TAGS(DB,'MAP')

;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 20,2014 J.O'REILLY
;			JUL 25, 2014 - JEOR: Updated to find nested tagnames
;			MAR 23, 2018 - KJWH: Removed COMMON _WHERE_TAGS,TAGS
;#################################################################################
;-
;****************************
  ROUTINE_NAME  = 'WHERE_TAGS'
;****************************
  IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE,'ERROR: STRUCT MUST BE A STRUCTURE'
  IF IDLTYPE(NAMES) NE 'STRING' THEN MESSAGE,'ERROR: NAMES MUST BE A STRING'

  TAGNAMES = TAG_NAMES(STRUCT)
  OK = WHERE_MATCH(TAGNAMES,NAMES,COUNT)
  IF COUNT GE 1 THEN RETURN,OK

  RETURN, []
          
END; #####################  END OF ROUTINE ################################
