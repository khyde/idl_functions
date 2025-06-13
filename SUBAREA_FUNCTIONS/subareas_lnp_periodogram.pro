; $ID:	SUBAREAS_LNP_PERIODOGRAM.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO SUBAREAS_LNP_PERIODOGRAM,XTITLE=XTITLE, ERROR = error

;+
; NAME:
;		SUBAREAS_LNP_PERIODOGRAM
;
; PURPOSE: PLOT THE LNP PERIODOGRAMS FOR SELECTED AREAS (BOXES) FROM A DAILY AVERASGE CSV FILE
; MADE USING TS_SUBAREAS AND A MASKFILE WITH THE SELECTED AREAS PAINTED AS SOLID UNIQUE COLORS
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE: SUBAREAS_LNP_PERIODOGRAM
;
; INPUTS:
;		Parm1:	NONE
;
; OUTPUTS:
;		This PROGRAM MAKES A PNG WITH A PERIODOGRAM FOR EACH OF THE SUBAREAS IN THE INPUT CSV FILE
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

; NOTES:
; ; =======> CONSTANTS FOR THE LNP PERIODOGRAM ARE THE DEFAULTS IN IDLS LNP_TEST

; MODIFICATION HISTORY:
;			Written  Dec 1,  2009: J. O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (jay.oreilly@noaa.gov)
;			Modified Dec 19, 2009: J. O'Reilly (PER ADVICE OF TERESA DUCAS) - OK=WHERE(CSV.SUBAREA_CODE EQ N AND CSV.GMEAN NE MISSINGS(CSV.GMEAN),COUNT)
;     Modified Dec 23, 2009: K. Hyde added the postscript device and edited the program
;     Modified Dec 30, 2009: J. O'ReilllyR, t.ducas added xtitle keyword,output file name is constructed from parsed input save file name

;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SUBAREAS_LNP_PERIODOGRAM'

	PAL_36,R,G,B

	COMPUTER = GET_COMPUTER()
	DIR = 'T'	                  																															; DEFAULT DRIVE LETTER FOR THE PROJECTS DIRECTORY ON THE SERVERS
	IF COMPUTER EQ 'HALIBUT'   THEN DIR = 'D'                                                 ; PROJECTS DRIVE ON KIM'S LAPTOP
	IF COMPUTER EQ 'LOLIGO'    THEN DIR = 'C'                                                 ; PROJECTS DRIVE ON JAY'S LAB DESKTOP
	IF COMPUTER EQ 'JAY_HOME'  THEN DIR = 'D'                                                 ; PROJECTS DRIVE ON JAY'S HOME DESKTOP
	IF COMPUTER EQ 'SWORDFISH' THEN DIR = 'T'


	MAP='EC'
;	MAP='ROBINSON'


	IF MAP EQ 'EC' THEN BEGIN
		DIR_IN   = DIR + ':\PROJECTS\ECOSVAR\DATA\'
		DIR_OUT  = DIR + ':\PROJECTS\ECOSVAR\PLOTS\'
	;	SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-EC-PXY_1024_1024-LNP-SEA_AQU-REPRO5-CHLOR_A-logged.SAVE'
 		SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-EC-PXY_1024_1024-LNP-SEA_AQU-CHLOR_A.SAVE'
 		SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-EC-PXY_1024_1024-LNP-SEAWIFS-REPRO6-CHLOR_A-OC4.SAVE'
 		SAVEFILE = DIR_IN + '!W-MASK_SUBAREA-EC-PXY_1024_1024-LNP-SEAWIFS-REPRO6-CHLOR_A-OC4.SAVE'
	ENDIF


	IF MAP EQ 'ROBINSON' THEN BEGIN
		DIR_IN   = DIR + ':\PROJECTS\GLOBAL_LNP\DATA\'
		DIR_OUT  = DIR + ':\PROJECTS\GLOBAL_LNP\PLOTS\'
	;	SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-ROBINSON-PXY_4096_2048-LNP-SEA_AQU-CHLOR_A.SAVE'
	;	SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-ROBINSON-PXY_4096_2048-LNP-TRANSECT-SEA_AQU-CHLOR_A.SAVE'
		SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-ROBINSON-PXY_4096_2048-LNP-NWATLANTIC-SEAWIFS-REPRO6-CHLOR_A-OC4.SAVE'
	;SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-ROBINSON-PXY_4096_2048-LNP-TRANSECT-SEAWIFS-REPRO6-CHLOR_A-OC4.SAVE'
	;	SAVEFILE = DIR_IN + '!D-MASK_SUBAREA-ROBINSON-PXY_4096_2048-LNP-SEAWIFS-REPRO6-CHLOR_A-OC4.SAVE'
	ENDIF
