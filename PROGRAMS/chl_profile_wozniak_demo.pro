; $ID:	CHL_PROFILE_WOZNIAK_DEMO.PRO,	2014-12-18	$

   PRO CHL_PROFILE_WOZNIAK_DEMO

;+
; NAME:
;		CHL_PROFILE_WOZNIAK
;
; PURPOSE:
;		This Program is a Demo for the Wozniak et al. chl profile generator
;
; CATEGORY:
;		MODELS
;
; CALLING SEQUENCE:
;		Result = CHL_PROFILE_WOZNIAK(0.7)
;  	Result = CHL_PROFILE_WOZNIAK([ 0.015625, 0.03125, 0.0625, 0.125,0.25,0.5,1,2,4,8,16])
;
; INPUTS:
;		CHL_SAT:	Satellite (surface) chlorophyll a concentration
;

; KEYWORD PARAMETERS:

; OUTPUTS:
;		This function returns an estimated chlorophyll a profile
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;	PROCEDURE:
;			This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;

;	Cconst = 10^(-0.0437 +0.8644* alog10(Ca0)  -0.0888*(alog10(Ca0))^2)

;	Cm 		= 0.269 	+ 0.245	*(ALOG10(Ca0)) + 1.51		*(ALOG10(Ca0))^2 + 2.13		*(ALOG10(Ca0))^3 + 0.81		*(ALOG10(Ca0))^4;

;	z_max = 17.9   	- 44.6  *(ALOG10(Ca0)) + 38.1		*(ALOG10(Ca0))^2 + 1.32		*(ALOG10(Ca0))^3 -10.7		*(ALOG10(Ca0))^4;

;	Sz 		= 0.0408 	+ 0.0217*(ALOG10(Ca0)) + 0.00239*(ALOG10(Ca0))^2 + 0.00562*(ALOG10(Ca0))^3 + 0.00514*(ALOG10(Ca0))^4;

;  CHL=  Ca0* ((Cconst+Cm*EXP(-((Z-Z_MAX)*Sz)^2)) / (Cconst+Cm*EXP(-((Z_MAX)*Sz)^2)) )

;
; MODIFICATION HISTORY:
;			Written April 2, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CHL_PROFILE_WOZNIAK'
	ERROR = ''

	DO_SHOW_FUNCTIONS = 2

	PAL_36
;	***********************************
	IF DO_SHOW_FUNCTIONS GE 1 THEN BEGIN
;	***********************************
		PSFILE=routine_name+'-SHOW_FUNCTIONS.PS'
    IF FILE_TEST(PSFILE) EQ 1 AND DO_SHOW_FUNCTIONS LT 2 THEN GOTO,DONE_DO_SHOW_FUNCTIONS
	 	PSPRINT,/COLOR,/FULL,FILENAME=PSFILE
	 	!P.MULTI=[0,2,2]
	 	FONTS,'TIMES'
    PAL_36,R,G,B
    BACKGROUND_COLOR=254
    !X.OMARGIN=[0,0]
    !Y.OMARGIN=[0,0]

    Ca0=INTERVAL([-3,3],BASE=10, 0.01)
    stop

		Cconst = 10^(-0.0437 +0.8644* alog10(Ca0)  -0.0888*(alog10(Ca0))^2)
		PLOT, Ca0, Cconst, /XLOG,/nodata, TITLE='Cconst'
		grids,color=34
		OPLOT, Ca0, Cconst, color = 8,THICK=3

		Cm 		= 0.269 	+ 0.245	*(ALOG10(Ca0)) + 1.51		*(ALOG10(Ca0))^2 + 2.13		*(ALOG10(Ca0))^3 + 0.81		*(ALOG10(Ca0))^4;
		PLOT, Ca0, Cm, /XLOG,/nodata, TITLE='Cm',/ylog
		grids,color=34
		OPLOT, Ca0, Cm, color = 8,THICK=3

		z_max = 17.9   	- 44.6  *(ALOG10(Ca0)) + 38.1		*(ALOG10(Ca0))^2 + 1.32		*(ALOG10(Ca0))^3 -10.7		*(ALOG10(Ca0))^4;
		PLOT, Ca0,  Z_MAX, /XLOG,/YSTYLE,/XSTYLE, YRANGE=[-200,200],/nodata,TITLE='Zmax',xtitle=UNITS('CHLOR_A'),XTICKFORMAT='(D06.3)'
		OPLOT, Ca0, Z_MAX, color = 8,THICK=3
		GRIDS,color=34

	  Sz 		= 0.0408 	+ 0.0217*(ALOG10(Ca0)) + 0.00239*(ALOG10(Ca0))^2 + 0.00562*(ALOG10(Ca0))^3 + 0.00514*(ALOG10(Ca0))^4;
  	PLOT, Ca0,  Sz, /XLOG,/YSTYLE,/XSTYLE,  /nodata,TITLE='Sz',xtitle=UNITS('CHLOR_A'),XTICKFORMAT='(D06.3)'
		OPLOT, Ca0, Sz, color = 8,THICK=3
		GRIDS,color=34



	PSPRINT
	DONE_DO_SHOW_FUNCTIONS:
	ENDIF


	END; #####################  End of Routine ################################
