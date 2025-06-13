; $ID:	POLY_FIT_ORTHO.PRO,	2020-07-08-15,	USER-KJWH	$
; Research Systems, Inc., jhowell 03/99
FUNCTION POLY_FIT_ORTHO, X, Y, NDEGREE, YFIT, POLYVAR, SIGMA, Corrm, TYPE=TYPE,$
                         ORPOLY=ORPOLY, XINTERP=XIN, YINTERP=YIN, INPOLY=INPOLY,$
                         C_O=C_O, C_X=C_X, C_T=C_T, XAVG=XAVG,XRANGE=XRANGE,$
                         QX=QX, QT=QT, RMS=RMS, STD=STD, FIT=FIT, DOUBLE=DOUBLE,$
                         WARNMSSG=WM
;+
; NAME:
;        POLY_FIT_ORTHO
;
; PURPOSE:
;        Perform a least squares polynomial fit using orthonormal polynomials
;   and return a vector of coefficients of length NDEGREE + 1.
;
;   As an alternative to the IDL function POLY_FIT, POLY_FIT_ORTHO is capable
;   of performing very high degree polynomial fits (exact fits are possible)
;   to an independent variable Y-vector using an arbitrary independent
;   variable X-vector. The function POLY_FIT is more limited in spanning
;   possible values of NDEGREE and X.
;
;   Execution time can be optimized for repeated calls to POLY_FIT_ORTHO
;   when the independent variable X vector remains the same between calls.
;
;   Other IDL curve fitting routines include SVDFIT, which uses Singular Value
;   Decomposition and allows the user to specify the bases used to perform the fit,
;   POLYFITW, which performs a weighted least squares fit and CURVEFIT which uses a
;   gradient-expansion algorithm to compute a non-linear least squares fit to a
;   user-supplied function.
;
; CATEGORY:
;        Curve fitting.
;
; CALLING SEQUENCE:
;   C = POLY_FIT_ORTHO( X, Y, NDEGREE, [YFIT, POLYVAR, SIGMA, Corrm,] TYPE=TYPE,$
;                       ORPOLY=ORPOLY, XINTERP=XIN, YINTERP=YIN, INPOLY=INPOLY,$
;                       C_O=C_O, C_X=C_X, C_T=C_T, XAVG=XAVG,XRANGE=XRANGE,$
;                       QX=QX, QT=QT, RMS=RMS, STD=STD, FIT=FIT, DOUBLE=DOUBLE.$
;                       WARNMSSG=WM )
;
; EXAMPLE:
;    X = FINDGEN(101)
;    Y = SIN(12.*!PI*X/100.) + RANDOMN(SEED, 101)
;    NDEGREE = 19
;    YFIT = POLY_FIT_ORTHO(X, Y, NDEGREE, /FIT)
;    PLOT, X, Y, LINESTYLE = 1
;    OPLOT, X, YFIT, THICK = 2
;    END
;
;
; INPUT:
;   X:  The independent variable vector of the same length as Y or longer.
;       If there are more elements in X than Y, then only the first N_ELEMENTS(Y)
;       elements in X are used.
;
;        Y:        The dependent variable vector of the same length as X.
;       If there are more elements in Y than X, then an error will occur.
;
;   NDEGREE:  The degree of the polynomial fit.
;
; OUTPUT:
;        POLY_FIT returns a coefficient vector of length NDEGREE + 1.
;   If the keyword FIT is specified and non-zero then POLY_FIT
;   returns the polynomial fit vector, YFIT, which is removed from
;   argument list.
;
;
; OPTIONAL OUTPUT:
;   YFIT:  Set on output to the polynomial fit vector of the same length as Y.
;
;   POLYVAR: Set on output to the distribution of variance in Y explained versus
;            degree of polynomial 0,...,NDEGREE where POLYVAR[0] includes the average
;            value of Y while  POLYVAR[J] J = 1, ..., NDEGREE is a monotonic sequence
;            with POLYVAR(NDEGREE) approaching the variance of Y
;            as NDEGREE increases toward N_ELEMENTS(Y) - 1.
;
;   SIGMA: Set on output to a vector of length NDEGREE + 1 containing error
;          estimates of the return coefficients.
;
;   Corrm: This argument is ignored by POLY_FIT_ORTHO and is present
;          to ensure that previously valid calls to POLY_FIT are compatible.
;
; KEYWORD PARAMETERS:
;
;   TYPE:  If this keyword is present then ...
;   TYPE=0 (default) leads to POLY_FIT_ORTHO returning
;          coefficient vector C_O of length NDEGREE + 1 where
;          YFIT = C_O[0] * ORPOLY[*,0] + . . . + C_O[NDEGREE] * ORPOLY[*,NDEGREE]
;
;   TYPE=1 leads to POLY_FIT_ORTHO returning
;          coefficient vector C_X of length NDEGREE + 1 where
;          YFIT = C_X[0] * X^0 + . . . + C_X[NDEGREE] * X^NDEGREE
;
;   TYPE=2 leads to POLY_FIT_ORTHO returning
;          coefficient vector C_T of length NDEGREE + 1 where
;          YFIT = C_T[0] * T^0 + . . . + C_T[NDEGREE] * T^NDEGREE
;          and T = (X - XAVG) / XRANGE
;
;   ORPOLY: Keyword set on output to an N_ELEMENTS(Y) x NDEGREE+1 array
;           containing the orthonormal polynomials evaluated at X.
;           The rows contain the polynomial vectors, so ORPOLY[*,0] is
;           the 0th degree polynomial, ORPOLY[*,1] is the 1st degree (linear)
;           polynomial, ORPOLY[*,2] the 2nd degree (quadratic) polynomial, and so on.
;
;   XINTERP: Keyword set on input to a vector of additional independent
;            variable values for calculation of the polynomial fit.
;            For predictable results, the values of XINTERP should be
;            bounded such that
;            MIN(X) LE MIN(XINTERP) and MAX(XINTERP) LE MAX(X)
;
;   YINTERP: Keyword set on output to the vector of same length as XINTERP
;            with the polynomial fit values calculated at XINTERP.
;
;   INPOLY: If the keyword XINTERP is specified then this keyword is set on
;           output to an N_ELEMENTS(XINTERP) x NDEGREE+1 array
;           containing the orthonormal polynomials evaluated at XINTERP.
;           The rows contain the polynomial vectors, so INPOLY[*,0] is
;           the 0th degree polynomial, INPOLY[*,1] is the 1st degree(linear)
;           polynomial, INPOLY[*,2] the 2nd degree (quadratic) polynomial, and so on.
;
;        C_O:        Keyword set on output to the vector of orthonormal polynomial
;           coefficients of length NDEGREE + 1 such that
;           YFIT = C_O[0] * ORPOLY[*,0] + . . . + C_O[NDEGREE] * ORPOLY[*,NDEGREE]
;
;        C_X:        Keyword set to a named array which on output is the vector of
;           X^P polynomial coefficients of length NDEGREE + 1 such that
;           YFIT = C_X[0] + C_X[1] * X + . . . + C_X[NDEGREE] * X^NDEGREE
;
;        C_T:        Keyword set to a named array which on output is the vector of
;           T^P polynomial coefficients of length NDEGREE + 1 where
;           T[J] = (X[J] - XAVG) / XRANGE corresponds to the independent
;           variable X-vector mapped into the interval [-0.5,0.5], and
;           YFIT = C_T[0] + C_T[1] * T + . . . + C_T[NDEGREE] * T^NDEGREE
;
;   XAVG:   Keyword set on output to a scalar corresponding to the
;           arithmetic average of the independent variable X-vector.
;
;   XRANGE: Keyword set on output to a scalar corresponding to the
;           difference between the maximum and minimum values of the
;           independent variable X-vector.
;
;   QX:     If this keyword is set to a named array or TYPE=1 then this
;           keyword is set on output to an NEDGREE + 1 x NDEGREE + 1 array
;           containing the coefficients of X^P, P = 0,...NDEGREE
;           for the NDEGREE + 1 orthonormal polynomials. The rows of
;           QX correspond to the different polynomials so, for example,
;           a 3rd degree orthonormal polynomial is
;           ORPOLY(*,3) = QX[0,3] + QX[1,3]*X + QX[2,3]*X^2 + QX[3,3]*X^3
;
;   QT:     If this keyword is set to a named array or TYPE=2 then this
;           keyword is set on output to an NEDGREE + 1 x NDEGREE + 1 array
;           containing the coefficients of T^P, P = 0,...NDEGREE
;           for the NDEGREE + 1 orthonormal polynomials where T = (X - XAVG)/XRANGE.
;           The rows of QT correspond to the different polynomials so,
;           for example, a 3rd degree orthonormal polynomial is
;           ORPOLY(*,3) = QT[0,3] + QT[1,3]*T + QT[2,3]*T^2 + QT[3,3]*T^3
;
;        RMS:        Keyword set on output to a scalar corresponding to the
;           root mean square of the difference between the
;           polynomial fit and the input dependent variable vector.
;           This is the value that is minimized for a given NDEGREE.
;
;        STD:        Keyword set on output to a scalar corresponding to the
;           statistical standard deviation between the polynomial fit
;           and the input dependent variable Y-vector. For NDEGREE much less
;           than the length of Y, STD is approximately equal to RMS.
;           The optional output Sigma in POLY_FIT is equivalent to STD.
;
;   FIT:    If this keyword is present and non-zero then the return value
;           of the POLY_FIT_ORTHO is the polynomial fit, equivalent to YFIT.
;           The keyword FIT over-rides the keyword TYPE and the optional
;           output YFIT is removed from argument list (i.e. POLYVAR becomes
;           the fourth argument and SIGMA becomes the fifth argument).
;
;   DOUBLE: If this keyword is present and non-zero then calculations
;           are done in double precision and output is of type DOUBLE.
;
;  WARNMSSG: If this keyword is present and non-zero then warning messages
;           will be issued if the number of calculations, based on the size of  NDEGREE
;            and the number of data, is  very large. When this keyword is set the user has
;            the  opportunity  to stop the calculations and have POLY_FIT_ORTHO return
;            using the last calculated NDEGREE polynomial.
;
;  REPEAT CALL SEQUENCE: If POLY_FIT_ORTHO is called repeatedly with the same
;                        X-vector then the keyword ORPOLY should be set to a named
;                        variable, unaltered, throughout the calling sequence for
;                        optimum efficiency. This applies to TYPE = 0 (default).
;                        For repeat calls with the same X-vector and TYPE = 1 and/or
;                        keyword C_X specified then keywords ORPOLY and QX should
;                        be set to named variables, and if TYPE = 2 and/or C_T
;                        is specified then ORPOLY and QT should be named variables.
;
;
; COMMON BLOCKS:
COMMON RANDOM_SEED, SEED ; Used for calculating coefficient error estimates.
;
; SIDE EFFECTS:
;        None.
;
; MODIFICATION HISTORY:
;        MARCH, 1999: Written by James F. Howell, Research Systems, Inc.
;-

