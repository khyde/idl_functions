; $ID:	READ_MAP_DATA.PRO,	2020-06-26-15,	USER-KJWH	$
;#############################################################################################################
	FUNCTION READ_MAP_DATA,MAPS 
	
;  PRO READ_MAP_DATA
;+
; NAME:
;		READ_MAP_DATA
;
; PURPOSE: THIS FUNCTION RETURNS THE DATA ON MAPS IN A STRUCTURE 
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = READ_MAP_DATA(TXT)
;
; INPUTS:
;		MAPS:	NAME(S) OF MAPS EG.[SMI,GEQ,NEC] 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: A STRING [E.G.FOR SMI] LIMIT = [-90.000000,-180.00000,90.000000,180.00000]
;		
;; EXAMPLES:
;  PRINT, READ_MAP_DATA()
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 10, 2013 J.O'REILLY
;			OCT 15,2013,JOR RENAMED TO READ_MAP_DATA
;#################################################################################
;
;
;-
;************************************
ROUTINE_NAME  = 'READ_MAP_DATA'
;************************************
SAVEFILE = GET_PATH() + 'IDL\DATA\MAPS_DATA_MASTER.SAVE'
DB = IDL_RESTORE(SAVEFILE)
;;OK = WHERE_IN(DB.MAP,  INFO,COUNT,/NO_SORT);===>/NO_SORT NOT WORKING MAINTAIN INFO INPUT ORDER
OK = WHERE_IN(DB.MAP,  MAPS,COUNT)
IF COUNT GE 1 THEN RETURN, DB[OK]
DONE:          
	END; #####################  END OF ROUTINE ################################
