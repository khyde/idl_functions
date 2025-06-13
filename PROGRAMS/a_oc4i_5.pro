; $ID:	A_OC4I_5.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION  A_OC4I_5 , Rrs443,Rrs460, Rrs520, Rrs545, NOTES=NOTES, LWN=LWN, COEFFS=coeffs, WLS=WLS
;+
; NAME:
;       A_OC4I_5  'Ocean Chlorophyll 4 GLI version 5'
;
; PURPOSE:
;       Compute  Chlorophyll concentration for CZCS wavelengths
;       Using 4th Order Polynomial Equation relating Log10(chla) to Log10(Maximum Band Ratio)
;
;       Original OC4I was developed Using SeaBAM Global dataset (n=919)
;       Reference:
;       O'Reilly, J.E., S. Maritorena, B.Gregg Mitchell, D.A. Siegel, K.L. Carder,
;                       S.A. Garver, M. Kahru and C. McClain.  1998.
;                       Ocean color chlorophyll algorithms for SeaWiFS.
;                       JGR Vol. 103(C11):24,937-24,953.
;
;       OC4I version 4 was tuned to 2804 in situ Reflectance-Chlorophyll observations from the 'Global Set'
;       developed in March, 2000
;
;
; CATEGORY:
;       Empirical Algorithm
;
; CALLING SEQUENCE:
;       C = A_OC4I_5(Rrs443,Rrs460,Rrs520,Rrs545)
;
; INPUTS:
;       Rrs for 443 nm, 460nm, 520nm, and Rrs545 nm;
;       (Reflectance)
;
; KEYWORD PARAMETERS:
;       NOTES :  Optional output from program.  Notes contains a text string which describes the
;                        equation which may be used (plotted) by the calling program.
;
;       LWN:     IF input data are Lwn and not Rrs
;
; OTHER PROGRAMS USED:
;      MISSINGS.PRO     : Checks for missing data code
;
; OUTPUTS:
;       Chlorophyll a concentration (ug/l)
;
; SIDE EFFECTS:
;       Negative calculations are changed to infinite in the output array.
;
; RESTRICTIONS:
;       Input data must be positive and finite
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Program Written by:  J.E.O'Reilly, July 28,1998
;       Version 3, July 24,1999
;       Version 4, March 30, 2000
;
;
;-


; **********************************************
; **********************************************

; Algorithm Name
  notes =  'Ocean Chlorophyll 4O version 5'

; ===> Equation Coefficients:
  a = [0.4006,-3.1247,3.1041,-1.4179,-0.3654]


  IF KEYWORD_SET(COEFFS) THEN RETURN, A
  IF KEYWORD_SET(WLS) 	THEN RETURN,[443,460,520,545]

; ===> Check for 4 input arrays

  IF N_PARAMS() LT 4 THEN MESSAGE,'ERROR: MUST INPUT Rrs443,Rrs460,Rrs520, and Rrs545 arrays'

; ===> initialize chlor array
  C = DOUBLE(Rrs443)
  C(*) = MISSINGS(C)

; ===================>
; Check for missing data
  OK = WHERE(Rrs443 NE MISSINGS(Rrs443) AND $
             Rrs460 NE MISSINGS(Rrs460) AND $
             Rrs520 NE MISSINGS(Rrs520) AND $
             Rrs545 NE MISSINGS(Rrs545) AND $
             Rrs443 GT 0d               AND $
             Rrs460 GT 0d               AND $
             Rrs520 GT 0d               AND $
             Rrs545 GT 0d               AND $
             FINITE(Rrs443)             AND $
             FINITE(Rrs460)             AND $
             FINITE(Rrs520)             AND $
             FINITE(Rrs545) , count)


 IF COUNT LT 1 THEN BEGIN
    MESSAGE,'ERROR: NO VALID INPUT DATA'
    RETURN,C
  ENDIF

; ===> Convert Rrs to Lwn if input data are rrs
; Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;           Band 1 Band 2  Band 3  Band 4  Band 5  Band 6  Band 7  Band 8
;           412 nm 443 nm  460 nm  520 nm  545 nm  670 nm  765 nm  865 nm
; F0_bar = [170.79, 189.45, 193.66, 188.35, 185.33, 153.41, 122.24, 98.82]

  IF NOT KEYWORD_SET(LWN) THEN BEGIN
    _RRS443 = RRS443
    _RRS460 = RRS460
    _RRS520 = RRS520
    _RRS545 = RRS545
  ENDIF ELSE BEGIN

; these are not correct for czcs
    _RRS443 = RRS443/189.45  ;SEAWIFS
    _RRS460 = RRS460/193.66  ;SEAWIFS
    _RRS520 = RRS520/188.35  ;SEAWIFS
    _RRS545 = RRS545/185.33  ;SEAWIFS
  ENDELSE




; ===> R = Log base 10 of Band Ratio
; Whichever (Rrs443,Rrs460,Rrs520) is greatest, ends up in the numerator of the maximum band ratio
  R = ALOG10((_RRS443[OK]>_RRS460[OK]>_RRS520[OK])/_RRS545[OK])

; ===> Calculate chlorophyll concentration (ug/l)
  C[OK] = 10.0^(a[0] + a[1]*R +  a(2)*R^2   + a(3)*R^3  + a(4)*R^4)

; ==================>
; Now replace Any Negative Values With Missing Code
  bad = WHERE(C  LE 0.0 , count_bad)
  IF count_bad GE 1 THEN C(bad)  = MISSINGS(C)

; ==================>
; Return chlorophyll array to calling program
  RETURN, C

  END ; end of program
; *********************************************************
; *********************************************************

