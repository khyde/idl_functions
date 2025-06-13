; $ID:	PLT_DATE_DEMO.PRO,	2014-05-20	$
;+
;#############################################################################################################
	PRO PLT_DATE_DEMO,DATES

;
; PURPOSE: PLOT A TIME-SERIES FOR AN ARRAY OF DATES
;
; CATEGORY:	PLT FAMILY
;
; CALLING SEQUENCE: PLT_DATE_DEMO,DATES
;
; INPUTS: STRUCTURE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			MAY 10,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'PLT_DATE_DEMO'
;********************************
;DIR = GET_SMI()
;DIR_IN = DIR.LME_CSV_CONCAT
;FILE = FILE_SEARCH(DIR_IN,'TAG_Y-PPD-OPAL.CSV')
;DB = CSV_READ(FILE) & ST,DB
;SETS = WHERE_SETS(DB.LME)
;IF N_ELEMENTS(SETS)NE 67 THEN MESSAGE,'ERROR:INCORRECT NUM OF LMES'
DATES = DATE_GEN(['1997','2000'])
SETS = PERIOD_SETS(DATE_2JD(DATES),PERIOD_CODE = 'Y')
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR _SET = 0,N_ELEMENTS(SETS) -1 DO BEGIN
  SET =SETS(_SET)
  SUBS = WHERE_SETS_SUBS(SET)
  DATE = DATES(SUBS)
  VAL = REPLICATE(0.5,N_ELEMENTS(DATE))
  PLT_DATE,DATE,VAL
  
ENDFOR;FOR _SET = 0,N_ELEMENTS(SETS) -1 DO BEGIN

DATES = DATE_GEN(['1998','2014'])
W = WINDOW()
PLT_DATE,DATES

STOP
END; #####################  END OF ROUTINE ################################
