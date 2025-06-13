; $ID:	GET_PANEL.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_PANEL,NUM,GRACE = GRACE 

; PURPOSE: THIS FUNCTION RETURNS THE POSITION FOR THE PLOT FUNCTION 
; 
; CATEGORY:	PLT;		 
;
; CALLING SEQUENCE: RESULT = GET_PANEL(10)
;
; INPUTS: NUM [NUMBER OF VERTICAL PANELS] 

; OPTIONAL INPUTS:  NONE
;		
; KEYWORD PARAMETERS: NONE
;         
;        
; OUTPUTS: THE POSITION FOR THE NEXT PANEL ON THE PAGE
;		
;; EXAMPLES:
;         P,GET_PANEL(10) & P,GET_PANEL()& P,GET_PANEL()& P,GET_PANEL()& P,GET_PANEL()& P,GET_PANEL()& P,GET_PANEL()
; 
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN 0CT 18, 2014 J.O'REILLY
;#################################################################################
;-
;*****************************
ROUTINE_NAME  = 'GET_PANEL'
;*****************************
COMMON GET_PANEL_,XX,YY,NUM_,DEC
COL = 1
IF NONE(GRACE) THEN GRACE = 0.1
IF KEY(NUM) OR NONE(XX) OR NONE(YY) THEN BEGIN  
  NUM_ = NUM
  IF NONE(DEC) THEN DEC = 1.0/NUM_
  XX=[0.15,0.85]
  YY=[0.90,1.00]
ENDIF;IF KEY(INIT) OR NONE(XX) OR NONE(YY) THEN BEGIN
YY[0] = YY[0] - DEC - GRACE 
YY[1] = YY[1] - DEC - GRACE 
;===>RECYCLE
IF YY[1] LE 0.0 THEN BEGIN
  XX=[0.15,0.85]
  YY=[0.00,1.00]
ENDIF;IF YY(1) LE 0.0 THEN BEGIN


RETURN,[XX[0],YY[0],XX[1],YY[1]]
          
END; #####################  END OF ROUTINE ################################
