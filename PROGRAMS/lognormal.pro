;
;; http://qecc.pnl.gov/LOGNORM4.htm
;This program uses one or more of the following relationships for lognormals:
;sigma = SQR(2 * LOG(mean / median)) = SQR(2 * LOG(mean / mode) / 3)
;sigma = SQR(LOG(median / mode)) = LOG(value1 / median) / z1
;sigma = SQR(LOG(CV ^ 2 + 1)) = LOG(GSD); GSD = EXP(sigma)
;sigma = LOG(value1 / value2) / (z1 - z2); sigma = SQR(mu - LOG(mode))
;SQR(EXP(sigma^2)-1)*EXP(sigma^2/2) = SD/median; !must be solved numerically!
;median = mean * EXP(-sigma ^ 2 / 2) = mode * EXP(sigma ^ 2)
;mu = LOG(median) = LOG(mean) - sigma ^ 2 /2 = LOG(mode) + sigma ^ 2
;mu = LOG(value1) + LOG(value2 / value1) * (0-z1) / (z2-z1); median = EXP(mu)
;mu = LOG(value1) - sigma * z1 = LOG(mode) + LOG(CV ^ 2 + 1)
;mode ^ 2 * SD ^ 2 - median ^ 4 + median ^ 3 * mode = 0 !numerically solved
;SD ^ 2 / value1 ^ 2 = EXP(-2 * z1 * sigma + sigma ^ 2) * (EXP(sigma ^ 2) - 1)
;[Note: Solve numerically; eqn. may yield 1 or 3 values of sigma for z1 > 1]
;mean = median * EXP(sigma ^ 2 / 2); lnmean = LOG(mean)
;mode = EXP(mu - sigma ^ 2) = median * EXP(-sigma ^ 2); lnmode = LOG(mode)
;CV = SQR(EXP(sigma ^ 2) - 1); CV = SD / mean; SD = CV * mean
;variance = SD ^ 2 = EXP(2 * mu + sigma ^ 2) * (EXP(sigma ^ 2) - 1)
;skewness = CV^3 + 3 * CV; kurtosis = CV^8 + 6 * CV^6 + 15 * CV^4 + 16 * CV^2
;zmode = -sigma; zmean = sigma / 2; zmedian = 0
;value = EXP(mu + zvalue * sigma); zvalue = (LOG(value) - mu) / sigma
;If mean < value then sigma = z1 + SQR(z1 ^ 2 + 2 * LOG(mean / value))
;If mean > value then sigma = z1 - SQR(z1 ^ 2 + 2 * LOG(mean / value))
;If mode > value then sigma = (-z1 + SQR(z1 ^ 2 - 4 * LOG(mode / value))) / 2
;If mode < value then sigma = (-z1 - SQR(z1 ^ 2 - 4 * LOG(mode / value))) / 2
;
;There are 16 methods of specifying a lognormal distribution. You can specify...
;1. the mean and median (or their natural logs)
;2. the mean and mode (or their natural logs)
;3. the median and mode (or their natural logs)
;4. the median (or its natural log) and the GSD or sigma = ln(GSD)
;5. the mean (or its natural log) and the GSD or sigma = ln(GSD)
;6. the mode (or its natural log) and the GSD or sigma = ln(GSD)
;7. a value & its %ile OR quantile OR std norm deviate & GSD or sigma=ln(GSD)
;8. the median & a value with its percentile OR quantile OR std normal deviate
;9. the mean & a value with its percentile OR quantile OR std normal deviate
;10. the mode & a value with its percentile OR quantile OR std normal deviate
;11. the median & [arithmetic] standard deviation OR coefficient of variation
;12. the mean & [arithmetic] standard deviation OR coefficient of variation
;13. the mode & [arithmetic] standard deviation OR coefficient of variation
;14. a value & its %ile OR quantile OR std norm deviate & [arithmetic] SD or CV
;15. a pair of values and their percentiles OR quantiles OR std normal deviates
;16. a file created by LOGNORML containing mu & sigma & etc.
;
;LOGNORM4 test 1999-09-20
;
;You chose the mean and median (or their natural logs) which results in a distribution with these parameters:
;GSD sigma SD CV variance skewness kurtosis
;3.245956 1.17741 3.464102 1.732051 12 10.3923 426
;
;PS0toD is Eq(6) & S0toD is Eq(4) from Strom DJ. Health Phys 51(4):437-445 1986.
;Dbar0toD = the average dose among persons receiving doses <= D
;Dbar0toD = S0toD / (N * PS0toD)
;Parameter Value ln(Value) %ile Quantile z-Value PS0toD S0toD No. Dbar0toD
;mean 2 0.6931472 72.19693 0.7219693 0.588705 0.2780307 0.5560613 0.7219693 0.7702008
;median 1 0 50 0.5 0 0.1195182 0.2390364 0.5 0.4780729
;mode 0.25 -1.386294 11.95182 0.1195182 -1.17741 9.27E-03 1.85E-02 0.1195182 0.1550654
;z 9.01E-03 -4.70964 3.17E-03 3.17E-05 -4 1.15E-07 2.31E-07 3.17E-05 7.29E-03
;z 2.92E-02 -3.53223 0.1349898 1.35E-03 -3 1.47E-05 2.95E-05 1.35E-03 2.18E-02
;z 9.49E-02 -2.35482 2.275013 2.28E-02 -2 7.43E-04 1.49E-03 2.28E-02 6.53E-02
;z 0.3080756 -1.17741 15.86553 0.1586553 -1 1.47E-02 2.95E-02 0.1586553 0.1856323
;z 3.245956 1.17741 84.13447 0.8413447 1 0.4295938 0.8591877 0.8413447 1.021208
;z 10.53623 2.35482 97.72498 0.9772499 2 0.7946272 1.589254 0.9772499 1.626252
;z 34.20015 3.53223 99.86501 0.9986501 3 0.9658159 1.931632 0.9986501 1.934243
;z 111.0122 4.70964 99.99683 0.9999683 4 0.9976179 1.995236 0.9999683 1.995299
;percentile 1.25E-02 -4.378827 0.01 0.0001 -3.719033 4.88E-07 9.76E-07 0.0001 9.76E-03
;percentile 2.63E-02 -3.638475 0.1 0.001 -3.090236 9.88E-06 1.98E-05 0.001 1.98E-02
;percentile 6.46E-02 -2.739097 1 0.01 -2.326375 2.29E-04 4.59E-04 0.01 4.59E-02
;percentile 0.1441802 -1.936691 5 0.05 -1.644874 2.38E-03 4.77E-03 0.05 9.54E-02
;percentile 0.2211483 -1.508922 10 0.1 -1.28156 6.97E-03 1.39E-02 0.1 0.1393407
;percentile 4.521852 1.508922 90 0.9 1.28156 0.5414743 1.082949 0.9 1.203276
;percentile 6.935764 1.936691 95 0.95 1.644874 0.6799145 1.359829 0.95 1.431399
;percentile 15.47301 2.739097 99 0.99 2.326375 0.8747137 1.749427 0.99 1.767098
;percentile 38.03395 3.638479 99.9 0.999 3.09024 0.9721138 1.944228 0.999 1.946174
;percentile 79.74052 4.378778 99.99 0.9999 3.718992 0.9944821 1.988964 0.9999 1.989163
;

