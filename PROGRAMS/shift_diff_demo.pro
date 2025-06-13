; $ID:	SHIFT_DIFF_DEMO.PRO,	2020-06-03-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO SHIFT_DIFF_DEMO,IMG

;
; PURPOSE: DEMO FOR SHIFT_DIFF
;
; CATEGORY:	STRUCT
;
; CALLING SEQUENCE: SHIFT_DIFF_DEMO,STRUCT
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
;			WRITTEN JAN 28,2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'SHIFT_DIFF_DEMO'
;********************************
PAL_LANDMASK,R,G,B
F="C:\IDL\LANDMASKS\MASK_LAND-NEC-PXY_1024_1024.PNG"
IM = READ_PNG(F,R,G,B)
IM = SHIFT_DIFF (IM , /ADD_BACK, /CENTER, DIRECTION= 7)
PNGFILE = !S.IDL_TEMP + ROUTINE_NAME + '.PNG'
WRITE_PNG,PNGFILE,IM,R,G,B
PF,PNGFILE
IMAGE_LOOK,IM,PNG = ROUTINE_NAME + '-'
RETURN

END; #####################  END OF ROUTINE ################################
