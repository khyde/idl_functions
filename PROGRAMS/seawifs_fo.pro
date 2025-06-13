
; SEAWIFS_F0 June 1,1999  ; J.O'Reilly

   FUNCTION SEAWIFS_F0, SDAY, ESD=ESD
;+
; NAME:
;       SEAWIFS_F0
;
; PURPOSE:
;       Compute F0 values for SeaWiFS Bands
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = SEAWIFS_F0(21)
;
; INPUTS:
;       Satellite day (Day of Year)
;
; KEYWORD PARAMETERS:
;       None
; OUTPUTS:
;       F) array (for each band)
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Coded  by:  J.E.O'Reilly, June 1,1999
;       Coded from NASA : ;; http://seawifs.gsfc.nasa.gov/~sbailey/solar_const.html
;-


; ==============>
  IF N_PARAMS()  EQ 0  THEN RETURN, -1


; ==============>
; table below lists the bandpass-weighted extraterrestrial solar irradiance constants () used in SeaWiFS processing. The values need to be adjusted for the earth - sun distance using the following equation:

;where:

;Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;Band 1 Band 2 Band 3 Band 4 Band 5 Band 6 Band 7 Band 8
;412 nm 443 nm 490 nm 510 nm 555 nm 670 nm 765 nm 865 nm
;170.79 189.45 193.66 188.35 185.33 153.41 122.24 98.82

;Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;           Band 1 Band 2  Band 3  Band 4  Band 5  Band 6  Band 7  Band 8
;           412 nm 443 nm  490 nm  510 nm  555 nm  670 nm  765 nm  865 nm
 F0_bar = [170.79, 189.45, 193.66, 188.35, 185.33, 153.41, 122.24, 98.82]


  A = 1.00014
  B = 0.01671
  C = 0.9856002831
  D = 3.4532868
  E = 360.0

; ==============>
; Make an array to hold results
  ARRAY = FLTARR(N_ELEMENTS(F0_BAR),N_ELEMENTS(sday))
  ESD = FLTARR(N_ELEMENTS(sday)) ; EARTH SUN DISTANCE FACTOR
  FOR nth = 0, N_ELEMENTS(sday)-1L DO BEGIN
    aday = sday(nth)
    F1 = 1.0 / ( (A-B*COS(2.0*!PI*(C * aday - D)/E)-0.00014*COS(4.0*!PI*(C * aday - D)/E))^2 )
    F0 = F0_bar * F1
    array(*,nth) = f0
    ESD(nth) = f1
  ENDFOR



RETURN, array
END ; END OF PROGRAM
