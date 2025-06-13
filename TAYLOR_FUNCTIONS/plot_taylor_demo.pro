; $Id:	plot_taylor_demo.pro,	October 07 2008	$

	PRO PLOT_TAYLOR_DEMO

;+
; NAME:
;		PLOT_TAYLOR_DEMO
;
; PURPOSE:
;		This procedure is a DEMO for PLOT_TAYLOR
;		1) A synthetic monthly time series is generated (as the Reference Series)
;		2) The Reference is used to make phase-shifted and bias-shifted time series
;		3) Pattern Statistics for the Taylor Plot are computed and
;		4) Written to a comma-delimited CSV file ('PLOT_TAYLOR_DEMO.CSV')
;		5) A PostScript file is opened and on the first page each time series is illustrated in a multi-panel plot
;		6) The Pattern Statistics are passed several times to PLOT_TAYLOR to illustrate its capabilities on subsequent
;			 pages of the PostScript file.
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:

;		PLOT_TAYLOR_DEMO
;
; INPUTS:
;		NONE

; OUTPUTS:
;		This Program Generates a PostScript Plot
;	 	'PLOT_TAYLOR_DEMO.PS' illustrating the Taylor Plot	and a comma-delimited CSV file
;		'PLOT_TAYLOR_DEMO.CSV' with the Pattern Statistics used to generate the Taylor Plot
;
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

; MODIFICATION HISTORY:
;			Written Dec 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PLOT_TAYLOR_DEMO'

;	===> Prime IDL's Mean function (when calling DEMEAN routine below the MEAN function must have been previously called)
	M=MEAN(1)


;	********************************************************************************************************************
;	*** Make a simple 1-year (360 day) Trimodal sinusoidal time series (Spring, small Summer bloom and a fall bloom) ***
;	********************************************************************************************************************
	N_SAMPLES = 360 ; 360-day year
	res = 30 				; 360/30 = 12 months
 	TIME =  DINDGEN(n_samples)*(1D/(N_SAMPLES))
	RAD = 2D*!DPI*TIME
	Series= SIN(RAD*FLOAT(2))
	series = series*SIN(RAD)+SIN(RAD)+COS(RAD)
	time = time*12
;	===> Shift the entire series by 7 values to line up peaks & valley with month
 	series = SHIFT(series,7)
;	===> Add 5 to make series positive
	series = series + 5


;	===> Subsample to get a 12 month annual Reference cycle
	Reference = SUBSAMPLE(Series,res) & NAME = 'Reference' & LABEL=['A']

;	===> Shift the Reference series to be out of phase by ~1,2,3 weeks
	Shift_1wk 	= SUBSAMPLE(SHIFT(Series,  7), res) 	& NAME=[NAME,'Shift_1wk'] 	& LABEL=[LABEL,'B']
	Shift_2wk 	= SUBSAMPLE(SHIFT(Series, 15), res)		& NAME=[NAME,'Shift_2wk'] 	& LABEL=[LABEL,'C']
	Shift_4wk 	= SUBSAMPLE(SHIFT(Series, 30), res)		& NAME=[NAME,'Shift_4wk'] 	& LABEL=[LABEL,'D']
	Shift_8wk 	= SUBSAMPLE(SHIFT(Series, 60), res)		& NAME=[NAME,'Shift_8wk'] 	& LABEL=[LABEL,'E']
	Shift_10wk 	= SUBSAMPLE(SHIFT(Series, 75), res)		& NAME=[NAME,'Shift_10wk'] 	& LABEL=[LABEL,'F']
	Shift_15wk 	= SUBSAMPLE(SHIFT(Series, 113), res)		& NAME=[NAME,'Shift_15wk'] 	& LABEL=[LABEL,'G']
	Shift_20wk 	= SUBSAMPLE(SHIFT(Series, 150), res)		& NAME=[NAME,'Shift_20wk'] 	& LABEL=[LABEL,'H']


;	===> Make up an annual series from the shifted series SHIFT_1 by adding and subtracting a bias of 1
	Shift_1wk_Plus_1 	= Shift_1wk + 1 & NAME=[NAME,'Shift_1wk_Plus_1'] 		& LABEL=[LABEL,'i']
	Shift_4wk_Minus_1 = Shift_4wk - 1 & NAME=[NAME,'Shift_4wk_Minus_1'] 	& LABEL=[LABEL,'j']

