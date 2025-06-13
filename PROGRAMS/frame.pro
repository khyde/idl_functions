; $ID:	FRAME.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO FRAME, COLOR=color,THICK=THICK, IM=im, GRACE=GRACE, PAGE=page,REGION=region,PLOT=plot,_EXTRA=_extra
;+
; NAME:
;       frame
;
; PURPOSE:
;       Draw a frame around the current graphics PLOT, REGION, OR PAGE window
;    		or around an 2-D ARRAY
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       frame
;       frame,3
;       frame,2,color=128
;
;       test = DIST(512)
;       frame,5,im=TEST,COLOR=255
;       TV, TEST
;       Control color and linestyle by using graphics keywords
; INPUTS:
;       None Required for framing a graphics window
;       Default frame THICK is 1 pixel wide
;       Default color is !P.color
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       Draws a frame on the current graphics device
;  or   around an image if im keyword used
;
; SIDE EFFECTS:
;       If keyword IM then image is modified by frame.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Apr 15, 1995.
;       August 18, 1997 Modified to frame images or current graphics window.
;       Dec 16,1998 Added grace capability
;				March 21,2003 jor added Region, Plot, Page Capability
;-

; =====> Default THICK is 1 pixel
 ROUTINE_NAME='BACKGROUND'
  IF N_ELEMENTS(COLOR) NE 1 THEN COLOR = 0 ELSE COLOR = COLOR
  IF N_ELEMENTS(THICK) NE 1 THEN THICK = 1 ELSE THICK = FIX(THICK)

; =====>Default Grace is 0 pixels
  IF N_ELEMENTS(GRACE) EQ 0 THEN GRACE = [0,0,0,0]
  IF N_ELEMENTS(GRACE) EQ 1 THEN GRACE = [GRACE,GRACE,GRACE,GRACE]

; =====> Check if an image was provided,If so, then draw the frame around the image and return
  IF KEYWORD_SET(IM) THEN BEGIN
    s=SIZE(IM)
    IF S[0] EQ 2 THEN BEGIN
      _PX = S[1]-1  & _PY = S(2)-1
      THICK = THICK -1
      IM(0+GRACE[0]:THICK+GRACE[0],GRACE(2):_PY-GRACE(3))       		= COLOR  ; Left
      IM((_PX-THICK-GRACE[1]):_px-GRACE[1],GRACE(2):_PY-GRACE(3)) 	= COLOR  ; Right
      IM(GRACE[0]:_PX-GRACE[1],0+GRACE(2):THICK+GRACE(2))       		= COLOR  ; Bottom
      IM(GRACE[0]:_PX-GRACE[1],(_PY-THICK-GRACE(3)):_PY-GRACE(3)) 	= COLOR  ; Top
      RETURN
      ENDIF ELSE MESSAGE,'ERROR: Image must be a 2 dimensional array'
    ENDIF


;	=====> Plot
	IF KEYWORD_SET(PLOT) THEN BEGIN
		X = !X.CRANGE & Y = !Y.CRANGE
  	IF !X.TYPE EQ 1 THEN X= 10.0^X
  	IF !Y.TYPE EQ 1 THEN Y= 10.0^Y
  	PLOTS, [X[1],X[1],X[0],X[0],X[1]],$
  				 [Y[1],Y[0],Y[0],Y[1],Y[1]],$
  					/DATA,COLOR=COLOR,THICK=thick,_EXTRA=_extra
 		RETURN
  ENDIF

;	=====> Page
	IF KEYWORD_SET(PAGE) THEN BEGIN
  FOR THICK = 0,THICK-1 DO BEGIN
    xL=0+THICK+GRACE[0]
    xR=!D.X_SIZE-THICK-1-GRACE[1]

    yB=0+THICK+GRACE(2)
    yT=!D.Y_SIZE-THICK-1-GRACE(3)
    PLOTS,[xL,xL,xR,xR, xL ],$
          [yB,yT,yT,yB, yB ],$
          /DEVICE,COLOR=COLOR,_EXTRA = _extra
    ENDFOR
 		RETURN
  ENDIF

;	=====> Region
	IF KEYWORD_SET(REGION)	THEN BEGIN
		X = !X.REGION & Y = !Y.REGION
		PLOTS,	[X[1],X[1],X[0],X[0],X[1]],$
  					[Y[1],Y[0],Y[0],Y[1],Y[1]],/NORMAL,COLOR=COLOR,_EXTRA=_extra
  	RETURN
	ENDIF

  END; End of Program
