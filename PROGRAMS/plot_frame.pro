; $ID:	PLOT_FRAME.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Program Plots a FRAME around the curent plot window
;
;
; HISTORY:
;		March 19,2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO PLOT_FRAME,COLOR,THICK=thick,_EXTRA=_extra
  ROUTINE_NAME='PLOT_FRAME'
  IF N_ELEMENTS(COLOR) NE 1 THEN COLOR = 0
  X = !X.CRANGE & Y = !Y.CRANGE
  IF !X.TYPE EQ 1 THEN X= 10.0^X
  IF !Y.TYPE EQ 1 THEN Y= 10.0^Y

  	PLOTS, [X[1],X[1],X[0],X[0],X[1]],$
  				 [Y[1],Y[0],Y[0],Y[1],Y[1]],$
  					/DATA,COLOR=COLOR,THICK=thick,_EXTRA=_extra


END; #####################  End of Routine ################################
