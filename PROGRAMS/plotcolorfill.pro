; $ID:	PLOTCOLORFILL.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; NAME:
;   PLOTCOLORFILL
;
; AUTHOR:
;   Craig B. Markwardt, NASA/GSFC Code 662, Greenbelt, MD 20770
;   craigm@lheamail.gsfc.nasa.gov
;
; PURPOSE:
;   Plots colorful bar charts
;
; CALLING SEQUENCE:
;   PLOTCOLORFILL, x, y, COLOR=col, BOTTOM=bot, WIDTH=wid, ...
;
; DESCRIPTION:
;
;   PLOTCOLORFILL plots a colorful vertical bar chart.  This may be
;   useful in cases where two dimensions of information need to be
;   conveyed in one plot.  [ I use it to show total intensity as a
;   function of time on the vertical axis, and temperature is coded
;   with color. ]
;
;   Most aspects of the bars are configurable.  The color is specified
;   by an array of colors, one for each bar.  [ Alternatively, a
;   single color for the entire plot can be given. ] Also, one color
;   can be designated as transparent.
;
;   Stacked bar charts can be constructed using two calls to
;   PLOTCOLORFILL.  See the example.
;
; INPUTS:
;
;   X, Y - Two arrays which give the X and Y position of the points.
;          In this style of plot, the x values should be monotonically
;          increasing, but not necessarily monospaced (see WIDTH).
;
; OPTIONAL INPUTS:
;   NONE
;
; INPUT KEYWORD PARAMETERS:
;
;   COLOR - an array giving the color of each bar, or alternatively a
;           scalar color for all of the bars.  The current color table
;           is not changed.  Default is color "1"
;
;   BOTTOM - normally the bottom of the bars is set to be zero.  You
;            may either specify a scalar bottom value for all of the
;            bars, or an array giving the bottom of each bar
;            individually.  See the example to see how stacked bar
;            charts can be constructed with this keyword.
;
;   WIDTH - sets the width of each bar, globally or individually.
;           Bars are centered on the "X" value, and extend 0.5 * WIDTH
;           to either side.  Default is to assume monospacing, using
;           the separation between the first two x values.
;
;   TRANSPARENT - designates a color which is "transparent".  Any bars
;                 with this color are simply not plotted.  Default is
;                 no transparent color.
;
;   PANEL, SUBPANEL - An alternate way to more precisely specify the
;                     plot and annotation positions.  See SUBCELL.
;                     Default is full-screen.
;
;   POSITION - Position of the bar chart in normal coordinates.
;              Overrides position given by PANEL/SUBPANEL.
;
;   XRANGE, YRANGE - gives plot range for each dimension, as for other
;                    plot commands.  Default is range of data.
;
;   Other keywords are passed to the plot command directly.
;
; OUTPUTS:
;   NONE
;
; PROCEDURE:
;
; EXAMPLE:
;
;   Stacked barcharts can be constructed by first making one chart
;   with a flat bottom, and then a second chart whose bottom is top of
;   the first.
;
;   x = findgen(30)
;   y1 = x^2
;   y2 = 400.-x
;   c1 = bindgen(30)*3+1b
;   c2 = 100b-bindgen(30)*3+1b
;   plotcolorfill, x, y1,    color=c1, bottom=0.
;   plotcolorfill, x, y1+y2, color=c2, bottom=y1, /noerase
;
; SEE ALSO:
;
;   PLOTPAN
;
; EXTERNAL SUBROUTINES:
;
;   SUBCELL, DEFSUBCELL, PLOTPAN
;
; MODIFICATION HISTORY:
;   Written, CM, 1997
;
;-

forward_function defsubcell, subcell

function defsubcell, default

  if n_elements(default) EQ 0 then default = [-1.,-1,-1,-1]
  mysubcell = default
  defaultsubpos = [ 0.08, 0.08, 0.95, 0.95 ]

  iwh = where(mysubcell LT 0, ict)
  if ict GT 0 then $
    mysubcell(iwh) = defaultsubpos(iwh)

  return, mysubcell
end

function subcell, subpos, position, margin=margin

  ;; Default value for subposition
  if n_elements(subpos) EQ 0 then mysubpos = [-1.,-1,-1,-1] $
  else mysubpos = subpos

  ;; Default value for position - full screen
  if n_elements(position) EQ 0 then position = [0.,0.,1.,1.]

  ;; Get margins if necessary
  if keyword_set(margin) EQ 1 OR n_elements(subpos) EQ 0 then $
    mysubpos = defsubcell(mysubpos)

  ;; Compute new window position
  x0 = position[0]
  y0 = position[1]
  dx = position(2)-position[0]
  dy = position(3)-position[1]

  newsubpos = reform(mysubpos * 0, 4)
  newsubpos([0,2]) = x0 + dx * mysubpos([0,2])
  newsubpos([1,3]) = y0 + dy * mysubpos([1,3])

  return, newsubpos
