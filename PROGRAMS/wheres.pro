; $ID:	WHERES.PRO,	2016-05-11,	USER-JOR	$
; #########################################################################; 
FUNCTION WHERES,ARRAY,VALUES,COUNT, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT
;+
; PURPOSE:  USES VALUE_LOCATE TO QUICKLY FIND SUBSCRIPTS IN ARRAY THAT ARE CLOSEST TO VALUES PROVIDED 
;
; CATEGORY: WHERE FAMILY;
;
;
; INPUTS: ARRAY ...... THE ARRAY IN WHICH TO FIND THE VALUES
;         VALUES...... THE VALUES TO FIND IN THE ARRAY
;
; OUTPUTS: COUNT ...... THE NUMBER OF VALUES FOUND
; 
; KEYWORDS: 
;             NCOMPLEMENT
;             COMPLEMENT

; OUTPUTS:  THE SUBSCRIPTS IN THE ARRAY WHERE THE VALUES ARE FOUND 
;
;; EXAMPLES:
;            PRINT,WHERES(FINDGEN(100),INDGEN(10),COUNT,NCOMPLEMENT=NCOMP,COMPLEMENT=COMP) & P,COUNT,NCOMPLEMENT,COMPLEMENT
;
; MODIFICATION HISTORY:
;     MAY 11, 2016  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;***********************
ROUTINE_NAME  = 'WHERES'
;***********************

SUBS = VALUE_LOCATE(ARRAY,VALUES)
COUNT = N_ELEMENTS(SUBS)
NCOMPLEMENT = 0 > (N_ELEMENTS(ARRAY) - COUNT)
COMPLEMENT  = REMOVE(LINDGEN(N_ELEMENTS(ARRAY)),SUBS)
RETURN,SUBS


END; #####################  END OF ROUTINE ################################
