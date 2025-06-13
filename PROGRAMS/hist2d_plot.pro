; $ID:	HIST2D_PLOT.PRO,	2020-07-08-15,	USER-KJWH	$

; ELIMINATE LOGLOG
; ALLOW NUM FREQ AS WELL AS FREQ PERCENT
;	DEMO DO BIVARIATE
; REDO NICE_RANGE NOT USING DECADES IF LOG OF DATA DESIRED

;	SHOW DEFAULT OF PLACING THE COLOR BAR WHERE THE TITLE GOES !!

	PRO HIST2D_PLOT, X,	Y, $

			MIN_X=MIN_X,	MAX_X=MAX_X,	BIN_X=BIN_X,$
			MIN_Y=MIN_Y,	MAX_Y=MAX_Y,	BIN_Y=BIN_Y,$

			PERCENT=PERCENT,	LOG=LOG,	SMO=smo, $

 			TITLE=title,	PAL=pal,$

      ISOTROPIC=isotropic, $

      XTITLE=xtitle,	X_COLOR=x_color,	X_THICK=x_thick,$
      YTITLE=ytitle, 	Y_COLOR=y_color,	Y_THICK=y_thick, $
      XLABEL=XLABEL,  YLABEL=YLABEL, $

			VERTICAL= vertical,     HORIZONTAL= horizontal, $
			BAR_NONE=BAR_none,      BAR_POS=BAR_pos,         BAR_TXT=BAR_txt,          BAR_COLOR=BAR_color,            BAR_CHARSIZE=BAR_charsize,$


     	ZERO_COLOR=zero_color,	BKG_COLOR=bkg_color,	MIN_COLOR=min_color,	MAX_COLOR=MAX_COLOR, $

      LAB_NONE=LAB_none,      LAB_POS=LAB_pos,         LAB_TXT=LAB_txt,          LAB_COLOR=LAB_color,            LAB_CHARSIZE=LAB_charsize,  LAB_ALIGN=lab_align,$
      REG_NONE=reg_none,      REG_COLOR=reg_color,     REG_THICK=reg_thick,      REG_LINESTYLE=reg_linestyle,    REG_TYPE=REG_TYPE,$
      MEAN_NONE=MEAN_none,    MEAN_COLOR=MEAN_color,   MEAN_THICK=MEAN_thick,    MEAN_PSYM=mean_psym,            MEAN_SYMSIZE=mean_symsize,$
      CURVE_NONE=CURVE_none,  CURVE_X=curve_x,         CURVE_Y=curve_y,          CURVE_COLOR=CURVE_color,        CURVE_THICK=CURVE_thick,          CURVE_LINESTYLE=CURVE_linestyle,$
 			ONE_NONE=one_none,      ONE_COLOR=one_color,     ONE_THICK=one_thick,      ONE_LINESTYLE=one_linestyle,$
 			GRID_NONE=GRID_none,    GRID_X=GRID_X,           GRID_Y=GRID_Y,            GRID_COLOR=GRID_color,					 GRID_THICK=GRID_thick,            GRID_LINESTYLE=GRID_linestyle,$
			CROSS_NONE=CROSS_none,  CROSS_X=CROSS_x,         CROSS_Y=CROSS_y,          CROSS_COLOR=CROSS_color,        CROSS_THICK=CROSS_thick,  CROSS_LINESTYLE=CROSS_linestyle,$

			FRAME_NONE=FRAME_none,  FRAME_COLOR=FRAME_color, FRAME_THICK=FRAME_thick,$

			STATS_NONE=stats_none,  STATS_POS=stats_pos,     STATS_THICK=stats_thick,  STATS_COLOR=stats_color,        STATS_CHARSIZE=stats_charsize,			STATS_BRIEF=stats_brief,$
      PARAMS=params,          DECIMALS=decimals,       FAST=fast,$   ; Passed to STATS2.pro

      NO_TIMESTAMP=no_timestamp, _EXTRA=_extra

