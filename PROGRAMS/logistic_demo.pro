; $ID:	LOGISTIC_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO LOGISTIC_DEMO, ERROR = error

;+
; NAME:
;		LOGISTIC_DEMO
;
; PURPOSE:
;		This procedure is a DEMO for the Logistic Equation
;
; CATEGORY:
;		EQUATION
;
; CALLING SEQUENCE:
;
;		LOGISTIC_DEMO
;
; INPUTS:
;		NONE
;
;
; OUTPUTS:
;		Plot
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written April 5, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'LOGISTIC_DEMO'

	DO_SIMPLE_SYMMETRIC_SIGMOID = 1
	DO_2_PARAMETER_SYMMETRIC_SIGMOID = 1

	DO_GENERALIZED_LOGISTIC = 0
	DO_IDL_FORMULA = 0
	DO_LOGISTIC =0
	DO_TANH = 0

	DO_TANH_VS_TRICUBE_BICUBE = 10


	PSPRINT,FILENAME=ROUTINE_NAME+'.PS',/FULL,/COLOR
	!P.MULTI=0
	PAL_36
;	***********************************
	IF DO_SIMPLE_SYMMETRIC_SIGMOID GE 1 THEN BEGIN
;	***********************************
;	===> Mathworld.wolfram.com
;	y = 1/ (1+exp(-x))
;	If y[0] = 1/2 then it is the solution to the ordinary differential equation:
;	dy/dx=y(1-y)
	X=FINDGEN(201)/10. - (10)
	y = 1.0/ (1+EXP(-x))
	PLOT, X,Y,/NODATA,TITLE='Simple Symmetric Sigmoid: y = 1/ (1+exp(-x))'
	GRIDS,COLOR=34
	OPLOT,X,Y,COLOR=21,THICK=3

	ENDIF


;	***********************************
	IF DO_2_PARAMETER_SYMMETRIC_SIGMOID GE 1 THEN BEGIN
