; $ID:	NOF.PRO,	2015-01-02	$

	FUNCTION NOF,ARR

;+
; NAME: NOF
;
; PURPOSE: SHORTHAND  FUNCTION FOR N_ELEMENTS
;
; CATEGORY:
;		CATEGORY
;		 INFO
;
; CALLING SEQUENCE:
; NOF, ARR
; INPUTS:
;		ARR:	ARR OF DATA
;		
; OPTIONAL INPUTS:
;		NONE:	
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		RETURNS THE NUMBER OF ELEMENTS IN AN ARRAY 
;

; EXAMPLES:
;  P, NOF(INDGEN(9))
;  P, NOF(NOTHING)
;
;
; MODIFICATION HISTORY:
;			WRITTEN DEC 31,2014 J.O'REILLY
;			
;-
;*******************
ROUTINE_NAME = 'NOF'
;*******************
RETURN,N_ELEMENTS(ARR)
	END; #####################  END OF ROUTINE ################################
