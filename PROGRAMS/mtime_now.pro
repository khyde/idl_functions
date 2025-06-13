; $ID:	MTIME_NOW.PRO,	2017-02-13,	USER-JEOR	$
; #########################################################################; 
FUNCTION MTIME_NOW,COMMA=COMMA
;+
; PURPOSE:  RETURNS THE MTIME FOR THE PRESENT TIME
;
; CATEGORY: DATE;
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  
;          COMMA.......... PUNCTUATE THE RESULT WITH COMMA FOR LEGABILITY

; OUTPUTS: MTIME [IN UNSIGNED LONG64 SECONDS SINCE JAN 1,1970]
;
;; EXAMPLES:
;          PRINT,MTIME_NOW()
;          PRINT,MTIME_NOW(/COMMA)
;
; MODIFICATION HISTORY:
;     JAN 22, 2017  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;********************
ROUTINE = 'MTIME_NOW'
;********************

MTIME = LONG64(SYSTIME(1,/SECONDS))
IF KEY(COMMA) THEN RETURN,STR_COMMA(MTIME) ELSE RETURN,MTIME

END; #####################  END OF ROUTINE ################################
