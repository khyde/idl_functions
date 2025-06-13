; $Id:	plot_taylor.pro,	April 09 2007	$

	PRO PLOT_TAYLOR, $

;			*** The only required inputs are those on the following line
			NAME=name, LABEL=label, STD=std, CORR=corr, $


;			*** Also illustrate Bias and a Bias Color Bar ?
			BIAS=bias,$

;			*** Plot Normalized STD ?
			NORMALIZED=normalized, $

;			*** Force the plot to be a semicircle (even when all correlations are positive)
			SEMI_CIRCLE=semi_circle, QUADRANT=quadrant,$

;			*** Position of plot on the page
			POSITION=position,$

;			*** Title for the Plot
			TITLE_PLOT=title_plot, TITLE_POS=TITLE_POS,TITLE_CHARSIZE=title_charsize,$

;			*** Palette for the plot axes and Labels and the palette for the Bias Scale
			PAL_PLOT=pal_plot, PAL_BIAS=pal_bias, $

;			*** X & Y Axes ***
			XRANGE = XRANGE, XTHICK=xthick,YTHICK=ythick, CHARSIZE=charsize, CHARTHICK=charthick,$

;			*** Labels ***
			LAB_SIZE=LAB_SIZE, LAB_COLOR=lab_color, LAB_THICK=lab_thick, $

;			*** Table of Labels/Symbols and their Names
			TAB_POSITION= TAB_POSITION, TAB_CHARSIZE=TAB_CHARSIZE, TAB_COLOR=tab_color,$

;			*** Correlation Axis (R) ***
			R_TITLE=R_TITLE, R_COLOR=R_COLOR,R_CHARSIZE=R_CHARSIZE,R_CHARTHICK=r_charthick, R_THICK=R_THICK, $

			R_LINESTYLE=R_LINESTYLE,R_TICKLEN=r_ticklen,$

;			*** Standard Deviation Arcs Centered at the origin ***
			SD_ARC=SD_ARC, SD_COLOR=SD_COLOR, SD_THICK=SD_THICK, SD_LINESTYLE=SD_LINESTYLE,$

;			*** Normalized Standard Deviation Arcs Centered at [1,0]
			NSD_ARC = NSD_ARC, NSD_COLOR=NSD_COLOR, NSD_THICK=NSD_THICK, NSD_LINESTYLE=NSD_LINESTYLE,$

;			*** Azimuths centered at the origin and extending to the correlation axis (RAXIS)
			RAZ_VAL = RAZ_VAL, RAZ_COLOR=RAZ_COLOR, RAZ_THICK=RAZ_THICK, RAZ_LINESTYLE=RAZ_LINESTYLE,RAZ_SPAN=RAZ_SPAN,$

;			*** Color Bar for Bias
			BI_NONE=bi_none,BI_POS= BI_POS, BI_HORIZ=bi_horiz, BI_RANGE=bi_range,BI_TITLE=BI_TITLE, BI_CHARSIZE=bi_charsize, BI_CHARTHICK=bi_charthick, $

;			*** Colored Circle behind each Label
 			BI_CIRCLE=BI_CIRCLE,$

;			*** Font to use
	 		FONT=font, $

			ERROR = error,$

;			*** Any undefined inputs are passed to PLOT via _EXTRA (e.g. NOERASE, etc ) ***
			_EXTRA=_extra

