; $ID:	PWAIT.PRO,	2015-12-03,	USER-JOR	$
;#############################################################################################################
	PRO PWAIT,INFO,DELAY
;+
; NAME:	PWAIT
;	
;
; PURPOSE: THIS PROGRAM PRINTS TXT AND WAITS BEFORE PROCEEDING
;
; CATEGORY:
;		PRINT
;		 
;
; CALLING SEQUENCE: PWAIT
;
; INPUTS: TXT: INFO TO PRINT
;         DELAY THE TIME IN SECONDS TO WAIT BEFORE PROCEEDING [DEFAULT = 2]
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: PRINTS INFO TO THE SCREEN AND WAITS BEFORE PROCEEDING
;		
;; EXAMPLES:  PWAIT,'TEST' & P,'WAITED 2 SECONDS'
;             PWAIT,'TEST',7 & P,'WAITED 7 SECONDS'
;             PWAIT,INDGEN(9),1 & P,'WAITED 1 SECONDS'
;
; MODIFICATION HISTORY:
;			WRITTEN MAR,7,2014  J.O'REILLY
;			
;			
;#################################################################################
;
;-
;*******************
ROUTINE_NAME='PWAIT'
;*******************
IF N_ELEMENTS(INFO) EQ 0 THEN MESSAGE, 'ERROR: MUST PROVIDE INFO'
IF N_ELEMENTS(DELAY) EQ 0 THEN DELAY = 2 
IF IDLTYPE(INFO) EQ 'STRUCT' THEN HELP,/STRUCT,INFO ELSE PRINT,INFO  
WAIT,DELAY
DONE:          
	END; #####################  END OF ROUTINE ################################
