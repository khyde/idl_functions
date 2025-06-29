; $ID:	GET_LME_INFO.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION GET_LME_INFO,LME,INIT=INIT,Q=Q

; PURPOSE: THIS FUNCTION  EXTRACT INFO FOR A LME FROM LME_STATS.SAV
; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_LME_INFO(LME)
;
; INPUTS: LME  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  ST,GET_LME_INFO('BALTIC_SEA')
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN SEP 11, 2014 J.O'REILLY
;			OCT 7,2014,JOR ALLOW NUMERIC LME CODE AS INPUT
;			
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_LME_INFO'
;****************************
COMMON GET_LME_INFO_,SAV
IF NONE(SAV) OR KEY(INIT)THEN BEGIN
  SAVFILE = !S.MASTER + 'LME_STATS.SAV'
  SAV = IDL_RESTORE(SAVFILE)
ENDIF;IF NONE(SAV) THEN BEGIN
IF NONE(LME) THEN RETURN,SAV
IF IDLTYPE(LME) EQ 'INT' THEN LME = GET_LME_NAMES(LME)
OK = WHERE_MATCH(SAV.MAP, LME,COUNT)

IF COUNT GE 1 THEN BEGIN
  IF NOT KEY(Q) THEN PSTRUCT,SAV[OK]  
  RETURN,SAV[OK]
ENDIF;IF COUNT GE 1 THEN BEGIN

DONE:          
	END; #####################  END OF ROUTINE ################################
