; $ID:	IS_L3B.PRO,	2017-07-11-14,	USER-JEOR	$
;+
;;#############################################################################################################
	FUNCTION IS_GSMAP, TXT

; PURPOSE: RETURNS 1 IF TXT A GSx MAP OR 0 IF NOT
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_L3B(FILE)
;
; INPUTS: FILE  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: 1 OR 0 
;		
; EXAMPLES:
;       PRINT, IS_GSMAP('GS9')
;       PRINT, IS_GSMAP('GSMAP')
;       
; MODIFICATION HISTORY:
;			WRITTEN JUL 09, 2017 J.O'REILLY
;#################################################################################
;-
; **************************
  ROUTINE_NAME  = 'IS_GSMAP'
; **************************

  TXT = STRUPCASE(TXT)
  IF HAS(TXT,'GS1')  THEN RETURN, 1
  IF HAS(TXT,'GS2')  THEN RETURN, 1
  IF HAS(TXT,'GS4')  THEN RETURN, 1
  IF HAS(TXT,'GS5')  THEN RETURN, 1
  IF HAS(TXT,'GS9')  THEN RETURN, 1
  IF HAS(TXT,'GS10') THEN RETURN, 1 
  RETURN,0
          
END; #####################  END OF ROUTINE ################################
