; $ID:	MAPS_LANDMASK_BATCH.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO MAPS_LANDMASK_BATCH

;
; PURPOSE: BATCH JOB  FOR MAPS_LANDMASK
;
; CATEGORY:	MAPS
;
; CALLING SEQUENCE: MAPS_LANDMASK_BATCH
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
;			 APR  2, 2014 WRITTEN BY J.O'REILLY
;			 MAR 29, 2016 - KJWH: Removed PFILE
;			
;			
;			
;#################################################################################
;
;-
;***********************************
ROUTINE_NAME  = 'MAPS_LANDMASK_BATCH'
;***********************************
  SET_PLOT,!D.NAME
  MAPS = MAPS_READ(/NAMES,/TRUE) & PN,MAPS,'MAPS'
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
    MAPP = MAPS[NTH]
    POF,NTH,MAPS,/NOPRO,TXT='Making ' + MAPP
    M = MAPS_READ(MAPP)
    IF M.INIT NE 'MAP_SET' THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    MAPS_LANDMASK,MAPP,OVERWRITE=0
  ENDFOR;FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
END; #####################  END OF ROUTINE ################################
