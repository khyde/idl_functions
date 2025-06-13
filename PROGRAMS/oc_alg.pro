; $ID:	OC_ALG.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Program Compares Various Ocean Color Algorithms with other algorithms
; SYNTAX:
;	OC_ALG_VERSUS, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = OC_ALG_VERSUS(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;	DT
; NOTES:


; VERSION:
;		Aug 31, 2001
; HISTORY:
;		Aug 31, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO OC_ALG, ps=ps , DIR_PLOTS=dir_plots
  ROUTINE_NAME='OC_ALG'
  DIR_OUT = 'D:\BIOOPT\OREILLY\'
  IF N_ELEMENTS(DIR_PLOTS) NE 1 THEN DIR_PLOTS = 'D:\BIOOPT\PLOTS\'
  RESTORE,'D:\BIOOPT\SAVE\OC_GLOBAL_EDIT_TRIM_OC4_4.SAVE'
  ds = sb

  pal36,R,G,B
  SETCOLOR,255
  GREY = 34
  FONT_TIMES
  COLORS =[4,10,13]

  !p.multi= 0
  chl_TICKNAME=['0.001','0.01','0.1','1','10','100']
  chl_TICKV    = [0.001,0.01,0.1,1,10,100]
  chl_ticks   = N_ELEMENTS(chl_TICKV)-1
  chl_range=[0.01,100]
  chl_psym = 1
  chl_symsize = 0.5

  BR_TICKNAME=['0.1','1','10']
  BR_TICKV    = [0.1,1.0,10.0]
  BR_tick   = N_ELEMENTS(xtickv)-1
  BR_range=[0.1,20]
  BR_psym = 1
  BR_symsize = 0.5


  CHLA = DS.CHLA
; ====================> Subject the measured Rrs to the various algorithms
  oc2_4 	= A_OC2C_4(DS.R490,  DS.R555_565B)
  oc4_4 	= A_OC4_4(DS.R443, DS.R490, DS.R510_I510, DS.R555_565B)
  OC4O_4  = A_OC4O_4(DS.R443,DS.R490, DS.R520_I520, DS.R565_I565)
  OC4G_4  = A_OC4G_4(DS.R443,DS.R485_I485, DS.R520_I520, DS.R570_I570)

  OCTS_C  = A_OCTS_C(DS.R490, DS.R520_I520, DS.R565_I565)

  oc3M_4 	= A_OC3M_4(DS.R443, DS.R490,  DS.R550_I550)
  Clark_CHL_MODIS=A_CLARK_CHL_MODIS(DS.R443,DS.R550_I550)


; Make a band ratio array
  RX =  0.001+ double(Lindgen(100000)*0.001)
  ok = WHERE(RX GE .1 AND RX LE 100)
  rx1 = rx(ok)
  rx2 = REPLICATE(1.0,N_ELEMENTS(rx1))
  ratio = rx1/rx2
  OK = WHERE(RATIO GE .2 AND RATIO LE 30)
  RATIO=RATIO[OK]
  RRS_RATIO=RATIO


  MODEL_oc2_4=A_OC2C_4(RATIO,1.0)
  MODEL_oc4_4=A_OC4_4(RATIO,RATIO,RATIO,1.0)
  MODEL_oc3M_4=A_OC3M_4(RATIO,RATIO,1.0)
  MODEL_oc4O_4=A_OC4o_4(RATIO,RATIO,RATIO,1.0)
  MODEL_oc4G_4=A_OC4G_4(RATIO,RATIO,RATIO,1.0)
;  MODEL_oc4O_4b=A_OC4o_4b(RATIO,RATIO,RATIO,1.0)
  MODEL_oc4O_4C=A_OC4o_4C(RATIO,RATIO,RATIO,1.0)
  MODEL_oc4O_4d=A_OC4o_4d(RATIO,RATIO,RATIO,1.0)
  MODEL_octs_c =A_OCTS_C(RATIO,RATIO,1.0,/RRS)
  MODEL_clark_chl_modis =A_CLARK_CHL_MODIS(RATIO,1.0);,/RRS)

  ok = where(MODEL_oc4O_4 gt 0.0001D and FINITE(MODEL_oc4O_4),COUNT)
  IF COUNT GE 1 THEN BEGIN
    RATIO=RATIO[OK]
    RRS_RATIO=RRS_RATIO[OK]
    MODEL_oc2_4=MODEL_oc2_4[OK]
    MODEL_oc4_4=MODEL_oc4_4(ok)
    MODEL_oc4O_4=MODEL_oc4O_4(ok)
  ;  MODEL_oc4O_4b=MODEL_oc4O_4b(ok)
    MODEL_oc4O_4d=MODEL_oc4O_4d(ok)
    MODEL_octs_c=MODEL_octs_c(ok)
    MODEL_clark_chl_modis=MODEL_clark_chl_modis(ok)
  ENDIF
PS=1
;GOTO,OC4_OC4O_OCTSC_vs_insitu_b
;GOTO,OC4O_v4_MB_vs_CHL
;GOTO,OC4O_v4_REL_FREQ_MB_vs_CHL
;GOTO, OC4O_v4_MBR_vs_CHL
;GOTO, OC4_VS_OC4O
;GOTO, LINE_OC2_4
;GOTO, OC4O_v4_MB_vs_CHL
;GOTO,OC4O_v4_MBR_vs_CHL
 ;GOTO,OC4_v4_MBR_vs_CHL_001
 ;GOTO,OC4_v4_MBR_vs_CHL_01
;goto, OC4O_v4_MB_vs_CHL
;GOTO, HIST2D_OC4_4
;GOTO, HIST2D_OC4_4_001
;GOTO, HIST2D_OC4O_4
;GOTO, GOAL_35_PERCENT
;goto, HIST2D_OC4_4_VS_IN_SITU
;GOTO, HIST2D_OC3M_4
;GOTO, HIST2D_OC4_4

GOTO,OC4G_v4_MBR_vs_CHL


; ************************************
  GOAL_35_PERCENT:
  LABEL = 'GOAL_35_PERCENT'
; ************************************
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  psprint,filename=psfile,/color,/half
  FONT_TIMES
  !P.MULTI= [0,2,1]
  ;  PLOT,RRS_RATIO, MODEL_oc2_4 ,COLOR=0,/XLOG,/YLOG
;  ===================================>
;  Generate variables x and y

