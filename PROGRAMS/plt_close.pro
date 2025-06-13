; $ID:	PLT_CLOSE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PLT_CLOSE

;
; PURPOSE: CLOSES ALL GRAPHICS OBJECTS  USING THE CLOSE METHOD
;
; CATEGORY:	PLT  
;
; CALLING SEQUENCE: PLT_CLOSE,OBJ,FILE=FILE
;
; INPUTS: NONE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE
;		
; OUTPUTS: CLOSES ALL GRAPHICS OBJECTS
;		
;
; MODIFICATION HISTORY:
;			APR 29,2014 WRITTEN BY  J.O'REILLY
;			
;			
;#################################################################################
;
;-
;***************************
ROUTINE_NAME  = 'PLT_CLOSE'
;***************************
;
;##### GET GRAPHICS OBJECTS  #####
WIN = GETWINDOWS(NAMES=OBJS)
 IF NONE(OBJS) THEN GOTO,DONE
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(OBJS) DO BEGIN
  OBJ = OBJS[NTH]
  OBJ.CLOSE
ENDFOR;FOR NTH = 0,N_ELEMENTS(OBJS) DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

DONE:

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
END; #####################  END OF ROUTINE ################################
