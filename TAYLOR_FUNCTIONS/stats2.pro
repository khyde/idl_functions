; $Id:	stats2.pro,	May 27 2007	$

FUNCTION STATS2, X, Y,$
 								 MODEL = MODEL,$
 								 LABEL=LABEL,$
                 XMISSING=xmissing, YMISSING=ymissing,$
                 PARAMS=params,  		DECIMALS=decimals,$

                 FILE=file,$
                 APPEND=append,$
                 NO_HEADING=no_heading,$

                 DOUBLE_SPACE=double_space,$
                 FAST=fast,$
                 SHOW=SHOW,$
                 ERROR=ERROR,$
                 _EXTRA=_extra

;+
; NAME:
;		STATS2
;
; PURPOSE:
;		Computes Regression Statistics:
;			N
; 		Intercept
;			Slope
;			Std_Intercept
;			Std_slope
;			R (correlation coefficient)
;			Rsq (r squared)
;			Cov (Covariance)
;			RMS (root mean squared deviation)
;			Bias
;			Mean_X
;			Mean_Y
; 		Y_absdev
;
;			Using NASA GSFC program SIXLIN.PRO
;			for 6 linear regression models, plus IDL Program Ladfit ("robust" least absolute deviation method)::
;		 	And returns the results in a structure for subsequent use
;
; CATEGORY:
; 	STATISTICS
;
; CALLING SEQUENCE:
;		X = FINDGEN(21) & Y=  X + RANDOMU(SEED,21)
;		Result = STATS2(X,Y)
;
; EXAMPLES:
;		Result = STATS2(FINDGEN(30),FINDGEN(30)+RANDOMN(SEED,30))
;		PRINT, Result
;		HELP,/STRU,Result(4)

