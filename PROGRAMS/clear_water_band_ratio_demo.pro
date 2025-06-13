; $ID:	CLEAR_WATER_BAND_RATIO_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

PRO CLEAR_WATER_BAND_RATIO_DEMO, QUIET=quiet
;+
; NAME:
;       CLEAR_WATER_BAND_RATIO_DEMO
;
; PURPOSE:
;       Calculate clear water Reflectance Ratio for 2 wavelengths
;       by calling CLEAR_WATER.PRO
;
; CATEGORY:
;       RADIANCE
;
; CALLING SEQUENCE:
;        CLEAR_WATER_BAND_RATIO_DEMO
;
; INPUTS:
;      None Required
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       Clear Water Reflectance Ratios for two bands
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Program assumes that input wavelengths for wl_pair are in
;               units of NANOMETERS.
;
; PROCEDURE:
;       Calls CLEAR_WATER.PRO
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 9, 1999
;-

 	ROUTINE_NAME='CLEAR_WATER_BAND_RATIO_DEMO'

; =================>
; Get all SeaWiFS Band Pairs
  BANDS = [SEAWIFS_BANDS(),531,550,560,565,570]
  S=SORT(BANDS)
  BANDS=BANDS(S)
  sets=PAIRS(BANDS)


  PRINT, 'Pair, Clear Water Rrs Band Ratio'
  PRINT, 'Pair,    bb/(bb+a),    bb/a'
  FMT='(2F10.4)'

;	===> Make a structure to hold results
	struct=REPLICATE(CREATE_STRUCT('PAIR','','bb_bb_a',0.0,'bb_a',0.0),N_ELEMENTS(SETS(0,*)))


  FOR NTH = 0, N_ELEMENTS(SETS(0,*))-1L DO BEGIN
    wl_pair = SETS(*,nth)


;   ====================>
;   Get clear water BAND RATIO value (Pope & Fry 1997)
    cwbb_abb = clear_water_band_ratio(wl_pair,/QUIET)
    cwb_a = clear_water_band_ratio(wl_pair,/QUIET, /B_OVER_A)
    txt_pair =  NUM2STR(WL_PAIR[0])+':'+NUM2STR(WL_PAIR[1])
    PRINT, txt_pair+'   '+ NUM2STR(cwbb_abb,FORMAT=FMT)+'   '+ NUM2STR(cwb_a,FORMAT=FMT) ; CLEAR WATER REFLECTANCE RATIO
    struct(nth).PAIR 		= txt_pair
    struct(nth).bb_bb_a = cwbb_abb
    struct(nth).bb_a 		= cwb_a

  ENDFOR
  STRUCT_2CSV,ROUTINE_NAME+'.CSV',STRUCT

  END; OF PROGRAM
