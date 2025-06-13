; $ID:	PLOT_OC_STATS.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; This program plots statistical relationships between Model and Measured Chlorophyll
;		Regression Scatterplot
;		Quantile-quantile plot
;		Log (Measured/Model)
;		Cumulative RMS

; NOTES:
 ;
; HISTORY:
;	 May 5, 1999	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882

; MODIFICATION HISTORY:
;		Written  1997  by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

  PRO PLOT_OC_STATS ,x,y, NOTES=notes,NOTE_SIZE=note_size, $
        TITLE=title,ALG_TITLE=alg_title,$
        QUIET=quiet, MODELX=modelx,MODELY=modely,$
         COEFFS=coeffs,ratio=ratio,MODEL_X_TITLE=MODEL_X_TITLE,$
         DECIMALS=decimals, CHL_AXIS = CHL_AXIS, BR_AXIS  = br_axis, $
        NO_NOTES=NO_NOTES,NO_TITLE=no_title, NO_DATE=no_date,$
        CHAR_SCALE=char_scale,LL=ll, BINSIZE=binsize,$
        PAGE_TITLE=PAGE_TITLE,PAGE_CHARSIZE=PAGE_CHARSIZE,$
        SINGLE=single,ALG_FORMULA=ALG_FORMULA,$

				CW_BR=CW_BR, CW_CHL=CW_CHL,$
				PANELS = PANELS,AUTHORS=authors,$
         _EXTRA=_extra

	ROUTINE_NAME='PLOT_OC_STATS'


;	**********************************
;	*** Remove any missing values  ***
;	**********************************
	OK=WHERE(X NE MISSINGS(X) AND Y NE MISSINGS(Y),COUNT)
	IF COUNT EQ 0 THEN STOP
	XX = X[OK]
	YY = Y[OK]


 	PAL_36
  grid_color=35
  grid_thick=2

  TITLE_BLANK=''
  CHL_NAME 	= UNITS('CHLOR_A',/NAME)
  Chl_UNITS = UNITS('CHLOR_A',/UNIT)


  IF NOT KEYWORD_SET(NOTES) THEN NOTES = ''
  IF NOT KEYWORD_SET(NOTE_SIZE) THEN NOTE_SIZE = 0.5
  IF NOT KEYWORD_SET(TITLE) THEN TITLE = ''
  IF NOT KEYWORD_SET(ALG_TITLE) THEN ALG_TITLE = ''
  IF NOT KEYWORD_SET(DECIMALS) THEN DECIMALS = 4
  IF N_ELEMENTS(binsize) NE 1 THEN binsize = .1
  IF N_ELEMENTS(PAGE_CHARSIZE) NE 1 THEN PAGE_CHARSIZE = 2
  IF N_ELEMENTS(PAGE_TITLE) NE 1 THEN PAGE_TITLE = ALG_TITLE

  IF N_ELEMENTS(BR_AXIS) NE 2 THEN BR_AXIS = [0.1,20]
  IF N_ELEMENTS(CHL_AXIS) NE 2 THEN CHL_AXIS = [0.001,100]

  IF KEYWORD_SET(NO_TITLE) THEN TITLE =''
  IF NOT KEYWORD_SET(CHAR_SCALE) THEN CHAR_SCALE=1.0
  IF N_ELEMENTS(ALG_FORMULA) NE 1 THEN ALG_FORMULA=''

	IF N_ELEMENTS(PANELS) EQ 0 THEN _PANELS = [1,2,3,4,5,6] ELSE _PANELS = PANELS

  SET_PMULTI,N_ELEMENTS(_PANELS)
  !X.OMARGIN=[2,4]
  !Y.OMARGIN=[2,5]


  XTICKNAME=['0.01','0.1','1','10','100']
  YTICKNAME=['0.01','0.1','1','10','100']


