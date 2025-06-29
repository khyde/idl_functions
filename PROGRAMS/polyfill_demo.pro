; $ID:	POLYFILL_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO POLYFILL_DEMO,IMG

;
; PURPOSE: DEMO POLYFILL
;
; CATEGORY:	STRUCT
;
; CALLING SEQUENCE: POLYFILL_DEMO,STRUCT
;
; INPUTS: STRUCTURE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			WRITTEN JAN 28,2014 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'POLYFILL_DEMO'
;********************************

DO_IDL_EXAMPLE  =     0
DO_MY_EXAMPLE   =     0
DO_CHINOOK      =     0
DO_MAKE_TILE_MAP  =   1


;*********************************
IF DO_IDL_EXAMPLE GE 1 THEN BEGIN
;*********************************
  PAL_36
  WINSIZE=600
  WINDOW, /FREE, XSIZE=WINSIZE, YSIZE=WINSIZE
  ; FILL THE RECTANGLE DEFINED BY THE WINDOW WITH A 10% MARGIN:
  POLYFILL, [.1,.9,.9,.1]*WINSIZE, $
    [.1,.1,.9,.9]*WINSIZE, /DEVICE,COLOR = TC(26);, PATTERN = PAT
    GOTO,DONE
ENDIF;ENDIF;IF DO_IDL_EXAMPLE GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||
;;*********************************
IF DO_MY_EXAMPLE GE 1 THEN BEGIN
;*********************************  
  WINSIZE=600
  WINDOW, /FREE, XSIZE=WINSIZE, YSIZE=WINSIZE
  X = [0,1,1,0,0]
  Y = [0,0,1,1,0]
  PAL_36 
  PLOT,X,Y,/NODATA
  POLYFILL,X,Y,COLOR = 255,/DATA
  IM = TVRD()
  STOP
  GOTO,DONE
ENDIF;ENDIF;IF DO_MY_EXAMPLE GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||

;******************************
IF DO_CHINOOK GE 1 THEN BEGIN
;******************************

;; SET COLOR DISPLAY MODE TO DECOMPOSED COLOR
DEVICE, DECOMPOSED = 1
; DEFINE VARIABLES:
@PLOT01
; DRAW AXES, NO DATA, SET THE RANGE:
PLOT, YEAR, CHINOOK, YRANGE = [MIN(SOCKEYE), MAX(CHINOOK)], $
   /NODATA, TITLE='SOCKEYE AND CHINOOK POPULATIONS', $
   XTITLE='YEAR', YTITLE='FISH (THOUSANDS)'
   
; MAKE A VECTOR OF X VALUES FOR THE POLYGON BY DUPLICATING
; THE FIRST AND LAST POINTS:
PXVAL = [YEAR[0], YEAR, YEAR[N1]]

; GET Y VALUE ALONG BOTTOM X-AXIS:
MINVAL = !Y.CRANGE[0]

; MAKE A POLYGON BY EXTENDING THE EDGES DOWN TO THE X-AXIS:
POLYFILL, PXVAL, [MINVAL, CHINOOK, MINVAL], $
   COL = 0.75 * !D.N_COLORS
; SAME WITH SECOND POLYGON.
POLYFILL, PXVAL, [MINVAL, SOCKEYE, MINVAL], $
   COL = 0.50 * !D.N_COLORS
; LABEL THE POLYGONS:
XYOUTS, 1968, 430, 'SOCKEYE', SIZE=2
XYOUTS, 1968, 490, 'CHINOOK', SIZE=2
ENDIF;ENDIF;IF DO_CHINOOK GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||


IF DO_MAKE_TILE_MAP GE 1 THEN BEGIN
  SET_PLOT,'WIN'
  DIR = REPLACE(!S.BATHY,'SAVE','DATA')
  LONLATS_FILE = DIR + "SRTM30PLUS-LONLATS.csv"
  DB = CSV_READ(LONLATS_FILE) & PF,LONLATS_FILE,/R
  DB = STRUCT_2NUM(DB)
  DB.TILE = STRUPCASE(DB.TILE)
  PAL_36,R,G,B
  FONT_HELVETICA
  MAPS_SET,'SMI'
  MAP_CONTINENTS,/HIRES,/COASTS,COLOR = 0
 
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(DB)-1 DO BEGIN
    D = DB[NTH]
    POF,NTH,DB
;    X = [D.LONMIN,D.LONMAX,D.LONMAX,D.LONMIN,D.LONMIN]
;    Y = [D.LATMIN,D.LATMIN,D.LATMAX,D.LATMAX,D.LATMIN]
    X = [D.LONMIN,D.LONMAX,D.LONMAX,D.LONMIN]
    Y = [D.LATMIN,D.LATMIN,D.LATMAX,D.LATMAX]
    XYZ = CONVERT_COORD(X,Y,/DATA,/TO_DEVICE)
    X = XYZ(0,*)
    Y = XYZ(1,*)
    P
    COLOR = REPLICATE(FIX(D.COLOR),N_ELEMENTS(X))
    POLYFILL,X,Y,COLOR = COLOR,/DEVICE,NOCLIP = 1
;    XYOUTS,MEAN(X),MEAN(Y),STRTRIM(D.COLOR,2),CHARSIZE = 7,COLOR = 0,/DEVICE 
    ;DOPNG,PAL = 'PAL36'
    P
  ENDFOR;FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
  ;MAP_CONTINENTS,/HIRES,/COASTS,COLOR = 0

  IM = TVRD()

  ZWIN
  PNGFILE = !S.IDL_TEMP + 'SRTM30_TILES.PNG'
  WRITE_PNG,PNGFILE,IM,R,G,B
  PF, PNGFILE
  STOP
ENDIF;IF DO_MAKE_TILE_MAP GE 1 THEN BEGIN

DONE:
END; #####################  END OF ROUTINE ################################
