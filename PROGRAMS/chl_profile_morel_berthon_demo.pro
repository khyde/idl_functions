; $ID:	CHL_PROFILE_MOREL_BERTHON_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

PRO CHL_PROFILE_MOREL_BERTHON_DEMO, PS=PS
;+
; NAME:
;       CHL_PROFILE_MOREL_BERTHON_DEMO
;
; PURPOSE:
;       Generate vertical profiles of chlorophyll concentration using model of:
;      	A. Morel and J.F. Berthon (1989)
;		Surface pigments, aglal biomass profiles, and potential production of the euphotic layer:
;		Relationships reinvestigated in view of remote-sensing applications.
;		Limnol. Oceanogr., 34(8):1545-1562.
;
; CATEGORY:
;      Models
;
; CALLING SEQUENCE:
;       CHL_PROFILE_MOREL_BERTHON_DEMO
;       CHL_PROFILE_MOREL_BERTHON_DEMO, cpd=1.0
;
; INPUTS:
;       None
;
; KEYWORD PARAMETERS:
;  		Cpd:    Mean  chl in the upper light penetration depth ( Cpd ~=~ sat chlorophyll, according to Morel and Berthon)
;
;
; OUTPUTS:
;    	Plot on screen
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
; NOTES:
; ===================>
; Create chlorophyll concentration profile using:
; Morel and Berthon (1989) p.1557, equation 6
; To simulate profile shapes shown on page 1555, Fig. 7b.
; This equation is based on the Standard Gaussian. See:
; Doudy,S. and S. Wearden, 1983. Statistics for Research
; John Wiley and Sons, New York, 537p.
; p.144
; f(y) = (1/(sigma*(2!pi)^0.5)) * exp -( ((y-u)^2.0) / (2*sigma^2.0))
;
; Also note that symbolic terms of Platt et al. 1991 are  used when possible
; Normal form of Platt et al. 1991 equation:
; bz= b0+   h/  (SIGMA*((2*!PI)^0.5) ) * exp( (-(Z-ZM)^2) / (2.0*sigma^2) )
;
; Morel and Berthon 1989 formulation:
; C_Cze =  b0+    bm * exp( -(  ((Zze-Zm) /ht)^2.0)    )
; or :
; C_Cze =  b0+    bm * exp( -  (Zze-Zm)^2.0 /  ht^2.0    )
;
; C_Cze is  chl / avg. euphotic chl
; C0 is background chl
; Cm is the biomass maximum:		Bm ~= h/  (SIGMA*((2*!PI)^0.5) ) in Platt et al. equation
; Zze is depth below surface, scaled to euphotic depth.
; Zm  is the depth of the chl maximum
; ht is the bump thickness parameter:    	ht  ~=  (2.0*sigma^2) in Platt et al. equation
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July, 1995.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;-

 ROUTINE_NAME='CHL_PROFILE_MOREL_BERTHON_DEMO'


	CD, CURR=DIR_WORK & DIR_WORK= DIR_WORK+ DELIMITER(/SLASH)

; ===>
	Cpd = [0.040, 0.101, 0.211, 0.368, 0.791, 2.664, 9.058]
;   The default values for Cpd are those in Morel and Berthon (1989) p. 1553, table 3, Avg. Cpd
;   These Cpd values generate curves a-g in their figure 7a when using their statistical model
;   which computes background chl, max chl, depth of chl max and 'bump spread' using
;   only the value of Cpd and model coefficients.

  PS=1

 	chl_sat = INTERVAL([-16,12],BASE=2,.005)

	DO_MOREL_BERTHON_FIG_7B 			= 0
	DO_CPD_VS_PROFILE_SHAPE      	= 0
	DO_CPD_CHLOROPHYLL_PROFILE 		= 0
	DO_FUNCTION_SHAPE      				= 1


	DO_CPD_VERSUS_CTOT_ZEU			= 0

	DO_CHL_SAT_ZEU 					=	0




;	************************************************************************
	IF DO_MOREL_BERTHON_FIG_7B THEN BEGIN
;	************************************************************************

	PSFILE=dir_work+ROUTINE_NAME+'_MOREL_BERTHON_FIG_7B.PS'
	IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/HALF
  SET_PMULTI
; ====================>
; Set some graphics defaults
  SETCOLOR,255
  PAL_36
  FONT_TIMES
  COLORS = [3, 8, 10, 14, 18, 20, 24, 27]
  !P.THICK      = 11
  !P.CHARTHICK  = 2
  !P.CHARSIZE   = 1.25
  !x.CHARSIZE   = 1.25
  !y.CHARSIZE   = 1.25

  !X.THICK      = 2
  !Y.THICK      = 2

  ZMAX=2.5

