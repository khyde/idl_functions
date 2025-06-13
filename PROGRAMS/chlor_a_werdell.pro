; $ID:	CHLOR_A_WERDELL.PRO,	2018-10-24-11,	USER-KJWH	$
FUNCTION CHLOR_A_WERDELL, ARRAY, SENSOR=SENSOR

;+
; NAME:
;   CHLOR_A_WERDELL
;
; PURPOSE:;
;   This procedure uses Jeremy Werdell's model to produce a Chesapeake Bay regional chlorophyll a using SeaWiFS and MODIS. 
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   Result = CHLOR_A_WERDELL(ARRAY, SENSOR=SENSOR)
;
; INPUTS:
;   ARRAY:   Input chlorophyll a data
;   SENSOR:  SeaWiFS or MODIS
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
;
; NOTES:
;  Algorithm provided by Xiaoju Pan (a former post-doc for Antonio Mannino)
;  CHL = 10^{A0 + A1*ALOG10(Rrs1/Rrs2) + A2*ALOG10[(Rrs1/Rrs2)^2] + A3*ALOG10[(Rrs1/Rrs2)^3]}
;  If Rrs1/Rrs2 is 490/555 then: A0=0.02534, A1=-3.033, A2=2.096,  A3=-1.607
;  If Rrs1/Rrs2 is 490/670 then: A0=1.351,   A1=-2.427, A2=0.9395, A3=-0.2432 
;
; MODIFICATION HISTORY:
;     Written Mar 22, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;     Modified:
;     Jul 28, 2015 - KJWH: Updated SENSOR check to look for any variation of MODIS (i.e. MODISA) by using HAS(SAT,'MODIS')
;     Oct 16, 2018 - KJWH: Added IF SAT EQ 'OCCCI'  THEN SAT = 'SEAWIFS' to work with the OCCCI sensor
;     Oct 24, 2018 - KJWH: Added IF SAT EQ 'VIIRS'  THEN SAT = 'MODIS'
;     
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CHLOR_A_PAN'

; ===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;      The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)


  IF N_ELEMENTS(SENSOR) NE 1 THEN BEGIN
    PRINT, 'Must provide SENSOR information'
    RETURN, []
  ENDIF ELSE SAT = STRUPCASE(SENSOR)
  
  IF SAT EQ 'VIIRS'  THEN SAT = 'MODIS'
  IF SAT EQ 'MODISA' THEN SAT = 'MODIS'
  IF SAT EQ 'OCCCI'  THEN SAT = 'SEAWIFS'
  IF HAS(SAT,'SEAWIFS') EQ 0 AND HAS(SAT,'MODIS') EQ 0 THEN BEGIN
    PRINT, 'Must provide either SEAWIFS or MODIS'
    RETURN, []
  ENDIF  

  IF SAT EQ 'SEAWIFS' THEN A = 0.249 ELSE A = 0.264           ; SLOPE - chlorophyll correction
  IF SAT EQ 'SEAWIFS' THEN B = 0.844 ELSE B = 0.960           ; INTERCEPT - chlorophyll correction

  ARR = VALID_DATA(FLOAT(ARRAY),PROD='CHLOR_A', SUBS=SUBS, COUNT=COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT)
  
  IF COUNT GE 1 THEN BEGIN
    ARR(SUBS) = 10^((ALOG10(ARR(SUBS))-A)/B)
    RETURN, ARR
  ENDIF
  RETURN, ARR

  
  
END
