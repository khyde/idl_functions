; $ID:	SUN_GREGG.PRO,	2020-07-08-15,	USER-KJWH	$
; From Watson Gregg, October 26,1999


  FUNCTION jd, i,j,k
;
;
;    This function converts a calendar date to the corresponding Julian
;    day starting at noon on the calendar date.  The algorithm used is
;    from Van Flandern and Pulkkinen, Ap. J. Supplement Series 41,
;    November 1979, p. 400.
;
;
;	Arguments
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
; This additional calculation is needed only for dates outside of the
; period March 1, 1900 to February 28, 2100
     	jd = jd + 15 - 3*((i+(j-9)/7)/100+1)/4
  return, JD
  end ; Function jd


; ************************************************************
  PRO sunangs,iyr,iday,gmt,xlon,ylat,sunz,suna

; Given year, day of year, time in hours (GMT) and latitude and
; longitude, returns an accurate solar zenith and azimuth angle.
;
; Based on IAU 1976 Earth ellipsoid.  Method for computing solar c  vector and local vertical from
; Patt and Gregg, 1993, Int. J.  c  Remote Sensing.

;  Subroutines required: sun2000
;                        gha2000
;                        jd
;
; save  !required for IRIX compilers
; real suni(3),sung(3),up(3),no(3),ea(3)
; real*8 pi,radeg,re,rem,f,omf2,omegae
; real*8 sec,gha,ghar,day

  common gconst, pi,radeg,re,rem,f,omf2,omegae

; ====================>
; Compute sun vector
; Compute unit sun vector in geocentric inertial coordinates
  sec = gmt*3600.0D
  sun2000,iyr,iday,sec,suni,rs

; ====================>
; Get Greenwich mean sidereal angle
  day = iday + sec/86400.0D
  gha2000,iyr,day,gha
  ghar = gha/radeg

; ====================>
; Transform Sun vector into geocentric rotating frame
  sung[1] = suni[1]*cos(ghar) + suni(2)*sin(ghar)
  sung(2) = suni(2)*cos(ghar) - suni[1]*sin(ghar)
  sung(3) = suni(3)

; ====================>
; Convert geodetic lat/lon to Earth-centered, earth-fixed (ECEF)
; vector (geodetic unit vector)
  rlon = xlon/radeg
  rlat = ylat/radeg
  cosy = cos(rlat)
  siny = sin(rlat)
  cosx = cos(rlon)
  sinx = sin(rlon)
  up[1] = cosy*cosx
  up(2) = cosy*sinx
  up(3) = siny

; ====================>
; Compute the local East and North unit vectors
  upxy = sqrt(up[1]*up[1]+up(2)*up(2))
  ea[1] = -up(2)/upxy
  ea(2) = up[1]/upxy
  no[1] = up(2)*ea(3) - up(3)*ea(2)  ;!cross product
  no(2) = up(3)*ea[1] - up[1]*ea(3)
  no(3) = up[1]*ea(2) - up(2)*ea[1]

; ====================>
; Compute components of spacecraft and sun vector in the
; vertical (up), North (no), and East (ea) vectors frame
  sunv = 0.0
  sunn = 0.0
  sune = 0.0
  FOR j = 1,3 DO BEGIN
   sunv = sunv + sung(j)*up(j)
   sunn = sunn + sung(j)*no(j)
   sune = sune + sung(j)*ea(j)
  enddo

; ====================>
; Compute the solar zenith and azimuth
  sunz = radeg*atan2(sqrt(sunn*sunn+sune*sune),sunv)

; ====================>
; Check for zenith close to zero
  IF (sunz gt 0.05D) THEN BEGIN
    suna = radeg*atan2(sune,sunn)
  ENDIF else BEGIN
    suna = 0.0D
  ENDELSE
  if (suna lt 0.0D) THEN suna = suna + 360.0D
  return
  end ; PRO SUNANGS


; ************************************************************
  PRO sun2000, iyr,iday,sec,sun,rs
; This subroutine computes the Sun vector in
; geocentric inertial (equatorial) coodinates.
; It uses the model referenced in The Astronomical Almanac for 1984,
; Section S (Supplement) and documented in:
; Exact closed-form geolocation algorithm for Earth survey sensors,
; by F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
; The accuracy of the Sun vector is approximately 0.1 c  arcminute.

;	Arguments:

