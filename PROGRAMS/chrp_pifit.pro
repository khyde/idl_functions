; $ID:	CHRP_PIFIT.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO CHRP_PIFIT, CRUISE=CRUISE, OUT_DIR=OUT_DIR, IN_DIR=IN_DIR, DO_DAILY=DO_DAILY
;+
; NAME:
;       CHRP_PIFIT
;
; PURPOSE:
;          Main routine for calculating primary productivity from C-14 and Oxygen measurements
;						1) Change dpm into productivity measurements
;						2) Run Platt Model to calculate productivity parameters for both C-14 and Oxygen data
;
;
; MODIFICATION HISTORY:
;       Written by:  Kimberly J.W. Hyde, July 6, 2006
;       Modified by: Kimberly J.W. Hyde, December 16th, 2008 ===> Added the ability to include manually determined
;                                                                 extinction coefficient data due to poor in-water light data
;-

	ROUTINE_NAME='CHRP_PIFIT'

 	PAL_36																																;	===> Load simple color palette
	DIC_CHL_FILE	= IN_DIR+'CHIRP_DIC_CHL_DATA.CSV'
	INWATER_PAR		= IN_DIR+'CHIRP_IN_WATER_PAR.CSV'
	PROFILE_DATA	= IN_DIR+'CHIRP_PROFILES.CSV'
	DAILY_PAR 		= IN_DIR+'PRUDENCE_DAILY_PAR.CSV'
	KD_FILE       = IN_DIR+'CHIRP_KD_DATA.csv'
	PROD_FILE 		= IN_DIR + CRUISE + '.CSV'

;	===> Read input files
	DC = READ_DELIMITED(DIC_CHL_FILE, DELIM='COMMA')
	C = READ_DELIMITED(PROD_FILE, DELIM='COMMA')
	L = READ_DELIMITED(INWATER_PAR, DELIM='COMMA')
	P = READ_DELIMITED(PROFILE_DATA, DELIM='COMMA')
	DP = READ_DELIMITED(DAILY_PAR, DELIM='COMMA')
	EC = READ_DELIMITED(KD_FILE,DELIM='COMMA')

; ===> Create output files
	SAVEPROD = OUT_DIR + CRUISE + '_PRODUCTIVITY.SAVE'
	SAVEPROF = OUT_DIR + 'CHRP_PROFILES.SAVE'
	SAVEFILE = OUT_DIR + '_LIGHT.SAVE'
	PSPROD  = OUT_DIR + CRUISE + '_FIGURES.PS'
	PSLIGHT  = OUT_DIR + 'CHIRP_LIGHT_FIGURES.PS'

; ===> If not provided then calculate light extinction coefficient ect.
	CHRP_LIGHT_EXT,LIGHT=L,PROFILE=P,PSFILE=PSLIGHT,OUTFILE=D

; ===> Create ID for the extinction coefficient data
	D_ID  = STRUPCASE(STRTRIM(D.CRUISE,2)) +STRUPCASE(STRTRIM(D.DATE,2)) +STRUPCASE(STRTRIM(D.STATION,2)) +STRTRIM(D.DEPTH,2)
	EC_ID = STRUPCASE(STRTRIM(EC.CRUISE,2))+STRUPCASE(STRTRIM(EC.DATE,2))+STRUPCASE(STRTRIM(EC.STATION,2))+STRTRIM(0.0,2)

; ===> If Kd is bad, then replace with pre-determined data
  OK_KD = WHERE(EC.KD NE MISSINGS(EC.KD),REPLACEMENT_KD)
  FOR NTH=0L, REPLACEMENT_KD-1 DO BEGIN
    REP_ID = EC_ID(OK_KD[NTH])
    OK = WHERE(D_ID EQ REP_ID, MATCH)
    IF MATCH EQ 1 THEN BEGIN
    	D[OK].KD        = FLOAT(EC(OK_KD[NTH]).KD)
    	D[OK].I0        = EC(OK_KD[NTH]).I0
    	D[OK].ZEU       = -ALOG(0.01)/D[OK].KD
    	D[OK].IZEU      = EC(OK_KD[NTH]).IZEU
    	D[OK].RSQ       = EC(OK_KD[NTH]).RSQ
    	D[OK].COEFFS    = ''
    	D[OK].EXT_MODEL = 'MANUAL'
    ENDIF
  ENDFOR

	SAVE, FILENAME=SAVEPROF, D, /COMPRESS
	SAVE_2CSV,SAVEPROF

