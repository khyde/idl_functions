; $ID:	PWIN.PRO,	2020-06-26-15,	USER-KJWH	$
;#############################################################################################################
	PRO PWIN,PNG=PNG
	
;  PRO PWIN
;+
; NAME: PWIN
;
; PURPOSE: THIS PROGRAM PRINTS :
;          1) THE NAME OF THE CURRENT GRAPHICS WINDOW
;          2) THE SIZE OF THE WINDOW
;          3) THE COLORS IN THE WINDOW
;          4) AND OPTIONALLY WRITES A PNG OF THE IMAGE IN THE CURRENT GRAPHICS WINDOW
;
; CATEGORY:
;		PRINT
;		 
;
; CALLING SEQUENCE: PWIN
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		PNG.......... WRITE A PNGFILE OF THE IMAGE [TVRD()] FROM THE CURRENT GRAPHICS WINDOW

; OUTPUTS: PRINTS NAME OF CURRENT WINDOW TO THE SCREEN
;		
;; EXAMPLES:
;    PWIN
;    ZWIN,[200,300] &  PWIN & ZWIN
;
; MODIFICATION HISTORY:
;			JAN 1,2013 WRITTEN BY J.O'REILLY
;			APR 4,2014,JOR ADDED SIZE,COLORS AND KEYWORD PNG
;			DEC 03,2015, JOR, ADDED EXAMPLES
;			MAR 03,2017, JEOR DOCUMENTATION
;#################################################################################
;-
;*******************
ROUTINE_NAME='PWIN'
;*******************
PX = !D.X_SIZE
PY = !D.Y_SIZE
H = HISTOGRAM(TVRD())
OK = WHERE(H GT 0,COUNT)
IF COUNT GE 1 THEN COLORS = STRJOIN(ROUNDS[OK]+ ',')
PRINT,'CURRENT WINDOW IS:'   ,'     ' +$
  !D.NAME + '  PX: '+ ROUNDS(PX) + '  ' + 'PY:  '+ ROUNDS(PY)
 PRINT, '  COLORS : ' + COLORS
;********************** 
IF KEY(PNG) THEN BEGIN
;********************** 
  PRINT
  TVLCT,R,G,B,/GET
  PNGFILE = !S.IDL_TEMP + ROUTINE_NAME + '.PNG'
  WRITE_PNG,PNGFILE,TVRD(),R,G,B
  PFILE,PNGFILE,/W  
ENDIF;IF KEY(PNG) THEN BEGIN
;|||||||||||||||||||||||||||
 
  
IF !D.NAME EQ 'WIN' THEN WDELETE 
DONE:          
	END; #####################  END OF ROUTINE ################################
