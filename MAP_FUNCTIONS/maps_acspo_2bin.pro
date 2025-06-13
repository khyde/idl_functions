; $ID:	MAPS_ACSPO_2BIN.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION MAPS_ACSPO_2BIN, ACSPO, MAP_OUT, MAP_SUBSET=MAP_SUBSET, BINS_OUT=BINS_OUT, INIT=INIT

;+
; NAME:
;   MAPS_ACSPO_2BIN
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   MAP_FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = MAPS_ACSPO_2BIN($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
;   This program was written on June 02, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jun 02, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAPS_ACSPO_2BIN'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  COMMON MAPS_ACSPO_2BIN_, BINS9, BINS4, BINS2, BINS1
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS9) THEN BINS9 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS4) THEN BINS4 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS2) THEN BINS2 = []
  IF KEYWORD_SET(INIT) OR ~N_ELEMENTS(BINS1) THEN BINS1 = []

  SZ = SIZEXYZ(ACSPO)
  IF SZ.PX NE 18000 OR SZ.PY NE 9000 THEN RETURN, 'ERROR: INPUT ARRAY DEMINSIONS MUST BE 18000 X 9000'
  IF ~N_ELEMENTS(MAP_OUT) THEN RETURN, 'ERROR: MAP_OUT MUST BE EITHER L3B4 OR L3B9'

  FILE  = !S.MAPINFO + 'ACSPO-PXY_18000_9000-2'+MAP_OUT+'.SAV'
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
    IF R[N+1]-R[N] GE 1 THEN L3B[N] = MEAN(ACSPO[R[R[N]:R[N+1]-1]],/NAN)
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


END ; ***************** End of MAPS_ACSPO_2BIN *****************
