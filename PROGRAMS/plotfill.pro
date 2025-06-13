; $ID:	PLOTFILL.PRO,	2020-07-08-15,	USER-KJWH	$

PRO PLOTFILL, $
              LEFT=left,$
              RIGHT=right,$
              BOTTOM=bottom,$
              Top=top,$
              offset,_EXTRA=_extra
;+
; NAME:
;       PLOTFILL
;
; PURPOSE:
;       Fill the area within the plotting area
;
; CATEGORY:
;       Plotting
;
; CALLING SEQUENCE:
;       PLOTFILL
;       PLOTFILL, COLOR = 3
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;      OFFSET:  The offset [left,right,bottom,top
;      _EXTRA:  Any valid IDL plot keywords
;
; OUTPUTS:
;      Fills in the plot area in the active graphics window
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 5, 1998
;-

  IF KEYWORD_SET(LEFT) OR KEYWORD_SET(RIGHT) OR KEYWORD_SET(BOTTOM) OR KEYWORD_SET(TOP) THEN BEGIN
  ; Get Normal cordinates for plot window
    x0 = !x.window[0]
    x1 = !x.window[1]
    y0 = !y.window[0]
    y1 = !y.window[1]
    NORMAL=1
    IF KEYWORD_SET(LEFT)   THEN x0 = x0+left
    IF KEYWORD_SET(RIGHT)  THEN x1 = x1-right
    IF KEYWORD_SET(BOTTOM) THEN y0 = y0+bottom
    IF KEYWORD_SET(TOP)    THEN y1 = y1-top
  ENDIF ELSE BEGIN
    x0 = !x.crange[0]
    x1 = !x.crange[1]
    y0 = !y.crange[0]
    y1 = !y.crange[1]
  ENDELSE

  POLYFILL,  [x0,x0,x1,x1,x0],$
             [y0,y1,y1,y0,y0],$
             NORMAL=normal,_EXTRA=_extra



  END
