; $ID:	SUNANGS.PRO,	2020-07-08-15,	USER-KJWH	$
PRO GHA2000 ,IYR,DAY,GHA
;
;  This subroutine computes the Greenwich hour angle in degrees for the
;  input time.  It uses the model referenced in The Astronomical Almanac
;  for 1984, Section S (Supplement) and documented in “Exact
;  closed-form geolocation algorithm for Earth survey sensors”, by
;  F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
;  It includes the correction to mean sideral time for nutation
;  as well as precession.
;  Calling Arguments
;  Name		Type 	I/O	Description
;
;  iyr		I*4	 I	Year (four digits)
;  day		R*8	 I	Day (time of day as fraction)
;  gha		R*8	 O	Greenwich hour angle (degrees)
;
;
; Subprograms referenced:
;
; JD		Computes Julian day from calendar date
; EPHPARMS	Computes mean solar longitude and anomaly and
; 		 mean lunar lontitude and ascending node
; NUTATE		Compute nutation corrections to lontitude and
; 		 obliquity
;
;
; Program written by:	Frederick S. Patt
; 			General Sciences Corporation
; 			November 2, 1992
;
; Modification History:
;
; C    implicit real*8 (a-h,o-z)
  COMMON NUTCM,DPSI,EPS,NUTIME
  COMMON GCONST,PI,RADEG,RE,REM,F,OMF2,OMEGAE
  IMON = 1 & NUTIME = -99999 &
;  Compute days since J2000
  iday = day
  fday = day - iday
  jday = jd(iyr,imon,iday)
  t = jday - 2451545.5D  + fday
;
;  Compute Greenwich Mean Sidereal Time	(degrees)
  gmst = 100.4606184D  + 0.9856473663D *t + 2.908d-13*t*t
;  Check if need to compute nutation correction for this day
  nt = t
  ;;;if (nt NE nutime) THEN BEGIN
  nutime = nt
  ephparms,t,xls,gs,xlm,omega
  nutate,t,xls,gs,xlm,omega,dpsi,eps
  ;;ENDIF
;
;  Include apparent time correction and time-of-day
  gha = gmst + dpsi*cos(eps/radeg) + fday*360.D
  GHA =GHA  MOD  360.D
  IF (GHA LT 0.D ) THEN  GHA = GHA + 360.D
; return
  end
;
;
; ay,
;
; Please forgive the lateness of my response, but I am attaching solar subroutines—i.e., to
; calculate solar zenith and azimuth.
; Watson
;
  PRO SUN2000 ,IYR,IDAY,SEC,SUN,RS
;
;  This subroutine computes the Sun vector in geocentric inertial
;  (equatorial) coodinates.  It uses the model referenced in The
;  Astronomical Almanac for 1984, Section S (Supplement) and documented
;  in “Exact closed-form geolocation algorithm for Earth survey
;  sensors”, by F.S. Patt and W.W. Gregg, Int. Journal of Remote
;  Sensing, 1993.  The accuracy of the Sun vector is approximately 0.1
;  arcminute.
;
; Arguments:
;
; Name	Type	I/O	Description
; --------------------------------------------------------
; IYR	I*4	 I	Year, four digits (i.e, 1993)
; IDAY	I*4	 I	Day of year (1-366)
; SEC	R*8	 I	Seconds of day
; SUN(3)	R*4	 O	Unit Sun vector in geocentric inertial
; 			 coordinates of date
; RS	R*4	 O	Magnitude of the Sun vector (AU)
;
; Subprograms referenced:
;
; JD		Computes Julian day from calendar date
; EPHPARMS	Computes mean solar longitude and anomaly and
; 		 mean lunar lontitude and ascending node
; NUTATE		Compute nutation corrections to lontitude and
; 		 obliquity
;
; Coded by:  Frederick S. Patt, GSC, November 2, 1992
; Modified to include Earth constants subroutine by W. Gregg,
; 	May 11, 1993.
;
;
; C   implicit real*8 (a-h,o-z)
;
  COMMON NUTCM,DPSI,EPS,NUTIME
  COMMON GCONST,PI,RADEG,RE,REM,F,OMF2,OMEGAE
  sun = fltarr(4)
  rs = 0.0
  ;real*4 sun(3),rs
