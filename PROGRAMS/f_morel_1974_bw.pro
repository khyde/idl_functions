; $Id: F_MOREL_1974_BW.pro $
;+
;	This Function Returns the Backscattering Coefficient (bw) for pure sea water
; after Morel 1974
; SYNTAX:
;		Result = F_MOREL_1974_BW(wl)
;
; OUTPUT:
; ARGUMENTS:
; 	Wl:  wavelength in namometers
;
; KEYWORDS:
;
; EXAMPLE:
; CATEGORY:
;
; NOTES:


; VERSION:
;	Jan 01,2001
; HISTORY:
;	Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION F_MOREL_1974_BW,WL, DEMO=demo
  ROUTINE_NAME='F_MOREL_1974_BW'


  IF KEYWORD_SET(DEMO) THEN BEGIN
    WL = INDGEN(1700) + 200
  ENDIF

  BW=0.00288*(WL/500.0)^(-4.32)
  s= REPLICATE(CREATE_STRUCT('WL',0.0,'BW',0.0),N_ELEMENTS(WL))
  S.WL = WL
  S.BW = BW

  IF KEYWORD_SET(DEMO) THEN BEGIN
    PLOT, S.WL,S.BW,XTITLE='Wavelength (nm)',YTITLE='Scattering Coefficient of Pure Sea Water (b!Sw!N)',/YLOG
  ENDIF  ELSE BEGIN
    RETURN, S
  ENDELSE

END; #####################  End of Routine ################################
