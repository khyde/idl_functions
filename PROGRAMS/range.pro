; $ID:	RANGE.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	FUNCTION RANGE,VALUES
	
;  PRO RANGE
;+
; NAME:
;		RANGE
;
; PURPOSE: THIS FUNCTION RETURNS THE RANGE [MIN,MAX] OF THE INPUT VALUES
;
; CATEGORY:
;		STATISTICS
;		 
;
; CALLING SEQUENCE:RESULT =RANGE(VALUES)
;
; INPUTS:
;		VALUES:	INPUT DATA/VALUES
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, RANGE([1,2,3])
;  PRINT,RANGE(INDGEN(101))
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2012  J.O'REILLY
;			SEP 23,2014,JOR ADDED KEY NAN
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='RANGE'
; *******************************************
; 
_MIN=MIN(VALUES,MAX=_MAX,/NAN)
RETURN,[_MIN,_MAX]

RETURN,''
DONE:          
	END; #####################  END OF ROUTINE ################################
