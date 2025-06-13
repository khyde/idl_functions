; $ID:	WHERE_NOT.PRO,	2020-06-26-15,	USER-KJWH	$
;#######################################################################3
FUNCTION WHERE_NOT , ARRAY, CMD
;+
; NAME:
;       WHERE_NOT
;
; PURPOSE:
;       SIMILAR TO WHERE COMMAND EXCEPT THAT WHERE_NOT RETURNS THE
;       VALUES OF THE ARRAY WHICH DO NOT MATCH THE CMD SUPPLIED BY THE USER
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;      A=WHERE_NOT([-1,1,2,3,4,5,6],'EQ 4') & PRINT, A
;
; INPUTS:
;      AN ARRAY
;
; KEYWORD PARAMETERS:
;      NONE
; OUTPUTS:
;
; SIDE EFFECTS:
;       NONE.
;
; RESTRICTIONS:
;       NONE.
;
; PROCEDURE:
;       STRAIGHTFORWARD.
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, JULY 17,2000
;  NOV 13,2014,JOR REPLACED RETURN, -1 WITH RETURN,[], FORMATTING
;##############################################################################
;-
;**************************
ROUTINE_NAME = 'WHERE_NOT'
;**************************
  IF N_ELEMENTS(ARRAY) LT 1 THEN RETURN, []

  L=LINDGEN(N_ELEMENTS(ARRAY))
  L(*) = 1L

  TXT = 'OK = WHERE(ARRAY ' + CMD + ', COUNT)'
  A=EXECUTE(TXT)
  IF COUNT GE 1 THEN    L[OK] = 0L

  OK = WHERE(L EQ 1,COUNT)
  IF COUNT GE 1 THEN BEGIN
    RETURN, ARRAY[OK]
  ENDIF ELSE BEGIN
    RETURN, []
  ENDELSE;IF COUNT GE 1 THEN BEGIN


END; #####################  END OF ROUTINE ################################
