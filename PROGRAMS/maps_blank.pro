; $ID:	MAPS_BLANK.PRO,	2019-12-02-10,	USER-KJWH	$
; #########################################################################; 
FUNCTION MAPS_BLANK, AMAP, PX=PX, PY=PY, FILL=FILL, DOUBLE=DOUBLE
;+
; PURPOSE:  THIS SIMPLE FUNCTION RETURNS A BLANK [MISSINGS] ARRAY FOR ANY VALID MAP
;
; CATEGORY: MAPS FAMILY
;
; INPUTS: 
;   AMAP: Map name 'L3B1','L3B2','NEC',OR 'NWA'
;
; OPTIONAL INPUTS
;   PX: X pixel dimensions (default derived from MAPS_SIZE)
;   PY: Y pixel dimenisons (defualt derived from MAPS_SIZE)
;
; KEYWORDS: 
;   FILL...... Value to fill in the blank array with (OPTIONAL)
;   DOUBLE.... To outout the blank array as a double flointing point array
;
; OUTPUTS: AN L3B ARRAY WITH ALL ELEMENTS SET TO INFINITY
;
; EXAMPLES:
;            HELP,MAPS_BLANK('L3B9')
;            HELP,MAPS_BLANK('L3B4')
;            HELP,MAPS_BLANK('NEC')
;            HELP,MAPS_BLANK('NWA')
;            HELP,MAPS_BLANK('GL8')
;            HELP,MAPS_BLANK('NEC',FILL=1.0) & PMM,MAPS_BLANK('NEC',FILL=1.0)
;
; MODIFICATION HISTORY:
;     FEB 10, 2017  WRITTEN BY: J.E. O'REILLY
;     FEB 21, 2017 - KJWH: Changed MAP_SIZE to MAPS_SIZE
;     APR 26, 2017 - KJWH: Added FILL keyword to fill in the blank array with a specified value
;     MAY 16, 2019 - KJWH: Added the DOUBLE keyword to make the blank array double floint point
;     DEC 02, 2019 - KJWH: Added PX and PY optional inputs to change the default size of the blank array
;-
; #########################################################################

; **********************
  ROUTINE = 'MAPS_BLANK'
; **********************

  M = MAPS_SIZE(AMAP) 
  IF NONE(PX) THEN PX = M.PX 
  IF NONE(PY) THEN PY = M.PY
  IF NONE(FILL) THEN FILL = MISSINGS(0.0)
  IF KEY(DOUBLE) THEN FILL = DOUBLE(FILL)
  IF N_ELEMENTS(FILL) NE 1 THEN MESSAGE, 'ERROR: FILL value must be a single element'
  RETURN,REPLICATE(FILL,PX,PY)

END; #####################  END OF ROUTINE ################################
