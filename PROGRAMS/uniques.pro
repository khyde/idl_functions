; $ID:	UNIQUES.PRO,	2019-07-29-16,	USER-KJWH	$
; #########################################################################; 
FUNCTION UNIQUES,ARR
;+
; PURPOSE:  RETURN THE UNIQUE VALUES IN AN ARR
;
; CATEGORY: UTILITY
;
;
; INPUTS: 
;       ARR.......... ARRAY OF VALUES
;
;
; KEYWORDS:  NONE

; OUTPUTS: THE UNIQUE VALUES IN THE INPUT ARR
;
;; EXAMPLES:
;           PRINT,UNIQUES([1,1,2,2,3,3,4,4,5,5])
;
; MODIFICATION HISTORY:
;     MAR 12, 2017  WRITTEN BY: J.E. O'REILLY
;     JUL 29, 2019 - KJWH: Changed UNIQUE to UNIQ
;-
; #########################################################################

;******************
ROUTINE = 'UNIQUES'
;******************
RETURN,ARR(UNIQ(ARR))

END; #####################  END OF ROUTINE ################################
