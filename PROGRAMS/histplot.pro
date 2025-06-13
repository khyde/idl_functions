; $ID:	HISTPLOT.PRO,	2020-07-08-15,	USER-KJWH	$
PRO HISTPLOT, $
; 						The following 9 variables are identical to those in the IDL HISTOGRAM function
              array,$                          ;INPUT
              BINSIZE=binsize,$                ;INPUT
              INPUT=input,$                    ;INPUT
              MAX=max,$                        ;INPUT
              MIN=min,$                        ;INPUT
              NAN=nan,$                        ;INPUT
              OMAX=omax,$                      ; OUTPUT
              OMIN=omin,$                      ; OUTPUT
              REVERSE_INDICES=reverse_indices,$; OUTPUT

;             Parameters computed and available as output:
              xhist,$                          ; OUTPUT
              yhist,$                          ; OUTPUT

;             yticks controls the number of y-axis tick intervals
              YTICKS=yticks,$                  ;INPUT

;             Relative Frequency
              RF=rf, $

;             Adds label (title) anywhere such as inside the histogram plot area
              NAME_TITLE = name_title,$
              NAME_POS=name_pos,$
              NAME_COLOR=name_color,$        ;INPUT
              NAME_CHARSIZE=name_charsize,$  ;INPUT
              NAME_ALIGN=name_align, $


;             Histogram bars:
              bar_NONE= bar_none,$             ;INPUT
              bar_color=bar_color,$            ;INPUT
              bar_outline=bar_outline,$        ;INPUT
              bar_thick=bar_thick,$            ;INPUT
              bar_opaque=bar_opaque,$          ;INPUT
              bar_center= bar_center,$         ;INPUT

;             Histogram labels above the bars:
              LAB_NONE=lab_none,$              ;INPUT
              LAB_PEAK=lab_peak,$              ;INPUT
              LAB_LEFT=lab_left,$              ;INPUT
              LAB_RIGHT=lab_right,$            ;INPUT
              lab_color=lab_color,$            ;INPUT
              LAB_CHARSIZE=lab_charsize,$      ;INPUT
              LAB_ABOVE=lab_above,$            ;INPUT
              LAB_ROOM=lab_room,$              ;INPUT


;             Cumulative % line:
              CUM_NONE=CUM_NONE,$              ;INPUT
              CUM_TITLE=cum_title,$            ;INPUT
              CUM_COLOR=cum_color,$            ;INPUT
              CUM_THICK=cum_thick,$            ;INPUT
              CUM_LINESTYLE=cum_linestyle,$    ;INPUT
              CUM_FMT=cum_fmt,$                ;INPUT
              CUM_CHARSIZE=cum_charsize,$      ;INPUT

;             Statistics
              STATS_NONE=STATS_NONE,$          ;INPUT
              STATS_POS=stats_pos,$            ;POSITION INSIDE PLOT WINDOW
              STATS_COLOR=stats_color,$        ;INPUT
              STATS_CHARSIZE=stats_charsize,$  ;INPUT
              PARAMS=params,$       ; Passed to Stats.pro
              DECIMALS=DECIMALS,$   ; Passed to STATS.pro
              STATS_BOX_COLOR=STATS_BOX_COLOR,$

							GRIDS_NONE = GRIDS_NONE,$
              GRIDS_LINESTYLE = GRIDS_LINESTYLE,$
              GRIDS_COLOR=GRIDS_COLOR,$
              GRIDS_THICK = GRIDS_THICK,$


              QUIET=quiet,$         ; Passed to Stats.pro