end


pro plotpan, x, y, $
             subpanel=subpanel, panel=panel, $
             _EXTRA=extra

  ;; Default is full-screen
  if n_elements(panel) EQ 0 AND n_elements(subpanel) EQ 0 then begin
      plot, x, y, /normal, _EXTRA=extra
  endif else begin
      if n_elements(panel) EQ 0 then panel=[0.0,0.0,1.0,1.0]
      plot, x, y, /normal, position=subcell(subpanel, panel, /marg), $
        _EXTRA=extra
  endelse

  return
end

pro plotcolorfill, x, y, color=col, bottom=bot, width=width, $
                   transparent=transparent, $
                   subpanel=subpanel, panel=panel, $
                   xrange=xrange, yrange=yrange, $
                   position=position, xstyle=xstyle, ystyle=ystyle, $
                   noerase=noerase, $
                   _EXTRA=extra


  if n_elements(xrange) EQ 0 then xrange = [min(x), max(x)]
  if n_elements(yrange) EQ 0 then yrange = [min(y), max(y)]

  ;; Set default values
  if n_elements(bot) EQ 0 then bot = y * 0. + yrange[0]
  if n_elements(bot) EQ 1 then bot = y * 0. + bot
  if n_elements(col) EQ 0 then col = byte(y)*0b+1b
  if n_elements(col) EQ 1 then col = byte(y)*0b+col
  if n_elements(width) EQ 0 then width = float(x)*0 + (x[1]-x[0])
  if n_elements(width) EQ 1 then width = float(x)*0 + width
  if n_elements(xstyle) EQ 0 then xstyle = 0
  if n_elements(ystyle) EQ 0 then ystyle = 0
  if n_elements(transparent) EQ 0 then transparent = -1L

  ;; Plot coordinate grid first
  if NOT keyword_set(noerase) then begin
  if n_elements(panel) EQ 0 AND n_elements(subpanel) EQ 0 then begin
      if n_elements(position) GT 0 then $
        extra = create_struct(extra, 'POSITION', position)
      plot, xrange, yrange, /nodata, xstyle=xstyle, ystyle=ystyle,_EXTRA=extra
  endif else begin
      ;; Set panel size
      if n_elements(panel) EQ 0 then panel=[0.0,0.0,1.0,1.0]
      if n_elements(subpanel) EQ 0 then subpanel = [-1., -1., -1., -1. ]
      subpanel = defsubcell(subpanel)
      plotpan, xrange, yrange, /nodata, panel=panel, subpanel=subpanel, $
        xstyle=xstyle, ystyle=ystyle, _EXTRA=extra
  endelse
  endif

  ;; Compute binsize
  numx     = n_elements(x)
  if n_elements(y) LT numx then numx = n_elements(y)

  ;; Loop through and draw filled rectangles
  for i = 0, numx-2 do begin
      binsz = width(i)/2.
      ;; The vertical size is given by "bot" and "y"
      if x(i) GE xrange[0] AND x(i+1) LE xrange[1] $
        AND long(col(i)) NE transparent then begin
          polyfill, $
            [x(i)-binsz, x(i)+binsz, x(i)+binsz, x(i)-binsz], $
            [bot(i), bot(i), y(i), y(i)] , $
            color=col(i), /data, noclip=0
      endif
  endfor

  ;; Overlay the coordinate grid again in case it got partially wiped.
  if NOT keyword_set(noerase) then begin
      axis, xaxis=0, xtickformat='(A1)', xrange=xrange, xstyle=xstyle
      axis, xaxis=1, xtickformat='(A1)', xrange=xrange, xstyle=xstyle
      axis, yaxis=0, ytickformat='(A1)', yrange=yrange, ystyle=ystyle
      axis, yaxis=1, ytickformat='(A1)', yrange=yrange, ystyle=ystyle
  endif

  ;; Finally, overlay the trace at the top of the curve.
  numx = numx
  xtop = fltarr(2, numx)
  ytop = fltarr(2, numx)
  numx = numx - 1
  xtop(0, *) = [ x(0:numx)-width(0:numx)/2. ]
  xtop(1, *) = [ x(0:numx)+width(0:numx)/2. ]
  ytop(0, *) = y(0:numx)
  ytop(1, *) = y(0:numx)
  ;; Plot the data trace at the top
  oplot, xtop, ytop

  return
end
