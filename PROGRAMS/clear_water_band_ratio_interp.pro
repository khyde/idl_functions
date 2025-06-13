; $ID:	CLEAR_WATER_BAND_RATIO_INTERP.PRO,	2020-07-08-15,	USER-KJWH	$

PRO CLEAR_WATER_BAND_RATIO_interp, WL_PAIR, OC_VALUE,QUIET=quiet
;+
; NAME:
;       CLEAR_WATER_BAND_RATIO_interp
;
; PURPOSE:
;       Calculate clear water Reflectance Ratio for 2 wavelengths
;       by calling CLEAR_WATER.PRO
;
; CATEGORY:
;       RADIANCE
;
; CALLING SEQUENCE:
;
;        CLEAR_WATER_BAND_RATIO_INTERP, [443.0,555], 18.21
; INPUTS:
;      None Required
;
; KEYWORD PARAMETERS:
;       B_OVER_A:  Computes Bb/A  (instead of default = Bb/(Bb+A)
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

; =================>
; Get all SeaWiFS Band Pairs


  PRINT, 'Pair,       Clear Water Rrs Band Ratio'
  PRINT, 'Pair,                     bb/(bb+a),    b/a,       OC VALUE   FRACT'
  FMT='(2F10.4)'
  IF N_ELEMENTS(WL_PAIR) NE 2 THEN STOP
  IF N_ELEMENTS(OC_VALUE) NE 1 THEN STOP

;   ====================>
;   Get clear water BAND RATIO value (Pope & Fry 1997)
    cwbb_abb = clear_water_band_ratio(wl_pair,/QUIET)
    cwb_a = clear_water_band_ratio(wl_pair,/QUIET, /B_OVER_A)
    II = INTERPOL([0.0,1.0],[(cwbb_abb), (cwb_a)],(oc_value))
   ; II = INTERPOL([0.0,1.0],[ALOG10(cwbb_abb), ALOG10(cwb_a)],ALOG10(oc_value))
    PRINT, NUM2STR(WL_PAIR[0])+':'+NUM2STR(WL_PAIR[1])+'   '$
                                  + NUM2STR(cwbb_abb,FORMAT=FMT)+'   '$
                                  + NUM2STR(cwb_a,FORMAT=FMT)+'    '$ ; CLEAR WATER REFLECTANCE RATIO
                                  + NUM2STR(OC_VALUE,FORMAT=FMT)+'   '$
                                  + NUM2STR(II,FORMAT=FMT)



  END; OF PROGRAM
