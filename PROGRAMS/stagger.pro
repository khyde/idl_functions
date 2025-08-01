; $ID:	STAGGER.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	FUNCTION STAGGER,ARRAY ,RIGHT=RIGHT,VERT=VERT,BELOW=BELOW,SPACES = SPACES
	
;  PRO STAGGER
;+
; NAME:
;		STAGGER
;
; PURPOSE: THIS FUNCTION RETURNS A STAGGERED TEXT ARRAY SUITABLE FOR PLOTTING ALONG THE Y-AXIS[WHEN CHARSIZE IS LARGE]
; 
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = STAGGER(ARRAY)
;
; INPUTS:
;		ARRAY:	INPUT STRING ARRAY [ OF SWITCH NAMES]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		RIGHT: ADDS SPACES TO THE RIGHT
;		VERT:  VERTICAL STAGGER [ADDS !C + SPACES TO EVERY OTHER ARRAY ELEMENT 
;   SPACES: NUMBER OF SPACES TO STAGGER ARRAY [DEFAULT = 5]
;   BELOW:  VERTICALLY STACKS THE XTICKNAMES BELOW THE X-AXIS

; OUTPUTS:
;		
;; EXAMPLES:
;  MONTH_LETTER= MONTH_NAMES(/LETTER) & PLIST,STAGGER(MONTH_LETTER) + '  !'
;  THE FOLLOWING 3 LINES SHOW HOW TO STAGGER THE XTICKNAMES ALONG [BELOW] THE XAXIS  
;   XTICKNAME = (GET_LOG_TICKS([0.001,1000],COMMA = 0)).TICKNAME &  XTICKV = FLOAT(XTICKNAME)
;   X = XTICKV & Y = X & XTICKNAME = STAGGER(XTICKNAME,/BELOW)
;   PLT = PLOT(X,Y,XTICKNAME=XTICKNAME,XTICKV=XTICKV,/XLOG,/YLOG,COLOR = 'BLUE',THICK = 3,XMINOR = 0,YMINOR = 0,FONT_SIZE = 9) & PLT_GRIDS,PLT

;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 19,2012 J.O'REILLY
;			OCT 20,JOR,ADDED KEYWORD SPACES
;			JAN 24,2014,JOR ADDED KEYWORD VERT [VERTICAL STAGGER]
;			APR 22,2018,JEOR: ADDED KEYWORD BELOW, AND EXAMPLE
;#################################################################################
;-
;	***************
ROUTINE='STAGGER'
; ***************
IF N_ELEMENTS(ARRAY) NE 0 THEN _ARRAY = ARRAY ELSE MESSAGE,'ARRAY IS REQUIRED'
SUBS=SUBSAMPLE(LINDGEN(N_ELEMENTS(_ARRAY)),2)

IF KEY(BELOW) THEN BEGIN
  _ARRAY(SUBS) = '!C!C!C' +_ARRAY(SUBS)
  RETURN,_ARRAY
ENDIF;IF KEY(BELOW) THEN BEGIN

IF N_ELEMENTS(SPACES) EQ 0 THEN NUM = 5 
_SPACES = STRING(REPLICATE(32B,NUM))
_SPACES = REPLICATE(_SPACES,N_ELEMENTS(SUBS),NUM)
IF KEYWORD_SET(RIGHT) THEN BEGIN
  _ARRAY(SUBS) = _ARRAY(SUBS)+ _SPACES  
ENDIF ELSE BEGIN
  _ARRAY(SUBS) = _SPACES +_ARRAY(SUBS) 
ENDELSE;IF NOT KEYWORD_SET(RIGHT) THEN BEGIN
IF KEYWORD_SET(VERT) THEN _ARRAY(SUBS) = _ARRAY(SUBS) + '!C' +  STRING(REPLICATE(32B,NUM))
RETURN,_ARRAY

RETURN,''
DONE:          
	END; #####################  END OF ROUTINE ################################
