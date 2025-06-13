; $ID:	PLOT_BACKGROUND.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Program fills in the PLOT area with the background color
;	(Used with Postscript to plot atop a background other than the default white)
;
; HISTORY:
;		March 19,2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO PLOT_BACKGROUND,COLOR,PAGE=PAGE
  ROUTINE_NAME='PLOT_BACKGROUND'
  IF N_ELEMENTS(COLOR) NE 1 THEN COLOR = 254
  X = !X.CRANGE & Y = !Y.CRANGE
  IF !X.TYPE EQ 1 THEN X= 10.0^X
  IF !Y.TYPE EQ 1 THEN Y= 10.0^Y
  IF NOT KEYWORD_SET(PAGE) THEN BEGIN
  	POLYFILL, [X[1],X[1],X[0],X[0],X[1]],$
  						[Y[1],Y[0],Y[0],Y[1],Y[1]],$
  						/DATA,COLOR=COLOR
  ENDIF ELSE BEGIN
		POLYFILL, [1,1,0,0,1],[1,0,0,1,1],/NORMAL,COLOR=COLOR
	ENDELSE

END; #####################  End of Routine ################################
