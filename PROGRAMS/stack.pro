; $ID:	STACK.PRO,	2017-08-20-11,	USER-JEOR	$
;#############################################################################################################
	FUNCTION STACK,ARRAY,SPACES=SPACES
	
;  PRO STACK
;+
; NAME:
;		STACK
;
; PURPOSE: THIS FUNCTION RETURNS A STACKED TEXT ARRAY WITH !C SUITABLE 
;          FOR PLOTTING AS A VERTICAL TEXT STRING
; 
;
; CATEGORY:  STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = STACK(ARRAY)
;
; INPUTS:
;		ARRAY:	INPUT STRING ARRAY 
;		
; KEYWORDS:
;		       SPACES.......... NUMBER OF SPACES BETWEEN VERTICAL ELEMENTS IN THE ARRAY [0,1,2,3,4]
;		 


; OUTPUTS:
;		
; EXAMPLES:
;          PRINT,STACK(['SEAWIFS','CHLOR_A','OCI'])
;		       P = PLOT(INDGEN(9),INDGEN(9)) & T = TEXT(0.25,0.55,STACK(['SEAWIFS','CHLOR_A','OCI']),/OVERPLOT)
;          P = PLOT(INDGEN(9),INDGEN(9),/NODATA) & T = TEXT(0.25,0.45,STACK(['SEAWIFS','CHLOR_A','OCI'],SPACES = 2),/OVERPLOT)
;          P = PLOT(INDGEN(9),INDGEN(9),/NODATA) & T = TEXT(0.25,0.45,STACK(['SEAWIFS','CHLOR_A','OCI'],SPACES = 0),/OVERPLOT)
;
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 20,2017 J.O'REILLY
;     AUG 23,2017, JEOR: ADDED EXAMPLR SPACES = 0

;#################################################################################
;-
;	**************
ROUTINE='STACK'
; **************
; ===> CONSTANTS:
DELIM = '!C' 
IF ANY(SPACES) THEN BEGIN
CASE (SPACES) OF
  0: DELIM = ''
  1: DELIM = '!C'
  2: DELIM = '!C!C'
  3: DELIM = '!C!C!C'

  ELSE: BEGIN
    DELIM = '!C'
  END
ENDCASE
ENDIF ELSE BEGIN
   DELIM = '!C'
ENDELSE;IF ANY(SPACES) THEN BEGIN



IF N_ELEMENTS(ARRAY) NE 0 THEN _ARRAY = ARRAY ELSE MESSAGE,'ARRAY IS REQUIRED'

N = LINDGEN(N_ELEMENTS(_ARRAY))

RETURN,STRTRIM(_ARRAY,2) + DELIM

DONE:          
	END; #####################  END OF ROUTINE ################################