;	***********************************
; Y = 1/( 1+EXP(-(a+b*X))
	TXT_EQUATION = '2 Parameter Symmetric Sigmoid: Y = 1/( 1+EXP(-(a+b*X)) '
	X=FINDGEN(401)/10. - (20)
	aa = FLOAT([-8,-5,-2,0,2,5,8])

	aa = [-2,-1,0.0,1,2]

	bb = [-2,-1,-0.5, 0.5,1,2]
;	bb = [ 0,0.2,0.5,1,2]
;	BB= -1*BB

  set_pmulti,n_elements(aa)

	Y_POS = 0.5
		FOR _b = 0,N_ELEMENTS(bb)-1 DO BEGIN
			b = bb(_b)
			start = 1
;			===> Hold b at 1 and vary a
		FOR _a = 0,N_ELEMENTS(aa)-1 DO BEGIN
			a = aa(_a)
			PRINT,A,B
			Y = 1/( 1+EXP(-(a+b*X)) )
			IF START EQ 1 THEN BEGIN
				PLOT, X,Y,/NODATA,XRANGE=[-12,12],/XSTYLE,YRANGE=[0,1],TITLE=TXT_EQUATION
				GRIDS,COLOR=34
				START=0
			ENDIF
			OPLOT,X,Y,COLOR=21,THICK=3
			XYOUTS2,5,0.8,'B= '+STRTRIM(ROUNDS(B,1),2)
			OK=WHERE_NEAREST(Y,Y_POS,NEAR=5)

			XPOS = X(OK[0])
			TXT_A = 'A!C'+STRTRIM(ROUNDS(A),2)
			XYOUTS2,XPOS,Y_POS,TXT_A,ALIGN=[0.5,0.5],CHARSIZE=0.75
		ENDFOR
	ENDFOR





		PSPRINT
	STOP

	ENDIF


;	***********************************
	IF DO_IDL_FORMULA GE 1 THEN BEGIN
;	***********************************
		CHL = 0.5

		A= 1.5
		b= 0.1

		C= 0.2
		Z= INTERVAL([0,2.0],.01)
		y =   1./(A + B*C^Z)
		y =    CHL + B*C^Z

		y =    CHL  * 1.0/(B*C^Z)
		plot, Z,y

		X=FINDGEN(101)/10. - (6) &PLOT, z,   1+chl+TANH(X)

	ENDIF

	IF DO_GENERALIZED_LOGISTIC GE 1 THEN BEGIN

;	A: Lower Asymptote
;	C: Upper Asymptote minus C
;	M: The time of maximum growth
;	B: Growth Rate
;	T: Affects near which asymptote growth occurs

  A = 1 & C = 55& M = 26& B = 5 & T = 21
	A = 1 ; CHL
	C = 55
	M = 26
	B = 11
	T = 44

PAL_36
SETCOLOR,255
X = FINDGEN(100)
CUM =  A + (C/(1+T*EXP(-B*(X-M)*1./T)))



!P.MULTI=[0,1,3]
PLOT, X,CUM,/nodata
GRIDS,COLOR=TC(34)
OPLOT, X,CUM,COLOR=TC(8),THICK=3
VPROFILE = SHIFT(CUM,1)

VPROFILE = CUM - VPROFILE
VPROFILE[0] = CUM[0]
VPROFILE(1:*) =  VPROFILE(1:*)
OPLOT, X,VPROFILE

PLOT, X,VPROFILE

PLOT, CUM,VPROFILE

PRINT, TOTAL(VPROFILE)

STOP
	ENDIF


;	******************************
	IF DO_LOGISTIC GE 1 THEN BEGIN
;	******************************

	X = FINDGEN(1001)/1000. - 0.5
	A= 0
	B= 7*!PI
	P = 1./ (1.+EXP(-(A+B*X)) )


PAL_36
	RANGE = [0.001,0.999]
PLOT, X,P
OK=WHERE(P GE RANGE[0] AND P LE RANGE[1],COUNT)

  PLOT_EVENT,[FIRST(X[OK]),LAST(X[OK])],COLOR=TC(11)

STOP
  p = EXP(- (X-MEAN(X))/.032)
  PLOT, X,P
	ENDIF



;	*******************************
	IF DO_TANH GE 1 THEN BEGIN
;	*******************************
	RANGE = [0.001,0.999]
	P = 1;!PI*22
	X = (FINDGEN(1001)-500)/500.
	F=  (TANH( X*!PI*P )/2.0)+0.5
	!P.MULTI = [0,2,2]
	PAL_36
	PLOT, X,F
	OPLOT, X,F,COLOR=TC(21)


	OK=WHERE(F GE RANGE[0] AND F LE RANGE[1],COUNT)
	XX=X[OK]
	FF = F[OK]
  PLOT_EVENT,[FIRST(XX),LAST(XX)],COLOR=TC(10)
	PLOT,F(0:499) ,1- REVERSE(F(500:*)),PSYM=3
	PLOT, XX,FF

ENDIF




;	*********************************************
	IF DO_TANH_VS_TRICUBE_BICUBE GE 1 THEN BEGIN
;	*********************************************
	RANGE = [0.001,0.999]
	!P.MULTI=[0,1,2]
;	!P.MULTI=0
	N = 1001
	CEN = N/2
	P = 1;!PI*22
	X = (FINDGEN(N)-CEN)/CEN
	F_TANH=  (TANH( X*!PI*P )/2.0)+0.5
	PAL_36
	PLOT, X,F_TANH
	GRIDS,COLOR=35
	OPLOT, [-1,1], [0,1],COLOR=TC(33)
	OPLOT, X,F_TANH,COLOR=TC(6)

;	OK=WHERE(F_TANH GE RANGE[0] AND F LE RANGE[1],COUNT)
;	XX=X[OK]
;	FF = F[OK]

;	===> OVERPLOT TRICUBE SIGMOID FUNCTION
	W= WEIGHT_TRICUBE(FINDGEN(N),CEN)

	F_TRICUBE=CUMULATE(W)/TOTAL(W)

 	OPLOT, X,F_TRICUBE,COLOR=TC(26),THICK=3


; ==> OVERPLOT SIMPLE SQUARE SIGMOID FUNCTION
	F_BISQUARE = (1 - X^2)

;	===> INTEGRAL OF (1 - X^2) IS : (1.0 + 1.5*X -  (X^3)/2)/2 ;;
	F_BISQUARE_INT = (1.0+1.5*X-(X^3)/2)/2 ;
	OPLOT, X, F_BISQUARE

	OPLOT, X,F_BISQUARE_INT,COLOR=TC[0]
 ;	PLOT, F_TRICUBE-F_BISQUARE

sigma = 3
  oplot, x,   1.0+1.5*X -(X^3)/2  -  3*X^4/2 ,COLOR=TC(10)

	ENDIF

PSPRINT
STOP
	END; #####################  End of Routine ################################