ERRNO=0 ; ERROR CATCHING CODE
CATCH,ERRNO
IF ERRNO NE 0 THEN BEGIN
   CATCH,/CANCEL
   HELP,/LAST_MESSAGE,OUTPUT=TRACEBACK
   MSSG=['Error Caught in POLY_FIT_ORTHO:',TRACEBACK,'Returning 0']
   A=DIALOG_MESSAGE(MSSG,/Error)
   RETURN,0
ENDIF

YY=Y & ND=LONG(NDEGREE[0]) ; SET INPUT TO LOCAL VARIABLES
NPTS=N_ELEMENTS(YY)
IF NPTS LE 0 THEN BEGIN ; MAKE SURE THERE IS AT LEAST A DATUM TO FIT
   B=DIALOG_MESSAGE(['Need at least two 1-element vectors X and Y',$
                     'for input to function POLY_FIT_ORTHO(X,Y,ND)',$
                     'Returning 0'],/Error)
   RETURN,0
ENDIF
XX=X[0:NPTS-1]
IF ND GE NPTS THEN ND=NPTS-1 ; EXACT FIT

KIN=KEYWORD_SET(XIN)  ; KEYWORD CHECKING AND INITIALIZATION
IF KEYWORD_SET(TYPE) THEN CASE TYPE[0] OF
   1: TYP = 1
   2: TYP = 2
   ELSE: TYP = 0
