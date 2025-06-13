
;		ERROR....
; $Id:	circles_intersection.pro,	March 07 2007	$
;	KEYWORD PARAMETERS:
;		ERROR.

	FUNCTION CIRCLES_INTERSECTION, 	CENTER_1=center_1,RADIUS_1=radius_1, $
																	CENTER_2=center_2,RADIUS_2=radius_2, ERROR = error

;+
; NAME:
;		CIRCLES_INTERSECTION
;
; PURPOSE:
;		This function determines the coordinates where two circles intersect
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE:
;
;		Result = CIRCLES_INTERSECTION(CENTER_1=center_1,RADIUS_1=radius_1, CENTER_2=center_2, RADIUS_2=radius_2)
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;	KEYWORD PARAMETERS:
;		CENTER_1.	The center [x,y] coordinates for Circle_1
;		RADIUS_1.	The radius (r) for Circle_1
;		CENTER_2.	The center [x,y] coordinates for Circle_2
;		RADIUS_2.	The radius (r) for Circle_2
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns the x,y coordinates of the intersections of the two circles
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;

;	Result = circles_intersection(Center_1=[0,0], radius_1=2.0, Center_2 = [1,0], radius_2 = 2)
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Formula from: Doctor Peterson, The Math Forum, 'Intersection of Circles', http://mathforum.org/dr.math/
;
;
; MODIFICATION HISTORY:
;
;			Written March 3, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CIRCLES_INTERSECTION'

 	cx_1= DOUBLE(Center_1(0))
	cy_1= DOUBLE(Center_1(1))
	r1 = DOUBLE(Radius_1)
	cx_2= Center_2(0)
	cy_2= Center_2(1)
	r2 =Radius_2

  x_dist = cx_2 - cx_1                          ;[difference in x coordinates]
  y_dist = cy_2 - cy_1                          ;[difference in y coordinates]
  p = SQRT(x_dist^2 + y_dist^2)                ;[distance between centers]
  k = (p^2 + r1^2 - r2^2)/(2*p)         ;[distance from center 1 to line
                                      ;joining points of intersection]
  x1 = cx_1 + x_dist*k/p + (y_dist/p)*sqrt(r1^2 - k^2)
  y1 = cy_1 + y_dist*k/p - (x_dist/p)*sqrt(r1^2 - k^2)

  x2 = cx_1 + x_dist*k/p - (y_dist/p)*sqrt(r1^2 - k^2)
  y2 = cy_1 + y_dist*k/p + (x_dist/p)*sqrt(r1^2 - k^2)


	STRUCT= REPLICATE(CREATE_STRUCT('X',0.0,'Y',0.0),2)
  STRUCT(0).X = X1
  STRUCT(0).Y = Y1
  STRUCT(1).X = X2
  STRUCT(1).Y = Y2

	RETURN,STRUCT





	END; #####################  End of Routine ################################
