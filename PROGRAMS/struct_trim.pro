; $ID:	STRUCT_TRIM.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	FUNCTION STRUCT_TRIM,STRUCT
;
;
; PURPOSE: THIS FUNCTION USES STRTRIM TO TRIM LEADING AND TRAILING SPACES FROM STRING TAGS IN A STRUCTURE
;  
; 
; 
; CATEGORY:	STRUCT;		 
;
; CALLING SEQUENCE: RESULT = STRUCT_TRIM(STRUCT)
;
; INPUTS: STRUCT 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: A STRUCTURE WITH ALL STRING TAGS TRIMMED OF SPACES
;		
;; EXAMPLES:
;  ST, STRUCT_TRIM(STRUCT)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN  19, 2014 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'STRUCT_TRIM'
;****************************
IF IDLTYPE(STRUCT) NE 'STRUCT' THEN MESSAGE,'ERROR: INPUT [STRUCT] MUST BE A STRUCTURE'
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_TAGS(STRUCT)-1 DO BEGIN
  IF IDLTYPE(STRUCT.(NTH)) EQ 'STRING' THEN STRUCT.(NTH) = TEMPORARY(STRTRIM(STRUCT.(NTH),2))  
ENDFOR;FOR NTH = 0,N_TAGS(STRUCT)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
RETURN, STRUCT
DONE:          
	END; #####################  END OF ROUTINE ################################
