; $ID:	NUMBER.PRO,	2020-06-30-17,	USER-KJWH	$
;#################################################################################################
FUNCTION NUMBER,NUM
;+
;	NUMBER:	THIS FUNCTION RETURNS  1 (TRUE) IF THE INPUT IS A NUMBER (OR A STRING NUMBER), 
;	                               0 (FALSE) IF IT IS NOT
;	                               
; CATEGORY: LOGICAL	                               
;
;	EXAMPLES:
;  	PRINT, NUMBER(['1','CAT','0','DOG','1.234','','1E4','123456']);=1       0       1       0       1       0       1       1
;		PRINT, NUMBER(-1L)
;   PRINT, NUMBER('') ; = 0 [NUL STRING IS NOT A NUMBER
;   PRINT,NUMBER(INDGEN(9))
;   PRINT,NUMBER(SINDGEN(9))
;   PRINT,NUMBER(FINDGEN(9))
;   PRINT,NUMBER(['ABC','A20A1412'])
;   PRINT,NUMBER(1.0); = 1
;   PRINT,NUMBER(1.0D); = 1
;   PRINT,NUMBER(1E6); = 1
;   PRINT,NUMBER(1E-6); = 1
;   PRINT,NUMBER('201412'); = 1
;   PRINT,NUMBER('20A1412'); = 0
;   PRINT,NUMBER('A201412'); = 0
;   PRINT,NUMBER(201412); = 1
;   PRINT,NUMBER(201412L); = 1
; MODIFICATION HISTORY:	
;              MAY 28, 2003 WRITTEN BY:	J.E. O'REILLY, NOAA, 28 TARZWELL DRIVE, NARRAGANSETT, RI 02882
;              FEB 26,2015,JOR STANDARDIZED FORMATTING, ADDED NEW FUNCTIONS
;              JUL 30,2015,JOR REWROTE PROGRAM [NOW USING IS_NUM]
;######################################################################################################
;-
;*********************
ROUTINE_NAME='NUMBER'
;*********************

ARR = REPLICATE(-1,NOF(NUM))
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0L, NOF(NUM)-1 DO BEGIN
  ARR[NTH] = IS_NUM(NUM[NTH])
ENDFOR;FOR NTH = 0L, NOF(NUM)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
RETURN,ARR

END; #####################  END OF ROUTINE ################################