ENDCASE ELSE TYP = 0
IF KEYWORD_SET(FIT) THEN IF FIT NE 0 THEN FIT=1B ELSE FIT=0B ELSE FIT=0B
IF KEYWORD_SET(WM) THEN IF WM NE 0 THEN DM=1B ELSE DM=0B ELSE DM=0B
IF FIT THEN TYP=0
KCX=KEYWORD_SET(C_X)
IF TYP EQ 1 THEN KCX = 1
KCT=KEYWORD_SET(C_T)
IF TYP EQ 2 THEN KCT = 1
KQX=KEYWORD_SET(QX)
IF KCX OR TYP EQ 1 THEN KQX = 1
KQT=KEYWORD_SET(QT)
IF KCT OR TYP EQ 2 THEN KQT = 1
IF KEYWORD_SET(DOUBLE) THEN $
   IF DOUBLE NE 0 THEN BEGIN
   YY=DOUBLE(YY)
   XX=DOUBLE(XX)
   A=DOUBLE(NPTS)
ENDIF ELSE A=FLOAT(NPTS) ELSE A=FLOAT(NPTS)

XAVG=TOTAL(XX)/A  ; MAP X INTO THE (T) INTERVAL [-0.5,+0.5]
XRANGE=(MAX(XX)-MIN(XX))
IF XRANGE GT 0. THEN T=(XX-XAVG)/XRANGE ELSE BEGIN
   B=DIALOG_MESSAGE(['Invalid X range for POLY_FIT_ORTHO',$
                     'Returning 0'])
   RETURN,0
