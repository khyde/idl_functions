; $ID:	BOXCONV.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION BOXCONV, DATA, WIDTH , FILT=FILT
;+
; NAME:
;       BOXCONV
;
; PURPOSE:
;				Smooth a 1-d data series using a BOX CONVOLUTION Filter
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;       NONE
;
; KEYWORD PARAMETERS:
;       FILT:  OUTPUT ONLY (THE DANIELL FILTER)
; OUTPUTS:
;
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
;				FROM: http:/sepwww.sanford.edu/sep/prof/pvi/zp/paper_html/node6.html
;       Written by:  J.E.O'Reilly, Feb 7, 2004
;-

	ROUTINE_NAME='BOXCONV'

	IF N_ELEMENTS(WIDTH) NE 1 THEN WIDTH=5

;	Restriction:
	WIDTH = WIDTH > 3

	xx=data
	nb=width
	nx=N_ELEMENTS(DATA)
	ny=	nx+nb-1
	bb=FLTARR(nx+nb)
	yy=FLTARR(nx+nb-1)

  bb[0] = xx[0]

	FOR i = 1,nx-1	DO bb(i) = bb(i-1) + xx(i)
	FOR i = nx,ny-1 DO bb(i) = bb(i-1)

	FOR i = 0,nb-1 	DO yy(i) = bb(i)
	FOR i = nb,ny-1 DO yy(i) = bb(i) - bb(i-nb)

	yy=yy/nb



 RETURN,YY





END; #####################  End of Routine ################################



