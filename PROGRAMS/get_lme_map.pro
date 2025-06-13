; $ID:	GET_LME_MAP.PRO,	2014-04-29	$


;#############################################################################################################
	FUNCTION GET_LME_MAP,VERBOSE=VERBOSE
	
;  PRO GET_LME_MAP
;+
; NAME:
;		GET_LME_MAP
;
; PURPOSE: THIS FUNCTION RETURNS THE STANDARD SMI IMAGE WITH ALL THE LMES 
;           MADE WITH STEP DO_MAKE_SMI_LME_67_MASTER_MAP IN MAKE_LME67_MAPS
;
; CATEGORY:
;		MAPS
;		 
;
; CALLING SEQUENCE:RESULT = GET_LME_MAP()
;
; INPUTS:
;		NONE:	
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: THE STANDARD LME SMI IMAGE WITH 67 SUBAREAS
;		
;; EXAMPLES:
;  LMES = GET_LME_MAP()
;	NOTES:

; MODIFICATION HISTORY:
;			WRITTEN SEP 16,2013 J.O'REILLY
;			OCT 2,2013,JOR GET_PATH
;			OCT 6,2013,JOR, NEW >C:\IDL\LME\LME-67-SMI-MASTER.PNG 
;			                IDENTICAL TO OLD AFTER APPLYING READ_LANDMASK]
;			OCT 8,2013,JOR ADDED VERBOSE
;			
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_LME_MAP'
;****************************
LME_IMAGE_FILE =GET_PATH()+ 'IDL\IMAGES\LME-67-SMI-MASTER.PNG'; NEW MADE USING DO_MAKE_SMI_LME_67_MASTER_MAP 
LME_IMAGE = READ_PNG(LME_IMAGE_FILE,R,G,B) & PAL_LME
IF KEYWORD_SET(VERBOSE) THEN PFILE,LME_IMAGE_FILE,/I
RETURN,LME_IMAGE
DONE:          
END; #####################  END OF ROUTINE ################################