; ====================>
; Now for each of the values in the Cpd array, plot the modeled profile of the ratio of
; chl / mean euphotic chl versus depth scaled to euphotic depth
  FOR nth = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
    D=CHL_PROFILE_MOREL_BERTHON(cpd(nth),ZMAX=ZMAX,/ALLOW_ERRORS)

    ymax = max(d.c_cze)
    xmax = 3
    IF nth EQ 0 THEN BEGIN
      PLOT, D.C_CZE, -D.Z_ZE , /NODATA,$
      xrange =[0,3], xstyle = 1,ystyle = 1,$
      xtitle = 'C/C!DZe!N', ytitle='Z/Ze',$
      XTICKS=6,YTICKS=5,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
      TITLE='                                                Morel and Berthon (1989, Fig. 7b)'

      GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=35

      xoffset= 0.98*xmax
      yoffset= -0.66*ZMAX
 ;     XYOUTS,/DATA,xoffset,yoffset,'Morel and Berthon (1989)  ' ,$
 ;                  charsize=!P.CHARSIZE*1.25, ALIGN=1.0 ,color=0
      yoffset = yoffset - 0.1
      XYOUTS,/DATA,xoffset,yoffset,'C!DPD!N         C!DB!N        C!DMAX!N   Z!DMAX!N  C!DB!N+C!DMAX!N  Del_Z   SSR' ,$
                  charsize=!P.CHARSIZE*.80, ALIGN=1.0 ,color=0
    ENDIF

    OPLOT, D.C_CZE, -D.Z_ZE,COLOR=COLORS(nth)

;   ==================>
;   Label each profile along top
    letter = STRING(BYTE(65+nth))
    XYOUTS, /DATA, D.C_Cze[0], 0.03, letter, align=0.5 , charsize=!P.CHARSIZE

;   ==================>
;   Make an entry for the table of parameters
    str_Cb      = STRING(D.CB,FORMAT='(F7.3)')
    str_CMAX    = STRING(D.CMAX,FORMAT='(F7.3)')
    str_Cb_Cmax = STRING(D.CB+D.CMAX,FORMAT='(F7.3)')
    str_Z_MAX   = STRING(D.Z_MAX,FORMAT='(F7.3)')
    str_DELTA_Z = STRING(D.DELTA_Z,FORMAT='(F7.3)')
    str_Cb      = STRING(D.CB,FORMAT='(F7.3)')
    str_Cpd     = STRING(Cpd(nth),FORMAT='(F7.3)')      ; Cpd (Sat chl)
    str_ssr     = STRING( MAX(D.C_Cze) / D.C_Cze[0],  FORMAT='(F5.2)')  ;Subsurface/surface chl ratio

    yoffset = yoffset - 0.1
    txt = letter +str_cpd+' '+' '+ str_CB +' ' + str_CMAX +' '+str_Z_MAX +' '+str_Cb_Cmax +' '+ str_DELTA_Z + ' ' + str_ssr ;an entry  for the table
     XYOUTS,/DATA,xoffset,yoffset,txt,charsize=!P.CHARSIZE*.95, ALIGN=1.0 ,color=0

    CAPTION," J.O'Reilly   ",charsize=0.5*!p.charsize

  ENDFOR

	IF KEYWORD_SET(PS) THEN PSPRINT
	!P.THICK      = 1
	ENDIF; DO_MOREL_BERTHON_FIG_7B



;	************************************************************************
	IF DO_CPD_VS_PROFILE_SHAPE THEN BEGIN
;	************************************************************************

	PSFILE=dir_work+ROUTINE_NAME+'_CPD_VS_PROFILE_SHAPE.PS'
	IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/HALF

; ====================>
; Set some graphics defaults
  SETCOLOR,255
  PAL_SW3
  FONT_TIMES

  COLORS= INDGEN(249)&colors=reverse(colors)
  !P.THICK      = 7
  !P.CHARTHICK  = 2
  !P.CHARSIZE   = 1.25
  !x.CHARSIZE   = 1.25
  !y.CHARSIZE   = 1.25

  !X.THICK      = 2
  !Y.THICK      = 2

  ZMAX=2.5

	CPD=[300, 100,30,10,3, 1 , 0.3,0.1,0.03,0.02,0.01,0.003,0.001,0.0003,0.0001]
	SET_PMULTI,N_ELEMENTS(CPD)
  COLORS=INTERVAL([249,1]) & stride= N_ELEMENTS(COLORS)/N_ELEMENTS(CPD) & COLORS=COLORS(0:*:STRIDE)

