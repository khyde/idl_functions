; $ID:	TOPO_MAPS_MAKE_BATCH.PRO,	2020-07-01-12,	USER-KJWH	$
;+
;#############################################################################################################
	PRO TOPO_MAPS_MAKE_BATCH

;
; PURPOSE: BATCH JOB  FOR TOPO_MAPS_MAKE
;
; CATEGORY:	MAPS, TOPO
;
; CALLING SEQUENCE: TOPO_MAPS_MAKE_BATCH
;
; INPUTS: NONE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: TOPO MAPS
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			 MAR 29, 2016 WRITTEN by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			 MAR 30, 2016 - KJWH: 
;			
;			
;			
;#################################################################################
;
;-
;***********************************
ROUTINE_NAME  = 'TOPO_MAPS_MAKE_BATCH'
;***********************************
  SET_PLOT,!D.NAME
  MAPS = MAPS_READ(/NAMES,/TRUE) & PN,MAPS,'MAPS'
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
    MAPP = MAPS[NTH]
    POF,NTH,MAPS,/NOPRO,TXT='Making ' + MAPP
    M = MAPS_READ(MAPP)
    IF M.INIT NE 'MAP_SET' THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    TOPO_MAPS_MAKE,MAPP,OVERWRITE=0
  ENDFOR;FOR NTH = 0,N_ELEMENTS(MAPS) -1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
END; #####################  END OF ROUTINE ################################
