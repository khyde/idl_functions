; $ID:	IDL_COLOR_TABLE.PRO,	2020-07-08-15,	USER-KJWH	$
;#############################################################################################################
	PRO PALS_!COLOR_TABLE
	
;  PRO PALS_!COLOR_TABLE
;+
; NAME:
;		PALS_!COLOR_TABLE
;
; PURPOSE: THIS PROGRAM  MAKES A CSV TABLE OF !COLOR
;
; CATEGORY:
;		PALETTE
;		 
;
; CALLING SEQUENCE: PALS_!COLOR_TABLE
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
;  PALS_!COLOR_TABLE
;
; MODIFICATION HISTORY:
;			WRITTEN MAY 14,2012  J.O'REILLY
;			MAY 29,2014,JOR RENAMED FROM IDL_COLOR_TABLE
;			
;			
;			
;#################################################################################
;
;
;-
;	********************************
ROUTINE_NAME  = 'PALS_!COLOR_TABLE'
; ********************************


CSVFILE = ROUTINE_NAME + '.CSV'
NAMES = TAG_NAMES(!COLOR)
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
NAME = NAMES[NTH]
RGB = !COLOR.(NTH)
R = FIX(RGB[0]) & G = FIX(RGB[1]) & B = FIX(RGB(2))
D = CREATE_STRUCT('NAME',NAME,'R',R,'G',G,'B',B)
IF N_ELEMENTS(DB) EQ 0 THEN DB = D ELSE DB = [DB,D]
ENDFOR;FOR NTH = 0,N_ELEMENTS(NAMES)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

STRUCT_2CSV,CSVFILE,DB
PFILE,CSVFILE,/W


DONE:          
	END; #####################  END OF ROUTINE ################################
