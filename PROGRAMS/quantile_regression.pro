      subroutine rq(m,n,m5,n2,a,b,t,toler,ift,x,e,s,wa,wb,
     1  nsol,sol,lsol)
      implicit double precision (a-h,o-z)
c
c     Algorithm AS229 Appl. Statist. (1987) Vol. 36, No. 3
c
      integer i,j,k,kl,kount,kr,l,lsol,m,m1,m2,m3,m4,m5,
     1  ift
      integer n,n1,n2,nsol,out,s(m)
      logical stage,test,init,iend
      double precision a1,aux,b1,big,d,dif,pivot,smax,t,t0,t1,tnt
      double precision min,max,toler,zero,half,one,two,three,four,five
      double precision b(m),sol(n2,nsol),a(m,n),x(n),wa(m5,n2),wb(m)
      double precision sum,e(m)
      double precision xx,y
      data big /1.0d37/
      data zero /0.0d0/
      data half /0.5d0/
      data one /1.0d0/
      data two /2.0d0/
      data three /3.0d0/
      data four /4.0d0/
      data five /5.0d0/
c
c     check dimension parameters
c
      ift = 0
      if (m5.ne.m + 5) ift = 3
      if (n2.ne.n + 2) ift = 4
      if (m.le.zero.or.n.le.zero) ift = 5
      if (ift.gt.two) return
c
c     initialization
c
      m1 = m + 1
      n1 = n + 1
      m2 = m + 2
      m3 = m + 3
      m4 = m + 4
      do 2 i = 1,m
        wb(i) = b(i)
        do 1 j = 1,n
          wa(i,j) = a(i,j)
   1    continue
   2  continue
      wa(m2,n1) = zero
      dif = zero
      iend = .true.
      if (t.ge.zero.and.t.le.one) goto 3
      t0 = one / float(m) - toler
      t1 = one - t0
      t = t0
      iend = .false.
   3  continue
      init = .false.
      lsol = 1
      kount = 0
      do 9 k = 1,n
        wa(m5,k) = zero
        do 8 i = 1,m
          wa(m5,k) = wa(m5,k) + wa(i,k)
   8    continue
        wa(m5,k) = wa(m5,k) / float(m)
   9  continue
      do 10 j = 1,n
        wa(m4,j) = j
        x(j) = zero
  10  continue
      do 40 i = 1,m
        wa(i,n2) = n + i
        wa(i,n1) = wb(i)
        if (wb(i).ge.zero) goto 30
        do 20 j = 1,n2
          wa(i,j) = -wa(i,j)
  20    continue
  30    e(i) = zero
  40  continue
      do 42 j = 1,n
        wa(m2,j) = zero
        wa(m3,j) = zero
        do 41 i = 1,m
          aux = sign(one,wa(m4,j)) * wa(i,j)
          wa(m2,j) = wa(m2,j) + aux * (one - sign(one,wa(i,n2)))
          wa(m3,j) = wa(m3,j) + aux * sign(one,wa(i,n2))
  41    continue
        wa(m3,j) = two * wa(m3,j)
  42  continue
      goto 48
  43  continue
      lsol = lsol + 1
      do 44 i = 1,m
        s(i) = zero
  44  continue
      do 45 j = 1,n
        x(j) = zero
  45  continue
c
c     compute next t
c
      smax = two
      do 47 j = 1,n
        b1 = wa(m3,j)
        a1 = (-two - wa(m2,j)) / b1
        b1 = -wa(m2,j) / b1
        if (a1.lt.t) goto 46
        if (a1.ge.smax) goto 46
        smax = a1
        dif = (b1 - a1) / two
  46    if (b1.le.t) goto 47
        if (b1.ge.smax) goto 47
        smax = b1
        dif = (b1 - a1) / two
  47  continue
      tnt = smax + toler * (one + dabs(dif))
      if (tnt.ge.t1 + toler) iend = .true.
      t = tnt
      if (iend) t = t1
  48  continue
c
c     compute new marginal costs
c
      do 49 j = 1,n
        wa(m1,j) = wa(m2,j) + wa(m3,j) * t
  49  continue
      if (init) goto 265