;+
; NAME:
;		ROUTINE_NAME
;			PLOT_TAYLOR
;
; PURPOSE:
;
;		This procedure draws a Taylor Diagram comparing pattern statistics (STD, Correlation) from several series
;
; CATEGORY:
;		STATISTICS, PLOT
;
; CALLING SEQUENCE:
;		PLOT_TAYLOR, NAME=name, LABEL=label, STD=std, CORR=corr
;
; INPUTS:
;			The only required inputs are: NAME, LABEL, STD and CORR
;
;	KEYWORD PARAMETERS:
;		NAME...........	Series Names (array)
;		LABEL..........	Label to use when plotting each STD vs. R coordinate (Same N_ELEMENTS as NAME)
;										LABELS may be the following characters:
;										!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
;										and standard IDL Plotting Symbols (PSYM) which are provided as strings with
;										a prefix of '#' (e.g.  '#1', '#2')
;										(e.g. LABEL = ['A','B','#1','#4','C','$','1']

;		STD............	Standard Deviation of the series (Same N_ELEMENTS as NAME)
;		CORR...........	Correlation between the series and the Reference series (Same N_ELEMENTS as NAME)
;		BIAS...........	Bias between the Series and the Reference Series (Ref - Series) (Same N_ELEMENTS as NAME)
;		NORMALIZED.....	STD input values are Normalized (i.e. divided by the Reference STD)
;		SEMI_CIRCLE.... Force the Taylor Plot to be a Semicircle
;		QUADRANT.......	Force the Taylor Plot to be just the upper right quadrant
;		POSITION.......	Position coordinates for the Plot on the page (See IDL Help on PLOT)

;		TITLE_PLOT.....	Title for the plot
;		TITLE_POS......	Position coordinates for the Title (in plot window units; [0.50,1.10])
;		TITLE_CHARSIZE.	Character size for the Title
;		CHARSIZE.......	Character size for the x and y axes (1.25)

;		PAL_PLOT.......	Name of the standard palette program for defining the Plot colors (PAL_SW3)
;		PAL_BIAS.......	Name of the standard palette program for defining just the Bias color bar (PAL_BIAS2)

;		XRANGE.........	Range for the x-axis (std range)
;		XTHICK.........	Thickness of the x-axis (4)
;		YTHICK.........	Thickness of the y-axis (4)
;		CHARTHICK......	Thickness of the x,y-axis characters (2)

;		LAB_SIZE.......	Size of the Label/Symbol to be plotted at each STD vs. R coordinate (CHARSIZE*1)
;		LAB_COLOR......	Color of the Label/Symbol (!P.COLOR)
;		LAB_THICK...... Thickness of the Label/Symbol (3)

;		TAB_POSITION...	Position coordinate for the upper left corner of the Table of Labels/Symbols and the Series Names
;										(in plot window units). semicircle [1.10, 1.10] or quadrant [1.10, 1.00]
;		TAB_CHARSIZE...	Size of the Table characters (CHARSIZE*.75)
;		TAB_COLOR......	Color of the Table characters (!P.COLOR)

;		R_TITLE........	Title for the Correlation Axis ('Correlation')
;		R_COLOR........	Correlation Axis Color (!P.COLOR)
;		R_CHARSIZE.....	Character size for the Correlation Axis labels (CHARSIZE*1 and scaled when position is used)
;		R_CHARTHICK....	Character thickness for the Correlation Axis labels (CHARTHICK*1)
;		R_THICK........	Thickness of the Correlation Axis (3)
;		R_LINESTYLE.... Linestyle for the Correlation Axis (0)
;		R_TICKLEN......	Tick length for the Correlation Axis (-0.02)

;		SD_ARC......... Standard Deviation Values used to draw Arcs centered at [0,0] (auto)
;		SD_COLOR.......	Color of SD Arcs (252)
;		SD_THICK.......	Thickness of SD Arcs (1)
;		SD_LINESTYLE...	Linestyle for SD Arcs (1)

;		NSD_ARC........	Normalized Standard Deviation (NSD) Values used to draw Arcs centered at [1,0] (auto)
;		NSD_COLOR...... Color of the NSD Arcs (252)
;		NSD_THICK......	Thickness of the NSD Arcs (1)
;		NSD_LINESTYLE..	Linestyle for the NSD Arcs (2)

;		RAZ_VAL........	Azimuth Values used to connect the origin [0,0] to the correlation axis
;										+- ['0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','0.95','0.99','1']
;		RAZ_COLOR......	Color of the Azimuths (253)
;		RAZ_THICK...... Thickness of the Azimuths (2)
;		RAZ_LINESTYLE..	Linestyle for the Azimuths (1)
;		RAZ_SPAN.......	The span or fraction of each Azimuth line which will be plotted
;										(Default is to plot only from 10% to 98% of the azimuth length [0.1,0.98] to avoid clutter
;										 where azimuths intersect the orgin and the correlation axis)

;		BI_NONE........ Prevents the drawing of a Bias Color Bar (but if Bias data are provided they will be correctly colored)
;										(BI_NONE is useful when placing several taylor plots on a page and you want only the first one to have a color bar)
;		BI_POS......... Position of the Bias color bar (in plot window units)
;										semicircle [0.98,0.55,1.00,1.05] or quadrant [0.955,0.55,0.980,0.973])
;		BI_HORIZ.......	The Bias color bar will be HORIZONTAL
;		BI_RANGE.......	Bias Range (this will override the default which automatically computes the range from the data bias
;										Note e.g. that if BI_RANGE=[-5,10] the default bias palette will not be centered at 0
;										but if BI_RANGE=[-10,10] then the greys indicating zero bias will be aligned properly with the bias scale.
;
;		BI_TITLE.......	Title of the Bias color bar ('Bias')
;		BI_CHARSIZE.... Character size for the Bias color bar axis
;		BI_CHARTHICK...	Character thickness for the Bias color bar axis

;		BI_CIRCLE......	Draw a bias-color-coded circle under the LABEL to indicate the bias

;		FONT...........	Font to use ('TIMES')

;		ERROR..........	Any Error messages are placed in ERROR, if no errors then ERROR = ''
;		_EXTRA.........	Any undefined inputs are passed to PLOT via _EXTRA

; OUTPUTS:
;		A Plot is drawn on the current graphic device

; RESTRICTIONS:
;		LABEL may be any of the following characters and/or any of the standard IDL PSYM values
;					!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
;
;	PROCEDURE:
;  	1) 	This routine draws a Taylor Plot
;				(Taylor, K. E. 2001. Summarizing multiple aspects of model performance
;				in a single diagram, J. Geophys. Res., 106(D7), 7183-7192).
;		2)	The Pattern Statistics and related information REQUIRED by this routine (NAME, LABEL, STD, CORR arrays)
;				are computed prior to calling PLOT_TAYLOR
;				(See PLOT_TAYLOR_DEMO for an example of computing the Pattern Statistics).
;		3)	If all correlation coefficients between the series and reference are positive then a quadrant plot is drawn,
;				If any of the correlation coefficients are negative then a semicircle plot is drawn.
;		4)	If the keyword NORMALIZED is used then this routine assumes that the values in the STD array  ;
;				are Normalized Standard Deviations (STD/Reference STD) and a 'Normalized Taylor Plot' will be drawn.;
;		5)	The Label for each series is plotted by centering the label at the STD-Correlation coordinate.
;				(CHAR_CENTER and XYOUTS_CHAR are used to accomplish the accurate positioning of each LABLE).
;		6)	If BIAS is provided with the same number of elements as NAME, LABEL, STD,and CORR
;				then a bias color bar is also drawn and the labels are either:
;					color-coded to reflect the degree of bias
;					or
;					if BI_CIRCLE keyword is set then a bias-color-coded circle is drawn under the LABEL to indicate the bias.
;		7)	A Table of LABEL and NAME for all series is plotted along the right side of the Taylor Plot

;		8)	The defaults (charsize,colors,linestyle,thickness,etc) for this routine were developed with
;				the PostScript Device in mind and FONT='TIMES' or FONT='HELVETICA'.

