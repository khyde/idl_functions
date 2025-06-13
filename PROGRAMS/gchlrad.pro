; $Id: gchlrad.pro,v 1.0 1995/01/01 12:00:00 J.E.O'Reilly Exp $

; FUNCTION GCHLRAD,CHL, SeaWiFS=SeaWiFS, OCTS=octs ,SMITH=smith
;+
; NAME:
;       gchlrad
;
; PURPOSE:
;       Compute Normalized Water-Leaving Radiances from chlorophyll concentration
;       Using Gordon 1988 Semi-analytical Model and FORTRAN Code Provide by Watson Gregg, GSFC, NASA
;
;       References:
;       Gordon, H.R., O.B. Brown, R.H. Evans, J.W. Brown, R.C. Smith, K.S. Baker and D.K. Clark
;          (1988) A semianalytic radiance model of ocean color. J. Geophys. Res. 93:10909-10924.
;
;       Gregg, W.W., F.C. Chen, A.L. Mezaache, J.D. Chen and J.A. Whiting
;          (1993) The Simulated SeaWiFS Data Set, Version 1.  SeaWiFS Technical Report Series,
;          NASA Technical Memorandum 104566, Vol. 9, Goddard Space Flight Center, MD
;
;
;
; CATEGORY:
;       SeaWiFS, OCTS
;
; CALLING SEQUENCE:
;       Result = gchlrad(chl)
;       LWN    = GCHLRAD(2.0^(RANDOMN(SEED,50000)))  ; Generates 50000 sets of Lwn's
;       Lwns   = gchlrad(chl)
;       Lwns   = gchlrad(chl,/SeaWiFS)
;       Lwns   = gchlrad(chl_array, /octs)
;       Lwns   = gchlrad(chl_array, /SEAWIFS,/SMITH)
;
; INPUTS:
;       chlorophyll concentration(s)
;
; KEYWORD PARAMETERS:
;        SeaWiFS : Computes Radiances for SeaWiFS bands (1-8)
;        OCTS    : Computes Radiances for OCTS    bands (1-8)
;        (IF both SeaWiFS AND OCTS KEYWORDS ARE PROVIDED THEN SeaWiFS radiances are computed)
;        SMITH    ; Use Older Smith and Baker Clear Water Parameters instead of Newer Pope 93 parameters
;
;
; OUTPUTS:
;
;       Lwn (Normalized Water-Leaving Radiances) for each of the radiance bands
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Input chlorophyll data Should be Greater than 0
;       Any zero or negative values or infinite values are changed to NAN (Not A Number)
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;
;           From Fortran code (gordchlrad) from Watson Gregg, GSFC, NASA, MD
;           Date: Wed, 12 Feb 97 17:55:53
;           gregg@smoc1.gsfc.nasa.gov (Watson Gregg)
;    Feb 12, 1997  Translated into IDL Code by:   J.E.O'Reilly,
;    Feb 19, 1997  Default is Pope Clear Water unless SMITH keyword is provided (Smith&Baker)
;
;-

; ********************************************************************
; Compile function GORDBB before main routine
; ********************************************************************
  PRO GORDBB, lam,bbplo,bbphi,A,B
; Computes backscattering coefficients for SeaWiFS bands
; using Gordon et al.'s (1988 -- semi-analytic model formulation.

; Assume a form (bb)p = AC**B
  b0 = 0.2   ; Recommended as best fit by Gordon

; Chl < 0.1
  _chl     = 0.1
  b550     = b0*_chl^0.62
  bbptilde = 0.02*(560.0/FLOAT(lam))
  bbplo    = bbptilde*b550

; Chl = 20.0
  _chl = 20.0
  b550 = b0*_chl^0.62
  bbphi = FLTARR(N_ELEMENTS(lam))
  FOR nl = 0, N_ELEMENTS(lam) -1 DO BEGIN
    IF lam(nl) LT 510  THEN       $
      bbptilde = 0.003            $
    else if lam(nl) LT 650 then   $
      bbptilde = 0.005            $
    else if  lam(nl) LT 700 then  $
    bbptilde = 0.003            $
    else                          $
    bbtilde = 0.005

    bbphi(nl) = bbptilde*b550
  ENDFOR

; Calculate B
  chllo = alog10(0.1)
  chlhi = alog10(20.0)
 ; write(6,10)
  B = (ALOG10(bbphi)-ALOG10(bbplo))/(chlhi-chllo)
  rloga = ALOG10(bbplo) - B*chllo
  A = 10.0^rloga
 ;    write(6,20)lam(nl),bbplo(nl),bbphi(nl),A(nl),B(nl)

;10    format(5x,'lambda',10x,'bbplo',10x,'bbphi',10x,'A',15x,'B')
;20    format(i10,4f15.5)

  END; End of function GORDBB


; *********************************************************************
; Compile function GORDSA before main program
; *********************************************************************
  PRO GORDSA, chl,Fo,rkw,bw,rk1,rk2,ascat,bscat,rlwn

; Gordon's semi-analytic radiance model, applied to SeaWiFS.
; Parameters
  nl=8
  rsmall = 0.48
  ro     = 0.021    ;direct reflectance
  robar  = 0.043    ;normalized mean reflectance Sun+sky from Gordon
  rn     = 1.341    ;index of refraction

; Compute normalized water-leaving radiances
  rkkc = alog10(chl/0.5)

  arg = rk2*rkkc
  arg2 = arg*arg
  rkc = rk1*chl*exp(-arg2) + 0.001*chl*chl
  rK = rkw + rkc
  bbc = ascat*chl^bscat
  bb = 0.5*bw + bbc
  RQ = 0.110*bb/rK
  Rlarge = RQ*!Pi
  rnum = (1.0-ro)*(1.0-robar)*Fo
  rden = rn*rn*(1.0-rsmall*Rlarge)
  rlwn = RQ*rnum/rden

  END  ; End of Pro GORDSA



