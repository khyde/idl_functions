; $ID:	MAPS_L3B_OR_MAP.PRO,	2017-11-29-15,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_L3B_OR_MAP, AMAP
;+
; PURPOSE:  RETURN EITHER A GLOBAL MAPP OR A L3BMAP EQUIVALENT DEPENDING ON THE INPUT
;
; CATEGORY: MAPS_ FAMILY
;
;
; INPUTS: AMAP.......... ANY VALID GLOBAL MAPP NAME [E.G.GL1,GL2,GL4 OR GL8]
;                        OR A VALID L3B MAP NAME [E.G. L3B1,L3B2,L3B4OR L3B9]
;
;
; KEYWORDS:  NONE
;
; OUTPUTS: 
;
;; EXAMPLES:
;            PRINT,MAPS_L3B_OR_MAP('L3B9')
;            PRINT,MAPS_L3B_OR_MAP('L3B4')
;            PRINT,MAPS_L3B_OR_MAP('L3B2')
;            PRINT,MAPS_L3B_OR_MAP('L3B1')
;            
;            PRINT,MAPS_L3B_OR_MAP('GL8')
;            PRINT,MAPS_L3B_OR_MAP('GL4')
;            PRINT,MAPS_L3B_OR_MAP('GL2')
;            PRINT,MAPS_L3B_OR_MAP('GL1')
;            
;            PRIMAPS_L3B_OR_MAPMAP('GL3')
;
; MODIFICATION HISTORY:
;     FEB 20, 2017  WRITTEN BY: J.E. O'REILLY
;     FEB 22, 2017 - KJWH: Changed the program name from MAPS_MAPP_VS_L3BMAP to MAPS_MAP_OR_L3BMAP
;     FEB 23, 2017 - KJWH: Changed the error to return the original input amap if a match was not found.  
;     FEB 24, 2107 - JEOR: Changed GL8 to GL9
;     FEB 24, 2017 - KJWH: Changed the name to MAPS_L3B_OR_MAP to be consistent with the MAPS_L3B family
;     AUG 23, 2017 - KJWH: Change the GLX maps to GSX 
;     OCT 27, 2023: KJWH: Added L3B10 and L3B25 maps
;-
; #########################################################################

;******************************
  ROUTINE = 'MAPS_L3B_OR_MAP'
;******************************

;CCCCCCCCCCCCCCCC
  CASE (AMAP) OF
    'L3B1': RETURN, 'GS1'
    'L3B2': RETURN, 'GS2'
    'L3B4': RETURN, 'GS4'
    'L3B9': RETURN, 'GS9'
    'L3B10': RETURN, 'GS10'
    'L3B25': RETURN, 'GS25'
    
    'GS1': RETURN, 'L3B1'
    'GS2': RETURN, 'L3B2'
    'GS4': RETURN, 'L3B4'
    'GS9': RETURN, 'L3B9'
    'GS10': RETURN, 'L3B10'
    'GS25': RETURN, 'L3B25'
  
    ELSE: RETURN, AMAP 
  ENDCASE;CASE (AMAP) OF
;CCCCCCCCCCCCCCCCCCCCCCCC




END; #####################  END OF ROUTINE ################################
