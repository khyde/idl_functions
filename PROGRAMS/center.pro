; $Id:	CENTER.PRO,	2003 Dec 02 15:41	$

 FUNCTION CENTER, X,Y
;+
; NAME:
;       CENTER
;
; PURPOSE:
;				Calculate Center of Mass of x,y points
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 8,2003
;       FROM: http://www.dfanning.com/ip_tips/fit_ellipse.html
;
;-

ROUTINE_NAME='CENTER'

XSIZE=(MAX(X)-MIN(X)+1)
YSIZE=(MAX(Y)-MIN(Y)+1)
IMAGE = BYTARR(XSIZE,YSIZE)
IMAGE(X,Y)=1


INDICES = WHERE(IMAGE EQ 1)


	 array = BytArr(xsize, ysize)
   array[indices] = 255B
   totalMass = Total(array)
   xcm = Total( Total(array, 2) * Indgen(xsize) ) / totalMass
   ycm = Total( Total(array, 1) * Indgen(ysize) ) / totalMass
   center = [MIN(X)+ xcm,  MIN(Y)+ycm]
   RETURN, CENTER



;  Thanks to David Foster at UCSD for this algorithm. You can use this Centroid program to return a two-element array containing the center of mass of a 2D array. The program code is extremely simple.

;   FUNCTION Centroid, array
;   s = Size(array, /Dimensions)
;   totalMass = Total(array)
;   xcm = Total( Total(array, 2) * Indgen(s[0]) ) / totalMass
;   ycm = Total( Total(array, 1) * Indgen(s[1]) ) / totalMass
;   RETURN, [xcm, ycm]
;   END



END; #####################  End of Routine ################################



