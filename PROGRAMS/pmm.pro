; $ID:	PMM.PRO,	2015-12-03,	USER-JOR	$
;+
;#############################################################################################################
	PRO PMM, ARR
;
; PURPOSE:  PRINT THE MINMAX OF THE INPUT ARR [A WRAPPER FOR MM]
;
; CATEGORY:	PRINT
;
; CALLING SEQUENCE: PMM,ARR
;
; INPUTS: ARR.....  DATA 
;         
;		
; OPTIONAL INPUTS: NONE
;			
;		
; KEYWORD PARAMETERS: NONE 
;		

; OUTPUTS: PRINTS THE MINMAX OF THE INPUT ARR
;		
; EXAMPLES: 
;   PMM,1
;   PMM,INDGEN(9)
;   PMM,[FINDGEN(9),MISSINGS(10.)]
;
; MODIFICATION HISTORY:
;			SEP 04,2015  WRITTEN BY J.O'REILLY
;			NOV 13, 2015 - KJWH: CHANGED MESSAGE TO PRINT SO THAT IT WILL PRINT THE ERROR 
;			AND NOT CRASH
;			DEC 03,2015,JOR ADDED EXAMPLES
;			
;#################################################################################
;-
;********************
ROUTINE_NAME  = 'PMM'
;********************
IF NONE(ARR) THEN PRINT,'ERROR: MUST PROVIDE ARR'
PRINT,MM(ARR)


END; #####################  END OF ROUTINE ################################