; ****************************************************************************************
	OK=WHERE(_PANELS EQ 1,COUNT)
  IF COUNT EQ 1 THEN BEGIN
	  IF KEYWORD_SET(SINGLE) THEN BEGIN
	    !P.MULTI= 0
	    PSPRINT,/COLOR,/HALF,FILENAME=title+'_A.PS'
	  ENDIF

	  PLOTXY, XX,YY,/loglog,XRANGE=[.01,100.],YRANGE=[.01,100.], XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME,$
	            DECIMALS=DECIMALS,params=[1,2,3,4,8,10,11],stats_pos=[.02,.99],$
	            XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1 ,$
	            TITLE= TITLE_BLANK ,$
	            XTITLE='!8In Situ!X '	+	CHL_NAME + CHL_UNITS,  YTITLE='Model ' + CHL_NAME + CHL_UNITS,$
	            stats_charsize=0.85*char_scale,REG_LINESTYLE=31,$
	            /one2one,psym=1,SYMSIZE=.7*!P.SYMSIZE,color=0,yMARGIN=[4,2], CHARSIZE=1.5, QUIET=quiet,$
	            grid_color=grid_color,grid_thick=grid_thick

	 ; grids,[0.01,0.1,1.0,10.0,100.0],[0.01,0.1,1.0,10.0,100.0],color=35,linestyle=0,thick=2
	  one2one,ratio= 5 ,linestyle=1
	  one2one,ratio=.2 ,linestyle=1

	  XYOUTS,33,0.02,/DATA,'A',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN=0.5
	  FRAME,/PLOT,COLOR=0,THICK=2
	  IF KEYWORD_SET(SINGLE) THEN PSPRINT
	 ENDIF ; PANELS


; ****************************************************************************************

	OK=WHERE(_PANELS EQ 2,COUNT)
  IF COUNT EQ 1 THEN BEGIN

	  IF KEYWORD_SET(SINGLE) THEN BEGIN
	    !P.MULTI= 0
	     PSPRINT,/COLOR,/HALF,FILENAME=TITLE+'_B.PS'
	  ENDIF
; 	====================>
; 	Quantile-Quantile Plot of in situ vs model
  	q= QUANTILE( (XX), (YY) , /LOG,  SYMSIZE=.25*!P.SYMSIZE,$
            XRANGE=[.01,100],YRANGE=[.01,100],$
            XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1 , XTICKNAME=XTICKNAME,YTICKNAME=YTICKNAME, $
            TITLE=  TITLE_BLANK ,$
            XTITLE='!8In Situ!X '	+	CHL_NAME + ' Quantiles' + CHL_UNITS,$
            YTITLE='Model '	+	CHL_NAME + ' Quantiles' + CHL_UNITS,$
            YMARGIN=[4,2], CHARSIZE=1.5 ,$
            ONE_COLOR=TC(21),ONE_THICK=1,LINESTYLE=0, $
            psym=2,GRIDS_COLOR=grid_color,GRIDS_LINESTYLE=0,GRIDS_THICK=grid_thick )
            ;    ONE_COLOR=34,ONE_THICK=11,LINESTYLE=0, $

	  XYOUTS,33,0.02,/DATA,'B',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN=0.5
	  FRAME,/PLOT,COLOR=0,THICK=2
	  IF KEYWORD_SET(SINGLE) THEN PSPRINT
	 ENDIF ; PANELS



