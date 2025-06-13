; $Id: PP_ALK_C02.PRO,v 1.0 1998/02/16 12:00:00 J.E.O'Reilly Exp $

  FUNCTION  PP_ALK_C02, TEMP=temp, SAL=sal, PH=ph, T_PH=T_PH, ALK_PH=alk_ph,$
            VERBOSE=verbose



;+
; NAME:
;       PP_ALK_C02
;
; PURPOSE:
;       Compute C02 concentration from in situ temperature, Salinity,
;                                           pH, pH temperature (lab), and Alkalinity pH
;
; CATEGORY:
;       Primary Productivity
;
; CALLING SEQUENCE:
;       Result = PP_ALK_CO2(TEMP, SAL, PH, PH_T, AH)
;
; INPUTS:
;       TEMPERATURE (in situ, Centigrade))
;       SALINITY    (in situ PPT)
;       pH          (Sea Water ph)
;       T_;H        (Temperature at which pH is measured, Centigrade)
;       ALK_pH      (Alkalinity pH) (Strickland and Parsons)
;
;
;
; KEYWORD PARAMETERS:
;       Carbonate_alkalinity
;
; OUTPUTS:
;       Total C02 concentration (mgC/m3)
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Program does not correct total C02 concentration for depth (assumes simulated in situ surface incubations).
;
; PROCEDURE:
;       Must provide all 5 input parameters.
;
; MODIFICATION HISTORY:
; Written by:  J.E.O'Reilly, March 16, 1998
; Code translated into IDL from a portion of the FORTRAN program NEPPP1.FOR
; Based on Strickland and Parsons, A Practical Handbook of Seawater Analysis. 1972

; Equations were derived by J.O'Reilly on May 6,1978
; using least squares polynomial regression to simulate and interpolate
; the table values in the Strickland and Parsons Tables referenced below ...
;-

;
; ====================>
; Ensure that N_ELEMENTS for each of the required input parameters is matched
  MIN_N = MIN([N_ELEMENTS(TEMP),N_ELEMENTS(SAL),N_ELEMENTS(PH),N_ELEMENTS(T_PH),N_ELEMENTS(ALK_PH)])
  MAX_N = MIN([N_ELEMENTS(TEMP),N_ELEMENTS(SAL),N_ELEMENTS(PH),N_ELEMENTS(T_PH),N_ELEMENTS(ALK_PH)])

  IF MIN_N NE MAX_N OR MAX_N EQ 0 THEN BEGIN
    PRINT, 'ERROR: ALL 5 INPUT PARAMETERS ARE REQUIRED'
    RETURN, -1
  ENDIF

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Compute Total Carbonate Alkalinity for each input set of measurements
  FOR nth = 0, N_ELEMENTS(ALK_PH)-1 DO BEGIN

;   Get nth set of inputs
    atemp   = temp
    asal    = sal
    aph     = ph
    at_ph   = t_ph
    aalk_ph = alk_ph

;   ====================>
;   If any of the required inputs are missing then set total C02 to default (25000.0)
    IF  ATEMP EQ MISSINGS(ATEMP) OR ASAL EQ MISSINGS(ASAL)   OR APH EQ MISSINGS(APH) $
                             OR AT_PH    EQ MISSINGS(AT_PH)  OR aalk_ph EQ MISSINGS(aalk_ph) $
                             THEN RETURN, 25000.0


;   ====================>
;     Temperature Corrections for pH measurements
;     Strickland and Parsons Table VI.3 p. 294
      IF ASAL  LT 32 THEN GOTO, L11
      GOTO, L13
 L11: IF ATEMP GT 20 THEN GOTO, L12
      ALPHA= -0.13677 + 0.034193*aph -0.0019643*aph^2
      GOTO, L15
 L12: ALPHA= -0.13346 + 0.033927*aph -0.0020090*aph^2
      GOTO, L15
 L13: IF ATEMP GT 20 THEN GOTO, L14
      ALPHA= -0.14225 + 0.035930*aph -0.0020980*aph^2
      GOTO, L15
 L14: ALPHA= -0.19973 + 0.050884*aph -0.0030804*aph^2


;     ====================>
;     Correct laboratory-measured pH to pHs (in situ pH)
 L15: pHs = aph-ALPHA*(ATEMP-AT_PH)



;     ====================>
;     Factor (f) for Total Alkalinity Correction
;     Strickland and Parsons Table VI.6 p.297

      IF aalk_ph GT 3   THEN GOTO, L16
      f=0.825 -0.00441*ASAL +0.0000847*ASAL^2
      GOTO, L18
 L16: IF aalk_ph GT 3.9 THEN GOTO, L17
      f=0.8079-0.00441*ASAL +0.0000847*ASAL^2
      GOTO, L18
 L17: f=0.8479-0.00441*ASAL +0.0000847*ASAL^2


;     ====================>
;     Total Alkalinity Calculation
;     Strickland and Parsons Table VI.6 p.297
;     Calculate AH
 L18: aH= 10.0^(aalk_ph *(-1.0)) ; make alkalinity pH negative
      total_alkalinity = 2.500 -((1250. * aH)/f)


;     ====================>
;     Conversion of Total Alkalinity to Carbonate Alkalinity
;     Calculate borate alkalinity and subtract from total alkalinity to get carbonate alkalinity
;     Strickland and Parsons Table VI.8 p.298
      borate_alkalinity=0.01*(2.718^(-17.57+2.14*pHs+0.056*ASAL)+ATEMP*(-1.09+0.134*pHs+0.0037*ASAL))
      IF borate_alkalinity LT 0 THEN borate_alkalinity=0.0

      carbonate_alkalinity = total_alkalinity - borate_alkalinity


;     ====================>
;     Conversion of Carbonate Alkalinity to Total Carbon Dioxide
;     Strickland and Parsons Table VI.9 p.300
      Ft = 2.7183^(0.928-0.114*pHs-0.0012*ASAL)+ATEMP*(0.0123-0.0016*pHs-0.00003*ASAL)

      total_C02 = carbonate_alkalinity * Ft

      GCM3 = total_C02 *12000.0
      IF KEYWORD_SET(VERBOSE) THEN BEGIN
        PRINT, '     TEMP        SAL,         PH          T_PH        ALK_PH      ALPHA,       pHs,           F,      TOT_ALK  BOR_ALK CAR_ALK       ft       TOT_C02    GCM3'
        PRINT, ATEMP,ASAL,APH,AT_PH,AALK_PH, ALPHA,PHS,F,TOTAL_ALKALINITY,BORATE_ALKALINITY,CARBONATE_ALKALINITY,FT,TOTAL_C02,GCM3,$
        FORMAT='(13F10.6,F10.1 )'
      ENDIF
   ENDFOR
   RETURN, GCM3

END
