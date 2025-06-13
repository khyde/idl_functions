; $ID:	MUR_2GEQ.PRO,	2015-08-23	$
;+
;;#############################################################################################################
	FUNCTION MUR_2GEQ,ARRAY

; PURPOSE: THIS FUNCTION USES CONGRID TO CHANGE THE SIZE OF VERY HIGH RESOLUTION MUR [SST] 
;          TO 4096X2048 PIXELS [GEQ SIZE]
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = MUR_2GEQ(ARRAY)
;
; INPUTS: ARRAY  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: THE INPUT ARRAY RESIZED TO A STANDARD GEQ SIZE [4096,2048]
;		
; EXAMPLE:
; HELP,MUR_2GEQ(BYTARR([32768, 16384]))
; 
; MODIFICATION HISTORY:
;			WRITTEN AUG 23, 2015 J.O'REILLY
;#################################################################################
;-
;*****************************
ROUTINE_NAME  = 'MUR_2GEQ'
;*****************************

S = SIZEXYZ(ARRAY)
IF S.PX NE 32768 OR S.PY NE 16384 THEN MESSAGE,'ERROR: ARRAY IS NOT A MUR '

RETURN,CONGRID(ARRAY,4096,2048,/INTERP,/CENTER,/MINUS_ONE)
          
	END; #####################  END OF ROUTINE ################################
