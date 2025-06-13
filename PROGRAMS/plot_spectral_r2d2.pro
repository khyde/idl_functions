; $ID:	PLOT_SPECTRAL_R2D2.PRO,	2020-07-08-15,	USER-KJWH	$

PRO PLOT_SPECTRAL_R2D2, WLS, DATA , TITLE=title
;+
; NAME:
;       PLOT_SPECTRAL_R2D2
;
; PURPOSE:
;				Generate a Spectral Diagnostic Plot (R2D2)
;       illustrating the Correlation Coefficient versus Bamd Distance (nm) for all combinations of bands in the input Rrs array
;
;
;
; INPUTS:
;				WLS:	Array of Wavelengths in nanometers (e.g. WLS=[412,443,490,510,555] )
;				DATA:	Array of Rrs where columns match the WLS and there are at least 3 rows (to allow a correlation)
;				TITLE: Title for the Plot
;
;	NOTE: Program assumes that WLS and the colums of the DATA are in INCREASING wavelength order
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 1999
;				updated: Nov 15, 2004 J.O'Reilly (pairs)
;-

; ***************************************************************************************
	ROUTINE_NAME = 'PLOT_SPECTRAL_R2D2'


;	===> CONSTANTS
	XRIGHT = 35 ; TO make room for the legend

;	===> Check inputs
	IF N_ELEMENTS(TITLE) NE 1 THEN _TITLE = '' ELSE _TITLE = TITLE

;	===> Check that at least 2 WLS provided
	SZ_WLS = SIZE(WLS,/STRUCT)
	IF SZ_WLS.DIMENSIONS[0] LT 2 OR SZ_WLS.DIMENSIONS[1] NE 0 THEN BEGIN
		PRINT,'ERROR: WLS must be an array of wavelengths e.g. WLS=[412,443,490,510,555]'
		GOTO, DONE
	ENDIF

;	===> Number of Wavelengths
	N_WLS = SZ_WLS.DIMENSIONS[0]

;	===> Check that the number of columns in DATA match the number of elements in WLS
	SZ_DATA = SIZE(DATA,/STRUCT)
	IF SZ_DATA.DIMENSIONS[0] NE N_WLS OR SZ_DATA.DIMENSIONS[1] LT 3 THEN BEGIN
		PRINT,'ERROR: DATA must be a array with the same number of columns as WLS and at least 3 Rows'
		GOTO, DONE
	ENDIF


;	===> Get all unique pairs of wavelengths
  PAIRS_WLS	=	PAIRS(WLS)
  N_PAIRS  	= N_ELEMENTS(PAIRS_WLS(0,*))
  PAIRS_SUBS=	PAIRS(WLS,/SUB)
  LABELS    = STRJOIN(PAIRS_SUBS(*))
  DIST_NM 	= REFORM(PAIRS_WLS(1,*) - PAIRS_WLS(0,*))
 	LABELS    = STRTRIM(STRJOIN(PAIRS_WLS(0,*)),2) + '-' + STRTRIM(STRJOIN(PAIRS_WLS(1,*)),2) ;; + 'nm'

;	===> Generate String Array of Letters A,B,C to represent each pair in the legend
	B=(BYTE(65+BINDGEN(N_PAIRS))) & B=REFORM(B,1,N_ELEMENTS(B)) & LETTERS= STRTRIM(B,2)
	LABELS = STRJOIN('!C!C'+ LETTERS + ' ' + LABELS)
	LABELS = '!C!CN='+ STRTRIM(SZ_DATA.DIMENSIONS[1],2) + LABELS


;	===> Get correlation coefficients for all pairs
	R  = 0.0D
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0,N_PAIRS-1 DO BEGIN
		R  = [R , CORRELATE( DATA(PAIRS_SUBS(0,NTH),*), DATA(PAIRS_SUBS(1,NTH),*),/DOUBLE  )]
	ENDFOR
	R =R (1:*)


;	===> Plot results
	PLOT, [0.0,MAX(DIST_NM) + XRIGHT],[-.5,1.1],/XSTYLE,/YSTYLE,$
		TITLE=_TITLE,XTITLE='Distance between band centers (nm)',YTITLE='Correlation',/NODATA ,$
		XGRIDSTYLE=1,XTICKLEN=1.0, YGRIDSTYLE=1,YTICKLEN=1.0
 	OPLOT, DIST_NM,R ,PSYM=3
 	XYOUTS,DIST_NM,R,LETTERS,ALIGN=0.5
	XYOUTS,!X.CRANGE[1],!Y.CRANGE[1],LABELS, /DATA, ALIGN=1.1

; ===> Connect series with lines
	X = REFORM(PAIRS_WLS(0,*))
	U = UNIQ(X)
	XU = X(U)
	FOR NTH=0,N_ELEMENTS(XU)-1 DO BEGIN
		OK=WHERE(X EQ XU[NTH])
		OPLOT,DIST_NM[OK], R[OK],LINESTYLE=NTH
	ENDFOR

	DONE:

END; #####################  End of Routine ################################