; ===> Create ID's for the C-14, O2, and DIC samples to easily match by CRUISE, STATION, DATE, AND RELATIVE DEPTH
	ID = STRUPCASE(STRTRIM(C.CRUISE,2))+STRUPCASE(STRTRIM(C.DATE,2))+STRUPCASE(STRTRIM(C.STATION,2))+STRUPCASE(STRTRIM(C.WATER_DEPTH,2))
	DIC_ID = STRUPCASE(STRTRIM(DC.CRUISE,2))+STRUPCASE(STRTRIM(DC.DATE,2))+STRUPCASE(STRTRIM(DC.STATION,2))+STRUPCASE(STRTRIM(DC.WATER_DEPTH,2))

; ===> Create new data structure that will contain the C-14 and O2 productivity data
	NEW = CREATE_STRUCT('ID','','CRUISE','','DATE','','STATION','','REL_DEPTH','','DEPTH',0.0,'CHLOROPHYLL',0.0,'METHOD','','LIGHT',0.0,'LIGHT_4PI',0.0,'PROD',0.0,$
											'PRED_PROD',0.0,'ZEU',0.0,'PSB',0.0,'ALPHA',0.0,'BETA',0.0,'PMAX',0.0,'PMAX_B',0.0,'ALPHA_B',0.0,'R2',0.0,'DAILY_PROD',0.0,'AREAL_PROD',0.0,'MODEL','')
	NEW = STRUCT_2MISSINGS(NEW)
; ===> Find DARK, STOCK and BLANK vials
	DOK = WHERE(STRMID(STRUPCASE(STRTRIM(C.VIAL_NUMBER,2)),0,2) NE 'DK' AND STRTRIM(STRMID(C.VIAL_NUMBER,0,5),2) NE 'STOCK' AND STRTRIM(C.VIAL_NUMBER,2) NE 'BLANK',COUNT)
	NEW = REPLICATE(NEW,COUNT)																						; Need ~16 rows per station to hold the prod data
	COUNTER = 0

; ===> Determine if the productivity method was C14, O2 or both
	MSET = WHERE_SETS(C.METHOD)
	FOR MTH = 0L, N_ELEMENTS(MSET)-1 DO BEGIN
		SUBS = WHERE_SETS_SUBS(MSET(MTH))
		M = C(SUBS)
		METHOD = MSET(MTH).VALUE
		MID = ID(SUBS)
		IF METHOD EQ 'C14' THEN BEGIN
			OK = WHERE(STRTRIM(STRMID(M.VIAL_NUMBER,0,5),2) EQ 'STOCK')										;	Find stock values
			STOCK = MEAN(FLOAT(M[OK].VALUE))
			OK = WHERE(STRTRIM(M.VIAL_NUMBER,2) EQ 'BLANK')																; Find blank values
			BLANK = MEAN(FLOAT(M[OK].VALUE))
		ENDIF

; ===> Find sample and dark values
		OK = WHERE(STRTRIM(STRMID(M.VIAL_NUMBER,0,5),2) NE 'STOCK' AND STRTRIM(M.VIAL_NUMBER,2) NE 'BLANK')
		CC = M[OK]
		CID = MID[OK]
		B = WHERE_SETS(CID)

		FOR NTH=0L, N_ELEMENTS(B)-1 DO BEGIN																						; Loop through each station set
			SET_ID = B[NTH].VALUE																													; Station/depth ID
			SUBS = WHERE_SETS_SUBS(B[NTH])
			SET = CC(SUBS)																																; Subset of original data
			CRUISE = SET[0].CRUISE
			DATE = SET[0].DATE
			STATION = SET[0].STATION
			REL_DEPTH = SET[0].REL_DEPTH
			DEPTH = SET[0].WATER_DEPTH

			;	===> Find dark values
			OK = WHERE(STRTRIM(STRMID(SET.VIAL_NUMBER,0,2),2) EQ 'DK')
			DARK = MEAN(FLOAT(SET[OK].VALUE))

			; ===> Find light values
			OK = WHERE(STRTRIM(STRMID(SET.VIAL_NUMBER,0,2),2) NE 'DK' AND FLOAT(SET.VALUE GT 0.0))
			PROD = FLOAT(SET[OK].VALUE)
			LIGHT = FLOAT(SET[OK].LIGHT)
			TIME = FIRST(FLOAT(SET[OK].TIME))
			NLIGHT = N_ELEMENTS(LIGHT)
			ZERO = COUNTER
			LAST = COUNTER + NLIGHT-1

