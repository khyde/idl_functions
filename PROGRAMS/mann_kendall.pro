; $ID:	MANN_KENDALL.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION MANN_KENDALL, X, ALPHA=ALPHA, MISSINGS=MISSINGS, SLOPE=SLOPE, PVAL=PVAL, Z=Z

;+
; NAME:
;   MANN_KENDALL
;
; PURPOSE:
;   This function calculates the non parametric MANN-KENDALL (MK) statistics to determine if there is (or not) a significant trend.  
;   The slope is calcualted by using Sen's method(s), which is robust and less affected by outliers (Sen p.k. 1968, ASAJ) 
;   
;   
;
; 
; 
;
; CATEGORY:
;   Statistics
;
; CALLING SEQUENCE:
;
;   Result = MANN_KENDALL(X, MISSINGS=MISSINGS)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   X:  The data array of variables to test
;
; KEYWORD PARAMETERS:
;   MISSINGS: The missing varible in the data array
;
; OUTPUTS:
;   This function returns the ...
;
; OPTIONAL OUTPUTS:
;   
; PROCEDURE:
;   SL = MANN_KENDALL([0.5,0.1,0.5,0.1,0.3]
;
; EXAMPLE:
;
; NOTES:
;   Code was adapted from Robinson Negron Juarez, Tulane University, Biosphere-Atmosphere INteraction and Climate Change Research
;     "This software is provided "as-is", without any express or implied warranty. The author WILL NOT BE resposable for any damage arising from its use."
;     If you find bugs and have the solutions please contac: rjuarez@tulane.edu
;     
; CITATION:  
;   Sen, P. K. 1968. Estimates of the Regression Coefficient Based on Kendall's Tau. Journal of the American Statistical Association, 63: 1379-1389.
;     
;   
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;         
;
; MODIFICATION HISTORY:
;     Written:  February 25, 2007 by Robinson Negron Juarez at Georgia Tech University (later Tulane University)
;               February 10, 2020 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov) 
;     Modified: Mar 07, 2007 - RNJ:  Paola Arias @ Georgia Tech completed Vn (Eq. 2.6  Sen P.K. 1968, ASAJ).
;               Sep 17, 2009 - RNJ:  RNJ @ Tulane University. The trend and the p-val (two-sides) on your screen.
;               Feb 10, 2020 - KJWH: Adapted code originally written by RNJ 
;-
; ****************************************************************************************************
ROUTINE_NAME = 'MANN_KENDALL'


  IF N_ELEMENTS(ALPHA) NE 1 THEN ALPHA = 0.05


  If TOTAL(FINITE(X,/NAN)) EQ 0 THEN BEGIN ; Currently this does not work with missing data, however the MK test should be able to work with missings data points
    X = FLOAT(X)
    NX = N_ELEMENTS(X)
    NX1 = NX-1.
    N = NX*(NX-1)/2.  ; THE NUMBER OF ELEMENTS IN D
    D = FLTARR(N)
    M = 0.

    FOR I=0,NX1-1 DO BEGIN
      FOR J=I+1,NX-1 DO BEGIN
        D(M)=X(J)-X(I)
        M=M+1
      ENDFOR
    ENDFOR

    FOR I=0L,N-1 DO BEGIN
      IF D(I) LT 0. THEN D(I)=-1.
      IF D(I) EQ 0. THEN D(I)= 0.
      IF D(I) GT 0. THEN D(I)= 1.
    ENDFOR

    S=TOTAL(D)

    U=X(UNIQ(X(SORT(X))))
    CORR=0.       ;Correction for tied observations (equal value)

    For y=0,N_Elements(U)-1 Do Begin
      find=Where(x eq U(y))
      uj=N_Elements(find)
      Corr=Corr+uj*(uj-1)*(2*uj+5)
    EndFor

    VS=(NX*(NX-1.)*(2*NX+5.)-CORR)/18.   ;For long series it is necessary to use the whole eq. 2.6 (Corr) (Sen p.k. 1968, ASAJ)

    IF S GT 0. THEN Z=(S-1)/SQRT(VS)
    IF S LT 0. THEN Z=(S+1)/SQRT(VS)
    IF S EQ 0. THEN Z=0.
    
    TAU = R_CORRELATE(X, FINDGEN(N_ELEMENTS(X))+1, /KENDALL)

    Sn=fltarr(n)
    m=0.

    For i=0,nx1-1 Do Begin
      For j=i+1,nx-1 Do Begin
        Sn(m)=(x(i)-x(j))/(i-j)
        m=m+1
      EndFor
    EndFor

    Snsorted=Sn(sort(Sn))
    m=float(fix(n/2.))

; ===> Probability value    
    PVAL=2*(1.-GAUSS_PDF(ABS(Z)))  ; (two-side)


; ===> Sen's Slope
    If 2*m    Eq n Then slope=0.5*(Snsorted(m)+Snsorted(m+1))
    If 2*m+1. Eq n Then slope=Snsorted(m+1)
    
; ===> Sen's Intercept    
    INT = median(x + slope*findgen(n_elements(x))+1);median of the values yi ? mxi - not sure if this is correct
    
    
  Endif Else Begin
    Print, 'There are missing values"
    slope=undef
  EndElse
  
  IF Z EQ 0 THEN TREND = 0
  IF Z GT 0 THEN TREND = 1
  IF Z LT 0 THEN TREND = -1
  
  IF Z NE 0 AND PVAL LT ALPHA THEN SIG = 1 ELSE SIG = 0
  
  
  RETURN, CREATE_STRUCT('N',NX,'TREND',TREND,'SIGNIFICANT',SIG,'ALPHA',ALPHA,'SCORE',S,'VAR_SCORE',VS,'Z',Z,'SLOPE',SLOPE,'INTERCEPT',INT,'PVALUE',PVAL,'TAU',TAU[0],'TAU_PVALUE',TAU[1])

End