stop
	IF FILE_TEST(DIR_OUT,/DIR) EQ 0 THEN FILE_MKDIR, DIR_OUT                                   ; IF THE OUTPUT DIRECTORY DOES NOT EXIST, CREATE IT


	FA=PARSE_IT(SAVEFILE,/ALL)
	TITLE_TXT=FA.PROD
	IF FA.ALG NE '' THEN TITLE_TXT=TITLE_TXT+'-'+FA.ALG
	IF FA.METHOD NE '' THEN TITLE_TXT=TITLE_TXT+' ('+STRLOWCASE(FA.METHOD)+')'
	PSFILE   = DIR_OUT + FA.NAME+ '-LNP_FREQUENCY.PS'                                              ; OUTPUT FILE

	CHL      = READALL(SAVEFILE)                                                                   ; OUTPUT FROM TS_SUBAREAS, USING CHLOR_A DAILY AVERAGES AND THE MASK :MASK_SUBAREA-EC-PXY_1024_1024-LNP.PNG
  BSET     = WHERE_SETS(CHL.SUBAREA_CODE)                                                        ; FIND THE NUMBER OF SUBAREA CODES

 																					                                                   		; CREATE THE POSTSCRIPT DEVICE FOR THE PLOTS
  PSPRINT,FILENAME=PSFILE,/COLOR,/FULL,/TIMES
 	N_PLOTS=N_ELEMENTS(BSET)
 ;	N_PLOTS=4                                                  										; CREATE THE POSTSCRIPT DEVICE FOR THE PLOTS
  !P.MULTI = [0,1,N_PLOTS]                                                              					; CREATE A FIGURE WITH ONE PLOT PER CODE
  TITLE_TXT   = TITLE_TXT+ '  '+UNITS('FREQ_Y')
  IF N_ELEMENTS(XTITLE) NE 1 THEN XTITLE_   = TITLE_TXT  ELSE XTITLE_ = XTITLE                   ; XTITLE MUST BE A SCALAR                                      ; XTITLE FOR PLOTS
  YTITLE   = 'LNP Peak Height'                                                                   ; YTITLE FOR PLOTS
  XMARGIN  = [8,2]                                                                               ; XMARGIN FOR PLOTS
  YMARGIN  = [2,2]                                                                               ; YMARGIN FOR PLOTS
  MIN_GOOD = 20                                                                                  ; EACH CODE MUST HAVE AT MORE THAN 20 OBSERVATIONS

