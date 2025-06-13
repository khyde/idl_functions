; $ID:	RRS_GLOBAL_CHL_PLOT_VS_VERSION.PRO,	2014-12-18	$
PRO rrs_global_chl_plot_vs_version, QUIET=quiet, PS=ps, _EXTRA=_eXTRA

  DIR_OUT = 'D:\BIOOPT\OREILLY\'
  ROUTINE_NAME = 'rrs_global_chl_plot_vs_version'
  PS=1
  pal36,R,G,B
  SETCOLOR,255
  GREY = 34

  !P.CHARTHICK=2
  !Y.OMARGIN=[2,2]
  !X.OMARGIN=[2,2]
  DEC=DECADES()

  FONT_TIMES

  GOTO, DO_PLUS_L3B_GLOBAL
; *****************************************************************************
;  PLOT OF GLOBAL CHL DIST VS VERSION:
; ******************************************************************************
; ALL DATA LE 64
  RESTORE,'D:\BIOOPT\OREILLY\SWRDGLOB_MARCH30_2000.SAVE'


  SET_PMULTI

  circle,fill=1,COLOR=0
  YTICKNAME=['0.01','0.1','1','10']
  YTICKV = YTICKNAME
  TX =  '(Rrs443>Rrs490>Rrs510)/Rrs555'
  TITLE_CHL =  'Chl a (!8u!Xg/l)'
  symsize=0.3



  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_OUT+ROUTINE_NAME+'_a.ps'

  !X.THICK=1
  !Y.THICK=1


; ========================>

  xx = sb.chla
  yy=sb.chla
  PIG_NAME ='Chl'
  char_scale=1.0


  rf_log, sb.chla, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.74,.88],TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE='C '+UNITS('CHLM3'),YTICKS=10,YMINOR=1,GRIDS_COLOR=34,grids_thick=3



  HISTPLOT, ALOG10(SB.CHLA), BINSIZE=0.05,XHIST,YHIST,/QUIET, XRANGE=[-3,2]

_linestyle=5
_thick = 5
_color=0
ltitle='V4: Cumulative'
OPLOT, 10.0^XHIST,CUMULATE(YHIST)/TOTAL(YHIST),COLOR=_color,THICK=_thick,LINESTYLE=_linestyle
AXIS,/YAXIS,yTITLE='Cumulative Frequency'
LPOS=[.63,.57,.74,.61]

LEG, POS=LPOS,color=_color,LINESTYLE=_linestyle,thick=_thick, TSIZE=.5,Label=ltitle ,Lsize=0.8

; read seabam 2

  sb= SWRDGLOB(/OLD1174)
RF_LOG, SB.CHLA,OVERPLOT=1.5, LINESTYLE=1,THICK=5,$
min=0.001,max=100.0,LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.74,.88],TSIZE=.7,$
        label=' V2: '

;OLD 919
sb= SWRDGLOB(/OLD919)
RF_LOG, SB.CHLA,OVERPLOT=3, LINESTYLE=2, THICK=5,$
min=0.001,max=100.0,LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.74,.88],TSIZE=.7,$
     label=' V1: '

IF KEYWORD_SET(PS) THEN PSPRINT




  DO_PLUS_L3B_GLOBAL:
; *****************************************************************************
;  PLOT OF GLOBAL CHL DIST VS VERSION A N D   SEAWIFS L3B DAILY GLOBAL:
; ******************************************************************************
; ALL DATA LE 64
  RESTORE,'D:\BIOOPT\OREILLY\SWRDGLOB.SAVE'
  S=READALL('K:\SEAWIFS_GLOBAL\L3b_DAY_Y_1998_Y_2000_FREQ_chlor_a.save')
  SET_PMULTI
  circle,fill=1,COLOR=0
  YTICKNAME=['0.01','0.1','1','10']
  YTICKV = YTICKNAME
  TX =  '(Rrs443>Rrs490>Rrs510)/Rrs555'
  TITLE_CHL =  'Chl a '+UNITS('CHLOR_A')
  symsize=0.3

  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_OUT+ROUTINE_NAME+'_b.ps'

  !X.THICK=3
  !Y.THICK=3
  PAL_36,R,G,B