;	===> Make up reduced series
	DM = DEMEAN(Shift_4wk,dmean=m)
  Shift_4wk_half = Shift_4wk*.5			& NAME=[NAME,'Shift_4wk_half'] 	& LABEL=[LABEL,'k']

	DM = DEMEAN(Shift_8wk,dmean=m)
  Shift_8wk_half = Shift_8wk*.5			& NAME=[NAME,'Shift_8wk_half'] 	& LABEL=[LABEL,'l']

;	===> Make up  amplified series
	DM = DEMEAN(Shift_4wk,dmean=m)
  Shift_4wk_dbl = Shift_4wk*2				& NAME=[NAME, 'Shift_4wk_dbl'] 	& LABEL=[LABEL,'m']

	DM = DEMEAN(Shift_8wk,dmean=m)
  Shift_8wk_dbl = Shift_8wk*2				& NAME=[NAME, 'Shift_8wk_dbl'] 	& LABEL=[LABEL,'n']

	DM = DEMEAN(Shift_4wk,dmean=m)
  Shift_4wk_tri = (Shift_4wk-1)*3	& NAME=[NAME, 'Shift_4wk_tri'] 	& LABEL=[LABEL,'O']

	DM = DEMEAN(Shift_8wk,dmean=m)
  Shift_8wk_tri = (Shift_8wk)*3	& NAME=[NAME, 'Shift_8wk_tri'] 	& LABEL=[LABEL,'P']

	N_NAME = N_ELEMENTS(NAME)

;	***************************************************************************************************
;	*** Make a Spreadsheet type structure to hold the statistical arrays needed for the taylor plot ***
;	***************************************************************************************************
	MISS = MISSINGS(0.0) ; NARR Standard Missing Data Scheme (see MISSINGS.PRO)
	DB = REPLICATE(CREATE_STRUCT('NAME','','LABEL','','N',-1L,'MEAN',MISS,'STD',MISS,$
															 'BIAS',MISS,'R',MISS,'CRMS',MISS,'NSTD',MISS,'NCRMS',MISS),N_NAME)

;	===> Compute stats (Reference Stats will be in the first Record or Row of the Spreadsheet)
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_NAME-1 DO BEGIN
		CMD = 'Data = ' + NAME(nth) & a = EXECUTE(cmd)

		DB(nth).NAME = NAME(nth)
		DB(nth).LABEL = LABEL(nth)

;		===> Univariate Stats
		S	= STATS(Data)
	  DB(nth).N 		= S.N
	  DB(nth).MEAN 	= S.MEAN
	  DB(nth).STD 	= S.STD

;		===> Assumes the Reference is the first series (first row in spreadsheet database)
		IF nth EQ 0 THEN BEGIN
			X_DEMEAN 		= DEMEAN(Data,DMEAN=REF_MEAN)
			REF_STD 		= S.STD
		ENDIF

;		===> Subtract the mean from the series
		Y_DEMEAN			= DEMEAN(Data)

;		===> Bivariate Stats
		S2 = STATS2(X_DEMEAN,Y_DEMEAN,MODEL='RMA') ;(The regression model is not important since we are calculating Corr an RMS)
		DB(nth).BIAS 	= S.MEAN 	- REF_MEAN
		DB(nth).R 		= S2.R
		DB(nth).NSTD 	= S.STD 	/ REF_STD
		DB(nth).CRMS 	= S2.RMS
		DB(nth).NCRMS	= S2.RMS 	/ REF_STD

	ENDFOR
;	||||||

;	***********************************************************
;	*** Write the statistics to a comma-delimited CSV file  ***
;	***********************************************************
	CSV_FILE = ROUTINE_NAME+'.CSV'
	STRUCT_2CSV, CSV_FILE, DB


;	*********************************************************************
;	*** NOTE that this csv file could have been generated earlier 		***
;	*** using the approach above to make a spreadsheet type structure ***
;	*** Then the CSV spreadsheet can be read using READ_CSV.PRO       ***
;	*** and used along with PLOT_TAYLOR to make the plots         		***
;
;;	DB=READ_CSV(CSV_FILE)
;;	DB=STRUCT_2NUM(DB) ; Convert string values to numeric
;	*********************************************************************


;	===> Can easily view the data base spread sheet using SPREAD
;   	SPREAD,DB



