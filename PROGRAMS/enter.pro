; $ID:	ENTER.PRO,	2016-06-30,	USER-JOR	$
;################################################################
	PRO ENTER,TXT
;+
;
;
; NAME:
;		ENTER
;
; PURPOSE:;
;		THIS PROGRAM PAUSES TO ASK THE USER TO PRESS ENTER [BEFORE CONTINUING]

; CATEGORY:
;		CONTROL
;
; CALLING SEQUENCE:	ENTER;	
;
; INPUTS: PRESS THE ENTER KEY
;
; KEYWORD PARAMETERS:	NONE
;	
;
; OUTPUTS: STOPS, THEN CONTINUES AFTER PRESSING ENTER
;		
;

;
; MODIFICATION HISTORY:
;			WRITTEN FEB 20,2014 BY J.O'REILLY
;			JUL 4,2014,JOR IF TXT NE '' THEN A = 0/0
;     JUN 30,2016 JEOR: ADDED PARAMETER TXT

;####################################################################			
;-
;	********************
ROUTINE_NAME = 'ENTER'
;*********************
ON_ERROR, 2
IF NONE(TXT) THEN TXT = '' 
T = ''
READ,T,PROMPT = TXT + '         PRESS ENTER TO CONTINUE >>>>>     '
IF TXT NE '' THEN A = 0/0

END; #####################  END OF ROUTINE ################################
