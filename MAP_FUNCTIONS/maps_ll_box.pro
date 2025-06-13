; $ID:	MAPS_LL_BOX.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION MAPS_LL_BOX

; PURPOSE: THIS FUNCTION RETURNS THE LON,LATS IN THE !MAP.LL_BOX AS A STRUCTURE
; 
; 
; CATEGORY:	MAPS FAMILY;		 
;
; CALLING SEQUENCE: RESULT = MAPS_LL_BOX()
;
; INPUTS: NONE  

; OPTIONAL INPUTS:  NONE
;		
; KEYWORD PARAMETERS: NONE

; OUTPUTS: STRUCTURE CONTAINING THE INFO IN !MAP.LL_BOX
;		
; EXAMPLES:

;            MAPS_SET,'NEC' & ST,MAPS_LL_BOX() & ZWIN
;            ZWIN,[1024,1024]& CALL_PROCEDURE,'MAP_NEC' & ST,MAPS_LL_BOX() & ZWIN

;
; MODIFICATION HISTORY:
;			WRITTEN AUG 30, 2015 J.O'REILLY
;			FEB 22,2016,JOR RENAMED TAGS TO AGREE WITH MAPS STRUCTURE
;#################################################################################
;-
;*****************************
ROUTINE_NAME  = 'MAPS_LL_BOX'
;*****************************
IF (!X.TYPE NE 3) THEN MESSAGE,'MAP TRANSFORM NOT ESTABLISHED.'
M = !MAP.LL_BOX
LATMIN = M[0]
LONMIN = M[1]
LATMAX = M(2)
LONMAX = M(3)
RETURN, CREATE_STRUCT('LATMIN',LATMIN,'LONMIN',LONMIN,'LATMAX',LATMAX,'LONMAX',LONMAX)
          
	END; #####################  END OF ROUTINE ################################