;	********************************************************************************
;	*** Make a multi-panel plot of each series on the same page as a Taylor Plot ***
;	********************************************************************************
;	===> Initialize the PostScript Device
  PSPRINT,/FULL,/COLOR, FILENAME= ROUTINE_NAME+'.PS'

;	===> Call a NARR standard colors Palette
	PAL36

;	===> Default font is TIMES (passed to PLOT_TAYLOR)

;	===> Need to make some room on the left and on the right for the table (name and plotting label)
	!X.OMARGIN=[5,15]
	!X.MARGIN = [3,2]
	!Y.MARGIN = [4,4]

	!P.MULTI=[0,5,5]
	MONTH = INDGEN(12)+1

;	===> Concatenate all the series to find the overall yrange so all series may be plotted on a common y-axis range
	data = 0.0
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_NAME -1 DO BEGIN
		CMD = 'Data = [data,' + NAME(nth)+ ']' & a = EXECUTE(cmd)
	ENDFOR
	data=data(1:*)
	YRANGE = MINMAX(data)




;	===> Plot each series
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0,N_NAME -1 DO BEGIN
		& title= DB(NTH).LABEL+' : ' + NAME(nth(0))
		CMD = 'Data = ' + NAME(nth) & a = EXECUTE(cmd)
		IF NTH EQ 0 THEN BEGIN
			PLOT, month,Reference,xrange=[0,13],/xstyle,yrange=yrange,/ystyle,xtitle='Month',ytitle= UNITS('CHLOROPHYLL'),$
			title=title,xtick_get=xtick_get
		ENDIF ELSE BEGIN
			PLOT, month,Reference,xrange=[0,13],/xstyle,yrange=yrange,/ystyle,xtitle='Month', $
			title=title,xtick_get=xtick_get
		ENDELSE
		GRIDS,x=xtick_get,/all,COLOR=253
		OPLOT,month,Reference,color=253,thick=7
		OPLOT, MONTH, data,COLOR=22,thick=3
		FRAME,/PLOT,COLOR=0,THICK=3
 	ENDFOR



	D = DB
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R , BIAS=D.bias,LAB_SIZE=2.6,/NORMALIZED, $
							Position = [0.15,0.05,0.75,0.60],r_title='Pattern Correlation Coefficient',/noerase,charsize=1.5,r_charsize=1,tab_charsize=1,bi_charsize=2,/SEMI_CIRCLE

	XYOUTS,0.5,0.99,"Taylor Plot Demo",charsize=2,/NORMAL,ALIGN = [0.5]
 	XYOUTS,0.95,0.05,"J.O'Reilly, NOAA",charsize=0.7,/NORMAL,ALIGN = [1.1]

;psprint
;stop

;	===> One plot per page
	!P.MULTI = 0


;	===> Note: A negative correlation will force the plot to be a semi-circle
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,title_plot='Minumum Inputs (Defaults)'

	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,LAB_COLOR=36,title_plot='Labels Same Color'

	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,LAB_COLOR=36,XRANGE = [0,1.5],title_plot='XRANGE = [0,1.5]',/NORMALIZED



;	===> Example of Normalized showing only upper right quadrant
;	===> Find just the positive correlations for later subsetting
  OK_POS_CORRELATION=WHERE(DB.R GE 0)
	D=DB(OK_POS_CORRELATION)
	LAB_COLOR = REPLICATE(120,N_ELEMENTS(D)) & OK=WHERE(D.NSTD LT 0.9) & LAB_COLOR(OK) = 48 & OK=WHERE(D.NSTD GT 1.1) & LAB_COLOR(OK) = 221 & OK=WHERE(D.NSTD GT 2.1) & LAB_COLOR(OK) = 249
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R ,/NORMALIZED, LAB_COLOR=LAB_COLOR	,title_plot='NORMALIZED Standard Deviation (only positive correlations)'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R , BIAS=D.bias,/NORMALIZED, title_plot='NORMALIZED Standard Deviation and Bias'