; ====================>
; Now for each of the values in the Cpd array, plot the modeled profile of the ratio of
; chl / mean euphotic chl versus depth scaled to euphotic depth
  FOR nth = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
    D=CHL_PROFILE_MOREL_BERTHON(cpd(nth),ZMAX=ZMAX,/ALLOW_ERRORS)
    ymax = max(d.c_cze)
    xmax = 5
;    IF nth EQ 0 THEN BEGIN
      PLOT, D.C_CZE, -D.Z_ZE , /NODATA,$
      xrange =[0,3], xstyle = 1,$
      YRANGE =[-3,0],ystyle = 1,$
      xtitle = 'C/C!DZe!N', ytitle='Z/Ze',$
      XTICKS=5,YTICKS=5,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
      TITLE= NUM2STR( CPD[NTH],TRIM=2)

      GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=253,thick=3
		  OPLOT, D.C_CZE, -D.Z_ZE,COLOR=COLORS(nth)
; 	ENDIF

;   ==================>
;   Make an entry for the table of parameters
 		str_Cpd     = 'C!DPD!N'				+	STRING(Cpd(nth),FORMAT='(F7.3)')      ; Cpd (Sat chl)
 		str_Cb      = 'C!DB!N'				+	STRING(D.CB,FORMAT='(F7.3)')
 		str_CMAX    = 'C!DMAX!N'				+	STRING(D.CMAX,FORMAT='(F7.3)')
		str_Z_MAX   = 'Z!DMAX!N'			+	STRING(D.Z_MAX,FORMAT='(F7.3)')
 		str_Cb_Cmax = 'C!DB!N+C!DMAX!N'+	STRING(D.CB+D.CMAX,FORMAT='(F7.3)')
   	str_DELTA_Z = 'Del_Z'					+	STRING(D.DELTA_Z,FORMAT='(F7.3)')
   	str_ssr     = 'SSR'						+	STRING( MAX(D.C_Cze) / D.C_Cze[0],  FORMAT='(F5.2)')  ;Subsurface/surface chl ratio


		TXT= [str_Cpd, str_Cb,  str_CMAX,  str_Z_MAX, str_Cb_Cmax,  str_DELTA_Z, str_ssr]
		TXT= STRJOIN(TXT+'!C')
		XYOUTS,/DATA, 1.35,-0.82, TXT,CHARSIZE=.6,ALIGN= 0,COLOR=0
  ENDFOR ;

    CAPTION," J.O'Reilly   ",charsize=0.5*!p.charsize

	IF KEYWORD_SET(PS) THEN PSPRINT
	!P.THICK      = 1
	ENDIF;


;	************************************************************************
	IF DO_CPD_CHLOROPHYLL_PROFILE THEN BEGIN
;	************************************************************************

	PSFILE=dir_work+ROUTINE_NAME+'_CPD_CHLOROPHYLL_PROFILE.PS'
	IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/FULL
	TITLE_PAGE='Morel and Berthon (1989), Equations (6,1a,1b, 2b,2c)'

; ====================>
; Set some graphics defaults
  SETCOLOR,255
  PAL_SW3
  FONT_TIMES

  COLORS= INDGEN(249)&colors=reverse(colors)
  !P.THICK      = 7
  !P.CHARTHICK  = 2
  !P.CHARSIZE   = 1.25
  !x.CHARSIZE   = 1.25
  !y.CHARSIZE   = 1.25

  !X.THICK      = 2
  !Y.THICK      = 2
  !Y.OMARGIN    = [0,1]

  ZMAX=2.5



	Cpd = [0.001,0.002,0.003, 0.01,0.015, 0.02, 0.03, 0.040, 0.101, 0.211, 0.368, 0.791, 2.664, 9.058, 10.0, 15.0, 20.0, 30.0]
  COLORS=INTERVAL([249,1]) & stride= N_ELEMENTS(COLORS)/N_ELEMENTS(CPD) & COLORS=COLORS(0:*:STRIDE)

	SET_PMULTI,N_ELEMENTS(CPD)
