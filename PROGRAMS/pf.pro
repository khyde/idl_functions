; $ID:	PF.PRO,	2015-12-03,	USER-JOR	$
;#############################################################################################################
	PRO PF,FILES,W=W,R=R,E=E,G=G,D=D,O=O,S=S,X=X,C=C,I=I,U=U,M=M,A=A,K=K,B=B,Z=Z
	
;+
; NAME: 	PF
;
; PURPOSE: A SHORT CUT,WRAPPER PROGRAM FOR PFILE
;
; CATEGORY:  DISPLAY
;		 
;
; CALLING SEQUENCE: PF
;
; INPUTS: SEE PFILE ;		
;		
; OPTIONAL INPUTS: SEE PFILE
;		
; KEYWORD PARAMETERS: SEE PFILE

; OUTPUTS:  SEE PFILE
;		
;; EXAMPLES: SEE PFILE
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 5,2014 J.O'REILLY
;			
;#################################################################################
;-
;*******************
ROUTINE_NAME  = 'PF'
;*******************

PFILE,FILES,W=W,R=R,E=E,G=G,D=D,O=O,S=S,X=X,C=C,I=I,U=U,M=M,A=A,K=K,B=B,Z=Z,TXT=TXT,_OUTTXT=_OUTTXT,_POFTXT=_POFTXT,QUIET=QUIET,VERBOSE=VERBOSE

END; #####################  END OF ROUTINE ################################
