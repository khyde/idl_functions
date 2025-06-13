; $ID:	RRS_SWAP.PRO,	2020-06-30-17,	USER-KJWH	$

  FUNCTION RRS_SWAP, RRS=RRS, SENSOR_IN=SENSOR_IN, SENSOR_OUT=SENSOR_OUT

;+
; NAME:
;   RRS_SWAP
;
; PURPOSE:
;   This function returns standardized wavelengths (mainly to compare similar wavelengths from different sensors)
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;   R = RRS_SWAP(RRS)
;   
; INPUTS:
;   SENSOR_IN.....The RRS wavelength (can input just the number or RRS_xxx)
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   A structure of sensor specific sensor RRS wavelengths
;
; OPTIONAL OUTPUTS:
;   
; EXAMPLE:
;   PRINT, RRS_SWAP(RRS='RRS_488')
;   PRINT, RRS_SWAP(RRS='488')
;   PRINT, RRS_SWAP(RRS='667')
;   PRINT, RRS_SWAP(RRS=488)
;   PRINT, RRS_SWAP(RRS=[412,443,488])
;   PRINT, RRS_SWAP(RRS=['RRS_412','RRS_443','RRS_488'])
;   PRINT, RRS_SWAP(RRS=GET_RRS('MODISA'))
;   PRINT, RRS_SWAP(SENSOR_IN='MODISA',SENSOR_OUT='SEAWIFS')
;  
;  
; NOTES:
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          
;
; MODIFICATION HISTORY:
;			Written:  October 17, 2018 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;			
;-
;	****************************************************************************************************
  ROUTINE_NAME = 'RRS_SWAP'
	
  IF ANY(SENSOR_IN)   THEN IRRS = STRMID(GET_RRS(SENSOR_IN),4,3)
  IF NONE(SENSOR_OUT) THEN ORRS = STRMID(GET_RRS('SEAWIFS'),4,3) ELSE ORRS = STRMID(GET_RRS(SENSOR_OUT),4,3)
  
  ADD_RRS = 0
  IF ANY(RRS) THEN BEGIN
    IF HAS(RRS[0],'RRS_') THEN ADD_RRS = 1 
    _RRS = REPLACE(RRS,'RRS_','')
    OK = WHERE_MATCH(IRRS,_RRS,COUNT)
    IF COUNT GT 0 THEN IRRS = IRRS[OK] ELSE GOTO, DONE
  ENDIF
  
  R412 = ['412','410','413']
  R443 = ['443']
  R469 = ['469']
  R490 = ['488','486','490']
  R510 = ['510','516','520']
  R531 = ['531']
  R547 = ['547']
  R555 = ['550','551','555','560']
  R565 = ['565']
  R620 = ['620']
  R645 = ['645']
  R670 = ['665','667','670','671']
  R678 = ['678']
  R681 = ['681']
  R709 = ['709']
  R750 = ['750']
  
  ALL = LIST(R412,R443,R490,R510,R555,R670)
  
  FOR A=0, N_ELEMENTS(ALL)-1 DO BEGIN
    R = ALL(A)
    CASE R[0] OF
      '412': BEGIN & I412 = WHERE_MATCH(IRRS,R412,CTI) & O412 = WHERE_MATCH(ORRS,R412,CTO) & IF CTI GT 0 AND CTO GT 0 THEN IRRS = REPLACE(IRRS,IRRS(I412),ORRS(O412)) & END
      '488': BEGIN & I488 = WHERE_MATCH(IRRS,R490,CTI) & O488 = WHERE_MATCH(ORRS,R490,CTO) & IF CTI GT 0 AND CTO GT 0 THEN IRRS = REPLACE(IRRS,IRRS(I488),ORRS(O488)) & END
      '550': BEGIN & I550 = WHERE_MATCH(IRRS,R555,CTI) & O550 = WHERE_MATCH(ORRS,R555,CTO) & IF CTI GT 0 AND CTO GT 0 THEN IRRS = REPLACE(IRRS,IRRS(I550),ORRS(O550)) & END
      '665': BEGIN & I665 = WHERE_MATCH(IRRS,R670,CTI) & O665 = WHERE_MATCH(ORRS,R670,CTO) & IF CTI GT 0 AND CTO GT 0 THEN IRRS = REPLACE(IRRS,IRRS(I665),ORRS(O665)) & END
      ELSE:  IRRS=IRRS
    ENDCASE
  ENDFOR  
  
  OK = WHERE_MATCH(IRRS,ORRS,COUNT)
  IF COUNT GE 1 THEN IRRS = IRRS[OK]
  
  IF ADD_RRS EQ 1 THEN IRRS = 'RRS_' + IRRS
  
  DONE:
  RETURN, IRRS
  
  
END; #####################  End of Routine ################################
