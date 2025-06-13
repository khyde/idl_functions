; $ID:	IMG_HIST.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;#############################################################################################################
	PRO IMG_HIST,IMG

;
; PURPOSE: HISTOGRAM OF ALL COLORS IN AN IMAGE
;
; CATEGORY:	IMG FAMILY
;
; CALLING SEQUENCE: IMG_HIST,IMG
;
; INPUTS: STRUCTURE [SPREAD SHEET TYPE DATABASE]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			JUN 4,2014,  WRITTEN BY J.O'REILLY 
;			JUL 8,2014,JOR REMOVED PRINT CMDS
;			
;			
;			
;#################################################################################
;-
;********************************
ROUTINE_NAME  = 'IMG_HIST'
;********************************
;===> DEFAULTS
IF NONE(IMG) THEN IMG = DIALOG_PICKFILE(FILTER = ['.PNG',',JPG'])

H = HISTOGRAM(IMG)
OK = WHERE(H NE 0,COUNT)
IF COUNT GE 1 THEN BEGIN
  T = ['COLOR  ,COUNT']
  TXT = STRTRIM((OK),2) + '   ' + STRTRIM(H[OK],2)
  TXT = [T,TXT]
  PLIST,TXT,/NOSEQ
ENDIF;IF COUNT GE 1 THEN BEGIN

END; #####################  END OF ROUTINE ################################
