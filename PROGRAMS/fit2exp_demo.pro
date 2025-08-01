PRO FIT2EXP_DEMO


  TITLE = '1995-06-24  W9507 N10'
	LIGHT = [1350,1040,869,729,571,471,393,333,263,215,175,148,123,102,81.6,66.8,56.7,44.7,38.1,33.3,29.4,25.2,21.7,20.9,18.9,17.0,15.0,13.4,$
		12.8,11.7,10.7,9.6,8.6,7.9,7.4,7.0,6.4,5.8,5.3,4.9,4.5,4.5]
	DEPTH = [1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18,18.5,19,19.5,20,20.5,21,21.5,22]
	STRUCT=LIGHT_EXTINCTION_COEFFICIENT(DEPTH=DEPTH,LIGHT=LIGHT, TITLE=TITLE, /SHOW)


 ;; d=expo_fit(depth,(light),a)



	x = FLOAT(DEPTH)
	y =	ALOG(FLOAT(LIGHT))

;	===> Create 2 by x array)
	XX = FLTARR(2,N_ELEMENTS(X)) & XX(0,*) = (X) & 	XX(1,*) = ALOG(X)
	COEFFS_P2 = REGRESS(XX,Y, CONST=CONST_P2, MCORRELATION=CORRELATION_P2, FTEST=FTEST_P2, SIGMA=SIGMA_P2, STATUS=STATUS_P2 , YFIT=YFIT_P2)

STOP

 A=FIT2EXP(DEPTH, LIGHT);, Param, Sigma_, X0, HELP=Help, CHI2=Chi2, DOF=DOF, $
         ;HERE=Here, TITLE=Title, XRANGE=Xrange, YRANGE=Yrange, _EXTRA=Plot_keys


STOP

END
