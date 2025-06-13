; $Id: F_MOREL_1974_PW.pro $
;+
;	This Function Returns the Backscattering Coefficient (PW) for pure sea water
; after Morel 1974
; SYNTAX:
;		Result = F_MOREL_1974_PW(wl)
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

FUNCTION F_MOREL_1974_PW,THETA, DEMO=demo
  ROUTINE_NAME='F_MOREL_1974_PW'


  IF KEYWORD_SET(DEMO) THEN BEGIN
    WL = INDGEN(600) + 200
    THETA = INDGEN(91)
  ENDIF

  PW=0.06225*(1.+0.835*(COS(!DTOR*THETA)^2))
  s= REPLICATE(CREATE_STRUCT( 'PW',0.0,'THETA',0.0) ,N_ELEMENTS(THETA))
  S.THETA = THETA
  S.PW = PW


  IF KEYWORD_SET(DEMO) THEN BEGIN
    PLOT, S.THETA,S.PW,XTITLE='Theta (degrees)',YTITLE='Phase Function for Pure Sea Water (p!Sw!N)'
    XYOUTS,0.7,0.7,'Morel, 1974',/normal,charsize=1.5
  ENDIF  ELSE BEGIN
    RETURN, S
  ENDELSE

END; #####################  End of Routine ################################
