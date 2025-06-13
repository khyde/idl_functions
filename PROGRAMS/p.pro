; $ID:	P.PRO,	2017-03-11-14,	USER-JEOR	$
; ; $ID:  P.PRO,  2015-12-03, USER-JOR  $
;#############################################################################################################
  PRO P,V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,_EXTRA=_EXTRA
  ;+
; NAME:
;   P
;
; PURPOSE: THIS PROGRAM IS A SHORT CUT FOR PRINT 
;
; CATEGORY: PRINT
;
; CALLING SEQUENCE:  P,(V1,V2,V3,V4,V5,V6,V7,V8,V9,V10)
;
; INPUTS:
;   V1 THROUGH V10  INPUTS TO PASS TO PRINT
;   
; OPTIONAL INPUTS:  NONE: 
;   
; KEYWORD PARAMETERS: NONE:
; 

; OUTPUTS: PRINTS TO DISPLAY
;   
;; EXAMPLES:
;           P,'HELLO'
;           P,123456789.12345
;           P,123456789.12345,FORMAT = '(F20.5)'
;           P,FINDGEN(10)
;           P,1,2,3
; MODIFICATION HISTORY:
;     WRITTEN MAR 31,2012  J.O'REILLY
;     MAY 21,2012,JOR,REMOVED FOR LOOP
;     JUN 27,2012,JOR:IF NONE(V1) THEN V1 = ''
;     JUN 26,2013,JOR   ADDED V1,V2,V3,V4,V5
;     JAN 5,2014,JOR    ADDED V6,V7,V8,V9,V10
;     DEC 17,2014,JOR ADDED NONE
;     JUL 1,2015,JOR ADDED KEY _EXTRA
;     MAR 02,2017,JOR ADDED CASE (N_PARAMS()) OF
;     MAR 11,2017,JEOR ADDED 0: PRINT
;                      IF IDLTYPE(V1) EQ 'UNDEFINED' THEN RETURN


 
;#################################################################################
;-
;******************
ROUTINE_NAME  = 'P'
;******************
IF IDLTYPE(V1) EQ 'UNDEFINED' THEN RETURN
CASE (N_PARAMS()) OF
  0: PRINT
  1: PRINT, V1,_EXTRA=_EXTRA
  2: PRINT, V1,V2,_EXTRA=_EXTRA
  3: PRINT, V1,V2,V3,_EXTRA=_EXTRA
  4: PRINT, V1,V2,V3,V4,_EXTRA=_EXTRA  
  5: PRINT, V1,V2,V3,V4,V5,_EXTRA=_EXTRA 
  6: PRINT, V1,V2,V3,V4,V5,V6,_EXTRA=_EXTRA  
  7: PRINT, V1,V2,V3,V4,V5,V6,V7,_EXTRA=_EXTRA 
  8: PRINT, V1,V2,V3,V4,V5,V6,V7,V8,_EXTRA=_EXTRA 
  9: PRINT, V1,V2,V3,V4,V5,V6,V7,V8,V9,_EXTRA=_EXTRA  
  10: PRINT, V1,V2,V3,V4,V5,V6,V7,V8,V9,V10,_EXTRA=_EXTRA  
  ELSE: BEGIN
    MESSAGE,'ERROR: TOO MANY PARAMETERS'

  END
ENDCASE

DONE:          

	END; #####################  END OF ROUTINE ################################
