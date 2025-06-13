; $ID:	SENSOR_EXTS.PRO,	2014-04-29	$
; ===> CHOOSE ONE: PRO OR FUNCTION 
;#############################################################################################################
	FUNCTION SENSOR_EXTS,SENSOR 
	
;  PRO SENSOR_EXTS
;+
; NAME:
;		SENSOR_EXTS
;
; PURPOSE: THIS FUNCTION RETURNS THE EXTS [OF AVAILABLE DATA FROM OBPG NASA] FOR A SENSOR 
;
; CATEGORY:
;		DATE
;		 
;
; CALLING SEQUENCE:RESULT = SENSOR_EXTS(SENSOR)
;
; INPUTS:
;		SENSOR:	INPUT  SENSOR [STRING]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE


; OUTPUTS:
;		A STRING ARRAY OF START AND END DATES OF [AVAILABLE] DATA FOR THE INPUT SENSOR

; EXAMPLES:
;  PL,SENSOR_EXTS()
;  PRINT, SENSOR_EXTS(['CZCS'])
;  PRINT, SENSOR_EXTS(['OCTS'])
;  PRINT, SENSOR_EXTS(['SEAWIFS'])
;  PRINT, SENSOR_EXTS(['TERRA'])
;  PRINT, SENSOR_EXTS(['AQUA'])
;  PRINT, SENSOR_EXTS(['MERIS'])
;  
;
;
; MODIFICATION HISTORY:
; 
;			WRITTEN FEB 27,2014 J.O'REILLY
;			MAR 1,2014,JOR   IF N_ELEMENTS(SENSOR) NE 1 THEN RETURN,EXTS

;			
;#################################################################################
;-
;******************************
ROUTINE_NAME  = 'SENSOR_EXTS'
;******************************
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A
  EXTS = [EXTS,'.L3m_DAY_PAR_par_9km.bz2']; PAR
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_488_9km.bz2']; RRS_488
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_510_9km.bz2']; RRS_510
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_516_9km.bz2']; RRS_516
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_531_9km.bz2']; RRS_531
  EXTS = [EXTS,'.L3m_DAY_GIOP_adg_443_giop_9km.bz2'];ADG_443_GIOP
  IF N_ELEMENTS(SENSOR) NE 1 THEN RETURN,EXTS
;########################################
CASE STRUPCASE(SENSOR) OF
  'CZCS': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  END;CZCS
  
  'OCTS': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_516_9km.bz2']; RRS_516
  END;OCTS
  
  'SEAWIFS': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_PAR_par_9km.bz2']; PAR
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_510_9km.bz2']; RRS_510
  EXTS = [EXTS,'.L3m_DAY_GIOP_adg_443_giop_9km.bz2'];ADG_443_GIOP
  END;SEAWIFS
  
  'AQUA': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_PAR_par_9km.bz2']; PAR
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_488_9km.bz2']; RRS_488
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_531_9km.bz2']; RRS_531
  EXTS = [EXTS,'.L3m_DAY_GIOP_adg_443_giop_9km.bz2'];ADG_443_GIOP
  END;AQUA
  
  'TERRA': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_PAR_par_9km.bz2']; PAR
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_488_9km.bz2']; RRS_488
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_531_9km.bz2']; RRS_531
  END;TERRA
  
  'MERIS': BEGIN
  EXTS = ['.L3m_DAY_CHL_chlor_a_9km.bz2']; CHLOR_A 
  EXTS = [EXTS,'.L3m_DAY_PAR_par_9km.bz2']; PAR
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_443_9km.bz2']; RRS_443
  EXTS = [EXTS,'.L3m_DAY_RRS_Rrs_510_9km.bz2']; RRS_510
  END;MERIS
    
ENDCASE

RETURN,EXTS

DONE:          

END; #####################  END OF ROUTINE ################################
