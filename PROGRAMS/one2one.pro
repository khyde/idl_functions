; $ID:	ONE2ONE.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO ONE2ONE, RATIO=ratio,_EXTRA=_extra
;+
; NAME:
;       ONE2ONE
;
; PURPOSE:
;       Overplot a one 2 one line (x=y) atop an existing plot
;
; CATEGORY:
;      PLOT
;
; CALLING SEQUENCE:
;       ONE2ONE
;       one2one, color=126,linestyle=2
;       one2one, ratio=5
;
; INPUTS:
;       None Required.
;
; KEYWORD PARAMETERS:
;        ratio      : Ratio of y to x (Used to draw a 2:1 , 3:1 , 1:5 curve etc.)
;       _EXTRA      : May contain Any IDL KEYWORDS which are valid for the OPLOT Command.
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       Overplots a line atop existing plot
;
; RESTRICTIONS:
;       Assumes you have already issued a PLOT COMMAND.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Feb 10, 1997.
;-

; ====================>
; over plot ONE2ONE line.
; Get x and y axis limits for subsequent plotting of one2one line

  XCRANGE= !X.CRANGE
  YCRANGE= !Y.CRANGE

IF KEYWORD_SET(_EXTRA) THEN BEGIN
  NAMES = STRUPCASE(TAG_NAMES(_EXTRA))
  OK = WHERE(STRPOS(NAMES, 'LINESTYLE') GE 0,COUNT)
  IF COUNT EQ 1 THEN BEGIN
      REG_LINESTYLE=_EXTRA.LINESTYLE
      IF REG_LINESTYLE GE 31 THEN BEGIN
        REG_COLOR = [0,255]  ; BLACK CENTER LINE AND WHITE MIDDLE LINE FOR CONTRAST
         REG_ = LONG(REG_LINESTYLE/10)
         REG__ = REG_LINESTYLE MOD REG_
         REG_THICK = [REG_ , REG__]
       ENDIF
  ENDIF
ENDIF


; ====================>
; If System variables !X.TYPE and !Y.TYPE ARE 1 THEN
; the plot is a log axis type

  IF !X.TYPE EQ 1 THEN XCRANGE= (10.0d*DOUBLE[1])^!X.CRANGE
  IF !Y.TYPE EQ 1 THEN YCRANGE= (10.0d*DOUBLE[1])^!Y.CRANGE

  LL= [XCRANGE[0] > YCRANGE[0], XCRANGE[1] < YCRANGE[1]]
  UR= [XCRANGE[0] > YCRANGE[0], XCRANGE[1] < YCRANGE[1]]

  range = [ll[0] < ur[0], ll[1] > ur[1]]
  increment = (range[1] - range[0])/1000.
  xx = range[0] + LINDGEN(1000) * increment


  IF N_ELEMENTS(ratio) EQ 1 THEN OPLOT, XX,ratio*XX, _EXTRA=_extra ELSE $
  OPLOT, XX,XX, _EXTRA=_extra

  END ; END OF PROGRAM
