; $ID:	TOPO_VIEW.PRO,	2020-07-01-12,	USER-KJWH	$
; 
PRO TOPO_VIEW,MAPP,LEVELS,PROD=PROD,COLORS=COLORS,THICKS=THICKS,METHOD=METHOD,BUFFER=BUFFER,NO_CB=NO_CB, LABEL=LABEL,PNGFILE=PNGFILE,DIR=DIR,DELAY=DELAY,_EXTRA=_EXTRA
; #########################################################################; 
;+
; THIS DISPLAYS LEVELS [DEPTHS OR ELEVATIONS] FROM SRTM30-PLUS TOPO DATA 

;
; CATEGORY: TOPO FAMILY
;
;
; INPUTS: MAPP ..... STANDARD MAP NAME
;         LEVELS.... ELEVATIONS [VALUES GE 0 ] OR DEPTHS [LT 0] [METERS, MAY BE MULTIPLE VALUES]

;
; KEYWORDS: 
;         PROD...... STANDARD PROD NAME
;         COLORS.... COLORS OF CONTOUR LINES [DEFAULT = 255]
;         THICKS.... THICKNESS OF CONTOUR LINES
;         METHOD.... METHOD OF DRAWING THE CONTOUR PATHS ['NG'= NEW GRAPHICS OR'DG'=[DIRECT GRAPHICS
;         BUFFER.... SEE WINDOW FUNCTION 
;         NO_CB..... NO COLORBAR [PASSED TO IMGR]
;         LABEL..... LABEL CONTOURS WHEN METHOD = 'DG'
;         PNGFILE... NAME OF OUTPUT PNG TO WRITE
;         DIR...     DIRECTORY OF THEN OUTPUT FILE 
;         DELAY..... SECONDS TO DELAY THE CLOSING OF THE DISPLAY
;         _EXTRA.... PASSED TO IMGR

; OUTPUTS: DISPLAYS A MAP OF THE LEVELS
;
;; EXAMPLES:
;       MAKE A GLOBAL SMI OF TOPOGRAPHY AN BATHYMMETRY
;       TOPO_VIEW,'SMI',PROD = 'TOPO',PAL = 'PAL_TOPO',PNGFILE=!S.IDL_TEMP + 'SMI-TOPO.PNG',/VERBOSE,/NO_CB
;       TOPO_VIEW ; WHEN NO MAPP THEN DEFAULTS TO SMI AND PLOTS THE 200M ISOBATH
;       METHOD = 'NG'
;       TOPO_VIEW,'EC',-[50,100,200,2000,4000],PROD = 'DEPTH',METHOD = 'NG',COLORS = [255,0,255,254,252],THICKS = [1],PNGFILE = !S.IDL_TEMP +'BATHY_EC-NG.PNG'
;;      METHOD = 'DG'
;       TOPO_VIEW,'EC',-[50,100,200,2000,4000],PROD = 'DEPTH',METHOD = 'DG',LABEL = 0,COLORS = [251,252,253,254,255],THICKS = 2,PNGFILE = !S.IDL_TEMP +'BATHY_EC-DG.PNG'
;
;       
;       
;       
; MODIFICATION HISTORY:
;     DEC 15, 2015  WRITTEN BY: J.E. O'REILLY
;     JAN 06, 2016 - JEOR: ADDED BYT=BYT TO CALL TO IMGR
;                          FIXED NG METHOD
;     JAN 07, 2016 - KJWH: CHANGED VARIABLE NAME TOPO TO TPO TO AVOID CONFLICT WITH IDL'S TOPO.PRO
;                          FORMATTING
;                          ADDED ERROR MESSAGE IF THE TOPO.SAV IS NOT AVAILABLE 
;                          ADDED DIR KEYWORD
;                          ADDED PX AND PY TO MAPS_SIZE
;                          ADDED C.CLOSE TO CLOSE THE IMAGE WINDOW
;     JAN 10, 2016 - JEOR: IF NONE(DELAY) THEN DELAY = 11 , NO_CLOSE LOGIC
;     JAN 23, 2016 - JEOR: ADDED KEY LABEL
;-
; #########################################################################

;**************************
  ROUTINE_NAME  = 'TOPO_VIEW'
;**************************
  IF NONE(PROD) THEN PROD = 'DEPTH'
  IF NONE(MAPP) THEN BEGIN
    MAPP = 'SMI'
    IF NONE(NO_CLOSE) THEN NO_CLOSE = 0
    IF NONE(BUFFER) THEN BUFFER = 0  
  ENDIF ELSE BEGIN
    IF NONE(NO_CLOSE) THEN NO_CLOSE = 1
    IF NONE(BUFFER) THEN BUFFER = 1
  ENDELSE
  IF NONE(DELAY) THEN DELAY = 11
  IF NONE(BIT_DEPTH) THEN BIT_DEPTH = 1
  M = MAPS_SIZE(MAPP,PX=PX,PY=PY)
  IF NONE(DIR)     THEN DIR     = !S.DEMO + ROUTINE_NAME + PATH_SEP() & DIR_TEST, DIR
  IF NONE(PNGFILE) THEN PNGFILE = DIR + ROUTINE_NAME + '-' + MAPP +'-' + PROD + '-'+ '.PNG'
  IF NONE(LEVELS)  THEN LEVELS  = -200
  IF NONE(COLORS)  THEN COLORS  = REPLICATE(255,NOF(LEVELS))
  IF NONE(THICKS)  THEN THICKS  = REPLICATE(1,NOF(LEVELS))
  IF NONE(METHOD)  THEN METHOD  = '' 
  C_FONT_SIZE = 8
  
  ;===> GET ALL THE TOPO DATA FOR THIS MAPP
  TPO = TOPO_GET(MAPP,/DATA)
  IF IDLTYPE(TPO) EQ 'STRING' THEN MESSAGE, TPO

  IF PROD EQ 'DEPTH' THEN BEGIN  
    TITLE = 'DEPTH'+ '   ' + UNITS(PROD,/NO_NAME)+ '- ' + MAPP
    PAL = 'PAL_BATHY'
  ENDIF;IF PROD EQ 'DEPTH' THEN BEGIN
  
  IF PROD EQ 'TOPO' THEN BEGIN
    TITLE = 'TOPO'+ '   ' + UNITS(PROD,/NO_NAME)+ '- ' + MAPP
    PAL = 'PAL_TOPO' 
    GONE,MAPP; [WHEN PROD = TOPO WE DO NOT WANT TO MASK THE LAND WITH THE LANDMASK]
  ENDIF;IF PROD EQ 'TOPO' THEN BEGIN

;===> MAKE A BYT IMAGE OF THE DEPTHS IN TOPO AND CAPTURE THE IMAGE IN IMG AND THE IMAGE OBJECT IN OBJ
  IMGR, TPO, PROD=PROD,TITLE=TITLE, TAG=TAG, MAP=MAPP, COAST_ONLY=COAST_ONLY, VSTAG=1, PAL=PAL, DELAY=DELAY,$
        BUFFER=BUFFER, VERBOSE=VERBOSE, BIT_DEPTH=BIT_DEPTH, COMMA=1, OBJ=OBJ, BYT=BYT,NO_CB=NO_CB, NO_CLOSE=NO_CLOSE, _EXTRA=_EXTRA
;******************************
  IF METHOD EQ 'NG' THEN BEGIN 
;******************************
  ;===> MAKE X & Y ARRAYS TO MATCH DIMENSIONS OF TOPO
    S = SIZEXYZ(TPO)
    X = FINDGEN(S.PX) & Y = FINDGEN(S.PY)
    C_COLOR =  RGBS(COLORS,PAL = PAL)
    ;===> PASS THE OBJECT [OBJ] FROM IMGR TO CONTOUR
    C = CONTOUR(TPO,X,Y, OVERPLOT=OBJ,C_VALUE=LEVELS,C_COLOR = C_COLOR,C_THICK=THICKS,C_LABEL_SHOW = 1,FONT_SIZE= C_FONT_SIZE  )
    C.SAVE,PNGFILE
    PFILE,PNGFILE
    C.CLOSE
    GOTO,DONE
  ENDIF;IF METHOD EQ 'NG' THEN BEGIN

;***************************
  IF METHOD EQ 'DG' THEN BEGIN ;===> DISPLAY BYT IN THE ZWIN
;***************************
    PLT_TOPO,MAPP,LEVELS,THICKS=THICKS,COLORS=COLORS,BYT=BYT,PAL = PAL,PNGFILE=PNGFILE, LABEL=LABEL ;===> ADD CONTOURS USING PLT_DEG
  ENDIF ; IF METHOD EQ 'DG' THEN BEGIN
        
DONE:
         

END; #####################  END OF ROUTINE ################################
