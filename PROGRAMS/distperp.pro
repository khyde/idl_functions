; $Id: distperp.pro,v 1.0 1996/08/20 12:00:00 J.E.O'Reilly Exp $
  FUNCTION DISTPERP, XARRAY,YARRAY, YINTERCEPT, SLOPE
;+
; NAME:
;       distperp
;
; PURPOSE:
;       Compute Perpendicular distances of points from a straight line
;
; CATEGORY:
;       Geometry
;
; CALLING SEQUENCE:
;       Result = distperp(1,1,1,1)
;
; INPUTS:
;       Individual x,y or matched arrays of x,y and the
;       Y-Intercept and slope of a line (e.g. regression line)
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       Perpendicular distances of x,y coordinates from the line
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
;       Written by:  J.E.O'Reilly, August 20, 1996
;                    Patterned after a segement from program: xyfit.pro (H.T. Freudenreich)
;-

; ===================>
; Check parameters
  IF N_PARAMS() NE 4 THEN MESSAGE,'ERROR, MUST PROVIDE X,Y, Y-INTERCEPT,SLOPE'
  IF N_ELEMENTS(XARRAY) NE N_ELEMENTS(YARRAY) THEN MESSAGE,'ERROR X AND Y ARRAYS MUST BE SAME SIZE'

  R=SQRT(1.+SLOPE^2)
  IF YINTERCEPT GT 0. THEN R= -R
  U1=SLOPE/R
  U2=-1./R
  U3=YINTERCEPT/R

  DISTANCE=U1*XARRAY+U2*YARRAY+U3  ; Perpendicular distance of points to line
  RETURN, DISTANCE
  END