;
;
  XK = 0.0056932
  ;data imon/1/
   imon=1
;   Compute floating point days since Jan 1.5, 2000
;    Note that the Julian day starts at noon on the specified date
  t = jd(iyr,imon,iday) - 2451545.0D  + (sec-43200.D )/86400.D
;  Compute solar ephemeris parameters
   ephparms,t,xls,gs,xlm,omega
;  Check if need to compute nutation corrections for this day
  nt = t
;;;;  if (nt NE nutime) THEN BEGIN
  nutime = nt
  nutate,t,xls,gs,xlm,omega,dpsi,eps
 ;;;; ENDIF
;
;  Compute planet mean anomalies
;   Venus Mean Anomaly
  g2 = 50.40828D  + 1.60213022D *t
  G2 =G2  MOD  360.D
;
;   Mars Mean Anomaly
  g4 = 19.38816D  + 0.52402078D *t
  G4 =G4  MOD  360.D
;
;  Jupiter Mean Anomaly
  g5 = 20.35116D  + 0.08309121D *t
  G5 =G5  MOD  360.D
;
;  Compute solar distance (AU)
  rs = 1.00014D  - 0.01671D *cos(gs/radeg) $
     - 0.00014D *cos(2.0D *gs/radeg)
;  Compute Geometric Solar Longitude
;	dls = 	(6893.0D0 - 4.6543463D-4*t)*sin(gs/radeg)
;     *		+ 72.0D0*sin(2.0D0*gs/radeg)
;     *		- 7.0D0*cos((gs - g5)/radeg)
;     *		+ 6.0D0*sin((xlm - xls)/radeg)
;     *		+ 5.0D0*sin((4.0D0*gs - 8.0D0*g4 + 3.0D0*g5)/radeg)
;     *		- 5.0D0*cos((2.0D0*gs - 2.0D0*g2)/radeg)
;     *		- 4.0D0*sin((gs - g2)/radeg)
;     *		+ 4.0D0*cos((4.0D0*gs - 8.0D0*g4 + 3.0D0*g5)/radeg)
;     *		+ 3.0D0*sin((2.0D0*gs - 2.0D0*g2)/radeg)
;     *		- 3.0D0*sin(g5/radeg)
;     *		- 3.0D0*sin((2.0D0*gs - 2.0D0*g5)/radeg)  !arcseconds

  dls=(6893.0D - 4.6543463D-4*t)*sin(gs/radeg) $
     + 72.0D *sin(2.0D *gs/radeg)$
     - 7.0D *cos((gs - g5)/radeg)$
     + 6.0D *sin((xlm - xls)/radeg)$
     + 5.0D *sin((4.0D *gs - 8.0D *g4 + 3.0D *g5)/radeg)$
     - 5.0D0*cos((2.0D0*gs - 2.0D*g2)/radeg) $
     - 4.0D0*sin((gs - g2)/radeg) $
     + 4.0D0*cos((4.0D*gs - 8.0D*g4 + 3.0D0*g5)/radeg) $
     + 3.0D0*sin((2.0D*gs - 2.0D*g2)/radeg) $
     - 3.0D0*sin(g5/radeg) $
     - 3.0D0*sin((2.0D*gs - 2.0D*g5)/radeg)  ;!arcseconds


;
;
;
  xlsg = xls + dls/3600.D
;  Compute Apparent Solar Longitude; includes corrections for nutation
;   in longitude and velocity aberration
  xlsa = xlsg + dpsi - xk/rs
;   Compute unit Sun vector
  sun[1] = cos(xlsa/radeg)
  sun(2) = sin(xlsa/radeg)*cos(eps/radeg)
  sun(3) = sin(xlsa/radeg)*sin(eps/radeg)
; type *,’ Sunlon = ‘,xlsg,xlsa,eps
;
; 	return
  end
;
;

;
  PRO EPHPARMS ,T,XLS,GS,XLM,OMEGA
