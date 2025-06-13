; $ID:	IS_OG.PRO,	2017-08-27-18,	USER-JEOR	$
;+
;;#############################################################################################################
	FUNCTION IS_OG

; PURPOSE: THIS LOGICAL FUNCTION TESTS IF THE CURRENT GRAPHICS IS OBJECT GRAPHICS [OG] OR NOT [DIRECT GRAPHICS]
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_OG()
;
; INPUTS: NONE          

; OUTPUTS: LOGICAL 1 OR 0
;		
;; EXAMPLES:
;         P = PLOT(INDGEN(9),INDGEN(9)) & PRINT,IS_OG()& P.CLOSE & PLOT,INDGEN(9),INDGEN(9)& PRINT,IS_OG()
;         P = PLOT(INDGEN(9),INDGEN(9)) & PRINT,IS_OG()& P.CLOSE & ZWIN,[9,9]& PRINT,IS_OG() & ZWIN
;         W = WINDOW() & PRINT,IS_OG()& WAIT,2 & W.CLOSE & ZWIN,[9,9]& PRINT,IS_OG()& ZWIN

;         
; MODIFICATION HISTORY:
;			WRITTEN AUG 21,2017 J.O'REILLY
;    AUG 27,2017 JEOR: ADDED EXAMPLES

;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_OG'
;***********************
RESULT = GETWINDOWS() 

IF RESULT EQ [] THEN RETURN, 0 ELSE RETURN,1

END; #####################  END OF ROUTINE ################################
