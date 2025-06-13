; $ID:	IMAGE_STATISTICS_DEMO.PRO,	2014-04-29	$
;#############################################################################################################
	PRO IMAGE_STATISTICS_DEMO
	
;  PRO IMAGE_STATISTICS_DEMO
;+
; NAME:
;		IMAGE_STATISTICS_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR IDL'S PLOTS
;
; CATEGORY:
;		PLOT
;		 
;
; CALLING SEQUENCE: IMAGE_STATISTICS_DEMO
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
;  IMAGE_STATISTICS_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 8,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***************************
ROUTINE_NAME  = 'IMAGE_STATISTICS_DEMO'
;***************************
IMAGE_STATISTICS,[1,2,3],COUNT=COUNT,MINIMUM = MINIMUM,MAXIMUM = MAXIMUM,DATA_SUM = DATA_SUM,MEAN = MEAN,VARIANCE = VARIANCE, SUM_OF_SQUARES=SUM_OF_SQUARES
PRINT,'COUNT  ',COUNT,'   MINIMUM   ',MINIMUM,'   MAXIMUM  ',MAXIMUM,'   DATA_SUM  ',DATA_SUM,'   MEAN   ',MEAN,'   VARIANCE   ',VARIANCE,'   SUM_OF_SQUARES   ', SUM_OF_SQUARES


END; #####################  END OF ROUTINE ################################
