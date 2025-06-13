; $Id: I_SUN_KIRK_day_length.pro,   Aug 28, 2003 J.E.O'Reilly Exp $

  FUNCTION  I_SUN_KIRK_day_length, lat, DOY

;+
; NAME:
;       I_SUN_KIRK
;
; PURPOSE:
;       Calculate sun characteristics according to equations in:
;       Kirk, J.T.O, 1994, Light and photosynthesis in aquatic ecosystems,
;                          Cambridge University Press, 509pp.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       I_SUN_KIRK_day_length
;
;
; INPUTS:
;       latitude, day of year
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 27, 1999
;				Aug 28,2003 jor, constrained radians to -1 and 1 to eliminate acos() problems near poles.
;-

; ====================>
  IF N_ELEMENTS(LAT) EQ 0 THEN STOP
  IF N_ELEMENTS(DOY) EQ 0 THEN STOP




_DOY=DOUBLE(DOY)
_LAT=DOUBLE(LAT)
; ====================>
; Must have balanced arrays
  IF N_ELEMENTS(_LAT) GT 1 AND N_ELEMENTS(_DOY) EQ 1 THEN _DOY = REPLICATE(_DOY,N_ELEMENTS(_LAT))
  IF N_ELEMENTS(_DOY) GT 1 AND N_ELEMENTS(_LAT) EQ 1 THEN _LAT = REPLICATE(_LAT,N_ELEMENTS(_DOY))

;===> FIX WHEN LAT IS 2D

; ====================>
; SOLAR DECLINATION
; Kirk, 1994, pages 35-36
; delta (d) and (y) are in degrees
; y is an angle:  y = 360.0* (doy-1)/365.0  ; Jan 1st = 0 degrees
  y = 360.0d * (_DOY-1)/365
  Y = !DTOR*Y
  declination = 0.39637 - 22.9133*cos(y) + 4.02543*sin(y)-0.3872*cos(2*y)+0.052*sin(2*y)
; Declination (d) for southern hemisphere is same numerical value as northern but d is opposite sign

; ====================>
; DAY  LENGTH
; Kirk, 1994, page 40
  factor = 0.133333

;	===> Following equation gives Problem with ACOS of radians that are lt -1 or gt 1.0
; ===> So, confine rads to -1 and 1d
;   day_length = factor*  ACOS(-1d*TAN(_lat*!DTOR)*TAN(declination*!DTOR))/!DTOR


  RADS = (-1d*TAN(_lat*!DTOR)*TAN(declination*!DTOR))
 	RADS = RADS < 1D
  RADS = RADS > (-1D)

 	day_length = factor*  ACOS( RADS )  / !DTOR
  RETURN, day_length
  END; End of PROGRAm