;
;   These values for Cpd [0.040, 0.101, 0.211, 0.368, 0.791, 2.664, 9.058]
;   are those in Morel and Berthon (1989) p. 1553, table 3, Avg. Cpd
;   These Cpd values generate curves a-g in their figure 7a when using their statistical model
;   which computes background chl, max chl, depth of chl max and 'bump spread' using
;   only the value of Cpd and model coefficients.

; ====================>
; Now for each of the values in the Cpd array, plot the modeled profile of the ratio of
; chl / mean euphotic chl versus depth scaled to euphotic depth
  FOR nth = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
    D=CHL_PROFILE_MOREL_BERTHON(cpd(nth),ZMAX=ZMAX,/ALLOW_ERRORS)
    ymax = max(d.c_cze)
    xmax = 5

		CHL_SAT=CPD[NTH]



	OK=WHERE(D.Z_ZE EQ 1)
	Z 	= D.Z
	Z_EUPHOTIC = D.Zeu
	CHLOR_EUPHOTIC_MEAN = D.C_TOT/D.Zeu

	CHL_PROFILE =	d.chl

  ;[0.040, 0.101, 0.211, 0.368, 0.791, 2.664, 9.058]

  IF CPD[NTH]  EQ 0.101 THEN XRANGE = [0.03,3.0]
  IF CPD[NTH]  EQ 0.211 THEN XRANGE = [0.03, 3.0]
  IF CPD[NTH]  EQ 0.368 THEN XRANGE = [0.03,	3.0]
  IF CPD[NTH]  EQ 0.791 THEN XRANGE = [0.03,	3.0]
  IF CPD[NTH]  EQ 2.664 THEN XRANGE = [0.5, 50.0]
  IF CPD[NTH]  EQ 9.058 THEN XRANGE = [0.5, 50.0]
  IF CPD[NTH]  GE 10.0  THEN XRANGE = [0.5, 50.0]


  IF CPD[NTH]  LE 0.04 THEN XRANGE = [0.01,1]
  IF CPD[NTH]  LE 0.04 THEN XRANGE = [0.01,1]

  IF CPD[NTH]  LE 0.01 THEN XRANGE = [0.003,0.3]
  IF CPD[NTH]  LE 0.002 THEN XRANGE = [0.0001,0.1]
  IF CPD[NTH]  LE 0.001 THEN XRANGE = [0.0001,0.03]



      PLOT, CHL_PROFILE,-Z , /NODATA,$
      /XLOG, xstyle = 1,  xrange = XRANGE,$
      YRANGE =[-200,0],ystyle = 1,$
      xtitle =  UNITS('CHLOR_A',/NAME,/UNIT), YTITLE='Depth(m)',$
      YTICKS=5,$
      XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
      TITLE= 'Cpd ('+NUM2STR( CPD[NTH],TRIM=2)+')'
			BACKGROUND,/PLOT,COLOR=254
      GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=253,thick=3
      FRAME,/PLOT,THICK=4,COLOR=0
		  OPLOT, CHL_PROFILE,-Z ,COLOR=COLORS(nth)
		  PLOT_EVENT,-Z_EUPHOTIC,/YAXIS,COLOR=0,LINESTYLE=1,THICK=3
		  LABEL=NUM2STR(Z_EUPHOTIC,FORMAT='(F10.1)')
		  XYOUTS,10^!X.CRANGE[1],-Z_EUPHOTIC,/DATA,LABEL,COLOR=0,ALIGN=1.01

; 	ENDIF

;   ==================>
;   Make an entry for the table of parameters
 		str_Cpd     = 'C!DPD!N'				+	STRING(Cpd(nth),FORMAT='(F7.3)')      ; Cpd (Sat chl)
 		str_Cb      = 'C!DB!N'				+	STRING(D.CB,FORMAT='(F7.3)')
 		str_CMAX    = 'C!DMAX!N'				+	STRING(D.CMAX,FORMAT='(F7.3)')
		str_Z_MAX   = 'Z!DMAX!N'			+	STRING(D.Z_MAX,FORMAT='(F7.3)')
 		str_Cb_Cmax = 'C!DB!N+C!DMAX!N'+	STRING(D.CB+D.CMAX,FORMAT='(F7.3)')
   	str_DELTA_Z = 'Del_Z'					+	STRING(D.DELTA_Z,FORMAT='(F7.3)')
   	str_ssr     = 'SSR'						+	STRING( MAX(D.C_Cze) / D.C_Cze[0],  FORMAT='(F5.2)')  ;Subsurface/surface chl ratio


		TXT= [str_Cpd, str_Cb,  str_CMAX,  str_Z_MAX, str_Cb_Cmax,  str_DELTA_Z, str_ssr]
		TXT= STRJOIN(TXT+'!C')