c
c     stage 1
c
c      determine the vector to enter the basis
      stage = .true.
      kr = 1
      kl = 1
  70  max = -one
      do 80 j = kr,n
        if (abs(wa(m4,j)).gt.n) goto 80
        d = abs(wa(m1,j))
        if (d.le.max) goto 80
        max = d
        in = j
  80  continue
      if (wa(m1,in).ge.zero) goto 100
      do 90 i = 1,m4
        wa(i,in) = -wa(i,in)
  90  continue
c
c      determine the vector to leave the basis
c
 100  k = 0
      do 110 i = kl,m
        d = wa(i,in)
        if (d.le.toler) goto 110
        k = k + 1
        wb(k) = wa(i,n1) / d
        s(k) = i
        test = .true.
 110  continue
 120  if (k.gt.0) goto 130
      test = .false.
      goto 150
 130  min = big
      do 140 i = 1,k
        if (wb(i).ge.min) goto 140
        j = i
        min = wb(i)
        out = s(i)
 140  continue
      wb(j) = wb(k)
      s(j) = s(k)
      k = k - 1
c
c     check for linear dependence in stage 1
c
 150  if (test.or. .not.stage) goto 170
      do 160 i = 1,m4
        d = wa(i,kr)
        wa(i,kr) = wa(i,in)
        wa(i,in) = d
 160  continue
      kr = kr + 1
      goto 260
 170  if (test) goto 180
      wa(m2,n1) = two
      goto 390
 180  pivot = wa(out,in)
      if (wa(m1,in) - pivot - pivot .le. toler) goto 200
      do 190 j = kr,n1
        d = wa(out,j)
        wa(m1,j) = wa(m1,j) - d - d
        wa(m2,j) = wa(m2,j) - d - d
        wa(out,j) = -d
 190  continue
      wa(out,n2) = -wa(out,n2)
      goto 120
c
c      pivot on wa(out,in)
c
 200  do 210 j = kr,n1
        if (j.eq.in) goto 210
        wa(out,j) = wa(out,j) / pivot
 210  continue
      do 230 i = 1,m3
        if (i.eq.out) goto 230
        d = wa(i,in)
        do 220 j = kr,n1
          if (j.eq.in) goto 220
          wa(i,j) = wa(i,j) - d * wa(out,j)
 220    continue
 230  continue
      do 240 i = 1,m3
        if (i.eq.out) goto 240
        wa(i,in) = -wa(i,in) / pivot
 240  continue
      wa(out,in) = one / pivot
      d = wa(out,n2)
      wa(out,n2) = wa(m4,in)
      wa(m4,in) = d
      kount = kount + 1
      if (.not.stage) goto 270
c
c       interchange rows in stage 1
c
      kl = kl + 1
      do 250 j = kr,n2
        d = wa(out,j)
        wa(out,j) = wa(kount,j)
        wa(kount,j) = d
 250  continue
 260  if (kount + kr.ne.n1) goto 70
c
c       stage 2
c
 265  stage = .false.
c
c      determine the vector to enter the basis
c
 270  max = -big
      do 290 j = kr,n
        d = wa(m1,j)
        if (d.ge.zero) goto 280
        if (d.gt. (-two)) goto 290
        d = -d - two
 280  if (d.le.max) goto 290
      max = d
      in = j
 290  continue
      if (max.le.toler) goto 310
      if (wa(m1,in) .gt.zero) goto 100
      do 300 i = 1,m4
        wa(i,in) = -wa(i,in)
 300  continue
      wa(m1,in) = wa(m1,in) - two
      wa(m2,in) = wa(m2,in) - two
      goto 100
