; $Id: SMOOTH_AYEAR.pro,  DEC 27,1999  J.E.O'Reilly Exp $

 PRO SMOOTH_AYEAR, DOY=doy, DATA=data, FRACTION=fraction, TIMES = times
;+
; NAME:
;       PROGRAM SMOOTH_AYEAR
;
; PURPOSE:
;       Smooth a single synthetic year time series
;       by first concatenating series so that artifacts at the ends (Jan, Dec)
;       of the time series are avoided.
;
; CATEGORY:
;       Statistics
;
; CALLING SEQUENCE:
;       SMOOTH_AYEAR, DOY=DOY,DATA=data, FRACTION=fraction
;
; INPUTS:
;       doy : 		day of year (values between 1 and 366)
;       data: 		y-axis data to be smoothed

;
; KEYWORD PARAMETERS:
;       fraction: 	Fraction of data points for SMOOTH
;					Default for program is 1/12th.
;
;       REPEAT:     Repeats smoothing process REPEAT TIMES (DEFAULT = 1X)
; OUTPUTS:
;       A 2-dimensional array of x,y  where x=input day and y = input data
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       .
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, December 19,1997
;       Dec 27,1999 added REPEAT
;-



  AGAIN:
; ====================>
; Sort day of year in ascending order
  S = SORT(doy)
  x = doy(s)
; Sort data in same order as doy
  Y = data(s)

  N = N_ELEMENTS(y)

; ===================>
; Concatenate data
  y = [y,y,y]

; ================>
; If fraction not provided then default is 1/12.0
  IF N_ELEMENTS(fraction)EQ 0 THEN FRACTION = 1.0/12.0

  NPTS = N*FRACTION
; =================>
; Use IDL function SMOOTH
  Ysmooth = SMOOTH(Y,NPTS)

; ================>
; Make a 2-dimensional array with doy and data
;  xy = DBLARR(2,N)
;  xy(0,*) = x
;  xy(1,*) = ysmooth(n:2*n-1L)

  DOY = X
  DATA = ysmooth(n:2*n-1L)

  IF N_ELEMENTS(TIMES) GE 1 THEN BEGIN
    IF TIMES GE 1 THEN BEGIN
      TIMES = TIMES -1
      GOTO, AGAIN
    ENDIF
  ENDIF


  END; END OF PROGRAM