; EQ_KW_DEMO    June 23,1999

  PRO EQ_KW_DEMO
;+
; NAME:
;       EQ_KW_DEMO
;
; PURPOSE:
;       Constructs plots of light absorption coefficients for pure seawater
;       according to several references (methods)
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       EQ_KW_DEMO
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       Plots Kw, plots difference between Kw'w, and plots ratios of Kw's
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY: June 8,1999 Written by J.O'Reilly & S. Maritorena
;-

  !P.MULTI=[0,1,3]
  !P.BACKGROUND = 255 & !P.COLOR=0
  LOADCT,39,NCOLORS=256


  L = INDGEN(301)+400
; =================>
; Get kw's
  kw_SB81=eq_kw(method='SB81',lambda=L)
  kw_P93 =eq_kw(method='P93', lambda=L)
  kw_PF97=eq_kw(method='PF97',lambda=L)

; ================>
  PLOT, L,kw_SB81, XRANGE=[350,750],/XSTYLE,$
        YRANGE=[0,0.70],/YSTYLE,YMINOR=1,$
        XTITLE = 'Wavelength (nm)',YTITLE='Kw (m!U-1!N)',$
        XTHICK=3,YTHICK=3,CHARSIZE=2.0,/NODATA

; Plot Smith & Baker 1981 kw
  OPLOT, L,kw_SB81, color=60,THICK=4,LINESTYLE=1
  OPLOT, [400,420],[0.6,0.6],color=60,THICK=4,LINESTYLE=1
  XYOUTS,430,0.6,'Smith & Baker 1981',color=60

; Plot Pope 1993 kw
  OPLOT, L,kw_P93, color=135,THICK=3
  OPLOT, [400,420],[0.5,0.5],THICK=3,color=135
  XYOUTS,430,0.5,'Pope 1993',color=135

; Plot Pope & Fry 1997
  OPLOT, L,kw_PF97, color=217,THICK=3
  OPLOT, [400,420],[0.4,0.4],THICK=3,color=217
  XYOUTS,430,0.4,'Pope & Fry 1997',color=217


; ================>
; Make difference plot
  PLOT, L,(kw_SB81-kw_PF97), XRANGE=[350,750],/XSTYLE,$
        YRANGE=[-0.045,0.035],/YSTYLE,$
        XTITLE = 'Wavelength (nm)',YTITLE='Kw (m!U-1!N)',$
        XTHICK=2,YTHICK=2,CHARSIZE=2.0, /NODATA

  OPLOT, [355,745],[0,0], LINESTYLE=1,COLOR=0 ; reference line

; Plot Smith & Baker - Pope & Fry 1997
  OPLOT,L, (kw_SB81-kw_PF97),COLOR=60,THICK=4,LINESTYLE=1
  OPLOT, [400,420],[-0.014,-0.014],color=60,THICK=4,LINESTYLE=1
  XYOUTS,430,-0.014,'(Smith & Baker 1981) - (Pope & Fry 1997)',color=60

; Plot Pope 1993 - Pope & Fry 1997
  OPLOT,L, (kw_p93-kw_PF97),COLOR=135,THICK=3
  OPLOT, [400,420],[-0.024,-0.024],color=135,THICK=3
  XYOUTS,430,-0.024,'(Pope 1993) - (Pope & Fry 1997)',color=135


; ================>
  PLOT, L,(kw_SB81)/kw_PF97, XRANGE=[350,750],/XSTYLE,$
        YRANGE=[0.9,2.5],/YSTYLE,$
        XTITLE = 'Wavelength (nm)',YTITLE='Ratio',$
        XTHICK=2,YTHICK=2,CHARSIZE=2.0,/NODATA

  OPLOT, [355,745],[1,1], LINESTYLE=1,COLOR=0

  OPLOT,L, (kw_SB81)/kw_PF97,COLOR=60,THICK=4,LINESTYLE=1
  OPLOT, [450,470],[2.25,2.25],color=60,THICK=4,LINESTYLE=1
  XYOUTS,480,2.25,'(Smith & Baker 1981)/(Pope & Fry 1997)',color=60

  OPLOT,L, (kw_p93)/kw_PF97,COLOR=135,THICK=3
  OPLOT, [450,470],[2.0,2.0],color=135,THICK=3
  XYOUTS,480,2.0,'(Pope 1993)/(Pope & Fry 1997)',color=135


  XYOUTS,0.97,0.01,/normal,"O'Reilly & Maritorena, 1999",align=1.0,CHARSIZE=0.4

END ; END OF PROGRAM