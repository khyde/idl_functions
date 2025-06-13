;Program to compute surface irradiance for cloud-free conditions
; IDL PROGRAM PROVIDED BY C.HU TO JOR

;Output: lam	wavelength in nm, 1D array
;	Edir	irradiance from direct solar beam, 1D array
;	Edif	irradiance from diffuse sky, 1D array
;	Ed	irradiance from both, 1D array
;Input:	everything else
;Note that aerosol information is set through two parameters:
;am (airmass type to define the size distribution) and
;vi (visibility in km to define the aerosol optical thickness
;relative humidity is assumed 80% in the FORTRAN code radtran4IDL.f

;jday=209.	;julidan day
;gmt=17.54	;GMT in decimal hour
;rlon=-81.5	;negative longitude means west
;rlat=25.5
;theta=27.5	;solar zenith angle in degrees
;	if theta is provided, rlon and rlat will not be used,
;	otherwise they are used together with jday and gmt to
;	compute theta. In other words, if theta is provided
;	rlon and rlat can be set to any values
;pres=1013.2	;surface pressure in mbar. 1013.2 is the "standard"
;wv=3.5	(cm^-1) ;water_vapor content
;ws=2.0	;wind speed in m/s
;ro3=305.	O3 in dobson unit
;am=1	;air mass type: 1 for maritime and 10 for continental
	;this will determine the aerosol size distribution function
;vi=50 (km) ;visibility. 50 km is corresponding to maritime aerosol
	; optical thickness at 550 nm about 0.0835, which is for
	; a typical clear sky in the north Atlantic ocean
	; Accordingly, vi=25 km is corresponding for OD of 0.167

pro radtran4idl,jday,GMT,rlon,rlat,theta=theta, $
	pres,wv,ws,ro3,am,vi,lam,Edir,Edif,Ed
;path = 'D:\FORT\radtran_so\'	;program path

path = 'D:\FORT\'	;program path


if (n_params() lt 14) then begin
        print,"Program to compute surface downwelling irradiance (direct and" + $
		" diffuse) based on Gregg and Carder (L&O 1991)"
        print,"Usage:radtran4idl,jday,GMT,rlon,rlat,theta=theta," + $
		"pres,wv,ws,ro3,am,vi,lam,Edir,Edif,Ed"
	print,"Look at the IDL source code for explanation of these terms "+ $
		"or email hu@seas.marine.usf.edu for details."
        goto,end_of_pro
endif

jday=float(jday)
gmt=float(gmt)
rlon=float(rlon)
rlat=float(rlat)
pres=float(pres)
wv=float(wv)
ws=float(ws)
ro3=float(ro3)
am=float(am)
vi=float(vi)
lam=fltarr(351)
Edir=lam
Edif=lam
Ed=lam

if (keyword_set(theta) eq 0) then $
	sunangle,jday,gmt,rlat,rlon,theta,phi
theta=float(theta)
jday=jday+gmt/24.

s=call_external(path+'RADTRAN4IDL.dll','radtran4idlf_',jday,$
	rlon,rlat,theta,pres,wv,ws,ro3,am,vi,lam,Edir,Edif,Ed)


SET_PMULTI,4
PLOT, LAM,EDIR,TITLE='Edir'
PLOT, LAM,EDif,TITLE='Edif'
PLOT, LAM,ED,TITLE='Ed'

STOP
end_of_pro:

end

