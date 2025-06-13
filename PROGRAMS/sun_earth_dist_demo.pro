; $ID:	SUN_EARTH_DIST_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;NAME:
;   SUN_EARTH_DIST_DEMO
;
;PURPOSE:
;		DEMO: Calculate the SUN to Earth Distance
;
;CATEGORY:
;
;CALLING SEQUENCE:
;		SUN_EARTH_DIST_DEMO
;
;INPUTS:
;		NONE
;
;KEYWORDS:
;	None
;OUTPUTS:
;	Distance from Center of Sun to Center of Earth in Astronomical Units (AU).
;	RESTRICTIONS:
;
;HISTORY:
; 	Oct 28, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************
PRO SUN_EARTH_DIST_DEMO
ROUTINE_NAME='SUN_EARTH_DIST_DEMO'
	IDL_SYSTEM
	PAL_36,R,G,B
	AU=149597870.691D; kilometers
	PRINT
  PRINT,' http://neo.jpl.nasa.gov/glossary/au.html'
	PRINT,' 1 AU = 149,597,870.691 kilometers'
;	PRINT,' Technical Definition: AU is short for Astronomical Unit and defined as:'
	PRINT,'	the radius of a Keplerian circular orbit of a point-mass having an orbital period of 2*(pi)/k days'
	PRINT,' (k is the Gaussian gravitational constant).'
	PRINT,'	Since an AU is based on radius of a circular orbit,'
	PRINT,' one AU is actually slightly less than the average distance between the Earth and the Sun (approximately 150 million km or 93 million miles).
	PRINT
  DOY=INDGEN(365)+1
  ESD =  SUN_EARTH_DIST(DOY)
  MM = MINMAX(ESD,SUBS=SUBS)
  JULIAN=DT_YDOY2JULIAN(2000,DOY)
  JULIAN_MIN = DT_DATE2JULIAN(DT_YDOY2DATE(2000,DOY(SUBS[0])))
  JULIAN_MAX = DT_DATE2JULIAN(DT_YDOY2DATE(2000,DOY(SUBS[1])))
  DT_MIN = DT_FMT(JULIAN_MIN,/YMD,/DAY)
  DT_MAX = DT_FMT(JULIAN_MAX,/YMD,/DAY)
  PRINT, 'Minimum Sun-Earth-Distance: '+ NUM2STR(MM[0]) +'AU' +' On ' +  DT_MIN
  PRINT, 'Maximum Sun-Earth-Distance: '+ NUM2STR(MM[1]) +'AU' +' On ' +  DT_MAX
	PRINT
	PRINT, 'Average of Minimum and Maximum Sun-Earth-Distances: '  + NUM2STR(MEAN(MM),FORMAT='(F10.8)')
	PRINT
	PRINT, 'Average of 365 Sun-Earth-Distances: '  + NUM2STR(MEAN(ESD),FORMAT='(F10.8)')


	DA=DT_AXIS(JULIAN,/MONTH,NAMES=1)
	!P.MULTI=0
	PSPRINT,FILENAME=!S.PRO+ROUTINE_NAME+'_1.PS',/half,/COLOR
	FONT_TIMES
	PLOT, JULIAN,ESD,YRANGE=[.98,1.02],YMINOR=1,$
		XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
		XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
		TITLE='Sun-Earth Distance!C',$
		YTITLE=UNITS('AU',/NAME,/UNIT),CHARSIZE=1.5
	GRIDS,XTICK_GET,YTICK_GET,COLOR=34,THICK=4,/ALL
	FRAME,THICK=3,COLOR=0,/PLOT
	OPLOT, JULIAN,ESD,COLOR=0,THICK=5
	PLOT_EVENT,JULIAN_MIN,COLOR=6,	THICK=5 	& PLOT_EVENT,JULIAN_MIN,COLOR=6,	LABEL=STRMID(DT_MIN,5) ,CHARSIZE=1.6 ,POS=1.0202,/DATA
	PLOT_EVENT,JULIAN_MAX,COLOR=21,	THICK=5  	& PLOT_EVENT,JULIAN_MAX,COLOR=21,	LABEL=STRMID(DT_MAX,5) ,CHARSIZE=1.6 ,POS=1.0202,/DATA

	TXT = 'Annual Variation'+'!C'+NUM2STR(100*(MM[1]-MM[0]),FORMAT='(F8.3)')+'(%)'
	XYOUTS,JULIAN(193),0.983,TXT,CHARSIZE=1.6
	CAPTION
  PSPRINT


	!P.MULTI=0
	PSPRINT,FILENAME=!S.PRO+ROUTINE_NAME+'_2.PS',/half,/COLOR
	FONT_TIMES

	SOL_FACTOR = (1./(ESD))^2
 	MM = MINMAX(SOL_FACTOR,SUBS=SUBS)
 	annual_range = 100.0* (MM[1]-MM[0])

;	===> Annual Variation in Solar Intensity Due to Sun-Earth-Distance'
  PRINT,'This translates into a variation in Solar Flux of: '+ NUM2STR( ANNUAL_RANGE ) +' %'

	PLOT, JULIAN,SOL_FACTOR,YRANGE=[.96,1.04],YMINOR=1,$
		XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
		XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
		TITLE='Variation in Solar Factor from Sun-Earth Distance Variation!C',$
		YTITLE='Solar Factor (Relative)',CHARSIZE=1.5
	GRIDS,XTICK_GET,YTICK_GET,COLOR=34,THICK=4,/ALL
	FRAME,THICK=3,COLOR=0,/PLOT
	OPLOT, JULIAN,SOL_FACTOR,COLOR=0,THICK=5
	PLOT_EVENT,JULIAN_MIN,COLOR=6,	THICK=5 	& PLOT_EVENT,JULIAN_MIN,COLOR=6,	LABEL=STRMID(DT_MIN,5) ,CHARSIZE=1.6 ,POS=1.0402,/DATA
	PLOT_EVENT,JULIAN_MAX,COLOR=21,	THICK=5  	& PLOT_EVENT,JULIAN_MAX,COLOR=21,	LABEL=STRMID(DT_MAX,5) ,CHARSIZE=1.6 ,POS=1.0402,/DATA

	TXT = 'Annual Variation'+'!C'+NUM2STR(ANNUAL_RANGE,FORMAT='(F8.3)')+'(%)'
	XYOUTS,JULIAN(193),1.021,TXT,CHARSIZE=1.6


; ===> Run varsol.pro
	solar_factor=VARSOL(INDGEN(365)+1)
	mm_flux = minmax(solar_factor)
	;VARSOL AGREES REASONALBLE WELL

 ;; OPLOT, JULIAN,solar_factor,COLOR=21,THICK=5

  CAPTION
  PSPRINT
END; #####################  End of Routine ################################



