pro sunae1,year,day,hour,lat,long,az,el,dec
;      implicit real(a-z)
; Purpose:
; Calculates azimuth and elevation of sun
;
; References:
; (a) Michalsky, J. J., 1988, The Astronomical Almanac's algorithm for
; approximate solar position (1950-2050), Solar Energy, 227---235, 1988
;
; (b) Spencer, J. W., 1989, Comments on The Astronomical
; Almanac's algorithm for approximate solar position (1950-2050)
; Solar Energy, 42, 353
;
; Input:
; year - the year number (e.g. 1977)
; day  - the day number of the year starting with 1 for
;        January 1
; time - decimal time. E.g. 22.89 (8.30am eastern daylight time is
;        equal to 8.5+5(hours west of Greenwich) -1 (for daylight savings
;        time correction
; lat -  local latitude in degrees (north is positive)
; lon -  local longitude (east of Greenwich is positive.
;                         i.e. Honolulu is 15.3, -157.8)
;
; Output:
; a - azimuth angle of the sun (measured east from north 0 to 360)
; e - elevation of the sun
;SUNAE1,2002,314, 5,41.+29./60, -71+19./60,AZ,EL & PRINT, AZ,EL
;SUNAE1,2002,355, 7 + 8/60. +5 , 41.+29./60, -71-19./60,AZ,EL & PRINT, AZ,EL
; Spencer correction introduced and 3 lines of Michalsky code
; commented out (after calculation of az)
;
; Based on codes of Michalsky and Spencer, converted to IDL by P. J.  Flatau
;	Nov 11,2002 jor. added dec for returning declination

      pi=4.*atan(1.)
      twopi=2.*pi
      rad=pi/180.
; get the current Julian date
      delta=year-1949.
      leap=fix(delta/4.)
      jd=32916.5+delta*365.+leap+day+hour/24.
; calculate ecliptic coordinates
       time=jd-51545.0
; force mean longitude between 0 and 360 degs
       mnlong=280.460+0.9856474*time
       mnlong= mnlong mod 360.
       if(mnlong lt 0) then mnlong=mnlong+360.
; mean anomaly in radians between 0, 2*pi
       mnanom=357.528+0.9856003*time
       mnanom=mnanom mod 360.
       if(mnanom lt 0.) then mnanom=mnanom+360.
       mnanom=mnanom*rad
; compute ecliptic longitude and obliquity of ecliptic
;       eclong=mnlong+1.915*(mnanom)+0.20*sin(2.*mnanom)
       eclong=mnlong+1.915*sin(mnanom)+0.020*sin(2.*mnanom)
       eclong=eclong mod  360.
       if(eclong lt 0) then eclong=eclong+360.
       oblqec=23.429-0.0000004*time
       eclong=eclong*rad
       oblqec=oblqec*rad
; calculate right ascention and declination
       num=cos(oblqec)*sin(eclong)
       den=cos(eclong)
       ra=atan(num/den)
; force ra between 0 and 2*pi
       if(den lt 0.) then $
        ra=ra+pi $
       else if(num lt 0.) then $
        ra=ra+twopi
; dec in radians
       dec=asin(sin(oblqec)*sin(eclong))
; calculate Greenwich mean sidereal time in hours
       gmst=6.697375+0.0657098242*time+hour
; hour not changed to sidereal sine "time" includes the fractional day
       gmst=gmst mod 24.
       if(gmst lt 0.) then gmst=gmst+24.
; calculate local mean sidereal time in radians
       lmst=gmst+long/15.
       lmst=lmst  mod 24.
       if(lmst lt 0.) then lmst=lmst+24.
       lmst=lmst*15.*rad
; calculate hour angle in radians between -pi, pi
        ha = lmst -ra
        if(ha lt -pi) then ha=ha+twopi
        if(ha gt pi) then ha=ha-twopi
        lat=lat*rad
; calculate azimuth and elevation
        el=asin(sin(dec)*sin(lat)+cos(dec)*cos(lat)*cos(ha))
        az=asin(-cos(dec)*sin(ha)/cos(el))
; add J. W. Spencer code (next 5 lines)
        if( (sin(dec) - sin(el)*sin(lat))  ge  0. ) then begin
           if(sin(az) lt 0.) then az=az+twopi
        endif else begin
           az=pi-az
        endelse
; end Spencer's corrections
;cc        elc=asin(sin(dec)/sin(lat))
;cc        if(el.ge.elc) az=pi-az
;cc        if(el.le.elc  .and. ha.gt.0.) az=twopi+az

; this puts azimuth between 0 and 2*pi radians
; calculate refraction correction for US stand. atm.
        el=el/rad
        if(el gt -0.56) then begin
           refrac=3.51561*(0.1594+0.0196*el+0.00002*el^2)/ $
                    (1.+0.505*el+0.0845*el^2)
        endif else begin
           refrac=0.56
        endelse
        el=el+refrac
        az=az/rad
        lat=lat/rad
;
        end


