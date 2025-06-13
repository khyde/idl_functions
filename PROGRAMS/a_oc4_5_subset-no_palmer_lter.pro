; $ID:	A_OC4_5_SUBSET-NO_PALMER_LTER.PRO,	2020-07-08-15,	USER-KJWH	$


 FUNCTION  A_OC4_5_SUBSET , Rrs443,Rrs489, Rrs510, Rrs555, NOTES=NOTES, LWN=LWN, COEFFS=coeffs
;+
; NAME:
;       A_OC4_5  'Ocean Chlorophyll 4 version 4'
;
; PURPOSE:
;       Compute  Chlorophyll concentration for CZCS wavelengths
;       Using 4th Order Polynomial Equation relating Log10(chla) to Log10(Maximum Band Ratio)
;
;       Original OC4 was developed Using SeaBAM Global dataset (n=919)
;       Reference:
;       O'Reilly, J.E., S. Maritorena, B.Gregg Mitchell, D.A. Siegel, K.L. Carder,
;                       S.A. Garver, M. Kahru and C. McClain.  1998.
;                       Ocean color chlorophyll algorithms for SeaWiFS.
;                       JGR Vol. 103(C11):24,937-24,953.
;
;       OC4 version 4 was tuned to 2804 in situ Reflectance-Chlorophyll observations from the 'Global Set'
;       developed in March, 2000
;
;
; CATEGORY:
;       Empirical Algorithm
;
; CALLING SEQUENCE:
;       C = A_OC4_5(Rrs443,Rrs489,Rrs510,Rrs555)
;
; INPUTS:
;       Rrs for 443 nm, 489nm, 510nm, and Rrs555 nm;
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
;				Aug 7, 2001  T.Ducas  do not calculate chlorophyl for bands with 'missings' values
;				Aug 27,2001  T.Ducas,   AND changed to OR in the following:(Nlw443 GT 0d Rrs489 GT 0d OR Nlw510 GT 0d )
;-


; **********************************************
; **********************************************
; Algorithm Name
  notes =  'Ocean Chlorophyll 4 version 4'


; =================>
; Equation Coefficients:

  a = [0.414,-3.068,2.757,-1.529,-0.279] ; 4TH ORDER


     IF KEYWORD_SET(COEFFS) THEN RETURN, A

; ===================>
; Check for 4 input arrays


  IF N_PARAMS() LT 4 THEN MESSAGE,'ERROR: MUST INPUT Rrs443,Rrs489,Rrs510, and Rrs555 arrays'

; initialize chlor array
   C = DOUBLE(Rrs443)
   C(*) = MISSINGS(C)

; ===================>
; Check for missing data
  OK = WHERE(Rrs443 NE MISSINGS(Rrs443) AND $
             Rrs489 NE MISSINGS(Rrs489) AND $
             Rrs510 NE MISSINGS(Rrs510) AND $
             Rrs555 NE MISSINGS(Rrs555) AND $
             (Rrs443 GT 0d               OR $
             Rrs489 GT 0d                OR $
             Rrs510 GT 0d)              AND $
             Rrs555 GT 0d               AND $
             FINITE(Rrs443)             AND $
             FINITE(Rrs489)             AND $
             FINITE(Rrs510)             AND $
             FINITE(Rrs555) , count)


	IF COUNT LT 1 THEN BEGIN
  	PRINT,'ERROR: NO VALID INPUT DATA'
  	RETURN, C
  ENDIF

; ================>
; Convert Rrs to Lwn if input data are rrs
; Table of Bandpass-weighted Mean Solar Irradiance for SeaWiFS
;           Band 1 Band 2  Band 3  Band 4  Band 5  Band 6  Band 7  Band 8
;           412 nm 443 nm  489 nm  510 nm  555 nm  670 nm  765 nm  865 nm
; F0_bar = [170.79, 189.45, 193.66, 188.35, 185.33, 153.41, 122.24, 98.82]

  IF NOT KEYWORD_SET(LWN) THEN BEGIN
    _RRS443 = DOUBLE(RRS443)
    _RRS489 = DOUBLE(RRS489)
    _RRS510 = DOUBLE(RRS510)
    _RRS555 = DOUBLE(RRS555)
  ENDIF ELSE BEGIN
; these are not correct for czcs
    _RRS443 = DOUBLE(RRS443)/189.45D  ;SEAWIFS
    _RRS489 = DOUBLE(RRS489)/193.66D  ;SEAWIFS
    _RRS510 = DOUBLE(RRS510)/188.35D  ;SEAWIFS
    _RRS555 = DOUBLE(RRS555)/185.33D  ;SEAWIFS
  ENDELSE


; ===> R = Log base 10 of Band Ratio
; Whichever (Rrs443,Rrs489,Rrs510) is greatest, ends up in the numerator of the maximum band ratio
 	R = ALOG10((_RRS443[OK] > _RRS489[OK] > _RRS510[OK]) / _RRS555[OK])

; ===> Calculate chlorophyll concentration (ug/l);
  C[OK] = 10.0^(a[0] + a[1]*R +  a(2)*R^2   + a(3)*R^3 + a(4)*R^4  )

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

