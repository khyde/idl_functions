; $ID:	PLOT_SPECTRA_Q1.PRO,	2014-12-18	$
PRO PLOT_SPECTRA_Q1, DB=DB,TITLE_PAGE=title_page, PS=ps

 PRO_NAME = 'PLOT_SPECTRA_Q'


 d = db

; ==================>
  IF KEYWORD_SET(PS) THEN PSPRINT,/FULL,/COLOR,FILE=PRO_NAME+'_Q_1.PS'
  SETCOLOR,255
  PAL_36
  !P.MULTI=[0,3,3]
  !p.charsize=1.5
  !X.MARGIN=[10,.5]

  PLOTXY, d.RRS412/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS412/RRS555',ytitle='Chl a (ug/l)',xrange=[0.05,10],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=0.5
  PLOTXY, d.RRS443/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS443/RRS555',ytitle='Chl a (ug/l)',xrange=[0.01,10],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=0.5

  PLOTXY, d.RRS490/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS490/RRS555',ytitle='Chl a',xrange=[0.01,10],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=0.5
  PLOTXY, d.RRS510/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS510/RRS555',ytitle='Chl a (ug/l)',xrange=[0.01,10],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=0.5
  PLOTXY, d.RRS443/d.RRS490, d.RRS412/d.RRS510,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS443/RRS490',ytitle='RRS412/RRS510',xrange=[0.1,10],yrange=[0.01,10],symsize = .5,decimals=3,stats_charsize=0.5
  PLOTXY, d.RRS412/d.RRS490, d.RRS443/d.RRS510,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS412/RRS490',ytitle='RRS443/RRS510',xrange=[0.01,10],yrange=[0.01,10],symsize = .5,decimals=3,stats_charsize=0.5
  PLOTXY, d.RRS412/d.RRS490, d.RRS443/D.RRS555,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='RRS412/RRS490',ytitle='RRS443/RRS555',xrange=[0.01,10],yrange=[0.01,10],symsize = .5,decimals=3,stats_charsize=0.5
  CAPTION
  IF KEYWORD_SET(PS) THEN PSPRINT


; ===========>
; highlight 490/555 and criteria
  IF KEYWORD_SET(PS) THEN PSPRINT,/FULL,/COLOR,FILE=DIR_WORK+PRO_NAME+'_Q3.PS' ELSE STOP
  SETCOLOR,255
  PAL_36
  !P.MULTI=[0,2,3]
  !p.charsize=1.5
  !X.MARGIN=[10,.5]
  SIEGEL_PNB_EDIT,DB=d; ALL INCLUSIVE

  PLOTXY, d.RRS443/d.RRS490, d.RRS412/d.RRS510,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='Rrs443/Rrs490',ytitle='Rrs412/Rrs510',xrange=[0.1,10],yrange=[0.01,10],symsize = 1.25,thick=2,decimals=3,stats_charsize=.75,/nodata
          oplot, d.RRS443/d.RRS490, d.RRS412/d.RRS510,psym=1, symsize=1.25,thick=2,color=6
  PLOTXY, d.RRS490/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='Rrs490/Rrs555',ytitle='Chl a',xrange=[0.01,10],yrange=[0.01,100],symsize = 1.25,thick=2,decimals=3,stats_charsize=.75,/nodata
          oplot, d.RRS490/D.RRS555,d.CHL_F, psym=1,symsize=1.25,thick=2,color=6

  SIEGEL_PNB_EDIT,DB=d, /SPECTRAL

  PLOTXY, d.RRS443/d.RRS490, d.RRS412/d.RRS510,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='Rrs443/Rrs490',ytitle='Rrs412/Rrs510',xrange=[0.1,10],yrange=[0.01,10],symsize = 1.25,thick=2,decimals=3,stats_charsize=.75,/nodata
          oplot, d.RRS443/d.RRS490, d.RRS412/d.RRS510, psym=1,symsize=1.25,thick=2,color=21

  PLOTXY, d.RRS490/D.RRS555,d.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='Rrs490/Rrs555',ytitle='Chl a',xrange=[0.01,10],yrange=[0.01,100],symsize = 1.25,thick=2,decimals=3,stats_charsize=.75,/nodata
          oplot,d.RRS490/D.RRS555,d.CHL_F, psym=1,symsize=1.25,thick=2,color=21
  IF KEYWORD_SET(PS) THEN PSPRINT



  IF KEYWORD_SET(PS) THEN PSPRINT,/FULL,/COLOR,FILE=DIR_WORK+PRO_NAME+'_Q4.PS' ELSE STOP
; ======================
; Now show band ratios increasing at high chl and decreasing at low chlorophyll

  !P.MULTI=[0,1,2]
  !P.CHARSIZE=1.2
  !X.MARGIN=[10,3]
  SETCOLOR,255
  PAL_36

  SIEGEL_PNB_EDIT,DB=d, /SPECTRAL

  PLOTXY, D.RRS490/D.RRS555,D.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          D.RRS555,xtitle='Rrs490/Rrs555',ytitle='Chl a',xrange=[0.1,5],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=1,SYMSIZE=2,THICK=2

  PLOTXY, D.RRS490/D.RRS555,D.CHL_F,/LOGLOG,PSYM=1,PARAMS=[1,2,3,4,8,10],/ystyle,/xstyle,$
          TITLE='Plumes and Blooms (Corrected for Instrument Self-Shading',xtitle='Rrs490s/RRS555s',ytitle='Chl a',xrange=[0.1,5],yrange=[0.01,100],symsize = .5,decimals=3,stats_charsize=1,SYMSIZE=2,THICK=2
  CAPTION
  IF KEYWORD_SET(PS) THEN PSPRINT



STOP

IF KEYWORD_SET(PS) THEN BEGIN
FILES = FILELIST('D:\BIOOPT\HARDING\*.PS')
 LPR,FILES,WAIT=60
ENDIF

  !X.MARGIN=[10,3]
  !P.CHARSIZE=1
END
