; $ID:	LNP_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	LNP_DEMO:	This Function returns DATE FROM A VALID PERIOD

; HISTORY:	May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO LNP_DEMO, PS=ps
  ROUTINE_NAME='LNP_DEMO'

;	Check influence of reduction in sampling on ACF

;	Can a randomly eliminated 10% of points serve to indicate the effect of reduced N on LNP

	PAL_36
	COLOR_DATA = 6
	COLOR_IDL = 16
	COLOR_SCARGLE = 21
  ps= 1
	SERIES = ['1','2','3','8_7','DAMPED','SARGASSO','MAB_SLOPE','GB_CENTRAL']
	HIGHEST_FREQUENCY=1000.
	HIGHEST_FREQUENCY=200.

;	GOTO,DEMO_SMOOTH

	SERIES_RANGE = [3,3] ;5

STOP
;	*********************************************************************************************
;	***** Demonstrate Proportionality between N samples and LNP of Data and LNP of INV_DATA *****
;	*********************************************************************************************
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR SERIES_=SERIES_RANGE[0],SERIES_RANGE[1]  DO BEGIN

		ASERIES=SERIES(SERIES_)

		TS=TIME_SERIES(ASERIES)
		TIMES = TS.TIME
		DATA=TS.DATA
;		===> NUMBER OF TARGET FREQUENCIES (NUMF)
		NUMF=2*N_ELEMENTS(data)

 		IF TS.PROD EQ 'CHLOR_A' THEN BEGIN
; 		===> CONVERT TIMES TO DECIMAL YEARS
			TIMES 			= JD_2DYEAR(TIMES)
			DATA = ALOG(DATA)
			numf=4*1024
		ENDIF

;		****************************************************************************************************
		IF PS THEN PSPRINT,FILENAME=ROUTINE_NAME+'_NumF_'+NUM2STR(NUMF)+'_'+aseries+'_LNP_1.PS',/FULL,/COLOR
;		****************************************************************************************************
		!P.MULTI=[0,2,3]

;		LLLLLLLLLLLLLLLLLLLLLL
		FOR nth = 1,3 DO BEGIN
			times_=subsample(times,nth)
			f_=subsample(DATA,nth)
			n_samples = N_ELEMENTS(f_)

;			***************************************
;			***** Demean and Detrend the data *****
;			***************************************
;			===> DETREND AND DEMEAN DATA
 			DETRENDED=DETREND(times_,DEMEAN(F_))

 			F_TXT = ASERIES
    	N_SAMPLES=N_ELEMENTS(DETRENDED)


;			*** LNP_TEST Using Original Data ***
			LABEL='DATA'+'!CN: '+NUM2STR(N_ELEMENTS(DETRENDED))
			TP=SPAN(times_)
    	T_AVG=TP/N_SAMPLES
			hifac=HIGHEST_FREQUENCY*(2*t_avg)
			P_DATA				=LNP_TEST(TIMES_-FIRST(TIMES_),DETRENDED,	WK1=WK1,	WK2=WK2,	OFAC=8,HIFAC=hifac,JMAX=JMAX)
			LABEL = LABEL+'!C'+ 'Peak: '+ NUM2STR(P_DATA[0],FORMAT='(F10.1)') + '!C'+ 'Period: '+ NUM2STR(WK1(JMAX),FORMAT='(F10.3)')

;			===> ACF Using Original Data
			LAG=FINDGEN(N_SAMPLES) & TP_ACF=TP
  		ACT=A_CORRELATE(DETRENDED, Lag  , /DOUBLE)
  		WIDTH=11
			TIME_FIRST_CROSS_ACT = ACF_FIRST_ZERO(ACT,Tp_ACF=Tp_ACF,WIDTH=WIDTH,SUBS=SUBS,SMO=SMO,  ERROR=error)
			LABEL = LABEL+'!C'+ 'ACT0: '+ NUM2STR(TIME_FIRST_CROSS_ACT,FORMAT='(F10.3)')

			PLOT,  WK1,WK2,/XLOG,/NODATA,XRANGE=[0.1,200],/XSTYLE & GRIDS,COLOR=34
			OPLOT, WK1,WK2,COLOR=COLOR_DATA
			s=COORD_2PLOT(.67,.8) 	& XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.8,COLOR=COLOR_DATA

;			*** LNP_TEST Using INV DFT ***
			LABEL='INV DFT'+'!CN: '+NUM2STR(N_ELEMENTS(DETRENDED))
   		Z_EXTEND=1 ; 1=YES
   		UPPER = NUMF
  		TIME_PER_BIN = TP/UPPER
  		IF Z_EXTEND THEN UPPER = UPPER/2
			HALF=0

