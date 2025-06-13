; $ID:	SENSOR_PRODS_L3M.PRO,	2020-06-26-15,	USER-KJWH	$
; 
;#############################################################################################################
	FUNCTION SENSOR_PRODS_L3M,SENSOR 
	
;  PRO SENSOR_PRODS_L3M
;+
; NAME:
;		SENSOR_PRODS_L3M
;
; PURPOSE: THIS FUNCTION RETURNS THE PRODS [AVAILABLE AS L3M-SMI] FOR  A SENSOR 
;
; CATEGORY:
;		SATELLITE		 
;
; CALLING SEQUENCE:RESULT = SENSOR_PRODS_L3M(SENSOR)
;
; INPUTS:
;		SENSOR:	INPUT  SENSOR [STRING]
;
; OUTPUTS:
;		A STRING ARRAY OF CENTRAL WAVELENGTHS FOR THE INPUT SENSOR

; EXAMPLES:
;  PRINT, SENSOR_PRODS_L3M(['CZCS'])
;  PLIST, SENSOR_PRODS_L3M(['OCTS'])
;  PLIST, SENSOR_PRODS_L3M(['SEAWIFS'])
;  PLIST, SENSOR_PRODS_L3M(['TERRA'])
;  PLIST, SENSOR_PRODS_L3M(['AQUA'])
;  PLIST, SENSOR_PRODS_L3M(['MERIS'])
;  
;	
;
; MODIFICATION HISTORY:
; 
;			WRITTEN APR 13,2013 J.O'REILLY
;			APR 14,2013,JOR REMOVED PAR FROM OCTS
;			MAY 3,2013,JOR, ADDED .L3m_DAY_GSM_adg_443_gsm_9km TO SEAWIFS & AQUA
;			
;#################################################################################
;
;
;-
;	******************************
ROUTINE_NAME  = 'SENSOR_PRODS_L3M'
; ******************************
;########################
; GET PRODS FOR A SENSOR:
CASE STRUPCASE(SENSOR) OF
  'CZCS': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_PAR_par_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_RRS_Rrs_520_9km']
    PRODS = ''
  END;CZCS
  
  'OCTS': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_516_9km']
  END;OCTS
  
  'SEAWIFS': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_PAR_par_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_RRS_Rrs_510_9km','.L3m_DAY_GSM_adg_443_gsm_9km','.L3m_DAY_GIOP_adg_443_giop_9km']
    END;SEAWIFS
  
  'AQUA': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_PAR_par_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_RRS_Rrs_488_9km','.L3m_DAY_RRS_Rrs_531_9km','.L3m_DAY_GSM_adg_443_gsm_9km','.L3m_DAY_GIOP_adg_443_giop_9km']
  END;AQUA
  
  'TERRA': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_PAR_par_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_RRS_Rrs_488_9km','.L3m_DAY_RRS_Rrs_531_9km']
  END;TERRA
  
  'MERIS': BEGIN
    PRODS=['.L3m_DAY_CHL_chlor_a_9km','.L3m_DAY_KD490_Kd_490_9km','.L3m_DAY_RRS_Rrs_443_9km','.L3m_DAY_RRS_Rrs_510_9km']
  END;MERIS
  
    'ALL':BEGIN
    PRODS = [SENSOR_PRODS_L3M('CZCS'),SENSOR_PRODS_L3M('OCTS'),SENSOR_PRODS_L3M('TERRA'),SENSOR_PRODS_L3M('AQUA'),SENSOR_PRODS_L3M('MERIS')]
    SETS = WHERE_SETS(PRODS) & OK = WHERE(SETS.VALUE NE '') & SETS=SETS[OK]&PRODS=SETS.VALUE &  RETURN,PRODS
    
  END;ALL
ENDCASE
RETURN,PRODS




DONE:          

END; #####################  END OF ROUTINE ################################
