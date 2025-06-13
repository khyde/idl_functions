; $ID:	STRETCH_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO STRETCH_DEMO
	
;  PRO STRETCH_DEMO
;+
; NAME:
;		STRETCH_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR IDL'S STRETCH
;
; CATEGORY:
;		PALETTE
;		 
;
; CALLING SEQUENCE: STRETCH_DEMO
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
;  STRETCH_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN MAY 14,2012  J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;	********************************
ROUTINE_NAME  = 'STRETCH_DEMO'
; ********************************

; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,



LOADCT, 5

;Create and display an image by entering:

TVSCL, DIST(300)

;Now adjust the color table with STRETCH. Make the entire color table fit in the range 0 to 70 by entering:

STRETCH, 0, 70

;Notice that pixel values above 70 are now colored white. Restore the original color table by entering:

STRETCH





DONE:          
	END; #####################  END OF ROUTINE ################################
