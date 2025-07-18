; $ID:	MAPS_IMAGE.PRO,	2020-06-03-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO MAPS_IMAGE, MAPP, TITLE=TITLE, STRUCT=STRUCT, PAL=PAL, DIR_OUT=DIR_OUT, PNG=PNG, DELAY=DELAY, EDIT=EDIT, VERBOSE=VERBOSE,$
                  C_LOW=C_LOW, C_HI=C_HI, IM=IM, PX=PX, PY=PY

;
; PURPOSE: MAKE AN IMAGE USING IDLS NEW IMAGE FUNCTION 
;
; CATEGORY:	MAPS
;
; CALLING SEQUENCE: MAPS_IMAGE,MAPP
;
; INPUTS: MAPP [NAME]
;		
; KEYWORD PARAMETERS:
;		STRUCT.... A MAPS STRUCTURE INPUT TO THIS ROUTINE
;		PAL....... THE PALETTE TO USE [DEFAULT = PAL_SW3
;		DIR_OUT... OUTPUT DIRECTORY FOR PNGFILE OF THE MAP [DEFAULT = !S.IDL_TEMP]
;   PNG....... WRITE A PNGFILE OF THE MAP 
;   CLOSE..... CLOSE THE WINDOW 
;   DELAY..... DELAY SECONDS TO DELAY CLOSING THE WINDOW
;   EDIT...... STOPS TO ALLOWS EDITING OF THE IMAGE IN THE IMAGE FUNCTION WINDOW
;   C_LOW..... LOWEST COLOR [DEFAULT = 1]
;   C_HI...... HIGHEST COLOR [DEFAULT = 250]
;   IM........ THE MAP IMAGE MADE BY THIS ROUTINE [OUTPUT]
;   PX........ THE PIXEL WIDTH OF THE OUTPUT IMAGE
;   PY........ THE PIXEL HEIGHT OF THE OUTPUT IMAGE

; OUTPUTS: 
;		
; EXAMPLES: 
;           MAPS_IMAGE,'NEC'
;           MAPS_IMAGE,'NEC',/PNG
;           MAPS_IMAGE,'NEC',PX = 2048,PY = 2048
;           MAPS_IMAGE,'NEC',IM=IM & SLIDEW,IM
;           MAPS_IMAGE,'NEC',/EDIT 
;           MAPS_IMAGE,'SMI'
;           MAPS_IMAGE,'BALTIC_SEA_J'
;           MAPS_IMAGE,'LME_BALTIC_SEA'
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 21,2014 J.O'REILLY
;			JAN 23, 2014 - KJWH: Fixed calls to IMAGE and TEXT functions
;			JAN 23, 2014 - JEOR: Removed superfluous call to MAPS_SET
;			                      IF IDLTYPE(S) EQ 'STRING' THEN BEGIN
;			FEB 24, 2014 - JEOR: Added keyword DIR_OUT
;			                     Removed keyword INIT [now INIT is always passed to MAPS_READ]
;			                     Removed keywords  CLOSE,_EXTRA
;			                     RGB_TABLE = RGBS([C_LOW,C_HI],PAL=PAL)
;     NOV 26, 2014 - KJWH: Cleaned up program and removed redundant code
;     DEC 05, 2014 - JEOR: Added new functions NONE, KEY, RGBS, ETC. for streamlining
;     JUL 08, 2015 - JEOR: Added MAPS_SET,MAP,BACKGROUND=BACKGROUND_COLOR,PX=PX,PY=PY
;     JAN 02, 2016 - JEOR: Added keywords PX and PY
;     AUG 11, 2016 - JEOR: Changed MAP to MAPP
;                          Added PLOTGRAT		
;     APR 29, 2019 - KJWH: Added VERBOSE keyword
;                          Updated formatting	
;#################################################################################
;-
;***************************
ROUTINE_NAME  = 'MAPS_IMAGE'
;***************************
;
;===> DEFAULTS 
  IF NONE(DIR_OUT) THEN DIR_OUT = !S.IDL_TEMP 
  IF NONE(PAL)     THEN PAL = 'PAL_SW3'
  RES = 600  
  IF NONE(C_LOW)   THEN C_LOW = 1
  IF NONE(C_HI)    THEN C_HI = 250
  IF NONE(DELAY)   THEN DELAY = 10
  RGB_TABLE = RGBS(PAL=PAL)
  BACKGROUND_COLOR = RGBS(255) 
  MAP_INFO_FONT_SIZE=12
  MAP_INFO_COLOR = 'CRIMSON'
;||||||||||||||||||||||||||||||||||  

;####################### USE STRUCT OR MAPS_READ ? ########################
  IF N_ELEMENTS(STRUCT) GE 1 THEN BEGIN
    IF WHERE(TAG_NAMES(STRUCT) EQ 'MAP') NE -1 THEN MAP = STRUCT.MAP
  ENDIF;IF N_ELEMENTS(STRUCT)GE 1 THEN BEGIN
  
  IF NONE(MAPP)    THEN MESSAGE,'ERROR: MAP IS REQUIRED'
  IF NONE(STRUCT) THEN S = MAPS_READ(MAPP,INIT=1) ELSE S = STRUCT
  IF IDLTYPE(S) EQ 'STRING' THEN BEGIN
    PRINT,S
    GOTO,DONE
  ENDIF;IF IDLTYPE(S) EQ 'STRING' THEN BEGIN
  IF NONE(PX) THEN PX = S.PX 
  IF NONE(PY) THEN PY = S.PY
  WINDOW_TITLE = CALLER(2)
  SETCOLOR,255,0
  MAPS_SET,MAPP,BKG_COLOR=BACKGROUND_COLOR,PX=PX,PY=PY
  MAP_CONTINENTS,/HIRES,/FILL,COLOR = 253
  MAP_CONTINENTS,/HIRES,/COASTS,COLOR = 0,THICK = 1
  PLOTGRAT,1.0,PSYM = 2,SYMSIZE = 1
  IM = TVRD()
  ZWIN
  I = IMAGE(IM,DIMENSIONS=[PX,PY],RGB_TABLE=RGB_TABLE,MARGIN=0.0,BACKGROUND_COLOR=BACKGROUND_COLOR,WINDOW_TITLE = MAP) ; SETTING MARGIN=0 WILL MAXIMIZE THE IMAGE IN THE WINDOW

;#######   DISPLAY THE MAP INFO ON THE MAP  ###################
  A = STRUCT_2ARR(S)
  N = TAG_NAMES(S)
  TXT =  N + '      ' + A
  IF KEY(VERBOSE) THEN LI, TXT, /NOSEQ
  TXT = [SPACES(),TXT]
  T = TEXT(0.6,0.0, /RELATIVE, TXT, POSITION=[0.60,0.05,0.7,0.60], FONT_SIZE=MAP_INFO_FONT_SIZE, COLOR=MAP_INFO_COLOR, ALIGNMENT= 0,TARGET = I ) ; MUST BE BETWEEN 0 AND 1.0 (0=LEFT, 0.5=CENTER, 1.0=RIGHT)
  
;#######################  EDIT MAP ?  #########################         
  IF KEY(EDIT)THEN BEGIN
    PRINT,I
    STOP
  ENDIF;IF KEY(EDIT)THEN BEGIN

;#######################  WRITE PNG ?  ########################
  IF KEY(PNG) THEN BEGIN
    PNGFILE = DIR_OUT + MAPP + '.PNG'
    I.SAVE, PNGFILE, RESOLUTION=RES
    PFILE,PNGFILE,/W
  ENDIF;IF KEY(PNG) THEN BEGIN
  
  WAIT,DELAY
  I.CLOSE
  DONE: 

END; #####################  END OF ROUTINE ################################



