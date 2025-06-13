; $Id:	i_f0.pro,	March 15 2007	$

; I_F0 June 1,1999  ; J.O'Reilly

   FUNCTION I_F0, SDAY, SAT=sat,ESDF=ESDF
;+
; NAME:
;       I_F0
;
; PURPOSE:
;       Compute F0 values for I Bands
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = I_F0(21)
;
; INPUTS:
;       Satellite day (Day of Year)
;
; KEYWORD PARAMETERS:
;
;       ESDF:  RETURN EARTH-SUN DISTANCE FACTOR
;
; OUTPUTS:
;       F0 array (for each band)
;
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


; ==========================>
; Default is SeaWiFS
  IF N_ELEMENTS(SAT) NE 1 THEN SAT = 'SEAWIFS'
  SAT = STRUPCASE(SAT)

  IF SAT EQ 'CZCS' THEN BEGIN
; ====================>
; Table of F0_bar for CZCS (taken from W. Gregg: (Evans and Gordon, 1994);
  F0_bar =[186.96, 187.02, 186.81, 153.09]  ;


  ENDIF


  IF SAT EQ 'SEAWIFS' THEN BEGIN
; 	==============>
; 	table below lists the bandpass-weighted extraterrestrial solar irradiance constants () used in SeaWiFS processing. The values need to be adjusted for the earth - sun distance using the following equation:
; 	Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;		# Extraterrestrial Solar Irradiance (mW/cm^2/um/sr)
;		# Thuillier
;           Band 1   Band 2   Band 3   Band 4   Band 5   Band 6   Band 7  Band 8
;            412 nm  443 nm  490 nm  	510 nm  555 nm  	670 nm  	765 nm  	865 nm
  F0_bar = [173.004, 190.154, 196.473, 188.158, 183.010, 	151.143, 	122.316, 	96.302]
  ENDIF



  IF SAT EQ 'MODIS' THEN BEGIN
; 	==============>
; 	table below lists the bandpass-weighted extraterrestrial solar irradiance constants () used in SeaWiFS processing. The values need to be adjusted for the earth - sun distance using the following equation:
; 	Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;		# Extraterrestrial Solar Irradiance (mW/cm^2/um/sr)
;		# Thuillier
;           Band 1  	Band 2   	Band 3   	Band 4   	Band 5   	Band 6   	Band 7  	Band 8 		Band 9
;            412 nm 	443 nm  	488 nm  	531 nm  	551 nm  	667 nm  	678 			748 nm  	869 nm
  F0_bar = [172.718,	187.688,	194.973,	185.82,		186.594,	152.163,	148.097,	128.123,	95.849]

  ENDIF


  IF N_ELEMENTS(SDAY) EQ 0 THEN RETURN, F0_BAR

; PARAMETERS
  A = 1.00014
  B = 0.01671
  C = 0.9856002831
  D = 3.4532868
  E = 360.0

; ==============>
; Make an array to hold results
  ARRAY = FLTARR(N_ELEMENTS(F0_BAR),N_ELEMENTS(sday))
  ESD = FLTARR(N_ELEMENTS(sday)) ; EARTH SUN DISTANCE FACTOR
  FOR nth = 0L, N_ELEMENTS(sday)-1L DO BEGIN
    aday = sday(nth)
    F1 = 1.0 / ( (A-B*COS(2.0*!PI*(C * aday - D)/E)-0.00014*COS(4.0*!PI*(C * aday - D)/E))^2 ) ;;;
    F0 = F0_bar * F1
    array(*,nth) = f0
    ESD(nth) = f1
  ENDFOR

IF KEYWORD_SET(ESDF) THEN RETURN, ESD
RETURN, array
END ; END OF PROGRAM
