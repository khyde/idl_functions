; $ID:	MAPS_AVHRR_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
;##########################################################################
FUNCTION MAPS_AVHRR_2BIN, AVHRR, MAP_OUT, BINS_OUT=BINS_OUT, INIT=INIT

; PURPOSE:
;   This program converts a 8640 x 4320 AVHRR array to a L3B array
;
; CATEGORY:
;    MAPPING
;    
; UTILITY:
;    REMAPPING
;    
; CALLING SEQUENCE:
;    L3B = MAPS_AVHRR_2BIN(AVHRR, 'L3B9') 
;    L3B = MAPS_AVHRR_2BIN(AVHRR, 'L3B4') 
;    
; REQUIRED INPUTS:
;   AVHRR....... A 8640 X 4320 AVHRR data array
;   MAP_OUT..... The name of the output L3B map
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;   INIT...... Reinitialize the COMMON block
;   
; OUTPUTS:
;   The AVHRR data array converted to the L3B map
;
; OPTIONAL OUTPUTS:
;   BINS_OUT........ The bin numbers for the output array (needed if subsetting the full array)
;
; 
; COMMON BLOCKS:
;   MAPS_AVHRR_2BIN_, BINS9, BINS4, BINS2, BINS1 
; 
; EXAMPLES:
; 
; NOTES:
;  The AVHRR_8640_4320_2L3B9(4).SAV files were created using MAPS_L3B_SUBS
;  
; COPYRIGHT:
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 29, 2015 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;   OCT 29, 2015 - KJWH: Initial code written
;   OCT 30, 2015 - KJWH: Added COMMON block and REFRESH keyword
;   OCT 30, 2015 - JEOR: Changed COMMON name to MAPS_AVHRR_2BIN_ to conform to our convention of knowing the program name that the COMMON variables are associated with
;                        Changed keyword REFRESH to INIT to conform to keywords in SWITCHES
;   MAR 14, 2016 - KJWH: Changed IF blocks to CASE    
;   JUN 23, 2016 - KJWH: Added L3B1 map cases             
;   AUG 19, 2016 - KJWH: Changed !S.MASTER to !S.MAPINFO
;   AUG 23, 2016 - KJWH: Updated the AVHRR file name
;   JAN 31, 2017 - KJWH: Added L3B2 map cases
;   AUG 04, 2021 - KJWH: Updated documenation and formatting
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Moved to MAP_FUNCTIONS
;   DEC 05, 2022 - KJWH: Added BINS_OUT as an optional output for the L3Bx bins                     
;- 
  
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_AVHRR_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
    
  COMMON MAPS_AVHRR_2BIN_, BINS9, BINS4, BINS2, BINS1 
  IF KEY(INIT) OR NONE(BINS9) THEN BINS9 = []
  IF KEY(INIT) OR NONE(BINS4) THEN BINS4 = []
  IF KEY(INIT) OR NONE(BINS2) THEN BINS2 = []
  IF KEY(INIT) OR NONE(BINS1) THEN BINS1 = []
  
  SZ = SIZEXYZ(AVHRR)
  IF SZ.PX NE 8640 AND SZ.PY NE 4320 THEN RETURN, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE 8640 X 4320'
  IF NONE(MAP_OUT) THEN RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B4 OR L3B9'
  
  FILE  = !S.MAPINFO + 'AVHRR-PXY_8640_4320-2'+MAP_OUT+'.SAV'
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY
  
  CASE STRUPCASE(MAP_OUT) OF
    'L3B9': BINS = BINS9
    'L3B4': BINS = BINS4
    'L3B2': BINS = BINS2
    'L3B1': BINS = BINS4
    ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B2, L3B4 OR L3B9'  
  ENDCASE
  
  L3B = FLTARR(NBINS) & L3B[*] = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF EXISTS(FILE) EQ 0 THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF NONE(BINS) THEN BINS = IDL_RESTORE(FILE)   
  IF NONE(BINS9) AND MAP_OUT EQ 'L3B9' THEN BINS9 = BINS ; Save BINS9 in common for subsequent calls
  IF NONE(BINS4) AND MAP_OUT EQ 'L3B4' THEN BINS4 = BINS ; Save BINS4 in common for subsequent calls
  IF NONE(BINS2) AND MAP_OUT EQ 'L3B2' THEN BINS2 = BINS ; Save BINS2 in common for subsequent calls
  IF NONE(BINS1) AND MAP_OUT EQ 'L3B1' THEN BINS1 = BINS ; Save BINS1 in common for subsequent calls
    
  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF R[N+1]-R[N] GE 1 THEN L3B[N] = MEAN(AVHRR[R[R[N]:R[N+1]-1]],/NAN)
  ENDFOR
  
  BINS_OUT = MAPS_L3B_BINS(MAP_OUT)
    
  L3B[WHERE(FINITE(L3B) EQ 0)] = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B[0:*] = L3B
  GONE, L3B
  RETURN, _L3B
  
END
