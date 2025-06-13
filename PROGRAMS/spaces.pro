; $ID:	SPACES.PRO,	2014-01-23 12	$
;#############################################################################################################
	FUNCTION SPACES, N 
	
;  PRO SPACES
;+
; NAME:
;		SPACES
;
; PURPOSE: THIS FUNCTION GENERATES A STRING OF SPACES
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE: RESULT = SPACES(TXT)
;
; INPUTS:
;		N:	NUMBER OF SPACES  [DEFAULT = 5]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: A STRING OF SPACES
;		
;; EXAMPLES:
;  HELP, SPACES()
;  HELP, SPACES(10)
;  T = SPACES() +'HELLO' +SPACES() & HELP,T
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2013 J.O'REILLY
;#################################################################################
;-
;	*******************************
ROUTINE_NAME  = 'SPACES'
; *******************************
IF N_ELEMENTS(N) NE 1 THEN _N = 5 ELSE _N = N
RETURN,STRING(REPLICATE(32B,_N))
DONE:          
	END; #####################  END OF ROUTINE ################################
