PRO NORMCUM,  N=N,_EXTRA=_extra

; J. O'Reilly, NOAA, Narragansett, RI 02882


; PROGRAM GENERATES XHIST,CUMULATE(YHIST) FOR A NORMAL DISTRIBUTION
; Default is to use an N WITH 200000 PTS


  IF N_ELEMENTS(N) NE 1 THEN N = 200000

  GOTO, TEST_CV
; ==============>
; NORMAL DISTRIBUTION
  HISTPLOT,RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,_EXTRA=_extra


; ===========>
; THIS shows the influence of mean on cv

  TEST_CV: ; LABEL
  WINDOW,0,XSIZE=1000,YSIZE=1200
  SETCOLOR,255
  loadct,0
  !P.MULTI = [0,2,3]
  HISTPLOT,   RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[-5,5],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  HISTPLOT,2+ RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[-3,7],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  HISTPLOT,4+ RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[-1,9],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  HISTPLOT,6+ RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[1,11],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  HISTPLOT,10+RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[5,15],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  HISTPLOT,15+RANDOMN(SEED,200000),binsize=0.001,lab_bars=[7,1,7],xticks=10,xrange=[10,20],bar_thick=2,bar_color=196,bar_outline=196,XHIST,YHIST,DECIMALS=3,_EXTRA=_extra,/LAB_NONE
  caption, "J.O'Reilly, NOAA",charsize=.6

  TVLCT,R,G,B,/GET
  WRITE_GIF,'C:\IDL\JAY\NORMCUM.GIF',TVRD(),R,G,B
END ; END OF PROGRAM