;	===> Fill in data structure with station information
			NEW(ZERO:LAST).METHOD = METHOD
			NEW(ZERO:LAST).ID = SET_ID
			NEW(ZERO:LAST).CRUISE = CRUISE
			NEW(ZERO:LAST).DATE = DATE
			NEW(ZERO:LAST).STATION = STATION
			NEW(ZERO:LAST).REL_DEPTH = STRUPCASE(REL_DEPTH)
			NEW(ZERO:LAST).DEPTH = DEPTH
			NEW(ZERO:LAST).LIGHT = REVERSE(LIGHT)

; ===> Convert the light collected with a cosine sensor to 4 PI readings
			LIGHT = 19.2 + (1.098 * LIGHT) - (0.00011 * LIGHT^2)

; ===> Match up DIC_ID with the Station/depth ID for C14 profiles
			IF METHOD EQ 'C14' THEN BEGIN
				OK = WHERE(DIC_ID EQ SET_ID,COUNT)
				IF COUNT GE 1 THEN BEGIN DIC = MEAN(FLOAT(DC[OK].AVG_DIC)) & CHL = MEAN(FLOAT(DC[OK].AVG_CHL)) & NEW(NLIGHT*NTH).CHLOROPHYLL = CHL & $
					ENDIF ELSE BEGIN
						PRINT, 'MAKE SURE DIC VALUES ARE PRESENT FOR'
						PRINT, 'CHECK DIC AND PRODUCTIVITY ID INFORMATION (i.e. depth, date, cruise, etc.)
						STOP
						GOTO, SKIP_C14
					ENDELSE
				DPM = PROD																																								; Convert DPM values
				PROD = DPMTOPROD(DPM=DPM,LIGHT=LIGHT,STOCK=STOCK,BLANK=BLANK,DARK=DARK,TIME=TIME,DIC=DIC)	; into productivity values
			ENDIF

			IF N_ELEMENTS(LIGHT) LT 5 AND N_ELEMENTS(PROD) LT 5 THEN CONTINUE
			PI = PI_FIT(LIGHT=LIGHT, PROD=PROD, LABEL=LABEL, CHL=CHL)																		; Run PI_FIT model

;	===> Find best fitting model
			OK = WHERE(PI.BETA NE MISSINGS(0.0) AND PI.MODEL_NAME EQ 'PLATT_MODEL')
			IF PI[OK].BETA LE 0 THEN MODEL_NAME = 'WEBB_MODEL' ELSE MODEL_NAME = 'PLATT_MODEL'
			OK = WHERE(PI.MODEL_NAME EQ MODEL_NAME)
			MPI = PI[OK]

; ===> Fill in data structure with productivity and model fit data

			NEW(ZERO:LAST).LIGHT_4PI = MPI.LIGHT
			NEW(ZERO:LAST).PROD = MPI.PROD
			NEW(ZERO:LAST).PRED_PROD = MPI.PFIT

;	===> Add photosynthetic parameters to the 0th line for each station
			NEW(ZERO).ALPHA		 		= MPI[0].ALPHA
			NEW(ZERO).BETA				= MPI[0].BETA
			NEW(ZERO).PMAX				= MPI[0].PMAX
			NEW(ZERO).PSB					= MPI[0].PSB
			NEW(ZERO).ALPHA_B 		= MPI[0].B_ALPHA
			NEW(ZERO).PMAX_B			= MPI[0].B_PMAX
			NEW(ZERO).CHLOROPHYLL = MPI[0].CHL
			NEW(ZERO).R2					= MPI[0].R2
			NEW(ZERO).MODEL				= MPI[0].MODEL_NAME
			COUNTER = LAST + 1

			SKIP_C14:
		ENDFOR
	ENDFOR
	OK = WHERE(NEW.ID NE MISSINGS(NEW.ID) AND NEW.DATE NE MISSINGS(NEW.DATE),COUNT)		; REMOVE ANY BLANK ROWS
	PI = NEW[OK]

