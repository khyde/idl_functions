; $ID:	REGRESSION_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

PRO REGRESSION_DEMO ,x,y,a0,coeff
;+
; NAME:
;       REGRESSION_DEMO
;
; PURPOSE:
;       Demonstrate graphically the
;       results from three regression
;       programs:
;        regression.pro
;        f_regres.pro
;        poly_fit.pro
;
; CATEGORY:
;       Statistics.
;
; CALLING SEQUENCE:
;       REGRESSION_DEMO
;
; INPUTS:
;       Uses: regression.pro
;             stats.pro
;             f_regres.pro
;             poly_fit.pro
;
; KEYWORD PARAMETERS:
;       none.
; OUTPUTS:
;       Graph.
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
;       Written by:  J.E.O'Reilly, Feb, 1995.
;-
    LOADCT,12,/SILENT

;  ===================================>
;  Generate variables x and y
   x = FINDGEN(500)
   x =    x  +  35* RANDOMU(s,n_elements(x))
   y =    x  +  77* RANDOMN(s,n_elements(x))
   max_val = max([x,y])



;  =====================================================================>
;  Least Squares-Y Linear Regression:
   REGRESSION,x,y,W,a0,coeff,resid,yfit,sigma,ftest,r,rmul,chksqr,/noprint
   print,'Method:            Y_int    Slope    Correlation'
   print,'------------------------------------------------------'
   print,'LSY  =         ', a0,coeff,r,$
          format='(A16,4f10.6)'



   PLOT, x,y,psym=2,color=255  ,$
         xrange=[0,max_val],yrange=[0,max_val],$
         TITLE='Linear Regression using REGRESSION, F_REGRES, and POLY_FIT',$
         CHARSIZE=.75
   oplot, x,yfit

;  Label Plot
   text = 'R = '+ STRTRIM(STRING(R),2)
   XYOUTS,0.2,0.9,text,/NORMAL

   XYOUTS,0.2,0.85,'REGRESSION.PRO',COLOR=255,/NORMAL




;  ====================>
;  Functional Regression
   XX = STATS(x,MISSING=-9)
   YY = STATS(y,MISSING=-9)

   f_reg = F_REGRES(XX.MEAN,YY.MEAN,A0,COEFF,R,-9)
   RMS = RMS(x,y,MISSING=-9)
   print,'f_regres(jor) =', f_reg.intercept,f_reg.slope,$
          format='(A16,2f10.6)'

   oplot, x, (f_reg.intercept + f_reg.slope*x),color=64
   XYOUTS,0.2,0.8,'F_REGRES.PRO',COLOR=64,/NORMAL

;  ===================================================>
;  Polynomial Regression:
   coefficients = POLY_FIT(X, Y, 1 ,Yfit, Yband, Sigma, A )
;
; INPUTS:
;       X:      The independent variable vector.
;       Y:      The dependent variable vector, should be same length as x.
;     NDegree:  The degree of the polynomial to fit.
; OUTPUTS:
;       POLY_FIT returns a vector of coefficients with a length of NDegree+1.
; OPTIONAL OUTPUT PARAMETERS:
;       Yfit:   The vector of calculated Y's.  These values have an error
;               of + or - Yband.
;       Yband:  Error estimate for each point = 1 sigma
;       Sigma:  The standard deviation in Y units.
;       A:      Correlation matrix of the coefficients.

  print,'poly_fit(n=1) =', coefficients[0],coefficients[1],$
         format='(A16,2f10.6)'

  oplot, x, yfit ,psym=4,color=128
   XYOUTS,0.2,0.75,'POLY_FIT.PRO = Boxes',COLOR=128,/NORMAL

; ====================>
; Now run program SIXLIN
; Six linear Regression Statistics from IDLGSFC.GSFC.NASA (sixlin.pro) in pub directory
;  [0] Ordinary Least Squares (OLS) Y vs. X
; [1] Ordinary Least Squares  X vs. Y
; (2) Ordinary Least Squares Bisector
; (3) Orthogonal Reduced Major Axis
; (4) Reduced Major-Axis
; (5) Mean ordinary Least Squares
sixlin,x,y,a,siga,b,sigb
PRINT, A,B
print, 'siga',siga
print, 'sigb',sigb




; ************************************
   END
