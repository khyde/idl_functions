; $ID:	SENSOR_DATES.PRO,	2023-09-21-13,	USER-KJWH	$

	FUNCTION SENSOR_DATES, SENSOR, JOIN=JOIN, MONTH=MONTH, YEAR=YEAR
	
;+
; NAME:
;		SENSOR_DATES
;
; PURPOSE: 
;   This function returns the beginning and ending dates [of available data from OBBG NASA] for a sensor mission
;
; CATEGORY:
;		DATE 
;
; CALLING SEQUENCE:
;   RESULT = SENSOR_DATES(SENSOR)
;
; REQUIRED INPUTS:
;		SENSOR......... The name of a valid "sensor"
;		
; OPTIONAL INPUTS:
;		None	
;		
; KEYWORD PARAMETERS:
;		JOIN........... Join the start and end dates with an "_' 
;		MONTH.......... Default to the first and last day of the month 
;   YEAR........... Default to the first and last day of the year
;
; OUTPUTS:
;		A string array of start and end dates of [available] data for the input sensor
;	
; OPTIONAL OUTPUTS:
;   None
;   
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;  PRINT, SENSOR_DATES('CZCS')
;  PRINT, SENSOR_DATES('OCTS')
;  PRINT, SENSOR_DATES('SEAWIFS')
;  PRINT, SENSOR_DATES('MODIST')
;  PRINT, SENSOR_DATES('MODISA')
;  PRINT, SENSOR_DATES('MERIS')
;  PRINT, SENSOR_DATES('COSTAMV')
;
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on February 16, 2013 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;   Inquiries should be directed to kimberly.hyde@noaa.gov
;   
; MODIFICATION HISTORY: 
;		FEB 16, 2013 - JEOR: Wrote initial code
; 	FEB 11, 2015 - KJWH: Added keyword JOIN to join the dates into a single string
;		OCT 22, 2015 - KJWH: Added VIIRS sensor dates and changed formatting
;		OCT 23, 2015 - KJWH: Changed AQUA to MODISA and TERRA to MODIST
;		OCT 24, 2015 - JEOR: Updated examples [MODISA,MODIST]
;		OCT 30, 2015 - KJWH: Added AVHRR and MUR dates
;		JUL 06, 2016 - KJWH: Added AQUA and TERRA sensor names and an error message if the sensor name doesn't match what is in the CASE list.
;		JAN 19, 2017 - KJWH: Fixed error in AVHRR dates.  Changed start date from 19811101 to 19810825
;		NOV 16, 2017 - KJWH: Now returning just the YYYYMMDD for the SENSOR DATES
;	                       Changed RETURN,SATDATE_2DATE(STRMID(SATDATES,0,8)) to RETURN,STRMID(SATDATE_2DATE(SATDATES),0,8)
;		DEC 04, 2017 - KJWH: Added several combination sensors (e.g. SA, SAT, SAV)            
;	                       Added keyword MONTH to make the beginning and end at the first and last day of the month
;		                     Added keyword YEAR to make the beginning and dates the first and last day of the year 
;		DEC 07, 2017 - KJWH: Changed the start date for VIIRS to '2012002'       
;		FEB 02, 2018 - KJWH: Changed YEAR = DATE_2YEAR(TODAY) to YR = DATE_2YEAR(TODAY) to avoid a conflict with the keyword YEAR   
;		FEB 26, 2018 - KJWH: Added OCCCI sensor   
;   MAR 18, 2018 - JEOR: ADDED 'COSTAMV' SENSOR    
;   APR 05, 2019 - KJWH: Added JPSS (VIIRS-NOAA20) SENSOR      
;   JUL 23, 2019 - KJWH: Added HERMES sensor  
;   DEC 01, 2020 - KJWH: Updated documentation
;                        Added ERROR message if more than 1 SENSOR provided
;                        Added COMPILE_OPT IDL2   
;   Jan 10, 2022 - KJWH: Changed HERMES to GLOBCOLOUR    
;   Feb 17, 2022 - KJWH: Added GEOPOLAR (SST)  
;   Mar 31, 2022 - KJWH: Added GEOPOLAR_INTERPOLATED (SST)        
;   Oct 11, 2022 - KJWH: Updated ACSPO start date                
;-
;	********************************************************************************
  ROUTINE_NAME  = 'SENSOR_DATES'
  COMPILE_OPT IDL2
  
  TODAY = STRMID(DATE_NOW(/GMT),0,8)
  YR = DATE_2YEAR(TODAY)
  DOY = STR_PAD(ROUNDS(DATE_2DOY(TODAY)),3)
  YDOY = YR+DOY
  JD = DATE_2JD(TODAY)

  IF N_ELEMENTS(SENSOR) NE 1 THEN RETURN, 'ERROR: Input sensor array must contain 1 element.'

