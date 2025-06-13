; $ID:	LINE_BISECT.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION LINE_BISECT, X,Y, WIDTH=WIDTH
;+
; NAME:
; 	PNT_LINE_BISECT

;		This Function Returns the x,y coordinates that bisect the line formed by X,Y, and the coordinates of pixels
;		at the center and around (on either side) the bisection point based on the value of WIDTH.

; MODIFICATION HISTORY:
;		Written Jan 31, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='LINE_BISECT'

	IF N_ELEMENTS(X) NE 2 AND N_ELEMENTS(Y) NE 2 THEN BEGIN
		PRINT,'ERROR: Must provide [x1,x2],[y1,y2]
		RETURN,-1
	ENDIF

;	===> Compute Slope for x,y
	SLOPE = [Y[1]-Y[0]]/[X[1]-X[0]]
	SLOPE=SLOPE[0]

;	===> Compute Mean x , y
	MEAN_X= TOTAL(MINMAX(X))/2.0
	MEAN_Y= TOTAL(MINMAX(Y))/2.0

;	===> Compute intercept for x,y
	INT = MEAN_Y - MEAN_X*SLOPE

;	===> Check Slope and adjust inverse slope as required
	IF FINITE(SLOPE) EQ 0 THEN BEGIN
	  INV_SLOPE = 0.0
	ENDIF ELSE BEGIN
		IF SLOPE EQ 0 THEN BEGIN
		  INV_SLOPE = 1.0E32
		ENDIF ELSE BEGIN
			INV_SLOPE = -(1./SLOPE)
		ENDELSE
	ENDELSE

;	===> Derive slope and intercept for perpendicular
 	YY = (INV_SLOPE * (X-MEAN_X)) +MEAN_Y
 	INV_INT = MEAN_Y - MEAN_X*INV_SLOPE


	IF N_ELEMENTS(WIDTH) NE 1 THEN _WIDTH = 1 ELSE _WIDTH = WIDTH

;	===> Around is always at least zero
	AROUND = (_WIDTH / 2) > 0


;	===> Determine if the x or y has a steeper rise and interpolate over the intervals
  IF SPAN(X) GE SPAN(YY) THEN BEGIN
		XXX = INTERVAL( [ MEAN_X-AROUND, MEAN_X+AROUND])
		YYY =  INV_INT +  INV_SLOPE*XXX
	ENDIF ELSE BEGIN
	 	YYY = INTERVAL( [MEAN_Y-AROUND, MEAN_Y+AROUND])
		XXX = (YYY- INV_INT)/ INV_SLOPE

;		TESTING
		XXX = REVERSE(XXX)
		YYY = REVERSE(YYY)

	ENDELSE


;	===> Stuff into a structure
	RETURN,CREATE_STRUCT('X',X,'Y',YY,'MEAN_X',MEAN_X,'MEAN_Y',MEAN_Y,'INT',INV_INT,'SLOPE',INV_SLOPE,'XP',XXX,'YP',YYY)

END; #####################  End of Routine ################################



