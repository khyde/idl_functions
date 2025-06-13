; $ID:	SETEX_MAIN.PRO,	2020-07-01-12,	USER-KJWH	$

  PRO SETEX_MAIN

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This procedure is the MAIN routine for the SET-EX (RI Sound/Narragansett Bay) project
;
; CATEGORY:
;   PROJECT MAIN
;
; NOTES:
;   This routine will display better if you set your tab to 2 spaces:
;   (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;   Citations or any other useful notes
;   
;   SWITCHES governs which processing steps to do and what to do in the step
;     '' (NULL STRING) = do not do the step
;        ANY ONE OR COMBINATION OF LETTERS WILL RUN THE STEP:
;     Y  = YES do the step
;     O  = OVERWRITE any output
;     V  = VERBOSE (allow PRINT statements)
;     RF = REVERSE the processing order of files in the step
;     S  = STOP at the beginning of the step and step through each command in the step
;     DATERANGE = Daterange for selecting files
;
; MODIFICATION HISTORY:
;			Written:  September 20, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			SEP 21, 2016 - Updated FIGURE 1 step 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SETEX_MAIN'
	
; ===> DEFAULTS
  SL = PATH_SEP()	
	
; ===> SWITCHES
	DO_FIGURE1       = 'Y'  ; 9/20/2016 - Create a sample MERIS image to be used in the proposal

; ===> DIRECTORIES
  DIR_PROJECTS = !S.PROJECTS  + 'SETEX'   + SL
  DIR_SATDATA  = DIR_PROJECTS + 'SATDATA' + SL
  DIR_DATA     = DIR_PROJECTS + 'DATA'    + SL
  DIR_DOC      = DIR_PROJECTS + 'DOC'     + SL
  DIR_FIGS     = DIR_PROJECTS + 'FIGURES' + SL
  DIR_IMAGES   = DIR_PROJECTS + 'IMAGES'  + SL
  
  DIR_TEST, [DIR_SATDATA,DIR_DATA,DIR_DOC,DIR_FIGS,DIR_IMAGES]	


; *****************************
	IF KEY(DO_FIGURE1) THEN BEGIN
; *****************************
	  SNAME = 'DO_FIGURE1'
    SWITCHES,DO_FIGURE1,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
    IF VERBOSE THEN PRINT, 'Running: ' + SNAME
	  IF KEY(STOPP) THEN STOP
	  
	  PRODS = ['rrs_443','latitude','longitude']
	  FOR I=0, N_ELEMENTS(PRODS)-1 DO BEGIN
	    F = DIR_SATDATA + 'M2005248_' + PRODS(I) + '.txt'
	    C = DIR_SATDATA + 'M2005248_' + PRODS(I) + '.csv'
	    IF FILE_MAKE(F,C,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
	    TXT = READ_TXT(F)
	    R = STRSPLIT(STRCOMPRESS(TXT[0]),' ',/EXTRACT)
	    ARR = FLTARR(N_ELEMENTS(TXT),N_ELEMENTS(R)) & ARR(*) = MISSINGS(0.0)
	    FOR N=0, N_ELEMENTS(RRS)-1 DO BEGIN
	      ROW = STRSPLIT(STRCOMPRESS(RRS(N)),' ',/EXTRACT)
	      OK = WHERE(ROW EQ -32767,COUNT)
	      IF PRODS(P) EQ 'rrs_443' THEN ROW = FLOAT(ROW)*2E-6+0.05
	      ROW[OK] = MISSINGS(0.0)
	      ARR(N,*) = ROW
	    ENDFOR
	    WRITE_CSV, C, ROTATE(ARR,3)
	  ENDFOR
	  
	  R = READ_CSV(DIR_SATDATA + 'M2005248_rrs_443.csv')
	  RARR = FLTARR(N_TAGS(R),N_ELEMENTS(R.(0)))
	  FOR N=0, N_TAGS(R)-1 DO RARR(N,*) = FLOAT(R.(N))
	STOP  
	  RI = MAPS_REMAP(CHL,MAP_IN='LONLAT',MAP_OUT='RI_SOUND',CONTROL_LONS=LON,CONTROL_LATS=LAT)
	  
	;  D = READ_NC(FILE[0])
	;  ST, D.SD
	  
	  SAVE_MAKE_L2,FILE,PRODS='chlor_a',DIR_OUT=dir_satdata,MAP_OUT=['NEC','RI_SOUND'],OVERWRITE=OVERWRITE,/GET_AREA,MAP_ONLY=MAP_ONLY
	  ;m = maps_remap(d.sd.chlor_a.image,map_in='lonlat',map_out='ri_sound',control_lons=d.sd.longitude.image, control_lats=d.sd.latitude.image)
	  
	  STOP
	  
	  IF VERBOSE THEN , SNAME
	ENDIF ; DO_FIGURE1 
	


END; #####################  End of Routine ################################