;*******************************************
;***** PLOT PI CURVES AND PROFILE DATA *****
;*******************************************

	PSPRINT,/FULL,/COLOR,FILENAME=PSPROD,/TIMES
	PID = PI.CRUISE + PI.DATE + PI.STATION
	PSET = WHERE_SETS(PID)
	FOR PTH = 0L, N_ELEMENTS(PSET)-1 DO BEGIN
		!P.MULTI = [0,2,3]
		PSET_ID = PSET(PTH).VALUE
		SUBS = WHERE_SETS_SUBS(PSET(PTH))
		PISET = PI(SUBS)
		STATION = PISET[0].STATION
		DE = WHERE_SETS(PISET.REL_DEPTH)
		DE = DE[REVERSE(SORT(DE.VALUE))]
		NDEPTHS = N_ELEMENTS(DE)
		FOR DTH = 0L, NDEPTHS-1 DO BEGIN
			DEPTH = DE(DTH).VALUE
			SUBS =WHERE_SETS_SUBS(DE(DTH))
			DESET = PISET(SUBS)
			M = WHERE_SETS(DESET.METHOD)
			NMETHODS = N_ELEMENTS(M)
			FOR MTH=0L, NMETHODS-1 DO BEGIN
				METHOD = M(MTH).VALUE
				SUBS = WHERE_SETS_SUBS(M(MTH))
				MSET = DESET(SUBS)
				IF MSET[0].ID EQ MISSINGS('') THEN GOTO, SKIP_PLOT
				IF STRUPCASE(MSET[0].REL_DEPTH) EQ 'SURF' THEN RD = 'Surface' ELSE RD = 'Chl Max'
				TXT_ID = MSET[0].CRUISE + ' ' + MSET[0].STATION + ' ' + RD + ' ' + STRMID(MSET[0].DATE,0,4) + '-' + STRMID(MSET[0].DATE,4,2) + '-' + STRMID(MSET[0].DATE,6,2)
				IF METHOD EQ 'C14' THEN BEGIN
					YTITLE = 'Productivity (mg C m!E-3!N h!E-1!N)'
					TITLE = '!E14!NC!C'+TXT_ID
				ENDIF
				IF METHOD EQ 'O2'  THEN BEGIN
					YTITLE = 'Productivity (mg O!D2!N m!E-3!N h!E-1!N)'
					TITLE = 'O!D2!N!C'+TXT_ID
				ENDIF
				XTITLE = 'Irradiance (!9m!7E m!E-2!N s!E-1!N)'
				CHARSIZE = 1.5
				XMARGIN = [4,4]
				YMARGIN = [4,4]
				SYMSIZE = 1.5
				PSYM = 2
				PTHICK = 2
				THICK = 2
				PCOLOR = 0
				FCOLOR = 22
				PLOT,  MSET.LIGHT_4PI, MSET.PROD, CHARSIZE=CHARSIZE, /NODATA, XMARGIN=XMARGIN, YMARGIN=YMARGIN, TITLE=TITLE, XTITLE=XTITLE, YTITLE=YTITLE
				OPLOT, MSET.LIGHT_4PI, MSET.PROD, PSYM=PSYM, SYMSIZE=SYMSIZE, COLOR=PCOLOR, THICK=PTHICK
				OPLOT, MSET.LIGHT_4PI, MSET.PRED_PROD,COLOR= FCOLOR, THICK=THICK
				TXT = '!CP!Dmax!N = ' + STRTRIM(ROUND(MSET[0].PMAX),2) +  '!CAlpha = ' +STRTRIM(STRING(MSET[0].ALPHA,FORMAT='(D30.2)'),2) + '!CBeta = ' + $
								STRTRIM(STRING(MSET[0].BETA,FORMAT='(D30.3)'),2) + '!CR!E2!N = ' + STRTRIM(STRING(MSET[0].R2,FORMAT='(D30.3)'),2)
				COOR = COORD_2PLOT(0.5,0.3)
				XYOUTS,COOR.X, COOR.Y, TXT, COLOR=0, CHARSIZE=1
			ENDFOR
		ENDFOR