;             Any valid commands to plot
;            (color, linestyle,thick,xgridstyle,xrange,yrange,etc.
;             get stuffed into _extra
              _EXTRA = _extra

;+
; NAME:
;       HISTPLOT
;
; PURPOSE:
; Plot the histogram of an array
;   and optionally plot the cumulative % frequency
;
; CATEGORY:
;   Plotting/Statistics
;
; CALLING SEQUENCE:
; histplot, array
;   histplot, array, xhist,yhist
;
; EXAMPLES
;   HISTPLOT,DIST(500),BINSIZE=5,TITLE='DIST FUNCTION',XTITLE='UNITS'
;   HISTPLOT,RANDOMN(SEED,1000)
;   HISTPLOT,RANDOMN(SEED,100000),binsize=0.1,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],decimals=3
;   HISTPLOT,RANDOMN(SEED,100000),binsize=0.1,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=196
; The following I like best:
;  HISTPLOT,RANDOMN(SEED,240000),binsize=0.1,lab_bars=[1,1,1],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=196,YRANGE=[0,10000],TITLE='Normal Distribution',cum_fmt='(i3,"%")',decimals=4
; INPUTS:
;   An array of integer,long,float,double
;
; KEYWORD PARAMETERS:
; BINSIZE - The size of each bin of the histogram (default=1)
;             (See IDL routine Histogram ... keywords here are the same as used in HISTOGRAM.PRO
;
;   Any input keyword that can be supplied to the PLOT procedure
;   can also be supplied to PLOTHIST.
;
;       Params:    A vector indicating which statistical results,
;                  (and their sequence or order), will be ppaced into
;                  the tag string variable: STATSTRING
;                  for subsequent use by the program calling stats
;
;                  (Note the user may specify values for PARAMS in any order:
;            0:    N (number of observations in array)
;            1:    Minimum
;            2:    Maximum
;            3:    Median (50%)
;            4:    Arithmetic mean
;            5:    Variance
;            6:    Standard Deviation
;            7:    Mean Absolute Deviation
;            8:    Coefficient of Variation
;            9:    Skewness
;           10:    Kurtosis
;       Decimals:  Number of desired decimal places in tag STATSTRING
;                  (Does not influence format of other structure tags)

;
; OUTPUTS:
;       Displays a bar histogram plot in the graphics window,
;       and a Cumulative % line plot
;
; NOTES:
;       IDL HISTOGRAM function assigns a number to a histogram bin if
;       the number is GREATER THAN OR EQUAL TO the lower boundary of the bin
;
;       The default for frequency labels on histogram bars is to label the
;       extremes and the peak frequency.  This is done because it is often
;       difficult to see the plot (bar) of the tails of quasi-normal distributions,
;       where the frequencies are very low.
;       Use the keyword LAB_NONE to prevent labeling histogram bars
;
; MODIFICATION HISTORY:
; Written by J.E. O'Reilly July 6,1996
;   August 9,1996  J.O'R Default is to plot cumulative, plot stats
;   January 12,1997 J.O'R Changed stats_pos so that a value of:
;                         stats_pos=[.5,.5] will plot stats in the middle
;                         of the plot window, even when multiple plots per page

;   February 18,1997 J.O'R  Eliminated a call to loadct,0
;   March 21, 1997   J.O'R  Added keywod BAR_CENTER to shift and center the bar over the tick marks
;   April 24, 1997          Added BAR_NONE keyword
;   May 21, 1997            Added  NAME AND RELATED keyword : to place a large title insige the plot area
;   Oct 8, 1997             Added KEYWORD RF  to generate a plot of Relative Frequency
;   Aug 25,1998             Added LAB_LEFT,LAB_CENTER,LAB_RIGHT
;		Aug 18,2005 JOR					Added polyfill to white out behind stats text
;   APR.24,2010,JOR         CHANGED SEVERAL VARIABLES TO FLOAT TO CONSERVE MEMORY
;-
;

; ====================>
; Check if user supplied array
 IF N_PARAMS() LT 1 then begin
  PRINT, 'Try Again ... e.g. histplot, array, [ xhist, yhist , BINSIZE=,...plot_keywords]'
  RETURN
 ENDIF


; ====================>
; Check keywords
; IF NOT KEYWORD_SET(BINSIZE)       THEN binsize       = 1.0d ELSE binsize = DOUBLE(ABS(binsize))
  IF NOT KEYWORD_SET(BINSIZE)       THEN binsize       = 1.0d ELSE binsize = FLOAT(ABS(binsize))
 
 IF NOT KEYWORD_SET(NAN)           THEN nan           = !VALUES.D_NAN
 IF NOT KEYWORD_SET(YTICKS)        THEN YTICKS=10

 IF NOT KEYWORD_SET(bar_color)     THEN bar_color     = 128
 IF NOT KEYWORD_SET(bar_outline)   THEN bar_outline   = !P.COLOR
 IF NOT KEYWORD_SET(bar_thick)     THEN bar_thick     = !P.THICK

 IF NOT KEYWORD_SET(CUM_COLOR)     THEN CUM_COLOR     = !P.COLOR
 IF NOT KEYWORD_SET(CUM_THICK)     THEN CUM_THICK     = !P.THICK
 IF NOT KEYWORD_SET(CUM_LINESTYLE) THEN CUM_LINESTYLE = !P.LINESTYLE
 IF NOT KEYWORD_SET(CUM_CHARSIZE) THEN CUM_CHARSIZE = !P.CHARSIZE

 IF NOT KEYWORD_SET(lab_room) OR N_ELEMENTS(lab_room) GT 1 THEN lab_room = 0.04d

 IF NOT KEYWORD_SET(lab_color)     THEN lab_color     = !P.COLOR
 IF NOT KEYWORD_SET(lab_charsize)  THEN lab_charsize  = 0.85
 IF NOT KEYWORD_SET(LAB_ABOVE)     THEN LAB_ABOVE     = 0.1d

 IF NOT KEYWORD_SET(stats_color)   THEN stats_color     = !P.COLOR
 IF NOT KEYWORD_SET(stats_charsize) THEN stats_charsize  = 0.85
 IF N_ELEMENTS(STATS_BOX_COLOR) EQ 0 THEN STATS_BOX_COLOR = !P.BACKGROUND




 IF NOT KEYWORD_SET(name_COLOR)     THEN name_color     = !P.COLOR
 IF NOT KEYWORD_SET(name_charsize)  THEN name_charsize  = 1.0
 IF NOT KEYWORD_SET(name_pos)       THEN name_pos       = [.8,.9]
 IF NOT KEYWORD_SET(name_align)     THEN name_align     = 0

 IF NOT KEYWORD_SET(GRIDS_COLOR) THEN GRIDS_COLOR=!P.COLOR
 IF NOT KEYWORD_SET(GRIDS_LINESTYLE) THEN GRIDS_LINESTYLE = !P.LINESTYLE
 IF NOT KEYWORD_SET(GRIDS_THICK) THEN GRIDS_THICK = !P.THICK

; ====================>
; Generate room for secondary y-axis (right side) for the Cumulative % line
  IF NOT KEYWORD_SET(CUM_NONE) THEN BEGIN
    XMARGIN=!X.MARGIN
    XMARGIN[1] = XMARGIN[0]
  ENDIF ELSE BEGIN
    XMARGIN=!X.MARGIN
  ENDELSE


; ====================>
; Determine the min and max of array

  IF NOT KEYWORD_SET(MIN) THEN BEGIN
    min = MIN(array)
;   Find the lowest increment just below min
    min = (FLOOR(min/binsize))*binsize
  ENDIF

  IF NOT KEYWORD_SET(MAX) THEN BEGIN
    max = MAX(array)
;   Find the highest increment just above max
    max = (CEIL(max/binsize))*binsize
  ENDIF
; ====================>
; Create the yhist array using HISTOGRAM
; The minimum value and maximum value are returned in
; variables omin and omax

  yhist = HISTOGRAM(array,BINSIZE=binsize,$
                    MIN=min,MAX=max, /NAN,$
                    omin=omin,omax=omax,$
                    REVERSE_INDICES=reverse_indices)

  n_bins= LONG(N_ELEMENTS(yhist))
  IF yhist(n_bins-1) EQ 0 THEN BEGIN
    yhist=yhist(0:n_bins-2)
    n_bins = n_bins-1
  ENDIF


  IF KEYWORD_SET(RF) THEN YHIST= YHIST/(DOUBLE(MAX(YHIST)))  ; Relative Frequency ... all values are normalized by highest value

;  half_bin= 0.5d * binsize
    HALF_BIN= FLOAT(0.5 * BINSIZE)
  

; ===> Create the xhist array
  xhist = LINDGEN(n_bins)*binsize + OMIN

; ===> Determine xrange for the plot
  xrange = [xhist[0],(xhist(n_bins-1)+binsize)]


; ===> Shift xhist to the middle of the histogram interval (binsize)
   IF NOT KEYWORD_SET(BAR_CENTER) THEN xhist = xhist+half_bin

; ===> Create variables for left and right sides of histogram bars
  xleft  = xhist - half_bin
  xright = xhist + half_bin


; ===> Compute yrange (Includes lab_room) for labeling bars with frequency)
  IF KEYWORD_SET(YTICKS) EQ 0 OR N_ELEMENTS(YTICKS) GT 1 THEN BEGIN
    yticks = 10
  ENDIF

; ===> Adjust yrange to give some room for labels above the tallest histogram bar
  yrange = max(yhist)*(1.0d + lab_room)

; ===>
; Frequency values should be whole numbers
; Make yrange[0] = 0 frequency
; Make yrange[1] = whole number which is evenly
; divisible by the number of yticks
  yrange = [0,CEIL(yrange/yticks)*yticks]

  IF KEYWORD_SET(RF) THEN BEGIN
    YRANGE=[0,1]
    YTITLE='Relative Frequency'
  ENDIF ELSE BEGIN
    YTITLE = 'Frequency'
  ENDELSE


; ===> Define Plot window but do not plot any data yet
  IF KEYWORD_SET(QUIET) THEN GOTO, SKIP_HISTO
  PLOT,/NODATA, xhist,[yhist],$
        XRANGE=XRANGE,YRANGE=YRANGE,$
        XSTYLE=1,YSTYLE=1,$
        YTICKS=YTICKS,$
        XMARGIN=XMARGIN,$
 ;        XTICKLEN=  0.02 ,$
        XTHICK = 2,YTHICK=2,$
        XMINOR=1,YMINOR=1,$
 ;       XGRIDSTYLE=1,YGRIDSTYLE=1,$
        TITLE='Histogram',XTITLE='Data',YTITLE=ytitle,$
        XTICK_GET=_XTICK_GET,$
        YTICK_GET=_YTICK_GET,$
         _EXTRA = _extra



;	IF KEYWORD_SET(GRIDS_BEHIND) THEN BEGIN
		IF NOT KEYWORD_SET(GRIDS_NONE) THEN  GRIDS,X=_XTICK_GET,Y=_YTICK_GET,COLOR=GRIDS_COLOR,LINESTYLE=GRIDS_LINESTYLE,THICK=GRIDS_THICK
;	ENDIF



; ===> Draw the Histogram Bars and Draw the Outline around each Bar
  IF NOT KEYWORD_SET(BAR_NONE) THEN BEGIN
;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
  	FOR i =0L,n_bins-1 DO BEGIN
    	POLYFILL,/DATA,	[xleft(i),xleft(i),xright(i),xright(i),xleft(i)],$
             				[0,       yhist(i),yhist(i) ,       0,        0] ,$
             		COLOR=bar_color
     	PLOTS, /DATA,[xleft(i),xleft(i),xright(i),xright(i),xleft(i)],$
              	[0,       yhist(i),yhist(i)    ,           0,       0],$
              	COLOR=bar_outline,THICK=bar_thick
  	ENDFOR
  ENDIF




; ===> Redraw horizontal lines (gridlines) across histogram bars
; (Visual references to the y-axis which are needed to judge
;  the height of the cumulative % line at any point)

  IF NOT KEYWORD_SET(bar_opaque) THEN BEGIN
  FOR i = 0L,N_ELEMENTS(_YTICK_GET)-1 DO BEGIN
       PLOTS,!X.CRANGE,[_YTICK_GET(i),_YTICK_GET(i)],LINESTYLE=1
  ENDFOR
  ENDIF

; ===> Label the Histogram Bars with the frequency number
  IF NOT KEYWORD_SET(LAB_NONE) THEN BEGIN
    XYZ = ABS(CONVERT_COORD(!D.X_CH_SIZE,!D.Y_CH_SIZE,/DEVICE,/TO_DATA))

    IF N_ELEMENTS(lab_left) EQ 1 THEN BEGIN
      lower = 0 > (lab_left-1L) < (n_bins-1L)
      XYOUTS,XHIST(0:lower),YHIST(0:lower)+lab_above*XYZ[1],STRTRIM(YHIST(0:lower),2),ALIGN=0.5,/DATA,COLOR=lab_color,CHARSIZE=lab_charsize
    ENDIF
    IF N_ELEMENTS(lab_peak) EQ 1 THEN BEGIN
       peak = WHERE(yhist EQ MAX(yhist))
       peak = peak[0]

       XYOUTS,XHIST(peak),YHIST(peak)+lab_above*XYZ[1],STRTRIM(YHIST(peak),2),ALIGN=0.5,/DATA,COLOR=lab_color,CHARSIZE=lab_charsize
    ENDIF
    IF N_ELEMENTS(lab_right) EQ 1 THEN BEGIN
      upper = 0 > (n_bins-lab_right) < (n_bins-1L)
      XYOUTS,XHIST(upper:*),YHIST(upper:*)+lab_above*XYZ[1],STRTRIM(YHIST(upper:*),2),ALIGN=0.5,/DATA,COLOR=lab_color,CHARSIZE=lab_charsize
    ENDIF

    IF N_ELEMENTS(lab_bars) EQ 1 THEN BEGIN
      XYOUTS,XHIST(*),YHIST+lab_above*XYZ[1],STRTRIM(YHIST,2),ALIGN=0.5,/DATA,COLOR=lab_color,CHARSIZE=lab_charsize
    ENDIF
  ENDIF

  tot_yhist = TOTAL(yhist)
  cum_yhist = [0.0,(CUMULATE(yhist)/(tot_yhist)) *MAX(_ytick_get)]

  IF  NOT KEYWORD_SET(CUM_NONE) THEN BEGIN
    IF NOT KEYWORD_SET(cum_fmt) THEN cum_fmt='(G0)'
    IF N_ELEMENTS(cum_title) NE 1 THEN cum_title='Cumulative %'
    ytickname=STRTRIM(STRING(_ytick_get*100.0/MAX(_ytick_get),FORMAT=cum_fmt),2)
    AXIS,YAXIS=1,ystyle=1,yticks=N_ELEMENTS(_ytick_get)-1,$
         ytickv=_ytick_get,ytickname= ytickname,ytitle=cum_title,CHARSIZE=CUM_CHARSIZE
    OPLOT,[xleft,xrange[1]],cum_yhist,COLOR=cum_color,THICK=cum_thick,LINESTYLE=cum_linestyle
  ENDIF

; ===> If keyword stats_NONE IS OFF then add statistics to plot
  IF  NOT KEYWORD_SET(STATS_NONE) THEN BEGIN
    _pos = [!X.S[1]*!X.CRANGE + !X.S[0],$
            !Y.S[1]*!Y.CRANGE + !Y.S[0]]
    IF NOT KEYWORD_SET(stats_pos) OR N_ELEMENTS(stats_pos) NE 2 THEN $
      STATS_POS = [0.01,.99]
    X_POS= (_POS[1]-_POS[0])*STATS_POS[0]+ _POS[0]
    Y_POS= (_POS(3)-_POS(2))*STATS_POS[1]+ _POS(2)
    _STATS=STATS(ARRAY,PARAMS=PARAMS,DECIMALS=DECIMALS,QUIET=quiet)

;		===> Determine width of statstring
	  XYOUTS,/NORM,-10,-10,_STATS.STATSTRING,CHARSIZE=STATS_CHARSIZE,WIDTH=CHARWIDTH
	  TXT=STRSPLIT(_STATS.STATSTRING,'!')

		CHAR_XSIZE = 	STATS_CHARSIZE*!D.X_CH_SIZE/FLOAT(!D.X_SIZE) ; Normal units
		CHAR_YSIZE =  STATS_CHARSIZE*!D.Y_CH_SIZE/FLOAT(!D.Y_SIZE) ; Normal units

	 	KERN = CHAR_YSIZE*0.04
	 	CHAR_YSIZE = CHAR_YSIZE + KERN
	 	HEIGHT = (N_ELEMENTS(TXT))*CHAR_YSIZE
	  offset = 0.001
		left 		= X_POS - offset
	  right 	= X_POS + CHARWIDTH + offset
	  bottom 	= y_pos - HEIGHT - offset
	  top 		= y_pos + offset
	  POLYFILL, /norm, [left,right,right,left],[bottom,bottom,top,top] ,color=STATS_BOX_COLOR
    XYOUTS,X_POS,Y_POS,_stats.statstring,/NORMAL,COLOR=STATS_COLOR,CHARSIZE=stats_charsize
  ENDIF


  IF  KEYWORD_SET(NAME_title) THEN BEGIN
     _pos = [!X.S[1]*!X.CRANGE + !X.S[0],$
            !Y.S[1]*!Y.CRANGE + !Y.S[0]]
    IF NOT KEYWORD_SET(name_pos) OR N_ELEMENTS(name_pos) NE 2 THEN $
      name_POS = [0.01,.96]
    X_POS= (_POS[1]-_POS[0])*name_POS[0]+ _POS[0]
    Y_POS= (_POS(3)-_POS(2))*name_POS[1]+ _POS(2)
    XYOUTS,X_POS,Y_POS,name_title,/NORMAL,COLOR=NAME_COLOR,CHARSIZE=name_charsize,align=name_align
  ENDIF
 SKIP_HISTO:


 END; #####################  End of Routine ################################
