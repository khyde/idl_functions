; $ID:	DEMO_LOG.PRO,	2014-04-29	$
;#############################################################################################################
	PRO DEMO_LOG
	
;  PRO DEMO_LOG
;+
; NAME:
;		DEMO_LOG
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR UNDERSTANDING LOG-TRANSFORMATION
;
; CATEGORY:
;		PALETTE
;		 
;
; CALLING SEQUENCE: DEMO_LOG
;
; INPUTS: NONE
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
;
;  DEMO_LOG
;
; MODIFICATION HISTORY:
;			WRITTEN MAR 13,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***************************
ROUTINE_NAME  = 'DEMO_LOG'
;***************************
;===> MAKE A SIMPLE GEOMETRIC TIME SERIES
TS = INTERVAL([-1,4],BASE = 10)
LOG_TS = ALOG10(TS)

PLINES

PRINT,' TS: ',TS
PRINT,' LOG_TS: ',LOG_TS
M=MEAN(TS)
LM=MEAN(LOG_TS)

PRINT,M

STOP
END; #####################  END OF ROUTINE ################################