;	Name	Type	I/O	Description
;	--------------------------------------------------------
;	IYR	I*4	 I	Year, four digits (i.e, 1993)
;	IDAY	I*4	 I	Day of year (1-366)
;	SEC	R*8	 I	Seconds of day
;	SUN(3)	R*4	 O	Unit Sun vector in geocentric inertial
;				 coordinates of date
;	RS	R*4	 O	Magnitude of the Sun vector (AU)
;
;	Subprograms referenced:
;
;	JD		Computes Julian day from calendar date
;	EPHPARMS	Computes mean solar longitude and anomaly and
;			 mean lunar lontitude and ascending node
;	NUTATE		Compute nutation corrections to lontitude and
;			 obliquity
;
;	Coded by:  Frederick S. Patt, GSC, November 2, 1992
;	Modified to include Earth constants subroutine by W. Gregg,
;		May 11, 1993.


;implicit real*8 (a-h,o-z)
;real*4 sun(3),rs
 sun = fltarr(4)
 rs = fltarr(4)
 common nutcm,dpsi,eps,nutime
 common gconst,pi,radeg,re,rem,f,omf2,omegae
 xk= 0.0056932 		;!Constant of aberration
 imon= 1
; ====================>
; Compute floating point days since Jan 1.5, 2000
; Note that the Julian day starts at noon on the specified date
  t = jd(iyr,imon,iday) - 2451545.0d + (sec-43200.d)/86400.d

; ====================>
; Compute solar ephemeris parameters
  ephparms,t,xls,gs,xlm,omega
; Check if need to compute nutation corrections for this day
  nt = t
  if (nt ne nutime) then begin
    nutime = nt
    nutate,t,xls,gs,xlm,omega,dpsi,eps
  endif

; ====================>
; Compute planet mean anomalies
; Venus Mean Anomaly
  g2 = 50.40828D + 1.60213022D*t
  g2 = dmod(g2,360.d)

; Mars Mean Anomaly
  g4 = 19.38816D + 0.52402078D*t
  g4 = dmod(g4,360.D)

; Jupiter Mean Anomaly
  g5 = 20.35116D + 0.08309121D*t
  g5 = dmod(g5,360.d)

; ====================>
; Compute solar distance (AU)
  rs = 1.00014D - 0.01671D*cos(gs/radeg) $
     - 0.00014D*cos(2.0D*gs/radeg)

; ====================>
; Compute Geometric Solar Longitude
	dls = 	(6893.0D - 4.6543463D-4*t)*sin(gs/radeg) $
     		+ 72.0D*sin(2.0D*gs/radeg) $
     		- 7.0D*cos((gs - g5)/radeg) $
     		+ 6.0D*sin((xlm - xls)/radeg) $
     		+ 5.0D*sin((4.0D*gs - 8.0D*g4 + 3.0D*g5)/radeg) $
     		- 5.0D*cos((2.0D*gs - 2.0D*g2)/radeg) $
     		- 4.0D*sin((gs - g2)/radeg) $
     		+ 4.0D*cos((4.0D*gs - 8.0D*g4 + 3.0D*g5)/radeg) $
     		+ 3.0D*sin((2.0D*gs - 2.0D*g2)/radeg) $
     		- 3.0D*sin(g5/radeg) $
     		- 3.0D*sin((2.0D*gs - 2.0D*g5)/radeg)  ;!arcseconds

  xlsg = xls + dls/3600.D

; ====================>
; Compute Apparent Solar Longitude; includes corrections for nutation
; in longitude and velocity aberration
  xlsa = xlsg + dpsi - xk/rs

; ====================>
;  Compute unit Sun vector
  sun[1] = cos(xlsa/radeg)
  sun(2) = sin(xlsa/radeg)*cos(eps/radeg)
  sun(3) = sin(xlsa/radeg)*sin(eps/radeg)
; PRINT,� Sunlon = �,xlsg,xlsa,eps
 ; return
  END ; PRO sun2000

; **************************************************
  PRO gha2000,iyr,day,gha

; This subroutine computes the Greenwich hour angle in degrees for the
; input time.  It uses the model referenced in The Astronomical Almanac
; for 1984, Section S (Supplement) and documented in:
; Exact closed-form geolocation algorithm for Earth survey sensors,
; by c  F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
; It includes the correction to mean
; sideral time for nutation as well as precession.
; Calling Arguments
; Name		Type 	I/O	Description

; iyr		I*4	 I	Year (four digits)
; day		R*8	 I	Day (time of day as fraction)
; gha		R*8	 O	Greenwich hour angle (degrees)


;	Subprograms referenced:
;	JD		Computes Julian day from calendar date
;	EPHPARMS	Computes mean solar longitude and anomaly and
;			 mean lunar lontitude and ascending node
;	NUTATE		Compute nutation corrections to lontitude and
;			 obliquity
;
;
;	Program written by:	Frederick S. Patt
;				General Sciences Corporation
;				November 2, 1992
;
;	Modification History:
;
; implicit real*8 (a-h,o-z)
  common nutcm,dpsi,eps,nutime
  common gconst,pi,radeg,re,rem,f,omf2,omegae
  imon = 1
  nutime = -99999

