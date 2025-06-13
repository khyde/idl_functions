; $ID:	IMG_CMYB_2TRUE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;;#############################################################################################################
	PRO IMG_CMYB_2TRUE,FILE

; PURPOSE: THIS FUNCTION CONVERTS A CMYK FOUR PLANE IMAGE TO A TRUE COLOR 3-PLANE IMAGE 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = IMG_CMYB_2TRUE(VARIABLE)
;
; INPUTS: VARIABLE  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, IMG_CMYB_2TRUE(VARIABLE)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			APR 30,2014,  WRITTEN BY J.O'REILLY
;#################################################################################
;-
;*****************************
ROUTINE_NAME ='IMG_CMYB_2TRUE'
;*****************************
;
FILE = 'JUNK.PNG'
IF NONE(FILE)  THEN BEGIN
  FILE = DIALOG_PICKFILE(FILTER = FILTERS,/MUST_EXIST,/READ)
  PFILE,FILE,/R
ENDIF ELSE BEGIN
  IM = READ_IMAGE(FILE)
ENDELSE;IF NONE(FILE) THEN BEGIN

;===> CHECK IF CMYK 
SZ = SIZEXYZ(IM)
PX = SZ.PX
PY = SZ.PY
IF SZ.DIMENSIONS[0] NE 4 THEN MESSAGE,'ERROR: ' + FILE + '  IS NOT CMYK'

;===> CONVERT FROM CMYK BACK TO RGB[FROM IDL HELP]
C= REFORM(IM(0,*,*))
M= REFORM(IM(1,*,*))
Y= REFORM(IM(2,*,*))
K= REFORM(IM(3,*,*))
R = (255 - C)* (1 - K/255)
G = (255 - M)* (1 - K/255)
B = (255 - Y)* (1 - K/255)
TRUE = BYTARR([3,PX,PY]) 
CMYK_CONVERT, C, M, Y, K,    R,G,B 
TRUE(0,*,*) = R
TRUE(1,*,*) = G
TRUE(2,*,*) = B
I = IMAGE(TRUE)
WRITE_IMAGE,'JJJ.PNG', 'PNG',I
STOP
DONE:          
	END; #####################  END OF ROUTINE ################################