; *********************************************************************
; MAIN FUNCTION
  FUNCTION GCHLRAD,CHL, SeaWiFS=SeaWiFS, OCTS=octs , SMITH=SMITH

; Table of Sensor Center Wavelengths (nm)
;       S E A W I F S      O C T S
; BAND  Center  Width      Center
; 1     412       20     412  (402-422)
; 2     443       20       443  (433-453)
; 3     490       20       490  (480-500)
; 4     510       20       520  (510-530)
; 5     555       20       565  (555-575)
; 6     670     20       665  (655-675)
; 7     765       40       765  (745-785)
; 8     865       40       865  (845-885)
; 9                       3715  (3550-3880)
; 10                      8525  (8250-8800)
; 11                     10850  (10300-11400)
; 12                     11950  (11400-12500)

; References
; SeaWiFS:  http://SeaWiFS.gsfc.nasa.gov/SeaWiFS/SEASTAR/SPACECRAFT.html
; OCTS   :  http://hdsn.eoc.nasda.go.jp/guide/guide/satellite/sendata/octs_e.html

; QUESTIONS:
;  IS center for SeaWiFS Band #2 443 or 441 ?? and
;  IS this why fobars and fobaro different for band #2
;  Are the Lams and Lamo correct ?
;  The correctness of the parameters (Tables) below requires checking.


  nlt = 8
  Fobar=FLTARR(nlt)

  lams=   [412,    443,     490,     510,     555,     670,     765,     865]  ; SeaWiFS
  lamo=   [412,    443,     490,     520,     565,     665,     765,     865]  ; OCTS

  Fobars= [170.79, 189.45,  193.66,  188.35,  185.33,  153.41,  122.24,  98.82] ;SeaWiFS
  Fobaro =[170.96, 188.17,  194.59,  185.74,  184.49,  153.12,  122.61,  98.55] ;OCTS

  bws =   [0.0067, 0.0048,  0.0031,  0.0026,  0.0019,  0.0008,  0.0005,  0.0003]

  rkws=   [0.0194, 0.0169,  0.0212,  0.0370,  0.0683,  0.4300,  2.53,    3.5]
  rk1s=   [0.208,  0.175,   0.121,   0.103,   0.076,   0.137,   0.040,   0.010]
  rk2s=   [1.077,  1.001,   0.963,   1.006,   1.144,   1.463,   1.732,   1.732]

; Clear Water Values
; NOTE THE rkw VALUES FOR last 2 bands (765,865) FOR POPE ARE WRONG AT PRESENT (SAME AS SMITH & BAKER)
  rkwsb= [0.01940, 0.01690, 0.02120, 0.03700, 0.06830, 0.43000, 2.53000, 3.5000];Smith&Baker, SeaWifs&OCTS
  rkws = [0.00544, 0.00842, 0.01746, 0.03820, 0.06900, 0.43460, 2.53000, 3.5000];POPE, SeaWiFS
  rkwo = [0.00544, 0.00878, 0.01850, 0.04740, 0.07430, 0.43110, 2.53000, 3.5000];POPE, OCTS

; Pope Clear Water Values (from Stephane Maritorena email)
; aw_pope(93) Units are 1/m.
;410  0.00560
;412  0.00544
;441  0.00842
;443  0.00878
;488  0.01746
;490  0.0185
;510  0.0382
;520  0.0474
;550  0.0654
;555  0.069
;565  0.0743
;665  0.4311
;670  0.4346
;671  0.43804
;683  0.465


;  pi  = !PI      ; IDL system variable for pi (!Pi) used instead of 'pi'
;  pi2 = 2.0*PI   ; ??????? not used in program ????

; ====================>
; Select extraterrestrial irradiance and lambda
; Default is SeaWiFS unless only octs keyword provided
  lam   = lams    ; Default is SeaWiFS
  Fobar = Fobars  ; Default is SeaWiFS
  rkw   = rkws    ; Default is SeaWiFS
  bw    = bws
  rk1   = rk1s
  rk2   = rk2s
  IF NOT KEYWORD_SET(SeaWiFS) AND KEYWORD_SET(OCTS) THEN BEGIN
    lam   = lamo
    Fobar = Fobaro
    rkw   = rkwo
  ENDIF

; If you want the older Smith & Baker Clear Water Values then rkw = rkwsb
  IF KEYWORD_SET(SMITH) THEN rkw = rkwsb


; ====================>
; Get scattering coefficients form Gordon's model appropriate for
; the sensor in question

  GORDBB, lam,bbplo,bbphi,ascat,bscat

; ====================>
; Make sure the input array is not empty
  IF N_ELEMENTS(chl) LT 1 THEN BEGIN
    MESSAGE,'ERROR: You Must Input a Chlorophyll Value or an Array of Chlorophyll Values'
  ENDIF

; ====================>
; Replace any input chl values which are LE 0 or EQ Infinity with
; the IDL system variable for floating Not A Number (1.#QNAN)
;  bad = WHERE(chl LE 0.0 OR NOT FINITE(CHL), COUNT_bad)
;  IF count_bad GE 1 THEN BEGIN
;    chl(bad) = !VALUES.(2)
;  ENDIF

; ====================>
; Compute normalized water-leaving radiances
  LWNS = FLTARR(nlt,N_ELEMENTS(chl))

  FOR _nth = 0L, N_ELEMENTS(chl)-1 DO BEGIN
    chl_ = CHL(_nth)
    GORDSA, chl_,Fobar,rkw,bw,rk1,rk2,ascat,bscat,rlwn
    LWNS(*,_nth) = rlwn
  ENDFOR

  RETURN, LWNS
  END

