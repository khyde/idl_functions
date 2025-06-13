; $ID:	PLT_LME_INFO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PLT_LME_INFO,NAME

;
; PURPOSE:  PLOTS CHL & PP DATA IN GET_LME_INFO FOE EACH LME
;
; CATEGORY:	PLT
;
; CALLING SEQUENCE: PLT_LME_INFO
;
; INPUTS: NONE
;         
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:  NONE
;		

; OUTPUTS: PNG FILE FOR EACH LME
;		
; EXAMPLES: 
; 
;
; MODIFICATION HISTORY:
;			OCT 6,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'PLT_LME_INFO'
;********************************
DB = GET_LME_INFO() & PN,DB
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(DB)-1 DO BEGIN
  D = DB[NTH]
  ST,D
  LME = D.LME
  NICKNAME = D.NICKNAME
  Y_CHL = D.Y_CHL
  DATES = 
  VAL = Y_CHL
  P
  PLT_DATE,DATES,VAL,TITLE=TITLE  
ENDFOR;FOR NTH = 0,N_ELEMENTS(DB)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

END; #####################  END OF ROUTINE ################################