; ****************************************************************************************
; HISTOGRAM OF  ALL, MODEL
;  IF NOT KEYWORD_SET(QUIET) THEN BEGIN

	OK=WHERE(_PANELS EQ 3,COUNT)
  IF COUNT EQ 1 THEN BEGIN

	  IF KEYWORD_SET(SINGLE) THEN BEGIN
	    !P.MULTI= 0
	     PSPRINT,/COLOR,/HALF,FILENAME=TITLE+'_C.PS'
	  ENDIF


	    HISTPLOT,alog10(YY/XX),    binsize=.05,xrange=[-1,1],$
	             xtitle='Log(Model Chl!8a!X/!8In Situ!X Chl!8a!X)',title=TITLE_BLANK ,$
	             xticks=8,params=[0,1,2,5,6,8,11,12],decimals=3,charsize=1.5,$
	             /lab_none,/cum_none,yMARGIN=[4,2],xmargin=[10,3] ,bar_color=34,$
	             /bar_opaque,$
	             GRIDS_COLOR=grid_color,GRIDS_LINESTYLE=0,GRIDS_THICK=grid_thick,$
	             STATS_CHARSIZE=0.85*CHAR_SCALE

    	OPLOT,[0.0,0.0],[0.0,10000],THICK=2

	   XYOUTS,0.875,6,/DATA,'C',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN=0.5
	   FRAME,/PLOT,COLOR=0,THICK=2
	   IF KEYWORD_SET(SINGLE) THEN PSPRINT
		ENDIF


; ****************************************************************************************
	OK=WHERE(_PANELS EQ 4,COUNT)
  IF COUNT EQ 1 THEN BEGIN

	  IF KEYWORD_SET(SINGLE) THEN BEGIN
	    !P.MULTI= 0
	     PSPRINT,/COLOR,/HALF,FILENAME=TITLE+'_D.PS'
	  ENDIF

; 	====================>
; 	Relative Frequency Plot of in situ vs model


	  n_set = 'N= '+STRTRIM(N_ELEMENTS(XX),2)
	  RF_LOG,XX,label='!8In Situ!X Chl!8a!X', THICK=15,LINESTYLE=0,color=0 ,min=0.01,max=100.0, XTICKNAME=XTICKNAME, $
	         TITLE=TITLE_BLANK,XTITLE= CHL_NAME,/NO_N,LTITLE=N_SET ,$
	         LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.72,.88],TSIZE=.7*char_scale, yMARGIN=[4,2], CHARSIZE=1.5 ,binsize=BINSIZE,$
	         GRIDS_COLOR=grid_color,GRIDS_LINESTYLE=0,GRIDS_THICK=grid_thick

	  RF_LOG,XX,OVERPLOT=0,          THICK=15,LINESTYLE=0,color=34 ,min=0.01,max=100.0,$
	         LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.72,.88],TSIZE=.7, /NO_N                      ,binsize=BINSIZE

	  RF_LOG,XX,OVERPLOT=0,          THICK=1,color=0 ,min=0.01,max=100.0,$
	         LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.72,.88],TSIZE=.7, /NO_N     , PSYM=1,SYMSIZE=0.5                 ,binsize=BINSIZE




	  RF_LOG,YY,label='Model Chl!8a!X', THICK=5,LINESTYLE=0,color=0,min=0.01,max=100.0,$
	         overplot=2,  /NO_N  ,LSIZE=.7*char_scale ,LPOS=[.63,.84,.72,.88]                   ,binsize=BINSIZE

	  XYOUTS,33,0.206,/DATA,'D',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN=0.5
	  FRAME,/PLOT,COLOR=0,THICK=2
	  IF KEYWORD_SET(SINGLE) THEN PSPRINT
	ENDIF


