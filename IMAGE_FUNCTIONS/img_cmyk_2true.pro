; $ID:	IMG_CMYK_2TRUE.PRO,	2020-06-03-17,	USER-KJWH	$
;+
;;#############################################################################################################
	PRO IMG_CMYK_2TRUE,IMG

; PURPOSE: THIS FUNCTION CONVERTS A 4-COLOR-PLANE CYMK [CYAN,YELLOW,MAGENTA,BLACK] 
;          IMG INTO A 3-COLOR-PLANE [RED,GREEN,BLUE] TRUE COLOR IMG
; 
; 
; CATEGORY:	IMG FAMILY;		 
;
; CALLING SEQUENCE: RESULT = IMG_CMYK_2TRUE(IMG)
;
; INPUTS: IMG A CYMK IMG [FROM MS-PAINT] 

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  TRUE = IMG_CMYK_2TRUE(VAR)
;	NOTES:
;The procedure uses the following method to convert from CMYK to RGB:
;   R = (255 - C) (1 - K/255)
;   G = (255 - M) (1 - K/255)
;   B = (255 - Y) (1 - K/255)
; MODIFICATION HISTORY:
;			WRITTEN JUL 2, 2014 J.O'REILLY
;#################################################################################
;-
;*******************************
ROUTINE_NAME  = 'IMG_CMYK_2TRUE'
;*******************************
FILE = !S.IMAGES + 'MASK_NEC_ESTUARY_SHELF.PNG' & PFILE,FILE,/X
IMG = READ_PNG(FILE)
C = REFORM(IMG[0,*,*]) & WRITE_PNG,!S.IDL_TEMP +'CYAN.PNG',C
M = REFORM(IMG[1,*,*]) & WRITE_PNG,!S.IDL_TEMP +'MAGENTA.PNG',M
Y = REFORM(IMG[2,*,*]) & WRITE_PNG,!S.IDL_TEMP +'YELLOW.PNG',Y
K = REFORM(IMG[3,*,*]) & WRITE_PNG,!S.IDL_TEMP +'BLACK.PNG',K

;C = REFORM(IMG[3,*,*]) & WRITE_PNG,!S.IDL_TEMP +'CYAN.PNG',C
;M = REFORM(IMG[2,*,*]) & WRITE_PNG,!S.IDL_TEMP +'MAGENTA.PNG',M
;Y = REFORM(IMG[1,*,*]) & WRITE_PNG,!S.IDL_TEMP +'YELLOW.PNG',Y
;K = REFORM(IMG[3,*,*]) & WRITE_PNG,!S.IDL_TEMP +'BLACK.PNG',K

;===> IS K ALL WHITE 255 ?
IF MIN(K) EQ 255 AND MAX(K) EQ 255 THEN BEGIN
  
;R = (255 - C)*(1 - K/255) & P,MM(R)
;G = (255 - M)*(1 - K/255) & P,MM(G)
;B = (255 - Y)*(1 - K/255) & P,MM(B)
  R = 255-C & P,MM(R)
  G = (255 - M)& P,MM(G)
  B = (255 - Y) & P,MM(B) 
ENDIF ELSE BEGIN
  CMYK_CONVERT, C, M, Y, K, R, G, B 
ENDELSE;IF SPAN(K) EQ 0 THEN BEGIN

SZ = SIZEXYZ(IMG) & PX = SZ.PX & PY = SZ.PY
TRUE = BYTARR(3,PX,PY)
TRUE(0,*,*)= R
TRUE(1,*,*)= G
TRUE(2,*,*)= B
;SL,IMG
WRITE_PNG, !S.IDL_TEMP + 'TRUE.PNG',TRUE
STOP

DONE: 

        
	END; #####################  END OF ROUTINE ################################
