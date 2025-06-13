; $ID:	PLOT_LINE.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO PLOT_LINE, X=X,Y=Y,_EXTRA=_extra
;+
; NAME:
;       PLOT_LINE
;
; PURPOSE:
;       Overplot a line atop an existing plot
;
; CATEGORY:
;      PLOT
;
; CALLING SEQUENCE:
;       PLOT_LINE
;       PLOT_LINE, color=126,linestyle=2

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

; ====> Get x and y axis limits for subsequent plotting of PLOT_LINE line

  XCRANGE= !X.CRANGE
  YCRANGE= !Y.CRANGE

IF KEYWORD_SET(_EXTRA) THEN BEGIN
  NAMES = STRUPCASE(TAG_NAMES(_EXTRA))
  OK = WHERE(STRPOS(NAMES, 'LINESTYLE') GE 0,COUNT)
  IF COUNT EQ 1 THEN BEGIN
      LINESTYLE=_EXTRA.LINESTYLE
      IF LINESTYLE GE 31 THEN BEGIN
        LINE_COLOR = [0,255]  ; BLACK CENTER LINE AND WHITE MIDDLE LINE FOR CONTRAST
         LINE = LONG(LINESTYLE/10)
         LINE = LINESTYLE MOD LINE
         LINE_THICK = [LINE , LINE]
       ENDIF
  ENDIF
ENDIF


; ====================>
; If System variables !X.TYPE and !Y.TYPE ARE 1 THEN
; the plot is a log axis type

  IF !X.TYPE EQ 1 THEN XCRANGE= (10.0d*DOUBLE[1])^!X.CRANGE
  IF !Y.TYPE EQ 1 THEN YCRANGE= (10.0d*DOUBLE[1])^!Y.CRANGE

  IF N_ELEMENTS(X) EQ 1 THEN OPLOT, [X,X], YCRANGE, _EXTRA=_extra
  IF N_ELEMENTS(Y) EQ 1 THEN OPLOT, XCRANGE,[Y,Y], _EXTRA=_extra

  END ; END OF PROGRAM
