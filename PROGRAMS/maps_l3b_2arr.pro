; $ID:	MAPS_L3B_2ARR.PRO,	2020-06-30-17,	USER-KJWH	$
; 
FUNCTION MAPS_L3B_2ARR, ARRAY, MP=MP, BINS=BINS
; #########################################################################; 
;+
; This program converts an incomplete L3B array into a complete L3B array
;
; CATEGORY: 
; 
; UTILITY;
;
; CALLING SEQUENCE: 
;   
;
; INPUTS: 
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
;   FEB 23, 2017  WRITTEN BY: by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;   SEP 07, 2017 - KJWH: Changed MAPP to MP 
;                        Replaced 
;                          L3BS = ['L3B9','L3B4','L3B2','L3B1']
;                          IF WHERE_IN(STRUPCASE(MAPP),L3BS) EQ [] THEN RETURN, ARRAY 
;                        With
;                          IF ~IS_L3B(MP) THEN RETURN ARRAY      
;                        Now subtracting 1 from the BINS to properly line up with the subscripts
;                          ARR(0,BINS-1) = ARRAY   
;   JUN 30, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed ARR(0,BINS-1) to ARR[0,BINS-1]
;                        Removed SL = PATH_SEP() 
;-

  ROUTINE_NAME  = 'MAPS_L3B_2ARR'
  COMPILE_OPT IDL2
  
  IF ~IS_L3B(MP) THEN RETURN, ARRAY  ; ===> Input map is not an L3B so return the original array
    
  MS = MAPS_SIZE(MP,PX=PX,PY=PY)
  SZ = SIZEXYZ(ARRAY,PX=APX,PY=APY)
  IF APY EQ PY THEN RETURN, ARRAY    ; ===> Array is alreay a full array for the L3Bx map
  
  IF N_ELEMENTS(BINS) NE N_ELEMENTS(ARRAY) THEN MESSAGE, 'ERROR: The number of BINS must equal the number of values in the ARRAY.'
  
  ARR = MAPS_BLANK(MP)
  ARR[0,BINS-1] = ARRAY             ; ===> Must subtract 1 from the BIN numbers because BINS start with 1, not 0
    
  RETURN, ARR
  
END; #####################  END OF ROUTINE ################################
