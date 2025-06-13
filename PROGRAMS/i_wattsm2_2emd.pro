; $Id: i_wattsm2_2emd.pro   May 6, 2005		K.J.W.Hyde

function I_WATTSm2_2Emd,WATTSM2,WAVE
;+
; NAME:
;      i_wattsm2_2emd
;
; PURPOSE:
;      Convert Watts per Meter square to Einsteins per Meter square per Day
;
;      Based on conversion table at http://www.es.embnet.org/~genus/lightcal.html LIGHT CALIBRATIONS AND RADIOMETRIC UNITS
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       Result = I_WATTSm2_2Emd(wattsm2,wave)
;
; INPUTS:
;       WATTSm2 (energy value in W/m^2)
;				WAVE (Wavelength)
;
; OUTPUTS:
;       EMD (PAR Einsteins per Meter Square per Day)
;
; RESTRICTIONS:
;       ;
; NOTES:
;
;
;
; MODIFICATION HISTORY:
;       Written by:  K.J.W.Hyde  May 6, 2005
;-

; ==================>
  IF N_ELEMENTS(WATTSm2) LT 1 THEN WATTSm2 = 1;
  IF N_ELEMENTS(WAVE) NE 1 THEN BEGIN
		PRINT, 'ERROR: Must provide wavelength'
  	RETURN,EMD
	ENDIF
; ====================>
	FACTOR = 8.362e-9

  EMD =  WATTSm2 * FACTOR * WAVE * 60*60*24.0  		; 60seconds * 60minutes *24hours

  RETURN, EMD

  END; END OF PROGRAM
