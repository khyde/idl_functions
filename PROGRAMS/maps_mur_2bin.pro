; $ID:	MAPS_MUR_2BIN.PRO,	2017-01-06,	USER-KJWH	$
;##########################################################################
FUNCTION MAPS_MUR_2BIN, MUR, MAP_OUT, INIT=INIT

; THIS PROGRAM CONVERTS A 36000 X 17999 MUR ARRAY TO EITHER A L3B9 OR L3B4 ARRAY
;
; CATEGORY:
;    MAPPING
;    
; UTILITY:
;    REMAPPING
;    
; CALLING SEQUENCE:
;    L3B = MAPS_MUR_2BIN(MUR_IMAGE, 'L3B9') 
;    L3B = MAPS_MUR_2BIN(MUR_IMAGE, 'L3B4') 
;    
; INPUTS:
;   MUR   = A 8640 X 4320 MUR DATA ARRAY
;   MAP_OUT = EITHER 'L3B9' OR 'L3B4'
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; OUTPUTS:
;
; EXAMPLES:
;
; MODIFICATION HISTORY:
;     OCT 29, 2015  WRITTEN BY: by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     OCT 30, 2015 - KJWH: Added COMMON block and INIT keyword
;     MAR 14, 2016 - KJWH: Changed IF blocks to CASE
;     APR 05, 2016 - KJWH: Corrected the dimensions in the ERROR statement checking the array dimensions
;     JUN 22, 2016 - KJWH: Added steps to create L3B1 maps
;     JUN 28, 2016 - KJWH: Added BINS1 to COMMON
;     AUG 19, 2016 - KJWH: Changed !S.MASTER to !S.MAPINFO
;     AUG 23, 2016 - KJWH: Updated the MUR file name
;     SEP 14, 2016 - KJWH: Fixed a bug with BINS
;     JAN 06, 2017 - KJWH: Added BINS2 to COMMON
;- 
  
;*********************************  
  ROUTINE_NAME = 'MAPS_MUR_2BIN'
;*********************************  
  
  COMMON MAPS_MUR_2BIN_, BINS9, BINS4, BINS2, BINS1
  IF KEY(INIT) OR NONE(BINS9) THEN BINS9 = []
  IF KEY(INIT) OR NONE(BINS4) THEN BINS4 = []
  IF KEY(INIT) OR NONE(BINS2) THEN BINS2 = []
  IF KEY(INIT) OR NONE(BINS1) THEN BINS1 = []
  
  SZ = SIZEXYZ(MUR)
  IF SZ.PX NE 36000 AND SZ.PY NE 17999 THEN RETURN, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE 36000 X 17999'
  IF NONE(MAP_OUT) THEN RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B4 OR L3B9'
  
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
  
  L3B = FLTARR(NBINS) & L3B(*) = MISSINGS(0.0)  ; CREATE BLANK ARRAY
  IF EXISTS(FILE) EQ 0 THEN MESSAGE, 'ERROR: Missing ' + FILE
  IF NONE(BINS) THEN BINS = IDL_RESTORE(FILE)
  IF NONE(BINS9) AND MAP_OUT EQ 'L3B9' THEN BINS9 = BINS ; Save BINS9 in common for subsequent calls
  IF NONE(BINS4) AND MAP_OUT EQ 'L3B4' THEN BINS4 = BINS ; Save BINS4 in common for subsequent calls
  IF NONE(BINS2) AND MAP_OUT EQ 'L3B2' THEN BINS2 = BINS ; Save BINS2 in common for subsequent calls
  IF NONE(BINS1) AND MAP_OUT EQ 'L3B1' THEN BINS1 = BINS ; Save BINS1 in common for subsequent calls
    
  H = HISTOGRAM(BINS, MIN=0, REVERSE_INDICES=R)
  FOR N=0, N_ELEMENTS(L3B)-1 DO BEGIN
    IF R[N+1]-R[N] GE 1 THEN L3B(N) = MEAN(MUR(R[R[N]:R[N+1]-1]),/NAN)
  ENDFOR
    
  L3B(WHERE(FINITE(L3B) EQ 0)) = MISSINGS(0.0) ; Change all non-finite values to INF
  _L3B = FLTARR(1, NBINS)
  _L3B(0:*) = L3B
  GONE, L3B
  RETURN, _L3B
  
END