c
c       compute quantiles
 310  continue
      do 320 i = 1,kl - 1
        k = wa(i,n2) * sign(one,wa(i,n2))
        x(k) = wa(i,n1) * sign(one,wa(i,n2))
 320  continue
      sum = zero
      do 330 i = 1,n
        sum = sum + x(i) * wa(m5,i)
        sol(i + 2,lsol) = x(i)
 330  continue
      sol(1,lsol) = t
      sol(2,lsol) = sum
      if (iend) goto 340
      init = .true.
      goto 43
 340  continue
      if (lsol.le.2) goto 355
      do 350 i = 2,lsol
        sol(1,i-1) = sol(1,i)
 350  continue
      lsol = lsol - 1
      sol(1,lsol) = one
 355  continue
      l = kl - 1
      do 370 i = 1,l
        if (wa(i,n1).ge.zero) goto 370
        do 360 j = kr,n2
          wa(i,j) = -wa(i,j)
 360    continue
 370  continue
      wa(m2,n1) = zero
      if (kr.ne.1) goto 390
      do 380 j = 1,n
        d = abs(wa(m1,j))
        if (d.le.toler .or. two - d .le. toler) goto 390
 380  continue
      wa(m2,n1) = one
 390  do 400 i = kl,m
        k = wa(i,n2) * sign(one,wa(i,n2))
        d = wa(i,n1) * sign(one,wa(i,n2))
        k = k - n
        e(k) = d
 400  continue
      wa(m2,n2) = kount
      wa(m1,n2) = n1 - kr
      sum = zero
      do 410 i = 1,m
        sum = sum + e(i) * (half + sign(one,e(i)) * (t - half))
 410  continue
      wa(m1,n1) = sum
      return
      end


