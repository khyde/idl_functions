; $ID:	SENSOR_LETTER_2SENSOR.PRO,	2020-07-01-12,	USER-KJWH	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION SENSOR_LETTER_2SENSOR,NAME 
	
;  PRO SENSOR_LETTER_2SENSOR
;+
; NAME:
;		SENSOR_LETTER_2SENSOR
;
; PURPOSE: THIS FUNCTION RETURNS THE SATELLITE SENSO BASED ON THE FIRST LETTER IN THE INPUT NAME
;
; CATEGORY:
;		DATE
;		 
;
; CALLING SEQUENCE:RESULT = SENSOR_LETTER_2SENSOR(NAME)
;
; INPUTS:
;		SENSOR:	INPUT STRING NAME
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		OFF: TURNS OFF THE NEXT ITEM IN THE SENSOR LIST [BY SERTTING ITS VALUE TO A NULL STRING


; OUTPUTS:
;		
;; EXAMPLES:
;  PRINT, SENSOR_LETTER_2SENSOR(['A2013046.L3m_DAY_CHL_chlor_a_9km'])
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2012  J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='SENSOR_LETTER_2SENSOR'
; *******************************************

; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 
LETTER = STRUPCASE(STRMID(NAME,0,1))
  CASE (LETTER) OF
    'C': BEGIN & RETURN,'CZCS' & END
    'O': BEGIN & RETURN,'OCTS' & END
    'S': BEGIN & RETURN,'SEAWIFS' & END
    'T': BEGIN & RETURN,'TERRA' & END  
    'A': BEGIN & RETURN,'AQUA' & END 
    'M': BEGIN & RETURN,'MERIS' & END   
    'E': BEGIN & RETURN,'ESACCI' & END 
    ELSE: BEGIN
    RETURN,''
    END
  ENDCASE


DONE:          
	END; #####################  END OF ROUTINE ################################
