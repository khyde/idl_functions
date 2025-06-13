; $ID:	FOR_LOOP_DEMO.PRO,	2014-04-29	$
;#############################################################################################################
	PRO FOR_LOOP_DEMO
	
;  PRO FOR_LOOP_DEMO
;+
; NAME:
;		FOR_LOOP_DEMO
;
; PURPOSE: THIS PROGRAM DEMONSTRATES THAT NTH IS INCREMENTED AFTER FORLOOP IS FINISHED
;
; CATEGORY:
;		PLOT
;		 
;
; CALLING SEQUENCE: FOR_LOOP_DEMO
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
;  FOR_LOOP_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 20,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***************************
ROUTINE_NAME  = 'FOR_LOOP_DEMO'
;***************************
NUM = INDGEN(3)+1
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(NUM)-1 DO BEGIN
      PRINT,'NTH   ',NTH,'  INSIDE LOOP'
  ENDFOR;FOR NTH = 0,N_ELEMENTS(NUM)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
  
      PRINT,'NTH   ',NTH,'  AFTER LOOP'
  STOP
END; #####################  END OF ROUTINE ################################
