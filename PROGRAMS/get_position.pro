; $ID:	GET_POSITION.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_POSITION,COL=COL,ROW=ROW,DEC=DEC,INIT=INIT

; PURPOSE: THIS FUNCTION RETURNS THE POSITION FOR THE PLOR FUNCTION
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_POSITION(CR)
;
; INPUTS: CR  [COLUMN,ROW]  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;         COL: NUMBER OF COLUMNS
;         ROW: NUMBER OF ROWS
;         INC: INCREMENT TO SUBTRACT FROM THE Y POSITION
;         INIT: INITIALIZE

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, GET_POSITION(366)
;  PRINT, GET_POSITION[1]
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN 0CT 18, 2014 J.O'REILLY
;#################################################################################
;-
;*****************************
ROUTINE_NAME  = 'GET_POSITION'
;*****************************
COMMON GET_POSITION_,XX,YY
IF NONE(COL) THEN COL = 1
IF NONE(ROW) THEN ROW = 10
IF NONE(DEC) THEN DEC = 0.1
IF KEY(INIT) OR NONE(XX) OR NONE(YY) THEN BEGIN  
XX=[0.15,0.85]
YY=[0.00,1.00]
ENDIF ELSE BEGIN
  YY = YY - DEC
  
  
ENDELSE;IF KEY(INIT) OR NONE(XX) OR NONE(YY) THEN BEGIN

RETURN,[XX[0],YY[0],XX[1],YY[1]]
          
END; #####################  END OF ROUTINE ################################