; ***** Loop through each subarea and create a PERIODOGRAM *****
  FOR N = 0L, N_ELEMENTS(BSET)-1 DO BEGIN
    SUBS = WHERE_SETS_SUBS(BSET(N))                                                              ; GET THE SUBSCRIPTS FOR THE SUBAREA CODE
    SET  = CHL(SUBS)                                                                             ; CREATE A SUBSET OF DATA FOR THE SUBAREA CODE
    OK_GMEAN=WHERE(STRUPCASE(TAG_NAMES(SET)) EQ 'GMEAN',COUNT_GMEAN)
    IF COUNT_GMEAN EQ 1 THEN OK=WHERE(SET.GMEAN NE MISSINGS(SET.GMEAN),COUNT) $                  ; FIND THE NUMBER OF NON-MISSING DATA
                        ELSE OK=WHERE(SET.MEAN NE MISSINGS(SET.MEAN),COUNT)
    IF COUNT LE MIN_GOOD THEN CONTINUE                                                           ; IF THERE ARE LESS THAN 20 OBSERVATIONS, GOTO NEXT SUBAREA CODE
    FP   = PARSE_IT(SET[OK].FIRST_NAME,/ALL)                                                     ; PARSE THE FILE NAMES
    YF   = YRFRA(FP.DATE_START)                                                                  ; GENERATE A YEAR-FRACTION DATE (YF)
   	IF COUNT_GMEAN EQ 1 THEN DATA = FLOAT(SET[OK].GMEAN) ELSE DATA = FLOAT(SET[OK].MEAN)                                                                      ; CONVERT MEAN DATA TO FLOAT
    SUBAREA_NAME = SET[0].SUBAREA_NAME                                                           ; SUBAREA_NAME
    SUBAREA_CODE = SET[0].SUBAREA_CODE                                                           ; SUBAREA_CODE

    DATA = DEMEAN(DATA,DMEAN=DMEAN)                                                              ; DEMEAN THE DATA (TO REMOVE THE ZERO FREQUENCY FOR THE LNP [SEE>PRESS ET. AL.])
    S    = STATS2(YF,DATA,MODEL='LSY',/QUIET)                                                    ; DO THE TREND CALCULATION ON THE DEMEANED DATA
    LNP  = LNP_TEST(YF,DATA,WK1=WK1,WK2=WK2,JMAX=JMAX)                                           ; RUN THE LNP ON THE DEMEANED DATA - RETURNS A 2-ELEMENT VECTOR CONTAINING THE
                                                                                                 ; MAXIMUM PEAK IN THE LOMB NORMALIZED PERIODOGRAM AND ITS SIGNIFICANCE.
                                                                                                 ; THE SIGNIFICANCE IS A VALUE IN THE INTERVAL [0.0, 1.0]
                                                                                                 ; A SMALL VALUE INDICATES THAT A SIGNIFICANT PERIODIC SIGNAL IS PRESENT.
    PEAK = LNP[0]
    PROB = LNP[1]
    PRINT,'SUBAREA ',SUBAREA_NAME,'     MAX PEAK=',NUM2STR(PEAK,DECIMALS=2),'    PERIOD OF MAX=', NUM2STR(WK1(JMAX),DECIMALS=2)
    YRANGE = [0,PEAK+1.]                                                                         ; GIVE SOME ROOM ABOVE THE PEAK
    XRANGE = [0,12]

    IF N MOD 2 EQ 0            THEN _YTITLE = YTITLE  ELSE _YTITLE = ' '                         ; ONLY WRITE THE YTITLE ON EVERY OTHER PLOT
    IF N EQ N_ELEMENTS(BSET)-1 THEN _XTITLE = XTITLE_ ELSE _XTITLE = ' '                         ; ONLY WRITE THE XTITLE ON THE LAST PLOT

    PLOT,WK1,WK2,LINESTYLE=0,THICK=2,CHARSIZE=1.5,$                                              ; PLOT THE RESULTS OF THE LNP TEST
        XRANGE=XRANGE,XTITLE=_XTITLE,XCHARSIZE=1.5,XTICKS=6,XMINOR=1,XSTYLE=8,XMARGIN=XMARGIN,XTICKLEN=-0.05,$
        YRANGE=YRANGE,YTITLE=_YTITLE,YCHARSIZE=1.5,YTICKS=0,YMINOR=1,YSTYLE=9,YMARGIN=YMARGIN,YTICKLEN=-0.01
    XYOUTS,8,0.8*PEAK, SUBAREA_NAME,/DATA ,CHARSIZE=1.25                                         ; ADD THE SUBAREA NAME
  ENDFOR ; FOR N = 0L, N_ELEMENTS(BSET)-1 DO BEGIN

  PSPRINT

 STOP                                                                                         ; CLOSE THE POSTSCRIPT DEVICE
  IMAGE_TRIM,PSFILE,DIR_OUT=DIR_OUT,DPI=600,BACKGROUND=255,GRACE=[10,10,10,10],/OVERWRITE        ; CONVERT THE POSTSCRIPT TO A PNG


 ;STOP
END; #####################  End of Routine ################################
