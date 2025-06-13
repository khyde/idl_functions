; $Id:	I_qcs.pro,	2003 Oct 29 09:22	$
;        I_QCS  June 4,1999
FUNCTION I_QCS, LAT=lat, DOY=DOY, PCT=PCT, UNITS=units

;+
; NAME:
;       I_QCS
;
; PURPOSE:
;
;	PROGRAM COMPUTES QCS USING SMITHSONIAN FORMULA
;	(SECKEL AND BEAUDRY, 1973)
;	EQUATIONS FROM KURING,LEWIS,PLATT,AND O'REILLY, 1988
;
;	PAR QUANTUM SENSOR AT SANDY HOOK MARINE LAB,NJ,
;   BLDG 74 ROOF: LATITUDE = 40DEG, 25 MIN NORTH(LAT = 40.41666)
;
; CATEGORY:
;
;   LIGHT
;
; CALLING SEQUENCE:
;       Result = I_QCS() ; WILL MAKE A PLOT
;       Result = I_QCS(LAT = 40.41666)
;       Result = I_QCS(LAT = 40.41666, DOY = [21, 366./2])
;       Result = I_QCS(LAT = 40.41666, DOY = [21, 175], UNITS='PAR')
;       Result = I_QCS(LAT = 40.41666, DOY = [21, 175], UNITS='PAR')
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;       LAT:   Latitude for Estimates of Clear Sky Radiation
;       DOY:   Day of Year
;       UNITS: PAR OR TR (TOTAL RADIATION)
;       PCT:   Percent of radiation value to output

;
; OUTPUTS:
;       Clear Sky Radiation in units of PAR (E/m2/d) or
;                           in units of Total Radiation
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
;       Written by:  J.E.O'Reilly, June 4,1999
;                    From FORTRAN QCS.FOR
;                    Necessary to add statement: PI = !DTOR*PI
;                    to convert PI to radians (Not needed in FORTRAN version)
;-
; ================>
; CONSTANTS
  DAYS_PER_YEAR = 365.25 ; WAS 365

  IF N_ELEMENTS(LAT) LT 1 THEN LAT = 40.41666


  IF N_ELEMENTS(DOY) LT 1 THEN DOY = DINDGEN(366)
  IF N_ELEMENTS(PCT) NE 1 THEN PCT = 100.0
  PCT = PCT/100.0

; ====================>
; Equations using Latitude

  A0 = 342.61 - 1.97*LAT - 0.018*LAT*LAT
  A1 =  52.08 - 5.86*LAT + 0.043*LAT*LAT
  B1 =  -4.08 + 2.46*LAT - 0.017*LAT*LAT
  A2 =   1.08 - 0.47*LAT + 0.011*LAT*LAT
  B2 = -38.79 + 2.43*LAT - 0.034*LAT*LAT


; ====================>
  PI = (DOY - 21.0)
  PI = PI * 360. / DAYS_PER_YEAR
  PI = !DTOR*PI

; ====================>
; Compute Q Clear Sky (Total Radiation)
  QCS = A0 + A1*COS(PI) + B1*SIN(PI) + A2*COS(2*PI) + B2*SIN(2*PI)

; ====================>
; Compute PAR Clear Sky
  PARcs = QCS * 0.397 * 0.44

; ====================>
; Compute percent of total
  QCS = QCS * PCT
  PARcs = PARcs * PCT

; ====================>
; Compute percent of total
  PI = PI * DAYS_PER_YEAR / 360

; ====================>
; Return units
  IF NOT KEYWORD_SET(UNITS) THEN UNITS='PAR'
  IF UNITS EQ 'PAR' THEN RETURN, PARcs
  IF UNITS EQ 'TR' THEN RETURN, QCS

END
