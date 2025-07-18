; $ID:	FILE_SEARCH_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO FILE_SEARCH_DEMO

;
; PURPOSE: DEMONSTRATES THE  ORDER OF FILES USING FILE_SEARCH
;
; CATEGORY:	FILE FAMILY
;
; CALLING SEQUENCE: FILE_SEARCH_DEMO
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
;			MAY 9,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'FILE_SEARCH_DEMO'
;********************************
;###> WRITE 67 FILES 
DIR = !S.IDL_TEMP + 'JUNK\'
DIR_TEST,DIR
MAPS = GET_LME_DB(/MAPS,/SORT) & PL,MAPS
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(MAPS)-1 DO BEGIN
  MAP = MAPS[NTH]
  FILE = DIR + MAP + '.TXT'
  WRITE_TXT,FILE,MAP
ENDFOR;FOR NTH = 0,N_ELEMENTS(MAPS)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

;===> GET THE FILES USING FILE_SEARCH

FILES = FILE_SEARCH(DIR,'*.TXT')
PL,FILES
FN = FILE_PARSE(FILES)
NAMES = FN.NAME
TXT = MAPS + '   ' + NAMES
PL,TXT
OK = WHERE(MAPS NE NAMES,COUNT)
IF COUNT GE 1 THEN MESSAGE,'ERROR: NOT IN ORDER' ELSE PRINT,'SORTED OK'
P
END; #####################  END OF ROUTINE ################################