;+
; NAME:
;       HIST2D_PLOT
;
; PURPOSE:
;       This PROGRAM Plots a 2-Dimensional Frequency Density Plot of two variables,
;				the Linear  Regression Line, a Color Bar, and Regression Statistics
;
; CATEGORY:
;       Statistics.
;
; CALLING SEQUENCE:
;       Result = HIST2D_PLOT(X,Y)
;
; INPUTS:
;     	X:  X data array
;   		Y:  Y data array
;
;	OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; 		BIN_X,BIN_Y,MAX_X,MAX_Y,MIN_X,MIN_Y (SEE IDL HELP FOR HIST2D ROUTINE)
;
; 		BIN_X: The size of each bin in the X direction (column width). IF this keyword is not specified, the size is set to 1.
; 		BIN_Y: The size of each bin in the Y direction (row height). 	If this keyword is not specified, the size is set to 1.
; 		MIN_X: The minimum X value to consider. If this keyword is not specified, then it is set to MIN(X).
; 		MAX_X: The maximum X value to consider. If this keyword is not specified, then it is set to MAX(X).
; 		MIN_Y: The minimum Y value to consider. If this keyword is not specified, then it is set to MIN(Y).
; 		MAX_Y: The maximum Y value to consider. If this keyword is not specified, then it is set to MAX(Y).
;
; 		ISOTROPIC:  Set this keyword to force the scaling of the X and Y axes to be equal (See IDL PLOT Keywords).
;
; 		SCALE: 	 Enlarge the 2D histogram array from HIST_2D by the scale factor using CONGRID .
;

; 		PAL:      			Name of IDL palette, e.g. 'PAL_SW3' to use
;
; 		XTITLE:     	Title for xaxis
; 		YTITLE:     	Title for yaxis
; 		X_COLOR:    	Color for xaxis
; 		Y_COLOR:    	Color for yaxis
; 		X_THICK:    	Thickness for xaxis
; 		Y_THICK:    	Thickness for yaxis
;
; 		LABEL_POS:  	X,Y POSITION FOR LABEL
; 		LABEL:      	Annotation text to be placed in lower right corner of plot
; 		LAB_COLOR:  	Color for label
; 		LAB_CHARSIZE: Charsize for label
;
; 		ZERO_COLOR:   Color to substitute for zero frequencies in the 2D-Histogram Image
; 		BKG_COLOR:    Color for the page background
;			MIN_COLOR			See cmin in CBAR
; 		MAX_COLOR:    See cmax in CBAR
;
;		 	REG_NONE:   		Do not do Regression
; 		REG_COLOR:    	Color for Regression Line     (can be array)
; 		REG_THICK:  		Thickness for Regression Line (can be array)
; 		REG_LINESTYLE:  Linestyle for Regression Line
;
; 		STATS_COLOR:  	Color for Statistical text to be plotted
; 		STATS_CHARSIZE: Size for Stats text
; 		DECIMALS:   		Number of Decimal Places for Stats text
; 		PARAMS:     		The Statistical Parameters to be plotted
; 		FAST:     			Use to speed up regression for very large x,y arrays

; 		ONE_NONE:   		Do not draw a one-2-one line
; 		ONE_COLOR:    	Color for one-20one line  (can be array)
; 		ONE_THICK:    	Thick for one-20one line  (can be array)
; 		ONE_LINESTYLE:  Linestyle for one-2-one line
;

;
; 		PAL:      Palette Name, e.g. 'PAL_SW3'
;

;