; ====================>
; Compute days since J2000
  iday = day
  fday = day - iday
  jday = jd(iyr,imon,iday)
  t = jday - 2451545.5D + fday

; ====================>
; Compute Greenwich Mean Sidereal Time	(degrees)
  gmst = 100.4606184D + 0.9856473663D*t + 2.908d-13*t*t

; ====================>
; Check if need to compute nutation correction for this day
  nt = t
  if (nt ne nutime) then BEGIN
    nutime = nt
    ephparms, t,xls,gs,xlm,omega
    nutate,   t,xls,gs,xlm,omega,dpsi,eps
  endif

; ====================>
; Include apparent time correction and time-of-day
  gha = gmst + dpsi*cos(eps/radeg) + fday*360.D
  gha = dmod(gha,360.D)
  if (gha LT 0.D) THEN gha = gha + 360.D
  return
  end ; PRO gha2000


; ************************************************************
  PRO ephparms ,t,xls,gs,xlm,omega
; This subroutine computes ephemeris parameters used by other
; Mission Operations routines:
;   the solar mean longitude and mean anomaly, and
;   the lunar mean longitude and mean ascending node.
; It uses the model referenced in The Astronomical Almanac for 1984,
; Section S (Supplement) and documented and documented in:
; Exact closed-form geolocation algorithm for Earth survey sensors,
; by F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.
; These parameters are used to compute the solar longitude and
; the nutation in longitude and obliquity.
;  Calling Arguments
;  Name		Type 	I/O	Description
;
;  t		R*8	 I	Time in days since January 1, 2000 at
;				 12 hours UT
;  xls		R*8	 O	Mean solar longitude (degrees)
;  gs		R*8	 O	Mean solar anomaly (degrees)
;  xlm		R*8	 O	Mean lunar longitude (degrees)
;  omega	R*8	 O	Ascending node of mean lunar orbit
;				 (degrees)
;
;
;	Program written by:	Frederick S. Patt
;				General Sciences Corporation
;				November 2, 1992
;
;	Modification History:
;
; implicit real*8 (a-h,o-z)

; ====================>
; Sun Mean Longitude
  xls = 280.46592D + 0.9856473516D*t
  xls = dmod(xls,360.D)

; ====================>
; Sun Mean Anomaly
  gs = 357.52772D + 0.9856002831D*t
  gs = dmod(gs,360.D)

; ====================>
; Moon Mean Longitude
  xlm = 218.31643D + 13.17639648D*t
  xlm = dmod(xlm,360.D)

; ====================>
;Ascending Node of Moon�s Mean Orbit
 omega = 125.04452D - 0.0529537648D*t
 omega = dmod(omega,360.D)
 return
end ; PRO ephparms


; ************************************************************
  PRO nutate, t,xls,gs,xlm,omega,dpsi,eps
; This subroutine computes the nutation in longitude and the obliquity
; of the ecliptic corrected for nutation.
; It uses the model referenced in The Astronomical Almanac for 1984,
; Section S (Supplement) and documented in:
; Exact closed-form geolocation algorithm for Earth survey sensors,
; by F.S. Patt and W.W. Gregg, Int. Journal of Remote Sensing, 1993.

; These parameters are used to compute the
; apparent time correction to the Greenwich Hour Angle
; and for the calculation of the geocentric Sun vector.
; The input ephemeris parameters are computed using subroutine ephparms.
; Terms are included to 0.1 arcsecond.

; Calling Arguments
;  Name		Type 	I/O	Description
;
;  t		R*8	 I	Time in days since January 1, 2000 at
;				 12 hours UT
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
;	Program written by:	Frederick S. Patt
;				General Sciences Corporation
;				October 21, 1992
;
;	Modification History:
;
; mplicit real*8 (a-h,o-z)
  common gconst,pi,radeg,re,rem,f,omf2,omegae

; ====================>
; Nutation in Longitude
  dpsi = - 17.1996D*sin(omega/radeg)  $
      	 	+ 0.2062D*sin(2.0D*omega/radeg)  $
      	     	- 1.3187D*sin(2.0D*xls/radeg)  $
      		+ 0.1426D*sin(gs/radeg)  $
      		- 0.2274D*sin(2.0D*xlm/radeg)

; ====================>
; Mean Obliquity of the Ecliptic
  epsm = 23.439291D - 3.560d-7*t

; ====================>
; Nutation in Obliquity
  deps = 9.2025D*cos(omega/radeg) + 0.5736D*cos(2.0D*xls/radeg)

; ====================>
; True Obliquity of the Ecliptic
  eps = epsm + deps/3600.D
  dpsi = dpsi/3600.D
  return
  end ; PRO nutate


