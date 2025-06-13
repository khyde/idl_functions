; $ID:	SUN_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;NAME:
;   SUN_DEMO
;
;PURPOSE:
;
;CATEGORY:
;
;CALLING SEQUENCE:
;		ROUTINE_NAME, Parameter1, Parameter2, Foobar
;		Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
;INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again
;		that positional parameters are shown with Initial Caps.
;
;KEYWORDS:
;
;OUTPUTS:
;
;EXAMPLE:
;
;RESTRICTIONS:
;
;HISTORY:
; 	Oct 6, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Jan 8 2004 changed doy to be fix
;-
; *************************************************************************

PRO SUN_DEMO
  ROUTINE_NAME='SUN_DEMO'
  DIR_PLOTS = 'D:\IDL\PROGRAMS\'
	YEAR = 2000
	PSFILE = DIR_PLOTS+ROUTINE_NAME+'.PS'
	PSPRINT,FILENAME=PSFILE,/COLOR,/HALF
	PAL_36
	SETCOLOR, 255
	dates = NUM2STR(INTARR(12) + YEAR) + NUM2STR(INDGEN(12)+1,LEADING=2) + '21000000'
	LIST, DATES
	N_DATES=N_ELEMENTS(DATES)
	DOY  = FIX(DATE_2DOY(DATES))

	LON  = [89.0]
	LAT =  [0.0]
	LON = REPLICATE(LON,N_DATES)
	LAT = REPLICATE(LAT,N_DATES)
	YEAR = REPLICATE(YEAR,N_DATES)

	MONTH=FIX(STRMID(DATES,4,2))
	DAY  = FIX(STRMID(DATES,6,2))

	DATE_START= STRMID(DATES,0,8) + '000000'
	JULIAN_START = DATE_2JD(DATE_START)
	MSEC_DAY= MSECONDS_DAY()

	N_PROS = 3

	STRUCT=CREATE_STRUCT('DATE','','ROUTINE','','ZENITH',0.0D,'AZIMUTH',0.0D)
	STRUCT=REPLICATE(STRUCT,N_DATES* N_PROS)
	COUNTER = 0
; pro lonlat2solz,lon,lat,year,day,msec,solz,sola
;	Bryan Franz, SAIC GSC, NASA/SIMBIOS Project, April 1998.(with much help from geonav.pro by Fred Patt)
; msec=milliseconds
	JULIAN=DATE_2JD(DATES)
	MSEC = (JULIAN-JULIAN_START) * MSEC_DAY

	DA=DT_AXIS(JULIAN,/MONTH,NAMES=1)

	LONLAT2SOLZ,lon,lat,year,DOY,msec,solz,sola
	START=COUNTER
	FIN  =COUNTER+N_DATES -1
	STRUCT(START:FIN).DATE = DATES
	STRUCT(START:FIN).ROUTINE = 'LONLAT2SOLZ'
	STRUCT(START:FIN).ZENITH = SOLZ
	START=START+N_DATES
	FIN=FIN+N_DATES


 	DDOY = DT_DATE2DOY(DATES)
 	DHOURS = 24.0* (DDOY MOD 1)
 	DOY    = FIX(DDOY)
;	===> Get the solar zenith angle
 	ZENSUN,DOY,DHOURS,lat,lon,zenith,azimuth,solfac,sunrise=sunrise,sunset=sunset
 	STRUCT(START:FIN).DATE = DATES
 	STRUCT(START:FIN).ROUTINE = 'ZENSUN'
 	STRUCT(START:FIN).ZENITH = zenith
 	START=START+N_DATES
	FIN=FIN+N_DATES



   RAD_CLEAR_SKY_SW_FROUIN ,$
                  YEAR=year,$
                  MONTH=month,$
                  Day  =day,$
                  GMTH=DHOURS,$
                  LAT = lat,$
                  LON = lon,$
                  RESULT= result
; CalcSurfSolIrrad, year, month, day, time, lat, lon,TauA865, Angstrom, Dobson, SolZen, E


  	STRUCT(START:FIN).DATE = DATES
  	STRUCT(START:FIN).ROUTINE = 'RAD_CLEAR_SKY_SW_FROUIN'
  	STRUCT(START:FIN).ZENITH = RESULT.SOL_ZEN
; 	START=START+N_DATES
;	FIN=FIN+N_DATES




	U=UNIQ(STRUCT.ROUTINE)
	COLOR= 0

	FOR NTH = 0,N_ELEMENTS(U)-1 DO BEGIN
		AROUTINE = STRUCT(U[NTH]).ROUTINE
		OK=WHERE(STRUCT.ROUTINE EQ AROUTINE)
		IF NTH EQ 0 THEN BEGIN
			PLOT, JULIAN,STRUCT.ZENITH, XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,$
			XTITLE='GMT',YRANGE=[0,120],/YSTYLE,$
			YTITLE='Solar Zenith'+ UNITS('DEG',/UNIT),$
			XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
	 		TITLE= DT_TXT,CHARSIZE=0.75,/NODATA
			GRIDS,XTICK_GET,YTICK_GET,COLOR=34,thick=1
		ENDIF
		OPLOT,JULIAN,STRUCT[OK].ZENITH, THICK=1,COLOR=COLOR
		COLOR=COLOR + 12

 	ENDFOR
	PSPRINT
	STOP
END; #####################  End of Routine ################################
