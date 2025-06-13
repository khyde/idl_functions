; $ID:	ACF_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	ACF_DEMO:	This Function Demonstrates the ACF (Autocorrelation Function)

; HISTORY:	May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO ACF_DEMO, PS=ps
  ROUTINE_NAME='ACF_DEMO'

	PAL_36
	COLOR_DATA = 6
	COLOR_IDL = 16
	COLOR_SCARGLE = 21
  ps= 1
	SERIES = ['1','2','3','8_7','DAMPED','SARGASSO','MAB_SLOPE','GB_CENTRAL']
	HIGHEST_FREQUENCY=1000.
	HIGHEST_FREQUENCY=100.

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



;	*********************************************************************************************
;	***** Demonstrate Proportionality between N samples and LNP of Data and LNP of INV_DATA *****
;	*********************************************************************************************
	IF PS THEN PSPRINT,FILENAME=ROUTINE_NAME+'_NumF_'+NUM2STR(NUMF)+'_'+aseries+'_ACF.PS',/FULL,/COLOR
;		****************************************************************************************************
	!P.MULTI=[0,3,5]
		times_= times
		f_=DATA
		n_samples = N_ELEMENTS(f_)

;		***************************************
;		***** Demean and Detrend the data *****
;		***************************************
;		===> DETREND AND DEMEAN DATA
 		F_=DETREND(times_,DEMEAN(F_),STRUCT=struct)


 		F_TXT = ASERIES
    N_SAMPLES=N_ELEMENTS(F_)


;		*** ACT Using Original Data ***
		LABEL='DATA'+'!CN: '+NUM2STR(N_ELEMENTS(F_))
		TP=SPAN(times_)
    T_AVG=TP/N_SAMPLES

		LAG=FINDGEN(N_SAMPLES) & TP_ACF=TP
  	ACT=A_CORRELATE(F_, Lag  , /DOUBLE)
  	PLOT,ACT/ACT[0],TITLE='ACT DATA'
  	WIDTH=11
		TIME_FIRST_CROSS_ACT = ACF_FIRST_ZERO(ACT,Tp_ACF=Tp_ACF,WIDTH=WIDTH,SUBS=SUBS,SMO=SMO,  ERROR=error)
		LABEL = LABEL+'!C'+ 'ACT0: '+ NUM2STR(TIME_FIRST_CROSS_ACT,FORMAT='(F10.3)')
		s=COORD_2PLOT(.67,.8, /TO_DATA) 	& XYOUTS,S.X,S.Y,/DATA,LABEL,CHARSIZE=0.6,COLOR=COLOR_DATA

  	Z_EXTEND=1 ; 1=YES
   	UPPER = NUMF
  	TIME_PER_BIN = TP/UPPER
  	IF Z_EXTEND THEN UPPER = UPPER/2
		HALF=0

;		===> DFT using FT_SCARGLE
		DFT_SCARGLE	= FT_SCARGLE(TIMES_,	F_,NUMF=numf,NUF=nuf,NUP=nup,HALF=half,DFTS=DFTS,Tp=Tp,NO_EXTEND=NO_EXTEND)
		ACF_SCARGLE = FT_2ACF(DFT_SCARGLE)
		TIMES_NEW = Tp* (FINDGEN(UPPER)/UPPER)
		t_avg= 2*TP/UPPER
		TP_ACF=2*TP

;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR WIDTH = 3,11,2 DO BEGIN
;			LLLLLLLLLLLLLLLLLLLLLL
			FOR TRAP =0,1 DO BEGIN
;				*** ACF Using INV DFT ***
				LABEL='INV DFT'+'!CN: '+NUM2STR(N_ELEMENTS(DFT_SCARGLE))
				TITLE='ACF Scargle '
				IF TRAP EQ 0 THEN TITLE = TITLE + ' Smooth Filter Width: '			+NUM2STR(WIDTH) $
										 ELSE TITLE = TITLE + ' Trapezoidal Filter Width: '	+NUM2STR(WIDTH)
				PLOT,ACF_SCARGLE/ACF_SCARGLE[0],TITLE=TITLE,XRANGE=[0,100],/NODATA
				OPLOT, ACF_SCARGLE/ACF_SCARGLE[0],COLOR=0
				GRIDS,COLOR=34
		  	TIME_FIRST_CROSS_SCARGLE = ACF_FIRST_ZERO(ACF_SCARGLE,Tp_ACF=Tp_ACF,WIDTH=WIDTH,TRAP=trap,SUBS=SUBS,SMO=SMO,  ERROR=error)
		  	OPLOT, SMO,COLOR=21
		  	LABEL = LABEL+'!C'+ 'ACF0: '+ NUM2STR(TIME_FIRST_CROSS_SCARGLE,FORMAT='(F10.3)')
				S=COORD_2PLOT(.67,.8) & XYOUTS,S.X,S.Y,LABEL,CHARSIZE=0.6,COLOR=COLOR_SCARGLE
			ENDFOR
		ENDFOR

		IF PS THEN PSPRINT ELSE STOP
 	ENDFOR ; FOR SERIES_=5,N_ELEMENTS(SERIES)-1L DO BEGIN


END; #####################  End of Routine ################################
