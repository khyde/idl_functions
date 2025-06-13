; $ID:	TILDA.PRO,	2013-10-09 16	$

	FUNCTION TILDA

;+
; NAME:
;		TILDA
;
; PURPOSE: RETURN THE TILDA CHARACTER ('~')
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE: PRINT,TILDA()
;
; INPUTS:
;		DATA:	VECTOR OF DATA
;		
; OPTIONAL INPUTS:
;		NONE:	
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		
;

; EXAMPLES:
;  PRINT,TILDA()
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			Written FEB 11,2012  J.O'Reilly
;-
;	*********************
ROUTINE_NAME = 'TILDA'
; *********************
RETURN,STRING(BYTE(126))
	END; #####################  End of Routine ################################
