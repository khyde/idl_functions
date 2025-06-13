; $ID:	IS_DATE.PRO,	2015-08-02	$
;+
;;#############################################################################################################
	FUNCTION IS_DATE,TXT

; PURPOSE: THIS FUNCTION TESTS IF TXT IS A DATE
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_DATE(TXT)
;
; INPUTS: TXT [A SATDATE]  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;         

; OUTPUTS: LOGICAL 1 OR 0
;		
;; EXAMPLES:
;   PRINT,IS_DATE('201412'); = 1
;   PRINT,IS_DATE('20141201'); = 1
;   PRINT,IS_DATE('2014120123'); = 1
;   PRINT,IS_DATE('201412012359'); = 1
;   PRINT,IS_DATE('20141201235959'); = 1
;   PRINT,IS_DATE('2014120123595999'); = 0
;   PRINT,IS_DATE('20141201235959ABC'); = 0
;   PRINT,IS_DATE('2014ABC1235959'); = 0
;
;        
; MODIFICATION HISTORY:
;			WRITTEN JUL 24,2015 WRITTEN BY J.O'REILLY
;			JUL 29,2015,JOR:ADDITIONAL CRITERION ADDED
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'IS_DATE'
;***************************

IF NONE(TXT) THEN MESSAGE,'ERROR: TXT IS REQUIRED'

;===> A STRING AND  6,8,10,12,OR 14 CHARS WIDE  AND ALL CHARS MUST BE NUMERIC
IF IDLTYPE(TXT) EQ 'STRING' AND $
   STRLEN(TXT) LE 14 AND $
   STRLEN(TXT) MOD 2 EQ 0 AND $
   NUMBER(TXT)   EQ 1 $
   THEN RETURN,1 ELSE RETURN,0

END; #####################  END OF ROUTINE ################################
