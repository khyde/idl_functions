; $ID:	MAPS_LANDMASK_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;#############################################################################################################
	PRO MAPS_LANDMASK_DEMO

;
; PURPOSE: DEMO FOR MAPS_LANDMASK
;
; CATEGORY:	MAPS
;
; CALLING SEQUENCE: MAPS_LANDMASK_DEMO
;
; INPUTS: NONE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: LANDMASKS
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			 APR 2,2014 WRITTEN BY J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;***********************************
ROUTINE_NAME  = 'MAPS_LANDMASK_DEMO'
;***********************************
 ; SET_PLOT,'WIN'

 ; MAPS = MAPS_READ(/NAMES) & PN,MAPS,'MAPS'
  MAPS='GOMN'
  FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
    ;POF,MAPS,NTH
    AMAP = MAPS[NTH]
    M = MAPS_READ(AMAP)
    IF M.INIT NE 'MAP_SET' THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    MAPS_LANDMASK,AMAP,METHOD='IDL'
  ENDFOR;FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN

END; #####################  END OF ROUTINE ################################
