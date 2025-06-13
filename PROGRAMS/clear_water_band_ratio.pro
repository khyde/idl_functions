; $ID:	CLEAR_WATER_BAND_RATIO.PRO,	2020-07-08-15,	USER-KJWH	$

function CLEAR_WATER_BAND_RATIO,  WL_PAIR,   B_OVER_A=b_over_a,QUIET=quiet
;+
; NAME:
;       CLEAR_WATER_BAND_RATIO
;
; PURPOSE:
;       Calculate clear water Reflectance Ratio for 2 wavelengths
;       by calling CLEAR_WATER.PRO
;
; CATEGORY:
;       RADIANCE
;
; CALLING SEQUENCE:
;       Result = CLEAR_WATER_BAND_RATIO(a)
;
; INPUTS:
;      WL_PAIR:  A pair of wavelengths for which Clear Water Reflecance Ratios
;                are computed. (First element is always in NUMERATOR of final
;                Clear Water Reflectance Ratio)
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

  IF N_ELEMENTS(WL_PAIR) NE 2 THEN BEGIN
    PRINT, 'ERROR: Must supply 2 wavelengths (nanometers)
  ENDIF

; ====================>
; Get clear water values (Pope & Fry 1997)
  cw = clear_water(wl_pair,QUIET=quiet)

  IF N_ELEMENTS(cw) EQ 2 THEN BEGIN
    CW_RATIO = FLTARR(2)
    IF NOT KEYWORD_SET(B_OVER_A) THEN BEGIN
      CW_RATIO[0] = CW[0].BBW/(CW[0].BBW+CW[0].AW_PF97)
      CW_RATIO[1] = CW[1].BBW/(CW[1].BBW+CW[1].AW_PF97)
    ENDIF ELSE BEGIN
      CW_RATIO[0] = CW[0].BBW/(          CW[0].AW_PF97)
      CW_RATIO[1] = CW[1].BBW/(          CW[1].AW_PF97)
    ENDELSE

    RETURN, CW_RATIO[0]/CW_RATIO[1] ; CLEAR WATER REFLECTANCE RATIO

  ENDIF ELSE RETURN, -1

  END; OF PROGRAM
