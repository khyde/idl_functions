; $ID:	PDATE.PRO,	2015-12-03,	USER-JOR	$
;#################################################################################
	PRO PDATE,_EXTRA=_EXTRA
;######################################################################################
;+
; NAME:
;		PDATE
;
; PURPOSE: PRINT THE CURRENT DATE 
;
; CATEGORY:
;		PRINT
;
; INPUTS: NONE REQUIRED [ ANY EXTRA INPUTS ARE PASSED TO DATE_FORMAT]

;
; OUTPUTS:
;		 PRINTS THE CURRENT DATE 
;

; EXAMPLES:
;   PDATE
;   PDATE,/MDY
;   PDATE,/DMY
;
; MODIFICATION HISTORY:
;			Written DEC 14,2012 J.O'Reilly
;			DEC 26,2012,JOR, ADDED KEYWORD COMMA TO DATE?_FORMAT
;			DEC 03,2015,JOR SIMPLIFIED
;#################################################################################
;-
;	**********************
ROUTINE_NAME = 'PDATE'
; **********************
	PRINT,DATE_FORMAT(DATE_NOW(),/YMD,/COMMA,_EXTRA=_EXTRA)
	END; #####################  END OF ROUTINE ################################