;   RATIO_NOISE =    10.^(ALOG10((RRS_RATIO))   + 0.01* (RANDOMU(s,n_elements(RATIO),/NORMAL)) - 0.01* (RANDOMU(s,n_elements(RATIO),/NORMAL)))
;  ; RATIO_NOISE = 10.^RATIO_NOISE
;   MODEL_oc2_4_NOISE=A_OC2C_4(RATIO_NOISE,1.0)
;   OPLOT,RRS_RATIO, MODEL_oc2_4_NOISE ,PSYM=3,COLOR=21
;   PLOTXY, CHLA,MODEL_OC2_4_NOISE,PSYM=1,/LOGLOG
   chl_TICKNAME=['0.01','0.1','1','10','100']
   chl_TICKV    = [0.01,0.1,1,10,100]
   chl_ticks   = N_ELEMENTS(chl_TICKV)-1
   chl_range=[0.01,100]
    PLOTXY,CHLA,OC4_4,PSYM=1,/LOGLOG,DECIMALS=2,/brief,$
  				Title=' ',/ISOTROPIC,$
          PARAMS=[ 8,10 ],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='in situ Chl '+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,yTITLE='Chl Algorithm '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,THICK=2,$
          REG_LINESYTLE=31, /mean_none,/reg_none,/GRID_NONE,$
          /one2one,one_color=8,one_thick=5,$
          xthick=4,ythick=4,grid_color=34,grid_thick=4,xcharsize=1.25,ycharsize=1.25,stats_charsize=1.8,stats_color=21

          ONE2ONE,COLOR=255

    SUBS=ROBUST_REG(ALOG10(OC4_4),ALOG10(CHLA),RSQ=0.954)
      PLOTXY,CHLA(SUBS),OC4_4(SUBS),PSYM=1,/LOGLOG,DECIMALS=2,/brief,$
  				Title=' ',/ISOTROPIC,$
          PARAMS=[ 8,10 ],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='in situ Chl '+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,yTITLE='Chl Algorithm '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,THICK=2,$
          REG_LINESYTLE=31, /mean_none,/reg_none,/GRID_NONE,$
          /one2one,one_color=8,one_thick=5,$
          xthick=4,ythick=4,grid_color=34,grid_thick=4,xcharsize=1.25,ycharsize=1.25,stats_charsize=1.8,stats_color=21
           ONE2ONE,COLOR=255
  psprint

STOP




STOP


; **********************************
; *** HIST2D OC2 v4
; **********************************

  HIST2D_OC2_4:
  LABEL='HIST2D_OC2_4'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[0,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10(ds.r490/ds.r555_565b),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -2, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.01,100],$
    XTITLE=UNITS('OC2'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC2_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]




; **********************************
; ***  LINE_OC2_4
; **********************************
  LINE_OC2_4:
  LABEL='LINE_OC2_4'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[2,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2

  chl_TICKNAME=[ '0.01','0.1','1','10','100']
  chl_TICKV    = [ 0.01,0.1,1,10,100]
  chl_ticks   = N_ELEMENTS(chl_TICKV)-1
  chl_range=[0.01,100]
  chl_psym = 1
  chl_symsize = 0.5

  BR_TICKNAME=['0.1','1','10']
  BR_TICKV    = [0.1,1.0,10.0]
  BR_tick   = N_ELEMENTS(xtickv)-1
  BR_range=[0.1,20]
  BR_psym = 1
  BR_symsize = 0.5

  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  PSPRINT,FILENAME=PSFILE,/COLOR,/HALF
  FONT_TIMES
    plot,  RRS_RATIO,MODEL_OC2_4,/NODATA,/XLOG,/YLOG,XRANGE=[0.1,20],YRANGE=[0.01,100],$
           XTITLE=UNITS('OC2'),YTITLE=UNITS('CHLOR_A',/NAME),/XSTYLE,/YSTYLE,CHARSIZE=2.5,$
           XTICKS=BR_TICKS,XTICKV=BR_TICKV,XTICKNAME=BR_TICKNAME,YTICKS=CHL_TICKS,YTICKV=CHL_TICKV,YTICKNAME=CHL_TICKNAME,$
           XTICK_GET=xtick_get,YTICK_GET=ytick_get,xthick=7,ythick=7
           GRIDS,XTICK_GET,ytick_get,COLOR=33,THICK=4,/ALL,frame=5
    OPLOT, RRS_RATIO,MODEL_OC2_4, COLOR=21,THICK=10
    PLOTS,[6.13,6.13],[0.006,0.003], COLOR=8,THICK=8
    PLOTS,[6.66,6.66],[0.006,0.003], COLOR=8,THICK=8
  PSPRINT
  STOP


; **********************************
; *** HIST2D OC4 v4
; **********************************

  HIST2D_OC4_4:
  LABEL='HIST2D_OC4_4'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10((DS.R443>DS.R490>DS.R510_I510)/DS.R555_565B),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -2, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.01,100],$
    XTITLE=UNITS('OC4'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC4_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]
STOP


; **********************************
; *** HIST2D OC4 v4 001
; **********************************

  HIST2D_OC4_4_001:
  LABEL='HIST2D_OC4_4_001'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10((DS.R443>DS.R490>DS.R510_I510)/DS.R555_565B),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -3, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.001,100],$
    XTITLE=UNITS('OC4'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC4_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]
STOP



; **********************************
HIST2D_OC4_4_VS_IN_SITU:
; **********************************
  LABEL='HIST2D_OC4_4_VS_IN_SITU'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10(ds.chla),ALOG10(OC4_4),/LOGLOG,$
    bin1=0.05,bin2=0.05, min1= -2, min2= -2, max1= 2, max2= 2, MAG=16,$
    XRANGE=[0.01,100],YRANGE=[.01,100],$
    YTITLE= 'OC4 ' + UNITS('CHLOR_A',/name),XTITLE='in situ '+ UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE, $
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    ONE_THICK=[7,2],ONE_COLOR=[0,255],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.4,0.8],SAMPLE=0
STOP



; **********************************
; *** HIST2D OC3M v4
; **********************************

  HIST2D_OC3M_4:
  LABEL='HIST2D_OC3M_4'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10((DS.R443>DS.R490)/DS.R550_I550),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -2, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.01,100],$
    XTITLE=UNITS('OC3M'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC3M_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]
STOP


; **********************************
; *** HIST2D OC3M v4 001
; **********************************

  HIST2D_OC3M_4_001:
  LABEL='HIST2D_OC3M_4_001'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10((DS.R443>DS.R490)/DS.R550_I550),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -3, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.001,100],$
    XTITLE=UNITS('OC3M'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC3M_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]
STOP



; **********************************
HIST2D_OC3M_4_VS_IN_SITU:
; **********************************
  LABEL='HIST2D_OC3M_4_VS_IN_SITU'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10(ds.chla),ALOG10(OC3M_4),/LOGLOG,$
    bin1=0.05,bin2=0.05, min1= -2, min2= -2, max1= 2, max2= 2, MAG=16,$
    XRANGE=[0.01,100],YRANGE=[.01,100],$
    YTITLE= 'OC3M ' + UNITS('CHLOR_A',/name),XTITLE='in situ '+ UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE, $
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    ONE_THICK=[7,2],ONE_COLOR=[0,255],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.4,0.8]
STOP

; END OF OC3M





















; **********************************
  HIST2D_OC4O_4:
; **********************************
  LABEL='HIST2D_OC4O_4'
  !P.MULTI=0
  !P.MULTI=0

  !P.CHARSIZE=0
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[50,0]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=2
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  FONT_TIMES
   hist2d_plot, alog10((DS.R443>DS.R490>DS.R520_I520)/DS.R565_I565),alog10(ds.chla) ,$
    bin1=0.03,bin2=0.05, min1= -1, min2= -2, max1= ALOG10(20), max2= 2, MAG=16,$
    XRANGE=[0.1,20],YRANGE=[.01,100],$
    XTITLE=UNITS('OC4O'),YTITLE=UNITS('CHLOR_A',/NAME),PS=1,/REG_NONE,/ONE_NONE,$
    FILE=PSFILE ,AXES=[1,0,1,0],FRAME=6,XTHICK=4,YTHICK=4,XCHARSIZE=1.5,YCHARSIZE=1.5,$
    CURVE_X=RRS_RATIO,CURVE_Y=MODEL_OC4O_4,CURVE_THICK=[7,2],$
    LABEL_TXT='N='+NUM2STR(N_ELEMENTS(DS.CHLA)),LABEL_POS=[0.8,0.8]
