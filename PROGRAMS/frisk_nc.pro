; $ID:	FRISK_NC.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO FRISK_NC,FILES
;
; PURPOSE:  READ NC FILES AND DISPLAY FILE ATTRIBUTES
;
; CATEGORY:	NC
;
; CALLING SEQUENCE: FRISK_NC
;
; INPUTS: FILE ... A NC FILE
;         
;		
; OPTIONAL INPUTS: 
;			
;		
; KEYWORD PARAMETERS: NONE 
;		

; OUTPUTS: PRINTS INFO 
;		
; EXAMPLES: 
; 
;
; MODIFICATION HISTORY:
;			JUN 04,2015,  WRITTEN BY J.O'REILLY

;			
;			
;			
;#################################################################################
;-
;************************
ROUTINE_NAME  = 'FRISK_NC'
;************************
IF NONE(FILES) THEN FILES = FLS(!S.DATASETS + 'OC-OCTS-9/L3/*L3b_DAY_CHL.nc') 
PN,FILES
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,NOF(FILES) -1 DO BEGIN
  FILE = FILES[NTH]
  DATA = READ_NC(FILE,PRODS= ['CHLOR_A','GLOBAL'],/DATA,STRUCT=STRUCT)
  ;DATA = READ_NC(FILE,PRODS= ['CHLOR_A'],/DATA,STRUCT=STRUCT);[THIS ALSO WORKS]
  P,(FILE_PARSE(FILE)).NAME
  P,MM(DATA)
  ST,STRUCT
  ENTER
  
ENDFOR;FOR NTH = 0,NOF(FILES) -1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF



END; #####################  END OF ROUTINE ################################
