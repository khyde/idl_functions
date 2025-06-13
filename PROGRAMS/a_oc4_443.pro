; $ID:	A_OC4_443.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION  A_OC4_443 , Rrs443,Rrs490, Rrs510, Rrs555, NOTES
;+
; NAME:
;       A_OC4  'Ocean Chlorophyll 4'
;
; PURPOSE:
;       Compute  Chlorophyll concentration
;       Using Modified 3rd Order Polynomial Equation relating Log chla to Maximum Band Ratio
 ;       Developed by J.O'Reilly (NOAA) and S. Maritorena (NASA)
;       Using SeaBAM Global dataset (n=919)
;        Reference: O'Reilly, J.E. and S. Maritorena. 1997. SeaBAM Algorithm Evaluation.
;                           NASA Sea WiFS Technical Report Series. Vol. #.
;                          S.B. Hooker and E.R. Firestone, Eds.,
;                          NASA Goddard Space Flight Center, Greenbelt, MD, ##pp.
;
; CATEGORY:
;       Empirical Algorithm
;
; CALLING SEQUENCE:
;       C = A_OC4(Rrs443,Rrs490,Rrs510,Rrs555)
;
; INPUTS:
;       Rrs for 443 nm, 490nm, 510nm, and Rrs555 nm;
;       (Reflectance)
;
; KEYWORD PARAMETERS:
;       NOTES :  Optional output from program.  Notes contains a text string which describes the
;                        equation which may be used (plotted) by the calling program.
;
; OTHER PROGRAMS USED:
;      MISSINGS.PRO     : Checks for missing data code
;      STRALONG.PRO  : Converts string array into a long string (See keyword Notes)
;      STR_ADD.PRO       : Adds characters to a string (See keyword Notes)
;      NUM2STR.PRO    : Converts number to string (See keyword Notes)
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
;       Program Written by:  J.E.O'Reilly, March 25, 1997.
;       Apr 15,1997 Added notes
;       June 5, 1997 Changed name to OC3B
;
;-


; **********************************************
; **********************************************
; Algorithm Name
  name =  'Ocean Chlorophyll 4'

; ===================>
; Check for 4 input arrays

    IF N_PARAMS() LT 4 THEN MESSAGE,'ERROR: MUST INPUT Rrs443,Rrs490,Rrs510, and Rrs555 arrays'

; ===================>
; Convert to double precision
  Rrs443 = DOUBLE(TEMPORARY(Rrs443))
  Rrs490 = DOUBLE(TEMPORARY(Rrs490))
  Rrs510 = DOUBLE(TEMPORARY(Rrs510))
  Rrs555 = DOUBLE(TEMPORARY(Rrs555))

; ===================>
; Check for missing data
  OK = WHERE(Rrs443 NE MISSINGS(Rrs443) AND $
             Rrs490 NE MISSINGS(Rrs490) AND $
             Rrs510 NE MISSINGS(Rrs510) AND $
             Rrs555 NE MISSINGS(Rrs555) AND $
             Rrs443 GT 0d               AND $
             Rrs490 GT 0d               AND $
             Rrs510 GT 0d               AND $
             Rrs555 GT 0d               AND $
             FINITE(Rrs443)             AND $
             FINITE(Rrs490)             AND $
             FINITE(Rrs510)             AND $
             FINITE(Rrs555) , count)

  IF COUNT GE 1 THEN BEGIN
    Rrs443 = Rrs443[OK]
    Rrs490 = Rrs490[OK]
    Rrs510 = Rrs510[OK]
    Rrs555 = Rrs555[OK]
  ENDIF  ELSE BEGIN
    MESSAGE,'ERROR: NO VALID INPUT DATA'
  ENDELSE

; =================>
; Equation Coefficients:

  a = [0.48263, -3.65903,  4.14697, -2.03113, -0.07871]

; ====================>
; Make a STRING (notes)  containing the information about the algorithm
  IF N_PARAMS() EQ 5 THEN BEGIN
    TXT   = name
    TXT   = [TXT, 'R = Log!D10!N((Rrs443>Rrs490>Rrs510)/Rrs555)']
    TXT   = [TXT, 'a = [' + STRALONG(STR_ADD(NUM2STR(A,FORMAT='(F10.4)') ,', ') ) +']' ]
    TXT   = [TXT, 'Chl a = 10^(a!D0!N+a!D1!NR+a!D2!NR!U2!N+a!D3!NR!U3!N) +a!D4!N']
    TXT   = [TXT, "SEABAM, J.O'Reilly, S.Maritorena"]
    TXT   = STR_ADD(TXT,'!C!C')
    TXT   = STRALONG(TXT)
    NOTES=TXT
  ENDIF

; ====================>
; R = Log base 10 of Band Ratio
; Whichever (Rrs443,Rrs490,Rrs510) is greatest, ends up in the numerator of the maximum band ratio
  R = ALOG10((Rrs443>Rrs490>Rrs510)/Rrs555)

; ====================>
; Calculate chlorophyll concentration (ug/l)
  C = 10.0^(a[0] + a[1]*R +  a(2)*R^2   + a(3)*R^3)  +a(4)

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