;	===> Example of Normalized showing Semi-circle (neg and pos correlations)
	D=DB
	LAB_COLOR = REPLICATE(120,N_ELEMENTS(D)) & OK=WHERE(D.NSTD LT 0.9) & LAB_COLOR(OK) = 48 & OK=WHERE(D.NSTD GT 1.1) & LAB_COLOR(OK) = 221 & OK=WHERE(D.NSTD GT 2.1) & LAB_COLOR(OK) = 249
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R ,/NORMALIZED, LAB_COLOR=LAB_COLOR	,title_plot='NORMALIZED Standard Deviation (All correlations)'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R , BIAS=D.bias,/NORMALIZED, title_plot='NORMALIZED Standard Deviation and Bias'


	D=DB
	LAB_COLOR = 20*INDGEN(N_ELEMENTS(D))+20
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,LAB_SIZE	=2,LAB_COLOR=LAB_COLOR,title_plot='Multi Color Large Labels'

	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R , BIAS=D.bias, title_plot='Example showing BIAS using color-coded labels (Probably Best Way)'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R , BIAS=D.bias, /BI_CIRCLE, title_plot='Example Showing BIAS using color-coded circles'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R , BIAS=D.bias, /BI_CIRCLE,LAB_COLOR= 255,R_TITLE='Monthly Pattern Correlation Coefficient',title_plot='Example showing BIAS using color-coded circles with white labels'


;	*** NOTE that when you want a /NORMALIZED plot then must pass NSTD (normalized standard deviation) to PLOT_TAYLOR
	LAB_COLOR = REPLICATE(120,N_ELEMENTS(D)) & OK=WHERE(D.NSTD LT 0.9) & LAB_COLOR(OK) = 48 & OK=WHERE(D.NSTD GT 1.1) & LAB_COLOR(OK) = 221
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R , /NORMALIZED, LAB_COLOR=LAB_COLOR	,title_plot='Example showing NORMALIZED Standard Deviation'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R , BIAS=D.bias,/NORMALIZED, title_plot='Example showing NORMALIZED Standard Deviation and Bias'


;	===> Showing the use of POSITON Keyword
	Position = [0.05,0.5,0.35,0.80]
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.NSTD, CORR=D.R  ,BIAS=D.bias,/NORMALIZED, title_plot='Showing the use the Position = [0.05,0.5,0.35,0.80]',position=position,TAB_CHARSIZE=0.4,charsize=0.75


;	===> Show other symbols being used
	D(1).LABEL = '$' & D(3).LABEL = '#1' & D(5).LABEL = '#5' & D(7).LABEL = '#4' & D(2).LABEL = '#' & d(11).label='~'
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,LAB_COLOR = 60,title_plot='Other Symbols'


;	===> Helvitica Font
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R ,LAB_COLOR = 60,title_plot='Other Symbols & HELVETICA Font', font='HELVETICA'


;	===> Specifying Bias Range
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R,BIAS=D.bias,LAB_COLOR = 60,title_plot='Bias Range = [-15,20] but your input should really be [-20,20]',BI_RANGE=[-15,20]



;	===> Specifying Bias Range but no color bar
	PLOT_TAYLOR,NAME=D.name, LABEL=D.label, STD=D.std, CORR=D.R,BIAS=D.bias,LAB_COLOR = 60,title_plot='Bias Range = [-20,20] and Suppress the Color Bar',BI_RANGE=[-20,20],/BI_NONE






LAB_COLOR = 20*INDGEN(N_ELEMENTS(D))+20
plot_taylor,name=d.name,label=d.label,std=d.nstd,corr=d.r, BIAS=D.bias,xrange=[0,2.],$
LAB_THICK=7,LAB_SIZE=1.3,/SEMI_CIRCLE,LAB_COLOR=LAB_COLOR,/normalized,thick=1.2,position=$
[0.1,0.05,0.45,0.45],TAB_CHARSIZE=1.,charsize=1.25,BI_CHARTHICK=.1,BI_TITLE=['% BIAS'],$
RAZ_VAL=[0.0, 0.9],RAZ_THICK=rt,RAZ_SPAN=rs,RAZ_LINESTYLE=0,RAZ_COLOR=0,SD_COLOR=255,SD_THICK=rt,$
;;font='helvetica', TITLE_POS=[0.5,1.3],BI_POS= [0.955,1.50,0.980,1.90],$
font='helvetica', TITLE_POS=[0.5,1.3],BI_POS= [0.25,1.60,0.75,1.64],$
CHARTHICK=.1,title_plot='SAB Surface Chlorophyll',r_title='Correlation' ,/BI_HORIZ


	PSPRINT


;	===> Change back
	!X.OMARGIN=[0,0]
	!X.MARGIN = [0,0]
	!Y.MARGIN = [0,0]
	!P.MULTI = 0



	END; #####################  End of Routine ################################
