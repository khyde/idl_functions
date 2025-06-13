; $ID:	BIVARIATE.PRO,	2014-04-21	$
;#############################################################################################################
	FUNCTION BIVARIATE,N ,XF=XF
	
;  PRO BIVARIATE
;+
; NAME:
;		BIVARIATE
;
; PURPOSE: THIS FUNCTION GENERATES A BIVARIATE SET OF X & Y VALUES 
;
; CATEGORY:
;		STATISTICS
;		 
;
; CALLING SEQUENCE:RESULT = BIVARIATE(N)
;
; INPUTS:
;		N:	NUMBER OF XY PAIRS DESIRED 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
; XF : XFACTER-MULTIPLIER

; OUTPUTS: A STRUCTURE WITH X AND Y VARIATES
;		
;; EXAMPLES:
;  XY=BIVARIATE() & HELP,XY
;	NOTES:
;		
;
;
; MODIFICATION HISTORY:
;			AUG 8,2013 WRITTEN BY J.O'REILLY
;			APR19,2014 UPGRADED WITHNEW FUNCTIONS
;#################################################################################
;
;
;-
;**************************
ROUTINE_NAME  = 'BIVARIATE'
;**************************
; 
 IF NONE(N)  THEN N = 500
 IF NONE(XF) THEN XF = 35
 IF NONE(YF) THEN YF = 77
;===>  GENERATE VARIABLES X AND Y
   X = FINDGEN(N)
   X =    X  +  XF* RANDOMU(S,N_ELEMENTS(X))
   Y =    X  +  YF* RANDOMN(S,N_ELEMENTS(X))
   RETURN, CREATE_STRUCT('X',X,'Y',Y)

DONE:          
	END; #####################  END OF ROUTINE ################################
