; $ID:	ABSORPTION_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
; ABSORPTION_DEMO    June 23,1999

  PRO ABSORPTION_DEMO
;+
; NAME:
;       ABSORPTION_DEMO
;
; PURPOSE:
;       Constructs plots of light absorption coefficients for:
;				 pure seawater;
;				 phytoplankton;
;
;       according to several references (methods)
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       ABSORPTION_DEMO
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;       None
;
; OUTPUTS:
;       Plots Aw,Aph, plots difference between Aw'w, and plots ratios of Aw's
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
; MODIFICATION HISTORY: Nov 8, 2001 Written by J.O'Reilly
;-

 ROUTINE_NAME='ABSORPTION_DEMO'

PS=1
  !P.MULTI=[0,1,2]
  !P.BACKGROUND = 255 & !P.COLOR=0
   PAL_36

  W = CLEAR_WATER()
  L = w.wl

; =================>
; Get Aw's AND Kw's
  Aw_SB81=W.AW_SB81
  Aw_P93 =W.AW_P93
  Aw_PF97=W.AW_PF97
  Kw_SB81=W.Kw_SB81
  Kw_P93 =W.Kw_P93
  Kw_PF97=W.Kw_PF97

  TITLE_PAGE ='Absorption by Pure Water & Phytoplankton vs. Wavelength'
  TITLE=''
  nm_title = 'Wavelength (nm)'
  ;NM_TITLE =  UNITS('LAMBDA' ,/NAME)
  NAME_APHI=  UNITS('APHI*' ,/NAME)
  NAME_WATER=  UNITS('AW' ,/NAME)

 !P.MULTI=0
; ****************************************************************
  POPE_FRY_1997:
  LABEL='WATER'
; ****************************************************************
  PSFILE='D:\BIOOPT\OREILLY\'+ROUTINE_NAME+'_'+label+'.PS'
  IF KEYWORD_SET(PS) THEN PSPRINT, FILENAME=PSFILE,/COLOR,/HALF
  FONT_TIMES
  ABS_LABEL = UNITS('ABS',/NAME)
  YTICKV = [0.00001,0.0001,0.001,0.01,0.1,1,10]
  YTICKNAME = NUM2STR(YTICKV,TRIM=2,FORMAT='(F8.5)')
  YTICKS = N_ELEMENTS(YTICKV)-1
; ================>
  PLOT, L,Aw_PF97, XRANGE=[300,800],/XSTYLE,$
        TITLE=title,$
        YRANGE=[0.00001,10],/YSTYLE,YMINOR=1,/YLOG,$
       ; YRANGE=[0.0, 0.01],/YSTYLE,YMINOR=1,$
        YTICKV=YTICKV,YTICKNAME=YTICKNAME,YTICKS=YTICKS,$
        XTITLE = nm_title,YTITLE=ABS_LABEL,$ ;'Aw (m!U-1!N)',$
        XTHICK=10,YTHICK=10,CHARSIZE=2,/NODATA,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET

        GRIDS,XTICK_GET,YTICK_GET,/ALL,COLOR=34,THICK=5,FRAME=10

  OPLOT, L,Aw_PF97, color=8,THICK=13
  ;OPLOT, [525,540],[0.006,0.006],THICK=3,color=8


 ; XYOUTS,550,0.005,UNITS('AW',/NAME)+'Pope & Fry 1997',color=8,CHARSIZE=2

GOTO, SKIP

; ***************************************************
; Absorption by Phytoplankton FROM CAMPBELL TABLE
; ***************************************************
  DIR_IN='D:\BIOOPT\CAMPBELL\'
  FILE = DIR_IN + 'CAMPBELL_MODEL_TABLE.CSV'
  ; JANETS CHL ARE   0.01 0.04 0.1 0.4 1 4 10 20

  DS=READALL(FILE)
  DS=STRUCT_2DBL(DS)

  CHL = [ '0.01','0.04','0.1','0.4','1','4','10','20']
  CHL = [ '0.01', '0.1', '1', '10' ]
  COLORS = [4,9,10,12,17,19,21,27]
  COLORS = [4, 10, 17, 21,27]
  FOR _CHL = 0,N_ELEMENTS(CHL)-1 DO BEGIN
    ACHL = CHL(_CHL)
    OK = WHERE(DS.CHL EQ ACHL)
    D=DS[OK]
      OPLOT, D.WL,D.A_PH,COLOR=COLORS(_CHL),THICK=15
      OPLOT, D.WL,D.A_PH,COLOR=0,THICK=3
      OK_L = WHERE(D.WL LT 460)
      MAX_APH =  MAX(D.A_PH(OK_L))
      OK = WHERE(D.A_PH EQ MAX_APH)
      txt = ACHL
      IF _CHL EQ N_ELEMENTS(CHL)-1 THEN txt = txt +' '+ UNITS('CHLOR_A',/name)
       IF _CHL EQ 0 THEN ALIGN= 0.1 ELSE ALIGN = 0.5
      XYOUTS,D(OK[0]).WL,MAX_APH+0.2*MAX_APH,TXT,ALIGN=ALIGN,color=COLORS(_CHL),CHARSIZE=2

  ENDFOR
IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP
SKIP:
; ***************************************************
; Absorption by Phytoplankton
; ***************************************************
  DIR_IN='D:\BIOOPT\BRICAUD\'
  FILE = DIR_IN + 'BRICAUD_1998_TABLE_AP_APHI.CSV'
  D=READALL(FILE)
  D=STRUCT_2DBL(D)
  CHL = [ '0.01','0.03','0.1','0.3','1','3','10']
  FOR _CHL = 0,N_ELEMENTS(CHL)-1 DO BEGIN
    ACHL = CHL(_CHL)
    A_P =  D.AP*ACHL^(D.EP-1)
    A_PHI =  D.APHI*ACHL^(D.EPHI-1)
    COLORS = [4,9,10,12,17,19,21,27]
    IF _CHL EQ 0 THEN BEGIN
      PLOT, D.LAMBDA,A_PHI,YRANGE=[0,0.25],XTICKS=6,XRANGE=[400,700],/XSTYLE,/YSTYLE, XTITLE=XTITLE,YTITLE=YTITLE,/NODATA
    ENDIF
      OPLOT, D.LAMBDA,A_PHI,COLOR=COLORS(_CHL)
      OPLOT, D.LAMBDA,A_PHI,COLOR=0,THICK=2
      OK_L = WHERE(D.LAMBDA LT 460)
      MAX_CHL =  MAX(A_PHI(OK_L))
      OK = WHERE(A_PHI(OK_L) EQ MAX_CHL)
      txt = ACHL
      IF _CHL EQ 0 THEN txt = txt + UNITS('CHLOR_A',/name)
       IF _CHL EQ 0 THEN ALIGN= 0.1 ELSE ALIGN = 0.5
      XYOUTS,D(OK_L(OK[0])).LAMBDA,MAX_CHL,TXT,ALIGN=ALIGN,color=COLORS(_CHL)

  ENDFOR
        XYOUTS,0.5, 0.95,/normal,TITLE_PAGE,align=0.47




  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
END
