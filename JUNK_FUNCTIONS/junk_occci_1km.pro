; $ID:	JUNK_OCCCI_1KM.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO JUNK_OCCCI_1KM

;+
; NAME:
;   JUNK_OCCCI_1KM
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   JUNK_FUNCTIONS
;
; CALLING SEQUENCE:
;   JUNK_OCCCI_1KM,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
;   This program was written on November 15, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 15, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'JUNK_OCCCI_1KM'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  PX = 34560 & PY = 17280 
  PXY = 'PXY_'+NUM2STR(PX)+'_'+NUM2STR(PY)
  LATFILE = !S.MAPINFO + 'OCCCI-1KM-'+PXY+'-LAT.SAV'
  LONFILE = !S.MAPINFO + 'OCCCI-1KM-'+PXY+'-LON.SAV'
  
 
  
  
;  PX = 100 & PY = 100
;  LAT = FINDGEN(PX, INCREMENT=0.10, START=40.0)
;  LON = FINDGEN(PY, INCREMENT=0.10, START=-80.0)
;  
;  LATS = FLTARR(N_ELEMENTS(LON),N_ELEMENTS(LAT)) & LATS[*] = MISSINGS(LATS) & LONS = LATS ; CREATE BLANK ARRAYS FOR THE LON AND LAT DATA
;  FOR L=0, N_ELEMENTS(LAT)-1 DO LONS[*,L] = TRANSPOSE(LON) ; FILL IN THE LON GRID FROM A SINGLE ARRAY
;  FOR L=0, N_ELEMENTS(LON)-1 DO LATS[L,*] = LAT            ; FILL IN THE LAT GRID FROM A SINGLE ARRAY
;
;  SLAT = LAT[40:60]
;  SLON = LON[40:60] 
;  
;  OKLON = WHERE_MATCH(LONS[*,0],SLON,COMPLEMENT=CLONS)
;  OKLAT = WHERE_MATCH(LATS[0,*],SLAT,COMPLEMENT=CLATS)
;
;  LL = BYTARR(PX,PY) & ARR = FLTARR(PX,PY)
;  LL[*,OKLON] = 1
;  LL[OKLAT,*] = LL[OKLAT,*]+1
  
    
  
  FLAT = IDL_RESTORE(LATFILE)
  FLON = IDL_RESTORE(LONFILE)
    
  FILE = !S.IDL_DEMO_FILES + 'CCI_ALL-v5.0-1km-DAILY.nc';D*OCCCI-1KM*.nc')
  
;  D = READ_NC(FILE)
;  LATS = REVERSE(D.SD.LAT.IMAGE) & PY = N_ELEMENTS(LATS)
;  LONS = REVERSE(D.SD.LON.IMAGE) & PX = N_ELEMENTS(LONS)
;  IMG = ROTATE(D.SD.CHLOR_A.IMAGE,7)
;  
;  LATS = D.SD.LAT.IMAGE & PY = N_ELEMENTS(LATS)
;  LONS = D.SD.LON.IMAGE & PX = N_ELEMENTS(LONS)
;  IMG = D.SD.CHLOR_A.IMAGE
;  
;  DIMG = MAPS_OCCCI1KM_2BIN(IMG,'L3B9', LATS=LATS, LONS=LONS)
;  
;  
; ; LIMG = MAPS_OCCCI1KM_2BIN(IMG, 'L3B2', LATS=LATS, LONS=LONS)
;  DM = maps_remap(Dimg, map_in='L3B9', map_out='NES')
;  GM = maps_remap(Dimg, map_in='L3B9', map_out='GEQ')

  DIR = !S.OC + 'OCCCI/VERSION_5.0/1KM/NC/CHLOR_A-CCI/'
  SFILE = !S.IDL_DEMO_FILES + 'CCI_ALL-v5.0-1km-DAILY_subset.nc'; FILE_SEARCH(DIR + 'M_202104*.nc')
  
  S = READ_NC(SFILE)
  SLATS = S.SD.LAT.IMAGE & SPY = N_ELEMENTS(SLATS)
  SLONS = S.SD.LON.IMAGE & SPX = N_ELEMENTS(SLONS)

  SIMG = S.SD.CHLOR_A.IMAGE[*,*]
  
  OK = WHERE(FLAT GE MIN(SLATS) AND FLAT LE MAX(SLATS) AND FLON GE MIN(SLONS) AND FLON LE MAX(SLATS),COUNT)
  
  LIMG = MAPS_OCCCI1KM_2BIN(SIMG, 'L3B9',LATS=SLATS, LONS=SLONS)
  LM = maps_remap(limg, map_in='L3B9', map_out='NES')
  GM = maps_remap(limg, map_in='L3B9', map_out='GEQ')
  
 ; OK = WHERE(DIMG NE MISSINGS(0.0) AND LIMG NE MISSINGS(0.0),COUNT)
 ; DIF = LIMG[OK]-DIMG[OK]
 ; PMM, DIF
  
stop
  
  OKLON = WHERE_MATCH(FLOAT(FLON[*,0]),FLOAT(SLONS),COMPLEMENT=CLONS)
  OKLAT = WHERE_MATCH(FLOAT(FLAT[0,*]),FLOAT(SLATS),COMPLEMENT=CLATS)
 
  LL = BYTARR(PX,PY) & ARR = FLTARR(PX,PY)
  LL[OKLON,*] = 1
  LL[*,OKLAT] = LL[*,OKLAT]+1
  
  SUBS = WHERE(LL EQ 2)
  ARR[SUBS] = IMG[SUBS] 
  
  ;OCCCI_1KM_2SAVE, FILES[0], DIR_OUT=DIR_OUT
  
  stop


END ; ***************** End of JUNK_OCCCI_1KM *****************
