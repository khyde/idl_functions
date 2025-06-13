; $ID:	MAKE_HELP.PRO,	2014-01-22 10	$
;+
;#############################################################################################################
	PRO MAKE_HELP,FAMILY

;
; PURPOSE: MAKE AN HTL HELP FILE FOR A FAMILY OF PROGRAMS 
;
; CATEGORY:	HELP
;
; CALLING SEQUENCE: MAKE_HELP
;
; INPUTS: FAMILY [PRODS_  OR MAPS_ OR STRUCT_ OR WHERE_  ETC]
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: MAKE_HELP,'WHERE'
;           MAKE_HELP,'MAPS'
;           MAKE_HELP,'PRODS'
;
; MODIFICATION HISTORY:
;			JAN 19,2014 WRITTEN BY J.O'REILLY
;			APR 14,2014,JOR,MINOR REVISIONS
;			
;			
;			
;#################################################################################
;
;
;-
;****************************
ROUTINE_NAME  = 'MAKE_HELP'
;****************************
IF NONE(FAMILY) THEN MESSAGE,'ERROR: FAMILY IS REQUIRED'

FILES = FILE_SEARCH(FAMILY +'_*.PRO') & PLIST,FILES

HTML = FAMILY + '_HELP.HTML'

MK_HTML_HELP,FILES,HTML,TITLE=FAMILY

  

END; #####################  END OF ROUTINE ################################