STOP
; **********************************
; *** RMA vs OC2 v4
; **********************************
  LABEL='RMA_VS_OC2'
         RMA_VS_OC2:
  !P.MULTI=[0,1,2]

  !P.MULTI=0
  !X.CHARSIZE=1.25
  !Y.CHARSIZE=1.25
  !P.CHARSIZE=1.25
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[2,2]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  PLOTXY,(ds.r490/ds.r555_565b),(ds.chla),/LOGLOG,psym=1,params=[1,2,3,4,8],reg_linestyle=31,xtitle='Rrs490/Rrs555',ytitle='Chl a '+ UNITS('CHLM3'),/mean_none,TYPE=['4'],stats_charsize=1.25,stats_pos=[.75,.934],decimals=3
  OPLOT, RRS_RATIO,MODEL_OC2_4,COLOR=21,thick=3
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP


  hist2d_plot, alog10(ds.r490/ds.r555_565b),alog10(ds.chla) ,bin1=0.05,bin2=0.05, min1= -2, min2= -2, max1= 2, max2= 2, MAG=8,XRANGE=[-1,ALOG10(20)]

pal_sw3
stop

  PLOTXY,(ds.r490/ds.r555_565b),(ds.chla),/LOGLOG,psym=1,params=[1,2,3,4,8],reg_linestyle=31,xtitle='Rrs490/Rrs555',ytitle='Chl a '+ UNITS('CHLM3'),/mean_none,TYPE=['4','0'],stats_charsize=1.25,stats_pos=[.75,.934],decimals=3

STOP


; ***************************************************************************************************
  OC3M_CLARK_CHL_MODIS_vs_insitu:
; ***************************************************************************************************
  LABEL='OC3M_CLARK_CHL_MODIS_vs_insitu'
  !P.MULTI=0
  !X.CHARSIZE=1.25
  !Y.CHARSIZE=1.25
  !P.CHARSIZE=1.25
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[2,2]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'_1.PS'

  PLOTXY, OC3M_4,Clark_chl_MODIS,PSYM=1,/LOGLOG,DECIMALS=3,$
  				Title='Clark_chl_MODIS versus OC3M v4',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='OC3M v4 Chl'+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,YTITLE='Clark_chl_MODIS Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(OC3M_4,Clark_chl_MODIS,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1

  CAPTION," J.O'Reilly (NOAA)"

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

;
 IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'_2.PS'
   Clark_CHL_MODIS=A_CLARK_CHL_MODIS(DS.R443,DS.R550_I550)
   PLOT, DS.R443/DS.R550_I550, DS.CHLA, /XLOG,/YLOG,$
  				Title='Clark_chl_MODIS',/ISOTROPIC,$
          xticks=BR_ticks,xtickv=BR_tickv,xtickname=BR_tickname,xrange=BR_range,/xstyle,Xtitle='(R!S!U443!R!D550!N)',$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,YTITLE='Clark_chl_MODIS Chl '+UNITS('CHLM3') ,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize

  CAPTION," J.O'Reilly (NOAA)"

  OPLOT, DS.R443/DS.R550_I550, Clark_CHL_MODIS,COLOR=21,thick=3,psym=3

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; ***************************************************************************************************
  OC4_OC4O_OCTSC_vs_insitu:
; ***************************************************************************************************
  LABEL='OC4_OC4O_OCTSC_vs_insitu'
  !P.MULTI=[0,2,3]
  !X.CHARSIZE=1.5
  !Y.CHARSIZE=1.5
  !P.CHARSIZE=1.5
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[2,2]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'

  PLOTXY, CHLA,OC4_4,PSYM=1,/LOGLOG,DECIMALS=3,$
  				Title='OC4 v4 versus in situ chlorophyll',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='in situ Chl '+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,yTITLE='OC4 v4 Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(CHLA,OC4_4,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1

  PLOTXY, CHLA,OC4O_4,PSYM=1,/LOGLOG,DECIMALS=3,$
  			  Title='OC4O v4 versus in situ chlorophyll',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='in situ Chl '+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,YTITLE='OC4O v4 Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(CHLA,OC4O_4,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1


  PLOTXY, CHLA,OCTS_C,PSYM=1,/LOGLOG,DECIMALS=3,$
  				Title='OCTS_C versus in situ chlorophyll',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='in situ Chl'+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,YTITLE='OCTS_C Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(CHLA,OCTS_C,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1

  PLOTXY, OC4O_4,OCTS_C,PSYM=1,/LOGLOG,DECIMALS=3,$
  				Title='OCTS_C versus OC4O v4',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,Xtitle='OC4O v4 Chl'+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,YTITLE='OCTS_C Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(OC4O_4,OCTS_C,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1
  CAPTION," J.O'Reilly (NOAA)"
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

; ***************************************************************************************************
  OC4_OC4O_OCTSC_vs_insitu_b:
; ***************************************************************************************************
  LABEL='OC4_OC4O_OCTSC_vs_insitu_b'
  !P.MULTI=[0,2,3]
  !X.CHARSIZE=1.5
  !Y.CHARSIZE=1.5
  !P.CHARSIZE=1.5
  !Y.MARGIN= [4,4]
  !X.OMARGIN=[2,2]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'

    PLOTXY, OCTS_C,OC4O_4,PSYM=1,/LOGLOG,DECIMALS=3,$
  				Title='OCTS_C versus OC4O v4',/ISOTROPIC,$
          PARAMS=[0,2,3,4,8,10,11],$
          xticks=chl_ticks,xtickv=chl_tickv,xtickname=chl_tickname,ytitle='OC4O v4 Chl'+UNITS('CHLM3'),$
          yticks=chl_ticks,ytickv=chl_tickv,ytickname=chl_tickname,xTITLE='OCTS_C Chl '+UNITS('CHLM3'), $
          xrange=chl_range,/xstyle,yrange=chl_range,/ystyle,$
          psym=chl_psym,symsize=chl_symsize,$
          REG_LINESYTLE=31, /mean_none,/reg_none,$
          /one2one,one_color=8,one_thick=5
          ONE2ONE,COLOR=255
  q=quantile(OCTS_C,OC4O_4,/quiet) & OPLOT, Q.X,Q.Y,COLOR=21,thick=5 & OPLOT, Q.X,Q.Y,COLOR=255,thick=1
  CAPTION," J.O'Reilly (NOAA)"
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

hist2d_plot, alog10(ds.r490/ds.r555_565b),alog10(ds.chla) ,bin1=0.03,bin2=0.05, min1= ALOG10(.1), min2= -2, max1= ALOG10(20),$
 max2= 2, MAG=8,/PS,/STATS_NONE,/REG_NONE,ONE_NONE=1,TOP_COLOR=250,X_X = ALOG10(RRS_RATIO), Y_Y=ALOG10(MODEL_OC2_4),xxyy_thick=3,xxyy_linestyle=71,xxyy_color=[250,0],/grids,background=254


