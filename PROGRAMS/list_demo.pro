; $ID:	LIST_DEMO.PRO,	2014-04-29	$
;#############################################################################################################
	PRO LIST_DEMO,DATA,X=X,Y=Y,N=N
	
;  PRO LIST_DEMO
;+
; NAME:
;		LIST_DEMO
;
; PURPOSE: THIS PROGRAM FOR IDL  LIST FUNCTION
;
; CATEGORY:
;		PALETTE
;		 
;
; CALLING SEQUENCE: LIST_DEMO
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES:
;
;  LIST_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN MAR 12,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***************************
ROUTINE_NAME  = 'LIST_DEMO'
;***************************
;LENGTH = 26
LIST = LIST(ALPHABET(), /EXTRACT)
LETTERS = LIST.TOARRAY()


STOP

PRINT,STR_JOIN(LETTERS) & PN,LETTERS

ALPHA = ''
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(LETTERS)-1 DO BEGIN
  ALPHA= [ALPHA,FIRST(LETTERS)] 
  LIST.REMOVE, [0]
ENDFOR;FOR NTH = 0,N_ELEMENTS(LETTERS)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
PN,LETTERS
PRINT,ALPHA



END; #####################  END OF ROUTINE ################################
