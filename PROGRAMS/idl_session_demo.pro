; $ID:	IDL_SESSION_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO IDL_SESSION_DEMO
	
;  PRO IDL_SESSION_DEMO
;+
; NAME:
;		IDL_SESSION_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR IDL_SESSION
;
; CATEGORY:
;		FILE
;		 
;
; CALLING SEQUENCE:IDL_SESSION_DEMO
;
; INPUTS: 
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: PRINTS TO SCREEN
;		
;; EXAMPLES:
;  IDL_SESSION_DEMO
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUL 22,2012  J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='IDL_SESSION_DEMO'
; *******************************************

; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 
CLOSE,/ALL

PX= 4320
PY=2160

;FFFFFFFFFFFFFFFFFFF
FOR Y= 0,PY DO BEGIN
  ;FFFFFFFFFFFFFFFFFFF
  FOR X =0,PX DO BEGIN
    PRINT,Y,X
    WAIT,0.2
  ENDFOR
ENDFOR


STOP



STOP


DONE:          
	END; #####################  END OF ROUTINE ################################