;		9)	This is a Beta version. The program needs some additional testing with data.
;				Please send any suggested improvements to J.O'Reilly (Jay.O'Reilly@NOAA.GOV)
;
; EXAMPLE:
;		See companion program PLOT_TAYLOR_DEMO.PRO which shows how to compute the Pattern Statistics and has a variety
;		of examples showing the use of optional keywords.
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;  	Use FONT='TIMES' or 'HELVETICA'. Letters based on these true-type fonts are centered correctly over the x,y coordinate
;	 	Use !X.MARGIN (e.g. !X.OMARGIN=[5,15]) to leave some room to the right of the Taylor Plot for the Table
;
;		Some of the coordinates in this program are in Plot Window units.
;		Plot Window units are like normal units. [1,1] means upper right corner of the plot window. [1.1,1.1] is just outside.
;
;
; MODIFICATION HISTORY:
;			Written Jan 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;			(Generalized the IDL code provided to me Nov 21, 2006 by Marjy Friedrichs (marjy@vims.edu)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PLOT_TAYLOR'
	ERROR = ''

;	============================================================
;	=== Minimum REQUIRED INPUTS are NAME, Label, STD & Corr  ===
;	============================================================
	N_NAME = N_ELEMENTS(NAME)
 	IF N_NAME EQ 0 THEN BEGIN
		ERROR='Must provide a name for each statistical comparison' & PRINT,ERROR & RETURN
	ENDIF

	IF 	N_ELEMENTS(LABEL) NE N_NAME OR N_ELEMENTS(STD) NE N_NAME OR N_ELEMENTS(CORR) NE N_NAME	THEN BEGIN
		ERROR='Name, Label, STD, & Corr must have same number of elements' & 	PRINT,ERROR & RETURN
	ENDIF

	LABEL = STRTRIM(LABEL,2)

;	===> Labels must be one character or 2 characters with the first being '#' for specifying PSYM values
	OK = WHERE(STRLEN(LABEL) EQ 2 AND STRMID(LABEL,0,1) NE '#',COUNT)
	IF COUNT GE 1 THEN BEGIN
		ERROR="Label may be only 1 character or 2 characters if the first character is '#' "
		PRINT, ERROR
		RETURN
	ENDIF

;	===> If BIAS array is provided then it will be used and a color bar will be drawn
	IF N_ELEMENTS(BIAS) EQ N_NAME THEN PLOT_BIAS = 1 ELSE PLOT_BIAS = 0

;	===> Use Colors 1 to 250, reserving 0, 251:255 for plot annotation (grids,axes,etc)
	min_color = 1
	max_color = 250

;	===> Default Font is Times if FONT is not provided
	IF N_ELEMENTS(FONT) NE 1 THEN _FONT = 'TIMES' ELSE _FONT = FONT
	FONTS,_FONT


;	===> Get the x,y alignments for Centering Letters/Characters when using XYOUTS_CHAR
	char_align=CHAR_CENTER(_font)

;	===> Default Palette for Axes, Labels, etc. is PAL_SW3
	IF N_ELEMENTS(PAL_PLOT) NE 1 THEN _PAL_PLOT = 'PAL_SW3' ELSE _PAL_PLOT = PAL_PLOT
	CALL_PROCEDURE,_PAL_PLOT

;	===> Default Palette for the Bias color scale is PAL_BIAS2
	IF N_ELEMENTS(PAL_BIAS) NE 1 THEN _PAL_BIAS = 'PAL_BIAS2' ELSE _PAL_BIAS = PAL_BIAS


;	========================================
;	===  X,Y  (Standard Deviation) Axes  ===
;	========================================
	IF N_ELEMENTS(CHARSIZE) 	NE 1 THEN _CHARSIZE 	= 1.25	ELSE _CHARSIZE = CHARSIZE   ; For both x and y axes
	IF N_ELEMENTS(CHARTHICK) 	NE 1 THEN _CHARTHICK 	= 2 		ELSE _CHARTHICK = CHARTHICK ; For both x and y axes
	IF N_ELEMENTS(XTHICK) 		NE 1 THEN _XTHICK 		= 4			ELSE _XTHICK = XTHICK
	IF N_ELEMENTS(YTHICK) 		NE 1 THEN _YTHICK 		= 4			ELSE _YTHICK = YTHICK

	XTICKLEN = -0.02 	; Xticks are outside axes to avoid interference with data symbols
  YTICKLEN = -0.02  ; Yticks are outside axes to avoid interference with data symbols
	XTITLE = 'Standard Deviation'
	YTITLE = 'Standard Deviation'
	IF KEYWORD_SET(NORMALIZED) THEN XTITLE = XTITLE + ' (normalized)'
	IF KEYWORD_SET(NORMALIZED) THEN YTITLE = YTITLE + ' (normalized)'


;	=========================================
; === C O R R E L A T I O N   A X I S   ===
;	=========================================
 	IF N_ELEMENTS(R_TITLE) NE 1 THEN _R_TITLE = 'Correlation' ELSE _R_TITLE = R_TITLE

;	===> Correlation Axis major tick values
	R_TICKV_POS = ['0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','0.95','0.99','1']
	R_TICKV_NEG = '-'+R_TICKV_POS(1:*)

;	===> Correlation Axis minor tick values
	R_TICKV_MINOR_POS = ['0.05','0.15','0.25','0.35','0.45','0.55','0.65','0.75','0.85','0.91','0.92','0.93','0.94','0.96','0.97','0.98']
	R_TICKV_MINOR_NEG = '-'+R_TICKV_MINOR_POS

;	===> Semicircle or just right quadrant?
;	(If any correlation coefficients are negative then xrange must encompass negative and positive)
	IF NOT KEYWORD_SET(QUADRANT) AND (KEYWORD_SET(SEMI_CIRCLE) OR MIN(CORR) LT 0) THEN BEGIN

		do_semicircle = 1
;		===> Default Range for the Standard Deviation axes
		IF N_ELEMENTS(XRANGE) NE 2 THEN BEGIN
			_XRANGE = [-MAX(NICE_RANGE(FLOAT(STD))), MAX(NICE_RANGE(FLOAT(STD)))]
		ENDIF ELSE BEGIN
			_XRANGE = XRANGE
		ENDELSE

		IF KEYWORD_SET(NORMALIZED) THEN 	_XRANGE(1) = _XRANGE(1) > 1 ;
		_XRANGE(0) = -_XRANGE(1)

		XSTYLE = 9 ; Exact and draw only bottom x axis
		YSTYLE = 5 ; Exact and draw only left y axis
		R_TICKV = [R_TICKV_POS, R_TICKV_NEG]
		R_TICKV_MINOR = [R_TICKV_MINOR_POS,R_TICKV_MINOR_NEG]
		pos_r_title_deg = 90.0

;		===> Default position for BIAS legend
		IF N_ELEMENTS(BI_POS) NE 4 THEN BEGIN
			IF NOT KEYWORD_SET(BI_HORIZ) THEN BEGIN
				_BI_POS = [0.98,0.55,1.00,1.05]
			ENDIF ELSE BEGIN
				_BI_POS = [0.3,1.30,0.7,1.33]
			ENDELSE
		ENDIF ELSE BEGIN
			_BI_POS = BI_POS
		ENDELSE


	ENDIF ELSE BEGIN

		do_semicircle = 0
;		===> Default Range for the Standard Deviation axes
		IF N_ELEMENTS(_XRANGE) NE 2 THEN BEGIN
			_XRANGE = [0, MAX(NICE_RANGE(FLOAT(STD)))]
			IF KEYWORD_SET(NORMALIZED) THEN BEGIN
				_XRANGE(1) = _XRANGE(1) > 2 ;
			ENDIF
		ENDIF ELSE BEGIN
			_XRANGE = XRANGE
		ENDELSE

		XSTYLE = 9 ; Exact and draw only bottom x axis
		YSTYLE = 9 ; Exact and draw only left y axis
		R_TICKV = R_TICKV_POS
		R_TICKV_MINOR = R_TICKV_MINOR_POS
		pos_r_title_deg = 45.0

;		===> Default position for BIAS legend
		IF N_ELEMENTS(BI_POS) NE 4 THEN BEGIN
			IF NOT KEYWORD_SET(BI_HORIZ) THEN BEGIN
				_BI_POS = [0.955,0.55,0.980,0.973]
			ENDIF ELSE BEGIN
				_BI_POS = [0.3,1.30,0.7,1.33]
			ENDELSE
		ENDIF ELSE BEGIN
			_BI_POS = BI_POS
		ENDELSE

	ENDELSE ; 	IF NOT KEYWORD_SET(QUADRANT) AND (KEYWORD_SET(SEMI_CIRCLE) OR MIN(CORR) LT 0) THEN BEGIN

;	===> YRANGE always begins at 0
	YRANGE = [0,_XRANGE(1)]


;	===> Defaults for R_CHARSIZE, R_CHARTHICK are the same as those for the X and Y axis
	IF N_ELEMENTS(R_CHARSIZE) 	NE 1 THEN BEGIN
		auto_r_charsize = 1
		_R_CHARSIZE 	= _CHARSIZE
	ENDIF ELSE BEGIN
		auto_r_charsize = 0
		_R_CHARSIZE  = R_CHARSIZE ; same as x and y charsize
	ENDELSE

	IF N_ELEMENTS(R_CHARTHICK) 	NE 1 THEN _R_CHARTHICK 	= _CHARTHICK ELSE _R_CHARTHICK = R_CHARTHICK; same as x and y charsize

;	===> Ticklen for the Correlation Axis (arc segment), default is to make ticks outside the RAXIS
	IF N_ELEMENTS(R_TICKLEN) NE 1 THEN _R_TICKLEN = -0.02	ELSE _R_TICKLEN = R_TICKLEN

;	===> Offset the RTICKNAMES from the RAXIS (Correlation Axis) by 1% if RTICKS point to the origin
;			 or by 1% greater than the distance from the outside ends of the RTICKS if they point away from the origin (-)
	rtickname_offset = 1.01*( _XRANGE(1)  >  (_XRANGE(1)-_R_TICKLEN*_XRANGE(1)) )

;	===> Correlation axis tick names
	IF N_ELEMENTS(RTICKNAME) EQ 0 THEN RTICKNAME = STRTRIM(R_TICKV,2)

;	===> Correlation axis color
	IF N_ELEMENTS(R_COLOR) EQ 0 THEN _R_COLOR = !P.COLOR	ELSE _R_COLOR = R_COLOR

;	===> Correlation axis linestyle
	IF N_ELEMENTS(R_LINESTYLE) EQ 0 THEN _R_LINESTYLE = 0	ELSE _R_LINESTYLE = R_LINESTYLE

;	===> Correlation axis thickness
	IF N_ELEMENTS(R_THICK) NE 1 THEN _R_THICK = 3	ELSE _R_THICK = R_THICK


;	=================================================
;	=== C O R R E L A T I O N    A Z I M U T H S  ===
;	=================================================
	IF N_ELEMENTS(RAZ_VAL) 	 EQ 0 THEN _RAZ_VAL = R_TICKV	ELSE _RAZ_VAL = RAZ_VAL

	IF N_ELEMENTS(RAZ_COLOR) EQ 0 THEN _RAZ_COLOR = REPLICATE(253,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_COLOR) EQ 1 THEN _RAZ_COLOR = REPLICATE(RAZ_COLOR,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_COLOR) GE 2 THEN _RAZ_COLOR	=	RAZ_COLOR

	IF N_ELEMENTS(RAZ_THICK) EQ 0 THEN _RAZ_THICK = REPLICATE(2,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_THICK) EQ 1 THEN _RAZ_THICK = REPLICATE(RAZ_THICK,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_THICK) GE 2 THEN _RAZ_THICK = RAZ_THICK

	IF N_ELEMENTS(RAZ_LINESTYLE) EQ 0 THEN _RAZ_LINESTYLE = REPLICATE(1,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_LINESTYLE) EQ 1 THEN _RAZ_LINESTYLE = REPLICATE(RAZ_LINESTYLE,N_ELEMENTS(_RAZ_VAL))
	IF N_ELEMENTS(RAZ_LINESTYLE) GE 2 THEN _RAZ_LINESTYLE = RAZ_LINESTYLE

	IF N_ELEMENTS(RAZ_SPAN) NE 2 THEN _RAZ_SPAN = [0.1,0.98] ELSE _RAZ_SPAN = RAZ_SPAN; Do not draw the first 10% and last 2% of azimuth


;	=========================================================================
;	===  S T A N D A R D   D E V I A T I O N   A R C S   Centered on [0,0]===
;	=========================================================================
	IF N_ELEMENTS(SD_COLOR) 		NE 1 	THEN _SD_COLOR 			= 252 ELSE _SD_COLOR 			= SD_COLOR
	IF N_ELEMENTS(SD_THICK) 		NE 1 	THEN _SD_THICK 			= 1 	ELSE _SD_THICK 			= SD_THICK
	IF N_ELEMENTS(SD_LINESTYLE) NE 1 	THEN _SD_LINESTYLE 	= 1		ELSE _SD_LINESTYLE	=	SD_LINESTYLE

;	===============================================================
;	=== N O R M A L I Z E D  STD  A R C S    Centered on  [1,0] ===
;	===============================================================
	IF N_ELEMENTS(NSD_COLOR) 			NE 1 	THEN _NSD_COLOR 			= 252	ELSE _NSD_COLOR 			= NSD_COLOR
	IF N_ELEMENTS(NSD_THICK) 			NE 1 	THEN _NSD_THICK 			= 1 	ELSE _NSD_THICK 			= NSD_THICK
	IF N_ELEMENTS(NSD_LINESTYLE) 	NE 1 	THEN _NSD_LINESTYLE 	= 2		ELSE _NSD_LINESTYLE		=	NSD_LINESTYLE

;	================
;	=== B I A S  ===
;	================
	IF N_ELEMENTS(BI_TITLE) 		NE 1 THEN _BI_TITLE = 'Bias' ELSE _BI_TITLE = BI_TITLE
	IF N_ELEMENTS(BI_CHARSIZE) 	NE 1 THEN BEGIN
		auto_bi_charsize = 1
		_BI_CHARSIZE 	= _R_CHARSIZE
	ENDIF ELSE BEGIN
		auto_bi_charsize = 0
		_BI_CHARSIZE  = BI_CHARSIZE
	ENDELSE

	IF N_ELEMENTS(BI_CHARTHICK) NE 1 THEN _BI_CHARTHICK = 1 ELSE _BI_CHARTHICK = BI_CHARTHICK


;	===================
;	=== L A B E L S ===
;	===================
	IF N_ELEMENTS(LAB_SIZE) 	EQ 0 THEN _LAB_SIZE = _CHARSIZE ELSE _LAB_SIZE = LAB_SIZE
	IF N_ELEMENTS(_LAB_SIZE) 	NE N_ELEMENTS(LABELS) THEN _LAB_SIZE = REPLICATE(_LAB_SIZE(0),N_NAME)

	IF N_ELEMENTS(LAB_COLOR) 	EQ 0 THEN _LAB_COLOR = 0 ELSE _LAB_COLOR = LAB_COLOR
	IF N_ELEMENTS(_LAB_COLOR) NE N_NAME THEN _LAB_COLOR=REPLICATE(_LAB_COLOR(0),N_NAME)

	IF N_ELEMENTS(LAB_THICK) 	EQ 0 THEN _LAB_THICK = 3 ELSE _LAB_THICK = LAB_THICK
	IF N_ELEMENTS(_LAB_THICK) NE N_NAME THEN _LAB_THICK=REPLICATE(_LAB_THICK(0),N_NAME)

;	=================
;	=== T A B L E ===
;	=================
	IF N_ELEMENTS(TAB_POSITION) NE 2 THEN BEGIN
		IF do_semicircle EQ 1 THEN _TAB_POSITION = [1.12, 1.10] ELSE _TAB_POSITION = [1.12, 1.00]
	ENDIF ELSE BEGIN
		_TAB_POSITION = TAB_POSITION
	ENDELSE

	IF N_ELEMENTS(TAB_CHARSIZE) EQ 0 THEN _TAB_CHARSIZE 	= _CHARSIZE*.75 ELSE _TAB_CHARSIZE = TAB_CHARSIZE
	IF N_ELEMENTS(TAB_COLOR) 	EQ 0 THEN _TAB_COLOR 	= !P.COLOR 			ELSE _TAB_COLOR = TAB_COLOR

;	==================
;	=== T I T L E  ===
;	==================
	IF N_ELEMENTS(TITLE_CHARSIZE) NE 1 THEN _TITLE_CHARSIZE = 1.25*_CHARSIZE ELSE _TITLE_CHARSIZE = TITLE_CHARSIZE
	IF N_ELEMENTS(TITLE_POS) NE 2 THEN BEGIN
		IF do_semicircle EQ 0 THEN _TITLE_POS = [0.50,1.10] ELSE _TITLE_POS = [0.50,1.20]
	ENDIF ELSE BEGIN
		_TITLE_POS = TITLE_POS
	ENDELSE
	IF N_ELEMENTS(TITLE_PLOT) NE 1 THEN _TITLE_PLOT = '' ELSE _TITLE_PLOT = TITLE_PLOT



;	==============================
;	=== Define the unit circle ===
;	==============================
	n_circle = 1000 ; resolution
	rad = FINDGEN(n_circle+1) * (!PI*2/n_circle)
	xcircle= SIN(rad)
	ycircle= COS(rad)




;	******************************************
;	*** D r a w   a   P o l a r   P l o t  ***
;	******************************************
	PLOT, /POLAR, /ISOTROPIC,[0,0],[1,1],$
	charsize=_CHARSIZE,charthick=_CHARTHICK, $
	XRANGE=_XRANGE,xstyle=xstyle,xthick=_xthick,xticks=xticks,$
	yrange=yrange,ystyle=ystyle,ythick=_ythick,yticks=yticks,$
	xtickv=xtickv,xminor=xminor,xticklen=xticklen,xtitle=xtitle,$
	ytickv=ytickv,yminor=yminor,yticklen=yticklen,ytitle=ytitle,$
	xtick_get=xtick_get,ytick_get=ytick_get,$
  POSITION=POSITION,_EXTRA=_extra

;	===> Adjust the R_CHARSIZE to be proportional to the character size of the
;			 X,Y axes lables  (i.e. when !P.MULTI or POSITION are used)
	IF auto_r_charsize EQ 1 THEN _R_CHARSIZE = _R_CHARSIZE * ((!X.REGION(1)-!X.REGION(0)))^0.333


;	**********************************************************************
;	*** Obtain the character width and height for this plotting device ***
;	**********************************************************************
	char_x_normal = _R_CHARSIZE*(!D.X_CH_SIZE/FLOAT(!D.X_SIZE))
	char_y_normal = _R_CHARSIZE*(!D.Y_CH_SIZE/FLOAT(!D.Y_SIZE))

;	**********************************************************************
;	*** Plot the Azimuths connecting the orgin to the correlation axis ***
;	**********************************************************************
	FOR nth = 0,N_ELEMENTS(_RAZ_VAL)-1 DO BEGIN
;	  _R_TICKV = FLOAT(R_TICKV(nth))
	  _R_TICKV = FLOAT(_RAZ_VAL(nth))
;		===> Do not plot the 0 or 1 over the x and y axis
		IF _R_TICKV EQ 1 OR _R_TICKV EQ -1 THEN CONTINUE ; >>>>>>>>>>>>
		IF do_semicircle EQ 0 AND _R_TICKV EQ 0 THEN CONTINUE ; >>>>>>>>>>>> BEGIN
		OPLOT,/polar,[_RAZ_SPAN(0)*_XRANGE(1),_RAZ_SPAN(1)*_XRANGE(1)],[ACOS(_R_TICKV),ACOS(_R_TICKV)],COLOR=_RAZ_COLOR(nth),THICK=_RAZ_thick(nth),LINESTYLE=_RAZ_linestyle(nth)
	ENDFOR


;	*************************************
;	***** Plot the Correlation Axis *****
;	*************************************
	OPLOT, xcircle*_XRANGE(1),ycircle*_XRANGE(1),color=_R_COLOR,thick=_R_THICK,linestyle=_R_LINESTYLE

;	******************************************************************************************
;	***** Plot the Correlation Axis Major ticks and ticknames perpendicular to the RAXIS *****
;	******************************************************************************************

	IF do_semicircle EQ 1 THEN rchar_offset = 1  ELSE rchar_offset = 2

	max_r_width = 0 ; Initialize (keep track of the maximum width of correlation axis labels)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_ELEMENTS(R_TICKV)-1 DO BEGIN
		rad =  ACOS(R_TICKV(nth))

;		===>. Plot the Major R_TICKV values perpendicular to the RAXIS
 		OPLOT,/polar,[_XRANGE(1), _XRANGE(1)-_R_TICKLEN*_XRANGE(1)],[rad,rad],$
 					COLOR=_R_COLOR,thick=_R_THICK,/NOCLIP
		ORIENTATION = rad*!RADEG
		IF FLOAT(RTICKNAME(nth)) LT 0 THEN BEGIN
		  offset = CV_COORD(FROM_RECT=[rtickname_offset, char_X_normal*rtickname_offset/(!X.WINDOW(1)-!X.WINDOW(0))],/TO_POLAR)
			ORIENTATION =  ORIENTATION   - 180
			rad = rad + offset(0)/rchar_offset
			align_x = 1
		ENDIF ELSE BEGIN
		  offset = CV_COORD(FROM_RECT=[rtickname_offset, char_X_normal*rtickname_offset/(!X.WINDOW(1)-!X.WINDOW(0))],/TO_POLAR)
			rad = rad - offset(0)/rchar_offset
			align_x = 0
		ENDELSE
		XY = CV_COORD(FROM_POLAR=[rad ,rtickname_offset],/TO_RECT)
;		===> Add the RTICKNAME to the RAXIS and use ALIGN to offset the RTICKNAME from the RAXIS
		XYOUTS, XY(0),XY(1), RTICKNAME(nth),/NOCLIP, $
						ORIENTATION=ORIENTATION,COLOR=_R_COLOR, CHARSIZE=_R_CHARSIZE,$
						CHARTHICK=_R_CHARTHICK,WIDTH=WIDTH ,ALIGN=[align_x]
		max_r_width= max_r_width > width
  ENDFOR
;	||||||


;	************************************************
;	***** Plot the Correlation Axis Minor ticks  ***
;	************************************************
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_ELEMENTS(R_TICKV_MINOR)-1 DO BEGIN
 		OPLOT,/polar,[_XRANGE(1), _XRANGE(1)-_R_TICKLEN*_XRANGE(1)*0.5],$
 			[ACOS(R_TICKV_MINOR(nth)),ACOS(R_TICKV_MINOR(nth))],	COLOR=_R_COLOR,thick=_R_THICK,/NOCLIP
  ENDFOR


;	********************************************************************
;	*** Plot the Correlation Axis Title Parallel to the curved axis  ***
;	********************************************************************
;	===> Make a string array of the characters extracted from the R_TITLE
	n_chars  = STRLEN(_R_TITLE)
	chars = STRING(REFORM(BYTE(_R_TITLE),1,n_chars ))

;	===> Get the middle position along the RAXIS
  RVALUE = COS(pos_r_title_deg/!RADEG)

 	rad = ACOS(RVALUE )

;	===> Use max_r_width from above to Determine offset from the R_TICKV for R_TITLE placement
  offset =  0.7*max_r_width*(_XRANGE(1))/(!Y.WINDOW(1)-!Y.WINDOW(0))

;	===> Convert from polar [angle, radius] to Data Units [x,y]
 	xy = CV_COORD(FROM_POLAR=[rad,rtickname_offset+offset],/TO_RECT)

;	===> Convert data to normal
	xyn = CONVERT_COORD(xy(0),xy(1),/DATA,/TO_NORMAL)

;	===> Determine offset from center
 	IF do_semicircle EQ 1 THEN x_offset_norm = (char_x_normal*n_chars /!PI) ELSE x_offset_norm = (char_x_normal*n_chars /2.00)

;	===> Convert the normal units xyn plus the x_offset_norm to data units
	xyd = CONVERT_COORD(xyn(0)-x_offset_norm,xyn(1)-0,/NORMAL,/TO_DATA)

;	===> Convert data to polar
	xyp = CV_COORD(FROM_RECT=[xyd(0),xyd(1)],/TO_POLAR)

;	===> Redefine rad
 	rad = xyp(0)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,n_chars -1 DO BEGIN
;		===> Convert from polar to Data Units
 		xy = CV_COORD(FROM_POLAR=[rad,rtickname_offset+offset],/TO_RECT)

;		===> Add the R_TITLE Character to the RAXIS
 		XYOUTS, xy(0),xy(1), CHARS(nth),/NOCLIP, $
 				 		ORIENTATION = -90 +((rad)*!RADEG),COLOR=_R_COLOR, CHARSIZE=_R_CHARSIZE,CHARTHICK=_R_CHARTHICK,ALIGN=0,WIDTH=width

;		===> Width (of last char plotted) is in data units, so convert to normal
		xyn = CONVERT_COORD(xy(0),xy(1),/DATA,/TO_NORMAL)

;		===> Adjust width so character spacing is correct along the RAXIS
		x_offset_norm =  width/ COS(((90-rad*!RADEG))/!RADEG)

;		===> Convert the normal units xyn plus the x_offset_norm to data units
		xyd = CONVERT_COORD(xyn(0)+x_offset_norm,xyn(1),/NORMAL,/TO_DATA)

;		===> Convert data to polar
		xyp = CV_COORD(FROM_RECT=[xyd(0),xyd(1)],/TO_POLAR)

;		===> Redefine rad (radians) for the next character in the R_TITLE
		rad = xyp(0)
  ENDFOR
;	//////



;	**********************************************************
;	*** Plot the Standard Deviation Arcs Centered at [0,0] ***
;	**********************************************************
	IF do_semicircle EQ 0 THEN NUM=N_ELEMENTS(XTICK_GET) ELSE NUM = N_ELEMENTS(XTICK_GET)*2
;	===> Determine appropriate number of values for drawing SD arcs
	IF N_ELEMENTS(SD_ARC) EQ 0 	THEN BEGIN
		IF do_semicircle EQ 0 THEN BEGIN
			_SD_ARC=XTICK_GET
		ENDIF ELSE BEGIN
			STEP = ABS(SPAN(XTICK_GET(0:1)))/2
			_SD_ARC = [XTICK_GET,XTICK_GET+STEP]
			_SD_ARC= _SD_ARC(SORT(_SD_ARC))
			_SD_ARC = _XRANGE(0) > _SD_ARC  < _XRANGE(1)
		ENDELSE
	ENDIF

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_ELEMENTS(_SD_ARC)-1 DO BEGIN
;		===> Prevent the SD circle from overplotting on the RAXIS
		ASD_ARC=_SD_ARC(nth)
		IF ASD_ARC LE _XRANGE(0) OR ASD_ARC GE _XRANGE(1) THEN CONTINUE ; >>>>
		OPLOT, ASD_ARC*xcircle,ASD_ARC*ycircle ,COLOR=_SD_color,THICK=_SD_thick,LINESTYLE=_SD_linestyle
	ENDFOR

;	===> If /NORMALIZED then make a darker line at the std value of 1
	IF  KEYWORD_SET(NORMALIZED) THEN BEGIN
		OPLOT, 1.0*xcircle,1.0*ycircle ,COLOR=!P.COLOR,THICK=_SD_thick,LINESTYLE=0
	ENDIF

;	*************************************************************************************************
;	*** If NORMALIZED then Plot the Normalized Standard Deviation semi-circles centered at [1,0]) ***
;	*************************************************************************************************
	IF KEYWORD_SET(NORMALIZED) THEN BEGIN
		IF N_ELEMENTS(NSD_ARC) EQ 0	THEN 	_NSD_ARC = [_SD_ARC,_SD_ARC+1] ELSE _NSD_ARC = NSD_ARC


		IF do_semicircle EQ 1 THEN BEGIN
 			OK=WHERE(_NSD_ARC  LT  SPAN([_XRANGE(0),1.0]),COUNT)
  		IF COUNT GE 1 THEN  _NSD_ARC=_NSD_ARC(OK)
  	ENDIF


