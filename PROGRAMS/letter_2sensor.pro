; $ID:	LETTER_2SENSOR.PRO,	2014-04-29	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION LETTER_2SENSOR,LETTER 
	
;  PRO LETTER_2SENSOR
;+
; NAME:
;		LETTER_2SENSOR
;
; PURPOSE: THIS FUNCTION RETURNS THE DWNSOR NAME FROM THE FIRST LETTER
;
; CATEGORY:
;		SENSORS
;		 
;
; CALLING SEQUENCE:RESULT = LETTER_2SENSOR(LETTER)
;
; INPUTS:
;		LETTER:	INPUT  LETTER [STRING]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE


; OUTPUTS:
;		A STRING ARRAY OF START AND END DATES OF [AVAILABLE] DATA FOR THE INPUT SENSOR

; EXAMPLES:
;  PRINT, LETTER_2SENSOR(['C'])
;  PRINT, LETTER_2SENSOR(['O'])
;  PRINT, LETTER_2SENSOR(['S'])
;  PRINT, LETTER_2SENSOR(['T'])
;  PRINT, LETTER_2SENSOR(['A'])
;  PRINT, LETTER_2SENSOR(['M'])
;  
;	
;
;
; MODIFICATION HISTORY:
; 
;			WRITTEN JUL 1,2013J.O'REILLY
;#################################################################################
;
;
;-
;	******************************
ROUTINE_NAME  = 'LETTER_2SENSOR'
; ******************************

;########################################
; FIRST AND LAST SATDATES [OF AVAILABLE L3m_DAY_CHL_chlor_a_9km DATA] FOR EACH MISSION:
CASE STRUPCASE(LETTER) OF
  'C': BEGIN
  SENSOR = 'CZCS'
  END;CZCS
  
  'O': BEGIN
  SENSOR = 'OCTS'
  END;OCTS
  
  'S': BEGIN
  SENSOR = 'SEAWIFS'
  END;SEAWIFS
  
  'A': BEGIN
  SENSOR = 'AQUA' 
  END;AQUA
  
  'T': BEGIN
  SENSOR = 'TERRA'
  END;TERRA
  
  'M': BEGIN
  SENSOR = 'MERIS'
  END;MERIS
    
ENDCASE

RETURN,SENSOR

DONE:          

END; #####################  END OF ROUTINE ################################
