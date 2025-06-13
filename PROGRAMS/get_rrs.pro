; $ID:	GET_RRS.PRO,	2018-10-16-11,	USER-KJWH	$

  FUNCTION GET_RRS, SENSOR

;+
; NAME:
;   GET_RRS
;
; PURPOSE:
;   This function returns a structure of sensor specific RRS wavelengths or just the wavelengths of a single sensor
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;   R = GET_RRS()
;   R = GET_RRS(SENSOR)
;   
; INPUTS:
;   None required (if SENSOR not provided, a structure of all information will be returned)
;
; OPTIONAL INPUTS:
;   SENSOR...... The name of a valid SENSOR
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   A structure of sensor specific sensor RRS wavelengths
;
; OPTIONAL OUTPUTS:
;   
; EXAMPLE:
;   HELP, GET_RRS(),/STRUCT
;   PRINT, GET_RRS('SEAWIFS')
;   PRINT, GET_RRS('MODISA')
;   PRINT, GET_RRS('VIIRS')
;   PRINT, GET_RRS('OCCCI') 
;  
;  
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          
;
; MODIFICATION HISTORY:
;			Written:  October 16, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;			
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_RRS'
	
	  IF N_ELEMENTS(SENSOR) EQ 1 THEN SENSOR = VALIDS('SENSORS',SENSOR) ELSE SENSOR = ''
	  
	  CZCS    = ['RRS_443', 'RRS_520', 'RRS_550', 'RRS_670', 'RRS_750']
    OCTS    = ['RRS_412', 'RRS_443', 'RRS_490', 'RRS_516', 'RRS_565', 'RRS_667']
    SEAWIFS = ['RRS_412', 'RRS_443', 'RRS_490', 'RRS_510', 'RRS_555', 'RRS_670']
    MODIST  = ['RRS_412', 'RRS_443', 'RRS_469', 'RRS_488', 'RRS_531', 'RRS_547', 'RRS_555', 'RRS_645', 'RRS_667', 'RRS_678']
	  MODISA  = ['RRS_412', 'RRS_443', 'RRS_469', 'RRS_488', 'RRS_531', 'RRS_547', 'RRS_555', 'RRS_645', 'RRS_667', 'RRS_678']
    MERIS   = ['RRS_413', 'RRS_443', 'RRS_490', 'RRS_510', 'RRS_560', 'RRS_620', 'RRS_665', 'RRS_681', 'RRS_709']
	  VIIRS   = ['RRS_410', 'RRS_443', 'RRS_486', 'RRS_551', 'RRS_671' ]
	  OCCCI   = ['RRS_412', 'RRS_443', 'RRS_490', 'RRS_510', 'RRS_555', 'RRS_670']  
	
	  STRUCT = CREATE_STRUCT('CZCS',CZCS,'OCTS',OCTS,'SEAWIFS',SEAWIFS,'MODIST',MODIST,'MODISA',MODISA,'MERIS',MERIS,'VIIRS',VIIRS,'OCCCI',OCCCI)
	  IF SENSOR EQ '' THEN RETURN, STRUCT
	  
	  OK = WHERE(TAG_NAMES(STRUCT) EQ SENSOR,COUNT)
	  IF COUNT EQ 0 THEN RETURN, STRUCT ELSE RETURN, STRUCT.(OK)
	
	


END; #####################  End of Routine ################################
