; $ID:	SENSOR_MAPS.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION SENSOR_MAPS, DATASET

;+
; NAME:
;   SENSOR_MAPS
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = SENSOR_MAPS($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 26, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   May 26, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SENSOR_MAPS'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  SENSOR_FILE = !S.IDL_MAINFILES + 'SENSORS_MAIN.csv'
  
  DAT = CSV_READ(SENSOR_FILE)
  
  IF ~N_ELEMENTS(DATASET) THEN RETURN, DAT
  
  
  MAPS = STRARR(N_ELEMENTS(DATASET))
  FOR D=0, N_ELEMENTS(DATASET)-1 DO BEGIN
    OK = WHERE(DAT.SENSOR EQ DATASET[D],COUNT)
    IF COUNT EQ 0 THEN BEGIN
      PRINT, 'ERROR: Unable to find ' + DATASET[D] + ' in ' + SENSOR_FILE
      RETURN, []
    ENDIF
    
    DSET = DAT[OK]
    IF COUNT GT 1 THEN BEGIN
      OKVER = WHERE(DSET.VERSION_STATUS EQ 'CURRENT', CTVER)
      IF CTVER EQ 0 THEN MESSAGE, 'ERROR: No default VERSION indicated in ' + SENSOR_FILE + ' for ' + DATASET[D]
      IF CTVER GT 1 THEN BEGIN
        MESSAGE, 'ERROR: More than one default VERSION indicated in ' + SENSOR_FILE + ' for ' + DATASET[D], /CONTINUE      
        OKDEF = WHERE(FIX(DSET.DEFAULT_COVERAGE) EQ 1 AND DSET.VERSION_STATUS EQ 'CURRENT', CTDEFAULT)
        IF CTDEFAULT EQ 0 THEN MESSAGE, 'ERROR: No default coverage indicated in ' + SENSOR_FILE + ' for ' + DATASET[D]
        IF CTDEFAULT GT 1 THEN MESSAGE, 'ERROR: More than one default coverage indicated in ' + SENSOR_FILE + ' for ' + DATASET[D]
        MAPS[D] = DSET[OKDEF].DEFAULT_MAP
      ENDIF ELSE MAPS[D] = DSET[OKVER].DEFAULT_MAP
    ENDIF ELSE MAPS[D] = DSET[OK].DEFAULT_MAP
  ENDFOR
  
  RETURN, MAPS


END ; ***************** End of SENSOR_MAPS *****************
