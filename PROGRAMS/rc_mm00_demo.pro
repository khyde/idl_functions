; $ID:	RC_MM00_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

   PRO RC_MM00_DEMO
;+
; NAME:
;       RC_MM00_DEMO
;
; PURPOSE:
;       Demonstrate the Morel-Maritorena Rrs Correction Factor
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;        RC_MM00_DEMO
;
; INPUTS:
;       NONE
;
; KEYWORD PARAMETERS:
;       None
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
;       Written by:  J.E.O'Reilly, March 16,2000
;-


;
SETCOLOR,255
PAL_36
;WIN
!p.thick=4
!X.THICK=2
!Y.THICK=2
!P.CHARTHICK=2
!P.CHARSIZE=1.15

GOTO, NEW

; *************************************************************
OLD:  ; PROVIDED BY S. MARITORENA
; *************************************************************
x = FINDGEN(100000)*.001+.001
f_510_520=rc_mm00( X, 510,520)
PLOT, X,f_510_520,/XLOG,/NODATA,TITLE='Morel-Maritorena 2000 Semi-Analytic Model',$
      xtitle='Chl a (mg/m3)',ytitle='Ratio',$
      xrange=[0.001,100],/xstyle, YRANGE=[0.75,1.6],/YSTYLE,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
GRIDS,XTICK_GET,YTICK_GET,COLOR=34
& OPLOT, X, f_510_520,COLOR=22; 510_520
f_550_555=rc_mm00( X, 550,555) & OPLOT, X, f_550_555, COLOR=6
f_555_565=rc_mm00( X, 555,565) & OPLOT, X, f_555_565, COLOR=9
f_510_530=rc_mm00( X, 510,530) & OPLOT, X, f_510_530, COLOR=26
f_520_530=rc_mm00( X, 520,530) & OPLOT, X, f_520_530, COLOR=19
f_555_560=rc_mm00( X, 555,560) & OPLOT, X, f_555_560, COLOR=2
f_550_565 = f_550_555 * f_555_565
OPLOT, X, f_550_565, COLOR=10
LABEL= ['Rrs555/Rrs560','Rrs550/Rrs555','Rrs555/Rrs565','Rrs550/Rrs565','Rrs520/Rrs530','Rrs510/Rrs520','Rrs510/Rrs530']
label=reverse(label)
COLOR=[2,6,9,10,19,22,26]
color=reverse(color)
LEG,pos =[0.60 ,0.70,0.64,0.95], color=color,label=label,THICK=!P.THICK,LSIZE=1.1



; *************************************************************
	NEW:
; *************************************************************
  X = INTERVAL([-4,2.3],BASE=10,0.001)
  S=MM01_J(WAVE=[510,530],CHL=X,/RRS,/SPREADSHEET)
  LX =   ALOG10(X)
  Y=S.RRS510/S.RRS530

  ;S=MM01_J(WAVE=[510,530],CHL=X,/SPREADSHEET)

  ;Y=S.RI_510/S.RI_530
  A = POLY_FIT( LX, Y, 7,YFIT=YFIT,/DOUBLE)
  f_510_530=rc_mm00( X, 510,530)


 PLOT, X,f_510_530,/XLOG,/NODATA,TITLE='Morel-Maritorena 2000 Semi-Analytic Model',$
      xtitle='Chl a (mg/m3)',ytitle='Ratio',$
      xrange=[0.0001,200],/xstyle, YRANGE=[0.65,1.6],/YSTYLE,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
 GRIDS,XTICK_GET,YTICK_GET,COLOR=34
 & OPLOT, X, f_510_530, COLOR=26
 OPLOT, X,Y, COLOR=34

 MODEL = (A[0] + A[1]*LX + A(2)*LX^2+ A(3)*LX^3 +A(4)*LX^4 +A(5)*LX^5 +A(6)*LX^6 +A(7)*LX^7)
 OPLOT, X,MODEL,LINESTYLE=1,COLOR=21



STOP

END; OF PROGRAM

