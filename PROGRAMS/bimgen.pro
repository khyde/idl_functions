; $ID:	BIMGEN.PRO,	2016-03-18,	USER-JOR	$
; 
FUNCTION BIMGEN,ARR,VAL
; #########################################################################; 
;+
; THIS FUNCTION RETURNS AN IMAGE OF 255B'S FROM THE INPUT ARR 

;
; CATEGORY: MATH;
;
; CALLING SEQUENCE: 
;
; INPUTS: 
;      ARR..... A 2D ARRAY OR [PX,PY] SIZES
;      VAL..... THE VALUE TO USE IN THE OUTPUT


;
; KEYWORDS:  NONE

; OUTPUTS:
;
; EXAMPLES:
;          PMM,BIMGEN([1024,1024])
;
; MODIFICATION HISTORY:
;     DEC 15, 2015  WRITTEN BY: J.E. O'REILLY
;     MAR 18,2016: JEOR ADDED SIZEXYZ
;-
; #########################################################################

;***********************
ROUTINE_NAME  = 'BIMGEN'
;***********************
IF NONE(VAL) THEN VAL = 255B

IF IS_2D(ARR) EQ 0 THEN BEGIN
  S = SIZEXYZ(ARR,PX=PX,PY=PY)
  RETURN,REPLICATE(VAL,[PX,PY])  
ENDIF;IF IS_2D(ARR) EQ 0 THEN BEGIN

BYT = BYTE(ARR)
BYT(*) = VAL
RETURN,BYT


END; #####################  END OF ROUTINE ################################
