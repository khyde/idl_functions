; $ID:	I_LIGHT_MEAN_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO I_LIGHT_MEAN_DEMO
;+
; NAME:
;       I_LIGHT_MEAN_DEMO
;
; PURPOSE:
;				Demonstrate the comparison between deriving mean light value by
;				the MEAN of light computed for many many thin layers
;				versus deriving the mean by using a fast formula.
;

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 23,2004
;-

ROUTINE_NAME='I_LIGHT_MEAN_DEMO'
DIR_PLOTS = 'D:\IDL\PLOTS\'

; PROGRAM SWITCHES (0=OFF,1=ON)
	DO_LIGHT_MEAN_ISOLUME		=	0

	DO_LIGHT_LAYER 					= 0
	DO_LIGHT_MEAN_LAYER 		=	0
	DO_LIGHT_MEAN_LAYER_K_VS_Z = 1



;	**********************************************************************************
;	***** Demonstrate computation of mean light energy and compare with formula ******
;	**********************************************************************************
	IF DO_LIGHT_MEAN_ISOLUME GE 1 THEN BEGIN
		PRINT,'This Demonstrates the equivalence of Estimates of Mean Light Intensity Based on the Mean of Light Intensities for Many Layers versus Estimates from a Fast Simple Formula.
		ZEU=25.0  ; euphotic depth 25.0 meters
		K=ALOG(0.01)/ZEU  ; overall extinction coefficient for euphotic layer

; 	===> Need a large set of depths that vary by very small increments
;  	Z=FINDGEN(20000001)/100000. ; (for more accuracy)
 		Z=DINDGEN(2000001)/10000.
;		===> surface light is 100% by definition
  	I0=100.0d

; 	===> Light at any depth
		Iz=I0*EXP(K*Z)

;		===> ISOLUMES
		ISOLUMES = [100,99,70,50,10,3,1,0.1, 0.01]

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0,N_ELEMENTS(ISOLUMES)-1 DO BEGIN
	  	LUME = ISOLUMES[NTH]*.01
			Z_ISO   = ALOG(LUME)/K
			OK=WHERE(Z LE Z_ISO,COUNT)
			MEAN_LIGHT =  MEAN(Iz(OK))

    	a = K*Z_ISO
	 		fraction= -1*((1.0D - EXP(a))/a) ;
	 		PRINT,'ISOLUME (%): '+STRTRIM(ISOLUMES[NTH],2) +' Depth '+ STRTRIM(Z_ISO ,2) + $
	 								 ' Mean Light for '+NUM2STR(Count)+' Layers: ' + NUM2STR(MEAN_LIGHT) + $
	 							  '  Versus Mean Based on Formula:  '+NUM2STR(FRACTION*100)

		print,I_LIGHT_MEAN( K=k, Z=Z_ISO)
		ENDFOR
	ENDIF ; IF DO_LIGHT_MEAN GE 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\



;	*******************************************************************************************************
;	***** Demonstrate Formulas for computation of mean light energy for top, mid and bottom of layers *****
;	*******************************************************************************************************
	IF DO_LIGHT_LAYER GE 1 THEN BEGIN
		PSPRINT,PSPRINT,FILENAME= DIR_PLOTS+ROUTINE_NAME+'-top-mid-bottom.PS',/COLOR,/FULL
		PAL_36
		TOP_COLOR = 21
		MID_COLOR = 10
		BOT_COLOR =  6

		ZEU=50.0  ; euphotic depth 25.0 meters
		KPAR= -ALOG(0.01)/ZEU  ; overall extinction coefficient for euphotic layer (POSITIVE K!)

		Z_LAYERS = [0.01,0.1,1.0,2.0,4.0, 8.0]

		SET_PMULTI,N_ELEMENTS(Z_LAYERS)

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,N_ELEMENTS(Z_LAYERS)-1  DO BEGIN
			z_layer = z_layers(nth)
			N_LAYERS=100.0/Z_LAYER
			Z=FINDGEN(N_LAYERS)*Z_LAYER


			K=REPLICATE(KPAR,N_LAYERS)
			FRACT=REPLICATE(0.0D,N_LAYERS)

			E=REPLICATE(0.0D,N_LAYERS);
			E[0]=60
			FRACT[0]=1.0D

;			===> Loop to compute FRACT the slow way
			FOR layer=1L,N_LAYERS-1L DO BEGIN
   			E(layer)=E(layer-1)*EXP(-K(layer)*Z_LAYER);
   			FRACT(layer)=FRACT(layer-1)*EXP(-K(layer)*Z_LAYER);
  		ENDFOR

