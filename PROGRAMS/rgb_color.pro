; $ID:	RGB_COLOR.PRO,	2021-04-15-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION RGB_COLOR,COLOR,PAL = PAL
;
;
; PURPOSE: THIS FUNCTION GETS THE RGB TRIPLET FROM A PALETTE
; 
; CATEGORY:	RGB		 
;
; CALLING SEQUENCE: RESULT = RGB_COLOR(COLOR,PAL=PAL)
;
; INPUTS: COLOR INDEX 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:  PAL [NAME OF PALETTE PROGRAM]

; OUTPUTS: A RGB TRIPLET
;		
;; EXAMPLES:
;   COLOR= RGB_COLOR[0] & HELP,COLOR
;   COLOR= RGB_COLOR(0,PAL = 'PAL_SW3') & HELP,COLOR
;   COLOR= RGB_COLOR('PAL_SW3',COLORS=[1,251]) & HELP,COLOR
;   
;   
;  NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 12, 2014 J.O'REILLY
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'RGB_COLOR'
;******************************
;#####>    DEFAULTS     #######################
IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_SW3'
IF N_ELEMENTS(COLOR) NE 1 THEN COLORS = [0,0] ELSE COLORS = [COLOR,COLOR]
RGB = CPAL_READ(PAL) 
RETURN,RGB(*,COLORS[0]:COLORS[1])

DONE:          
	END; #####################  END OF ROUTINE ################################
