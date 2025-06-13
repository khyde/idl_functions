; $ID:	BRACKET.PRO,	2019-09-21-10,	USER-JEOR	$
; #########################################################################; 
FUNCTION BRACKET,NUM,VAL,PCT=PCT
;+
; PURPOSE:  RETURN TWO VALUES BRACKETING THE INPUT VALUE
;
; CATEGORY: MATH
;
;
; INPUTS:
;         NUM ......... NUMBER TO BRACKET 
;         VAL ......... VALUE TO SUBTRACT AND ADD TO THE NUM 
;
;
; KEYWORDS:  
;         PCT .......... THE PERCENT OF THE INPUT NUM TO SUBTRACT AND ADD TO THE INPUT NUM
;        
;         
; OUTPUTS: ARRAY OF THE  TWO VALUES BRACKETING THE INPUT NUM
;
;; EXAMPLES: 
;           PRINT,BRACKET(5,1);4.000,6.000
;           PRINT,BRACKET(10,1);9,11
;           PRINT,BRACKET(100,1);  99     101
;           PRINT,BRACKET(100,1,PCT = 1);99.0000      101.000
;           PRINT,BRACKET(100,1,PCT = 0.01);
;           PRINT,BRACKET(-5,1); NOTE WHAT HAPPENS WITH A NEGATIVE NUMBER
;           PRINT,BRACKET(-5,1,/PCT);
;
; MODIFICATION HISTORY:
;     SEP 17, 2019  WRITTEN BY: J.E. O'REILLY
;     SEP 21, 2019,JEOR: IF NUM LT 0.0 AND NUM GT -1.0 THEN OUT = REVERSE(OUT)
; #########################################################################
;-
;******************
ROUTINE = 'BRACKET'
;******************
IF KEY(PCT) THEN VAL_ = (NUM * (PCT/100.0)) ELSE VAL_ = (VAL)
OUT = [(NUM-VAL_),(NUM+VAL_)]
IF NUM LT 0.0 AND NUM GT -1.0 THEN OUT = REVERSE(OUT)
RETURN,OUT

END; #####################  END OF ROUTINE ################################