;**************************************************************
;	DO DAILY AND AREAL PRODUCTIVITY CALCULATIONS AND ADD TO PLOTS
;**************************************************************
;***** DO DAILY PRODUCTION CALCULATION *****
		IF DO_DAILY GE 2 THEN BEGIN
			OK = WHERE(STRLEN(DP.TIME) EQ 4,COUNT)
			IF COUNT GE 1 THEN DP[OK].TIME = '0' + DP[OK].TIME
			OK = WHERE(STRMID(DP.TIME,0,2) GE '06' AND STRMID(DP.TIME,0,2) LE '18' AND DP.TOTPAR GT -2.2)
			DPT = DP[OK]
			HOURS = FINDGEN(13*4)*.25+6
			TAGS = TAG_NAMES(DP)
			SET = WHERE_SETS(PI.ID+PI.METHOD)

			FOR NTH = 0L, N_ELEMENTS(SET)-1 DO BEGIN
				SUBS = WHERE_SETS_SUBS(SET[NTH])
				PROF = PI(SUBS)
				DEPTH = PROF[0].DEPTH
				SS_ID = STRSPLIT(SET[NTH].VALUE,'_',/EXTRACT)
				ID = PROF[0].CRUISE+PROF[0].DATE+PROF[0].STATION
				DATE = PROF[0].DATE
				OK = WHERE(D.ID EQ ID AND D.DEPTH EQ 0 AND D.KD NE MISSINGS(0.0), DAILY_YES) & IF DAILY_YES LT 1 THEN CONTINUE
				KD = D[OK].KD
				OK = WHERE(DPT.DATE EQ DATE,DAILY_YES) & IF DAILY_YES LT 1 THEN CONTINUE
				PAR = FLOAT(DPT[OK].TOTPAR)
				TIME = DPT[OK].TIME
				IF N_ELEMENTS(PAR) LT N_ELEMENTS(HOURS) THEN BEGIN  					; If there is a missing light value (n < 52), then
					TTIME = FLOAT(STRMID(TIME,0,2))+FLOAT(STRMID(TIME,3,2))/60	; interpolate the light to fill in for the missing
					PAR = INTERPOL(PAR,TTIME,HOURS)															; values
				ENDIF
				PAR = 19.2 + (1.098 * PAR) - (0.00011 * PAR^2)
				PRODSUM = 0
				IF PROF[0].MODEL NE MISSINGS('') AND PROF[0].MODEL EQ 'PLATT_MODEL' THEN BEGIN
					PSB = PROF[0].PSB
					ALPHA = PROF[0].ALPHA
					BETA = PROF[0].BETA
					FOR HTH = 0L, N_ELEMENTS(PAR)-1 DO BEGIN
						HPAR = PAR(HTH)
						IZ = HPAR * EXP(-KD * DEPTH)
						PROD = PSB * (1-EXP((-ALPHA*IZ)/PSB)) * EXP((-BETA*IZ)/PSB)
						PRODSUM = PRODSUM + PROD/4
					ENDFOR
				ENDIF
				IF PROF[0].MODEL NE MISSINGS('') AND PROF[0].MODEL EQ 'WEBB_MODEL' THEN BEGIN
					PMAX = PROF[0].PMAX
					ALPHA = PROF[0].ALPHA
					FOR HTH = 0L, N_ELEMENTS(PAR)-1 DO BEGIN
						HPAR = PAR(HTH)
						IZ = HPAR * EXP(-KD * DEPTH)
						IF IZ LT 0 THEN STOP
						PROD = Pmax * (1-EXP((-ALPHA*IZ)/Pmax))
						PRODSUM = PRODSUM + PROD/4
					ENDFOR
				ENDIF
				PI(SUBS[0]).DAILY_PROD = PRODSUM
			ENDFOR

	; ***** DO AREAL PRODUCTION CALCULATION *****
	;	Determine if there are multiple samples (surface and chlorophyll max) or just a surface sample
	; If just a surface sample, then assume that the water column is homogenous
	;	If a chlorophyll max is present, then will need to integrate

			PID = PI.CRUISE + PI.DATE + PI.METHOD
			PSETS = WHERE_SETS(PID)
	  	!P.MULTI = [2,2,3]
			FOR ATH = 0L, N_ELEMENTS(PSETS)-1 DO BEGIN
				SUBS = WHERE_SETS_SUBS(PSETS(ATH))
				PROF = PI(SUBS)
				OK = WHERE(PROF.DAILY_PROD NE MISSINGS(0.0) AND PROF.STATION EQ STATION,COUNT) & IF COUNT LT 1 THEN CONTINUE
				ASET = PROF[OK]
				METH = ASET[0].METHOD
				PRID = ASET[0].CRUISE + ASET[0].DATE + ASET[0].STATION
				OK = WHERE(D.ID EQ PRID)
				DSET = D[OK]
				DAILY = ASET.DAILY_PROD
				DEPTH = ASET.DEPTH
				ZEU = DSET[0].ZEU
				KD = DSET[0].KD
				DATE = DSET[0].DATE
				MAXDEPTH = -1*ROUND(MAX(DSET.DEPTH)+1)
				OK = WHERE(DPT.DATE EQ DATE)
				PAR = FLOAT(DPT[OK].TOTPAR)
				PAR = 19.2 + (1.098 * PAR) - (0.00011 * PAR^2)
				XX = [FINDGEN(ROUND(ZEU+1)*2)*0.5,ZEU]				; Determine the depths for integration (every 0.5 meters to the euphotic depth)
				FOR DTH = 0L, N_ELEMENTS(XX)-1 DO BEGIN
					DEPTH = [DEPTH,XX(DTH)]
					IF XX(DTH) LT MAX(DEPTH) THEN BEGIN
						PSB = ASET[0].PSB
						ALPHA = ASET[0].ALPHA
						BETA = ASET [0].BETA
						PMAX = ASET[0].PMAX
						MODEL = ASET[0].MODEL
					ENDIF
					IF N_ELEMENTS(ASET) GT 1 AND XX(DTH) GE MAX(DEPTH) THEN BEGIN
						PSB = ASET[1].PSB
						ALPHA = ASET[1].ALPHA
						BETA = ASET[1].BETA
						PMAX = ASET[1].PMAX
						MODEL = ASET[1].MODEL
					ENDIF
					PRODSUM = 0
					IF ASET[0].MODEL NE MISSINGS('') AND MODEL EQ 'PLATT_MODEL' THEN BEGIN
						FOR HTH = 0L, N_ELEMENTS(PAR)-1 DO BEGIN
							HPAR = PAR(HTH)
							IZ = HPAR * EXP(-KD * XX(DTH))
							PROD = PSB * (1-EXP((-ALPHA*IZ)/PSB)) * EXP((-BETA*IZ)/PSB)
							PRODSUM = PRODSUM + PROD/4
						ENDFOR
					ENDIF
					IF ASET[0].MODEL NE MISSINGS('') AND MODEL EQ 'WEBB_MODEL' THEN BEGIN
						FOR HTH = 0L, N_ELEMENTS(PAR)-1 DO BEGIN
							HPAR = PAR(HTH)
							IZ = HPAR * EXP(-KD * XX(DTH))
							IF IZ LT 0 THEN STOP
							PROD = Pmax * (1-EXP((-ALPHA*IZ)/Pmax))
							PRODSUM = PRODSUM + PROD/4
						ENDFOR
					ENDIF
					DAILY =  [DAILY,PRODSUM]
				ENDFOR
				SRT = SORT(DEPTH)
				DEPTH = DEPTH(SRT)
				DAILY = DAILY(SRT)
				AFIT = PROFILE_INTEGRATION(VAR=DAILY, DEPTH=DEPTH, MAX_DEPTH=ZEU,ERROR=error, EXTRA=EXTRA)
				AREAL = AFIT.INTEGRATED_X
				OK = WHERE(PI.STATION EQ STATION AND PI.REL_DEPTH EQ 'SURF' AND PI.METHOD EQ METH AND PI.DAILY_PROD NE MISSINGS(0.0),COUNT)
				PI[OK].AREAL_PROD = AREAL
				PI[OK].ZEU = ZEU
				MAXDEPTH = ROUND(MAX(DSET.DEPTH)+1)
				YRANGE = [MAXDEPTH,0]
				XRANGE = [0,MAX(DAILY)]
				XMARGIN = [4,4]
				YMARGIN = [7,4]
				TXT = ASET[0].CRUISE + ' ' + ASET[0].STATION + ' '+ STRMID(ASET[0].DATE,0,4) + '-' + STRMID(ASET[0].DATE,4,2) + '-' + STRMID(ASET[0].DATE,6,2)
				IF ASET[0].METHOD EQ 'C14' THEN BEGIN
					XTITLE = 'Daily Productivity (mg C m!E-3!N h!E-1!N)'
					TITLE = '!E14!NC!C'+TXT
					ELEM = 'C'
				ENDIF
				IF ASET[0].METHOD EQ 'O2'  THEN BEGIN
					XTITLE = 'Daily Productivity (mg O!D2!N m!E-3!N h!E-1!N)'
					TITLE = 'O!D2!N!C'+TXT
					ELEM = 'O!D2!N'
				ENDIF