;  This subroutine computes ephemeris parameters used by other Mission
;  Operations routines: the solar mean longitude and mean anomaly, and
;  the lunar mean longitude and mean ascending node.  It uses the model
;  referenced in The Astronomical Almanac for 1984, Section S
;  (Supplement) and documented and documented in “Exact closed-form
;  geolocation algorithm for Earth survey sensors”, by F.S. Patt and
;  W.W. Gregg, Int. Journal of Remote Sensing, 1993.  These parameters
;  are used to compute the solar longitude and the nutation in
;  longitude and obliquity.
;  Calling Arguments
;  Name		Type 	I/O	Description
;
;  t		R*8	 I	Time in days since January 1, 2000 at
; 			 12 hours UT
;  xls		R*8	 O	Mean solar longitude (degrees)
;  gs		R*8	 O	Mean solar anomaly (degrees)
;  xlm		R*8	 O	Mean lunar longitude (degrees)
;  omega	R*8	 O	Ascending node of mean lunar orbit
; 			 (degrees)
;
;
; Program written by:	Frederick S. Patt
; 			General Sciences Corporation
; 			November 2, 1992
;
; Modification History:
;
; C  implicit real*8 (a-h,o-z)
;  Sun Mean Longitude
  xls = 280.46592D  + 0.9856473516D *t
  XLS =XLS  MOD  360.D
;  Sun Mean Anomaly
  gs = 357.52772D  + 0.9856002831D *t
  GS =GS  MOD  360.D
;  Moon Mean Longitude
  xlm = 218.31643D  + 13.17639648D *t
  XLM =XLM  MOD  360.D
;  Ascending Node of Moon’s Mean Orbit
  omega = 125.04452D  - 0.0529537648D *t
  OMEGA =OMEGA  MOD  360.D
; return
  end
;
  PRO NUTATE ,T,XLS,GS,XLM,OMEGA,DPSI,EPS
;  This subroutine computes the nutation in longitude and the obliquity
;  of the ecliptic corrected for nutation.  It uses the model referenced
;  in The Astronomical Almanac for 1984, Section S (Supplement) and
;  documented in “Exact closed-form geolocation algorithm for Earth
;  survey sensors”, by F.S. Patt and W.W. Gregg, Int. Journal of
;  Remote Sensing, 1993.  These parameters are used to compute the
;  apparent time correction to the Greenwich Hour Angle and for the
;  calculation of the geocentric Sun vector.  The input ephemeris
;  parameters are computed using subroutine ephparms.  Terms are
;  included to 0.1 arcsecond.
;  Calling Arguments
;  Name		Type 	I/O	Description
;
;  t		R*8	 I	Time in days since January 1, 2000 at
; 			 12 hours UT
;  xls		R*8	 I	Mean solar longitude (degrees)
;  gs		R*8	 I	Mean solar anomaly   (degrees)
;  xlm		R*8	 I	Mean lunar longitude (degrees)
;  Omega	R*8	 I	Ascending node of mean lunar orbit
;  				 (degrees)
;  dPsi		R*8	 O	Nutation in longitude (degrees)
;  Eps		R*8	 O	Obliquity of the Ecliptic (degrees)
; 				 (includes nutation in obliquity)
;
;
; Program written by:	Frederick S. Patt
; 			General Sciences Corporation
; 			October 21, 1992
;
; Modification History:
;
; C  implicit real*8 (a-h,o-z)
  COMMON GCONST,PI,RADEG,RE,REM,F,OMF2,OMEGAE
;  Nutation in Longitude
  dpsi = - 17.1996D *sin(omega/radeg)	 	+ 0.2062D *sin(2.0D *omega/radeg)	     	- 1.3187D *sin(2.0D *xls/radeg)		+ 0.1426D *sin(gs/radeg)		- 0.2274D *sin(2.0D *xlm/radeg)
;
;
;
;
;
;  Mean Obliquity of the Ecliptic
  epsm = 23.439291D  - 3.560d-7*t
;  Nutation in Obliquity
  deps = 9.2025D *cos(omega/radeg) + 0.5736D *cos(2.0D *xls/radeg)
;  True Obliquity of the Ecliptic
  eps = epsm + deps/3600.D
  dpsi = dpsi/3600.D
; return
  end
;
;
  PRO JD ,I,J,K
