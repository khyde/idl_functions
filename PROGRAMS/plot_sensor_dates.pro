; $ID:	PLOT_SENSOR_DATES.PRO,	2020-07-08-15,	USER-KJWH	$

  PRO PLOT_SENSOR_DATES, DATASETS, DATERANGE=DATERANGE, DELAY=DELAY, TEMP=TEMP, BUFFER=BUFFER, OVERWRITE=OVERWRITE

;+
; NAME:
;   PLOT_SENSOR_DATES
;
; PURPOSE:
;   This procedure plots the number of files for a given sensor/dataset
;
; CATEGORY:
;   GRAPHICS
;
; CALLING SEQUENCE:
;   PLOT_SENSOR_DATES, DATASETS, DATERANGE=DATERANGE
;
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUTS:
;   DATASETS............ The name of the DATASETS (i.e. sensors) to plot
;   DATERANGE........... The start and end date of the plots
;   DELAY............... The amount of time to keep a temporary plot open before closing and continuing
;
; KEYWORD PARAMETERS:
;   TEMP................ To create a temporary plot that is not saved
;   BUFFER.............. To control the graphics buffer
;   OVERWRITE........... Overwrite an existing plot
;
; OUTPUTS:
;   This procedure creates a series of plots showing the number of files for a given dataset/sensor
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
; 
; SIDE EFFECTS:  
;   None 
;   
; RESTRICTIONS:  
;   New datasets/sensors will need to be added to the default list and CASE block
;
; EXAMPLE:
;   PLOT_SENSOR_DATES,'MODISA',DATERANGE=['20190101','20201231']
;   
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 18, 2011 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882   
;
; MODIFICATION HISTORY:
;	  Apr 18, 2011 - KJWH: Wrote initial code
;	  Dec 29, 2015 - KJWH: Added SWITCHES information 
;		Aug 01, 2018 - KJWH: Added COPYRIGHT
;		Dec 01, 2020 - KJWH: Updated documentation
;		                     Added COMPILE_OPT IDL2
;		                     Added an optional DATASETS (sensor) input
;		                     Changed subscript () to []
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PLOT_SENSOR_DATES'
	COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(DATASETS) EQ 0 THEN DATASETS = ['SEAWIFS','MODISA','MODIST','VIIRS','JPSS1','AVHRR','MUR','OCCCI'];,'HERMES']
	DIRS     = ['OC','SST'];,'FRONTS']
	LEVELS   = ['L1A','L2','L3B2','L3B4','L3B9','L4']
	MAPS     = ['L3B2','L3B4','L3B9']
	
	IF NONE(BUFFER) THEN BUFFER = 1
	IF KEYWORD_SET(TEMP) THEN BEGIN
	  BUFFER = 0
	  IF N_ELEMENTS(DELAY) NE 1 THEN DELAY = 10
	ENDIF
	
	
	COLORS = ['RED','BLUE','GREEN','ORANGE','CYAN']
	HT = 140
	SP = 20

	FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
	  DATASET = DATASETS[N]
	  SDATES = SENSOR_DATES(DATASET)                                                      ; Get the SENSOR daterange
	  IF ANY(DATERANGE) THEN DTR = GET_DATERANGE(DATERANGE) ELSE DTR = ['19780101','21001231']
	  IF DTR[0] LT SDATES[0] THEN DTR[0] = SDATES[0]                                      ; If default start date (19810101), then change to the sensor start date
	  IF DTR[1] GT SDATES[1] THEN DTR[1] = SDATES[1]                                      ; If default end date (21001231), then change to the sensor end date
	  DTR = GET_DATERANGE(DTR)                                                            ; Make sure the daterange has complete dates (e.g. convert 2019_2020 to 20190101_20201231)
	  AX = DATE_AXIS([DTR[0],DTR[1]],/MONTH,STEP_SIZE=6)                                  ; Create the date axis from the date range
	  
	  FOR S=0, N_ELEMENTS(DIRS)-1 DO BEGIN
	    CASE DIRS[S] OF
	      'OC':     PRODS = ['CHL','RRS','PAR','IOP','KD490']
	      'SST':    PRODS = ['SST','SST4']
	      'FRONTS': PRODS = ['GRAD_CHL-BOA','GRAD_SST-BOA']
	    ENDCASE
	    
	    PLTDIR = !S.DATASETS + DIRS[S] + SL + DATASET + SL + 'SENSOR_DATE_PLOTS' + SL     ; Output plot directory
	    DIR_TEST, PLTDIR                                                                  ; Make directory if it does not exist
	    FOR L=0, N_ELEMENTS(LEVELS)-1 DO BEGIN
    	  DIR = !S.DATASETS + DIRS[S] + SL + DATASET + SL + LEVELS[L] + SL + 'NC' + SL
    	  IF FILE_TEST(DIR,/DIR) EQ 0 THEN CONTINUE                                       ; Check to see if the directory exists
    	   
    	  FILES = FILE_SEARCH(DIR + '*.*',COUNT=COUNTP)                                   ; Look for files in the directory
    	  FILES = DATE_SELECT(FILES,DTR)
    	  IF COUNTP GE 1 THEN BEGIN
    	    P, NUM2STR(COUNTP) + ' files in ' + DIR
    	    PNGFILE = PLTDIR + STRJOIN([DATASET,LEVELS[L]],'-') + '.png'                  ; Create the output PNG file name
    	    IF FILE_MAKE(FILES,PNGFILE,OVERWRITE=OVERWRITE) EQ 0 AND ~KEYWORD_SET(TEMP) THEN CONTINUE ; Check to see if the PNG file should be recreated
    	    FP = PARSE_IT(FILES)                                                          ; Parse file names to get date info
    	    BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))                ; Determine the number of files per day
    	    
    	    TITLE = STRJOIN([DATASET,LEVELS[L]],'-')                                      ; Make a title for the plot
    	    W = WINDOW(DIMENSIONS=[1000,400],BUFFER=BUFFER)                               ; Create a graphics window for the plots
    	    PLT = PLOT(AX.JD,[0,MAX(BSET.N)],/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=5, /CURRENT,XRANGE=AX.JD,YRANGE=NICE_RANGE([0,MAX(BSET.N+2)]),TITLE=TITLE,MARGIN=[0.05,0.15,0.025,0.2])
    	    PLT = PLOT(YDOY_2JD(STRMID(BSET.VALUE,0,4),STRMID(BSET.VALUE,4,3)),BSET.N,/CURRENT,/OVERPLOT,CLIP=0,SYMBOL='CIRCLE',/SYM_FILLED,COLOR='BLUE',THICK=2,SYM_SIZE=0.75)
          IF ~KEYWORD_SET(TEMP) THEN W.SAVE, PNGFILE ELSE WAIT, DELAY
          W.CLOSE
          CONTINUE
    	  ENDIF 
    	  
      	W = []
      	FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN                                            ; Loop through product sub-directories
      	  PROD = PRODS[P]
      	  FILES = FILE_SEARCH(DIR + PROD + SL + '*.*',COUNT=COUNTP)                      ; Find files in the sub-directories
      	  FILES = DATE_SELECT(FILES,DTR)
    	    P, NUM2STR(COUNTP) + ' files in ' + DIR + PROD + SL
    	    IF P EQ 0 THEN PNGFILE = PLTDIR + STRJOIN([DATASET,LEVELS[L],PROD],'-') ELSE PNGFILE = PNGFILE + '_' + PROD
    	    
    	    TITLE = STRJOIN([DATASET,LEVELS[L],PROD],'-') + ' (N = ' + NUM2STR(COUNTP) + ')
    	    IF W EQ [] THEN W = WINDOW(DIMENSIONS=[1000,200*N_ELEMENTS(PRODS)],BUFFER=BUFFER)
    	    PLT = PLOT(AX.JD,[0,2],/NODATA,XTICKNAME=AX.TICKNAME, XTICKVALUE=AX.TICKV, XMINOR=5,LAYOUT=[1,N_ELEMENTS(PRODS),P+1], /CURRENT,XRANGE=AX.JD,YRANGE=NICE_RANGE([0,2]),TITLE=TITLE,MARGIN=[0.05,0.15,0.025,0.2])
    	    IF COUNTP GT 0 THEN BEGIN
      	    FP = PARSE_IT(FILES)                                            ; Parse file names to get date info
      	    BSET = WHERE_SETS(FP.YEAR_START+DATE_2DOY(FP.DATE_START,/PAD))  ; Determine the number of files per day
      	    DR = CREATE_DATE(MIN(FP.DATE_START),MAX(FP.DATE_END),/DOY)
      	    OK = WHERE_MATCH(BSET.VALUE,DR,VALID=VALID)
      	    ARR = REPLICATE(0,N_ELEMENTS(DR))
            ARR[VALID] = BSET[OK].N
      	    PLT = PLOT(YDOY_2JD(STRMID(DR,0,4),STRMID(DR,4,3)),ARR,/CURRENT,/OVERPLOT,CLIP=0,SYMBOL='CIRCLE',COLOR='GREY',SYM_COLOR='BLUE',THICK=3,SYM_SIZE=0.05)
          ENDIF ; COUNT FILES
        ENDFOR ; PROD
        IF W NE [] THEN BEGIN
          IF ~KEYWORD_SET(TEMP) THEN W.SAVE, PNGFILE + '.png' ELSE WAIT, DELAY
          W.CLOSE  
        ENDIF  
    	ENDFOR ; LEVEL
    ENDFOR ; DIR
  ENDFOR ; DATASET
	
	


END; #####################  End of Routine ################################
