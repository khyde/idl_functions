; $ID:	DOPNG.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO DOPNG ,NAME,IMG = IMG,PAL=PAL
	
;  PRO DOPNG
;+
; NAME:
;		DOPNG
;
; PURPOSE: THIS PROGRAM CAPTURES THE IMAGE IN THE ACTIVE WINDOW [Z OR WIN] AND WRITES A PNG FILE
;
; CATEGORY:
;		IMAGES
;		 
;
; CALLING SEQUENCE:DOPNG
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NAME:	 FIRST NAME [ WITHOUT EXTENSION ] FOR PNGFILE
;		
; KEYWORD PARAMETERS:
;          PAL: NAME OF PALLETE PROGRAM TO LOAD [E.G. PAL_36;PAL_SW3]
;          
; OUTPUTS: A PNG FILE ['DOPNG.PNG'] IN THE WORKING DIRECTORY
;		
;; EXAMPLES:
;     DOPNG
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 9,2012  J.O'REILLY
;			APR 9,2014,JOR: PNGFILE = !S.IDL_TEMP + ROUTINE_NAME+'.PNG'
;     APR 12,2014,JOR:IF NONE(IMG) THEN IM = TVRD() ELSE IM = IMG


;#################################################################################
;
;
;-
;	******************
ROUTINE_NAME='DOPNG'
; ******************

; 

; DEFAULT PALETTE
IF N_ELEMENTS(PAL) NE 1 THEN _PAL = 'PAL_36' ELSE _PAL = PAL
CALL_PROCEDURE,_PAL,R,G,B


IF NONE(IMG) THEN IMG = TVRD()
IF NONE(NAME) THEN NAME = ROUTINE_NAME
PNGFILE = !S.IDL_TEMP + NAME +'.PNG'

WRITE_PNG,PNGFILE,IMG,R,G,B
PFILE,PNGFILE,/W

DONE:          
	END; #####################  END OF ROUTINE ################################