;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR nth = 0,N_ELEMENTS(_NSD_ARC)-1 DO BEGIN
			A_NSD_ARC = _NSD_ARC(nth)
			XX = 1 + _NSD_ARC(nth)*xcircle
			YY = _NSD_ARC(nth)*ycircle

;			===> Determine the intersections of the NSD_ARC and the Correlation Axis (Arc)
			xy= CIRCLES_INTERSECTION(Center_1=[0.,0.],radius_1=_XRANGE(1), Center_2=[1.0,0.0D],radius_2 =_NSD_ARC(nth))
 			ok_xy=WHERE(FINITE(xy.x) AND FINITE(xy.y),count_xy)
;			===> IF xy.x AND xy.y are Infinite (NAN) then the NSD circle is inside the SD circle so draw this NSD Arc
			IF count_xy EQ 0 THEN BEGIN
				OPLOT,XX,YY,COLOR=_NSD_color,THICK=_NSD_thick,LINESTYLE=_NSD_linestyle
			ENDIF ELSE BEGIN
				xy = xy(ok_xy)
				ok_y=WHERE(xy.y GT 0,COUNT_Y)
				IF COUNT_Y EQ 1 THEN BEGIN
					xy=xy(ok_y)
;					===> Set any xx,yy outside the SD semicircle to infinity so they will not plot
					ok = WHERE((XX LE _XRANGE(0) OR XX GE 0.99*xy.x) OR YY LE 0.03,count)
					IF COUNT GE 1 THEN BEGIN
						XX(OK) = MISSINGS(XX)
						YY(OK) = MISSINGS(YY)
					ENDIF
						OPLOT,XX,YY,COLOR=_NSD_color,THICK=_NSD_thick,LINESTYLE=_NSD_linestyle
				ENDIF ELSE BEGIN
					 OPLOT,XX,YY,COLOR=_NSD_color,THICK=_NSD_thick,LINESTYLE=_NSD_linestyle
				ENDELSE
			ENDELSE
		ENDFOR
	ENDIF



