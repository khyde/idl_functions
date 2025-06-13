; $Id:	xyouts2.pro,	February 07 2007	$
	PRO XYOUTS2, X,Y,TXT, $
								CHARSIZE=charsize, ALIGN=align, BACKGROUND=background, $
								DATA=data,NORMAL=normal,DEVICE=device, $
							  LINESPACE=linespace,GRACE=grace,$
							  POS_LAST=pos_last, $
							  WIDTH=width, _EXTRA=_extra, ERROR=error
;+
; NAME:
;		XYOUTS2
;
; PURPOSE:
;		This Procedure is calls IDL's XYOUT but allows both horizontal and vertical ALIGNMENT of Text
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		XYOUTS2,X,Y,TXT
;
;	INPUTS:
;		X.......... X Coordinate
;		Y.......... Y Coordinate
;		Txt........ Text (passed to XYOUTS
;
;	KEYWORD PARAMETERS:
;		CHARSIZE... Character size (Passed to XYOUTS)
;		ALIGN...... Text Alignment [Horizontal, Vertical] Relative Units (0 to 1.0)
;		BACKGROUND. Set the area under the txt to the color value of BACKGROUND (Default=!P.background) then add txt
;
;		DATA....... X,Y in Data Units
;		NORMAL..... X,Y in Normal Units
;		DEVICE..... X,Y in Device Units
;		LINESPACE.. The space (fraction of the character height)
;								between each line of text when "!C" is embedded in the text'
;							  (default = 0.7).  Used when /BACKGROUND is set
;		GRACE...... The fraction of the character width and height which will be set to background color
;								when /BACKGROUND is set. (default = [0.05,0.05])
;		WIDTH......	Width of character as returned by XYOUTS.PRO
;		_EXTRA..... Undefined Keywords Passed to XYOUTS
;
; OUTPUTS:
;		This procedure draws on the default graphics device using  XYOUTS
;	OPTIONAL OUTPUTS:
;		ERROR:			If errors are encountered then error will contain the error message else error = ''
;		POS_LAST... The last position in normal coordinates when /BACKGROUND is set
;
; EXAMPLE:
;
;	RESTRICTIONS:
;		THIS ROUTINE IS STILL A 'WORK IN PROGRESS'
;		Works well with FONTS,'TIMES' and other TrueType Fonts, not as well with other fonts.
;
;	  There are some issues in how "!C" is handled by IDL, e.g. when  TXT = 'XX!CXX!CX!CXq'
;		Lower Case letters (g j p q y) will not be centered properly in the vertical direction when align = [0.5,0.5]
;
; MODIFICATION HISTORY:
;			Feb 10,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
  ROUTINE_NAME='XYOUTS2'
  ERROR = ''

	IF N_ELEMENTS(X) EQ 0 OR N_ELEMENTS(Y) EQ 0 OR N_ELEMENTS(X) NE N_ELEMENTS(Y) THEN BEGIN
    ERROR='Must provide X,Y  OR X,Y,Z Normal coordinates'
    RETURN
  ENDIF

  IF N_ELEMENTS(GRACE) NE 2 		THEN _GRACE = [0.05,0.05] ELSE _GRACE = GRACE

  IF N_ELEMENTS(BACKGROUND) EQ 1 THEN 	DO_BACKGROUND = 1  ELSE 	DO_BACKGROUND = 0



;	===> IF TXT is numeric then use STRTRIM
	IF NUMERIC(TXT) EQ 1 THEN _TXT = STRTRIM(TXT,2) ELSE _TXT = TXT

	IF N_ELEMENTS(CHARSIZE) EQ 1 THEN _CHARSIZE=CHARSIZE ELSE _CHARSIZE = 1.0

	CHAR_XSIZE 	= _CHARSIZE*FLOAT(!D.X_CH_SIZE)/FLOAT(!D.X_SIZE) ; Normal units

	D_FACTOR = (FLOAT(!D.X_CH_SIZE)/FLOAT(!D.Y_CH_SIZE))
	P_FACTOR = 1.0

 	CASE !P.FONT OF
		'-1': BEGIN
    	D_FACTOR = 0.75
    	IF N_ELEMENTS(LINESPACE) NE 1 THEN _LINESPACE = .4 ELSE _LINESPACE = LINESPACE
    	FRACTION_BELOW = D_FACTOR*0.4
  	END

    '0': BEGIN
    IF !D.FLAGS AND 1 EQ 1 THEN P_FACTOR = (FLOAT(!D.X_SIZE)/FLOAT(!D.Y_SIZE))
    IF N_ELEMENTS(LINESPACE) NE 1 THEN _LINESPACE = .3 ELSE _LINESPACE = LINESPACE
  	FRACTION_BELOW = 0.20
    END

    '1': BEGIN
    IF N_ELEMENTS(LINESPACE) NE 1 THEN _LINESPACE = .60 ELSE _LINESPACE = LINESPACE
  	FRACTION_BELOW = 1- 0.90*D_FACTOR
    END
  ENDCASE

  FACTOR = D_FACTOR * P_FACTOR
 	CHAR_YSIZE 	= FACTOR * (_CHARSIZE*!D.Y_CH_SIZE/FLOAT(!D.Y_SIZE))


	FOR NTH = 0L,N_ELEMENTS(X)-1L DO BEGIN

;	****************************************************
;	*** Convert X,Y from Data to Normal Coordinates  ***
;	****************************************************
	XYZ=CONVERT_COORD(X(NTH),Y(NTH),DATA=DATA,DEVICE=device,NORMAL=normal,/TO_NORMAL)
	XNORMAL = REFORM(XYZ(0,*))
	YNORMAL = REFORM(XYZ(1,*))
	IF N_ELEMENTS(ALIGN) EQ 2 THEN BEGIN
		_ALIGN = ALIGN(0)
		YNORMAL = YNORMAL - ALIGN(1)*CHAR_YSIZE
	ENDIF

	IF N_ELEMENTS(ALIGN) EQ 1 THEN _ALIGN = ALIGN
	IF N_ELEMENTS(_ALIGN) EQ 0 THEN _ALIGN  = 0

;		===> Determine width of text string (width will be compensated for any !C
 		XYOUTS,/NORM,-10,-10,_TXT(NTH),CHARSIZE=CHARSIZE,WIDTH=CHARWIDTH
		left 		= XNORMAL  - CHARWIDTH*_ALIGN(0)
		right 	= XNORMAL  + CHARWIDTH*(1.0-_ALIGN(0))
		bot			= YNORMAL
		top 		= YNORMAL  + CHAR_YSIZE
		POS_LAST = [LEFT,BOT,RIGHT,TOP]



;	********************************
	IF DO_BACKGROUND EQ 1 THEN BEGIN
;	********************************
		left 		= left		- 	_GRACE(0)*CHARWIDTH
		right 	= right 	+ 	_GRACE(0)*CHARWIDTH
		bot			= bot		  - 	_GRACE(1)*CHAR_YSIZE
		top 		= top			+ 	_GRACE(1)*CHAR_YSIZE

;		===> Determine number of text lines based on '!C' delimiters
;				 and adjust bot to deal with the vertically arranged text
		CTXT=STRSPLIT(_TXT(NTH),'!C',/REGEX,/EXTRACT,/PRESERVE_NULL)

		IF N_ELEMENTS(CTXT) GT 1 THEN BEGIN
			bot = bot -1.0 * (FLOAT(N_ELEMENTS(CTXT)-1)* (CHAR_YSIZE + _LINESPACE*CHAR_YSIZE ))
		ENDIF

;		===> See if the last line of CTXT has any special lower case characters (g j p q y)
		LTXT = STRSPLIT(LAST(CTXT),'gjpqy',/EXTRACT,/PRESERVE_NULL)

;		===> See if the last line of CTXT has any special Upper case characters (Q)
		UTXT = STRSPLIT(LAST(CTXT),'Q',/EXTRACT,/PRESERVE_NULL)

		IF N_ELEMENTS(UTXT) EQ 1 AND N_ELEMENTS(LTXT) GT 1 THEN bot = bot - FRACTION_BELOW*CHAR_YSIZE
		IF N_ELEMENTS(UTXT) GE 1 AND N_ELEMENTS(LTXT) GT 1 THEN bot = bot - FRACTION_BELOW*CHAR_YSIZE
		IF N_ELEMENTS(UTXT) GE 1 AND N_ELEMENTS(LTXT) EQ 1 THEN bot = bot - FRACTION_BELOW*CHAR_YSIZE*0.4


;		===> Fill 'behind' the text with the background
		POLYFILL, /norm, [left,right,right,left,left],[bot,bot,top,top,bot] ,color= BACKGROUND
		POS_LAST(1) = BOT
		POS_LAST(3) = TOP


	ENDIF

;	===> Pass to IDL's XYOUTS
  XYOUTS,XNORMAL,YNORMAL,_TXT(NTH),/NORMAL,CHARSIZE= _charsize, ALIGN= _align,WIDTH=CHARWIDTH, _EXTRA=_extra

	ENDFOR

	WIDTH=CHARWIDTH
 DONE:

END; #####################  End of Routine ################################