;		XYOUTS,/DATA, 1.35,-0.82, TXT,CHARSIZE=.6,ALIGN= 0,COLOR=0
  ENDFOR ;

 ;   CAPTION," J.O'Reilly   ",charsize=0.5*!p.charsize
	XYOUTS,0.5,0.996,/NORMAL,TITLE_PAGE,CHARSIZE=1.25,COLOR=0,ALIGN=0.5
	IF KEYWORD_SET(PS) THEN PSPRINT
	!P.THICK      = 1
	!Y.OMARGIN    = [0,0]
	ENDIF;


;	************************************************************************
	IF DO_FUNCTION_SHAPE THEN BEGIN
;	************************************************************************

	PSFILE=dir_work+ROUTINE_NAME+'_FUNCTION_SHAPE.PS'
	IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/HALF

	TITLE_PAGE='Morel and Berthon (1989), Page 1557, Equation 6
; ====================>
; Set some graphics defaults
  SETCOLOR,255
  PAL_SW3
  FONT_TIMES

  COLORS= INDGEN(249)&colors=reverse(colors)
  !P.THICK      = 7
  !P.CHARTHICK  = 2
  !P.CHARSIZE   = 1.25
  !x.CHARSIZE   = 1.25
  !y.CHARSIZE   = 1.25

  !X.THICK      = 2
  !Y.THICK      = 2

  ZMAX=2.5

	MIN_CPD = 0.0001 & MAX_CPD = 1000.
	CPD=INTERVAL([ALOG10(MIN_CPD),ALOG10(MAX_CPD)],BASE=10, 0.1)

	N_PLOTS = 8
	SET_PMULTI,N_PLOTS

	FOR nth = 0, N_ELEMENTS(Cpd)-1 DO BEGIN
 		D=CHL_PROFILE_MOREL_BERTHON(CPD[NTH], ZMAX=ZMAX,/ALLOW_ERRORS)
 		IF nth EQ 0 THEN DD=D ELSE DD = [DD,D]
 	ENDFOR
 	  D=DD

  COLORS = [ 8, 10, 14, 18, 20, 24, 27]
  PAL_36


; ===> Plot each function response to CPD

  XRANGE=MINMAX(CPD)
  XTICKVAL=INTERVAL(FLOAT(ALOG10(XRANGE)),1,BASE=10)
  XTICKNAME=NUM2STR(XTICKVAL,TRIM=2)
  XTICKS=N_ELEMENTS(XTICKVAL)-1

  ymax = max(d.c_cze)
  xmax = 5