ENDELSE

IF KIN THEN BEGIN ; MAP XIN INTO THE (TIN) INTERVAL [-0.5,+0.5]
   NIN=N_ELEMENTS(XIN)
   TIN=(XIN-XAVG)/XRANGE
ENDIF

NEWPOLY=1 ; DO NEW POLYNOMIALS NEED TO BE CREATED
EPS = (A/A)*1.E-4
IF T[0] NE 0. AND T[NPTS-1] NE 0. THEN $
IF KEYWORD_SET(ORPOLY)  THEN BEGIN
   S=SIZE(ORPOLY)
   IF S[0] EQ 2 AND S[1] EQ NPTS AND S[2] GE ND+1 THEN IF $
      ORPOLY[0,0] EQ 1./SQRT(A) AND $
      ABS(ORPOLY[NPTS-1,1]/T[NPTS-1]-ORPOLY[0,1]/T[0]) LT EPS THEN $
      IF NOT KQX AND NOT KQT THEN NEWPOLY = 0 ELSE BEGIN
         NEW1 = 0 & NEW2 = 0
         IF KQX THEN BEGIN
            S=SIZE(QX)
            IF S[0] EQ 2 AND S[1] EQ S[2] AND S[2] GE ND+1 THEN IF $
               QX[0,0] EQ 1./SQRT(A) THEN NEW1=0 ELSE $
               NEW1 = 1 ELSE NEW1 = 1
         ENDIF
         IF KQT THEN BEGIN
            S=SIZE(QT)
            IF S[0] EQ 2 AND S[1] EQ S[2] AND S[2] GE ND+1 THEN IF $
               QT[0,0] EQ 1./SQRT(A) THEN NEW2=0 ELSE $
               NEW2 = 1 ELSE NEW2 = 1
         ENDIF
         NEWPOLY = MAX([NEW1,NEW2])
      ENDELSE
ENDIF
IF KIN AND NOT NEWPOLY THEN BEGIN
   NEWPOLY=1
   IF KEYWORD_SET(INPOLY) THEN BEGIN
      S=SIZE(INPOLY)
      IF S[0] EQ 2 AND S[1] EQ NIN AND S[2] GE ND+1 THEN IF $
      INPOLY[0,0] EQ 1./SQRT(A) AND $
      ABS(INPOLY[NPTS-1,1]/TIN[NPTS-1] - $
          INPOLY[0,1]/TIN[0]) LT EPS THEN NEWPOLY=0
   ENDIF
ENDIF

IF ND LE 0 THEN BEGIN  ; SPECIAL CASE WHEN ND=0
   YAVG=TOTAL(YY)/A
   YFIT=YAVG + FLTARR(NPTS)
   C_O=[YAVG*SQRT(A)] & C_X=[YAVG] & C_T=C_X
   IF NEWPOLY THEN ORPOLY=1./SQRT(A)+FLTARR(NPTS,1)
   IF KIN THEN YIN=YAVG + FLTARR(NIN,1)
   IF KIN AND NEWPOLY THEN INPOLY=1./SQRT(A)+FLTARR(NIN)
   QX=ORPOLY[*,0] & QT=QX
   POLYVAR=[C_O[0]*C_O[0]]
   RMS=SQRT(TOTAL((Y-YAVG)^2)/A)
   STD=RMS & SIGMA=[2.*STD/SQRT(NPTS)]
   IF FIT THEN BEGIN
      RET=YFIT
      YFIT=POLYVAR & POLYVAR=SIGMA
      RETURN,RET ; RETURN AVERAGE VALUE VECTOR
   ENDIF
   CASE TYP OF
        0: RETURN, [C_O]
        1: RETURN, [C_X]
        2: RETURN, [C_T]
   ENDCASE
ENDIF

