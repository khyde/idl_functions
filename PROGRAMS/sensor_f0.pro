; $ID:	SENSOR_F0.PRO,	2020-06-26-15,	USER-KJWH	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION SENSOR_F0,SENSOR,WL=WL
	
;  PRO SENSOR_F0
;+
; NAME:
;		SENSOR_F0
;
; PURPOSE: THIS FUNCTION GETS THE f0 FOR A SENSOR
;
; CATEGORY:
;		SENSORS
;		 
;
; CALLING SEQUENCE:RESULT = SENSOR_F0(SENSOR)
;
; INPUTS:
;		SENSOR:	INPUT SENSOR NAME [STRING] 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   WL:   WAVELENGTH TO USE TO GET A SPECIFIC F0

; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, SENSOR_F0('SEAWIFS',WL = 444)
;  PRINT, SENSOR_F0('SEAWIFS',WL = 144); ERROR [ NO 144 WL FOR SEAWIFS
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN APR 27,2013 J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************
ROUTINE_NAME  = 'SENSOR_F0'
; *******************************

S = SENSOR_DATA(SENSOR)

IF N_ELEMENTS(WL) EQ 1 THEN BEGIN
  
  OK = WHERE(S.WL EQ WL,COUNT)
  IF COUNT EQ 1 THEN RETURN,S.F0[OK] ELSE RETURN,'ERROR: CAN NOT FIND INPUT WL:  '+ STRTRIM(WL,2)
ENDIF ELSE BEGIN

RETURN,S.f0

ENDELSE; IF N_ELEMENTS(WL) EQ 1 THEN BEGIN

DONE:          
	END; #####################  END OF ROUTINE ################################