;   IF nth EQ 0 THEN BEGIN
	str_Cpd     = 'C!DPD!N'
 	str_Cb      = 'C!DB!N'
 	str_CMAX    = 'C!DMAX!N'
	str_Z_MAX   = 'Z!DMAX!N'
 	str_Cb_Cmax = 'C!DB!N+C!DMAX!N'
  str_DELTA_Z = 'Del_Z'
  str_ssr     = 'SSR'


  EQ_CB=  	"Cb= 0.768" 				+"!C" + "+ (0.087 * Log(Cpd))" +"!C" + "- (0.179 * (Log(Cpd))^2.0)" +"!C" + "- (0.025 * (Log(Cpd))^3.0)"
  EQ_Cmax=	"Cmax = 0.299" 			+"!C" + "- (0.289 * Log(Cpd))" +"!C" + "+ (0.579 * (Log(Cpd))^2.0)"
  EQ_Z_max=	"Z_max   = 0.600" 	+"!C" + "- (0.640 * Log(Cpd))" +"!C" + "+ (0.021 * (Log(Cpd))^2.0)" +"!C" + "+ (0.115 * (Log(Cpd))^3.0)"
  EQ_Delta_Z="delta_Z = 0.710" 	+"!C" + "+ (0.159 * Log(Cpd))" +"!C" + "+ (0.021 * (Log(Cpd))^2.0)"

  PLOT, CPD, D.CB  ,/XLOG, /NODATA,Ytitle=str_Cb,$
    xrange =xrange,xstyle=1,ystyle = 0,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
	  OPLOT, CPD, D.CB,COLOR=COLORS[0]
	  PLOT_EVENT,0.0,/YAXIS, COLOR=0,THICK=3,LINESTYLE=1
	  XYOUTS,/DATA, 2E-3, -0.7,EQ_CB,CHARSIZE=0.7

	PLOT, CPD, D.CMAX  ,/XLOG, /NODATA,Ytitle=str_CMAX,$
    xrange =xrange,xstyle=1,ystyle = 0,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
	  OPLOT, CPD, D.CMAX,COLOR=COLORS[1]
	  XYOUTS,/DATA, 2E-3, 9,EQ_Cmax,CHARSIZE=0.7

	PLOT, CPD, D.Z_MAX  ,/XLOG, /NODATA,Ytitle=str_Z_MAX,$
    xrange =xrange,xstyle=1,ystyle = 0,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
    PLOT_EVENT,0.0,/YAXIS, COLOR=0,THICK=3,LINESTYLE=1
	  OPLOT, CPD, D.Z_MAX,COLOR=COLORS(2)
	  XYOUTS,/DATA, 2E-3, -2.0,EQ_Z_max,CHARSIZE=0.7
	  OK=WHERE(CPD GE 1) & PRINT, MIN(D.Z_MAX[OK])


	PLOT, CPD, D.CB+D.CMAX  ,/XLOG, /NODATA,Ytitle=str_Cb_Cmax,$
    xrange =xrange,xstyle=1,ystyle = 0,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
	  OPLOT, CPD, D.CB+D.CMAX,COLOR=COLORS(3)

	PLOT, CPD, D.DELTA_Z  ,/XLOG, /NODATA,Ytitle=str_DELTA_Z,$
    xrange =xrange,xstyle=1,ystyle = 0,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
	  OPLOT, CPD, D.DELTA_Z ,COLOR=COLORS(4)
	  XYOUTS,/DATA, 0.2E-3, 1.3,EQ_Delta_Z,CHARSIZE=0.7


	SSR=0.0
  FOR NTH=0,N_ELEMENTS(CPD)-1 DO BEGIN
  	D=CHL_PROFILE_MOREL_BERTHON(CPD[NTH], ZMAX=ZMAX,/ALLOW_ERRORS)
  	SSR = [SSR,MAX(D.C_Cze) / D.C_Cze[0]]
  ENDFOR

	  PLOT, CPD, SSR  ,/XLOG, /NODATA,TITLE=str_ssr,$
    xrange =xrange,xstyle=1,ystyle = 1,xtitle= 'Cpd '+UNITS('CHLOR_A',/NO_NAME),Ytitle=str_ssr,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET
    GRIDS,X=XTICK_GET,Y=YTICK_GET,COLOR=34,thick=3
	  OPLOT, CPD, SSR,COLOR=COLORS(6)


		XYOUTS,0.5,0.99,/NORMAL,TITLE_PAGE,CHARSIZE=1.25,COLOR=0,ALIGN=0.5

    CAPTION," J.O'Reilly   ",charsize=0.5*!p.charsize

	IF KEYWORD_SET(PS) THEN PSPRINT
	!P.THICK      = 1

	ENDIF;



;	************************************************************************
	IF DO_CPD_VERSUS_CTOT_ZEU THEN BEGIN
;	************************************************************************
 	PSFILE=ROUTINE_NAME+'_CPD_VERSUS_CTOT_ZEU.PS'
	IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/full
	cpd = INTERVAL([-16,12],BASE=2,.005)
	CHL_SAT=CPD

; ====================>
; Set some graphics defaults
  SETCOLOR,255
  PAL_36
  FONT_TIMES
  COLORS = [ 8,  14, 21]
  !P.THICK      = 11
  !P.CHARTHICK  = 2
  !P.CHARSIZE   = 1.25
  !x.CHARSIZE   = 1.25
  !y.CHARSIZE   = 1.25

  !X.THICK      = 2
  !Y.THICK      = 2
;============================================================
;   Calculate Chl_tot from Satellite Surface Chlorophyll Data
;============================================================
  C_TOT=38.0*FLOAT(Chl_sat lt 1.)*(Chl_sat > 0.)^0.425 $
       +40.2*FLOAT(Chl_sat ge 1.)*(Chl_sat > 0.)^0.507
  CHL_TITLE = UNITS('CHLOR_A')
  !P.MULTI=[0,1,3]
 !P.CHARSIZE=2.5
 PLOT, CHL_SAT,C_TOT,/XLOG,/YLOG,/NODATA, $
		xrange =[0.0001,1000],yrange=[0.1,1000], xstyle = 1,ystyle = 1,$
		xtitle = 'Sat '+UNITS('CHLOR_A'), ytitle='Euphotic '+UNITS('CHLOR_A'),$
