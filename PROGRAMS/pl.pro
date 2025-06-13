; $ID:	PL.PRO,	2014-07-20-18	$
;#############################################################################################################
	PRO PL,DATA,DATA2, SKIP=SKIP, NOSEQ=NOSEQ, NOHEAD=NOHEAD, FILE=FILE,NOTES=NOTES, DELIM=DELIM,TAGS=TAGS,TAGNAMES=TAGNAMES,OVERWRITE=OVERWRITE
;+
; NAME:
;		PL
;
; PURPOSE: A SHORT CUT WRAPPER PROGRAM FOR PLIST
;
; CATEGORY:
;		DISPLAY
;		 
;
; CALLING SEQUENCE: PL
;
; INPUTS: SEE PLIST
;		
;	
; KEYWORD PARAMETERS:  SEE PLIST

; OUTPUTS: SEE PLIST
;		
;; EXAMPLES:  SEE PLIST
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 5,2014 J.O'REILLY;	
;			JUL 20,2014,JOR ADDED DATA2		
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'PL'
;***************************

PLIST ,DATA,DATA2, SKIP=SKIP, NOSEQ=NOSEQ, NOHEAD=NOHEAD, FILE=FILE,NOTES=NOTES, DELIM=DELIM,TAGS=TAGS,TAGNAMES=TAGNAMES,OVERWRITE=OVERWRITE

  

END; #####################  END OF ROUTINE ################################