IF DM AND NEWPOLY THEN BEGIN  ; LAST CHECK BEFORE CREATING POLYNOMIALS
IF ND*NPTS GE 1.E5 AND ND*NPTS LT 1.E6 AND ND GE 50 THEN BEGIN
   MSSG=['POLY_FIT_ORTHO: requirements very large.',$
         'Suggest reducing NPTS or NDEGREE','CONTINUE?']
   TXT=DIALOG_MESSAGE(MSSG,/QUESTION)
   IF TXT EQ 'No' THEN RETURN,0
ENDIF

IF ND*NPTS GE 1.E6  AND ND*NPTS LT 1.E7 AND ND GE 25 THEN BEGIN
   MSSG=['POLY_FIT_ORTHO: requirements extremely large.',$
         'Strongly suggest reducing NPTS or NDEGREE','CONTINUE?']
   TXT=DIALOG_MESSAGE(MSSG,/QUESTION)
   IF TXT EQ 'No' THEN RETURN,0
ENDIF

IF ND*NPTS GE 1.E7 AND ND GT 12 THEN BEGIN
   MSSG=['POLY_FIT_ORTHO: requirements possibly too large.',$
         'Should probably reduce NPTS or NDEGREE','CONTINUE?']
   TXT=DIALOG_MESSAGE(MSSG,/QUESTION)
   IF TXT EQ 'No' THEN RETURN,0
ENDIF
ENDIF

IF NEWPOLY THEN BEGIN    ; BEGIN POLYNOMIAL CREATION BLOCK

ORPOLY=FLTARR(NPTS,ND+1)+1./SQRT(A) ; INITIALIZE POLYNOMIALS.
IF KIN THEN INPOLY=FLTARR(NIN,ND+1)+1./SQRT(A)
IF KQX THEN  BEGIN
   QX=(A/A)*FLTARR(ND+1,ND+1)
   QX[0,0]=1./SQRT(A)
ENDIF
IF KQT THEN BEGIN
   QT=(A/A)*FLTARR(ND+1,ND+1)
   QT[0,0]=1./SQRT(A)
ENDIF

TIME_BEGIN=SYSTIME[1] & TIME_TEST=2. & NOMORE=0B & MSSGCNT=0B
NDSV=ND
FOR I=1,ND DO BEGIN  ; CONSTRUCTING POLYNOMIAL VECTORS
    IF NOMORE THEN GOTO,SKIP_POLY_CONSTRUCTION
    ORPOLY[*,I]=T*ORPOLY[*,I-1]  ; NON-ORTHOGONAL POLYNOMIALS
    IF KIN THEN INPOLY[*,I]=TIN*INPOLY[*,I-1]
    IF KQX THEN BEGIN
       QX[0,I]=-XAVG*QX[0,I-1]/XRANGE
       FOR J=1,I-1 DO QX[J,I]=(QX[J-1,I-1]-XAVG*QX[J,I-1])/XRANGE
       QX[I,I]=QX[I-1,I-1]/XRANGE
    ENDIF
    IF KQT THEN FOR J=1,I DO QT[J,I]=QT[J-1,I-1]

    FOR K=0,I-1 DO BEGIN  ;  GRAM-SCHMIDT ORTHOGONALIZATION
        CIK=TOTAL(ORPOLY[*,I]*ORPOLY[*,K])
        ORPOLY[*,I]=ORPOLY[*,I]-CIK*ORPOLY[*,K]
        IF KIN THEN INPOLY[*,I]=INPOLY[*,I]-CIK*INPOLY[*,K]
        IF KQX THEN QX[*,I]=QX[*,I]-CIK*QX[*,K]
        IF KQT THEN QT[*,I]=QT[*,I]-CIK*QT[*,K]
    ENDFOR

    PMAG=SQRT(TOTAL(ORPOLY[*,I]^2))  ; NORMALIZING
    ORPOLY[*,I]=ORPOLY[*,I]/PMAG
    IF KIN THEN INPOLY[*,I]=INPOLY[*,I]/PMAG
    IF KQX THEN QX[*,I]=QX[*,I]/PMAG
    IF KQT THEN QT[*,I]=QT[*,I]/PMAG

    IF DM THEN BEGIN
       PCNT_DONE=100.*FLOAT(I)/ND
       IF PCNT_DONE LT 80. THEN $
       IF SYSTIME[1] - TIME_BEGIN GE TIME_TEST THEN BEGIN
          MSSGCNT=MSSGCNT+1
          MSSG0='The function POLY_FIT_ORTHO is approximately '+$
          STRCOMPRESS(STRING(PCNT_DONE),/REMOVE_ALL)+'%  done.'
          MSSG1='CONTINUE calculations?        CANCEL this message?'
          TXT=DIALOG_MESSAGE([MSSG0,MSSG1],/QUESTION,/CANCEL)
          IF TXT EQ 'Cancel' THEN BEGIN
              TXT2=DIALOG_MESSAGE(['Canceling this message means no more',$
                                                           'opportunities to cleanly halt this process. ',$
                                                           'Do you still want to cancel?'],/question)
              IF TXT2 EQ 'Yes' THEN DM = 0B
          ENDIF
          IF TXT EQ 'No' THEN BEGIN
             NOMORE=1B & NDSV=I
          ENDIF
          TIME_TEST=SYSTIME[1] - TIME_BEGIN + MSSGCNT*4.
       ENDIF
    ENDIF
    SKIP_POLY_CONSTRUCTION: JJ=0B
