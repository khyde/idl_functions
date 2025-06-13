; $ID:	FONT_HELV2.PRO,	2014-04-29	$
;#############################################################################################################
	PRO FONT_HELV2
	
;  PRO FONT_HELV2
;+
; NAME:
;		FONT_HELV2
;
; PURPOSE: THIS PROGRAM CALLS FONT_HELVITICA_BOLD THEN FONT_HELVETICA 
;           TO GET BLACK WITH WHITE OVERPRINTING CHARACTERS FOR LABELLING SATELLITE IMAGES 
;
; CATEGORY:
;		FONT
;		 
;
; CALLING SEQUENCE: FONT_HELV2
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
;  FONT_HELV2
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 17,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***************************
ROUTINE_NAME  = 'FONT_HELV2'
;***************************
COMMON,_FONT_HELV2, OVERPRINT

IF N_ELEMENTS(OVERPRINT) EQ 0 THEN BEGIN
FONT_HELVETICA

OVERPRINT = 1
ENDIF;IF N_ELEMENTS(OVERPRINT) EQ 0 THEN BEGIN


END; #####################  END OF ROUTINE ################################
