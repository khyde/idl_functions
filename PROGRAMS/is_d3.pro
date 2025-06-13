; $ID:	IS_D3.PRO,	2020-06-03-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION IS_D3,DAT

; PURPOSE: THIS FUNCTION TESTS IF D3 IS A 3-D FILE OR A D3 [3-D] ARRAY
; 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = IS_D3(D3_FILE) OR RESULT = IS_D3(D3)
;
; INPUTS: DAT [A D3 ARRAY OR A D3_FILE]  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;         

; OUTPUTS: LOGICAL 1 OR 0
;		
;; EXAMPLES:
;         D3_FILE = !S.IDL_TEMP + 'D3.SAV' & P,IS_D3(D3_FILE)
;         D3_FILE = !S.IDL_TEMP + 'D3.SAV' & D3 = IDL_RESTORE(D3_FILE) & D3=D3.DATA & P,IS_D3(D3)
;         P,IS_D3(FINDGEN(9))
;         P,IS_D3(FINDGEN(9,9))
;         P,IS_D3(FINDGEN(9,9,9))
; MODIFICATION HISTORY:
;			WRITTEN FEB 8,2015 J.O'REILLY
;			FEB 10,2015,JOR ADDED CAPABILITY TO DISCERN A D3_FILE OR D3 DATA ARRAY
;#################################################################################
;-
;***********************
ROUTINE_NAME  = 'IS_D3'
;***********************

IF NONE(DAT) THEN MESSAGE,'ERROR: A D3_FILE OR A D3 ARRAY IS REQUIRED'
;===> IS D3 A FILE OR A DATA ARRAY 
;
;************************************
IF IDLTYPE(DAT) EQ 'STRING' THEN BEGIN
;************************************
  D3 = IDL_RESTORE(DAT)
  SZ = SIZEXYZ(D3.DATA)
ENDIF;IF IDLTYPE(D3) EQ 'STRING' THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||

;************************************
IF IDLTYPE(DAT) EQ 'STRUCT' THEN BEGIN
  ;************************************
  SZ = SIZEXYZ(DAT.DAT)
ENDIF;IF IDLTYPE(D3) EQ 'STRING' THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||
;
;***************************************
IF IS_NUM(FIRST(DAT)) THEN SZ = SIZEXYZ(DAT)
;|||||||||||||||||||||||||||||||||||||||


IF SZ.PX GE 1 AND SZ.PY GE 1 AND SZ.PZ GE 1 THEN RETURN,1 ELSE RETURN,0

END; #####################  END OF ROUTINE ################################
