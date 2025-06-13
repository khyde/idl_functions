; $ID:	SAMPLE.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION SAMPLE,ARRAY,N
;
;
;
;
; PURPOSE: THIS FUNCTION RETURNS A SAMPLE [N] OF THE INPUT ARRAY
; 
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: 
;
; INPUTS: ARRAY ARRAY OF VALUES
;         N NUMBER OF OUTPUT VALUES FROM THE ARRAY 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 
;		
; EXAMPLES:
;  PL,SAMPLE(INDGEN(100),10)
;  
;  
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 27,2014 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'SAMPLE'
;****************************
IF N_ELEMENTS(N) NE 1 THEN N = 1
I = LINDGEN(N_ELEMENTS(ARRAY))
NUM = N_ELEMENTS(ARRAY)/N
IN = INTERVAL(I,NUM)
RETURN,ARRAY(IN)
DONE:          
	END; #####################  END OF ROUTINE ################################