hist2d_plot, alog10(ds.r490/ds.r555_565b),alog10(ds.chla) ,bin1=0.03,bin2=0.05, min1= ALOG10(.1), min2= -2, max1= ALOG10(20), max2= 2, MAG=8,/PS,/STATS_NONE,/REG_NONE,ONE_NONE=1,TOP_COLOR=250

; ***************************************************************************************************
  OC4O_v4_MB_vs_CHL:
; ***************************************************************************************************
  LABEL='OC4O_v4_MB_vs_CHL'
  !P.MULTI=[0]
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARSIZE=1.0
  !Y.MARGIN= [4,4]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2

  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/HALF,FILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
   XX =  ((DS.R443> DS.R490> DS.R520_I520)/DS.R565_I565)
   YY =   CHLA
   A = ds.R443 & B = ds.R490 & C= ds.R520_I520 & D = ds.R565_I565
   OKA = WHERE(A Gt B AND A GT C,COUNTA)
   OKB = WHERE(B GE A AND B GT C,COUNTB)
   OKC = WHERE(C GE A AND C GE B,COUNTC)
   TX =  EQ_WRITE('OC4OBR')
  yrange=[.001, 100.]
  COLORS =[4,10,13]
  n_set = 'N= '+STRTRIM(STRING(N_ELEMENTS(XX)),2)
  n_set  = ''
  Title = 'OC4O v4 Maximum Band versus Band Ratio'

  RF_LOG,XX(oka),label='443/555!C', THICK=0,LINESTYLE=1,color=0 ,min=0.03,max=20.0,xrange=[0.3,20],xstyle=1,YRANGE=[0,1],YTICKS=10,/YSTYLE, $
         TITLE=TITLE,XTITLE= tx,LTITLE=N_SET ,$
         LSIZE=1 ,LPOS=[.60,.37,.65,.44],TSIZE=!P.charsize, yMARGIN=[4,2], CHARSIZE=!P.charsize ,binsize=.10, title=title

  grids,[.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],[0.0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1],color=35,THICK=2,linestyle=0, frame=3,/all

  RF_LOG,XX(oka),OVERPLOT=0,label='443/565!C', THICK=7,LINESTYLE=1,color=COLORS[0] ,min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
           LSIZE= 1 ,LPOS=[.60,.37,.65,.44],TSIZE=!P.charsize,                            binsize=.10

  RF_LOG,XX(okb),OVERPLOT=2,label='490/565!C', THICK=7,LINESTYLE=0,color=COLORS[1],min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
          LSIZE=1 ,LPOS=[.60,.37,.65,.44]                  ,binsize=.10

  RF_LOG,XX(okc),OVERPLOT=4,label='520/565!C', THICK=7,LINESTYLE=2,color=COLORS(2),min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
          LSIZE=1 ,LPOS=[.60,.37,.65,.44]                 ,binsize=.10

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; ***************************************************************************************************
  OC4_v4_MBR_vs_CHL_001:
; ***************************************************************************************************
  LABEL='OC4_v4_MBR_vs_CHL_001'
  !P.MULTI=[0,2,2]
  !Y.OMARGIN=[20,5]
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARSIZE=1.0
  !Y.MARGIN= [4,4]
  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  symsize=0.5
  XRANGE=[0.3,25]

  PAL_36,R,G,B
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE=DIR_OUT+ROUTINE_NAME+'_'+label+'.PS'

  XX =  ((DS.R443> DS.R490> DS.R510_I510)/DS.R555_565B)
  YY =   CHLA
  A = ds.R443 & B = ds.R490 & C= ds.R510_I510 & D = ds.R555_565B
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  TX =  EQ_WRITE('OC4BR')
  yrange=[.001, 100.]
  COLORS =[4,10,13]
  TITLE_PAGE = 'OC4 v4!C!DIn Situ Maximum Band Ratio versus Chlorophyll a!N'
  TITLE = ''
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')

  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL

  circle,fill=1,color=GREY
  OPLOT, XX,YY,PSYM=8,thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  XYOUTS, XRANGE[1] ,36,'!C!D(n= ' + NUM2STR(COUNTA+COUNTB+COUNTC) + ')!N',charsize=1.25,ALIGN=1.05

; ============>
; Color each
  A = SB.R443 & B = SB.R490 & C= SB.R510_I510
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)


 ; ===========================>
 ; PLOT 510/555
   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA

  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL

  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize

  circle,fill=1,color=COLORS(2)
  OPLOT, XX(OKC),YY(OKC),PSYM=8,THICK=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS510_555')+'!C!D(n= ' + NUM2STR(COUNTC) + ')!N',charsize=1.25,ALIGN=1.05



; ========================>
; Plot 490/555

   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA

  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0, THICK=2, frame=3,/ALL

  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize

  circle,fill=1,color=COLORS[1]

  ;OPLOT, RATIO_OC4,OC4,COLOR=255,thick=1
  OPLOT, XX(OKB),YY(OKB),PSYM=8,COLOR=COLORS[1],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS490_555')+'!C!D(n= ' + NUM2STR(COUNTB) + ')!N',charsize=1.25,ALIGN=1.05


; ========================>
; Plot 443/555

  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
         color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA

  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL


  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize

  circle,fill=1,color=COLORS[0]
  OPLOT, XX(OKA),YY(OKA),PSYM=8,COLOR=COLORS[0],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3



  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS443_555')+'!C!D(n= ' + NUM2STR(COUNTA) + ')!N',charsize=1.25,ALIGN=1.05

  CW_X=CLEAR_WATER_BAND_RATIO([443,555],QUIET=quiet)
  ok = value_locate(RRS_RATIO ,cw_X)
  cw_Y = MODEL_OC4_4(ok)
  PLOTS, CW_X,CW_Y, PSYM=1, COLOR=1,SYMSIZE=2,THICK=3
  XYOUTS,CW_X,CW_Y,'Theoretical Clear Water '+EQ_WRITE('RRS443_555')+' ('+ NUM2STR(STRING(CW_X,FORMAT='(F6.2)'))+')', align=1.06,charsize=0.76


  xyouts,0.5,0.97,/normal,TITLE_PAGE,charsize=2,align=0.5

  !Y.OMARGIN=[2,2]

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP


; ***************************************************************************************************
  OC4_v4_MBR_vs_CHL_01:
