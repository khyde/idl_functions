; $ID:	SENSOR_WAVELENGTHS.PRO,	2020-03-02-10,	USER-KJWH	$

	FUNCTION SENSOR_WAVELENGTHS, SENSOR, VERSION=VERSION, STRING=STRING 
	
;+
; NAME:
;		SENSOR_WAVELENGTHS
;

; NAME:
;   SATSHIP_GET_FILES.PRO
;
; PURPOSE:
;   Get the RRS wavelengths of an ocean color sensor
;
; CATEGORY:
;   Information
;
; CALLING SEQUENCE:
;  RESULT = SENSOR_WAVELENGTHS, SENSOR
;  
; INPUTS:
;   SENSOR:   The name of a valid ocean color sensor
;   
; OPTIONAL INPUTS:
;   NA
;   
; KEYWORD PARAMETERS:
;   STRING: To return the values as a string instead of an integer
;
; OUTPUTS:
;   A list of sensor specific wavelenths
;
; OPTIONAL OUTPUTS:
;   NA
;
; EXAMPLES:
;    RRS = SENSOR_WAVELENGTHS('SEAWIFS')
;    RRS = SENSOR_WAVELENTHS('MODISA',/STRING)
;
; NOTES:
;   This function must be updated with changes to sensor wavelengths or when new sensors are added to the dataset list
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;     Written Mar 2, 2020 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;                                         Adapted from SENSOR_BANDS
;     Modified:
;        
;			
;
;-
; #################################################################################


  ROUTINE_NAME  = 'SENSOR_WAVELENGTHS'

  IF ANY(VERSION) THEN BEGIN
    IF VERSION NE '' THEN SENSOR = SENSOR + '_' + VERSION
  ENDIF

; Get the center wavelenths for a specified sensor 
  CASE STRUPCASE(SENSOR) OF
    'MODISA':    RRS = [412, 443, 469, 488, 531, 547, 555, 645, 667, 678]
    'SEAWIFS':   RRS = [412, 443, 490, 510, 555, 670]
    'VIIRS':     RRS = [410, 443, 486, 551, 671]
    'JPSS1':     RRS = [411, 445, 489, 556, 667]
    'MERIS':     RRS = [413, 443, 490, 510, 560, 620, 665, 681, 709]
    'CZCS':      RRS = [443, 520, 550, 670, 750]
    'OCTS':      RRS = [412, 443, 490, 516, 565, 667]
    'OCCCI':     RRS = [412, 443, 490, 510, 555, 670]
    'OCCCI_5.0': RRS = [412, 443, 490, 510, 560, 665]
  ENDCASE
  
  
  IF KEYWORD_SET(STRING) THEN RETURN, ROUNDS(RRS) ELSE  RETURN,RRS


END; #####################  END OF ROUTINE ################################
