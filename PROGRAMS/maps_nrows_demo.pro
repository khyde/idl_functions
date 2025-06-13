; $ID:	MAPS_NROWS_DEMO.PRO,	2020-06-03-17,	USER-KJWH	$
; #########################################################################; 
PRO MAPS_NROWS_DEMO
;+
; PURPOSE:  COMPARE NROWS IN OUR L3B SERIES WITH PY IN OUR GL SERIES
;
; CATEGORY: MAPS_ FAMILY
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE

; OUTPUTS:  A CSV
;
;; EXAMPLES:
;
; MODIFICATION HISTORY:
;     FEB 22, 2017  WRITTEN BY: J.E. O'REILLY
;     FEB 24,2017 JOR GL8 CHANGED TO GL9
;-
; #########################################################################

;**************************
ROUTINE = 'MAPS_NROWS_DEMO'
;**************************
DIR_OUT = !S.IDL_TEMP

L3BMAPS = ['L3B1','L3B2','L3B4','L3B9']
FOR N = 0,NOF(L3BMAPS)-1 DO BEGIN
  L3BMAP = L3BMAPS(N)
  MAPP = MAPS_MAPP_VS_L3BMAP(L3BMAP)
  PY = (MAPS_READ(MAPP)).PY
  NROWS = MAPS_L3B_NROWS(L3BMAP)
  MAPS_SCALE,MAPP,KMP_X=KMP_X,KMP_Y=KMP_Y
  D = CREATE_STRUCT('L3BMAP',L3BMAP,'MAPP',MAPP,'PY',PY,'NROWS',NROWS,'KMP_X',KMP_X,'KMP_Y',KMP_Y)
  IF NONE(DB) THEN DB = D ELSE DB = [DB,D]
ENDFOR;FOR N = 0,NOF(L3BMAPS)-1 DO BEGIN
 CSV = DIR_OUT + ROUTINE + '.CSV'
 CSV_WRITE,CSV,DB

END; #####################  END OF ROUTINE ################################
