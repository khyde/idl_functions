; $Id:	XYOUTS_CHAR.pro,	February 07 2007	$
	PRO XYOUTS_CHAR, X,Y,TXT, $
								CHARSIZE=charsize, ALIGN=align ,$
								DATA=data,NORMAL=normal,DEVICE=device, $
							   _EXTRA=_extra, ERROR=error
;+
; NAME:
;		XYOUTS_CHAR
;
; PURPOSE:
;		This Procedure is calls IDL's XYOUT but allows both horizontal and vertical ALIGNMENT of Text
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:
;
;		XYOUTS_CHAR,X,Y,TXT
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
  ROUTINE_NAME='XYOUTS_CHAR'
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

	CHAR_YSIZE 	= _CHARSIZE*FLOAT(!D.Y_CH_SIZE)/FLOAT(!D.Y_SIZE)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0L,N_ELEMENTS(X)-1L DO BEGIN

;		****************************************************
;		*** Convert X,Y from Data to Normal Coordinates  ***
;		****************************************************
		XYZ=CONVERT_COORD(X(NTH),Y(NTH),DATA=DATA,DEVICE=device,NORMAL=normal,/TO_NORMAL)
		XNORMAL = REFORM(XYZ(0,*))
		YNORMAL = REFORM(XYZ(1,*))


		XNORMAL = XNORMAL - ALIGN(0)*CHAR_XSIZE
		YNORMAL = YNORMAL - ALIGN(1)*CHAR_YSIZE





;		===> Pass to IDL's XYOUTS
  	XYOUTS,XNORMAL,YNORMAL,_TXT(NTH),/NORMAL,CHARSIZE= _charsize, WIDTH=CHARWIDTH, _EXTRA=_extra

	ENDFOR

	WIDTH=CHARWIDTH
 DONE:

END; #####################  End of Routine ################################