;			===> DFT using FT_SCARGLE
			DFT_SCARGLE= FT_SCARGLE(TIMES_,	DETRENDED,NUMF=numf,NUF=nuf,NUP=nup,HALF=half,DFTS=DFTS,Tp=Tp,NO_EXTEND=NO_EXTEND)
			ACF_SCARGLE = FT_2ACF(DFT_SCARGLE)
			INV_SCARGLE	=	REAL_PART(FFT(DFT_SCARGLE,/INVERSE))
			INV_SCARGLE = INV_SCARGLE(0:UPPER)
			TIMES_NEW = Tp* (FINDGEN(N_ELEMENTS(INV_SCARGLE))/N_ELEMENTS(INV_SCARGLE))

			t_avg= 2*TP/N_ELEMENTS(INV_SCARGLE)

			hifac=HIGHEST_FREQUENCY*(t_avg)

			P_INV_SCARGLE	=LNP_TEST(TIMES_NEW,INV_SCARGLE,WK1=WK1_,	WK2=WK2_,	OFAC=8,HIFAC=hifac,JMAX=JMAX_)
			LABEL = LABEL+'!C'+ 'Peak: '+ NUM2STR(P_INV_SCARGLE[0],FORMAT='(F10.1)') + '!C'+ 'Period: '+ NUM2STR(WK1_(JMAX),FORMAT='(F10.3)')

			TP_ACF=2*TP
			WIDTH=11
    	TRAP=1

	  	TIME_FIRST_CROSS_SCARGLE = ACF_FIRST_ZERO(ACF_SCARGLE,Tp_ACF=Tp_ACF,WIDTH=WIDTH, SUBS=SUBS,SMO=SMO,  ERROR=error)
	  	LABEL = LABEL+'!C'+ 'ACF0: '+ NUM2STR(TIME_FIRST_CROSS_SCARGLE,FORMAT='(F10.3)')

			PLOT,  WK1_,WK2_,/XLOG,/NODATA,XRANGE=[0.1,200],/XSTYLE & GRIDS,COLOR=34
			OPLOT, WK1_,WK2_,COLOR=COLOR_SCARGLE
			s=COORD_2PLOT(.67,.8) & XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.8,COLOR=COLOR_SCARGLE

		ENDFOR
	IF PS THEN PSPRINT ELSE STOP
	ENDFOR




DEMO_SMOOTH:
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR SERIES_=5,N_ELEMENTS(SERIES)-1L DO BEGIN
		ASERIES=SERIES(SERIES_)

		TS=TIME_SERIES(ASERIES)
		TIMES = TS.TIME
		DATA=TS.DATA
;		===> NUMBER OF TARGET FREQUENCIES (NUMF)
		NUMF=2*N_ELEMENTS(data)

 		IF TS.PROD EQ 'CHLOR_A' THEN BEGIN
; 		===> CONVERT TIMES TO DECIMAL YEARS
			TIMES 			= JD_2DYEAR(TIMES)
			DATA = ALOG(DATA)
			numf=4*1024
		ENDIF

;		****************************************************************************************************
		IF PS THEN PSPRINT,FILENAME=ROUTINE_NAME+'_NumF_'+NUM2STR(NUMF)+'_'+aseries+'_LNP_2.PS',/FULL,/COLOR
;		****************************************************************************************************
		!P.MULTI=[0,3,4]


;			***************************************
;			***** Demean and Detrend the data *****
;			***************************************
;			===> DETREND AND DEMEAN DATA
 			DETRENDED=DETREND(times,DEMEAN(DATA))

 			F_TXT = ASERIES
    	N_SAMPLES=N_ELEMENTS(DETRENDED)

;			*** LNP_TEST Using Original Data ***
			LABEL='DATA'+'!CN: '+NUM2STR(N_ELEMENTS(DETRENDED))
			TP=MAX(TIMES)-MIN(TIMES)
    	T_AVG=TP/N_SAMPLES
			hifac=HIGHEST_FREQUENCY*(2*t_avg)
			P_DATA				=LNP_TEST(TIMES-FIRST(TIMES),DETRENDED,	WK1=WK1,	WK2=WK2,	OFAC=8,HIFAC=hifac,JMAX=JMAX)
			LABEL = LABEL+'!C'+ 'Peak: '+ NUM2STR(P_DATA[0],FORMAT='(F10.1)') + '!C'+ 'Period: '+ NUM2STR(WK1(JMAX),FORMAT='(F10.3)')

;			===> ACF Using Original Data
			LAG=FINDGEN(N_SAMPLES) & TP_ACF=TP
  		ACT=A_CORRELATE(DETRENDED, Lag  , /DOUBLE)
  		WIDTH=11
			TIME_FIRST_CROSS_ACT = ACF_FIRST_ZERO(ACT,Tp_ACF=Tp_ACF,WIDTH=WIDTH,SUBS=SUBS,SMO=SMO,  ERROR=error)
			LABEL = LABEL+'!C'+ 'ACT0: '+ NUM2STR(TIME_FIRST_CROSS_ACT,FORMAT='(F10.3)')

			PLOT,  WK1,WK2,/XLOG,/NODATA,XRANGE=[0.1,200],/XSTYLE,TITLE='DATA' & GRIDS,COLOR=34
			OPLOT, WK1,WK2,COLOR=COLOR_DATA
			s=COORD_2PLOT(.67,.8) 	& XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.8,COLOR=COLOR_DATA


			FOR WIDTH = 3,25,2 DO BEGIN
;				SMOOTH PERIODOGRAM
				PLOT,  WK1,WK2,/XLOG,/NODATA,XRANGE=[0.1,200],/XSTYLE,TITLE='DANIELLE Width:'+NUM2STR(WIDTH) & GRIDS,COLOR=34
				OPLOT, WK1,FILTER_DANIELL(WK2,WIDTH),COLOR=COLOR_DATA
		ENDFOR
	IF PS THEN PSPRINT ELSE STOP
	ENDFOR



;		****************************************************************
;		***** Demonstrate Periodogram Smoothing via DANIELL FILTER *****
;		****************************************************************





END; #####################  End of Routine ################################
