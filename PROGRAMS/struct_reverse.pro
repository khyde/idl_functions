; $ID:	STRUCT_REVERSE.PRO,	2020-07-08-15,	USER-KJWH	$
; 
;#############################################################################################################
	FUNCTION STRUCT_REVERSE,STRUCT 
	
;  PRO STRUCT_REVERSE
;+
; NAME:
;		STRUCT_REVERSE
;
; PURPOSE: THIS FUNCTION REVERSES THE ORDER OF A STRUCTURE
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = STRUCT_REVERSE(STRUCT)
;
; INPUTS:
;		STRUCT:	INPUT STRUCTURE 
;

; OUTPUTS: SAME AS INPUT STRUCTURE BUT WITH ELEMENTS REVERSED
;		
;; EXAMPLES:
;   S = REPLICATE(CREATE_STRUCT('ARR',1),2) & S[1].ARR = 2 & PRINT,S[0].ARR & PRINT, S[1].ARR & S=STRUCT_REVERSE(S) & PRINT,S[0].ARR & PRINT, S[1].ARR
;  
;  
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN APR 20,2013 J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************
ROUTINE_NAME  = 'STRUCT_REVERSE'
; *******************************
    I = INDGEN(N_ELEMENTS(STRUCT))
    I = REVERSE(I)
    STRUCT=STRUCT(I)
    RETURN,STRUCT
DONE:          
	END; #####################  END OF ROUTINE ################################