ENDFOR & ND=NDSV & NDEGREE=ND

ENDIF  ;  END POLYNOMIAL CREATION BLOCK

C_O = REFORM(YY#ORPOLY[*,0:ND]) ; COEFFICIENTS OF ORTHONORMAL POLYNOMIALS

YFIT = ORPOLY[*,0:ND]#C_O ; POLYNOMIAL FIT

IF KCX THEN C_X = QX[0:ND,0:ND]#C_O ;  COEFFICIENTS OF X^0,...,X^(ND)

IF KCT THEN C_T = QT[0:ND,0:ND]#C_O ;  COEFFICIENTS OF T^0,...,T^(ND)

IF KIN THEN YIN = INPOLY[*,0:ND]#C_O  ; POLYNOMIAL FIT AT XIN

RMS = SQRT(TOTAL((YFIT-YY)^2)/A)  ; RMS DIFFERENCE

IF ND LT NPTS-1 THEN $  ; STANDARD DEVIATION
   STD = SQRT(TOTAL((YFIT-YY)^2)/(NPTS-ND-1)) ELSE STD = 0.

CC=C_O * C_O / (A-1)                   ; SQUARE OF AVERAGE COEFFICIENT VALUES
POLYVAR=FLTARR(ND+1)+CC[0]              ; SQUARE OF AVERAGE Y VALUE
FOR J=1,ND DO POLYVAR[J]=TOTAL(CC[1:J]) ; RECOMPOSING SUM OF SQUARES

IF N_PARAMS() GT 5 THEN BEGIN
   SEED=1000.*RANDOMU(SEED)   ; RANDOM INITIAL SEED
   BETA = 0.1                 ; SIGMA CALCULATION: EVALUATE BETA*NPTS
   M= LONG(BETA * NPTS)         ;  M REALIZATIONS WITH M Y VALUES PERTURBED
   IF M LT 2 THEN M = 2         ; M IS AT LEAST 2
   SUM=A*FLTARR(ND+1)           ; SUM ARRAY TO STORE SUM OF SQUARES
   YSCALE=SQRT(RMS*RMS+POLYVAR[ND]) ; SCALE FOR PERTURBATIONS
   FOR I=1,M DO BEGIN
      N = LONG(RANDOMU(SEED,M) * NPTS) ; RANDOM POINTS SELECTED
      YTST = YY & P = (-1.)^N * YSCALE ; PERTURBATIONS
      YTST[N] = YTST[N] + P  ; PERTURBATION VECTOR
      CASE TYP OF
           0: SUM=SUM + (REFORM(YTST#ORPOLY[*,0:ND]) - C_O)^2
           1: SUM=SUM + ((QX[0:ND,0:ND] # REFORM(YTST#ORPOLY[*,0:ND])) - C_X)^2
           2: SUM=SUM + ((QT[0:ND,0:ND] # REFORM(YTST#ORPOLY[*,0:ND])) - C_T)^2
      ENDCASE
   ENDFOR
   SIGMA = 2. * SQRT( SUM / (M-1) ) / SQRT(M) ; NORMAL ERROR ESTIMATE
ENDIF

IF FIT THEN BEGIN
   RET=YFIT
   YFIT=POLYVAR & IF N_PARAMS() GT 5 THEN POLYVAR=SIGMA
   RETURN,RET ; RETURN POLYNOMIAL FIT
END
CASE TYP OF          ;  RETURN COEFFICIENTS
     0: RETURN, C_O
     1: RETURN, C_X
     2: RETURN, C_T
ENDCASE

END ; END POLY_FIT_ORTHO

