; $Id:	grids.pro,	January 04 2007	$

	PRO GRIDS, X=X, Y=Y, NO_X=no_x, NO_Y=no_y, ALL=all, _EXTRA=_extra

;+
; NAME:
;		GRIDS
;
; PURPOSE:;
;		This program DRAWS grid lines of any color, thickness, and linesytle in the Plot Window
 ;
; CATEGORY:
;		GRAPHICS
;
; CALLING SEQUENCE:
;		GRIDS
;
; INPUTS:
;		X:	X coordinates for the Vertical grid lines
;		Y:	Y coordinates for the Horizontal grid lines
;
 ;
; KEYWORD PARAMETERS:
;		NO_X:	Suppress Vertical grid lines
;		NO_Y:	Suppress Horizontal grid lines
;		ALL:	Draw all grid lines
;		_EXTRA: Any valid keywords for the PLOTS routine used by this program to draw the grids
;					  e.g. color, linestyle,thick
;
;
; OUTPUTS:
;		Grid lines are drawn on the default graphics device
;
;
; EXAMPLE:
; First;  PLOT,[1,2,3], /NODATA, XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
;       Then:   GRIDS, X=XTICK_GET,Y=YTICK_GET
;       Or:      GRIDS, X=XTICK_GET,Y=YTICK_GET , COLOR=128,THICK=2,LINESTYLE=1
;
;
;
;	NOTES:
;		The default for this routine is not to draw grids atop the x and y axes lines
;		KEYWORD ALL is used to draw all grids provided in X,Y (or determined by this routine if X,Y
;		are not provided), even those atop the x and y axes lines
;
;

; MODIFICATION HISTORY:
; 	Written by:  J.E.O'Reilly, Oct 17, 1997
;		March 21,2003 jor eliminated FRAME ; NOW USE FRAME,/PLOT,COLOR=0,THICK=1; ETC
;		Jan 4, 2006 JOR Streamlined routine
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GRIDS'

;	===> Get the min,max, x,y from the plot axes
	IF !X.TYPE EQ 0 THEN BEGIN
  	MIN_X = !X.CRANGE(0)
  	MAX_X = !X.CRANGE(1)
  ENDIF ELSE BEGIN
  	MIN_X = 10^!X.CRANGE(0)
  	MAX_X = 10^!X.CRANGE(1)
  ENDELSE
  IF !Y.TYPE EQ 0 THEN BEGIN
  	MIN_Y = !Y.CRANGE(0)
  	MAX_Y = !Y.CRANGE(1)
  ENDIF ELSE BEGIN
  	MIN_Y = 10^!Y.CRANGE(0)
  	MAX_Y = 10^!Y.CRANGE(1)
	ENDELSE



;	*******************************************************************************************
;	*** If X or Y not provided then get them from the current PLOT using the AXIS procedure ***
;	*******************************************************************************************

	IF N_ELEMENTS(X) EQ 0 THEN BEGIN
;		===> If the X axis is linear get XX from XTICK_GET
  	IF !X.TYPE EQ 0 THEN AXIS,/XAXIS,/NODATA,XSTYLE=5,XTICK_GET=XX
;		===> If the X axis is log then get XX from the DECADES function
  	IF !X.TYPE EQ 1 THEN BEGIN
      DEC = DECADES()
      OK = WHERE(DEC GE MIN_X AND DEC LE MAX_X,COUNT)
      IF COUNT GE 1 THEN XX = DEC(OK) ELSE XX = [MIN_X,MAX_X]
  	ENDIF
  ENDIF ELSE XX = X

	IF N_ELEMENTS(Y) EQ 0 THEN BEGIN
;		===> If the Y axis is linear get YY from YTICK_GET
  	IF !Y.TYPE EQ 0 THEN AXIS,/YAXIS,/NODATA,YSTYLE=5,YTICK_GET=YY
;		===> If the Y axis is log then get YY from the DECADES function
  	IF !Y.TYPE EQ 1 THEN BEGIN
      DEC = DECADES()
      OK = WHERE(DEC GE MIN_Y AND DEC LE MAX_Y,COUNT)
      IF COUNT GE 1 THEN YY = DEC(OK) ELSE YY = [MIN_Y,MAX_Y]
  	ENDIF
  ENDIF ELSE YY = Y



;	===> Unless ALL keyword is used the default for this routine
;			 is not to draw grids atop x,y axes
;			 Remove any XX,YY that on the plot axes
  IF NOT KEYWORD_SET(ALL) THEN BEGIN
    OK=WHERE(XX NE MIN_X AND XX NE MAX_X,COUNT)
    IF COUNT GE 1 THEN XX = XX(OK)
		OK=WHERE(YY NE MIN_Y AND YY NE MAX_Y,COUNT)
    IF COUNT GE 1 THEN YY = YY(OK)
  ENDIF


;	===> DRAW X GRIDS unless preempted by NO_X
  IF NOT KEYWORD_SET(NO_X) THEN BEGIN
	  FOR I = 0L,N_ELEMENTS(XX)-1L DO BEGIN
	    PLOTS,[XX(I),XX(I)],[MIN_Y,MAX_Y],_EXTRA=_extra
	  ENDFOR
	ENDIF


;	===> DRAW Y GRIDS unless preempted by NO_Y
	IF NOT KEYWORD_SET(NO_Y) THEN BEGIN
	  FOR I = 0L,N_ELEMENTS(YY)-1L DO BEGIN
	    PLOTS,[MIN_X,MAX_X],[YY(I),YY(I)],_EXTRA=_extra
	  ENDFOR
  ENDIF

	END; #####################  End of Routine ################################

