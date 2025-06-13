; $ID:	SMALLNUM.PRO,	2016-02-04,	USER-JOR	$
; 
FUNCTION SMALLNUM,NUM
; #########################################################################; 
;+
; PURPOSE:  THIS FUNCTION RETURNS THE SMALLEST FLOATING POINT OR DOUBLE PRECISION NUMBER POSSIBLE FOR THIS MACHINE

;
; CATEGORY: UTILITY;
;
; INPUTS: 
;       ..... NUM A FLOAT OR DOUBLE NUMBER OR ARRAY
;
;
; KEYWORDS:  NONE

; OUTPUTS: THE SMALLEST FLOATING POINT OR DOUBLE PRECISION NUMBER POSSIBLE FOR THIS MACHINE
;
; EXAMPLES:
;         PRINT,SMALLNUM()
;         PRINT,SMALLNUM(0.0)
;         PRINT,SMALLNUM(0.0D)
;         PRINT,SMALLNUM(FINDGEN(9))
;         PRINT,SMALLNUM(DINDGEN(9))
;
; MODIFICATION HISTORY:
;     FEB 04, 2016  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*************************
ROUTINE_NAME  = 'SMALLNUM'
;*************************
IF IDLTYPE(NUM) EQ 'DOUBLE' THEN DOUBLE=1 ELSE DOUBLE = 0

RETURN,(MACHAR(  DOUBLE= DOUBLE )).EPS


END; #####################  END OF ROUTINE ################################