;This program uses one or more of the following relationships for lognormals:
sigma = SQRT(2 * ALOG(mean / median))
sigma = SQRT(2 * ALOG(mean / mode) / 3)
sigma = SQRT(ALOG(median / mode))
sigma = ALOG(value1 / median) / z1
sigma = SQRT(ALOG(CV ^ 2 + 1))
sigma = ALOG(GSD); GSD = EXP(sigma)
sigma = ALOG(value1 / value2) / (z1 - z2); sigma = SQRT(mu - ALOG(mode))

;SQRT(EXP(sigma^2)-1)*EXP(sigma^2/2) = SD/median; !must be solved numerically!
median = mean * EXP(-sigma ^ 2 / 2)
median = mode * EXP(sigma ^ 2)
mu = ALOG(median)
mu = ALOG(mean) - sigma ^ 2 /2
mu = ALOG(mode) + sigma ^ 2
mu = ALOG(value1) + ALOG(value2 / value1) * (0-z1) / (z2-z1); median = EXP(mu)
mu = ALOG(value1) - sigma * z1 = ALOG(mode) + ALOG(CV ^ 2 + 1)
mode ^ 2 * SD ^ 2 - median ^ 4 + median ^ 3 * mode = 0 !numerically solved
SD ^ 2 / value1 ^ 2 = EXP(-2 * z1 * sigma + sigma ^ 2) * (EXP(sigma ^ 2) - 1)
[Note: Solve numerically; eqn. may yield 1 or 3 values of sigma for z1 > 1]
mean = median * EXP(sigma ^ 2 / 2); lnmean = ALOG(mean)
mode = EXP(mu - sigma ^ 2) = median * EXP(-sigma ^ 2); lnmode = ALOG(mode)
CV = SQRT(EXP(sigma ^ 2) - 1); CV = SD / mean; SD = CV * mean
variance = SD ^ 2 = EXP(2 * mu + sigma ^ 2) * (EXP(sigma ^ 2) - 1)
skewness = CV^3 + 3 * CV; kurtosis = CV^8 + 6 * CV^6 + 15 * CV^4 + 16 * CV^2
zmode = -sigma; zmean = sigma / 2; zmedian = 0
value = EXP(mu + zvalue * sigma); zvalue = (ALOG(value) - mu) / sigma
If mean < value then sigma = z1 + SQRT(z1 ^ 2 + 2 * ALOG(mean / value))
If mean > value then sigma = z1 - SQRT(z1 ^ 2 + 2 * ALOG(mean / value))
If mode > value then sigma = (-z1 + SQRT(z1 ^ 2 - 4 * ALOG(mode / value))) / 2
If mode < value then sigma = (-z1 - SQRT(z1 ^ 2 - 4 * ALOG(mode / value))) / 2