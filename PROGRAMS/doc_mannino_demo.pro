; $ID:	DOC_MANNINO_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO DOC_MANNINO_DEMO

;+
; NAME:
;		DOC_MANNINO_DEMO
;
; PURPOSE:
;		This Program is a DEMO for DOC_MANNINO.PRO

; CATEGORY:
;		Algorithm
;
; CALLING SEQUENCE:
;
;		DOC_MANNINO_DEMO
;
; INPUTS:
;		NONE
;
; KEYWORD PARAMETERS:
;		REFRESH.... Reinitializes variables in COMMON MEMORY
;
; OUTPUTS:
;		A plot of the weighting function used in the blending of two seasonal functions
;
;
; COMMON BLOCKS:
;		COMMON COMMON_DOC_MANNINO_DEMO, WEIGHT_WINTER, WEIGHT_SUMMER
;		The weight_winter and weight_summer are stored in common to avoid computing these weights each time
;		the routine is called.
;
;
; EXAMPLE:
;		DOC_MANNINO_DEMO
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
; MODIFICATION HISTORY:
;		Program written by J.E. O'Reilly (Jay.O'Reilly@NOAA.GOV), May 12, 2007
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DOC_MANNINO_DEMO'

  BLENDING = ['LINEAR','']
  SENSOR = ['SEAWIFS','MODISA']
  R443  = [0.0173573,0.00868767]
  R547  = [0.0044088,0.00220438]
  R555  = [0.0043408,0.00217040]
  DATES = '2015'+['0501','0515','0520','0525','0601','0603','0605','0609','0611','0613','0615','0715','0815','0915','1001','1003','1005','1007','1009','1011','1011','1015','1020','1025','1030','1105']
  O = []
  INIT = 1
  FOR B=0, N_ELEMENTS(BLENDING)-1 DO BEGIN
    IF BLENDING(B) EQ 'LINEAR' THEN LINEAR = 1 ELSE LINEAR = 0
    FOR S=0, N_ELEMENTS(SENSOR)-1 DO BEGIN
      FOR R=0, N_ELEMENTS(R443)-1 DO BEGIN
        FOR D=0, N_ELEMENTS(DATES)-1 DO BEGIN
          IF SENSOR(S) EQ 'SEAWIFS' THEN DOC = DOC_MANNINO(RRS443=R443(R), RRS555=R555(R), DATE=DATES(D), ACDOM_ALG='MLR_A412', LINEAR=LINEAR, INIT=INIT) $
                                    ELSE DOC = DOC_MANNINO(RRS443=R443(R), RRS547=R547(R), DATE=DATES(D), ACDOM_ALG='MLR_A412', LINEAR=LINEAR, INIT=INIT)
          T = CREATE_STRUCT('SENSOR',SENSOR(S),'DATE',DATES(D),'DOY',DATE_2IDOY(DATES(D)),'RRS443',R443(R),'RRS547',MISSINGS(0.0),'RRS555',MISSINGS(0.0),DOC)
          IF SENSOR(S) EQ 'MODISA' THEN T.RRS547 = R547(R) ELSE T.RRS555 = R555(R)
          O = [O,T]    
        ENDFOR
      ENDFOR
    ENDFOR
	  STRUCT_2CSV, FIX_PATH(!S.PROJECTS + 'ECOS/SATDATA/DOC/KHYDE_TEST_DOC_'+BLENDING(B)+'.CSV'),O
	ENDFOR  

STOP ; OLD DEMO BELOW

;		===> Make PostScript Plot of the relative weights versus a Date Axis
		PSFILE=ROUTINE_NAME+'.PS'
		PSPRINT,FILENAME=PSFILE,/COLOR,/FULL
		PRINT, 'Making '+ PSFILE
		PAL_36


		!P.MULTI=[0,2,2]
;		===> Make a plot of acdom355 vs doc
		A_CDOM_355 = INTERVAL([0,2],0.01)
		doc= DOC_MANNINO(A_CDOM_355=A_CDOM_355, DATE='20060101',/REFRESH)
		PLOT, A_CDOM_355, DOC
		DOC_WINTER = 1/ ( ALOG(A_CDOM_355)*(-0.0048650) + 0.0074394  )
		OPLOT, A_CDOM_355
		grids,color=34

;		===> Summer
		doc= DOC_MANNINO(A_CDOM_355=A_CDOM_355, DATE='20060801',/REFRESH)
		PLOT, A_CDOM_355, DOC
		DOC_SUMMER = 1/ ( ALOG(A_CDOM_355)*(-0.002923)  + 0.0062469  )
		OPLOT, A_CDOM_355, DOC,COLOR=21
		grids,color=34



;		===> Show blending function
		F=BLEND(FINDGEN(1001))
		PLOT,F,TITLE='DOC Seasonal Transition Blending Function',xstyle=5,/NODATA,YTITLE='Weights',YMINOR=1,XMINOR=1
		LEGEND, ['Fall-Winter-Spring','Summer'],psym=[0,0],color=[6,21],pos=[1,0.75],pspacing=1,thick=[5,5],spacing=1
		FRAME,/PLOT,COLOR=0,THICK=4
		AXIS, XAXIS=0, XRANGE=[0,1],xtitle='Transition Period',XTICKNAME=['Start','Middle','End'],xticks=2,XMINOR=1
		GRIDS,COLOR=34,thick=2
		FRAME,/PLOT,COLOR=0,THICK=3
	  OPLOT, F,COLOR=21,THICK=5
	  OPLOT, F, COLOR=0,THICK=1
	  OPLOT, 1-F,COLOR=6,THICK=5
	  OPLOT, 1-F,COLOR=0,THICK=1

	  DA = DATE_AXIS(/FYEAR)
		PLOT, DA.JD, WEIGHT_WINTER, xticks=DA.TICKS, XTICKNAME=DA.TICKNAME,XTICKV=DA.TICKV,$
									TITLE='DOC Algorithm: Blending Weights of 2 Seasonal Functions',YTITLE='Relative Weight',/XSTYLE,/YSTYLE,/NODATA


		LEGEND, ['Fall-Winter-Spring','Summer'],psym=[0,0],color=[6,21],pos=[da.tickv[1],0.75],pspacing=1,thick=[5,5],spacing=1
		GRIDS, X=DA.TICKV,COLOR=34
		FRAME,/PLOT,COLOR=0,THICK=4

		OPLOT,YDOY_2JD(2020,INDGEN(367)), WEIGHT_WINTER,PSYM=0,COLOR=6, THICK=3
		OPLOT,YDOY_2JD(2020,INDGEN(367)), WEIGHT_SUMMER,PSYM=0,COLOR=21, THICK=3

		PSPRINT

;	********************************************************************************************


END; #####################  End of Routine ################################



