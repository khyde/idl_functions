 pro kstwo_plot, data1, data2, D, prob, CHARSIZE=charsize
;+
;  pro kstwo_plot, data1, data2, D, prob, CHARSIZE=charsize
;
; NAME:
;       KSTWO_PLOT
; PURPOSE:
;       Return the two-sided Kolmogorov-Smirnov statistic
;       and make a nice plot of the two distributions.
; EXPLANATION:
;       Returns the Kolmogorov-Smirnov statistic and associated probability 
;       that two arrays of data values are drawn from the same distribution
;       Algorithm taken from procedure of the same name in "Numerical
;       Recipes" by Press et al., 2nd edition (1992), Chapter 14
;
; CALLING SEQUENCE:
;       kstwo_plot, data1, data2, D, prob  
;
; INPUT PARAMATERS:
;       data1 -  vector of data values, at least 4 data values must be included
;               for the K-S statistic to be meaningful
;       data2 -  second set of data values, does not need to have the same 
;               number of elements as data1
;
; OUTPUT PARAMETERS:
;       D - floating scalar giving the Kolmogorov-Smirnov statistic.   It
;               specifies the maximum deviation between the cumulative 
;               distribution of the data and the supplied function 
;       prob - floating scalar between 0 and 1 giving the significance level of
;               the K-S statistic.   Small values of PROB show that the 
;               cumulative distribution function of DATA1 is significantly 
;               different from DATA2
;
; EXAMPLE:
;       Test whether two vectors created by the RANDOMN function likely came
;       from the same distribution
;
;       IDL> data1 = randomn(seed,40)        ;Create data vectors to be 
;       IDL> data2 = randomn(seed,70)        ;compared
;       IDL> kstwo_plot, data1, data2, D, prob   & print,D,prob
;
; PROCEDURE CALLS
;       procedure PROB_KS - computes significance of K-S distribution
;
; REVISION HISTORY:
;       Written     W. Landsman                August, 1992
;       FP computation of N_eff      H. Ebeling/W. Landsman  March 1996
;       Converted to IDL V5.0   W. Landsman   September 1997
;       PLOT output added       D. Dewey     May 2005
;-

 On_error, 2

 if ( N_params() LT 4 ) then begin
    print,'Syntax - kstwo, data1, data2, d, prob'
    return
 endif

 n1 = N_elements( data1 )
 if ( N1 LE 3 ) then message, $
   'ERROR - Input data values (first param) must contain at least 4 values'

if n_elements(charsize) NE 1 then charsize = 1.0

 n2 = N_elements( data2 )
 if ( n2 LE 3 ) then message, $
   'ERROR - Input data values (second param) must contain at least 4 values'

 sortdata1 = data1[ sort( data1 ) ]        ;Sort input arrays into 
 sortdata2 = data2[ sort( data2 ) ]        ;ascending order

 fn1 = ( findgen( n1 )  ) / n1
 fn2 = ( findgen( n2 )  ) / n2

 j1 = 0l & j2 = 0l
 id1 = lonarr(n1+n2)  & id2 = id1
 i = 0l

; Form the two cumulative distribution functions, marking points where one
; must test their difference

 while (  (j1 NE (N1-1)) or (j2 NE (N2-1)) ) do begin

     ; increment the lower one...
     ; But, if one is saturated then increment the other...
     ; so that a nice plot can be created.
     if sortdata1[j1] LE sortdata2[j2] then begin
       j1 = j1 +1
       if j1 EQ N1 then begin
         j1 = N1-1
         j2 = j2 + 1
       end
     end else begin
       j2 = j2 +1
       if j2 EQ N2 then begin
         j2 = N2-1
         j1 = j1 + 1
       end
     end
       
     id1[i] = j1   & id2[i] = j2
     i = i+1

 endwhile

 id1 = id1[0:i-1]   &  id2 = id2[0:i-1]

; The K-S statistic D is the maximum difference between the two distribution
; funtions

 dvals = abs( fn1[id1] - fn2[id2] )
 D = max( dvals )        

 N_eff =  n1*n2/ float(n1 + n2)              ;Effective # of data points
 PROB_KS, D, N_eff, prob                ;Compute significance of statistic

 ; plot the data
 alldata = [data1,data2]
 plot, sortdata1[id1], fn1[id1], YRANGE=[0.,1.], /YSTYLE, $
    XRANGE=[min(alldata),max(alldata)], /XSTYLE, CHARSIZE=charsize, $
    XTITLE='Data range', YTITLE='Cumulative fraction', $
    TITLE='K-S test:  D = '+STRING(D, FORMAT='(F6.4)') + $
      ', Prob = ' + STRING(prob, FORMAT='(F8.6)') + $
      '  (N_eff ='+STRCOMPRESS(STRING(N_eff, FORMAT='(G10.4)'))+')'
 oplot,sortdata2[id2], fn2[id2], linestyle=2
;
; indicate where the max D value is:
dind = where ( dvals EQ D )
dind = dind(0)
oplot, sortdata1(id1(dind))*[1.,1.], [0.0,1.0], LINESTYLE=1

 return
 end
