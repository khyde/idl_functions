; $ID:	MAPS_MUR_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
;##########################################################################
FUNCTION MAPS_MUR_2BIN, MUR, MAP_OUT, MAP_SUBSET=MAP_SUBSET, BINS_OUT=BINS_OUT, INIT=INIT


;+
; NAME:
;   MAPS_MUR_2BIN
; 
; PURPOSE: 
;   This function converts a 36000 X 17999 MUR array to a L3B array
;
; CATEGORY:
;   MAPS_FUNCTIONS
;    
; CALLING SEQUENCE:
;    L3B = MAPS_MUR_2BIN(MUR_IMAGE, 'L3B9') 
;    
; REQUIRED INPUTS:
;   MUR ........... A 8640 X 4320 MUR data array
;   MAP_OUT........ A valid L3B map
;
; OPTIONAL INPUTS:
;   MAP_SUBSET..... A valid map to subset the full array
;
; KEYWORD PARAMETERSS:
;   INIT........... To reinitialize the COMMON structure
;
; OUTPUTS:
;   The MUR data array converted to the L3B map
; 
; OPTIONAL OUTPUTS:
;   BINS_OUT........ The bin numbers for the output array (needed if subsetting the full array)
;
; COMMON BLOCKS:
;   MAPS_MUR_2BIN_ - to store the map specific information
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;
; EXAMPLES
; 
; NOTES:
;   Information on NASA's integerized sinusoidal binning scheme - https://oceancolor.gsfc.nasa.gov/docs/format/l3bins/
;
; COPYRIGHT:
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 29, 2015 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;   OCT 29, 2015 - KJWH: Initial code written
;   OCT 30, 2015 - KJWH: Added COMMON block and INIT keyword
;   MAR 14, 2016 - KJWH: Changed IF blocks to CASE
;   APR 05, 2016 - KJWH: Corrected the dimensions in the ERROR statement checking the array dimensions
;   JUN 22, 2016 - KJWH: Added steps to create L3B1 maps
;   JUN 28, 2016 - KJWH: Added BINS1 to COMMON
;   AUG 19, 2016 - KJWH: Changed !S.MASTER to !S.MAPINFO
;   AUG 23, 2016 - KJWH: Updated the MUR file name
;   SEP 14, 2016 - KJWH: Fixed a bug with BINS
;   JAN 06, 2017 - KJWH: Added BINS2 to COMMON
;   MAY 12, 2022 - KJWH: Now subsetting the array and returning the bin numbers if a SUBSET_MAP is provided
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Updated documentation
;   DEC 05, 2022 - KJWH: Changed KEY() to KEYWORD_SET()
;                        Change NONE() to ~N_ELEMENTS()
;                        Now returning the default L3Bx bins in BINS_OUT if the MAP_SUBSET is not set
;- 
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_MUR_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
   
  
  COMMON MAPS_MUR_2BIN_, BINS9, BINS4, BINS2, BINS1
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS9) THEN BINS9 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS4) THEN BINS4 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS2) THEN BINS2 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS1) THEN BINS1 = []
  
  SZ = SIZEXYZ(MUR)
  IF SZ.PX NE 36000 AND SZ.PY NE 17999 THEN RETURN, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE 36000 X 17999'
  IF ~N_ELEMENTS(MAP_OUT) THEN RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B4 OR L3B9'
  
  FILE  = !S.MAPINFO + 'MUR-PXY_36000_17999-2'+MAP_OUT+'.SAV'
  MS = MAPS_SIZE(MAP_OUT)
  NBINS = MS.PY

  CASE STRUPCASE(MAP_OUT) OF
    'L3B9': BINS  = BINS9
    'L3B4': BINS  = BINS4
    'L3B2': BINS  = BINS2
    'L3B1': BINS  = BINS1
    ELSE: RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B1, L3B4 OR L3B9'
  ENDCASE
  
  L3B = FLTARR(NBINS) & L3B[*] = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF EXISTS(FILE) EQ 0 THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF ~N_ELEMENTS(BINS) THEN BINS = IDL_RESTORE(FILE)
  IF ~N_ELEMENTS(BINS9) AND MAP_OUT EQ 'L3B9' THEN BINS9 = BINS ; Save BINS9 in common for subsequent calls
  IF ~N_ELEMENTS(BINS4) AND MAP_OUT EQ 'L3B4' THEN BINS4 = BINS ; Save BINS4 in common for subsequent calls
  IF ~N_ELEMENTS(BINS2) AND MAP_OUT EQ 'L3B2' THEN BINS2 = BINS ; Save BINS2 in common for subsequent calls
  IF ~N_ELEMENTS(BINS1) AND MAP_OUT EQ 'L3B1' THEN BINS1 = BINS ; Save BINS1 in common for subsequent calls
    
  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF R[N+1]-R[N] GE 1 THEN L3B[N] = MEAN(MUR[R[R[N]:R[N+1]-1]],/NAN)
  ENDFOR
    
  L3B[WHERE(FINITE(L3B) EQ 0)] = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B[0:*] = L3B
  GONE, L3B
  
  BINS_OUT = MAPS_L3B_BINS(MAP_OUT)
  IF KEYWORD_SET(MAP_SUBSET) THEN BEGIN
    IF VALIDS('MAPS',MAP_SUBSET) EQ '' THEN MESSAGE, 'ERROR: ' + MAP_SUBSET + ' is not a "VALID" map.'
    L3BSUB = MAPS_L3B_SUBSET(_L3B, INPUT_MAP=MAP_OUT, SUBSET_MAP=MAP_SUBSET, SUBSET_BINS=BINS_OUT)
    _L3B = L3BSUB
  ENDIF
  
  RETURN, _L3B
  
END
