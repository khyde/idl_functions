; $ID:	CREATE_DATE.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION CREATE_DATE, STARTDATE, ENDDATE, DOY=DOY, JD=JD, CURRENT_DATE=CURRENT_DATE
;+
; NAME:
;   CREATE_DATE
;
; PURPOSE:
;		Generate a series of dates based on given inputs
;
; CATEGORY:
;		DATE_FUNCTION
;
; CALLING SEQUENCE:
;   Result = CREATE_DATE(STARTDATE,ENDDATE)
;
; REQUIRED INPUTS:
;   STARDATE....... The first date of the time series
;   ENDDATE........ The last date of the time series
;
; KEYWORD PARAMETERS:
;	  DOY............ Set to return the result as YYYYDOY
;	  JD............. Set to return result as julian day
;	  CURRENT_DATE... Set to make the ENDATE the current date
;
; OUTPUTS:
;	  An array of specified dates either in YYYYMMDD (default), DOY, or JD
;
; OPTIONAL OUTPUTS:
;   None
; 
; SIDE EFFECTS:
;   Currently only considers leap year between 1960 and 2040
;
; RESTRICTIONS:
;   Program assumes date is a string 8 characters long (e.g. 19770317)
;
; EXAMPLE:
;    Result = CREATE_DATE('20200101','20221231')
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2005, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written April 21, 2005 by Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
; 
; MODIFICATION HISTORY:
;   Apr 21, 2005 - KJWH: Initial code written
;   Mar 09, 2016 - KJWH: Added CURRENT_DATE keyword to make the ENDDATE the current date
;   Jan 30, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL2
;-
;*******************************************************************************************************************
 
  ROUTINE_NAME = 'CREATE_DATE'
  COMPILE_OPT IDL2

  IF NONE(ENDDATE) OR KEY(CURRENT_DATE) THEN ENDDATE = DATE_NOW(/DATE_ONLY)

;	===> Create years and leapyears
	YEARS = SINDGEN(181)+1960
	LP = 4
	LEAP_YEARS = MISSINGS('')
	FOR NTH = 0L, N_ELEMENTS(YEARS)-1 DO BEGIN
		IF NTH MOD LP EQ 0 THEN BEGIN
			IF NTH EQ 0 THEN LEAP_YEARS = STRTRIM(YEARS[NTH],2) ELSE LEAP_YEARS = [LEAP_YEARS,STRTRIM(YEARS[NTH],2)]
		ENDIF
	ENDFOR

;	===> Create DOY for normal and leap years
	DAYS = SINDGEN(365)+1
	DAYS = STRTRIM(DAYS,2)
	OK = WHERE(DAYS LT 10)
	DAYS[OK] = '00'+DAYS[OK]
	OK = WHERE(DAYS GT 9 AND DAYS LT 100)
	DAYS[OK] = '0'+ DAYS[OK]
	LDAYS = [DAYS,'366']

;	===> Determine start and end dates
	SYEAR = STRMID(STRTRIM(STRING(STARTDATE),2),0,4)
	OK = WHERE(SYEAR EQ YEARS,COUNT)
	IF COUNT NE 1 THEN BEGIN
		PRINT, 'ERROR: Invalid start date'
		RETURN, []
	ENDIF
	SDOY = DATE_2DOY(STARTDATE)
	SJD = DATE_2JD(STARTDATE)

	EYEAR = STRMID(STRTRIM(STRING(ENDDATE),2),0,4)
	OK = WHERE(EYEAR EQ YEARS,COUNT)
	IF COUNT NE 1 THEN BEGIN
		PRINT, 'ERROR: Invalid end date'
		RETURN, []
	ENDIF
	EDOY = DATE_2DOY(ENDDATE)
	EJD	 = DATE_2JD(ENDDATE)

	IF SJD GT EJD THEN BEGIN
		PRINT, 'ERROR: STARTDATE is greater than ENDDATE
		RETURN, DATES
	ENDIF

	OK = WHERE(YEARS GE SYEAR AND YEARS LE EYEAR)
	YRS = YEARS[OK]
	YDOY = MISSINGS('')
	FOR NTH=0L, N_ELEMENTS(YRS)-1 DO BEGIN
		YR = STRTRIM(STRING(YRS[NTH]),2)
		OK = WHERE(LEAP_YEARS EQ YR,COUNT)
		IF COUNT EQ 1 THEN D = LDAYS ELSE D = DAYS
		R = REPLICATE(YR, N_ELEMENTS(D))
		RD = R+D
		IF NTH EQ 0 THEN YDOY = RD ELSE YDOY = [YDOY,RD]
	ENDFOR

	DATE = YDOY_2DATE(STRMID(YDOY,0,4),STRMID(YDOY,4,3))
	JDATE   = DATE_2JD(DATE)
	OK = WHERE(JDATE GE SJD AND JDATE LE EJD)

	DATES = DATE[OK]

	IF KEYWORD_SET(DOY) THEN BEGIN
		RETURN, YDOY[OK]
	ENDIF

	IF KEYWORD_SET(JD)  THEN BEGIN
		RETURN, JDATE[OK]
	ENDIF

	RETURN, DATES

  END ; END OF PROGRAM
