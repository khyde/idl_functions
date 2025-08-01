; $ID:	MAPS_CONTOUR.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION MAPS_CONTOUR,DATA,BYT,$
	 C_LEVELS =C_LEVELS,$
	 C_COLORS = C_COLORS ,$
	 C_ANNOTATION=C_ANNOTATION,$
	  C_CHARSIZE=C_CHARSIZE ,$
	  C_CHARTHICK= C_CHARTHICK ,$
	  C_THICK = C_THICK  

; PURPOSE: THIS FUNCTION CONTOURS A DATA ARRAY
; 
; 
; CATEGORY:	MAPS;		 
;
; CALLING SEQUENCE: RESULT = MAPS_CONTOUR(DATA)
;
; INPUTS: DATA  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:
;     C_LEVELS : DATA CONTOURE LEVELS
;     C_COLORS : CONTOUR COLORS FOR EACH C_LEVELS 
;     C_ANNOTATION: ANNOTATE CONTOUR 
;     C_CHARSIZE : SIZE FOR CONTOUR ANNOTATIONS
;     C_CHARTHICK : THICKNESS OF ANNOTATION LABELS
;     C_THICK    : THICKNESS OF CONTOURS
; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, MAPS_CONTOUR(VAR)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'MAPS_CONTOUR'
;****************************
BIMG = BYTE(DATA) & BIMG(*) = 255B
OK = WHERE(DATA EQ MISSINGS(DATA),COUNT)
ZWIN, DATA
IF COUNT GE 1 THEN DATA[OK] = MISSING_2NAN(DATA[OK])
DATA = MEDIAN(DATA,3)
  DATA_RANGE=MINMAX(DATA,/FIN)

  IF N_ELEMENTS(MIN_VALUE) NE 1 THEN _MIN_VALUE = DATA_RANGE[0] ELSE _MIN_VALUE = MIN_VALUE
  IF N_ELEMENTS(MAX_VALUE) NE 1 THEN _MAX_VALUE = DATA_RANGE[1] ELSE _MAX_VALUE = MAX_VALUE
  CONTOUR,DATA,LEVELS=C_LEVELS,MIN_VALUE=_MIN_VALUE,MAX_VALUE=_MAX_VALUE,C_COLORS=1,C_ANNOTATION=C_ANNOTATION,C_CHARSIZE=C_CHARSIZE,C_CHARTHICK=C_CHARTHICK,C_THICK=C_THICK,$
  XSTYLE=5,YSTYLE=5,XMARGIN=[0,0],YMARGIN=[0,0],POSITION=[0,0,1,1], CLOSED=0,/NOERASE,_EXTRA=_EXTRA
  C=TVRD()
  ZWIN
  OK = WHERE(C EQ 1,COUNT)
  IF COUNT GE 1 THEN BIMG[OK] = 1
  RETURN,BIMG
          
	END; #####################  END OF ROUTINE ################################
