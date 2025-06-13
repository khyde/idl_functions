; $ID:	ROBUST_LINEFITJ.PRO,	2020-07-08-15,	USER-KJWH	$
; MODIFIED BY J.O'Reilly to perform ROBUST functional regression instead of ROBUST least squares y

;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    ROBUST_LINEFIT is an outlier-resistant straight-line fit.
;
;NAME:
; ROBUST_LINEFIT
;
;PURPOSE:
; An outlier-resistant straight-line fit.
;
;CALLING SEQUENCE:
; COEFF = ROBUST_LINEFIT(X,Y, YFIT,SS,CHI)
;
;INPUTS:
; X = Independent variable vector, floating-point or double-precision
; Y = Dependent variable vector
;
;OUTPUTS:
; Function result = coefficient vector
; Either floating point or double precision.
;
;OPTIONAL OUTPUT PARAMETERS:
; YFIT = Vector of calculated y's
; SS   = The estimated standard deviations of the coefficients
; CHI  = The CHI-square of the fit.
;
;SUBROUTINE CALLS:
; MED, to calculate the median
;
;PROCEDURE:
; For the initial estimate, the data is sorted by X and broken into 2
; groups. A line is fitted to the x and y medians of each group.
; Bisquare ("Tukey's Biweight") weights are then calculated, using the

; interquartile range as the measure of dispersion and a limit of 6
; standard deviations.
; This is done iteratively until the chi-square, also calculated using
; biweights, begins to grow or changes by less than CLOSE_ENOUGH, now set
; .0002.
;
;AUTHOR: H. Freudenreich, STX, 4/91.
;; MODIFIED Aug 30,2000 BY J.O'Reilly to perform ROBUST functional regression instead of ROBUST least squares y
;-
function  robust_linefitj,xin,yin,yfit,ss,chi

;close_enough = 0.0002 ; original
close_enough = 0.00001
itmax = 50

eps = 1.0e-24
n   = n_elements(xin)
m   = float(n)

; First, shift X and Y to their centers of gravity:
x0 = total(xin)/n
y0 = total(yin)/n
x  = xin-x0
y  = yin-y0

if (n/4*4) eq n then need2 = 1 else need2 = 0
n3 = 3*n/4  &  n1 = n/4

cc = fltarr(2)
ss = fltarr(2)

; First guess:
if n gt 5 then begin
   s=sort(x)
   u=x(s)
   v=y(s)
   nhalf=n/2-1
   x1=median(u(0:nhalf)) & x2=median(u(nhalf+1:n-1))
   y1=median(v(0:nhalf)) & y2=median(v(nhalf+1:n-1))
   cc[1]=(y2-y1)/(x2-x1)  & cc[0]=y1-cc[1]*x1
endif else begin
   sx=total(x)  &  sy=total(y)  &  sxy=total(x*y)  &  sx2=total(x*x)
   d=sx2-sx*sx
   cc[0]=(sx2*sy-sx*sxy)/d  &  cc[1]=(sxy-sx*sy)/d
endelse

yfit = cc[0]+cc[1]*x
dev  = y-yfit
devs = dev(sort(dev))

; Determine the spread from the interquartile range:
if need2 then sig = (devs(n3-1)+devs(n3)-devs(n1-1)-devs(n1))*.5 $
         else sig = devs(n3)-devs(n1)
sig = sig/1.35
if sig lt eps then begin
   chi = 0.
   print,' ROBUST_LINEFIT: Zero Residuals.'
   goto,afterfit
endif

; Calculate the biweights:
s = abs(dev)/(6.*sig)
q = where(s gt 1.) & if q[0] ge 0 then s(q)=1.0
w = (1.-s*s)^2
w = m*w/total(w)

; Now iterate until the solution converges:
chi  = 1.0e30
diff = chi
nit  = 0
while( (diff gt close_enough) and (nit lt itmax) ) do begin



; Compute the slope coefficients


  nit = nit+1
  sw  = total(w)
  sx=total(w*x) & sy=total(w*y) & sxy=total(w*x*y) & sx2=total(w*x*x) &sy2=total(w*y*y)

; ============>
; from sixlin.pro
 if sxy EQ 0. then $
      message,'SXY is zero, SIXLIN is terminated'
 if sxy LT 0. then sign = -1.0 else sign = 1.0
 b_0 = sxy / sx2
 b_1 = sy2 / sxy
 b_4 = sign*sqrt( b_0*b_1 )
 ;a = yavg - b*xavg
cc[1] = b_4
cc[0] = sy/m - b_4*sx/m

; ^^^^^^^^^^ sixlin

  d   = sw*sx2-sx^2
  oldcc = cc
;  cc[0] = (sx2*sy-sx*sxy)/d  &  cc[1]=(sw*sxy-sx*sy)/d




; Now, how good is this fit? We need a robust Chi-Squared.
  yfit = cc[0]+cc[1]*x
 ; dev  = y-yfit

  xfit = (y-cc[0])/cc[1] ; JAY


  dev  = SQRT((y-yfit)^2 + (x-xfit)^2) ; JAY

  devs = dev(sort(dev))
  if need2 then sig = (devs(n3-1)+devs(n3)-devs(n1-1)-devs(n1))*.5 $
           else sig = devs(n3)-devs(n1)
  sig = sig/1.35
  if sig lt eps then begin
     chi = 0.
     print,' ROBUST_LINEFIT: Zero Residuals.'
     goto,afterfit
  endif
  s = abs(dev)/(6.*sig)
  q = where(s gt 1.) & if q[0] ge 0 then s(q)=1.0
  w = (1.-s*s)^2
  w = m*w/total(w)
  oldchi = chi
  chi = total(dev*dev*w)/(m-2.)
  diff = oldchi - chi
  if diff lt 0. then begin
     cc=oldcc
     chi=oldchi
  endif



endwhile
if nit eq itmax then print,' ROBUST_LINEFIT did not converge in 50 iterations'

afterfit:

; Untranslate the coefficients
cc[0] = cc[0]+y0-cc[1]*x0

if n_params[0] gt 2 then begin
   yfit = cc[0] + cc[1]*xin

;    Now the standard deviations of the coefficients:
   sw = total(w)   & sx=total(w*x)  & sx2=total(w*x*x)
   d  = sw*sx2-sx^2
   if d lt 1.0e-30 then begin
      print,' Unable to calculate uncertainties of the coefficients'
   endif else begin
      if d eq 0. then begin
         print,'ROBUST_LINEFIT: No Estimates on Coefficient Sigmas Possible'
         ss = [0.,0.]
      endif else begin
         ss[0]=sqrt(sx2/d)  & ss[1]=sqrt(sw/d)
      endelse
   endelse
endif

return,cc
end

