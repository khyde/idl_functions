; $ID:	GET_RGB_TABLE.PRO,	2021-04-15-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_RGB_TABLE,PAL,COLORS=COLORS
;
;
; PURPOSE: THIS FUNCTION GETS THE RGB TABLE FOR A PALETTE
; 
; CATEGORY:	PALETTES;		 
;
; CALLING SEQUENCE: RESULT = GET_RGB_TABLE(PAL)
;
; INPUTS: PAL 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   COLORS:  [LOWEST ,HIGHEST] COLORS TO EXTRACT FROM PALETTE DEFAULT = [0,255]

; OUTPUTS: 
;		
;; EXAMPLES:
;   RGB_TABLE= GET_RGB_TABLE() & HELP,RGB_TABLE
;   RGB_TABLE= GET_RGB_TABLE('PAL_SW3') & HELP,RGB_TABLE
;   RGB_TABLE= GET_RGB_TABLE('PAL_SW3',COLORS=[1,251]) & HELP,RGB_TABLE
;   RGB_TABLE= GET_RGB_TABLE(COLORS=[1,251]) & HELP,RGB_TABLE
;   
;   
;  NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 4, 2014 J.O'REILLY
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'GET_RGB_TABLE'
;******************************
;#####>    DEFAULTS     #######################
IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_SW3'
IF N_ELEMENTS(COLORS) NE 2 THEN COLORS = [0, 255]

 RGB = CPAL_READ(PAL) 
 RETURN,RGB(*,COLORS[0]:COLORS[1])

DONE:          
	END; #####################  END OF ROUTINE ################################
