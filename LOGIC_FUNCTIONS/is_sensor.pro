; $ID:	IS_SENSOR.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION IS_SENSOR, SENSOR

;+
; NAME:
;   IS_SENSOR
;
; PURPOSE:
;   Uses the VALIDS function to determine if the input sensor name is in the MASTER list of sensors
;
; CATEGORY:
;   LOGIC
;
; CALLING SEQUENCE:
;   Result = IS_SENSOR(SENSOR)
;
; REQUIRED INPUTS:
;   SENSOR.......... A text array of "sensors"
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   1............. If the text is a "valid" sensor
;   0............. If the text is not a "valid" sensor 
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
;   PRINT, IS_SENSOR('SEAWIFS')
;   PRINT, IS_SENSOR(['SEAWIFS','MODISA','APPLE','DOG','CAT','VIIRS'])
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
;   This program was written on November 04, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 04, 2020 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'IS_SENSOR'
  COMPILE_OPT IDL2
  
  VALID = REPLICATE(0, N_ELEMENTS(SENSOR))
  VAL = VALIDS('SENSORS',SENSOR)
  OK = WHERE(VAL NE '', COUNT)
  IF COUNT GT 0 THEN VALID[OK] = 1
  
  RETURN, VALID

END ; ***************** End of IS_SENSOR *****************
