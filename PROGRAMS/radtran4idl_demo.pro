PRO radtran4idl_demo
jday=209.	;julidan day
gmt=17.54	;GMT in decimal hour
rlon=-81.5	;negative longitude means west
rlat=25.5
theta=27.5	;solar zenith angle in degrees
;	if theta is provided, rlon and rlat will not be used,
;	otherwise they are used together with jday and gmt to
;	compute theta. In other words, if theta is provided
;	rlon and rlat can be set to any values
pres=1013.2	;surface pressure in mbar. 1013.2 is the "standard"
wv=3.5;	(cm^-1) ;water_vapor content
ws=2.0	;wind speed in m/s
ro3=305.	;O3 in dobson unit
am=1	;air mass type: 1 for maritime and 10 for continental
;	this will determine the aerosol size distribution function
vi=50 ;(km) ;visibility. 50 km is corresponding to maritime aerosol
;	 optical thickness at 550 nm about 0.0835, which is for
;	 a typical clear sky in the north Atlantic ocean
;	 Accordingly, vi=25 km is corresponding for OD of 0.167


CD,'D:\FORT\radtran4idl\'

radtran4idl,jday,GMT,rlon,rlat,theta=theta, $
	pres,wv,ws,ro3,am,vi,lam,Edir,Edif,Ed



END
