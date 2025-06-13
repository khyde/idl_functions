; $ID:	ARROW_OPEN.PRO,	2020-07-08-15,	USER-KJWH	$
  PRO arrow_open,ANGLE=angle, ASPECT=aspect, ALIGN=align, _extra=_extra

;+
; NAME:
;       arrow_open
;
;	PURPOSE: This program Creates an Open Arrow Symbol for subsequent use by IDL Plot commands
;
;	KEYWORDS:
;		ASPECT: Aspect ratio of y:x  is used to elongate or shorten arror
;		ALIGN: Default is the tip of the arrow will be at the x,y location when the symbol us called by PLOT
;					 align=0.5 = The Tip of the arrow will be centered on the x,y coordinates issued to the plot command
;					 align=1.0 = The Base of the arrow will be centered on the x,y coordinates issued to the plot command

;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, April 9, 1994.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;
;-

; ====================>
  IF N_ELEMENTS(ANGLE) EQ 0 THEN _ANGLE = 0 ELSE _ANGLE = -1.0*ANGLE
  IF N_ELEMENTS(ASPECT) EQ 0 THEN _ASPECT = 1 ELSE _ASPECT = ASPECT

  x= [-1, 0, 1, 0.5,0.5,-0.5, -0.5, -1]
  y= [0,  1, 0, 0, -1,  -1,    0,    0]

  y=_aspect*y

	xX   = x*COS(_ANGLE*!DTOR) - Y*SIN(_ANGLE*!DTOR)
	yY   = X*SIN(_ANGLE*!DTOR) + Y*COS(_ANGLE*!DTOR)

  y_tip =  yy[1]
	x_tip =  xx[1]

	y_base =  ((yy(4)+yy(5))/2)
	x_base =  ((xx(4)+xx(5))/2)


  IF N_ELEMENTS(ALIGN) NE 1 THEN _ALIGN = 0.5 ELSE _ALIGN = ALIGN
  	XXX = X_TIP-  _ALIGN*(x_tip-x_base)
  	YYY = Y_TIP-  _ALIGN*(y_tip-y_base)
  	YY = YY - YYY
  	XX = XX - XXX

;;; translation
;;  IF KEYWORD_SET(TIP) THEN BEGIN
;;		yy=yy-yy[1]
;;		xx=xx-xx[1]
;;  ENDIF
;;
;;; translation
;;  IF KEYWORD_SET(BASE) THEN BEGIN
;;		yy=yy- ((yy(4)+yy(5))/2)
;;		xx=xx- ((xx(4)+xx(5))/2)
;;  ENDIF
;;


 	USERSYM,XX,YY,COLOR=!P.COLOR,THICK=1,_extra=_extra

  END; END OF PROGRAM
