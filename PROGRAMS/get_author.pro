; $ID:	GET_AUTHOR.PRO,	2017-11-29-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_AUTHOR

; PURPOSE: THIS FUNCTION RETURNS THE AUTHOR DEPENDING ON THE !S.USER VARIABLE 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_AUTHOR()
;
; INPUTS: NONE  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: NAME OF AUTHOR 
;		
;; EXAMPLES:
;  PRINT, GET_AUTHOR()
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;			MODIFIED:
;			 JAN 31, 2017 - KJWH: CHANGED !S.COMPUTER TO !S.USER
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_AUTHOR'
;****************************
IF !S.USER EQ 'KJWH'          THEN AUTHOR = 'K.J.W.HYDE'
IF !S.USER EQ 'JEOR'          THEN AUTHOR = "J.E.O'REILLY"                               ; JOR DESKTOP
RETURN,AUTHOR
          
	END; #####################  END OF ROUTINE ################################