; ===> Plot daily and areal productivity data
				PLOT, DAILY,DEPTH,XRANGE=XRANGE,YRANGE=YRANGE,XSTYLE=XSTYLE,XTITLE=XTITLE,YTITLE='Depth (m)',TITLE=TITLE,/NODATA,XMARGIN=XMARGIN, YMARGIN=YMARGIN, CHARSIZE=CHARSIZE
				OPLOT,DAILY,DEPTH,PSYM=-2,COLOR=22,THICK=3,SYMSIZE=1.15
				OPLOT,XRANGE,[ZEU,ZEU],LINESTYLE=1, THICK=4
				IF N_ELEMENTS(ASET)  GT 1 THEN OPLOT,ASET.DAILY_PROD,ASET.DEPTH, COLOR=0, THICK=5, PSYM=2, SYMSIZE=1.5 ELSE $
				PLOTS,ASET.DAILY_PROD,ASET.DEPTH, COLOR=0, THICK=5, PSYM=2, SYMSIZE=1.5
		;		PLOTS,APROD.X_MAX_DEPTH,-ZEU,PSYM=2,COLOR=18,SYMSIZE=1.5,THICK=1.5
				TXT=   'Areal productivity = ' + '!C    ' + STRTRIM(STRING(AREAL),2) + ' (mg '+ELEM+' m!E-2!N)'
				COOR = COORD_2PLOT(0.05,0.2)
				XYOUTS, COOR.X,COOR.Y ,TXT,/DATA,ALIGN=0.0, COLOR=0,CHARSIZE=1

