; $ID:	PLOTSTAT4.PRO,	2014-12-18	$
  PRO PLTSTAT4 ,xx,yy , TITLE=title

  DIR_WORK='C:\IDL\JAY\'


  IF NOT KEYWORD_SET(TITLE) THEN TITLE = ' '
  PAL_36
  !P.MULTI=[0,2,3]
  IF KEYWORD_SET(PS) THEN psinit,file=dir_work +  'PLTSTAT4.ps',/FULL,/color

  PLOTXY, XX,YY,/loglog,XRANGE=[.01,100.],YRANGE=[.01,100.], $
            DECIMALS=3,params=[1,2,3,4,7,9,10],stats_pos=[.02,.99],$
            XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1 ,$
            TITLE= title ,$
            XTITLE='!8In Situ!X '  + ' (!8u!Xg/l)' ,$
            YTITLE='Model ' +  ' (!8u!Xg/l)',$
            stats_charsize=0.85,$
            /one2one,psym=1,color=0,yMARGIN=[4,2], CHARSIZE=1.5


  one2one,ratio= 5 ,linestyle=1
  one2one,ratio=.2 ,linestyle=1


; ====================>
; Quantile-Quantile Plot of in situ vs model
  q= QUANTILE( (XX), (YY) , /LOG,  SYMSIZE=.5,$
            XRANGE=[.01,100],YRANGE=[.01,100],$
            XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1 ,$
            TITLE=  TITLE ,$
            XTITLE='!8In Situ!X ' +    ' Quantiles (!8u!Xg/l)' ,$
            YTITLE='Model ' +  ' Quantiles (!8u!Xg/l)' ,yMARGIN=[4,2], CHARSIZE=1.5)


; ================>
; HISTOGRAM OF  ALL, MODEL
  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    histplot,alog10(YY/XX),    binsize=.05,xrange=[-1,1],$
             xtitle='Log(Model/!8In Situ!X)',title=TITLE ,$
             xticks=8,params=[0,1,2,3,4,6,9,10],decimals=3,charsize=1.5,$
             /lab_none,/cum_none,yMARGIN=[4,2],xmargin=[6,0] ,bar_color=34
    OPLOT,[0.0,0.0],[0.0,10000],THICK=4
  ENDIF

; ====================>
; Relative Frequency Plot of in situ vs model


  n_set = 'N= '+STRTRIM(STRING(N_ELEMENTS(XX)),2)
  RF_LOG,XX,label='!8In Situ!X', THICK=15,LINESTYLE=0,color=0 ,min=0.01,max=100.0,$
         TITLE=TITLE,XTITLE=  ' (!8u!Xg/l)',/NO_N,LTITLE=N_SET ,$
         LSIZE= 0.7 ,LPOS=[.63,.84,.74,.88],TSIZE=.7, yMARGIN=[4,2], CHARSIZE=1.5 ,binsize=.20

  RF_LOG,XX,OVERPLOT=0,          THICK=15,LINESTYLE=0,color=34 ,min=0.01,max=100.0,$
         LSIZE= 0.7 ,LPOS=[.63,.84,.74,.88],TSIZE=.7, /NO_N                      ,binsize=.20

  RF_LOG,YY,label='MODEL', THICK=5,LINESTYLE=0,color=0,min=0.01,max=100.0,$
         overplot=2,  /NO_N  ,LSIZE=.7 ,LPOS=[.63,.84,.74,.88]                   ,binsize=.20


 IF KEYWORD_SET(PS) THEN psterm
END
