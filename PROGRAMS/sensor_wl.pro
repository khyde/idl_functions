; $ID:	SENSOR_WL.PRO,	2014-04-29	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION SENSOR_WL,SENSOR 
	
;  PRO SENSOR_WL
;+
; NAME:
;		SENSOR_WL
;
; PURPOSE: THIS FUNCTION GETS THE WAVELENGTHS FOR A SENSOR
;
; CATEGORY:
;		SENSORS
;		 
;
; CALLING SEQUENCE:RESULT = SENSOR_WL(SENSOR)
;
; INPUTS:
;		SENSOR:	INPUT SENSOR NAME [STRING] 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, SENSOR_WL(['SEAWIFS'])
;	NOTES:
;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2013 J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************
ROUTINE_NAME  = 'SENSOR_WL'
; *******************************

S = SENSOR_DATA(SENSOR)
RETURN,S.WL
DONE:          
	END; #####################  END OF ROUTINE ################################