; *********************************************************************************
	OK=WHERE(_PANELS EQ 5,COUNT)
  IF COUNT EQ 1 THEN BEGIN

	 	IF KEYWORD_SET(SINGLE) THEN BEGIN
	    !P.MULTI= 0
	     PSPRINT,/COLOR,/HALF,FILENAME=TITLE+'_E.PS'
	  ENDIF

	  IF N_ELEMENTS(RATIO) GE 1 THEN BEGIN
	   XRANGE = BR_AXIS

		IF KEYWORD_SET(LL) THEN BEGIN
		  IF LL EQ 'LL' THEN xlog = 1
		  IF LL EQ 'NL' THEN xlog = 0
		ENDIF ELSE BEGIN
		  XLOG = 1
		ENDELSE


	  yrange=CHL_AXIS
	  YTICKNAME= NUM2STR(STRING(INTERVAL(ALOG10(CHL_AXIS),BASE=10),FORMAT='(F8.3)'),TRIM=2)

	  PLOT,/ylog,XLOG=xlog,ratio,XX,XRANGE=XRANGE,YRANGE=yrange, XSTYLE=1,YTICKNAME=YTICKNAME,$
	            XTITLE=MODEL_X_TITLE,$
	            XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1 ,$
	            TITLE= TITLE_BLANK ,$
	            YTITLE= CHL_NAME,$
	            color=0,xmargin=[10,3],yMARGIN=[4,2], CHARSIZE=1.5,PSYM=1,SYMSIZE=.7*!P.SYMSIZE,/NODATA,_EXTRA=_extra

	IF KEYWORD_SET(LL) THEN BEGIN
	  IF LL EQ 'NL' THEN BEGIN

	    grids,[INTERVAL(XRANGE,0.5)],$
	      [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
	      .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,thick=2
	  ENDIF
	  IF LL EQ 'LL' THEN BEGIN
	    grids,XX=[.1,.2,.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
	      YY=[.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
	      .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0
	  ENDIF
	ENDIF

	  OPLOT, ratio,XX,color=0, PSYM=1,SYMSIZE=.7*!P.SYMSIZE
	  OPLOT, ratio,XX,color=0, PSYM=1,SYMSIZE=.7*!P.SYMSIZE

	  OPLOT, modelX, MODELY,THICK=3,COLOR=21
	  OPLOT, modelX, MODELY,THICK=1,COLOR=255

		IF N_ELEMENTS(CW_BR) EQ 1 AND N_ELEMENTS(CW_CHL) EQ 1 THEN BEGIN
	 	  PLOTS,CW_BR,CW_CHL,PSYM=4,COLOR=6,/NOCLIP
	 	  XYOUTS,CW_BR,CW_CHL,/DATA,'CW',CHARSIZE=0.55
		ENDIF

	  XYOUTS,10.0^!x.crange[1],15, /DATA,'E',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN= 1.2

	  FRAME,/PLOT,COLOR=0,THICK=2
	  IF KEYWORD_SET(SINGLE) THEN PSPRINT

	  ENDIF
	 ENDIF ; PANELS



;	****************************
;	*** RMSE QUARTILES Plot  ***
;	****************************
	OK=WHERE(_PANELS EQ 6,COUNT)
  IF COUNT EQ 1 THEN BEGIN
		IF KEYWORD_SET(SINGLE) THEN BEGIN & !P.MULTI= 0 & PSPRINT,/COLOR,/HALF,FILENAME=TITLE+'_F.PS' &  ENDIF

	 	CHL_TITLE = UNITS('CHLOR_A',/UNIT,/NAME)
		RMS_TITLE='RMSE Quartiles (Model versus  ' + '!8In Situ!X)'
		XTICKNAME=['0.01','0.1','1','10','100']
		XTICKVAL =XTICKNAME
		XRANGE = [0.01,100]
		YRANGE = [0.0, 0.5]


  	CHLOR_A = X
		RAW_RMS   = DBLARR(N_ELEMENTS(X))

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
 		FOR NTH=0,N_ELEMENTS(X)-1 DO BEGIN & RAW_RMS[NTH] = (RMS(ALOG10(X[NTH]),ALOG10(Y[NTH]))).RMS & ENDFOR



		PERCENTS = [25,50,75]
		TXT_PERCENTS = STRTRIM(PERCENTS,2)+' %'
		binsize = 0.25

		CHL_AXIS=INTERVAL([-2,2],BASE=10, 0.25)

;		CHL_AXIS = [0.01,0.03,0.1, 0.3,1.0, 3,10, 30, 100]

		LOG_AXIS = ALOG10(CHL_AXIS)


		half_bin= 0.5d * binsize
		CENTER_AXIS= 10^(LOG_AXIS+half_bin)
; 	===> Create the xhist array


		BINS = FLTARR(N_ELEMENTS(CHL_AXIS))
		NUM  = REPLICATE(0,N_ELEMENTS(CHL_AXIS))
		PER  = FLTARR(3,N_ELEMENTS(CHL_AXIS))
		PER(*) 	= MISSINGS(PER)
		PER  		= INFINITY_2NAN(PER)

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0,N_ELEMENTS(CHL_AXIS)-2 DO BEGIN
			LOW=CHL_AXIS[NTH]
			UPP = CHL_AXIS(NTH+1)
			PRINT, LOW,UPP
			OK=WHERE(X GT LOW AND X LE UPP,COUNT)
			NUM[NTH] = COUNT
			IF COUNT GE 2 THEN BEGIN

			  _RAW_RMS = RAW_RMS[OK]
				PER(*,NTH)=PERCENTILE(_RAW_RMS,PERCENT=PERCENTS)

			ENDIF
		ENDFOR

		PAL_36
		PLOT, CENTER_AXIS,PER,/NODATA,/XLOG, XTITLE = CHL_TITLE , YTITLE=RMS_TITLE,XRANGE=XRANGE,YRANGE=YRANGE,/XSTYLE,/YSTYLE,$
					XTICKV=XTICKV,XTICKNAME=XTICKNAME,CHARSIZE=1.5
		GRIDS,XX=CHL_AXIS,COLOR=TC(34)

		COLORS = [0,0,0]
		LINESTYLES = [2,0,1]
		THICKS = [3,3,3]

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,N_ELEMENTS(PERCENTS)-1 DO BEGIN
	  	APER = PER(NTH,*)
	  	ANUM = NUM[NTH]
	  	OPLOT, CENTER_AXIS, PER(NTH,*)	,COLOR=TC(COLORS[NTH]),LINESTYLE=LINESTYLES[NTH],THICK=THICKS[NTH]
		ENDFOR
		XX = CHL_AXIS
		OK = WHERE(NUM GT 0)
		XYOUTS,CENTER_AXIS[OK],REPLICATE(0.02,N_ELEMENTS(CHL_AXIS[OK])),STRTRIM(NUM[OK],2), COLOR=TC[0],/DATA,ALIGN= 0.5 ,CHARSIZE=0.5
		LSIZE  = 0.7

		LSTYLE = [0,1,2,3,4]
		!P.CHARTHICK=1
		BOX=[255, 0,  1, 0.75, 0.8]
		LEG,pos =[0.20 ,0.85,0.28,0.94],BOX=BOX, color=REVERSE(COLORS) ,label=REVERSE(TXT_PERCENTS) ,THICK=REVERSE(THICKS),LSIZE=LSIZE,LINESTYLE=REVERSE(LINESTYLES)
		!P.CHARTHICK=1

  	XYOUTS,10.0^!x.crange[1],0.42, /DATA,'F',CHARSIZE=2*char_scale,CHARTHICK=2,ALIGN= 1.2

		FRAME,/PLOT,COLOR=0,THICK=2
	  IF KEYWORD_SET(SINGLE) THEN PSPRINT
	 ; -----------------------------------------------------------------------------------

	ENDIF ; PANELS



  IF NOT KEYWORD_SET(NO_NOTES) THEN BEGIN

    XYOUTS,.75,.3,notes,/normal, ALIGN=0.5, CHARSIZE=NOTE_SIZE

  ENDIF

 	IF ALG_FORMULA NE '' THEN BEGIN
     XYOUTS,.47,.001,ALG_FORMULA,/normal, ALIGN=0.5, CHARSIZE=0.8
  ENDIF

  XYOUTS,.5,.94,PAGE_TITLE,/normal, ALIGN=0.5, CHARSIZE=PAGE_CHARSIZE

	IF N_ELEMENTS(AUTHORS) EQ 1 THEN BEGIN
     XYOUTS,.92, 0.94,AUTHORS,/normal, ALIGN= 1, CHARSIZE=0.5
  ENDIF
!X.OMARGIN=[0,0]

DONE:

END
