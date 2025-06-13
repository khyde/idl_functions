; $ID:	MAPS_GS_2L3B.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO MAPS_GS_2L3B, PX=PX, PY=PY, KM=KM

;+
; NAME:
;   MAPS_GS_2L3B
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   MAPS_FUNCTIONS
;
; CALLING SEQUENCE:
;   MAPS_GS_2L3B,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on August 06, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Aug 06, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_GS_2L3B'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
    
  
  PX = 7200
  PY = 3600
  MP = 'GS5'
  MI = MAPS_READ(MP)  ; Read to get the map projection details
  IF IDLTYPE(MI) EQ 'STRING' THEN BEGIN
    MI = MAPS_READ('GS4')
    MAPS_MAKE, MP, PROJ=MI.PROJ, LATMIN=MI.LATMIN, LATMAX=MI.LATMAX, LONMIN=MI.LONMIN, LONMAX=MI.LONMAX, ROTATION=0, ISOTROPIC=1,$
      P0LON=MI.P0_LON, P0LAT=MI.P0_LAT, PX=PX, PY=PY, MAPSCALE=''
  ENDIF
  
  LAND = READ_LANDMASK(MP)
  LSTR = READ_LANDMASK(MP,/STRUCT)
  ROWCOUNT = LONARR(PY)
  FOR N=0, PY-1 DO ROWCOUNT[N] = N_ELEMENTS(WHERE(LAND[*,N] NE LSTR.OUT_OF_AREA_CODE))
  IF TOTAL(ROWCOUNT) NE PX*PY-LSTR.COUNT_OUT_OF_AREA THEN MESSAGE, 'ERROR: The total number of bins should equal the total number of "ocean" pixels'
  
  BLK = MAPS_BLANK(MP,FILL=0)
  SUBS = WHERE(LAND NE LSTR.OUT_OF_AREA_CODE,COUNT,COMPLEMENT=COMPLEMENT)
  BLK[SUBS] = LINDGEN(COUNT)+1
  BLK = ROTATE(BLK, 7)
  IMGR, BLK, DELAY=2
  
  PRINT, 'The number of rows for ' + MP + ' is ' + NUM2STR(PY)
  PRINT, 'The number of total bins for ' + MP + ' is ' + ROUNDS(TOTAL(ROWCOUNT)) + ' - UPDATE MAPS_MAIN.csv...'

  stop

  L3B = MAPS_L3B_2LONLAT(REPLACE(MP,'GS','L3B'), /OVERWRITE)
  
  
  stop


END ; ***************** End of MAPS_GS_2L3B *****************