;	**********************
;	*** Plot the Title ***
;	**********************
	xy = COORD_2PLOT(_TITLE_POS(0),_TITLE_POS(1),/TO_NORMAL)
  XYOUTS,xy.x,xy.y,/NORMAL,_TITLE_PLOT,CHARSIZE=_TITLE_CHARSIZE,ALIGN=0.5


;	****************************************
;	*** Determine coordinates for labels ***
;	****************************************
	xy = FLTARR(2,N_NAME)
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0L,N_NAME-1L DO BEGIN
;		===> Convert from polar to data units
		xy(*,nth) = CV_COORD(FROM_POLAR=[ACOS(CORR(nth)),STD(nth)],/TO_RECT)
	ENDFOR


;	******************************
;	*** Plot a Bias Color Bar  ***
;	******************************
	IF PLOT_BIAS EQ 1 THEN BEGIN
;		===> Save old system x,y,plot values
		sys_x = !x
		sys_y = !y
		sys_p = !p

;		===> Load the Bias Palette
		CALL_PROCEDURE,_PAL_BIAS
	 	IF N_ELEMENTS(BI_RANGE) NE 2 THEN BEGIN
	 		bias_range = NICE_RANGE(BIAS)
;			===> Make bias_range symmetrical about zero
			bias_range = [-MAX(ABS(bias_range)),MAX(ABS(bias_range))]

