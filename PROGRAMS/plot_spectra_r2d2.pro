; $ID:	PLOT_SPECTRA_R2D2.PRO,	2020-07-08-15,	USER-KJWH	$
; SIEGEL_PNB_EDIT,DB=DB & DATA = [[DB.RRS412], [DB.RRS443], [DB.RRS490], [DB.RRS510], [DB.RRS555], [DB.RRS656]]    & DATA = TRANSPOSE(DATA) & HELP, DATA & WL = [412,443,490,510,555,656] & PLOT_SPECTRA_R2D2, WL,DATA

 PRO PLOT_SPECTRA_R2D2,WL,DATA,  LABEL=label, QUIET=quiet,_EXTRA=_extra
;+
; NAME:
;       PLOT_SPECTRA_R2D2
;
; PURPOSE:
;       Plot Rrs or Lw Spectra
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;
; INPUTS:
;       WL:  Wavelengths (nm)
;       DATA: ARRAY with columns matching number of elements in WL
;
; KEYWORD PARAMETERS:
;       RATIO:  The nth wavelength to divide all
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 23,1999
;-

  PRO_NAME ='PLOT_SPECTRA_R2D2'

; ====================>
; Must provide LW, AND DATA
  IF N_PARAMS() LT 2 THEN STOP

  N_WL = N_ELEMENTS(WL)

; ===================>
; Number of rows in DATA must equal number of elements in WL
  ARRAY=DATA
  S=SIZE(ARRAY)
  IF S[0] EQ 2 THEN BEGIN
    N_BANDS = S[1]
    N_ROWS  = S(2)
  ENDIF
  IF S[0] EQ 1 THEN BEGIN
    N_BANDS = S[1]
    N_ROWS  = 1
  ENDIF
  IF N_BANDS NE N_WL THEN STOP



  DIST_NM = 0
  R2 = 0
  R = 0
  COUNTER = -1L
  ALPHA_LABELS = ''
  LABELS = ''

  _PAIRS = PAIRS(WL)
  _SUBS  = PAIRS(WL,/SUBS)
  N_PAIRS = N_ELEMENTS(_PAIRS(0,*))


  SET_PMULTI,N_PAIRS

  FOR NTH = 0,N_PAIRS-1L  DO BEGIN

    XSUB = _SUBS(0,NTH)
    YSUB = _SUBS(1,NTH)
    xname = NUM2STR(_PAIRS(0,NTH))
    yname = NUM2STR(_PAIRS(1,NTH))
    xtitle= xname + ' vs '+ yname
    ytitle = 'R2'
    PLOTXY, DATA(XSUB,*), DATA(YSUB,*) , /LOGLOG,PSYM=1,PARAMS=[8],/ystyle,/xstyle,$
           TITLE=TITLE,XTITLE=XTITLE,ytitle=ytitle,stats_pos=[0.02,0.95], symsize = 1,decimals=3,stats_charsize=.8,/QUIET,REG_LINESTYLE=31
    S=STATS2(ALOG10(DATA(XSUB,*)), ALOG10(DATA(YSUB,*)),/QUIET)
    S = S(4)
    DIST_NM=[DIST_NM, ABS(_PAIRS(1,NTH) - _PAIRS(0,NTH))]
    R2 = [R2,S.RSQ]
    R = [R,S.R]
    COUNTER=COUNTER+1
    ALPHA_LABELS = [ALPHA_LABELS, STRING(BYTE(65+COUNTER))]
    LABELS = [LABELS , XTITLE]
  ENDFOR
  IF KEYWORD_SET(PS) THEN   PSPRINT ELSE STOP

; ***************************************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,/full,/COLOR,FILE='d:\idl\programs\S_NM_DIST_'+SET+'.ps'

  !P.MULTI=0
  !P.MULTI=[0,1,2]
  !P.CHARSIZE=1.0
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARTHICK=2
  !X.THICK=2
  !Y.THICK=2
  !X.MARGIN=[7, 4]
  !Y.MARGIN=[4,3]
  !P.THICK=1

  R=R(1:*)
  R2=R2(1:*)
  DIST_NM = DIST_NM(1:*)
  ALPHA_LABELS=ALPHA_LABELS(1:*)
  LABELS = LABELS(1:*)


  PLOT, DIST_NM,R2,PSYM=1,/XSTYLE,/YSTYLE,SYMSIZE=0.5,THICK=2, XRANGE=[0,270],YRANGE=[0.0,1.0],$
        XTITLE = 'Distance Between Band Centers (nm)',YTITLE='R!U2!N (log-transformed data)', _EXTRA=_extra
  XYOUTS, DIST_NM,R2,ALPHA_LABELS,/DATA,charsize=1.4*!p.charsize,COLOR=21
  LEG_LABELS = ALPHA_LABELS + '  ' +  LABELS
  LEG, LABEL=LEG_LABELS,POS=[0.8, 0.1, 0.8,0.85],THICK=!P.CHARTHICK

  CAPTION,"J.O'Reilly, NOAA "
  IF KEYWORD_SET(PS) THEN   PSPRINT ELSE STOP




  END
