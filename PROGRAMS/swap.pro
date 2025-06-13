; $ID:	SWAP.PRO,	2016-09-05,	USER-JOR	$
;+
;#############################################################################################################
	PRO SWAP,A,B
;
; PURPOSE: SWAP [EXCHANGE] TWO VARIABLES
;
; CATEGORY:	UTILITY
;
; CALLING SEQUENCE: SWAP,A,B
;
; INPUTS: A,B THE TWO ITEMS TO SWAP
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: A = 1 & B = 2 & SWAP,A,B & PRINT,A,B
;            A = [0,0,1,1] & B = [2,2,2,2] & SWAP,A,B & PRINT,A,B
;            A = 'A' & B = 'B'& SWAP,A,B & PRINT,A,B
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 28,2014 J.O'REILLY
;			SEP 05,2016,JOR ADDED TEMPORY
;			
;#################################################################################
;-
;*********************
ROUTINE_NAME  = 'SWAP'
;*********************

IF N_ELEMENTS(A) EQ 0 OR N_ELEMENTS(B) EQ 0  THEN MESSAGE,'TWO VARIABLES ARE REQUIRED'

TEM = TEMPORARY(A)
A = B
B = TEM  

END; #####################  END OF ROUTINE ################################