;			===> If all input bias was zero then bias_range is [0,0] so make it [-1,1]
			IF SPAN(bias_range) EQ 0 THEN bias_range = [-1,1.]
		ENDIF ELSE BEGIN
			bias_range = BI_RANGE
		ENDELSE

		color_bias = INDGEN(max_color-min_color+1)+min_color
		tickname = [' ',' ']
		width_bar = 0.025 ; normal units

		IF auto_bi_charsize EQ 1 THEN _BI_CHARSIZE = _R_CHARSIZE


;		===> Suppress the Bias Color Bar ?
		IF NOT KEYWORD_SET(BI_NONE) THEN BEGIN

;			===> Convert BI_POS_normal to Data units
			xyn = COORD_2PLOT([_BI_POS(0),_BI_POS(2)],[_BI_POS(1),_BI_POS(3)],/TO_NORMAL)
		  _BI_POS = [xyn.x(0),xyn.y(0),xyn.x(1),xyn.y(1)]

			PLOT, xyn.x, xyn.y,/XSTYLE,/YSTYLE,position=_BI_POS,/NORMAL,/NOERASE,$
						XRANGE=xyn.x,xticks=1,xminor=1, xtickname	=tickname,$
			  		yrange=xyn.y,yticks=1,yminor=1, ytickname	=tickname,$
			  	 	color=!P.COLOR, title=_BI_TITLE, $
			  		charsize=_BI_CHARSIZE, charthick=_BI_CHARTHICK,psym=3

		 	xsize = SPAN(xyn.x)
		 	ysize = SPAN(xyn.y)



			IF NOT KEYWORD_SET(BI_HORIZ) THEN BEGIN
				color_bar =  REPLICATE(1B,1) # color_bias
				TV, color_bar, xyn.x(0), xyn.y(0), XSIZE=xsize, YSIZE=ysize, /Normal
				AXIS, YAXIS=1,YRANGE=bias_range,/XSTYLE,/YSTYLE,CHARSIZE=_BI_CHARSIZE,$
							XMINOR=1, YMINOR=1,YTICKLEN= 0.0,charthick=_BI_CHARTHICK,YTICKNAME=ytickname,$
							XTITLE=BAR_TITLE
			ENDIF ELSE BEGIN
				color_bar =  color_bias #  REPLICATE(1B,1)
				TV, color_bar, xyn.x(0), xyn.y(0), XSIZE=xsize, YSIZE=ysize, /Normal
				AXIS, XAXIS=0,XRANGE=bias_range,/XSTYLE,/YSTYLE,CHARSIZE=_BI_CHARSIZE,$
							XMINOR=1, YMINOR=1,XTICKLEN= 0.0,charthick=_BI_CHARTHICK,XTICKNAME=xtickname,$
							XTITLE=BAR_TITLE
			ENDELSE

