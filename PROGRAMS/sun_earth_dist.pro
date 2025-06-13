; $Id:	SUN_EARTH_DIST.PRO,	2003 Oct 24 16:18	$
;+
;NAME:
;   SUN_EARTH_DIST
;
;PURPOSE:
;		Calculate the SUN to Earth Distance
;
;CATEGORY:
;
;CALLING SEQUENCE:
;		Result = SUN_EARTH_DIST(Doy)
;
;INPUTS:
;		Doy:	Day of Year (1-365 or 1-366)
;
;KEYWORDS:
;	None
;OUTPUTS:
;	Distance from Center of Sun to Center of Earth in Astronomical Units (AU).
;
;NOTES:
; MEAN EARTH-SUN DISTANCE
;	http://neo.jpl.nasa.gov/glossary/au.html
; 1 AU = 149,597,870.691 kilometers
; Technical Definition: AU is short for Astronomical Unit and defined as:
;	the radius of a Keplerian circular orbit of a point-mass having an orbital period of 2*(pi)/k days
;	(k is the Gaussian gravitational constant).
;	Since an AU is based on radius of a circular orbit,
;	one AU is actually slightly less than the average distance between the Earth and the Sun (approximately 150 million km or 93 million miles).

; http://imaging.geocomm.com/glossary/m.html
;	Mean Earth-Sun distance is the arithmetical mean of the maximum and minimum distances between a planet (Earth) and the object about which it revolves (Sun).
;
;	http://hyperphysics.phy-astr.gsu.edu/hbase/solar/soldata2.html#c3
; Maximum distance from Sun: 1.017 AU=1.521x10^8 km
; Minimum distance from Sun: 0.983 AU=1.471x10^8 km

;
;RESTRICTIONS:
;
;HISTORY:
;		http://seawifs.gsfc.nasa.gov/staff/sbailey/solar_const.html
;	according to Sean Bailey:
; Patt, F.S. and W.W. Gregg. 1994. Exact closed-form geolocation algorithm for
;	Earth survey sensors, Int. J. Remote Sensing, Vol. 15, No. 18, pp. 3719-3734.
;	They pull from:
;    Van Flandern, T.C. and I.F. Pulkkinen. 1979, Low-precision formulae for
;planetary positions. The Astrophysical Journal of Supplement Series, Vol.41 pp. 391-411.


; 	Oct 6, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SUN_EARTH_DIST,DOY
  ROUTINE_NAME='SUN_EARTH_DIST'

; PARAMETERS
  A = 1.00014
  B = 0.01671
  C = 0.9856002831
  D = 3.4532868
  E = 360.0

  IF N_ELEMENTS(DOY) EQ 0 THEN DOY = INDGEN(365)+1
; ==============>
; Make an array to hold results
  ESD = (A-B*COS(2.0*!PI*(C * DOY - D)/E)-0.00014*COS(4.0*!PI*(C * DOY - D)/E))

  RETURN,ESD


END; #####################  End of Routine ################################
