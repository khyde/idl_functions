; $ID:	AREAS_LABEL.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION AREAS_LABEL,IM
;
;
;
; PURPOSE: THIS FUNCTION USES AREAS_GET TO LABEL BLOBS IN A REGION WITH THIIR NUMBER
; 
; CATEGORY:	AREAS		 
;
; CALLING SEQUENCE: RESULT = AREAS_LABEL(IM)
;
; INPUTS: IM 2-DIMENSIONAL IMAGE ARRAY 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 
;		
;; EXAMPLES:
;  ST, AREAS_LABEL()
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 22,2014, J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'AREAS_LABEL'
;****************************
;===> CONSTANTS
CHARSIZE = 15
COLOR = 0
; FOR TESTING > 
 IF N_ELEMENTS(IM) EQ 0 THEN  IM =READ_LANDMASK(MAP='SMI',/LAND)
  DB = AREAS_GET(IM)
  ZWIN,IM
  TV,IM
  IM(*) = 255
  TV,IM
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0, N_ELEMENTS(DB)-1 DO BEGIN
  D = DB[NTH]
  P
  XYOUTS2,XP,YP,D.AREA,CHARSIZE = CHARSIZE,COLOR = COLOR,ALIGN = [0.5,0.5],/DEVICE
ENDFOR;FOR NTH, N_ELEMENTS(DB)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
IM = TVRD()
ZWIN
SRETURN,IM
DONE:          
	END; #####################  END OF ROUTINE ################################