; ========================>
  xx = sb.chla
  yy=sb.chla
  PIG_NAME ='Chl'
  char_scale=1.0
  TITLE_CHL =  'Chl !8a!X '+UNITS('CHLM3')
  LPOS=[.64,.96,.71,.98]

  rf_log, sb.chla, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=0

  rf_log, sb.chla,OVERPLOT=0, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=13

  HISTPLOT, ALOG10(SB.CHLA), BINSIZE=0.05,XHIST,YHIST,/QUIET, XRANGE=[-3,2]

 _linestyle=5
 _thick = 5
 _color=12
 ltitle='V4: Cumulative'
 ;OPLOT, 10.0^XHIST,CUMULATE(YHIST)/TOTAL(YHIST),COLOR=_color,THICK=_thick,LINESTYLE=_linestyle
 ;AXIS,/YAXIS,yTITLE='Cumulative Frequency'


LPOS=[.63,.96,.71,.98]
; read seabam 2

;  sb= SWRDGLOB(/OLD1174)
;RF_LOG, SB.CHLA,OVERPLOT=1.5, LINESTYLE=1,THICK=5,$
;min=0.001,max=100.0,LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.74,.88],TSIZE=.7,$
;        label=' V2: ',COLOR=0

;OLD 919
sb= SWRDGLOB(/OLD919)
RF_LOG, SB.CHLA,OVERPLOT=1, LINESTYLE=2, THICK=5,$
min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1,$
     label=' V1: ',COLOR=32

LPOS=[.63,.86,.71,.93]

OPLOT, S.CHL, MEDIAN(S._FR,5),LINESTYLE=0,THICK= 6,COLOR=8
LEG, POS=LPOS,color=8,LINESTYLE=0,thick=6, TSIZE=TSIZE,Label='SeaWiFS!CMean Global!CL3b Day!C1998,1999,2000',Lsize=1.0


IF KEYWORD_SET(PS) THEN PSPRINT
STOP



  DO_PLUS_L3B_GLOBALB:
; *****************************************************************************
;  PLOT OF GLOBAL CHL DIST VS VERSION A N D   SEAWIFS L3B DAILY GLOBAL:
; ******************************************************************************
; ALL DATA LE 64
  RESTORE,'D:\BIOOPT\OREILLY\SWRDGLOB.SAVE'
  S=READALL('K:\SEAWIFS_GLOBAL\L3b_DAY_Y_1998_Y_2000_FREQ_chlor_a.save')
  SET_PMULTI
  circle,fill=1,COLOR=0
  YTICKNAME=['0.01','0.1','1','10']
  YTICKV = YTICKNAME
  TX =  '(Rrs443>Rrs490>Rrs510)/Rrs555'
  TITLE_CHL =  'Chl a '+UNITS('CHLOR_A')
  symsize=0.3

  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_OUT+ROUTINE_NAME+'_B2.ps'

  !X.THICK=3
  !Y.THICK=3
  PAL_36,R,G,B

; ========================>
  xx = sb.chla
  yy=sb.chla
  PIG_NAME ='Chl'
  char_scale=1.0
  TITLE_CHL =  'Chl !8a!X '+UNITS('CHLM3')
  LPOS=[.64,.96,.71,.98]

  rf_log, sb.chla, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=0

  rf_log, sb.chla,OVERPLOT=0, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=13

  HISTPLOT, ALOG10(SB.CHLA), BINSIZE=0.05,XHIST,YHIST,/QUIET, XRANGE=[-3,2]

 _linestyle=5
 _thick = 5
 _color=12
 ltitle='V4: Cumulative'
 ;OPLOT, 10.0^XHIST,CUMULATE(YHIST)/TOTAL(YHIST),COLOR=_color,THICK=_thick,LINESTYLE=_linestyle
 ;AXIS,/YAXIS,yTITLE='Cumulative Frequency'


