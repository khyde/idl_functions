; $ID:	PN.PRO,	2015-11-23	$
;###########################################################################################################
	PRO PN,ARRAY,TXT

;+
; NAME:
;		PN
;
; PURPOSE: PRINT THE NUMBER OF ELEMENTS IN AN ARRAY
;
; CATEGORY:
;		CATEGORY
;		 INFO
;
; CALLING SEQUENCE:
; PN, ARRAY
; INPUTS:
;		ARRAY:	ARRAY OF DATA
;		
; OPTIONAL INPUTS:
;		TXT:	THE TEXT TO PRINT INSTEAD OF 'ELEMENTS'
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		THIS PROGRAM PRINTS THE NUMBER OF ITEMS TO PROCESS
;

; EXAMPLES:
;   PN
;   PN,BINDGEN(10)
;   PN,BINDGEN(4444444)
;   PN,'4444444'
;   
;   
; MODIFICATION HISTORY:
;			WRITTEN SEP 25,2011  J.O'REILLY
;			DEC 26,2011, JOR, IG ARRAY EQ '' THEN N = 0
;			FEB 23,2012,JOR, ADDED PARAMETER TXT
;			FEB 26,2012,JOR, FIXED A TYPO
;			FEB 23,2013,JOR, REPLACED 'PROCESSING' WITH '>>>>>'
;			SEP 29,2014,JOR PRINT,'>>>>>  ' +STR_COMMA(STRTRIM(N,2)) + TXT

;###########################################################################################################
;-
;	****************************
	ROUTINE_NAME = 'PN'
; ****************************

IF N_ELEMENTS(TXT)EQ 0 THEN TXT = '  ELEMENTS' ELSE TXT = '  ' +TXT
	N = N_ELEMENTS(ARRAY)
	PRINT
	PRINT,'>>>>>  ' + STR_COMMA(STRTRIM(N,2)) + TXT
  PRINT

	END; #####################  END OF ROUTINE ################################
