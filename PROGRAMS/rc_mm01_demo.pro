; $ID:	RC_MM01_DEMO.PRO,	2014-12-18	$

   PRO RC_MM01_DEMO
;+
; NAME:
;       RC_MM01_DEMO
;
; PURPOSE:
;       Demonstrate the Morel-Maritorena Rrs Correction Factor
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;        RC_MM01_DEMO
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


  RESTORE,'D:\IDL\DATA\MM01_CHL_RRS.SAVE

chl_label = 'Chl '+ UNITS('CHLM3')

f_485_490=RRS.rrs485/RRS.rrs490
f_510_520=RRS.rrs510/RRS.rrs520
f_510_531=RRS.rrs510/RRS.rrs531
f_520_531=RRS.rrs520/RRS.rrs531

f_550_555=RRS.rrs550/RRS.rrs555
f_550_565=RRS.rrs550/RRS.rrs565

f_555_560=RRS.rrs555/RRS.rrs560
f_555_565=RRS.rrs555/RRS.rrs565
f_555_570=RRS.rrs555/RRS.rrs570

COLORS=[0]
LABELS=[' ']

PLOT, RRS.CHL,f_510_531,/XLOG,/NODATA,TITLE='Morel-Maritorena 2001 Semi-Analytic Model',$
      xtitle=chl_label,ytitle='Ratio',$
      xrange=[0.001,100],/xstyle, YRANGE=[0.7,1.6],/YSTYLE,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET

GRIDS,XTICK_GET,YTICK_GET,COLOR=34,/all

LABEL='Rrs510/Rrs531' & COLOR = 26 & OPLOT, RRS.CHL,f_510_531,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs510/Rrs520' & COLOR = 22 & OPLOT, RRS.CHL,f_510_520,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs550/Rrs555' & COLOR = 19 & OPLOT, RRS.CHL,f_550_555,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs555/Rrs560' & COLOR = 17 & OPLOT, RRS.CHL,f_555_560,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs555/Rrs565' & COLOR = 13 & OPLOT, RRS.CHL,f_555_565,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs555/Rrs570' & COLOR = 10 & OPLOT, RRS.CHL,f_555_570,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]

LABEL='Rrs485/Rrs490' & COLOR = 8  & OPLOT, RRS.CHL,f_485_490,COLOR=COLOR & COLORS=[COLORS,COLOR] & LABELS=[LABELS,LABEL]



LEG,pos =[0.60 ,0.70,0.64,0.95], color=colors(1:*),label=labels(1:*),THICK=!P.THICK,LSIZE=1.1



STOP

END; OF PROGRAM

