; $ID:	STRUCT_FROM.PRO,	2014-04-29	$
;#############################################################################################################
	FUNCTION STRUCT_IT,VAL,NAME=NAME
	
;+
; NAME:
;		STRUCT_IT
;
; PURPOSE: THIS FUNCTION RETURNS A STRUCTURE FOR A SCALAR VARIABLE
;
; CATEGORY:STRUCTURES
;		
;		 
;
; CALLING SEQUENCE:RESULT = STRUCT_IT()
;
; INPUTS: VAL  A SCALAR VARIABLE

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS: 
;         NAME  NAME [TAGNAME TO ASSIGN TO THE STRUCTURE]
; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, STRUCT_IT(10)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 8, 2014 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'STRUCT_IT'
;****************************
IF N_ELEMENTS(VAL) EQ 0 THEN MESSAGE,'ERROR: MUST PROVIDE A VAL'
IF N_ELEMENTS(NAME) NE 1 THEN NAME = 'S'
RETURN,CREATE_STRUCT(NAME,VAL)  
DONE:          
	END; #####################  END OF ROUTINE ################################
