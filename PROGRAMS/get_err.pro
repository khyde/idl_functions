; $ID:	GET_ERR.PRO,	2020-06-30-17,	USER-KJWH	$
; 
FUNCTION GET_ERR
; #########################################################################; 
;+
; PURPOSE: THIS FUNCTION RETURNS THE ERRORS IN !ERROR_STATE  

;
; CATEGORY: GET;
;

; OUTPUTS:  GETS THE !ERROR_STATE.MSG 
;
;; EXAMPLES: PLIST,GET_ERR()
;
; MODIFICATION HISTORY:
;     JAN 20,2016  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;************************
ROUTINE_NAME  = 'GET_ERR'
;************************
TXT =!ERROR_STATE.MSG 
IF TXT[0] EQ '' THEN TXT = 'NO ERRORS'
RETURN,TXT 

END; #####################  END OF ROUTINE ################################
