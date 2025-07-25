; $Id:	ARROW_RAINBOW.PRO,	2003 Dec 02 15:41	$

 PRO ARROW_RAINBOW, ANGLE, ASPECT=ASPECT,ALIGN=align
;+
; NAME:
;       ARROW_RAINBOW
;
; PURPOSE:
;
;

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, May 5, 2004
;
;-

ROUTINE_NAME='ARROW_RAINBOW'
	IF N_ELEMENTS(ASPECT) NE 1 THEN _ASPECT = 9 ELSE _ASPECT = ASPECT

	BACKGROUND=255

  IF N_ELEMENTS(ANGLE) NE 1 THEN _ANGLE=0 ELSE _ANGLE = ANGLE

IF _ANGLE EQ 0  THEN BEGIN
	ZWIN,[100,760]
	VERTICAL = 1
	HORIZONTAL = 0
ENDIF

IF _ANGLE EQ 90 OR _ANGLE EQ 270 THEN BEGIN
	ZWIN,[760,100]
	VERTICAL = 0
	HORIZONTAL = 1
ENDIF




PAL_SW3,R,G,B
SETCOLOR,BACKGROUND
ERASE,BACKGROUND
ARROW_OPEN,COLOR=0,SYMSIZE=7,ASPECT=_ASPECT,THICK=3,FILL=1,ANGLE=_ANGLE,ALIGN=align
PLOT,[0,1],[0,1],/nodata,xstyle=5,ystyle=5,xmargin=[0,0],ymargin=[0,0],/NOERASE
plots,0.5,0.5,PSYM=8,SYMSIZE=10.,COLOR=0,THICK=3
IM=TVRD()

INSIDE=WHERE(IM EQ 0,COMPLEMENT=OUTSIDE)


SETCOLOR,BACKGROUND
ERASE,BACKGROUND
CBAR,vmin=0, vmax=255, cmin=0, cmax=255, VERTICAL=VERTICAL,HORIZONTAL=HORIZONTAL,XMARGIN=[0,0],YMARGIN=[0,0],POS=[0,0,.999,.999],XSTYLE=5,YSTYLE=5
PAL_SW3,R,G,B
IM = TVRD()
IM(OUTSIDE) = BACKGROUND
TV,IM
ARROW_OPEN,COLOR=0,SYMSIZE=7,ASPECT=_ASPECT,THICK=3,FILL=0,ANGLE=_ANGLE,ALIGN=align
PLOT,[0,1],[0,1],/nodata,xstyle=5,ystyle=5,xmargin=[0,0],ymargin=[0,0],/NOERASE
plots,0.5,0.5,PSYM=8,SYMSIZE=10.,COLOR=0,THICK=3
IM=TVRD()
ZWIN
IM=CUTOUT(IM,BACKGROUND=BACKGROUND)

DIR='D:\IDL\IMAGES\'
PNGFILE=DIR+ROUTINE_NAME+'_'+NUM2STR(_ANGLE)+'.PNG'
WRITE_PNG,PNGFILE,IM,R,G,B


END; #####################  End of Routine ################################



