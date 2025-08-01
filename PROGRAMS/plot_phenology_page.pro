; $ID:	PLOT_PHENOLOGY_PAGE.PRO,	2020-07-08-15,	USER-KJWH	$
;###################################################################################################
	PRO  PLOT_PHENOLOGY_PAGE,FILE,DIR_OUT= DIR_OUT,MAP=MAP,DIR_DATA=DIR_DATA, $
                          SUBAREA_CODES=SUBAREA_CODES,PROD=PROD , $
                          METHODS=METHODS,DATE_MIN=DATE_MIN,DATE_MAX=DATE_MAX,STATS_COLOR=STATS_COLOR,$
                          OVERWRITE=OVERWRITE,PS=PS,P_MULTI=P_MULTI, SHOW_MEAN=SHOW_MEAN, SHOW_CV=SHOW_CV,TRANSFORM = TRANSFORM
                          
                          
                          
                          
                          
;+
; NAME:
;       PLOT_PHENOLOGY_PAGE
; PURPOSE:  MAKE A POSTSCRIPT PLOT OF PHENOLOGY FROM MONTHLY MIN,MAX
;KEYWORDS:
;       PS: MAKE A PS PLOT[DEFAULT]
;       JUL 4,2013 WRITTEN BY:  J.OREILLY [AFTER PLOT_LME_PAGE
;       
;###################################################################################################
;-
;******************************
 ROUTINE_NAME = 'PLOT_PHENOLOGY_PAGE'
;******************************
;  PSPRINT  REILL  STOP

P
IF NOT KEYWORD_SET(PS) AND NOT KEYWORD_SET(PNG) THEN PS = 1
  IDL_SYSTEM
  PAL_SW3,R,G,B
  BACKGROUND,COLOR=255
  BACKGROUND_COLOR = 254
  GRID_COLOR = 252
	SETCOLOR, BACKGROUND_COLOR
	TITLE_PAGE_CHARSIZE = 2
	STATS_CHARSIZE = 1.2
	NAME_CHARSIZE = 1
	;JAN 19,2011,JOR
	; ===> STANDARDIZE FOR MONTH LABELS AND GRID LINES (SO VARYING TIME SERIES LENGTHS DO NOT CAUSE STAGGERING OF VERTICAL LINE AT EACH YEAR)
	XJM=DATE_AXIS(['20200101','20201231'],/MONTH, ROOM=[0,1],STEP_SIZE=3,MAX_LABELS=60,/FYEAR)
	;===> REMOVE J (JULY) BETWEEN YEARS
	OK = WHERE(XJM.TICKNAME EQ 'J!C',COUNT)& IF COUNT GE 1 THEN XJM.TICKNAME[OK] = ' '
  XJY=DATE_AXIS(['20200101','20201231'],/YEAR,ROOM=[0,0],STEP_SIZE=1,/FYEAR)
  OK = WHERE(XJY.TICKNAME EQ '2020',COUNT)& IF COUNT GE 1 THEN XJY.TICKNAME[OK] = ' '
  ;===> MUST HAVE LESS THAN 60 TICKV
  ;
	;TAG_MONTH-CHLOR_A
	
PAGE_SUBTITLE ="CHL'
  UL='_'
  DASH='-'
  IF N_ELEMENTS(FILE) EQ 0 OR N_ELEMENTS(DIR_OUT) EQ 0 OR N_ELEMENTS(MAP) EQ 0 THEN STOP
  DB = CSV_READ(FILE)
  LMES = GET_LME_MAPS()
;===> SORT NORTH TO SOUTH
  S=SORT(LMES.NORTH_SOUTH) & LMES=LMES(S)
   
  IF N_ELEMENTS(PROD) LT 1 THEN PROD=['CHLOR_A']
  IF N_ELEMENTS(METHODS) NE N_ELEMENTS(PROD) THEN STOP
  IF N_ELEMENTS(DIR_IMAGES) LT 1 THEN DIR_IMAGES='D:\IDL\IMAGES\'
	IF N_ELEMENTS(SHOW_MEAN) EQ 0 THEN _SHOW_MEAN=1 ELSE _SHOW_MEAN = SHOW_MEAN
	IF N_ELEMENTS(SHOW_CV)   EQ 0 THEN _SHOW_CV=0   ELSE _SHOW_CV   = SHOW_CV
  IF N_ELEMENTS(OVERWRITE) LT 1 THEN _OVERWRITE = 0 ELSE _OVERWRITE = OVERWRITE
  IF N_ELEMENTS(DIR_DATA) LT 1 THEN DIR_DATA='D:\IDL\DATA\'
  IF N_ELEMENTS(DATE_MIN) LT 1 THEN DATE_MIN = '19790901000000'
	IF N_ELEMENTS(DATE_MAX) LT 1 THEN  DATE_MAX = '20201230235959'

  DAY_LENGTH_LME=[18,19,20,21,54,55,56,57,58,59,60,61]
  YLOG=0
  
  	IF PROD EQ 'CHLOR_A' OR PROD EQ 'PPD' THEN YLOG=1
    PERIODS = DB.PERIOD & DATES = STRMID(PERIOD_2DATE(PERIODS),0,8)
    APERIOD = '!M'
	  
	  JULIAN = (DATE_2JD(DATES) + DATE_2JD(DATES))/2.0 ;

		
	  IF PROD EQ 'PPD' OR PROD EQ 'CHLOR_A' THEN YRANGE=[0.1,30] ; PROD PER DAY
    IF PROD EQ 'CHLOR_A' THEN YRANGE=[0.01,100.0] 

	  XBLANK = REPLICATE(' ',N_ELEMENTS(XJM.TICKNAME))
	  NOTES = MAP
	  PRODUCT_TXT =''
	  IF PROD EQ 'PPD' THEN PRODUCT_TXT = 'PRIMARY PRODUCTIVITY'
	  IF PROD EQ 'CHLOR_A' THEN PRODUCT_TXT = 'CHLOROPHYLL'
	  IF PROD EQ 'PAR' THEN PRODUCT_TXT = ' PAR '
	  IF PROD EQ 'SST' THEN PRODUCT_TXT = 'SURFACE TEMPERATURE'
	  IF PROD EQ 'CHLOR_EUPHOTIC' THEN PRODUCT_TXT = 'CHLOR_EUTHOTIC'
	  IF PROD EQ 'K_PAR' THEN PRODUCT_TXT = 'K_PAR'
;	  TITLE_PAGE = 'TRENDS IN ' + PRODUCT_TXT + ' OF LARGE MARINE ECOSYSTEMS' ;!C'
    TITLE_PAGE =PRODUCT_TXT + ' TRENDS IN LARGE MARINE ECOSYSTEMS' ;!C'
	  
	  JULIAN_MIN = DATE_2JD(DATE_MIN) & JULIAN_MAX = DATE_2JD(DATE_MAX)
	  DATE_TXT = DT_FMT(JULIAN_MIN,/DMY,/MONTH) + ' - ' +  DT_FMT(JULIAN_MAX,/DMY,/MONTH)

	
	  
	 
	   IF KEYWORD_SET(PS) THEN BEGIN	   
  	    PLTFILE = DIR_OUT+ROUTINE_NAME+'-' + PROD + '.PS'
        PSPRINT,/FULL,FILENAME=PLTFILE,/COLOR
     ENDIF;IF KEYWORD_SET(PS) THEN BEGIN
    
	    FONT_HELVETICA
	    !P.CHARSIZE=1.0
	    !P.REGION = 0
	    !Y.OMARGIN=[6,5]
	    !X.OMARGIN=[15,4]	;!X.OMARGIN=[8.5,3.3] CHANGED 8-13-07 BY K. HYDE
	    !Y.MINOR=1
	    !Y.TICKLEN=0.002

    ;===> FIND MEAN FOR EACH SET THEN SORT ON THE MEAN
	  
	  SETS = WHERE_SETS(DB.LME)  
    IF N_ELEMENTS(P_MULTI) LT 1 THEN !P.MULTI=[0,1,N_ELEMENTS(SETS)] ELSE !P.MULTI = [0,1,P_MULTI]
	  ;FFFFFFFFFFFFFFFFFFFFFFFFFFF
	  FOR _LME = 0,N_ELEMENTS(LMES) -1 DO BEGIN
	   LME=LMES(_LME)
	   AMAP = LME.MAP
     OK = WHERE(DB.LME EQ AMAP,COUNT)
     IF COUNT GE 1 THEN BEGIN     
       D=DB[OK]
       SUB_MIN = D.SUB_MIN
       SUB_MAX = D.SUB_MAX
     STOP
     ENDIF;IF COUNT GE 1 THEN BEGIN
	
	  STOP
   


	      POF,_LME,LMES
          LME = LMES(_LME)
	        ACODE = LONG(LME.CODE)
	        OK = WHERE(LONG(LME.CODE) EQ ACODE)
	        ANAME = STRUPCASE(STRTRIM(LME(OK[0]).NAME,2))
	        AMAP = LME(OK[0]).MAP
	        OK_LME = WHERE(STRUPCASE(DB.LME) EQ AMAP,COUNT_LME)
	        IF COUNT_LME EQ 0 THEN STOP

          D = DB(OK_LME)
          ;JD = PERIOD_2JD(D.PERIOD) & JD = JD_2JD(JD,/MONTH,/MID)
          
          SUB_MIN = D.SUB_MIN
          SUB_MAX = D.SUB_MAX          
          X_PLOT = SUB_MIN
          Y_PLOT = D.MEAN	       

	;       ===> COMPUTE STATS ON ALL MONTHS
	        OK = WHERE(Y_PLOT NE MISSINGS(Y_PLOT),COUNT)
	        IF COUNT LT 1 THEN CONTINUE

	        X_PLOT=X_PLOT[OK] & Y_PLOT=Y_PLOT[OK]
	        
	        
	        _STATS =STATS(FLOAT(Y_PLOT),DECIMALS=3,/QUIET,TRANSFORM=TRANSFORM)	        
	        IF N_ELEMENTS(STATS_COLOR) EQ 1 THEN _STATS_COLOR = STATS_COLOR ELSE _STATS_COLOR		= SD_SCALES(_STATS.MEAN  ,PROD=PROD,/DATA2BIN)
	        YSTYLE = 5

	        IF _LME EQ N_ELEMENTS(LMES)-1 THEN BEGIN
	          XTICKNAME=XJM.TICKNAME
	          XTITLE=' '
	        ENDIF ELSE BEGIN
	         XTICKNAME = XBLANK
	         XTITLE=''
	         YTITLE=' '
	        ENDELSE


	;       FORCE MAGNITUDE AND COLOR TO BE WITHIN YRANGE
	        Y_FORCED =   YRANGE[0] >  FLOAT(Y_PLOT) < YRANGE[1]
;
	        XX = X_PLOT   ; DAYS SHIFTED

					AXIS_CHARSIZE=2.25
					IF N_ELEMENTS(XJM.TICKV) GT 15 THEN AXIS_CHARSIZE=1.75
					;STOP
          PLOT,[XX,XX],[Y_FORCED,Y_FORCED],YLOG=YLOG,$
          YSTYLE=YSTYLE,XTICKS=XJM.TICKS,XTICKV=XJM.TICKV,XTICKNAME=XTICKNAME,COLOR = 0,$
	        	 XTITLE=XTITLE,YTITLE=YTITLE,YRANGE=YRANGE,YMARGIN=[0,0], /NODATA ,CHARSIZE=AXIS_CHARSIZE,/NOCLIP


	        BACKGROUND,/PLOT,COLOR=BACKGROUND_COLOR
	;        FRAME,/PLOT, COLOR = 0, THICK=1
	        IF APERIOD NE '!Y' THEN GRIDS,X=XJY.TICKV,COLOR=GRID_COLOR,THICK=1,/NO_Y
	 					GRIDS,X=XJY.TICKV,COLOR=0,/ALL,THICK=3,/NO_Y

     
	        SYMBOL_COLOR= SD_SCALES(Y_FORCED,PROD=PROD,/DATA2BIN,SPECIAL_SCALE='L3B')
          ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	        FOR NTH = 0L,N_ELEMENTS(Y_FORCED)-1 DO BEGIN
;            CIRCLE,8,FILL=1,COLOR=SYMBOL_COLOR[NTH],THICK=7
	          CIRCLE,2,FILL=0,COLOR=SYMBOL_COLOR[NTH],THICK=7
	          DATA_SYMSIZE=0.8
            DATA_SYMSIZE=3.0
            DATA_SYMSIZE=2.0
;            DATA_SYMSIZE=0.2
;	          IF APERIOD EQ '!Y' THEN DATA_SYMSIZE = 1.5
	          IF APERIOD EQ '!Y' THEN DATA_SYMSIZE = 1.5
	          IF NTH EQ 0 THEN PRINT,DATE_FORMAT(JD_2DATE([FIRST(X_PLOT),LAST(X_PLOT)]),/YMD)
	  	      PLOTS,X_PLOT[NTH],Y_FORCED[NTH],PSYM=8 ,/NOCLIP,SYMSIZE=DATA_SYMSIZE
	        ENDFOR;FOR NTH = 0L,N_ELEMENTS(Y_FORCED)-1 DO BEGIN
	        ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

	        XPOS_RIGHT= !X.CRANGE[1] + 14 ; DAYS
	        XPOS_LEFT = !X.CRANGE[0] - 5 ; DAYS
	        IF !Y.TYPE EQ 0 THEN BEGIN
	          YPOS= 0.30*(!Y.CRANGE[1] - !Y.CRANGE[0])+ !Y.CRANGE[0]
	        ENDIF ELSE BEGIN
	        YPOS=	10^(0.5* (!Y.CRANGE[1] - !Y.CRANGE[0]) + !Y.CRANGE[0])
	       ;   YPOS=  10^( !Y.CRANGE(0))
	        ENDELSE
	;       =====> WRITE THE LME NAME IN LEFT COLUMN
	        XYOUTS,XPOS_LEFT,YPOS-0.99,/DATA, ANAME, CHARSIZE=NAME_CHARSIZE, ALIGN = 1.03,WIDTH=CWIDTH,COLOR=0
          ;XYOUTS,XPOS_LEFT,YPOS,/DATA, ANAME, CHARSIZE=NAME_CHARSIZE, ALIGN = 1.0,WIDTH=CWIDTH,COLOR=0
	;       =====> WRITE THE STATS_STRING IN RIGHT COLUMN
          _STATS=STATS(Y_FORCED,DECIMALS=2,/QUIET)
	         TXT = ROUNDS(_STATS.MEAN,2)
	         XYOUTS,XPOS_RIGHT,YPOS-0.99,/DATA, TXT, CHARSIZE=STATS_CHARSIZE,COLOR=_STATS_COLOR
         
					IF _LME EQ N_ELEMENTS(LMES)-1 THEN BEGIN

;     =====> ADD LEGEND
 ;           POS=[!X.WINDOW(0),!Y.WINDOW(0)-10,!X.WINDOW(1),!Y.WINDOW(0)-0]
 ;;           LEG=COLOR_BAR_SCALE(PROD=PROD,/TRIM,PY=95,NOTE_CHARSIZE=2,PS=1,NOTE_POS=POS)
						
						
						
						
;     =====> ADD LEGEND
          POS = [ !X.WINDOW[0],0.970, !X.WINDOW[1], 0.980]  
				  LEG=COLOR_BAR_SCALE(PROD=PROD,/TRIM,PY=95,/PS,CHARSIZE=TITLE_PAGE_CHARSIZE,POS=POS)
            
				    TXT = "J.E. O'Reilly"
			;	    TXT = TXT +   ',  SEAWIFS CHLOROPHYLL, SEAWIFS PAR, AVHRR SST (JPL)'
;				    XYOUTS, 0.5, 0.002,/NORMAL, TXT, ALIGN=0.3,CHARSIZE=NAME_CHARSIZE*0.75
;            XYOUTS, 0.5, 0.001,/NORMAL, TXT, ALIGN=0.3,CHARSIZE=NAME_CHARSIZE*1.25
            XYOUTS, 0.90, 0.001,/NORMAL, TXT, ALIGN=0.3,CHARSIZE=NAME_CHARSIZE*0.75
				    XYZ=CONVERT_COORD(XPOS_RIGHT,YPOS,/DATA,/TO_NORMAL)
				    TXT=''
				    IF _SHOW_MEAN THEN TXT = 'MEAN'
				    IF _SHOW_MEAN AND _SHOW_CV THEN TXT = 'MEAN  CV'
				    XYOUTS,XYZ[0],0.95,/NORMAL, TXT,COLOR=0,CHARSIZE=STATS_CHARSIZE,ALIGN= 0.25
					ENDIF

	      ENDFOR;FOR _LME = 0,N_ELEMENTS(LMES) -1 DO BEGIN
	      
	      XYOUTS, 0.55, 1.05,/NORMAL, TITLE_PAGE, ALIGN=0.5,CHARSIZE=TITLE_PAGE_CHARSIZE
	      
        IF KEYWORD_SET(PS) THEN PSPRINT
       
        PRINT 
        PFILE,PLTFILE,/W
      

 

 
END; #####################  END OF ROUTINE ################################
