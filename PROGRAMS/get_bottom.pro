; $ID:	GET_BOTTOM.PRO,	2014-06-23-19	$
;+
;;#############################################################################################################
	FUNCTION GET_BOTTOM,LON,LAT

; PURPOSE: THIS FUNCTION GETS THE BOTTOM DEPTH FROM !S.DATA +'SRTM30-SMI-PXY_4320_2160-BATHY.SAVE'

; 
; 
; CATEGORY:	UTILITY;		 
;
; CALLING SEQUENCE: RESULT = GET_BOTTOM(LON,LAT)
;
; INPUTS: LON - LONGITUDE
;         LAT - LATITUDE  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  PRINT, GET_BOTTOM(LON,LAT)
;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN JUN 23,2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_BOTTOM'
;****************************
IF NONE(LON) OR NONE(LAT) THEN MESSAGE,'ERROR: LON & LAT ARE REQUIRED'
BATHY_FILE=!S.DATA +'SRTM30-SMI-PXY_4320_2160-BATHY.SAVE'
COMMON GET_BOTTOM_ ,BOTTOM_DEPTH
IF NONE(BOTTOM_DEPTH) THEN BOTTOM_DEPTH = STRUCT_SD_READ(BATHY_FILE)
MAPS_SET,'SMI'
XYZ = CONVERT_COORD(LON,LAT,/DATA,/TO_DEVICE)
XP = REFORM(XYZ(0,*))
YP = REFORM(XYZ(1,*))
RETURN, BOTTOM_DEPTH(XP,YP)
 
DONE:          
	END; #####################  END OF ROUTINE ################################
