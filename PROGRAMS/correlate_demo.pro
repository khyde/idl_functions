; $ID:	CORRELATE_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO CORRELATE_DEMO, ERROR = error
;
;;
;
;+
; NAME:
;		CORRELATE_DEMO
;
; PURPOSE:
;		THIS IS A DEMO FOR CORRELATION - TO SHOW HOW SUBSETS OF A LARGE BIVARIATE POPULATION HAVE A LOWER R-SQUARE THAN THE WHOLE DOES.
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:
;
; INPUTS:
;		NONE
;

;
; OUTPUTS:
;		This PROGRAM GENARATES A PING IMAGE IN THE DEFAULT IDL DIRECTORY
;
; OPTIONAL OUTPUTS:
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
; Written AUGUST 17, 2010 J O'REILLY, 28 Tarzwell Drive, NMFS, NOAA 02882 (jay.oreilly@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CORRELATE_DEMO'
	NUM=500
	_NUM= NUM -1
	SETS=5
	CHUNK=NUM/SETS
SUB_START= 0
SUB_END= SUB_START + CHUNK -1
   
   
   x = FINDGEN(NUM)
   x =    x  +  35* RANDOMU(s,n_elements(X))
   y =    x  +  77* RANDOMN(s,n_elements(X))
   MAX_X=MAX(X)
   MAX_Y=MAX(Y)
   
;   SLIDEW,[1000,800]
    ZWIN,[1000,800]
   
   SETCOLOR,255
    PAL_36
SET_PMULTI, SETS
S=STATS2(X,Y,MODEL='RMA',PARAMS=[2,8],DECIMALS=3)
   XX=X
   YY=S.INT +   X*S.SLOPE
TITLE= ROUNDS[0]+':'+ROUNDS(NUM)
   PLOT, X,Y,PSYM=2,COLOR=TC[0]  ,$
;         XRANGE=[0,MAX_X],YRANGE=[0,MAX_Y],$
          XRANGE=[0,NUM],YRANGE=[0,NUM],$
         
         TITLE=TITLE,CHARSIZE=1.5
   TEXT=S.STATSTRING
;   XPOS=0.05*MAX_X
;   YPOS=0.98*MAX_Y
    XPOS=0.05*NUM
   YPOS=0.98*NUM
;   STOP
    XYOUTS,XPOS,YPOS,text,/DATA,CHARSIZE=1.5,ALIGNMENT=0.0
   
   OPLOT,XX,YY, COLOR=TC(21),THICK=2
   ONE2ONE, LINESTYLE=0,COLOR=TC(11),THICK=2
;   GOTO,SKIP
;  ======SUBSET==>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
   FOR N = 1, SETS  DO BEGIN
IF N EQ 1 THEN BEGIN
  SUB_START = 0
  SUB_END= SUB_START + CHUNK -1
  
ENDIF ELSE BEGIN
  SUB_START= SUB_START+ CHUNK
  SUB_END= SUB_START + CHUNK -1
  SUB_START= 0> SUB_START < _NUM
    SUB_END= 0> SUB_END < _NUM
  ENDELSE
  SX = X(SUB_START:SUB_END)
    SY = Y(SUB_START:SUB_END)
  MAX_X=MAX(SX)
  MAX_Y=MAX(SY)
  S=STATS2(SX,SY,MODEL='RMA',PARAMS=[2,8],DECIMALS=3)
  TEXT=S.STATSTRING
  
   XX=SX
   YY=S.INT +   XX*S.SLOPE
;   STOP
;
  TITLE= ROUNDS(SUB_START)+':'+ROUNDS(SUB_END)
  
   PLOT, XX,YY,PSYM=2,COLOR=TC[0]  ,$
         XRANGE=[0,NUM],YRANGE=[0,NUM],$
         TITLE=TITLE,CHARSIZE=2
;   oplot, x,yfit,COLOR = TC(21),THICK = 2
;   XPOS=0.05*MAX_X
;   YPOS=0.98*MAX_Y
    XYOUTS,XPOS,YPOS,TEXT,/DATA,CHARSIZE=1.5,ALIGNMENT=0.0
   
   OPLOT,XX,YY, COLOR=TC(21),THICK=1
   ONE2ONE, COLOR=11,LINESTYLE=0,thick=2
;IF N EQ SETS -1 THEN STOP
ENDFOR ;   FOR N = 1 SETS -1 DO BEGIN
;  ======SUBSET==>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
SKIP:
IMAGE=TVRD()
HELP,IMAGE
;STOP
PNGFILE= ROUTINE_NAME + '.PNG'
TVLCT,/GET,R,G,B
;PAL_36,R,G,B


WRITE_PNG, PNGFILE,IMAGE,R,G,B
	END; #####################  End of Routine ################################