;			===> Draw a frame around the color bar
			FRAME,/PLOT,THICK=2
		ENDIF ; IF NOT KEYWORD_SET(BI_NONE) THEN BEGIN


		S= SCALE(BIAS_RANGE,[min_color,max_color],SLOPE=slope,INTERCEPT=intercept)



;		===> Restore old system x,y,plot values
		!x = sys_x	; Restore incoming X/Y scaling.
		!y = sys_y
		!p = sys_p


;		*********************
;		*** Plot the Data ***
;		*********************
		IF KEYWORD_SET(BI_CIRCLE) THEN BEGIN
;			===> Show Bias as a circle whose color is scaled to the magnitude of bias
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR nth = 0L,N_NAME-1L DO BEGIN
				BIAS_COLOR = min_color > intercept+slope*BIAS(nth)  < max_color
				CIRCLE,/FILL,COLOR = BIAS_COLOR
				PLOTS, xy(0,nth),xy(1,nth),PSYM=8,SYMSIZE= _LAB_SIZE(nth)*1.5
	 	 	ENDFOR

;			===> Plot the labels after all the filled circles are drawn
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR nth = 0L,N_NAME-1L DO BEGIN
				alabel=LABEL(nth)
;				===> Plot the Label Letter or Symbol at the center of the coordinate using ACOLOR
;				===> Use XYOUTS_CHAR if this alabel is text or use PLOTS if it is a plot symbol
				IF STRLEN(alabel) EQ 2 AND STRMID(alabel,0,1) EQ '#'  THEN BEGIN
					alabel = STRMID(alabel,1)	; Remove the # from alabel
					PLOTS, xy(0,nth),xy(1,nth), PSYM=alabel,COLOR=_LAB_COLOR(nth),/DATA,SYMSIZE=_LAB_SIZE(nth),THICK=_LAB_THICK(nth)
				ENDIF ELSE BEGIN
					ok = WHERE(char_align.char EQ alabel,count) & IF count NE 1 THEN CONTINUE ; >>>>>>>>>>>>
					align = [char_align(ok).x, char_align(ok).y]
					XYOUTS_CHAR,xy(0,nth),xy(1,nth),alabel,ALIGN=align,COLOR=_LAB_COLOR(nth),/DATA,CHARSIZE=_LAB_SIZE(nth),CHARTHICK=_LAB_THICK(nth)
				ENDELSE
	 	 ENDFOR

		ENDIF ELSE BEGIN

