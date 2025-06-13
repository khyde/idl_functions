; $ID:	COLOR_CIRCLEL_SCALE.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO COLOR_CIRCLE_SCALE, SHIFT=shift,ERROR = error

;+
; NAME:
;		COLOR_CIRCLE_SCALE
;
; PURPOSE:
;		This procedure draws a Circular Color Scale
;
; CATEGORY:
;		PLOT
;
; CALLING SEQUENCE:

;
;		COLOR_CIRCLE_SCALE, Parameter1, Parameter2, Foobar
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	PROCEDURE:
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jan 15, 2006  by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'COLOR_CIRCLE_SCALE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

	IF N_ELEMENTS(SHIFT) EQ 0 THEN _SHIFT = 0 ELSE _SHIFT = SHIFT


 	;PSPRINT,/COLOR ,/FULL

 	psave = !P
 	xsave = !X
	ysave = !Y
	zsave = !Z

 	WIN, [600,600]
 	plot, xcircle,ycircle,/NORMAL

  PAL_SW3
;	===> Get the aspect ratio of the current graphics device
	aspect = FLOAT(!d.y_size) / FLOAT(!d.x_size)

stop

;	******************************
;	*** Define the unit circle ***
;	******************************
	n_circle = 360 ; resolution
	rad = FINDGEN(n_circle+1) * (!PI*2/n_circle)
	xcircle= SIN(rad)
	ycircle= COS(rad)

;	===> Normally our NARR palettes reserve 0 and 251-255 for annotations
	IF N_ELEMENTS(BOT_COLOR) NE 1 THEN BOT_COLOR = 1
	IF N_ELEMENTS(TOP_COLOR) NE 1 THEN TOP_COLOR = 250

  BOT_COLOR = 21
  TOP_COLOR = 250


;	===> Get colors for each arc
	COLORS = INTERPOL([BOT_COLOR,TOP_COLOR],N_CIRCLE)

  COLORS=REVERSE(COLORS)
  COLORS=SHIFT(COLORS,_SHIFT)


	FOR NTH = 0L,N_CIRCLE-1L DO BEGIN
		X = [0, XCIRCLE[NTH],XCIRCLE(NTH+1),0]
		Y = [0, YCIRCLE[NTH],YCIRCLE(NTH+1),0]/ASPECT
		POLYFILL,X,Y,COLOR= TC(COLORS[NTH])
	ENDFOR
	;PSPRINT
	STOP

  !P=	psave
 	!X= xsave
	!Y= ysave
	!Z= zsave
stop





	END; #####################  End of Routine ################################
