; $ID:	RRS_2LWN.PRO,	2020-07-08-15,	USER-KJWH	$

   FUNCTION Rrs_2Lwn,VALUE, DOY, WAVE=WAVE
;+
; NAME:
;       Rrs_2Lwn
;
; PURPOSE:
;       Convert Remote Sensing Reflectance to normalized water leaving radiance 
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;				Result = Rrs_2Lwn(value,DOY,WAVE=WAVE)
;       Result = Rrs_2Lwn(21,145,WAVE=412)
;
; INPUTS:
;       DOY:		Satellite day (Day of Year)
;				WAVE:		Wavelength
;				VALUE:	Normalized water leaving radiance value
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       Lwn value for each Rrs
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
;       Written by:			K.J.W. Hyde		March 18, 2010
;       based on the equation:
;								Rrs = Lwn/F0
;								Lwn = Rrs*F0
;-


; ==========================>
; Check for DOY
  IF N_ELEMENTS(DOY) LE 1 THEN BEGIN
  	PRINT, 'ERROR: NO DOY PROVIDED TO DETERMINE F0'
  	RETURN, Rrs
  ENDIF
; Check that DOY and VALUE arrays have equal elements
	IF N_ELEMENTS(VALUE) NE N_ELEMENTS(DOY) THEN BEGIN
		PRINT, 'ERROR: NUMBER OF VALUES DOES NOT EQUAL NUMBER OF DOYS'
		RETURN,Rrs
	ENDIF
  IF N_ELEMENTS(VALUE) LE 1 THEN BEGIN
  	PRINT, 'ERROR: INVALID INPUT VALUE'
  	RETURN, Rrs
  ENDIF

	OK = WHERE(VALUE LE 0,COUNT)
	IF COUNT GE 1 THEN BEGIN
  	PRINT, 'ERROR: NEGATIVE VALUES'
  	RETURN, Rrs
  ENDIF
  IF N_ELEMENTS(WAVE) NE 1 THEN BEGIN
  	PRINT, 'ERROR: NO WAVELENGTH PROVIDED'
  	RETURN, Rrs
  ENDIF	ELSE _WAVE = WAVE

	I = I_F0(DOY)
	IF _WAVE EQ 412 THEN F = I[0]
	IF _WAVE EQ 443 THEN F = I[1]
	IF _WAVE EQ 490 THEN F = I(2)
	IF _WAVE EQ 510 THEN F = I(3)
	IF _WAVE EQ 555 THEN F = I(4)
	IF _WAVE EQ 670 THEN F = I(5)

	Lwn = VALUE*F

RETURN, Lwn
END ; END OF PROGRAM