;		Result = STATS2(X,Y, xmissing = -9,/SHOW)
;		Result = STATS2(x,y, params=[0,1,4,2,3])             ; Model,N,Rsq,Slope,Intercept
;		Result = STATS2(x,y, params=[1,2,3])               ; Model,N,Slope,Intercept
;		Result = STATS2(x,y, params=[0,4,5,2,3])    ; MODEL,Slope,RSQ,N,Intercept
;		Result = STATS2(x,y, params=[0,4,5,2,3],DECIMALS=3); MODEL,Slope,RSQ,N,Intercept
;                                         (Numbers in tag STATSTRING have 3 decimal places)
;
; INPUTS:
;		An X and Y Array of same size
;
; KEYWORD PARAMETERS:
;
;		XMISSING:	Value for missing X data (This value will be excluded from the statistics).
;   YMISSING:	Value for missing Y data (This value will be excluded from the statistics).
;
;   MODEL: The Regression Model(s) (e.g. MODEL='LSY', or MODEL='RMA')
;
;			LSY:	LEAST SQUARES Y
;			LSX:	LEAST SQUARES X
;			LSB:	LEAST SQUARES BISECTOR
;			ORMA:	ORTHOGONAL REDUCED MAJOR AXIS
;			RMA:	REDUCED MAJOR AXIS (FUNCTIONAL REGRESSION)
;			MLS:	MEAN LEAST SQUARES
;			RLAD:	ROBUST LEAST ABSOLUTE DEVIATION (IDL'S LADFIT.PRO)

;		PARAMS:	A vector indicating which statistical results
;						will be placed into the tag string variable: STATSTRING
;           for subsequent use by the program calling STATS2
;           (Note the user may specify values for PARAMS in any order).
;			0:	Model Name (Full name of the regression model)
;			1:	Model (short name)
;			2:	N
;			3:	Intercept
;			4:	Slope
;			5:	Std_Intercept
;			6:	Std_slope
;			7:	R
;			8:	Rsq (r squared)
;			9:	Cov (Covariance)
;			10:	RMS (root mean squared deviation)
;			11:	BIAS
;			12:	Mean_X
;			13:	Mean_Y
;			14:	Y_ABSDEV
;			15:	DATE
;			16:	LABEL
;
;		DECIMALS:	Number of desired decimal places to use in making the STATSTRING Tag.
;           	Tag STATSTRING is useful when combined with an XYOUTS command.
;          		Decimals only applies to the formatting of the statistics in STATSTRING.
;							(The statistics in the returned structure have full precision)
;
;		MODEL:	Narrows the statistical output to a particular model
;         	(e.g. MODEL='LSY', or MODEL='RMA' or MODEL = ['LSY','RMA']

;
;		FILE:		Full name of the file to write all statistical results
;
;		APPEND:	Appends (Writes) statistics to existing file
;
;		NO_HEADING:	Supresses heading
;
;		LABEL:	User may add text string identifying subset or any other identifier which will be added to
;						each record (line) of the statistical output
;
;
;		DOUBLE_SPACE:	Places an extra line space between formatted statistics in STATSTRING.
;
;		SHOW:	Prints statistics to the standard IDL Command Log Output Window
;
;
; OUTPUTS:
;		A structure containing the various statistics:
;			N = number of x,y,pairs
;			Intercepts,slopes,standard deviations of intercepts and slope coefficients
;			Correlation Coefficient Squared, Covariance,
;			RMS (Root Mean Square Deviation)
;
;
; RESTRICTIONS:
;		The Default for the FORMAT used in this routine to make the STATSTRING is	5 significant digits.
;		(FORMAT='(G-0.5)').  You may obtain more precision by using the KEYWORD DECIMALS (e.g. DECIMALS=7)
;		This program prevents DECIMALS from exceeding 14 (a reasonable precision for double-precision data)
;
;		LABEL MAY NOT have any commas.  This routine substitutes any commas in the LABEL with ';'.
;
; ====================>
; Other Programs called:
; 	NASA GSFC SIXLIN.PRO is called to obtain regression intercepts,slopes,siga,sigb
; 	NOAA NARR RMS.PRO    is called to obtain RMS
; 	NOAA NARR STATS.PRO  is called to obtain MEANS
; 	IDL PROGRAM CORRELATE.PRO is called to obtain correlation coefficient and covariance
;
; MODIFICATION HISTORY:
;		Written August 6,1996, J.E. O'Reilly, NOAA, Narragansett, RI
;		Revised August 8,1996  J.O'R Added PARAMS
;		Revised January 6,1997, J.O'R Added IDL's LADFIT.PRO (Robust Least Absolution Deviation)
;		Revised January 9, 1997,J.O'R Added BIAS
;		Revised August  26,1998,J.O'R Added correlation coefficient
;		Revised September 14,1998     Added keyword DOUBLE_SPACE
;		Revised Jan 3, 2007 JOR Eliminated keyword QUIET, now using SHOW.
;														Chanced tagname "TYPE_" to "MODEL"
;														Now use model names to specify models, not numbers
;														Statistics are written to a comma-delimited text file.
;-

;	****************************************************************************************************
	ROUTINE_NAME = 'STATS2'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

; ===>Define missing value for double precision data (!VALUES.D_INFINITY)
  missing = MISSINGS(0.0D)

;	===> Get EPS (Precision of double-precision values)
  SS=MACHAR() & EPS=SS.EPS

; ===> Linespace: Normally each statistic in statstring will be plotted on its own line (when using the XYOUTS)
  IF NOT KEYWORD_SET(double_space) THEN linespace = '!C' ELSE linespace = '!C!C'

;	===> User provided LABEL are added to the stats strucure
	IF N_ELEMENTS(LABEL) EQ 1 THEN _LABEL = LABEL ELSE _LABEL = ''

; ===> Make a STRUCTURE to hold the statistical results
  STATS2_ = {MODEL_NAME:'',$
  					Model:'',$
            N:0L, $
            INT:missing,$
            slope:missing,$
            Std_INT:missing,$
            Std_Slope:missing,$
            r:missing,$
            Rsq:missing,$
            COV:missing,$
            RMS:missing,$
            BIAS:missing, $
            Mean_X:missing,$
            Mean_Y:missing,$
            Y_ABSDEV:missing,$
            MODEL_NUM:'',$
            DATE:'',$
            LABEL: _LABEL,$
            statstring:''}



;	*********************************
;	*** C A T C H    E R R O R S  ***
;	*********************************
	CATCH, Error_Status
   IF Error_Status NE 0 THEN BEGIN
    ERROR = !ERROR_STATE.MSG
   	CATCH, /CANCEL
   	RETURN,_STATS
   ENDIF

; ===> X and Y must be present and be the same size
  IF N_ELEMENTS(X) NE N_ELEMENTS(Y) OR N_ELEMENTS(X) LE 1 THEN BEGIN
    ERROR = 'ERROR: X AND Y ARRAYS MUST EACH BE 2 OR MORE ELEMENTS AND MUST BE THE SAME SIZE'
    RETURN,STATS2_
  ENDIF

	TAGNAMES=TAG_NAMES(STATS2_)
  NTAGS = N_ELEMENTS(TAGNAMES)

;	===> Replace any '_' in the tagnames with space
	TAGNAMES_CAP = REPLACE(tagnames,'_',' ')

;	===> Capitalize first letters of all words
  TAGNAMES_CAP = STR_CAP(TAGNAMES_CAP,/ALL)


; ===> Copy X and Y (This keeps original input arrays unchanged)
  xarray= X
  yarray= Y

; ===> Check keyword xmissing (not provided then xmissing = !VALUES.D_INFINITY
  IF N_ELEMENTS(xmissing) EQ 0 THEN BEGIN
    xmissing = missing  ; INFINITY (DOUBLE PRECISION)
  ENDIF ELSE BEGIN
    xmissing = DOUBLE(xmissing)
  ENDELSE

; ===> Check keyword ymissing (not provided then ymissing = !VALUES.D_INFINITY
  IF N_ELEMENTS(ymissing) EQ 0 THEN BEGIN
    ymissing = missing  ; INFINITY (DOUBLE PRECISION)
  ENDIF ELSE BEGIN
    ymissing = DOUBLE(ymissing)
  ENDELSE

; ===> Find good data values (not equal to missing values or Infinity or NAN)
  ok	= WHERE(xarray NE xmissing  AND FINITE(xarray) $
  			AND yarray NE ymissing  	AND FINITE(yarray),count)

;	===> Must have at least 2 pairs
  IF count GE 2 THEN BEGIN
    xarray =  xarray(OK)
    yarray =  yarray(OK)
  ENDIF ELSE BEGIN
		ERROR = 'ERROR: X AND Y ARRAYS DO NOT HAVE TWO OR MORE NON-MISSING VALUES'
    RETURN,STATS2_
	ENDELSE

; ===> Default format for statistics is 5 significant digits
	FORMAT_STATSTRING='(G-0.5)'

; ===> Check keyword DECIMALS
  IF N_ELEMENTS(DECIMALS) EQ 1 THEN BEGIN
    IF DECIMALS GE 1 AND DECIMALS LE 14 THEN FORMAT_STATSTRING='(D-0.'+ STRTRIM(DECIMALS,2) + ')'
  ENDIF

; ********************************
;	*** Fill the Stats Structure ***
; ********************************

;	===> Replicate Stats structure to hold results from the 7 regression models
  STATS2_ = REPLICATE(STATS2_,7)

  STATS2_.MODEL = ['LSY','LSX','LSB','ORMA','RMA','MLS','RLAD']

	STATS2_.MODEL_NUM = ['0','1','2','3','4','5','6']

	STATS2_.MODEL_NAME = ['Least Squares Y', 'Least Squares X', 'Least Squares Bisector',$
												'Orthogonal Reduced Major Axis', 'Reduced Major Axis',$
												'Mean Least Squares', 'Robuxt Lad Fit']

	STATS2_.DATE = DATE_NOW()


  n = N_ELEMENTS(xarray)
  s = SIZE(xarray)
  IF  n EQ 1 AND s(0) EQ 0 THEN  n = 0
	IF  n EQ 1 AND xarray(0) EQ MISSING THEN BEGIN
  	n = 0
   	STATS2_.n = n
  ENDIF




  IF KEYWORD_SET(FAST) THEN BEGIN
;   THE FOLLOWING CODE IS COPIED FROM GSFC SIXLINE.PRO
    a = dblarr(6) & b=a
    rn = N_elements(xarray)
    if rn LT 2 THEN message,'Input X and Y vectors must contain at least 2 data points'
    if rn NE N_elements(yarray) then message,'Input X and Y vectors must contain equal number of data points'

;   Compute averages and sums

    xavg = total(xARRAY)/rn
    yavg = total(yARRAY)/rn
    x = xarray - xavg
    y = yarray - yavg
    sxx = total(x^2)
    syy = total(y^2)
    sxy = total(x*y)
    if sxy EQ 0. then message,'SXY is zero, STATS2 is terminated'
    if sxy LT 0. then sign = -1.0 else sign = 1.0

;   Compute the slope coefficients

    b[0] = sxy / sxx
    b[1] = syy / sxy
    b[2] = (b[0]*b[1] - 1.D + sqrt((1.D + b[0]^2)*(1.D +b[1]^2)))/(b[0] + b[1] )
    b[3] = 0.5 * ( b[1] - 1.D/b[0] + sign*sqrt(4.0D + (b[1]-1.0/b[0])^2))
    b[4] = sign*sqrt( b[0]*b[1] )
    b[5] = 0.5 * ( b[0] + b[1] )
     STATS2_(0:5).slope = b
;   Compute Intercept Coefficients
    a = yavg - b*xavg
    STATS2_(0:5).int = a

;   ===> Get RMS
    _rms  = RMS(xarray,yarray)
    STATS2_.rms= _rms.rms

    STATS2_.N = rN
    STATS2_.r = CORRELATE(xarray,yarray)
    STATS2_.rsq =  STATS2_.r ^2
    GOTO, SKIP_SLOW

  ENDIF


; **********************************************************************
; IF NOT TOO MANY POINTS THEN PROCEED HERE

  CASE 1 OF
    (n GE 2): BEGIN      ; SIXLIN must have at least 2 x y pairs
     STATS2_.n = n

;    ===> Get the Mean x and Mean y
     XX = XARRAY & YY = YARRAY
     STATSX = STATS(XX,LABEL='X: '+_LABEL,SHOW=SHOW)
     STATSY = STATS(YY,LABEL='Y: '+_LABEL,SHOW=SHOW)

     STATS2_.MEAN_X = STATSX.MEAN
     STATS2_.MEAN_Y = STATSY.MEAN

;    ===> Call Correlate
     R   =  CORRELATE(xarray,yarray)

     STATS2_.r   = r
     STATS2_.rsq = r^2

;    ===> Call Correlate again to get covariance
     cov = CORRELATE(xarray,yarray,/COVARIANCE)
     STATS2_.cov = cov

;    ===> Call RMS program
     rms  =RMS(xarray,yarray)
     STATS2_.rms= rms.rms

;    ===> Compute Bias
     STATS2_.bias= TOTAL(yarray-xarray)/n

;    ===> Call NASA GSFC SIXLIN
     SIXLIN,xarray,yarray,intercept,siga,slope,sigb


;    ===> Call IDL's LADFIT
;		 LADFIT HANGS IF XARRAY AND YARRAY ARE IDENTICAL OR IDENTICALLY PROPORTIONAL
		 IF R ge (1.d - 2*eps) or R le (1.d + 2*eps) THEN BEGIN ; ALL INTERCEPTS AND SLOPES are same if correlation = 1.000000000
		 	lad = [INTERCEPT(0),SLOPE(0)] & absdev = 0.0
		 ENDIF ELSE BEGIN
     	lad = LADFIT(xarray,yarray, absdev=absdev,/DOUBLE)
		 ENDELSE

;    ===> Fill the STATS structure with results from all regression models in SIXLIN and results from LATFIT
     STATS2_(0:5).INT				= intercept(*)
     STATS2_(0:5).SLOPE   	= slope(*)
     STATS2_(0:5).STD_INT		=	siga(*)
     STATS2_(0:5).STD_slope	=	sigb(*)
     STATS2_(6).INT      		= lad(0)
     STATS2_(6).SLOPE    		= lad(1)
     STATS2_(6).Y_ABSDEV 		= absdev

     ENDCASE

    ( n LT 2): BEGIN
      STATS2_.n = n
      ERROR = 'N is less than 2'
     ENDCASE

   ENDCASE

;  ===> If KEYWORD_SET(FAST) then the minimum set of statistics were done and come to SKIP_SLOW
   SKIP_SLOW:


;	===> Subset STATS2_ for the statistical models (MODEL) choosen
 	IF N_ELEMENTS(MODEL) GE 1  THEN BEGIN
 		OK_MODEL = WHERE(STATS2_.MODEL EQ STRUPCASE(MODEL),COUNT_MODEL)
 		IF COUNT_MODEL GE 1 THEN STATS2_ = STATS2_(OK_MODEL)
	ENDIF ; ELSE incorrect model names and ALL 7 MODELS WILL REMAIN IN THE STATS2_


;	===> Default is to fill the statstring with all statistical results
  IF N_ELEMENTS(PARAMS) EQ 0 THEN BEGIN
  	PARAMS=INDGEN(NTAGS)
	ENDIF ELSE BEGIN
;		===> Find all but statstring
    ok = WHERE(PARAMS GE 0 AND PARAMS LE (NTAGS-2),count)
    IF COUNT GE 1 THEN PARAMS = PARAMS(ok) ELSE PARAMS=INDGEN(NTAGS-1)
  ENDELSE


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR NTH = 0,N_ELEMENTS(params)-1 DO BEGIN
  	_param = params(NTH)
  	IF _param LE 1 THEN STATS2_.statstring = STATS2_.statstring+ linespace+ STRTRIM(STATS2_.(_param),2)
    IF _param EQ 2 THEN STATS2_.statstring = STATS2_.statstring+ linespace + TAGNAMES_CAP(_param) + ': ' + STRTRIM(STRING(STATS2_.(_param),FORMAT='(I)'),2)
    IF _param GE 3 AND _param LT NTAGS-2 THEN STATS2_.statstring = STATS2_.statstring+ linespace + TAGNAMES_CAP(_param) + ': ' + STRTRIM(STRING(STATS2_.(_param),FORMAT=FORMAT_STATSTRING),2)

  ENDFOR


;	===> Prepare the heading for printed output
	DELIM=","
	TARGETS = [1,2,3,4,5,6,7,8,9,10,11,12,13,14]
	NAMES = [TAGNAMES_CAP(TARGETS),_LABEL]
	NAMES = STRJOIN(NAMES+DELIM)

; ===> Open a file for writing statistical results
  IF KEYWORD_SET(FILE) THEN BEGIN
;   If Keyword APPEND is set then add to the file
;   otherwise, open a NEW file (rewrite)
    IF KEYWORD_SET(append) THEN OPENU,lun,FILE,/GET_LUN,/APPEND ELSE $
                                OPENW,lun,FILE,/GET_LUN


		IF NOT KEYWORD_SET(NO_HEADING) THEN PRINTF,lun,NAMES

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR i = 0,N_ELEMENTS(STATS2_) -1 DO BEGIN
		 PRINTF,lun,	STATS2_(i).(0),DELIM, $
		 							STATS2_(i).(1),DELIM, $
	                 STATS2_(i).(2),DELIM, $
	                 STATS2_(i).(3),DELIM, $
	                 STATS2_(i).(4),DELIM, $
	                 STATS2_(i).(5),DELIM, $
	                 STATS2_(i).(6),DELIM, $
	                 STATS2_(i).(7),DELIM, $
	                 STATS2_(i).(8),DELIM, $
	                 STATS2_(i).(9),DELIM, $
	                 STATS2_(i).(10),DELIM, $
	                 STATS2_(i).(11),DELIM, $
	                 STATS2_(i).(12),DELIM, $
	                 STATS2_(i).(13),DELIM, $
	                 STATS2_(i).(14),DELIM, $
	                 STATS2_(i).(15),DELIM, $
	                 STATS2_(i).(16),DELIM, $
	                 STATS2_(i).(17),DELIM, $
                 FORMAT='(A4,A,I10,A,15(G16.8,A),A,A)'
    ENDFOR
    CLOSE,LUN
    FREE_LUN,LUN
  ENDIF

 IF KEYWORD_SET(SHOW) THEN BEGIN
;   If Keyword APPEND is set then add to the file
;   otherwise, open a NEW file (rewrite)

		IF NOT KEYWORD_SET(NO_HEADING) THEN PRINT,NAMES

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR i = 0,N_ELEMENTS(STATS2_) -1 DO BEGIN
			 PRINT,			STATS2_(i).(0),DELIM, $
		 							STATS2_(i).(1),DELIM, $
	                 STATS2_(i).(2),DELIM, $
	                 STATS2_(i).(3),DELIM, $
	                 STATS2_(i).(4),DELIM, $
	                 STATS2_(i).(5),DELIM, $
	                 STATS2_(i).(6),DELIM, $
	                 STATS2_(i).(7),DELIM, $
	                 STATS2_(i).(8),DELIM, $
	                 STATS2_(i).(9),DELIM, $
	                 STATS2_(i).(10),DELIM, $
	                 STATS2_(i).(11),DELIM, $
	                 STATS2_(i).(12),DELIM, $
	                 STATS2_(i).(13),DELIM, $
	                 STATS2_(i).(14),DELIM, $
	                 STATS2_(i).(15),DELIM, $
	                 STATS2_(i).(16),DELIM, $
	                 STATS2_(i).(17),DELIM, $
                 FORMAT='(A4,A,I10,A,15(G16.8,A),A,A)'
    ENDFOR

  ENDIF


  RETURN, STATS2_

END; #####################  End of Routine ################################

