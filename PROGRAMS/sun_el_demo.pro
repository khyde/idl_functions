; $ID:	SUN_EL_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;NAME:
;   SUN_EL_DEMO.PRO
;
;PURPOSE:

;
;HISTORY:
; 	Feb 20, 2005,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO SUN_EL_DEMO
  ROUTINE_NAME='SUN_EL_DEMO.PRO'



	LATS =    0.D
	LONS =  [-71,71]

  DATE = DATE_NOW()
  DATE = '2004062120000'
 ; DATE = '20041221120000'

 	JD = DATE_2JD(DATE)
;	===> Convert to GMT
	HOURS = 02

  JD = JD_ADD( JD,hours,/HOUR)
  DATE = JD_2DATE(JD)
	DOY = DATE_2DOY(DATE)
	DHOURS = (DOY MOD 1)*24.0
	DOY = FIX(DOY)
	YEAR = STRMID(DATE,0,4)



LATS=REPLICATE(LATS,N_ELEMENTS(LONS))
;I=I_SUN_KIRK( LONS,LATS, DATE)
;		PRINT, I.SOL_EL
;		STOP

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH=0,N_ELEMENTS(LONS)-1 DO BEGIN
		PRINT, DATE,   DOY, DHOURS, LONS[NTH],LATS[NTH]
		ZENSUN,DOY,DHOURS,LATS[NTH],LONS[NTH],Z,A,S,sunrise=sr,sunset=ss  ; ,/local
		PRINT,  90-Z, A
		SUNAE1,YEAR ,DOY,DHOURS,LATS[NTH],LONS[NTH],AZ,EL,DEC
		PRINT, EL,AZ
		I=I_SUN_KIRK( LONS[NTH],LATS[NTH], DATE)
		PRINT, I.SOL_EL
		DB= DT_SUNPOS(DATE=DATE,LAT=latS[NTH],LON=lonS[NTH])
;	 	ST,DB
	ENDFOR
	STOP

END; #####################  End of Routine ################################
