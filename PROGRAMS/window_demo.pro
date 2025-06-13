; $ID:	WINDOW_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO WINDOW_DEMO
	
;  PRO WINDOW_DEMO
;+
; NAME:
;		WINDOW_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR IDL'S WINDOW PROCEDURE
;
; CATEGORY:
;		PROGRAMS
;		 
;
; CALLING SEQUENCE: WINDOW_DEMO
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES:
;
;  WINDOW_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN FEB 27,2013  J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;	********************************
ROUTINE_NAME='WINDOW_DEMO'
; ********************************


;===> DISPLAY A GRAPHICS WINDOW
WINDOW, 0, XSIZE=400, YSIZE=400, TITLE = ROUTINE_NAME+ '-0'
FONT_CALIBRI
XYOUTS,0.5,0.5,/NORMAL,ROUTINE_NAME,CHARSIZE = 7,ALIGN = 0.5,WIDTH=WIDTH
PRINT,WIDTH
;===> NOW AN INVISIBLE PIXMAP WINDOW
WINDOW, 1, XSIZE=400, YSIZE=400, TITLE = ROUTINE_NAME+ '-2',/PIXMAP
FONT_CALIBRI
XYOUTS,0.5,0.5,/NORMAL,ROUTINE_NAME,CHARSIZE = 7,WIDTH=WIDTH
PRINT,WIDTH

;===> NOW SET THE ACTIVE WINDOW TO 1 AND GET THE TXT
WSET,1
IM = TVRD()
;SLIDEW,IM,TITLE = 'TVRD()'
HELP,IM

DONE:          
	END; #####################  END OF ROUTINE ################################
