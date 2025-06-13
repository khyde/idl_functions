PRO STATS_DEMO   ; JULYU 18, 2003
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

DO_CV_LOG_TRANSFORMED = 0

DO_VARIANCE						= 1
DO_COMPARE_MSE				 = 1

;	******************************
	IF DO_VARIANCE GE 1 THEN BEGIN
		NUM=[1,1,1,2,5.]
		S=STATS(NUM)
		V = TOTAL(( NUM- MEAN(NUM))^2)/ (N_ELEMENTS(NUM)-1)
		V_IDL = VARIANCE(NUM)

		PRINT, 'VARIANCE IDL, VARIANCE EQ, VARIANCE STATS'
		PRINT, V_IDL, V, S.VAR
		PRINT & PRINT & PRINT

	ENDIF

;	******************************
	IF DO_COMPARE_MSE GE 1 THEN BEGIN
		NUM=[1,1,1,2,5.,6]
		N= FLOAT(N_ELEMENTS(NUM))
		S=STATS(NUM)
 		S2=STATS2(NUM,MEAN(NUM))
 		M = MEAN(NUM)
 		MM = REPLICATE(M,N)
 		MSE =  ( TOTAL(NUM - MM)^2) /N
 		PRINT,'MSE: ',MSE
 		STOP

;		Campbell MSE = m^2 + ((N-1)/N)   * var
		NUM=[1,1,1,2,5.]
		N= FLOAT(N_ELEMENTS(NUM))
		S=STATS(NUM)
 		VAR = VARIANCE(NUM)
 		MSE =  (MEAN(NUM))^2 + ((N-1)/N)*VAR

;		EQUATION 9

 		RMSE = SQRT(MSE)
 		PRINT, 'RMSE  ALTERNATE WAY:' , RMSE
 		STOP

		PRINT, 'VARIANCE IDL, VARIANCE EQ, VARIANCE STATS'
		PRINT, V_IDL, V, S.VAR

	ENDIF


IF DO_CV_LOG_TRANSFORMED GE 1 THEN BEGIN
; ===> Demonstrate the use of CV for Log-Transformed data
	C= [2,4,8.]
	C=C*0.01
	PRINT,'RAW'
	S=STATS(C)
	PRINT,'CV: ', s.CV

	PRINT,'LOG10-TRANSFORMED'
	S= STATS(ALOG10(C))
	CV  = 100.*(10.^S.STD -1.0)
	PRINT,'CV: ', CV
	ST,S
	PRINT, '10^S.STD', 10^S.STD

	PRINT,'LN-TRANSFORMED'
	S= STATS(ALOG(C))
	CV  = 100.*(EXP(S.STD) -1.0)
	PRINT,'CV: ', CV
	PRINT, 'EXP(S.STD)', EXP(S.STD)



	RESULT=RANDOMN(SEED,/GAMMA)

ENDIF ; IF DO_CV_LOG_TRANSFORMED GE 1 THEN BEGIN

;FUNCTION lognormal,lnr,mach=mach
;
;  default,mach,2
;  sig=sqrt(alog(1.+0.25*mach^2))
;  pdf=exp(-0.5*(lnr+0.5*sig^2)^2 /sig^2)  / (sig*sqrt(2.*!pi))
;  return,pdf
;END










END ; OF PROGRAM
