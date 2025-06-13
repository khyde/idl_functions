; $Id: FRESNEL.pro $
;+
;	This Function Returns the Reflectivity (R) of a plane of water surface for unpolarized light
; SYNTAX:
;	Result = FRESNEL(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;
; NOTES:
; 	Reference: Handbook of Marine Science, 1974, Volume I, F.G. Walton Smith, CRC Press, Inc., Table 3.2-4, page 191.

; VERSION:
;		Jan 01,2001
; HISTORY:
;		Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

pro FRESNEL
  ROUTINE_NAME='FRESNEL'
; ************************************************************************
; ****************** Reflectivity of a water surface  table 3.2-4 ********
; ************************************************************************
  ; n = sin i/ sin r
  i = [0.000001, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 85.0, 90.0]
  i=DOUBLE(i)
  n=1.333 ; index of refraction for pure water (1.3398 for seawater)
  sinr = sin(i*!DTOR)/n
  r    = ASIN(sinr)/!DTOR
  PRINT, R

  A=(SIN(!DTOR*(i-r))^2)/(SIN(!DTOR*(i+r))^2)
  B=(TAN(!DTOR*(i-r))^2)/(TAN(!DTOR*(i+r))^2)
  R = 0.5*( A + B)

  print,r
END; #####################  End of Routine ################################