;      XTICKS=6,YTICKS=5,$
       XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
      TITLE='         Morel and Berthon (1989)'

      GRIDS,x=XTICK_GET,y=YTICK_GET,COLOR=35
      OPLOT, CHL_SAT,C_TOT,COLOR=COLORS[0]
      TXT=" C_TOT=38.0*FLOAT(Chl_sat LT 1.)*(Chl_sat > 0.)^0.425  + 40.2*FLOAT(Chl_sat GE 1.)*(Chl_sat > 0.)^0.507 "
      XYOUTS, 1.07E-4,0.2,/DATA,TXT,CHARSIZE=0.94

;		============================================================
; 		Calculate Euphotic Depth with Morel's Case I model
;		============================================================
; 	print,'Calculating Euphotic depth'
;;		From Behrenfeld
;;  	Z_eu=(C_TOT > 0.)-FLOAT(C_TOT LE 0.)
;;  	Z_eu=1/Z_eu
;;  	Z_eu=(Z_eu > 0.)
;;  	Z_eu=(568.2*(Z_eu le 0.1)*Z_eu^(.746)+ 200.*(Z_eu gt 0.1)*Z_eu^(.293))  ;Z_eu

			Z_eu  =  (C_TOT GT 10.0)* 568.2*C_TOT^(-0.746) +  (C_TOT LE 10.0)* 200.*C_TOT^(-0.293)



  PLOT, C_TOT,Z_eu,/NODATA,  /xlog,/ylog, $
       xrange =[0.1,1000],yrange=[300,1], xstyle = 1,ystyle = 1,$
       xtitle='Euphotic '+UNITS('CHLOR_A'), ytitle = 'Euphotic Depth (m)',$
;      XTICKS=6,YTICKS=5,$
       XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET;,$
       TITLE='                                                Morel and Berthon (1989)'

      GRIDS,x=XTICK_GET, y=YTICK_GET,COLOR=35
 			OPLOT,C_TOT,Z_eu,COLOR=COLORS[1]
			TXT=" Z_eu  =  (C_TOT GT 10.0)* 568.2*C_TOT^(-0.746) +  (C_TOT LE 10.0)* 200.*C_TOT^(-0.293) "
			XYOUTS, 0.15, 2,/DATA,TXT,CHARSIZE=1

 	PLOT, chl_sat,Z_eu,/NODATA,  /xlog,/ylog, $
       xrange =[0.00001,1000],yrange=[1000,1], xstyle = 1,ystyle = 1,$
       xtitle = 'Sat '+UNITS('CHLOR_A'), ytitle = 'Euphotic Depth (m)',$
;      XTICKS=6,YTICKS=5,$
       XTICK_GET=XTICK_GET, YTICK_GET=YTICK_GET ;,$
       TITLE='                                                Morel and Berthon (1989)'

      GRIDS,x=XTICK_GET, y=YTICK_GET,COLOR=35
 			OPLOT,chl_sat,Z_eu,COLOR=COLORS(2)

   ; CAPTION," J.O'Reilly   ",charsize=0.5*!p.charsize

	IF KEYWORD_SET(PS) THEN PSPRINT
	ENDIF ; DO_CTOT_VERSUS_ZEU

;	************************************************************************
	IF DO_CHL_SAT_ZEU THEN BEGIN
;	************************************************************************
;		Develop a simple function relating Chl_sat to Z_eu ******
		PSFILE=ROUTINE_NAME+'_CHL_SAT_ZEU.PS'
		IF KEYWORD_SET(PS) THEN PSPRINT,FILENAME=PSFILE,/COLOR,/full


;		NOTES:
;		IF Pure Water Extinction coefficien (blue light) = 0.02m-1
;		PRINT, ALOG(0.01)/.02
;		230.26 meters = Zeu for pure water
;		IF chlorophyll-specific absorption coefficient is -0.016 then
;		max euphotic chl can be 288 mg chl m-2

;		===>
		PAL_36,R,G,B
		chl_sat = INTERVAL([-16,12],BASE=2,.005)

		ok=where(chl_sat ge 1e-4 and chl_sat le 2e1)&chl_sat=chl_sat(ok)
;		============================================================
;   	Calculate Chl_tot from Satellite Surface Chlorophyll Data
;		============================================================

  	C_TOT= 38.0*FLOAT(Chl_sat lt 1.)*(Chl_sat > 0.)^0.425 $
       		+40.2*FLOAT(Chl_sat ge 1.)*(Chl_sat > 0.)^0.507                 ;