LPOS=[.63,.96,.71,.98]
; read seabam 2

;  sb= SWRDGLOB(/OLD1174)
;RF_LOG, SB.CHLA,OVERPLOT=1.5, LINESTYLE=1,THICK=5,$
;min=0.001,max=100.0,LSIZE= 0.7*char_scale ,LPOS=[.63,.84,.74,.88],TSIZE=.7,$
;        label=' V2: ',COLOR=0

;OLD 919
;sb= SWRDGLOB(/OLD919)
;RF_LOG, SB.CHLA,OVERPLOT=1, LINESTYLE=2, THICK=5,$
;min=0.001,max=100.0,LSIZE= 1*char_scale ,LPOS=LPOS,TSIZE=1,$
;     label=' V1: ',COLOR=32

LPOS=[.63,.86,.71,.93]

OPLOT, S.CHL, MEDIAN(S._FR,5),LINESTYLE=0,THICK= 6,COLOR=8
LEG, POS=LPOS,color=8,LINESTYLE=0,thick=6, TSIZE=TSIZE,Label='SeaWiFS!CMean Global!CL3b Day!C1998,1999,2000',Lsize=1.0


IF KEYWORD_SET(PS) THEN PSPRINT
STOP



 DO_PLUS_L3B_GLOBAL_V4:
; *****************************************************************************
;  PLOT OF GLOBAL CHL DIST VS VERSION A N D   SEAWIFS L3B DAILY GLOBAL:
; ******************************************************************************
; ALL DATA LE 64
  RESTORE,'D:\BIOOPT\OREILLY\SWRDGLOB.SAVE'
  S=READALL('K:\SEAWIFS_GLOBAL\L3b_DAY_Y_1998_Y_2000_FREQ_chlor_a.save')
  SET_PMULTI
  circle,fill=1,COLOR=0
  YTICKNAME=['0.01','0.1','1','10']
  YTICKV = YTICKNAME
  TX =  '(Rrs443>Rrs490>Rrs510)/Rrs555'
   TITLE_CHL =  'Chl !8a!X '+UNITS('CHLM3')
  symsize=0.3


  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_OUT+ROUTINE_NAME+'_c.ps'

  !X.THICK=3
  !Y.THICK=3
  PAL_36,R,G,B

; ========================>
  xx = sb.chla
  yy=sb.chla
  PIG_NAME ='Chl'
  char_scale=1.0

  rf_log, sb.chla, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 0.9*char_scale ,LPOS=[.63,.88,.74,.92],TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=0,/xstyle

  rf_log, sb.chla,OVERPLOT=0, LINESTYLE=0,THICK=7, $
      min=0.001,max=100.0,LSIZE= 0.9*char_scale ,LPOS=[.63,.88,.74,.92],TSIZE=1.0,$
      TITLE='Global Data Set', label=' V4: ', XTITLE=TITLE_CHL,YTICKS=10,YMINOR=1,$
      GRIDS_COLOR=35,grids_thick=3,COLOR=13,/xstyle

  HISTPLOT, ALOG10(SB.CHLA), BINSIZE=0.05,XHIST,YHIST,/QUIET, XRANGE=[-3,2]

 _linestyle=5
 _thick = 5
 _color=12
 ltitle='V4: Cumulative'
 ;OPLOT, 10.0^XHIST,CUMULATE(YHIST)/TOTAL(YHIST),COLOR=_color,THICK=_thick,LINESTYLE=_linestyle
 ;AXIS,/YAXIS,yTITLE='Cumulative Frequency'
 LPOS=[.63,.83,.74,.91]

OPLOT, S.CHL, MEDIAN(S._FR,5),LINESTYLE=0,THICK= 6,COLOR=8
LEG, POS=LPOS,color=8,LINESTYLE=0,thick=6, TSIZE=TSIZE,Label='SeaWiFS!CMean Global!CL3b Day!C1998,1999,2000',Lsize=1.0

IF KEYWORD_SET(PS) THEN PSPRINT






END ; OF PROGRAM
