; $ID:	LINFIT_DEMO.PRO,	2014-12-18	$

 PRO LINFIT_DEMO, COLORS
;+
; NAME:
; 	LINFIT_DEMO

;		This Program demonstrates IDL'S LINFIT_DEMO PROGRAM

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='LINFIT_DEMO'
	PAL_36
; Define two n-element vectors of paired data:
	X = [-3.20, 4.49, -1.66, 0.64, -2.43, -0.89, -0.12, 1.41, $
      2.95, 2.18, 3.72, 5.26]
	Y = [-7.14, -1.30, -4.26, -1.90, -6.19, -3.98, -2.87, -1.66, $
     -0.78, -2.61, 0.31, 1.74]


	!P.MULTI=[0,2,2]
	PLOTXY,X,Y,PSYM=1


; Define an n-element vector of Poisson measurement errors:
	measure_errors = SQRT(ABS(Y))

; Compute the model parameters, A and B, and print the result:
	result = LINFIT(X, Y, MEASURE_ERRORS=measure_errors,YFIT=YFIT)
	PRINT, result
	OPLOT, X,YFIT,COLOR=TC(21)
	PLOT, X, YFIT-Y,PSYM=1
	STOP



END; #####################  End of Routine ################################



