; $ID:	IDL_DEMO_CMYK_CONVERT.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO IDL_DEMO_CMYK_CONVERT

;
; PURPOSE: IDL DEMO :CMYK_CONVERT
;
; CATEGORY:	IMG FAMILY
;
; CALLING SEQUENCE: IDL_DEMO_CMYK_CONVERT
;
; INPUTS: NONE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		TAG: THE TAGNAME TO PLOT

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			JUL 2,2014,  WRITTEN BY J.O'REILLY 
;			
;			
;			
;#################################################################################
;-
;*************************************
ROUTINE_NAME  = 'IDL_DEMO_CMYK_CONVERT'
;*************************************
FILE = FILEPATH( 'ROSE.JPG', SUBDIRECTORY=['EXAMPLES','DATA'] )
READ_JPEG, FILE, IMAGE
RED = REFORM( IMAGE[0,*,*] )
GREEN = REFORM( IMAGE[1,*,*] )
BLUE = REFORM( IMAGE[2,*,*] )
P
; CONVERT FROM RGB TO CMYK
CMYK_CONVERT, C, M, Y, K, RED, GREEN, BLUE, /TO_CMYK


; DISPLAY USING CYAN (GREEN + BLUE) COLOR TABLE
IIMAGE, GREEN=C, BLUE=C, VIEW_GRID=[2,3], DIM=[600,800]
; DISPLAY USING MAGENTA (RED + BLUE) COLOR TABLE
IIMAGE, RED=M, BLUE=M, /VIEW_NEXT
; DISPLAY USING YELLOW (RED + GREEN) COLOR TABLE
IIMAGE, RED=Y, GREEN=Y, /VIEW_NEXT
; DISPLAY USING INVERTED GRAYSCALE (LIKE INK)
IIMAGE, 255B-K, /VIEW_NEXT

; CONVERT FROM CMYK BACK TO RGB
CMYK_CONVERT, C, M, Y, K, R, G, B
IIMAGE, IMAGE, /VIEW_NEXT
IIMAGE, RED=R, GREEN=G, BLUE=B, /VIEW_NEXT


STOP



END; #####################  END OF ROUTINE ################################