;;  **********************
;     Quantile Regression (rq)
;
;
;DESCRIPTION:
;       Perform  a  quantile  regression on a design matrix, x, of
;       explanatory variables and a vector, y, of responses.
;
;USAGE:
;       rq(x, y, tau=-1, alpha=.1, dual=F, int=T, tol=1e-4, ci = T,
;method="score",
;       interpolate=T, tcrit=T, hs=T)
;
;
;REQUIRED ARGUMENTS:
;x:     vector or matrix of explanatory variables.  If  a  matrix,
;       each  column represents a variable and each row represents
;       an observation (or case).  This should not contain  column
;       of  1s unless the argument intercept is FALSE.  The number
;       of rows of x should equal the number of  elements  of   y,
;       and  there   should   be fewer columns than rows.  If x is
;       missing, rq() computes the ordinary sample quantile(s)  of
;       y.
;y:     response vector with as many observations as the number of
;       rows of x.
;
;OPTIONAL ARGUMENTS:
;tau:   desired quantile. If tau is missing or outside  the  range
;       [0,1]  then  all the regression quantiles are computed and
;       the corresponding primal and dual solutions are  returned.
;alpha: level  of significance for the confidence intervals; de-
;       fault is set at 10%.
;dual:  return the dual solution if TRUE (default).
;int:   flag for intercept; if TRUE (default) an intercept term is
;       included in the regression.
;tol:   tolerance parameter for rq computations.
;ci:    flag for confidence interval; if TRUE (default) the confi-
;       dence intervals are returned.
;method:  if method="score" (default), ci is  computed  using  re-
;       gression rank score inversion; if method="sparsity", ci is
;       computed using sparsity function.
;interpolate:  if TRUE (default), the smoothed  confidence  inter-
;       vals are returned.
;tcrit:   if  tcrit=T (default), a finite sample adjustment of the
;       critical point is performed using  Student's  t  quantile,
;       else the standard Gaussian quantile is used.
;hs:     logical  flag  to  use Hall-Sheather's sparsity estimator
;       (default); otherwise Bofinger's version is used.
;
;VALUE:
;coef:  the estimated parameters of the tau-th  conditional  quan-
;       tile function.
;resid: the  estimated residuals of the tau-th conditional quan-
;       tile function.
;dual:  the dual solution (if dual=T).
;h:     the index of observations in the basis.
;ci:    confidence intervals (if ci=T).
;
;VALUE:
;sol:   a  (p+2) by m matrix whose first row contains the  'break-
;       points'  tau_1,tau_2,...tau_m,  of  the quantile function,
;       i.e. the values in [0,1] at which  the  solution  changes,
;       row  two contains the corresponding quantiles evaluated at
;       the mean design point, i.e. the inner product of xbar  and
;       b(tau_i), and the last p rows of the matrix give b(tau_i).
;       The solution b(tau_i) prevails from tau_i to tau_i+1.
;dsol:  the matrix of dual solutions corresponding to  the  primal
;       solutions  in  sol.   This is an n by m matrix whose ij-th
;       entry is 1 if y_i > x_i  b(tau_j),  is  0  if  y_i  <  x_i
;       b(tau_j),   and  is between 0 and 1 otherwise, i.e. if the
;       residual is zero.  See  Gutenbrunner  and  Jureckova(1991)
;       for  a  detailed discussion of the statistical interpreta-
;       tion of dsol.
;h:     the matrix of observations indices  in  the  basis  corre-
;       sponding to sol or dsol.
;
;EXAMPLES:
;       rq(stack.x,stack.loss,.5)  #the l1 estimate for the stackloss data
;       rq(stack.x,stack.loss,tau=.5,ci=T,method="score")  #same as above with
;                      #regression rank score inversion confidence interval
;       rq(stack.x,stack.loss,.25)  #the 1st quartile,
;                      #note that 8 of the 21 points lie exactly
;                      #on this plane in 4-space
;       rq(stack.x,stack.loss,-1)   #this gives all of the rq solutions
;       rq(y=rnorm(10),method="sparsity")  #ordinary sample quantiles
;
;METHOD:
;       The  algorithm used is a modification of the Barrodale and
;       Roberts algorithm for l1-regression, l1fit in  S,  and  is
;       described in detail in Koenker and d"Orey(1987).
;
;REFERENCES:
;       [1]  Koenker,  R.W.  and  Bassett, G.W. (1978). Regression
;       quantiles, Econometrica, 46, 33-50.
;
;       [2] Koenker, R.W. and d'Orey (1987). Computing  Regression
;       Quantiles. Applied Statistics, 36, 383-393.
;
;       [3]  Gutenbrunner,  C.  Jureckova,  J. (1991).  Regression
;       quantile and regression rank score process in  the  linear
;       model  and  derived  statistics, Annals of Statistics, 20,
;       305-330.
;
;       [4] Koenker, R.W. and d'Orey (1994).  Remark  on  Alg.  AS
;       229:  Computing  Dual  Regression Quantiles and Regression
;       Rank Scores, Applied Statistics, 43, 410-414.
;
;       [5] Koenker, R.W. (1994). Confidence Intervals for Regres-
;       sion  Quantiles, in P. Mandl and M. Huskova (eds.), Asymp-
;       totic Statistics, 349-359, Springer-Verlag, New York.
;
;
;SEE ALSO:
;       trq and qrq for further details and references.
;
;
;
;
;
;
;Regression Rank-scores (rrs.test)
;
;DESCRIPTION:
;        Function to compute regression rankscore test of linear
;        hypotheisis.  Tests the hypothesis that b_1 = 0 in the
;        quantile regression model y = X_0 b_0 + X_1 b_1 + u, where
;        X_0 is assumed to include an intercept (appended
;        automatically) and at least 1 other parameter.
;
;USAGE:
;        rrs.test(x0, x1, y, v, score="wilcoxon")
;
;REQUIRED ARGUMENTS:
;x0:     matrix of regressors under the null, reduced parameter model,
;        a column of ones is appended automatically for the intercept.
;x1:     matrix of regressors under test in the alternative, full
;        parameter (x0 + x1) model.
;y:      response variable, may be omitted if v is provided.
;v:      regression quantile structure from rq(x0,y)
;score:  score function for test (see rank()), default is "wilcoxon",
;        numeric scores in the interval 0 < score < 1 provide quantile
;        rank-score tests corresponding to those used for computing
;        confidence intervals in rq()
;
;VALUE:
;Tn:     Standardized test statistic that is asymptotically Chi-squared
;        with rank(x1) degrees of freedom, i.e., difference in number of
;        parameters in null and alternative models.
;sn:     Raw unstandardized test statistic
;rank:   vector of rank scores from ranks()
;x1hat:  residual matrix of qr decomposition of x0 on x1, used in asymptotic
;        variance/covariance to standardize sn to create Tn.
;
;EXAMPLES:
;        rrs.test(stack.x[,1:2],stack.x[,3],stack.loss,score=0.5)
;        rrs.test(stack.x[,1:2],stack.x[,3],stack.loss,score=0.9)
;        rrs.test(stack.x[,1:2],stack.x[,3],stack.loss,score="wilcoxon")
;
;METHOD: See [1] for details on using rrs.test to test more general
;        (Rb=r) forms of the linear hypothesis.
;
;REFERENCES:
;        [1] Gutenbrunner, C., J. Jureckova, R. Koenker, and S. Portnoy.
;        (1993) Tests of linear hypotheses based on regression rank scores.
;        Journal of Nonparametric Statistics 2:307-331.
;
;        [2] Koenker, R. W., and V. d'Orey. (1994) A remark on algorithm
;        AS229: computing dual regression quantiles and regression rank
;        scores.  Applied Statistics 43:410-414.
;
;SEE ALSO:
;        rrs.full.test, rq, and ranks
;
;
;
;
;
;Regression Rank-scores - full model (rrs.full.test)
;
;DESCRIPTION:
;        Function to compute regression rankscore test of linear
;        hypotheisis.  Tests the hypothesis that b_1 = 0 in the
;        quantile regression model y = X_0 b_0 + X_1 b_1 + u, where
;        X_0 is explicitly just an intercept (a column of 1's is
;        not appended automatically as in rrs.test).
;
;USAGE:
;        rrs.full.test(x0, x1, y, v, score="wilcoxon")
;
;REQUIRED ARGUMENTS:
;x0:     matrix of regressors under the null, reduced parameter model
;        is a column of ones, which must be provided.
;x1:     matrix of regressors under test in the alternative, full
;        parameter (x0 + x1) model.
;y:      response variable, may be omitted if v is provided.
;v:      regression quantile structure from rq(x0,y)
;score:  score function for test (see rank()), default is "wilcoxon",
;        numeric scores in the interval 0 < score < 1 provide quantile
;        rank-score tests corresponding to those used for computing
;        confidence intervals in rq()
;
;VALUE:
;Tn:     Standardized test statistic that is asymptotically Chi-squared
;        with rank(x1) degrees of freedom, i.e., difference in number of
;        parameters in null and alternative models.
;sn:     Raw unstandardized test statistic
;rank:   vector of rank scores from ranks()
;x1hat:  residual matrix of qr decomposition of x0 on x1, used in asymptotic
;        variance/covariance to standardize sn to create Tn.
;
;EXAMPLES:
;        stack.x<-cbind(1,stack.x)
;        rrs.full.test(stack.x[,1],stack.x[,2:4],stack.loss,score=0.5)
;
;METHOD: See [1] for details on using rrs.test to test more general
;        (Rb=r) forms of the linear hypothesis.
;
;REFERENCES:
;        [1] Gutenbrunner, C., J. Jureckova, R. Koenker, and S. Portnoy.
;        (1993) Tests of linear hypotheses based on regression rank scores.
;        Journal of Nonparametric Statistics 2:307-331.
;
;        [2] Koenker, R. W., and V. d'Orey. (1994) A remark on algorithm
;        AS229: computing dual regression quantiles and regression rank
;        scores.  Applied Statistics 43:410-414.
;
;SEE ALSO:
;        rrs.test, rq, and ranks
;
;
;
;
;
;Linearized Quantile Estimation (qrq)
;
;
;DESCRIPTION:
;       Compute linearized quantiles from rq data structure.
;
;USAGE:
;       qrq(s, a)
;
;REQUIRED ARGUMENTS:
;s:      data  structure returned by the quantile regression func-
;       tion rq with t<0 or t>1.
;a:     the vector of quantiles for which the  corresponding  lin-
;       earized quantiles are to be computed.
;
;VALUE:
;       a vector of the linearized quantiles corresponding to vec-
;       tor a, as interpolated from the second row of s$sol.
;
;SEE ALSO:
;       rq and  trq  for further detail.
;
;EXAMPLES:
;       z_qrq(rq(x,y),a)       #assigns z the linearized quantiles
;                              #corresponding to vector a.
;
;
;
;
;
;
;
;
;Function  to compute analogues of the trimmed mean for the linear
;regression model. (trq)
;
;
;DESCRIPTION:
;       The function returns a regression trimmed  mean  and  some
;       associated  test statistics.  The proportion a1 is trimmed
;       from the lower tail  and  a2  from  the  upper  tail.   If
;       a1+a2=1 then a result is returned for the a1 quantile.  If
;       a1+a2<1 two methods of trimming are possible described be-
;       low  as  "primal" and "dual". The function "trq.print" may
;       be used to print results in the style of ls.print.
;
;USAGE:
;       trq(x, y, a1=0.1, a2,  int=T, z,  method="primal", tol=1e-4)
;
;REQUIRED ARGUMENTS:
;x:     vector or matrix of explanatory variables.  If  a  matrix,
;       each  column represents a variable and each row represents
;       an observation (or case).  This should not contain  column
;       of  1s unless the argument intercept is FALSE.  The number
;       of rows of x should equal the number of  elemants  of   y,
;       and  there   should   be fewer columns than rows.  Missing
;       values are not  allowed.
;y:     reponse vector with as many observations as the number  of
;       rows of x.  Missing value are not allowed.
;
;OPTIONAL ARGUMENTS:
;a1:     the lower trimming proportion; defaults to .1 if missing.
;a2:    the upper trimming proportion; defaults to a1 if  missing.
;int:   flag for intercept; if TRUE, an intercept term is included
;       in regression model.  The  default  includes  an  intercept
;       term.
;z:      structure  returned by the function 'rq' with t <0 or >1.
;       If missing, the function rq(x,y,int=int) is  automatically
;       called to generate this argument.  If several calls to trq
;       are anticipated for the same data this avoids  recomputing
;       the rq solution for each call.
;method:   method  to  be used for the trimming.  If the choice is
;       "primal", as is the default, a trimmed mean of the  primal
;       regression  quantiles   is computed based on the sol array
;       in the 'rq' structure.  If the method is "dual", a weight-
;       ed  least-squares  fit  is done using the dual solution in
;       the 'rq'  structure  to  construct  weights.   The  former
;       method  is discussed in detail in Koenker and Potnoy(1987)
;       the latter in Ruppert and Carroll(1980)  and  Gutenbrunner
;       and Jureckova(1991).
;tol:   Tolerance parameter for rq computions
;
;VALUE:
;coef:  estimated coeficient vector
;resid:  residuals from the fit.
;cov:   the estimated covariance matrix for the coeficient vector.
;v:     the scaling factor of the covariance matrix under iid  er-
;       ror assumption: cov=v*(x'x)^(-1).
;wt:     the  weights  used in the least squares computation,  Re-
;       turned only when method="dual".
;d:     the bandwidth used to compute the sparsity function.   Re-
;       turned only when a1+a2=1.
;
;EXAMPLES:
;       z_rq(x,y)  #z gets the full regression quantile structure
;       trq(x,y,.05,z=z)  #5% symmetric primal trimming
;       trq(x,y,.01,.03,method="dual")  #1% lower and 3% upper trimmed least-
;                                    #squares fit.
;       trq.print(trq(x,y)) #prints trq results in the style of ls.print.
;
;METHOD:
;       details  of  the methods may be found in Koenker and Port-
;       noy(1987) for the case of primal trimming  and  in  Guten-
;       brunner and Jureckova(1991) for dual trimming.  On the es-
;       timation of the covariance  matrix  for  individual  quan-
;       tiles,  see  Koenker(1987) and the discussion in Hendricks
;       and Koenker(1991).  The estimation of the  covariance  ma-
;       trix  under   non-iid conditions is an open research prob-
;       lem.
;
;REFERENCE:
;       Bassett, G., and Koenker, R. (1982), "An  Empirical  Quan-
;       tile  Function for Linear Models With iid Errors," Journal
;       of the American Statistical Association, 77, 407-415.
;
;       Koenker, R.W. (1987), "A Comparison of Asymptotic  Methods
;       of  Testing  based  on  L1  Estimation," in Y. Dodge (ed.)
;       Statistical Data Analysis Based on the L1 norm and Related
;       Methods, New York:  North-Holland.
;
;       Koenker, R. W., and Bassett, G.W (1978), "Regression Quan-
;       tiles", Econometrica, 46, 33-50.
;
;       Koenker, R., and Portnoy,  S.  (1987),  "L-Estimation  for
;       Linear  Models", Journal of the American Statistical Asso-
;       ciation, 82, 851-857.
;
;       Ruppert, D.  and  Carroll,  R.J.  (1980),  "Trimmed  Least
;       Squares  Estimation  in  the Linear Model", Journal of the
;       American Statistical Association, 75, 828-838.
;
;