;			===> Show Bias color in the Label
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR nth = 0L,N_NAME-1L DO BEGIN
				alabel=LABEL(nth)
				BIAS_COLOR = min_color > intercept+slope*BIAS(nth)  < max_color
;				===> Plot the Label Letter at the center of the coordinate
;				===> Use XYOUTS_CHAR if this alabel is text or use PLOTS if it is a plot symbol
				IF STRLEN(alabel) EQ 2 AND STRMID(alabel,0,1) EQ '#'  THEN BEGIN
					alabel = STRMID(alabel,1)	; Remove the # from alabel
					PLOTS, xy(0,nth),xy(1,nth), PSYM=alabel,COLOR=BIAS_COLOR,/DATA,SYMSIZE=_LAB_SIZE(nth),THICK=_LAB_THICK(nth)
				ENDIF ELSE BEGIN
					ok = WHERE(char_align.char EQ alabel,count) & IF count NE 1 THEN CONTINUE ; >>>>>>>>>>>>
					align = [char_align(ok).x, char_align(ok).y]
					XYOUTS_CHAR,xy(0,nth),xy(1,nth),alabel,ALIGN=align,COLOR=BIAS_COLOR,/DATA,CHARSIZE=_LAB_SIZE(nth),CHARTHICK=_LAB_THICK(nth)
				ENDELSE

	 	 	ENDFOR
		ENDELSE; 	IF KEYWORD_SET(BI_CIRCLE) THEN BEGIN

	ENDIF ELSE BEGIN ; IF PLOT_BIAS EQ 1 THEN BEGIN


;		===> Recall PAL_PLOT
		CALL_PROCEDURE,_PAL_PLOT

;		===> No Bias shown, Just show the Labels using the color provided in _LAB_COLOR
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR nth = 0L,N_NAME-1L DO BEGIN
			alabel=LABEL(nth)

;		===> Plot the Label Letter at the center of the coordinate
 			;				===> Use XYOUTS_CHAR if this alabel is text or use PLOTS if it is a plot symbol
				IF STRLEN(alabel) EQ 2 AND STRMID(alabel,0,1) EQ '#'  THEN BEGIN
					alabel = STRMID(alabel,1)	; Remove the # from alabel
					PLOTS, xy(0,nth),xy(1,nth), PSYM=alabel,COLOR=_LAB_COLOR(nth),/DATA,SYMSIZE=_LAB_SIZE(nth),THICK=_LAB_THICK(nth)
				ENDIF ELSE BEGIN
					ok = WHERE(char_align.char EQ alabel,count) & IF count NE 1 THEN CONTINUE ; >>>>>>>>>>>>
					align = [char_align(ok).x, char_align(ok).y]
					XYOUTS_CHAR,xy(0,nth),xy(1,nth),alabel,ALIGN=align,COLOR=_LAB_COLOR(nth),/DATA,CHARSIZE=_LAB_SIZE(nth),CHARTHICK=_LAB_THICK(nth)
				ENDELSE

	 	ENDFOR
	ENDELSE ; IF NOT KEYWORD_SET(PLOT_BIAS) THEN BEGIN


	CALL_PROCEDURE,_PAL_PLOT

;	****************************************
;	*** Plot the Table of Labels & Names ***
;	****************************************
;	===> Determine table y-character size in normal units
  char_y_normal = _TAB_CHARSIZE*(!D.Y_CH_SIZE/FLOAT(!D.Y_SIZE))

;	===> Convert char_y_normal to char_y_data coordinates
	xyz   = CONVERT_COORD([0.5,0.5],[0.5,0.5+char_y_normal],/NORMAL,/TO_DATA)
	char_y_data = SPAN(xyZ(1,*))

;	===> Convert upper left corner position of table from plot-window coordinates to data coordinates
	xp = _TAB_POSITION(0)
	yp = _TAB_POSITION(1)
	xydata = COORD_2PLOT(xp,yp,/TO_DATA)

;	===> Determine the x-offset for the NAMES (in plot coordinate)
	XYOUTS,/DATA,-10,-10, STRMID(NAME(0),0,1),CHARSIZE=CHARSIZE,WIDTH=X_offset

;	===> offset between the LABEL and NAME in Characters
	X_offset = X_offset*2.4
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_NAME-1 DO BEGIN
		ANAME = NAME(nth)
		ANAME = '  '+ANAME
		alabel = LABEL(nth)

;		===> Use XYOUTS2 if this alabel is text or use PLOTS if it is a plot symbol
		IF STRLEN(alabel) EQ 2 AND STRMID(alabel,0,1) EQ '#'  THEN BEGIN
			alabel = STRMID(alabel,1)	; Remove the # from alabel
			PLOTS, xydata.x,xydata.y, PSYM=alabel,/DATA,COLOR=_TAB_COLOR,SYMSIZE= _TAB_CHARSIZE,THICK=_LAB_THICK(nth)
		ENDIF ELSE BEGIN
			XYOUTS2,xydata.x,xydata.y, alabel,/DATA, ALIGN=[0.5,0.5],COLOR=_TAB_COLOR,CHARSIZE= _TAB_CHARSIZE
		ENDELSE
;		===> Use XYOUTS2 to plot aname to the right of the label
		XYOUTS2, xydata.x+ x_offset,xydata.y, ANAME,/DATA, ALIGN=[0.0,0.5],COLOR=_TAB_COLOR,CHARSIZE= _TAB_CHARSIZE,CHARTHICK=_LAB_THICK(nth)

;		===> Decrease y-position in Data units
		xydata.y =  (xydata.y - char_y_data)
	ENDFOR



	END; #####################  End of Routine ################################