;
; _EXTRA: Extra keywords for the initial PLOT routine:
;
;	OUTPUTS:
;
;	OPTIONAL OUTPUTS:
;
;
;	COMMON BLOCKS:
;
;	SIDE EFFECTS:
;
; EXAMPLES:
;		X=RANDOMN(SEED,256L*256) & Y=RANDOMN(SEED,256L*256) & WINDOW,0,XSIZE=512,YSIZE=512 & HIST2D_PLOT,X,Y
;
;
;
; PROCEDURE:
;
; RESTRICTIONS:
;		NOTE that HIST_2DJ  is called NOT IDL's HIST_2D (see explanation in HIST_2DJ)
;
;		Do not provide XSTYLE AND YSTYLE AS _EXTRA KEYWORDS TO THIS PROGRAM (for proper alignment of image and plot axes
;		this program Plots using XSTYLE=5, YSTYLE=5).
;
;
; NOTES:
;					IF program jams up in CBAR ('AXIS: Data coordinate system not established.' , usually because you are trying to place
;					the COLOR BAR below the plot x axis, then give some room in the y dimension (!Y.OMARGIN=[10,2])
;
;					DO NOT USE AN INTERPOLATION VALUE OF 7 (THERE IS A PROBLEM WITH CONGRID !! JOR
;					ORIG IMAGE FROM HIST2D = 13 AND INTERPOLATE = 7 & 13 results in a problem ?
;
; MODIFICATION HISTORY:
;		Written Feb 6,2001 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;
;   Program logic for scaling images is taken from IMG_CONT.PRO (RSI).
;
; 	Oct 1,2001 Modified MIN_X,MAX_X,MIN_Y,MAX_Y inputs to HIST_2D TO account for the 1/half bin offset
;            between data locations and the image cells returned by HIST_2D.
; 	Aug 6, 2004 jor td make colorbar smaller,TAKE OUT MULTI LOGIC
;		Nov 2006 JOR Now using CONGRID instead of REBIN
;-
; *************************************************************************
  ROUTINE_NAME='HIST2D_PLOT'


;	************************
;	*** D E F A U L T S  ***
;	************************

;	===> Inputs to IDL HIST_2D Routine:

  NICE_X = NICE_RANGE(X)
  NICE_Y = NICE_RANGE(Y)

  IF N_ELEMENTS(MIN_X) NE 1 THEN MIN_X = NICE_X[0]
  IF N_ELEMENTS(MAX_X) NE 1 THEN MAX_X = NICE_X[1]
  IF N_ELEMENTS(MIN_Y) NE 1 THEN MIN_Y = NICE_Y[0]
  IF N_ELEMENTS(MAX_Y) NE 1 THEN MAX_Y = NICE_Y[1]

;	===> Default is to partition the data range (or nice_range) into 50 bins
  IF N_ELEMENTS(BIN_X) NE 1 THEN BIN_X = ABS((MAX_X-MIN_X)/50.)
  IF N_ELEMENTS(BIN_Y) NE 1 THEN BIN_Y = ABS((MAX_Y-MIN_Y)/50.)


;	===> Default is not to interpolate and no enlargement (interpolation) of the array generated by IDL's HIST_2D
  IF KEYWORD_SET(SMO) THEN BEGIN
;		===> Resolution is equal to the numerical value of SMO (e.g. 2,4,8,16, etc)
  	RESOLUTION = 1 > SMO
  ENDIF ELSE BEGIN
  	RESOLUTION = 1
  ENDELSE

;	===> Default Axes are bottom & left
  IF N_ELEMENTS(axes) NE 4 THEN axes=[1,1,0,0]

;	===> Title, and axes titles
  IF N_ELEMENTS(TITLE)  NE 1 THEN TITLE		=	'Joint Frequency Distribution'
  IF N_ELEMENTS(XTITLE) NE 1 THEN XTITLE 	= 'X'
  IF N_ELEMENTS(YTITLE) NE 1 THEN YTITLE 	= 'Y'

;	===> Axes color, thick
  IF N_ELEMENTS(X_COLOR) NE 1 THEN X_COLOR = 0
  IF N_ELEMENTS(Y_COLOR) NE 1 THEN Y_COLOR = 0
  IF N_ELEMENTS(X_THICK) NE 1 THEN X_THICK = !P.THICK
  IF N_ELEMENTS(Y_THICK) NE 1 THEN Y_THICK = !P.THICK

;	===> Label color and character size
  IF N_ELEMENTS(LAB_COLOR) 		NE 1 THEN LAB_COLOR = 0
  IF N_ELEMENTS(LAB_CHARSIZE) NE 1 THEN LAB_CHARSIZE = 1.5

;	===> Colors for zero frequencies, background, max and min color for resulting byte array
  IF N_ELEMENTS(ZERO_COLOR) NE 1 THEN ZERO_COLOR = 255
  IF N_ELEMENTS(BKG_COLOR) 	NE 1 THEN BKG_COLOR = 255
  IF N_ELEMENTS(MAX_COLOR) 	NE 1 THEN MAX_COLOR = 250
  IF N_ELEMENTS(MIN_COLOR) 	NE 1 THEN MIN_COLOR = 1

;	===> Position coordinates for Stats output, stats color and character size
	IF N_ELEMENTS(stats_pos) 			NE 2 THEN STATS_POS = [0.02,0.98]
  IF N_ELEMENTS(STATS_COLOR)    NE 1 THEN STATS_COLOR = 0
  IF N_ELEMENTS(STATS_CHARSIZE) NE 1 THEN STATS_CHARSIZE = 1

;	===> Number of decimal places to show for statistical results
  IF N_ELEMENTS(DECIMALS)       NE 1 THEN DECIMALS = 3
  IF N_ELEMENTS(FAST)           NE 1 THEN FAST = 1

;	===> Codes for Statistical Parameters to show (see STATS2)
  IF N_ELEMENTS(PARAMS)         LT 1 THEN BEGIN
  	PARAMS = [1,2,3,4,5,6,8,10,11]
  	IF FAST EQ 1 THEN PARAMS = [1,2,3,4,8,10]
	ENDIF


;	===> Default Regression is Reduced Major Axis (Type II)
	IF N_ELEMENTS(REG_TYPE) EQ 0 THEN _REG_TYPE = 4 ELSE _REG_TYPE = REG_TYPE

;	===> Statistical Linear Regression line color, thick, linestyle
  IF N_ELEMENTS(REG_COLOR)     NE 2 THEN REG_COLOR = [255,0]
  IF N_ELEMENTS(REG_THICK)     NE 2 THEN REG_THICK = [3,1]
  IF N_ELEMENTS(REG_LINESTYLE) NE 1 THEN REG_LINESTYLE = 0

  IF N_ELEMENTS(CURVE_COLOR)     NE 2 THEN CURVE_COLOR = [255,0]
  IF N_ELEMENTS(CURVE_THICK)     NE 2 THEN CURVE_THICK = [3,1]
  IF N_ELEMENTS(CURVE_LINESTYLE) NE 1 THEN CURVE_LINESTYLE = 0

  IF N_ELEMENTS(ONE_COLOR)     LT 1 THEN ONE_COLOR = [255,0]
  IF N_ELEMENTS(ONE_THICK)     LT 1 THEN ONE_THICK = [3,1]
  IF N_ELEMENTS(ONE_LINESTYLE) NE 1 THEN ONE_LINESTYLE = 0


;	===> Grid color, thick and linestyle
  IF N_ELEMENTS(GRID_COLOR)     LT 1 THEN GRID_COLOR = 0
  IF N_ELEMENTS(GRID_THICK)     LT 1 THEN GRID_THICK = 2
  IF N_ELEMENTS(GRID_LINESTYLE) NE 1 THEN GRID_LINESTYLE = 1

;	===> Mean xy color, thick, psym and symsize
	IF N_ELEMENTS(MEAN_COLOR)     LT 1 THEN MEAN_COLOR = [0]
  IF N_ELEMENTS(MEAN_THICK)     LT 1 THEN MEAN_THICK = [2]
  IF N_ELEMENTS(MEAN_PSYM) 			NE 1 THEN MEAN_PSYM = 1
  IF N_ELEMENTS(MEAN_SYMSIZE) 	NE 1 THEN MEAN_SYMSIZE = 1

;	===> Color Bar
	IF N_ELEMENTS(BAR_COLOR) NE 1 THEN BAR_color = 0
	IF N_ELEMENTS(BAR_CHARSIZE) NE 1 THEN BAR_charsize = 1.0

	IF N_ELEMENTS(HORIZONTAL) NE 1 AND N_ELEMENTS(VERTICAL) NE 1 THEN VERTICAL = 1 ; DEFAULT
	IF N_ELEMENTS(HORIZONTAL) EQ 1 AND N_ELEMENTS(VERTICAL) EQ 1 THEN VERTICAL = 1 ; DEFAULT

	IF N_ELEMENTS(BAR_POS) NE 4 THEN BEGIN
	 	IF KEYWORD_SET(HORIZONTAL) THEN _BAR_POS = [0.10, 0.935,0.9, 0.952]
	 	IF KEYWORD_SET(VERTICAL  ) THEN _BAR_POS = [0.935, 0.10, 0.952, 0.9]

IF KEYWORD_SET(HORIZONTAL) THEN _BAR_POS = [0.10, 0.935,0.9, 0.952]
IF KEYWORD_SET(VERTICAL  ) THEN _BAR_POS = [1.005, 0.0, 1.018, 1.00]

  ENDIF ELSE _BAR_POS = BAR_POS

	IF N_ELEMENTS(BAR_TXT) NE 1 THEN BEGIN
		IF KEYWORD_SET(HORIZONTAL) THEN BAR_TXT='Frequency' ELSE BAR_TXT = 'Freq.'
		IF KEYWORD_SET(PERCENT) THEN BAR_TXT = BAR_TXT+' %'
	ENDIF

;	===> Frame
	IF N_ELEMENTS(FRAME_COLOR)    NE 1 THEN FRAME_COLOR = 0
  IF N_ELEMENTS(FRAME_THICK)    NE 1 THEN FRAME_THICK = 2

;	===> CROSS
	IF N_ELEMENTS(CROSS_COLOR)     LT 1 THEN CROSS_COLOR = [0]
  IF N_ELEMENTS(CROSS_THICK)     LT 1 THEN CROSS_THICK = [2]
  IF N_ELEMENTS(CROSS_LINESTYLE) NE 1 THEN CROSS_LINESTYLE = 1


;	===> Palette
  IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_SW3'

; ===> X and Y label
	IF N_ELEMENTS(XLABEL) EQ 0 THEN XLABEL =''
	IF N_ELEMENTS(YLABEL) EQ 0 THEN YLABEL =''

	XTITLE=XTITLE+'  '+ XLABEL
	YTITLE=YTITLE+'  '+ YLABEL



;	***********************************************************************************
; *** H I S T _ 2 D     Construct an Image of the joint occurance of x,y data 		***
;	***********************************************************************************
;	===> Use HIST_2DJ (use O'Reilly version which does not add an extra array element if it is not needed)
	Image = HIST_2DJ(X,Y,MIN1=MIN_X,MAX1=MAX_X,BIN1=BIN_X, MIN2=MIN_Y,MAX2=MAX_Y,BIN2=BIN_Y)

; ===> Get the resulting image array size in pixels
  SZ_IMAGE = SIZE(IMAGE,/STRUCT)
  PX = SZ_IMAGE.DIMENSIONS[0]
  PY = SZ_IMAGE.DIMENSIONS[1]


;	===> Make FIMAGE, a floating-point image from Image
;	===> IF /PERCENT THEN Calculate the Relative Percent Frequency for each element in FIMAGE
	IF KEYWORD_SET(PERCENT) THEN FIMAGE = 100.0*IMAGE/TOTAL(IMAGE) ELSE FIMAGE = FLOAT(IMAGE) ;


;	***********************************************************************
;	*** E N L A R G E   A N D    S M O O T H     T H E   F I M A G E    ***
;	***********************************************************************
;	===> Enlarge FIMAGE using CONGRID, nearest neighbor resampling (INTERP=0) and CENTER keyword
 	FIMAGE 	= CONGRID(FIMAGE,	PX*RESOLUTION, PY*RESOLUTION,/CENTER,INTERP=0)

;	===> Find the non-zero frequencies
	OK_FIMAGE		=	WHERE(FINITE(FIMAGE) AND FIMAGE GT 0, COUNT_FIMAGE,NCOMPLEMENT=N_ZERO_FREQUENCY,COMPLEMENT=OK_ZERO_FREQUENCY)

;	===> Log10-Transform IF /LOG
	IF KEYWORD_SET(LOG) THEN BEGIN
 		IF COUNT_FIMAGE GE 1 THEN FIMAGE(OK_FIMAGE) = ALOG10(FIMAGE(OK_FIMAGE))
	ENDIF

;	===> Compute the min max of FIMAGE
 	MIN_FIMAGE = MIN(FIMAGE(OK_FIMAGE))
	MAX_FIMAGE = MAX(FIMAGE(OK_FIMAGE))

;	===> Set any zero frequencies to Infinity
	IF N_ZERO_FREQUENCY GE 1 THEN FIMAGE(OK_ZERO_FREQUENCY) = MISSINGS(FIMAGE)

;	===> Smooth, ignoring missing value codes (infinity)
	FIMAGE = SMOOTH( FIMAGE, RESOLUTION,/EDGE_TRUNCATE, MISSING=MISSINGS(FIMAGE), /NAN )


;	**************************************************************************
;	***  S C A L E   P R O B A B I L I T Y    A R R A Y     T O  B Y T E   ***
;	**************************************************************************
;	===> Initialize a binary image
	BIMAGE = BYTE(FIMAGE) & BIMAGE(*,*) = 0b

;	===> Use SCALE to construct a binary image of the probability values
;			 scaling the Probability Values between MIN_FIMAGE and MAX_FIMAGE to the color range ([MIN_COLOR,MAX_COLOR]
	BIMAGE(OK_FIMAGE) =  SCALE(FIMAGE(OK_FIMAGE),[MIN_COLOR,MAX_COLOR],MIN=MIN_FIMAGE,MAX=MAX_FIMAGE )

;	===> Replace the Zero Frequency pixels in the BIMAGE with the ZERO_COLOR
  IF N_ZERO_FREQUENCY GE 1 THEN BIMAGE(OK_ZERO_FREQUENCY) = ZERO_COLOR


;	===> Load the palette and erase to the background color
  CALL_PROCEDURE,PAL,R,G,B
  ERASE,BKG_COLOR


; ********************************************
; ****** P L O T  ****************************
; ********************************************
  PLOT, X,Y,/nodata, xstyle=9, ystyle = 9,$
	  XTICK_GET=xtick_get,YTICK_GET=ytick_get,$
	  XRANGE=[MIN_X,MAX_X],YRANGE=[MIN_Y,MAX_Y],TITLE=TITLE,XTITLE=XTITLE,YTITLE=YTITLE,$
	  XTICKLEN= -0.02, YTICKLEN= -0.02,$
	  XTICKFORMAT='(G0)',YTICKFORMAT='(G0)',$
	  ISOTROPIC=isotropic, _EXTRA= _extra


; ********************************************
; ****** Scale HIST_2D IMAGE TO PLOT AREA  ***
; ********************************************
;	===> Dimensions of hist2d image
 	sz_image = SIZE(FIMAGE,/STRUCT)
  IF sz_image.N_DIMENSIONS  NE 2  THEN MESSAGE, 'Image is not 2D'
  PX = SZ_IMAGE.DIMENSIONS[0]
  PY = SZ_IMAGE.DIMENSIONS[1]

; ===> Get size of window in device units
  window_x = !x.window * !d.x_vsize
  window_y = !y.window * !d.y_vsize

  px_window = window_x[1]-window_x[0]   ;Size in x in device units
  py_window = window_y[1]-window_y[0]   ;Size in Y in device units

  px = FLOAT(PX)     ;Image sizes
  py = FLOAT(PY)

  image_aspect 				= px / py    ;Image aspect ratio
  window_aspect 			= px_window / py_window    ;Window aspect ratio
  image_window_ratio = image_aspect / window_aspect     ;Ratio of aspect ratios

 	IMAGE_OFFSET_X = 0
 	IMAGE_OFFSET_Y = 0



;	****************************************************************************************
; *** D I S P L A Y   I M A G E   T O   G R A P H I C    O U T P U T     D E V I C E   ***
;	****************************************************************************************
;	POSTSCRIPT ?
  IF (!d.flags and 1) NE 0 THEN BEGIN     				; Scalable pixels?
		IF KEYWORD_SET(ISOTROPIC) THEN BEGIN       		;	Retain aspect ratio?;
        IF image_window_ratio GE 1.0 THEN BEGIN
        	py_window = py_window / image_window_ratio
          IMAGE_OFFSET_Y =  py_window	* (image_window_ratio-1.0)*0.5
       	ENDIF ELSE BEGIN
       		px_window = px_window * image_window_ratio ;Adjust window size
 					IMAGE_OFFSET_X =  px_window	* (1.0-image_window_ratio)*0.5
       	ENDELSE
    ENDIF

    TV, BImage,window_x[0]+IMAGE_OFFSET_X, window_y[0]+IMAGE_OFFSET_Y,xsize = px_window, ysize = py_window, /device

  ENDIF ELSE BEGIN                  							;Not scalable pixels (e.g. not postscript)

    IF keyword_set(ISOTROPIC) THEN BEGIN
      IF image_window_ratio ge 1.0 THEN py_window = py_window / image_window_ratio ELSE px_window = px_window * image_window_ratio
    ENDIF


; 	===> The values -0.5 appear in the following input to POLY_2D to yield correct image placement when using small MAG factors (e.g. 1) JOR
    TV,POLY_2D(BImage,$           ;Have to resample Image
              [[-0.0,0],[px/px_window,0]], [[-0.0,py/py_window],[0,0]],$
;               [[-0.5,0],[px/px_window,0]], [[-0.5,py/py_window],[0,0]],$

              0,px_window,py_window), $   ; 0 = DO NOT WANT TO INTERPOLATE (use nearest neighbor)
              window_x[0],window_y[0]

  ENDELSE     ; IF (!d.flags and 1) NE 0 THEN BEGIN



; *********************
; *****  A X E S  *****
; *********************
; AXES ORDER=	XBOTTOM; YLEFT, XTOP, YRIGHT
;;  IF AXES[0] NE 0 THEN AXIS, XAXIS = 0 ,XSTYLE=1,XTITLE=XTITLE,XTICKLEN= -0.02,COLOR=X_COLOR,XTHICK=X_THICK,XTICKNAME=XTICK_GET,_EXTRA= _extra
;;  IF AXES[1] NE 0 THEN AXIS, YAXIS = 0 ,YSTYLE=1,YTITLE=YTITLE,YTICKLEN= -0.02,COLOR=Y_COLOR,YTHICK=Y_THICK,YTICKNAME=YTICK_GET,_EXTRA= _extra
;;  IF AXES(2) NE 0 THEN AXIS, XAXIS = 1 ,XSTYLE=1,XTITLE=XTITLE,XTICKLEN= -0.02,COLOR=X_COLOR,XTHICK=X_THICK,XTICKNAME=XTICK_GET,_EXTRA= _extra
;;  IF AXES(3) NE 0 THEN AXIS, YAXIS = 1 ,YSTYLE=1,YTITLE=YTITLE,YTICKLEN= -0.02,COLOR=Y_COLOR,YTHICK=Y_THICK,YTICKNAME=YTICK_GET,_EXTRA= _extra


  IF NOT KEYWORD_SET(LOGLOG) THEN BEGIN
   	MIN_X = !X.CRANGE[0]
	  MAX_X = !X.CRANGE[1]
	  MIN_Y = !Y.CRANGE[0]
	  MAX_Y = !Y.CRANGE[1]
  ENDIF ELSE BEGIN
    MIN_X = 10.^MIN_X
    MAX_X = 10.^MAX_X
    MIN_Y = 10.^MIN_Y
    MAX_Y = 10.^MAX_Y
  ENDELSE


; ************************
; *****  G R I D S   *****
; ************************
  IF NOT KEYWORD_SET(GRID_NONE) THEN BEGIN
  IF N_ELEMENTS(GRID_X) EQ 0 THEN _GRID_X = XTICK_GET ELSE _GRID_X = GRID_X
  IF N_ELEMENTS(GRID_Y) EQ 0 THEN _GRID_Y = YTICK_GET ELSE _GRID_Y = GRID_Y
  	GRIDS,XX= _GRID_X, YY= _GRID_Y, THICK=GRID_THICK,COLOR=GRID_COLOR,LINESTYLE=GRID_LINESTYLE
  ENDIF

; *****************************
; *****  M E A N   X,Y    *****
; *****************************
  IF  NOT KEYWORD_SET(MEAN_NONE) THEN BEGIN
    OK=WHERE(FINITE(X) AND FINITE(Y) ,COUNT)
    IF COUNT GE 1 THEN 	PLOTS, MEAN(X[OK]),MEAN(Y[OK]), THICK=MEAN_THICK,COLOR=MEAN_COLOR,PSYM=MEAN_PSYM,SYMSIZE=MEAN_SYMSIZE
  ENDIF

; **********************************
; *****   C R O S S H A I R    *****
; **********************************
  IF NOT KEYWORD_SET(CROSS_NONE) THEN BEGIN
    IF N_ELEMENTS(CROSS) EQ 2 THEN BEGIN
      OPLOT, [MIN_X,MAX_X],[CROSS_Y,CROSS_Y], THICK=CROSS_THICK,COLOR=CROSS_COLOR
      OPLOT, [CROSS_X,CROSS_X],[MIN_Y,MAX_Y], THICK=CROSS_THICK,COLOR=CROSS_COLOR
   ENDIF
  ENDIF

; ************************************
; *****  C U R V E_X, C U R V E_Y  ***
; ************************************
  IF  NOT KEYWORD_SET(CURVE_NONE) THEN BEGIN
    IF N_ELEMENTS(CURVE_X) GE 1 THEN BEGIN
    FOR N=0,N_ELEMENTS(CURVE_COLOR)-1 DO BEGIN
      ACOLOR = CURVE_COLOR(N)
      ATHICK = CURVE_THICK(N)
      OPLOT, CURVE_X,CURVE_Y, THICK=ATHICK,COLOR=ACOLOR
    ENDFOR
   OPLOT, CURVE_X,CURVE_Y,   THICK=1,COLOR=0
   ENDIF
  ENDIF

; ****************************
; *****  O N E 2 O N E   *****
; ****************************
  IF NOT KEYWORD_SET(ONE_NONE) THEN BEGIN
     FOR N=0,N_ELEMENTS(ONE_COLOR)-1 DO BEGIN
      ACOLOR = ONE_COLOR(N)
      ATHICK = ONE_THICK(N)
      OPLOT, [MIN_X,MAX_X], [MIN_X,MAX_X], THICK=ATHICK,COLOR=ACOLOR
    ENDFOR
  ENDIF


; *********************************
; *****   R E G R E S S I O N *****
; *********************************
  IF NOT KEYWORD_SET(REG_NONE) THEN BEGIN

    IF KEYWORD_SET(STATS_BRIEF) THEN _stats_brief = STATS_BRIEF ELSE _stats_brief = 0

    _stats2 = STATS2(X,Y,DECIMALS=decimals,PARAMS=params,FAST=fast,brief=_stats_brief,/quiet)

    SLOPE = _stats2(_REG_TYPE).SLOPE
    INT   = _stats2(_REG_TYPE).INT
    RSQ   = _stats2(_REG_TYPE).RSQ
    FOR N=0,N_ELEMENTS(REG_COLOR)-1 DO BEGIN
      ACOLOR = REG_COLOR(N)
      ATHICK = REG_THICK(N)
      IF NOT KEYWORD_SET(LOGLOG) THEN BEGIN
        OPLOT, [MIN_X,MAX_X],INT+SLOPE*[MIN_X,MAX_X], THICK=ATHICK,COLOR=ACOLOR
      ENDIF ELSE BEGIN
        OPLOT, 10.^[MIN_X,MAX_X], 10.^(INT+ SLOPE*[MIN_X,MAX_X]), THICK=ATHICK,COLOR=ACOLOR
      ENDELSE
    ENDFOR
    OPLOT, [MIN_X,MAX_X], INT + SLOPE*[MIN_X,MAX_X], THICK=1,COLOR=0
 	ENDIF

; ***********************************
; *****   S T A T I S T I C S   *****
; ***********************************
	IF  NOT KEYWORD_SET(stats_none) THEN BEGIN
	 	_stats2 = STATS2(X,Y,DECIMALS=decimals,PARAMS=params,FAST=fast,brief=_stats_brief,/quiet)

		SLOPE = _stats2(_REG_TYPE).SLOPE
		INT   = _stats2(_REG_TYPE).INT
		RSQ   = _stats2(_REG_TYPE).RSQ

	   STATS_TXT = ''
	  FOR i = 0, N_ELEMENTS(_REG_TYPE)-1 DO BEGIN
	    STATS_TXT = STATS_TXT + _stats2(_REG_TYPE(i)).statstring
	  ENDFOR
		P=COORD_2PLOT(STATS_POS[0],STATS_POS[1], /TO_DATA)
;;;;	  XYOUTS,P.X,P.Y,STATS_TXT, COLOR=STATS_COLOR,CHARSIZE=stats_charsize
	  XYOUTS2,P.X,P.Y,STATS_TXT, COLOR=STATS_COLOR,CHARSIZE=stats_charsize,BACKGROUND=ZERO_COLOR
	ENDIF


;	**********************
;	***** F R A M E  *****
;	**********************
 	IF NOT KEYWORD_SET(FRAME_NONE) THEN FRAME, COLOR=FRAME_COLOR,THICK=FRAME_THICK,/PLOT


; *************************
; *****   L A B E L   *****
; *************************
 	IF NOT KEYWORD_SET(LAB_NONE) THEN BEGIN
 		IF N_ELEMENTS(LAB_TXT) GE 1 THEN BEGIN
  		IF N_ELEMENTS(LAB_POS) NE 2 THEN BEGIN
    		LAB_POS = [0.98,0.03]
  		ENDIF
			P=COORD_2PLOT(LAB_POS[0],LAB_POS[1], /TO_DATA)
			IF N_ELEMENTS(LAB_ALIGN) NE 1 THEN LAB_ALIGN=1.1
  		XYOUTS,P.X,P.Y,LAB_TXT,COLOR=LAB_COLOR,CHARSIZE=LAB_CHARSIZE, ALIGN=LAB_ALIGN
  	ENDIF
	ENDIF


; ******************************
; *****  C O L O R B A R   *****
; ******************************
; ===> JHUAPL program CBAR to draw a color bar
	IF NOT KEYWORD_SET(BAR_NONE) THEN BEGIN

;		===> Get the normal coordinates
 		P=COORD_2PLOT([_BAR_POS[0],_BAR_POS(2)],[_BAR_POS[1],_BAR_POS(3)], /TO_DATA)
		XYZ = CONVERT_COORD(P.X,P.Y,/DATA,/TO_NORMAL)
		XPOS=REFORM(XYZ(0,*))
		YPOS=REFORM(XYZ(1,*))
		IF XPOS[1] LT XPOS[0] THEN XPOS=REVERSE(XPOS)
		IF YPOS[1] LT YPOS[0] THEN YPOS=REVERSE(YPOS)
		NORM_POS = [XPOS[0],YPOS[0],XPOS[1],YPOS[1]]

		CBAR,vmin=MIN_FIMAGE,VMAX=MAX_FIMAGE,cmin= MIN_COLOR,cmax=MAX_COLOR,pos= NORM_POS,$
		COLOR=BAR_COLOR,title=BAR_TXT,charsize=BAR_CHARSIZE,$
		xticklen= -0.5,yticklen= -0.5,$
		XTICKFORMAT='(G0)',YTICKFORMAT='(G0)',$
		VERTICAL=VERTICAL,HORIZONTAL=HORIZONTAL,$
		XLOG=LOG,YLOG=LOG,$
		XMINOR=1,YMINOR=1
	ENDIF



;	*******************************
;	***** T I M E   S T A M P   ***
; *******************************
 	IF NOT KEYWORD_SET(NO_TIMESTAMP) THEN BEGIN
 		DATE=DATE_NOW()

; 		STOP
 	ENDIF




END; #####################  END of Routine ################################
