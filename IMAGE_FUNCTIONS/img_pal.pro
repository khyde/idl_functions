; $ID:	IMG_PAL.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO IMG_PAL

;
; PURPOSE: EXTRACT R,G,B FROM AN IMAGE FILE AND WRITE THE PALETTE
;
; CATEGORY:	PAL
;
; CALLING SEQUENCE: IMG_PAL
;
; INPUTS: NONE
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
;			APR 11,2014,WRITTEN BY J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'IMG_PAL'
;********************************
FILTERS = ['*.JPG', '*.TIF', '*.PNG']
FILE = DIALOG_PICKFILE(/READ, FILTER = FILTERS)
;YN_ADD_MAP =STRUPCASE(DIALOG_MESSAGE('ENTER Y OR N',TITLE = 'ADD ' + S.MAP +'  TO MAPS MASTER ',/DEFAULT_NO,/QUESTION))

FN = FILE_PARSE(FILE)
NAME = FN.NAME
NAME = REPLACE(NAME,'-','_')
IMG = READ_IMAGE(FILE)
I = IMAGE(IMG)
T =I.RGB_TABLE
I.CLOSE
R = REFORM(T(0,*))
G = REFORM(T(1,*))
B = REFORM(T(2,*))
PAL_WRITE,NAME,R,G,B

END; #####################  END OF ROUTINE ################################