; ***************************************************************************************************
  LABEL='OC4_v4_MBR_vs_CHL_01'
  !P.MULTI=[0,2,2]
  !Y.OMARGIN=[20,5]
  !X.charsize=1.5
  !Y.charsize=1.5
  !P.charsize=1.5
  !Y.MARGIN= [4,4]
  !X.THICK = 3
  !Y.THICK = 3
  !P.CHARTHICK=3
  symsize=0.5
  XRANGE=[0.3,25]
  chl_TICKNAME=['0.01','0.1','1','10','100']
  chl_TICKV    = [0.01,0.1,1,10,100]
  chl_ticks   = N_ELEMENTS(chl_TICKV)-1
  chl_range=[0.01,100]
  BR_TICKNAME=['0.1','1','10']
  BR_TICKV    = [0.1,1.0,10.0]
  BR_tick   = N_ELEMENTS(BR_TICKV)-1
  BR_range=[0.1,20]

  PAL_36,R,G,B
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE=DIR_OUT+ROUTINE_NAME+'_'+label+'.PS'
  XX =  ((DS.R443> DS.R490> DS.R510_I510)/DS.R555_565B)
  YY =   CHLA
  A = ds.R443 & B = ds.R490 & C= ds.R510_I510 & D = ds.R555_565B
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  TX =  EQ_WRITE('OC4BR')
  COLORS =[4,10,13]
  TITLE_PAGE = 'OC4 v4!C!DIn Situ Maximum Band Ratio versus Chlorophyll a!N'
  TITLE = ''
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')
  PLOT,/xlog,/ylog, xx,yy,$
  			 XRANGE=BR_RANGE,XTICKS=BR_TICK,XTICKNAME=BR_TICKNAME,XTICKV=BR_TICKV,/XSTYLE,$
  			 YRANGE=CHL_RANGE,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,/YSTYLE,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
        color=0,yMARGIN=[4,2], charsize=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
        [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,color=GREY
  OPLOT, XX,YY,PSYM=8,thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  XYOUTS, BR_RANGE[1] ,20,'!C!D(n= ' + NUM2STR(COUNTA+COUNTB+COUNTC) + ')!N',charsize=2.5,ALIGN=1.05
; ============>
; Color each
  A = SB.R443 & B = SB.R490 & C= SB.R510_I510
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
 ; ===========================>
 ; PLOT 510/555
   PLOT,/xlog,/ylog, xx,yy,$
  			 XRANGE=BR_RANGE,XTICKS=BR_TICK,XTICKNAME=BR_TICKNAME,XTICKV=BR_TICKV,/XSTYLE,$
  			 YRANGE=CHL_RANGE,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,/YSTYLE,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
        color=0,yMARGIN=[4,2], charsize=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS(2)
  OPLOT, XX(OKC),YY(OKC),PSYM=8,THICK=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  plots,  1.5,50, psym=8,THICK=2,symsize=symsize
  N_TXT= '!C!D(n= ' + NUM2STR(COUNTC) + ')!N'
  XYOUTS, BR_RANGE[1] ,20,EQ_WRITE('RRS510_555'),charsize=2.5,ALIGN=1.05
; ========================>
; Plot 490/555
    PLOT,/xlog,/ylog, xx,yy,$
  			 XRANGE=BR_RANGE,XTICKS=BR_TICK,XTICKNAME=BR_TICKNAME,XTICKV=BR_TICKV,/XSTYLE,$
  			 YRANGE=CHL_RANGE,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,/YSTYLE,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
        color=0,yMARGIN=[4,2], charsize=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0, THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[1]
  ;OPLOT, RATIO_OC4,OC4,COLOR=255,thick=1
  OPLOT, XX(OKB),YY(OKB),PSYM=8,COLOR=COLORS[1],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  plots,  1.5,50, psym=8,THICK=2,symsize=symsize
  N_TXT='!C!D(n= ' + NUM2STR(COUNTB) + ')!N'
  XYOUTS, BR_RANGE[1] ,20,EQ_WRITE('RRS490_555'),charsize=2.5,ALIGN=1.05
; ========================>
; Plot 443/555
  PLOT,/xlog,/ylog, xx,yy,$
  			 XRANGE=BR_RANGE,XTICKS=BR_TICK,XTICKNAME=BR_TICKNAME,XTICKV=BR_TICKV,/XSTYLE,$
  			 YRANGE=CHL_RANGE,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,/YSTYLE,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
        color=0,yMARGIN=[4,2], charsize=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[0]
  OPLOT, XX(OKA),YY(OKA),PSYM=8,COLOR=COLORS[0],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4_4,COLOR=0,thick=3
  plots,  1.5,50, psym=8,THICK=2,symsize=symsize
  N_TXT='!C!D(n= ' + NUM2STR(COUNTA) + ')!N'
  XYOUTS, BR_RANGE[1] ,20,EQ_WRITE('RRS443_555'),charsize=2.5,ALIGN=1.05
  CW_X=CLEAR_WATER_BAND_RATIO([443,555],QUIET=quiet)
  ok = value_locate(RRS_RATIO ,cw_X)
  cw_Y = MODEL_OC4_4(ok)
;  PLOTS, CW_X,CW_Y, PSYM=1, COLOR=1,SYMSIZE=2,THICK=3
;  XYOUTS,CW_X,CW_Y,'Theoretical Clear Water '+EQ_WRITE('RRS443_555')+' ('+ NUM2STR(STRING(CW_X,FORMAT='(F6.2)'))+')', align=1.06,charsize=0.76
  xyouts,0.5,0.97,/normal,TITLE_PAGE,charsize=2,align=0.5
  !Y.OMARGIN=[2,2]
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; ***************************************************************************************************
  OC4O_v4_MBR_vs_CHL:
; ***************************************************************************************************
  LABEL='OC4O_v4_MBR_vs_CHL'
  !P.MULTI=[0,2,2]
  !Y.OMARGIN=[20,5]
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARSIZE=1.0
  !Y.MARGIN= [4,4]
  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  symsize=0.5
  XRANGE=[0.3,25]
  PAL_36,R,G,B
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE=DIR_OUT+ROUTINE_NAME+'_'+label+'.PS'
  XX =  ((DS.R443> DS.R490> DS.R520_I520)/DS.R565_I565)
  YY =   CHLA
  A = ds.R443 & B = ds.R490 & C= ds.R520_I520 & D = ds.R565_I565
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  TX =  EQ_WRITE('OC4OBR')
  yrange=[.001, 100.]
  COLORS =[4,10,13]
  TITLE_PAGE = 'OC4O v4!C!DIn Situ Maximum Band Ratio versus Chlorophyll a!N'
  TITLE = ''
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')
  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,color=GREY
  OPLOT, XX,YY,PSYM=8,thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4O_4,COLOR=0,thick=3
  XYOUTS, XRANGE[1] ,36,'!C!D(n= ' + NUM2STR(COUNTA+COUNTB+COUNTC) + ')!N',charsize=1.25,ALIGN=1.05
; ============>
; Color each
  A = SB.R443 & B = SB.R490 & C= SB.R520_I520
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
 ; ===========================>
 ; PLOT 520/555
   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS(2)
  OPLOT, XX(OKC),YY(OKC),PSYM=8,THICK=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4O_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS520_565')+'!C!D(n= ' + NUM2STR(COUNTC) + ')!N',charsize=1.25,ALIGN=1.05
; ========================>
; Plot 490/555
   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0, THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[1]
  ;OPLOT, RATIO_OC4,OC4,COLOR=255,thick=1
  OPLOT, XX(OKB),YY(OKB),PSYM=8,COLOR=COLORS[1],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4O_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS490_565')+'!C!D(n= ' + NUM2STR(COUNTB) + ')!N',charsize=1.25,ALIGN=1.05
; ========================>
; Plot 443/555
  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
         color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA

  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[0]
  OPLOT, XX(OKA),YY(OKA),PSYM=8,COLOR=COLORS[0],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4O_4,COLOR=0,thick=3
 plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS443_565')+'!C!D(n= ' + NUM2STR(COUNTA) + ')!N',charsize=1.25,ALIGN=1.05

  CW_X=CLEAR_WATER_BAND_RATIO([443,565],QUIET=quiet)
  ok = value_locate(RRS_RATIO ,cw_X)
  cw_Y = MODEL_oc4O_4(ok)
  PLOTS, CW_X,CW_Y, PSYM=1, COLOR=1,SYMSIZE=2,THICK=3
  XYOUTS,CW_X,CW_Y,'Theoretical Clear Water '+EQ_WRITE('RRS443_565')+' ('+ NUM2STR(STRING(CW_X,FORMAT='(F6.2)'))+')', align=1.06,charsize=0.8
  xyouts,0.5,0.97,/normal,TITLE_PAGE,charsize=2,align=0.5
  !Y.OMARGIN=[2,2]
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP







; ******************************************************************************
  OC4O_v4_REL_FREQ_MB_vs_CHL: LABEL='OC4O_v4_REL_FREQ_MB_vs_CHL'
; ******************************************************************************
  TITLE='OC4O v4!CRelative Frequency of Maximum Band Ratio versus Chl!Da!N'
  SET_PMULTI
  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_OUT+ROUTINE_NAME+'_'+label+'.PS'
  PAL_36
  !X.THICK=2
  !Y.THICK=2
  BINSIZE=0.3
  LABEL=[EQ_WRITE('RRS443_565'),EQ_WRITE('RRS490_565'),EQ_WRITE('RRS520_565')]
  POS=[.76,.56,.81,.76]
  ;COLOR = [0,0,0]
  COLOR=COLORS
  LINESTYLE=[1,0,2]
  thick = [7,7,7]
  psymsize = [1,1,1]
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')
  chl_TICKNAME=['0.01','0.1','1','10','100']
  chl_TICKV    = [0.01,0.1,1,10,100]
  chl_tickS   = N_ELEMENTS(chl_TICKV)-1
  chl_range=[0.01,100]
  XX =  ((DS.R443> DS.R490> DS.R520_I520)/DS.R565_I565)
  YY =   CHLA
  A = ds.R443 & B = ds.R490 & C= ds.R520_I520 & D = ds.R565_I565
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  HISTPLOT, ALOG10(YY(OKA)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTA,YHISTA,/QUIET
  HISTPLOT, ALOG10(YY(OKB)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTB,YHISTB,/QUIET
  HISTPLOT, ALOG10(YY(OKC)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTC,YHISTC,/QUIET

  ARRAY = [[YHISTA],[YHISTB],[YHISTC]]
  YHIST_TOT = TOTAL(ARRAY,2)

  _YHISTA = 100.0*FLOAT(YHISTA)/YHIST_TOT
  _YHISTB = 100.0*FLOAT(YHISTB)/YHIST_TOT
  _YHISTC = 100.0*FLOAT(YHISTC)/YHIST_TOT

XTICK_GET = [0.01,0.1,1.0,10.0,100]
XTICK_GET = [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100]
YTICK_GET = FINDGEN(11)*10.0
PLOT,  10.0^XHISTA, _YHISTA, YRANGE=[0, 100],/XLOG, XRANGE=[0.01,100],$
      XTICKS=CHL_TICKS,XTICKNAME=CHL_TICKNAME,XTICKV=CHL_TICKV,YMINOR=1,$
      XTITLE=TITLE_CHL,YTITLE='Relative Frequency (%)',$
      TITLE=TITLE

GRIDS,COLOR=grey,THICK=6,XTICK_GET,YTICK_GET,FRAME=4

OK = WHERE(YHISTA NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTA[OK], THICK=THICK[0],COLOR=COLOR[0],LINESTYLE=LINESTYLE[0]
OK = WHERE(YHISTB NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTB[OK], THICK=THICK[1],COLOR=COLOR[1],LINESTYLE=LINESTYLE[1]
OK = WHERE(YHISTC NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTC[OK], THICK=THICK(2),COLOR=COLOR(2),LINESTYLE=LINESTYLE(2)

LEG,POS=POS,linestyle=linestyle,label=LABEL,LSIZE=1.25,color=COLOR,thick=thick
;  LEG,POS=POS,linestyle=linestyle,            LSIZE=.7,color=color,thick=thick


 IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP












; ***************************************************************************************************
  OC4G_v4_MB_vs_CHL:
; ***************************************************************************************************
  LABEL='OC4G_v4_MB_vs_CHL'
  !P.MULTI=[0]
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARSIZE=1.0
  !Y.MARGIN= [4,4]

  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2

  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/HALF,FILE=DIR_PLOTS +label+'.PS'
   XX =  ((DS.R443> DS.R485_I485> DS.R520_I520)/DS.R570_I570)
   YY =   CHLA
   A = ds.R443 & B = ds.R485_I485 & C= ds.R520_I520 & D = ds.R570_I570
   OKA = WHERE(A Gt B AND A GT C,COUNTA)
   OKB = WHERE(B GE A AND B GT C,COUNTB)
   OKC = WHERE(C GE A AND C GE B,COUNTC)
   TX =  EQ_WRITE('OC4GBR')
  yrange=[.001, 100.]
  COLORS =[4,10,13]
  n_set = 'N= '+STRTRIM(STRING(N_ELEMENTS(XX)),2)
  n_set  = ''
  Title = 'OC4G v4 Maximum Band versus Band Ratio'

  RF_LOG,XX(oka),label='443/570!C', THICK=0,LINESTYLE=1,color=0 ,min=0.03,max=20.0,xrange=[0.3,20],xstyle=1,YRANGE=[0,1],YTICKS=10,/YSTYLE, $
         TITLE=TITLE,XTITLE= tx,LTITLE=N_SET ,$
         LSIZE=1 ,LPOS=[.60,.37,.65,.44],TSIZE=!P.charsize, yMARGIN=[4,2], CHARSIZE=!P.charsize ,binsize=.10, title=title

  grids,[.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],[0.0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1],color=35,THICK=2,linestyle=0, frame=3,/all

  RF_LOG,XX(oka),OVERPLOT=0,label='443/570!C', THICK=7,LINESTYLE=1,color=COLORS[0] ,min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
           LSIZE= 1 ,LPOS=[.60,.37,.65,.44],TSIZE=!P.charsize,                            binsize=.10

  RF_LOG,XX(okb),OVERPLOT=2,label='485/570!C', THICK=7,LINESTYLE=0,color=COLORS[1],min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
          LSIZE=1 ,LPOS=[.60,.37,.65,.44]                  ,binsize=.10

  RF_LOG,XX(okc),OVERPLOT=4,label='520/570!C', THICK=7,LINESTYLE=2,color=COLORS(2),min=0.03,max=20.0,xrange=[0.3,13],xstyle=1,$
          LSIZE=1 ,LPOS=[.60,.37,.65,.44]                 ,binsize=.10

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; ***************************************************************************************************


STOP



STOP

; ***************************************************************************************************
  OC4G_v4_MBR_vs_CHL:
; ***************************************************************************************************
  LABEL='OC4G_v4_MBR_vs_CHL'
  !P.MULTI=[0,2,2]
  !Y.OMARGIN=[15,8]
  !x.OMARGIN=[2,2]
  !X.CHARSIZE=1.0
  !Y.CHARSIZE=1.0
  !P.CHARSIZE=1.0
  !Y.MARGIN= [3,3]
  !X.THICK = 2
  !Y.THICK = 2
  !P.CHARTHICK=2
  FONT_TIMES

  symsize=0.5
  XRANGE=[0.3,25]
  PAL_36,R,G,B
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/FULL,FILE=DIR_PLOTS +label+'.PS'
  XX =  ((DS.R443> DS.R485_I485> DS.R520_I520)/DS.R570_I570)
  YY =   CHLA
  A = ds.R443 & B = DS.R485_I485 & C= ds.R520_I520 & D = DS.R570_I570
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  TX =  EQ_WRITE('OC4GBR')
  yrange=[.001, 100.]
  COLORS =[4,10,13]
  TITLE_PAGE = 'OC4G v4!C!DIn Situ Maximum Band Ratio versus Chlorophyll a!N'
  TITLE = ''
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')
  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,color=GREY
  OPLOT, XX,YY,PSYM=8,thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4G_4,COLOR=0,thick=3
  XYOUTS, XRANGE[1] ,36,'!C!D(n= ' + NUM2STR(COUNTA+COUNTB+COUNTC) + ')!N',charsize=1.25,ALIGN=1.05
; ============>
; Color each
  A = SB.R443 & B = SB.R485_I485 & C= SB.R520_I520
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
 ; ===========================>
 ; PLOT 520/570
   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS(2)
  OPLOT, XX(OKC),YY(OKC),PSYM=8,THICK=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4G_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS520_570')+'!C!D(n= ' + NUM2STR(COUNTC) + ')!N',charsize=1.25,ALIGN=1.05
; ========================>
; Plot 485/570
   PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
        color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA
  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0, THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[1]
  ;OPLOT, RATIO_OC4,OC4,COLOR=255,thick=1
  OPLOT, XX(OKB),YY(OKB),PSYM=8,COLOR=COLORS[1],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4G_4,COLOR=0,thick=3
  plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS485_570')+'!C!D(n= ' + NUM2STR(COUNTB) + ')!N',charsize=1.25,ALIGN=1.05
; ========================>
; Plot 443/570
  PLOT,/xlog,/ylog, xx,yy,YTICKS=CHL_TICK,YTICKNAME=CHL_TICKNAME,YTICKV=CHL_TICKV,$
         TITLE=TITLE,Xtitle=TX   ,YTITLE=TITLE_CHL , $
         XRANGE=[0.3,25],YRANGE=[0.001,100],/XSTYLE,/YSTYLE,$
         color=0,yMARGIN=[4,2], CHARSIZE=1.00,PSYM=1,SYMSIZE=symsize,/NODATA

  grids,[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20],$
       [.001,.002,.003,.004,.005,.006,.007,.008,.009,.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100],color=35,linestyle=0,THICK=2, frame=3,/ALL
  circle,fill=1,COLOR=GREY
  OPLOT, XX,YY,PSYM=8,COLOR=GREY,thick=2,symsize=symsize
  circle,fill=1,color=COLORS[0]
  OPLOT, XX(OKA),YY(OKA),PSYM=8,COLOR=COLORS[0],thick=2,symsize=symsize
  OPLOT, RRS_RATIO,MODEL_OC4G_4,COLOR=0,thick=3
 plots,  9,50, psym=8,THICK=2,symsize=symsize
  XYOUTS, XRANGE[1] ,36,EQ_WRITE('RRS443_570')+'!C!D(n= ' + NUM2STR(COUNTA) + ')!N',charsize=1.25,ALIGN=1.05

  CW_X=CLEAR_WATER_BAND_RATIO([443,570],QUIET=quiet)
  ok = value_locate(RRS_RATIO ,cw_X)
  cw_Y = MODEL_OC4G_4(ok)
  PLOTS, CW_X,CW_Y, PSYM=1, COLOR=1,SYMSIZE=2,THICK=3
  XYOUTS,CW_X,CW_Y,'Theoretical Clear Water '+EQ_WRITE('RRS443_570')+' ('+ NUM2STR(STRING(CW_X,FORMAT='(F6.2)'))+')', align=1.06,charsize=0.8
  xyouts,0.5,0.94,/normal,TITLE_PAGE,charsize=2,align=0.5
  !Y.OMARGIN=[2,2]
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; ******************************************************************************
  OC4G_v4_REL_FREQ_MB_vs_CHL: LABEL='OC4G_v4_REL_FREQ_MB_vs_CHL'
; ******************************************************************************
  TITLE='OC4G v4!CRelative Frequency of Maximum Band Ratio versus Chl!Da!N'
  SET_PMULTI
  IF KEYWORD_SET(PS) THEN PSPRINT,/HALF,/COLOR,FILE=DIR_PLOTS +label+'.PS'
  PAL_36
  !X.THICK=2
  !Y.THICK=2
  BINSIZE=0.3
  LABEL=[EQ_WRITE('RRS443_570'),EQ_WRITE('RRS485_570'),EQ_WRITE('RRS520_570')]
  POS=[.76,.56,.81,.76]
  ;COLOR = [0,0,0]
  COLOR=COLORS
  LINESTYLE=[1,0,2]
  thick = [7,7,7]
  psymsize = [1,1,1]
  TITLE_CHL =  'Chl!Da!N' + UNITS('CHLM3')
  chl_TICKNAME=['0.01','0.1','1','10','100']
  chl_TICKV    = [0.01,0.1,1,10,100]
  chl_tickS   = N_ELEMENTS(chl_TICKV)-1
  chl_range=[0.01,100]
  XX =  ((DS.R443> DS.R485_I485> DS.R520_I520)/DS.R570_I570)
  YY =   CHLA
  A = ds.R443 & B = DS.R485_I485 & C= ds.R520_I520 & D = ds.R570_I570
  OKA = WHERE(A Gt B AND A GT C,COUNTA)
  OKB = WHERE(B GE A AND B GT C,COUNTB)
  OKC = WHERE(C GE A AND C GE B,COUNTC)
  HISTPLOT, ALOG10(YY(OKA)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTA,YHISTA,/QUIET
  HISTPLOT, ALOG10(YY(OKB)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTB,YHISTB,/QUIET
  HISTPLOT, ALOG10(YY(OKC)), binsize=BINSIZE,MIN= -2., MAX = 2.,XHISTC,YHISTC,/QUIET

  ARRAY = [[YHISTA],[YHISTB],[YHISTC]]
  YHIST_TOT = TOTAL(ARRAY,2)

  _YHISTA = 100.0*FLOAT(YHISTA)/YHIST_TOT
  _YHISTB = 100.0*FLOAT(YHISTB)/YHIST_TOT
  _YHISTC = 100.0*FLOAT(YHISTC)/YHIST_TOT

XTICK_GET = [0.01,0.1,1.0,10.0,100]
XTICK_GET = [.01,.02,.03,.04,.05,.06,.07,.08,.09,.1,.2,.3,.4,.5,.6,$
       .7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100]
YTICK_GET = FINDGEN(11)*10.0
PLOT,  10.0^XHISTA, _YHISTA, YRANGE=[0, 100],/XLOG, XRANGE=[0.01,100],$
      XTICKS=CHL_TICKS,XTICKNAME=CHL_TICKNAME,XTICKV=CHL_TICKV,YMINOR=1,$
      XTITLE=TITLE_CHL,YTITLE='Relative Frequency (%)',$
      TITLE=TITLE

GRIDS,COLOR=grey,THICK=6,XTICK_GET,YTICK_GET,FRAME=4

OK = WHERE(YHISTA NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTA[OK], THICK=THICK[0],COLOR=COLOR[0],LINESTYLE=LINESTYLE[0]
OK = WHERE(YHISTB NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTB[OK], THICK=THICK[1],COLOR=COLOR[1],LINESTYLE=LINESTYLE[1]
OK = WHERE(YHISTC NE 0,COUNT)
OPLOT, 10.0^XHISTA[OK], _YHISTC[OK], THICK=THICK(2),COLOR=COLOR(2),LINESTYLE=LINESTYLE(2)

LEG,POS=POS,linestyle=linestyle,label=LABEL,LSIZE=1.25,color=COLOR,thick=thick
;  LEG,POS=POS,linestyle=linestyle,            LSIZE=.7,color=color,thick=thick


 IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP





















STOP
; ***************************************************************


; *********************
  OC4_v4_versus_OCTS_C:
  LABEL='OC4_v4_versus_OCTS_C'

; *******************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/half,file=DIR_PLOTS +label+'.PS'

  PLOTXY, OC4_4,OCTS_C,PSYM=1,/LOGLOG,DECIMALS=3,$
          PARAMS=[0,2,3,4,8,10,11], YTITLE='OCTS_C '+UNITS('CHLM3'), $
          Xtitle='OC4 v4 '+UNITS('CHLM3'), xrange=[0.001,100],/xstyle,yrange=[0.001,100],/ystyle,$
          REG_LINESYTLE=31, /mean_none
  ONE2ONE,COLOR=255

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP



; *********************
  OC4G_v4_versus_OCTS_C:
  LABEL='OC4G_v4_versus_OCTS_C'

; *******************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/half,FILE=DIR_PLOTS +label+'.PS'

  PLOTXY, OC4G_4,OCTS_C,PSYM=1,/LOGLOG,DECIMALS=3,$
          PARAMS=[0,2,3,4,8,10,11], YTITLE='OCTS_C '+UNITS('CHLM3'), $
          Xtitle='OC4G v4 '+UNITS('CHLM3'), xrange=[0.001,100],/xstyle,yrange=[0.001,100],/ystyle,$
          REG_LINESYTLE=31, /mean_none
  ONE2ONE,COLOR=255

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

STOP

; *******************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/half,FILE=DIR_PLOTS +label+'.PS'

  PLOTXY, OC4_4,OC4G_4B,PSYM=1,/LOGLOG,DECIMALS=3,$
          PARAMS=[0,2,3,4,8,10,11], YTITLE='OC4G v4b '+UNITS('CHLM3'), $
          Xtitle='OC4 v4 '+UNITS('CHLM3'), xrange=[0.01,100],/xstyle,yrange=[0.01,100],/ystyle,$
          REG_LINESYTLE=31, /mean_none
  ONE2ONE,COLOR=255

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP


  OC4_VS_OC4G: LABEL='OC4_VS_OC4G'
; *******************************************************************
  IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/half,FILE=DIR_PLOTS +label+'.PS'

  PLOTXY, OC4_4,OC4G_4B,PSYM=1,/LOGLOG,DECIMALS=3,$
          PARAMS=[0,2,3,4,8,10,11], YTITLE='OC4G v4b '+UNITS('CHLM3'), $
          Xtitle='OC4 v4 '+UNITS('CHLM3'), xrange=[0.01,100],/xstyle,yrange=[0.01,100],/ystyle,$
          REG_LINESYTLE=31, /mean_none
  ONE2ONE,COLOR=255

  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP






; *******************************************************************
 LABEL = 'OC4G_RATIO'
 IF KEYWORD_SET(PS) THEN PSPRINT,/COLOR,/half,FILE=DIR_PLOTS +label+'.PS'
    xtickv=findgen(10)*.1 + .1
    xtickv = [xtickv,xtickv*10]
    ok = where(xtickv ge 0.3)
    xtickv = xtickv(ok)
    Ytickv=findgen(10)*.001 + .001
    Ytickv = [Ytickv,Ytickv*10,Ytickv*100,Ytickv*1000,Ytickv*10000]
    xtickname=NUM2STR(XTICKV)
    ytickname=NUM2STR(YTickv)
    xticks=n_elements(xtickv)
    yticks=n_elements(ytickv)

    PLOT, ratio, MODEL_OC4G_4, /XLOG,/YLOG,$
          ;;;XRANGE= [0.01,50],/XSTYLE,YRANGE=[0.000000001,100000],$
          XRANGE= [0.3,25],/XSTYLE,YRANGE=[0.001,100],$
          XTITLE='(Rrs443>Rrs485>Rrs520)/Rrs570', ytitle='Chl a (mg m!E-3!N)',/nodata,CHARSIZE=1.25,$
          TITLE='OC4G Algorithm'
    GRIDS,xtickv,ytickv,COLOR=34,LINESTYLE=0,THICK=2


    colors=[6,21]
    thick =[4,4]
    linestyle=[0,0]
    label=['OC4G v4','OC4G v4b']

    OPLOT, RATIO,MODEL_OC4G_4,COLOR=COLORS[0],THICK=THICK[0]
    OPLOT, RATIO,MODEL_OC4G_4b,COLOR=COLORS[1],THICK=THICK[1]

    !P.CHARTHICK = 2
    LEG,POS=[0.6,0.75, 0.65,0.9],LABEL=LABEL,COLOR=COLORS,LINESTYLE=LINESTYLE,THICK=THICK,LSIZE=1.5
    IF KEYWORD_SET(PS) THEN psprint ELSE STOP




STOP
STOP
;   ============>
;   Plot OC4_2 vs OC4_3
    PLOT,  OC4_2, OC4_3, /XLOG,/YLOG,$
            XRANGE=[.001,100],YRANGE=[.001,100],/xstyle,$
            XTITLE='OC4-2 Chl a (ug/l)',YTITLE='OC4-3 Chl a (ug/l)', /NODATA,CHARSIZE=2


    ONE2ONE,LINESTYLE=0,THICK=9,color=34
    OPLOT, OC4_2, OC4_3, COLOR=21,THICK=3


stop
;   ============>
;   Plot RATIO OC4_3 vs OC4_2
    PLOT,  OC4_2, OC4_3/OC4_2, /XLOG, /xstyle,$
            XRANGE=[.001,65],YRANGE=[.5,5],$
            XTITLE='OC4-2 Chl a (ug/l)',YTITLE='OC4-3 / OC4-2', /NODATA,CHARSIZE=2

   ;
   grids,[.01,0.1,1.0,10.0,100] ,[0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6],color=34
   oplot, OC4_2, REPLICATE(1.0,N_ELEMENTS(OC4_2)),color=34,thick=3
   OPLOT, OC4_2, OC4_3/OC4_2, COLOR=21,THICK=4

   IF KEYWORD_SET(PS) THEN PSPRINT


END; #####################  End of Routine ################################