; 		===> Fraction of Surface Light at the top of each layer (Identical to FRACT in above loop):
 			fract_top= EXP(K[0]*z_layer 		+ TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

; 		===> Fraction of Surface Light at the bottom of each layer:
 			fract_bot= EXP(         					TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

;			===> Fraction of Surface Light in the middle of each layer:
 			fract_mid = EXP(K[0]*z_layer*0.5 + TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

;			===> Show equivalence of fract_mid_fast to fract_mid
			fract_mid_fast= FRACT_TOP*EXP(-1.0d*K[0]*Z_LAYER*0.5)
			PRINT
			PRINT,'MINMAX DIFFERENCE (FRACT_MID - FRACT_MID_FAST)', STRING(MINMAX(FRACT_MID-FRACT_MID_FAST))


	 		PLOT, fract_top,fract_top,/xlog,/ylog ,XTHICK=2,YTHICK=2, $
	 					TITLE='Layer Thickness = '+NUM2STR(z_layer,TRIM=2)+' (m)',XTITLE='Light Fraction Top',YTITLE='Light Fraction'
			OPLOT, fract_top, fract_top,COLOR	= TOP_COLOR,THICK=2
			OPLOT, fract_top, fract_mid,color	=MID_COLOR,THICK=2
			OPLOT, fract_top, fract_mid_FAST,	color=34,THICK=1,LINESTYLE=1
			OPLOT, fract_top, fract_bot,color	=BOT_COLOR,THICK=2
			print
			PRINT,'Light Fraction for TOP, MID, BOTTOM of First 12 layers when Layer Thickness is: ' + STRING(Z_LAYER)+ ' meters'
			PRINT,FRACT_TOP(0:11), FRACT_MID(0:11), FRACT_BOT(0:11)

;			===> Legend
		TXT = ['Fraction Top','Fraction Mid','Fraction Bot']
		COLORS = [TOP_COLOR,MID_COLOR,BOT_COLOR]
 		THICKS = [2,2,2]
 		LEG,pos =[0.02 ,0.83,0.06,0.93], color=colors,label=TXT,THICK=THICKS,LSIZE=1.0
		ENDFOR
		PSPRINT

		PRINT
		CD,CURR=CURR

		PRINT,'A postscript plot (IDL.PS) was made in the directory: ' + CURR
	ENDIF


;	*********************************************************************************
;	***** Demonstrate Formulas for computation of mean light energy for a layer *****
;	*********************************************************************************
	IF DO_LIGHT_MEAN_LAYER GE 1 THEN BEGIN
		PSPRINT,FILENAME= DIR_PLOTS+ROUTINE_NAME+'-mean_light.PS'/COLOR,/FULL
		PAL_36
		ZEU=25.0  ; euphotic depth 25.0 meters
		K=ALOG(0.01)/ZEU

		TOP_COLOR = 21
		MEAN_COLOR = 19
		MID_COLOR = 10
		BOT_COLOR =  6

		ZEU=25.0  ; euphotic depth 25.0 meters
		KPAR= -ALOG(0.01)/ZEU  ; overall extinction coefficient for euphotic layer (POSITIVE K!)

		Z_LAYERS = [0.01,0.1,1.0,2.0,4.0, 8.0,16.0]
		Z_LAYERS = [16,8,4,2]


		SET_PMULTI,N_ELEMENTS(Z_LAYERS)

;  	Z=FINDGEN(20000001)/100000. ; (for more accuracy)
 		ZZ=DINDGEN(2000001)/10000.
;		===> surface light is 100% by definition
  	I0=1.0d
; 	===> Light at any depth
		Iz=I0*EXP(K*ZZ)

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,N_ELEMENTS(Z_LAYERS)-1  DO BEGIN
			z_layer = z_layers(nth)

			N_LAYERS=100.0/Z_LAYER
			Z=FINDGEN(N_LAYERS)*Z_LAYER
			K=REPLICATE(KPAR,N_LAYERS)

; 		===> Fraction of Surface Light at the top of each layer (Identical to FRACT in above loop):
 			fract_top= EXP(K[0]*z_layer 		+ TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

; 		===> Fraction of Surface Light at the bottom of each layer:
 			fract_bot= EXP(         					TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

;			===> Fraction of Surface Light in the middle of each layer:
 			fract_mid = EXP(K[0]*z_layer*0.5 + TOTAL(-1.0D*K*Z_layer,/CUMULATIVE,/DOUBLE))

			A = -K* z_layer
			FRACT_MEAN = -1*FRACT_TOP*((1.0d - EXP(a))/a)
			FRACT_MEAN_LOOP = REPLICATE(0D,N_ELEMENTS(Z))

			FOR _z=0,N_ELEMENTS(Z)-2 DO BEGIN
				UPPER=Z(_Z) & LOWER = Z(_Z+1)
				OK=WHERE(ZZ GE UPPER AND ZZ LT LOWER,COUNT)
				FRACT_MEAN_LOOP(_z) =  MEAN(Iz(OK))
			ENDFOR

			PRINT
			PRINT, FRACT_TOP
			PRINT, FRACT_MEAN
			PRINT, FRACT_MEAn_LOOP
			PRINT,FRACT_MID
			PRINT,FRACT_BOT

			PRINT,'MINMAX(FRACT_MEAN-FRACT_MEAN_LOOP)'
			PRINT,MINMAX(FRACT_MEAN-FRACT_MEAN_LOOP)

 	 		PLOT, fract_top,fract_top,/xlog,/ylog ,XTHICK=2,YTHICK=2, $
	 					TITLE='Layer Thickness = '+NUM2STR(z_layer,TRIM=2)+' (m)',XTITLE='Light Fraction Top',YTITLE='Light Fraction'
			OPLOT, fract_top, fract_top,COLOR	= TOP_COLOR,THICK=2
			OPLOT, fract_top, FRACT_MEAN,	color=MEAN_COLOR,THICK=1,LINESTYLE=1
			OPLOT, fract_top, fract_mid,color	=MID_COLOR,THICK=2
			OPLOT, fract_top, fract_bot,color	=BOT_COLOR,THICK=2
			print

;			===> Legend
			TXT = ['Fraction Top','Fraction Mean','Fraction Mid','Fraction Bot']
			COLORS = [TOP_COLOR,MEAN_COLOR,MID_COLOR,BOT_COLOR]
 			THICKS = [2,2,2,2]
 			LEG,pos =[0.02 ,0.83,0.06,0.93], color=colors,label=TXT,THICK=THICKS,LSIZE=1.0
			ENDFOR

			PSPRINT
		PRINT
		CD,CURR=CURR

		PRINT,'A postscript plot (IDL.PS) was made in the directory: ' + CURR
	ENDIF


;	**********************************************************************************
;	***** Demonstrate
;	**********************************************************************************
	IF DO_LIGHT_MEAN_LAYER_K_VS_Z GE 1 THEN BEGIN
		PSPRINT,FILENAME=DIR_PLOTS+ROUTINE_NAME+'-K_PAR-VS-MEAN_LIGHT.PS',/COLOR,/FULL
		K_PARS = 0.01 + 0.01*DINDGEN(100)
		K_PARS = [ 0.02, 0.03, 0.04,  0.05, 0.06, 0.07,0.08,0.09,0.1, 0.2, 0.3, 0.4, 0.5,1.0]
		D=DECADES() & OK=WHERE(D GE 0.02 AND D LE 1.01)
		K_PARS = FLOAT(D[OK])
		Z = .001 * DINDGEN(2E5)
		PAL_SW3,R,G,B
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0,N_ELEMENTS(K_PARS)-1 DO BEGIN
			K_PAR = K_PARS[NTH]
			L = I_LIGHT_MEAN(K=K_PAR, Z=Z )
		  IF NTH EQ 0 THEN BEGIN
		  	PLOT, Z,L  ,XRANGE = [.1,200],/XSTYLE,$
		  	XTITLE = UNITS('DEPTH',/UNIT,/NAME),ytitle = 'Mean Light Intensity in Water Column',  /NODATA
		  	GRIDS,COLOR=253,THICK=1,/ALL
    		FRAME,/PLOT,COLOR=0,THICK=4
		  ENDIF

			COLOR= 1 > SD_SCALES(PROD='K_PAR',K_PAR,/DATA2BIN,SPECIAL_SCALE='L3B') < 249
    	OPLOT, Z,L,COLOR=COLOR ,THICK=3
    	OK=WHERE_NEAREST(Z,MEDIAN(Z),NEAR=5)

			XYOUTS2,Z[OK],L[OK], NUM2STR(K_PAR,TRIM=2),CHARSIZE=charsize, ALIGN=[0.5,0.5],/DATA, _EXTRA=_extra,BACKGROUND=background

		ENDFOR

STOP
			LEG=COLOR_BAR_SCALE(PROD='SST',SPECIAL_SCALE='L3B')
			SZ=SIZE(LEG,/STRUCT)
			PX=SZ.DIMENSIONS[0]
			PY=SZ.DIMENSIONS[1]


		PSPRINT
	ENDIF ; IF DO_LIGHT_MEAN GE 1 THEN BEGIN
;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\\



END; #####################  End of Routine ################################



