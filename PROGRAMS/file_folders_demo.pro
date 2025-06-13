; $ID:	FILE_FOLDERS_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO FILE_FOLDERS_DEMO
	
;  PRO FILE_FOLDERS_DEMO
;+
; NAME:
;		FILE_FOLDERS_DEMO
;
; PURPOSE: 
;
; CATEGORY:
;		PLOT
;		 
;
; CALLING SEQUENCE: FILE_FOLDERS_DEMO
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
;  FILE_FOLDERS_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN APR 18,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;-
;**********************************
ROUTINE_NAME  = 'FILE_FOLDERS_DEMO'
;**********************************

PAL_LANDMASK,R,G,B
S=FILE_FOLDERS(GET_PATH() + 'PROJECTS\JUNK\')  
ST,S
MAP = 'NEC'
DIR=S.DIR_IMAGES
LAND =READ_LANDMASK(LANDMASK_FILE, MAP=MAP,PX=PX,PY=PY, DIR=DIR,/LAND)
;===> WRITE THE LANDMASK TO S.PLOTS

PNGFILE = S.PLOTS + ROUTINE_NAME + '.PNG'
WRITE_PNG,PNGFILE,LAND,R,G,B & PFILE,PNGFILE,/W
TXT = ' A PNGFILE ['+PNGFILE + '] WAS WRITTEN TO: '  + S.PLOTS
TXTFILE = S.DOCS + ROUTINE_NAME + '.TXT'
WRITE_TXT,TXTFILE,TXT & PFILE,TXTFILE,/W

END; #####################  END OF ROUTINE ################################