;	===> Plot chlorophyll profile
				S2 = MAXDEPTH+(MAXDEPTH/4.5)
				OK = WHERE(DSET.CHLOROPHYLL NE MISSINGS(0.0))
				AXIS,0,S2,XAXIS=0,!Y.CRANGE[1]*0.6,XRANGE=[0,ROUND(MAX(DSET[OK].CHLOROPHYLL)+1)],/XSTYLE,XTITLE='Chlorophyll (ug/L)', CHARSIZE=CHARSIZE, COLOR=12, /SAVE
				OPLOT,DSET[OK].CHLOROPHYLL,DSET[OK].DEPTH,COLOR = 12,THICK = 5
				OK = WHERE(DSET.TEMP NE MISSINGS(0.0))
;	===> Plot temperature profile
				S2 = MAXDEPTH+(MAXDEPTH/2.5)
				AXIS,0,S2,XAXIS=0,!Y.CRANGE[1]*0.6,XRANGE=[0,30],/XSTYLE,XTITLE='Temperature (C)', CHARSIZE=CHARSIZE, COLOR=4, /SAVE
				OPLOT, DSET[OK].TEMP,DSET[OK].DEPTH, COLOR=4, THICK=5, LINESTYLE=3
			ENDFOR
		ENDIF

		SKIP_DAILY:
		IF DAILY_YES LT 1 OR DO_DAILY LT 2 THEN BEGIN
			TXT = 'No daily data available'
			COOR = COORD_2PLOT(0.0,-0.5)
			XYOUTS,COOR.X, COOR.Y, TXT, COLOR=0, CHARSIZE=1
		ENDIF
		SKIP_PLOT:
	ENDFOR
	PSPRINT
	SAVE, FILENAME=SAVEPROD,PI,/COMPRESS
	SAVE_2CSV,SAVEPROD

	RETURN
END
