; $ID:	IS_NUM.PRO,	2016-11-07,	USER-JOR	$
;+
;#############################################################################################################
	FUNCTION IS_NUM,NUM

; PURPOSE: THIS FUNCTION TESTS IF NUM IS A NUMBER
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_NUM(NUM)
;
; INPUTS: NUM TO CHECK  


; OUTPUTS: LOGICAL 1 OR 0
;		
; EXAMPLES:
;   PRINT,IS_NUM('13.4'); = 1
;   PRINT,IS_NUM(1.0); = 1
;   PRINT,IS_NUM(1.0D); = 1
;   PRINT,IS_NUM(1E6); = 1
;   PRINT,IS_NUM(1E-6); = 1
;   PRINT,IS_NUM('201412'); = 1
;   PRINT,IS_NUM('20A1412'); = 0
;   PRINT,IS_NUM('CAT'); = 0
;   PRINT,IS_NUM('A201412'); = 0
;   PRINT,IS_NUM(201412); = 1
;   PRINT,IS_NUM(201412L); = 1
;   PRINT,IS_NUM(201412UL); = 1
;   PRINT,IS_NUM(ULONG64(7)); = 1
;   PRINT,IS_NUM(BYTE(7)); = 0  ??
;        
; MODIFICATION HISTORY:
;			WRITTEN JUL 24,2015 WRITTEN BY J.O'REILLY
;     THE CODE: STREGEX(STRTRIM(NUM,2),CHAR,/BOOLEAN)IS FROM WAYNE LANDSMAN PROGRAM VALID_NUM
;####################################################################################
;-
;************************
ROUTINE_NAME  = 'IS_NUM'
;************************
IF NONE(NUM) THEN MESSAGE,'ERROR: NUM IS REQUIRED'
ON_IOERROR,BADNUM

CHAR = '^[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eEdD][-+]?[0-9]+)?$' 
RETURN,STREGEX(STRTRIM(NUM,2),CHAR,/BOOLEAN)

BADNUM:
RETURN,0

END; #####################  END OF ROUTINE ################################