;
;
;    This function converts a calendar date to the corresponding Julian
;    day starting at noon on the calendar date.  The algorithm used is
;    from Van Flandern and Pulkkinen, Ap. J. Supplement Series 41,
;    November 1979, p. 400.
;
;
; Arguments
;
;     	Name    Type 	I/O 	Description
;     	----	---- 	--- 	-----------
;     	i	I*4  	 I 	Year - e.g. 1970
;     	j       I*4  	 I  	Month - (1-12)
;     	k       I*4  	 I  	Day  - (1-31)
;     	jd      I*4  	 O  	Julian day
;
;     external references
;     -------------------
;      none
;
;
;     Written by Frederick S. Patt, GSC, November 4, 1992
;
;
  jd = 367*i - 7*(i+(j+9)/12)/4 + 275*j/9 + k + 1721014
;  This additional calculation is needed only for dates outside of the
;   period March 1, 1900 to February 28, 2100
;     	jd = jd + 15 - 3*((i+(j-9)/7)/100+1)/4
;       	return
  end
;



  PRO SUNANGS ,IYR,IDAY,GMT,XLON,YLAT,SUNZ,SUNA
;
;  Given year, day of year, time in hours (GMT) and latitude and
; c  longitude, returns an accurate solar zenith and azimuth angle.
;  Based on IAU 1976 Earth ellipsoid.  Method for computing solar
;  vector and local vertical from Patt and Gregg, 1993, Int. J.
;  Remote Sensing.
;
;  Subroutines required: sun2000
;    gha2000
;    jd
;
; C save  !required for IRIX compilers
;
  COMMON GCONST,PI,RADEG,RE,REM,F,OMF2,OMEGAE
  SUNI= FLTARR(4)&SUNG= FLTARR(4)&UP= FLTARR(4)&NO= FLTARR(4)&EA= FLTARR(4)&
  PI=0.0D&RADEG=0.0D&RE=0.0D&REM=0.0D&F=0.0D&OMF2=0.0D&OMEGAE=0.0D&
  SEC=0.0D&GHA=0.0D&GHAR=0.0D&DAY=0.0D&
;
;
;  Compute sun vector
;   Compute unit sun vector in geocentric inertial coordinates
  sec = gmt*3600.0D
  SUN2000, IYR,IDAY,SEC,SUNI,RS
;
;   Get Greenwich mean sidereal angle
  day = iday + sec/86400.0D
  GHA2000, IYR,DAY,GHA
  ghar = gha/radeg
;
;   Transform Sun vector into geocentric rotating frame
  sung[1] = suni[1]*cos(ghar) + suni(2)*sin(ghar)
  sung(2) = suni(2)*cos(ghar) - suni[1]*sin(ghar)
  sung(3) = suni(3)
;
;  Convert geodetic lat/lon to Earth-centered, earth-fixed (ECEF)
;  vector (geodetic unit vector)
  rlon = xlon/radeg
  rlat = ylat/radeg
  cosy = cos(rlat)
  siny = sin(rlat)
  cosx = cos(rlon)
  sinx = sin(rlon)
  up[1] = cosy*cosx
  up(2) = cosy*sinx
  up(3) = siny
;
;  Compute the local East and North unit vectors
  upxy = sqrt(up[1]*up[1]+up(2)*up(2))
  ea[1] = -up(2)/upxy
  ea(2) = up[1]/upxy
  no[1] = up(2)*ea(3) - up(3)*ea(2)  ;cross product
  no(2) = up(3)*ea[1] - up[1]*ea(3)
  no(3) = up[1]*ea(2) - up(2)*ea[1]
;
;  Compute components of spacecraft and sun vector in the
;  vertical (up), North (no), and East (ea) vectors frame
  sunv = 0.0
  sunn = 0.0
  sune = 0.0
  FOR  J = 1,3 DO BEGIN ;DO#_
  sunv = sunv + sung(j)*up(j)
  sunn = sunn + sung(j)*no(j)
  sune = sune + sung(j)*ea(j)
  ENDFOR
;
;  Compute the solar zenith and azimuth
  sunz = radeg*ATAN(sqrt(sunn*sunn+sune*sune),sunv)
;  Check for zenith close to zero
  if (sunz  GT  0.05D )THEN BEGIN
  suna = radeg*ATAN(sune,sunn)
  ENDIF ELSE BEGIN
  suna = 0.0D
  ENDELSE
  IF (SUNA  LT  0.0D ) THEN SUNA = SUNA + 360.0D
;
;       return
  end
;
;
