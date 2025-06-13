; $ID:	PSTRUCT.PRO,	2014-12-11	$
;#############################################################################################################
	PRO PSTRUCT,STRUCT,NUM
	
;  PRO PSTRUCT
;+
; NAME:
;		PSTRUCT
;
; PURPOSE: THIS PROGRAM PRINTS INFO ABOUT A STRUCTURE BY CALLING STRUCT_PRINT
;
; CATEGORY:
;		STRUCT FAMILY
;		 
;
; CALLING SEQUENCE: PSTRUCT,STRUCT
;
; INPUTS: STRUCTURE
;		
;		
; OPTIONAL INPUTS:
;		NUM: NUMBER OF ELEMENTS TO PRINT [DEFAULT = 5]
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES: I = MAPS_INFO('GEQ') & PSTRUCT,I
;
;  PSTRUCT
;
; MODIFICATION HISTORY:
;			WRITTEN JUL 8,2013 J.O'REILLY;	
;			OCT 12,2014,JOR:IF NONE(STRUCT) THEN STRUCT = STRUCT_READ()
		
;#################################################################################
;
;
;-
;************************
ROUTINE_NAME  = 'PSTRUCT'
;************************
;
IF NONE(NUM) THEN NUM = 5 ELSE NUM = NUM -1

STRUCT_PRINT,STRUCT,NUM
PN,STRUCT

END; #####################  END OF ROUTINE ################################