; ===> First and last satdates of available data for each mission
  SATDATES = []
  CASE STRUPCASE(SENSOR) OF
    'CZCS':       SATDATES = ['C1978303', 'C1986173']      
    'OCTS':       SATDATES = ['O1996306', 'O1997181']  
    'SEAWIFS':    SATDATES = ['S1997247', 'S2010345']  
    'MODISA':     SATDATES = ['A2002185', 'A'+YDOY]  
    'AQUA':       SATDATES = ['A2002185', 'A'+YDOY]  
    'MODIST':     SATDATES = ['T2000055', 'T'+YDOY]  
    'TERRA':      SATDATES = ['T2000055', 'T'+YDOY]  
    'MERIS':      SATDATES = ['M2002119', 'M2012099']      
    'VIIRS':      SATDATES = ['V2012002', 'V'+YDOY]
    'JPSS1':      SATDATES = ['V2017347', 'V'+YDOY]
    'AVHRR':      DATES = ['19810825', TODAY]
    'MUR':        DATES = ['20020601', TODAY]
    'SA':         DATES = ['19970904', TODAY] ; SeaWiFS + MODISA
    'AT':         DATES = ['20000224', TODAY] ; MODIST + MODISA
    'SAT':        DATES = ['19970904', TODAY] ; SeaWiFS + MODIST + MODISA
    'AV':         DATES = ['20020704', TODAY] ; MODISA + VIIRS
    'SAV':        DATES = ['19970904', TODAY] ; SeaWiFS + MODISA + VIIRS
    'SAVJ':       DATES = ['19970904', TODAY] ; SeaWiFS + MODISA + VIIRS + JPSS1
    'SATV':       DATES = ['19970904', TODAY] ; SeaWiFS + MODISA + MODIST + VIIRS
    'ATV':        DATES = ['20000224', TODAY] ; SeaWiFS + MODISA + MODIST + VIIRS
    'OCCCI':      DATES = ['19970904', TODAY] ; Blended ESA product.  As of 2018-02-26, only current through 2016-12-31, but should be updated routinely
    'GLOBCOLOUR': DATES = ['19970904', TODAY] ; Blended GlobColour product.  
    'GEOPOLAR':   DATES = ['20020901', TODAY] ; Blended NOAA SST product
    'GEOPOLAR':   DATES = ['20020901', TODAY] ; Blended NOAA SST product
    'GEOPOLAR_INTERPOLATED':   DATES = ['20020901', TODAY] ; Blended and interpolated NOAA SST product
    'COSTAMV':    DATES = ['19781030', TODAY] ; JAY [CZCS,OCTS,SEAWIFS,TERRA,AQUA,MERIS,VIIRS]
    'MEASURES':   DATES = ['19920925', TODAY] ; Sea surface height
    'CMES':       DATES = ['19930101', TODAY] ; 
    'CORAL':      DATES = ['19850101', TODAY] ; Coral Reef Watch
    'ACSPO':      DATES = ['20000224', TODAY] ; NOAA super-collated SST
    'ACSPONRT':      DATES = ['202204023', TODAY] ; NOAA super-collated SST - Near real-time
    'OISST': DATES = ['19810101',TODAY] ; Optimally interpolated SST
    ELSE:      RETURN,'ERROR: Invalid SENSOR (' + SENSOR + ')'
  ENDCASE
  
  IF SATDATES NE [] THEN DATES = SATDATE_2DATE(SATDATES)
  IF KEY(MONTH) THEN BEGIN
    DATES[0] = STRMID(DATES[0],0,6) + '01'
    DATES[1] = STRMID(DATES[1],0,6) + DAYS_MONTH(STRMID(DATES[1],4,2),YEAR=STRMID(DATES[1],0,4),/STRING)
  ENDIF
  IF KEY(YEAR) THEN BEGIN
    DATES[0] = STRMID(DATES[0],0,4) + '0101'
    DATES[1] = STRMID(DATES[1],0,4) + '1231'
  ENDIF
  
  IF KEY(JOIN) THEN RETURN,STRJOIN(STRMID(DATES,0,8),'-') ELSE RETURN,STRMID(DATES,0,8)
  
  DONE:          

END; #####################  END OF ROUTINE ################################