;		============================================================
; 		Calculate Euphotic Depth with Morel's Case I model
;		============================================================
; 	print,'Calculating Euphotic depth'
  	Z_eu  =  (C_TOT GT 10.0)* 568.2*C_TOT^(-0.746) +  (C_TOT LE 10.0)* 200.*C_TOT^(-0.293)



		!P.MULTI=[0,1,3]
		PLOT, CHL_SAT, Z_EU,/XLOG,/YLOG,XTHICK=2,YTHICK=2,CHARSIZE=1.5,$
		 	xtitle = 'Sat '+UNITS('CHLOR_A'), ytitle = 'Euphotic Depth (m)',$
		 	XRANGE=[1E-5,1E3],YRANGE=[0.1,300],/XSTYLE,/YSTYLE,/NODATA
		GRIDS,COLOR=35
		OPLOT, CHL_SAT, Z_EU,thick=7,COLOR=0
		DEG=3
		coeff=POLY_FIT_ORTHO(alog10(chl_sat),alog10(Z_eu),DEG,YFIT,TYPE=1)
		oplot, chl_sat, 10^yfit,color=18,thick=3
		_chl_sat = INTERVAL([-16,12],BASE=2,.005)
		IF DEG EQ 2 THEN BEGIN
			YY=(COEFF[0]+ $
				COEFF[1]*(alog10(_chl_sat))+$
				COEFF(2)*(alog10(_chl_sat))^2)
			ENDIF
		IF DEG EQ 3 THEN BEGIN
			YY=(COEFF[0]+ $
				COEFF[1]*(alog10(_chl_sat))+$
				COEFF(2)*(alog10(_chl_sat))^2+$
				COEFF(3)*(alog10(_chl_sat))^3 )
		ENDIF
		OPLOT,_CHL_SAT, 10^YY,COLOR=18,THICK=3

;		=======================================================================
; 	Calculate K_PAR via Nelson and Smith,1991, positive coefficients (m-1)
;		=======================================================================
 		K_PAR 	= 0.04 + (0.0088 * _Chl_sat) + (0.054 * _Chl_sat^(2./3) ) ;
 		Z_eu_NS = -ALOG(0.01)/K_PAR
    OPLOT,_CHL_SAT, Z_eu_NS, COLOR=19

;		=======================================================================
; 	Calculate K_PAR via Jay
;		=======================================================================
;		K_PAR 	= 0.02 + (0.022 * _Chl_sat) + (0.08 * _Chl_sat^(0.30) ) ;pretty good
		K_PAR 	= 0.02 + (0.018 * _Chl_sat) + (0.08 * _Chl_sat^(0.325) ) ;
		K_PAR 	= 0.02 + (0.0186 * _Chl_sat) + (0.08 * _Chl_sat^(0.33) ) ;
		K_PAR 	= 0.02 + (0.0183 * _Chl_sat) + (0.0833 * _Chl_sat^(0.333) ) ;pretty good
		K_PAR 	= 0.02 + (0.0183 * _Chl_sat) + (0.0843 * _Chl_sat^(0.333) ) ;best
 		K_PAR 	= 0.02 + (0.0186  * _Chl_sat) + (0.0856 * _Chl_sat^(0.333) ) ;pretty good
 		Z_eu_NS = -ALOG(0.01)/K_PAR
    OPLOT,_CHL_SAT, Z_eu_NS, COLOR=6

;		===>
		PLOT, chl_sat, z_eu-10^yfit,/XLOG,CHARSIZE=1.5,$
		 xtitle = 'Sat '+UNITS('CHLOR_A'), $
		 ytitle = 'Euphotic Depth (Morel&Berthon - Poly (m)',/NODATA
		GRIDS,COLOR=35
		OPLOT,chl_sat, z_eu-10^yfit,COLOR=6,THICK=3



		PLOT, chl_sat, (10^yfit)/Z_EU,/XLOG,CHARSIZE=1.5,$
			xtitle = 'Sat '+UNITS('CHLOR_A'), $
		 	ytitle = 'Euphotic Depth (Poly/ Morel&Berthon',yrange=[0.8,1.2],/NODATA
		GRIDS,COLOR=35
		OPLOT,chl_sat, (10^yfit)/Z_EU,thick=5,color=21
		IF KEYWORD_SET(PS) THEN PSPRINT

	ENDIF

END  ; End of Program
