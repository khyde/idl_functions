; $ID:	MAPS_COASTLINE_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$

  PRO MAPS_COASTLINE_DEMO

;+
; NAME:
;   MAPS_COASTLINE_DEMO
;
; PURPOSE:
;   This procedure is a demo for MAPS_COASTLINE
;
; CATEGORY:
;   MAPS
;
; CALLING SEQUENCE:
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
;			Written:  MAR 23, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: MAR 25, 2016 - KJWH: Added EC, GEQ, ANTARCTICA_J and SOUTH_BRAZIL_SHELF_J maps
;			                               Now looping through MAPS
;			                               Added ANTARCTICA ICE vs GROUND example  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MAPS_COASTLINE_DEMO'
	
	SL = PATH_SEP()
	DIR = !S.DEMO + ROUTINE_NAME + SL & DIR_TEST, DIR
	PAL_LANDMASK, R, G, B
	
	
	;===> #####   SWITCHES
	DO_NEC                  = 'Y'
	DO_EC                   = 'Y'
	DO_GEQ                  = 'Y'
	DO_ANTARCTICA_J         = 'Y'
	DO_SOUTH_BRAZIL_SHELF_J = 'Y'

  DO_MAPS = [ DO_NEC,  DO_EC,  DO_GEQ,  DO_ANTARCTICA_J,  DO_SOUTH_BRAZIL_SHELF_J]
  SNAMES  = ['DO_NEC','DO_EC','DO_GEQ','DO_ANTARCTICA_J','DO_SOUTH_BRAZIL_SHELF_J'] 

;WINDOW, /FREE, XSIZE=1024, YSIZE=1024
;map_set, 40, -75, conic=1,standard_parallels=[36.1667,43.8333],scale=4251828.0,isotropic=1,position=[0.0,0.0,1.0,1.0],/NOERASE
;MAPS_COASTLINE, land_COLOR=!d.table_size - 1
;
;STOP


  FOR NTH=0, N_ELEMENTS(DO_MAPS)-1 DO BEGIN
    IF DO_MAPS[NTH] EQ '' THEN CONTINUE
    SNAME = SNAMES[NTH]
    AMAP = STRMID(SNAME,3)
    SWITCHES,DO_MAPS[NTH],STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
    IF VERBOSE THEN PRINT, 'Running: ' + SNAME 
    IF KEY(STOPP) THEN STOP

    PNGFILE = DIR + AMAP + '-NO_KEYWORD_OPTIONS.PNG'
	  IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
  	  MAPS_SET, AMAP
  	  MAPS_COASTLINE  ; Defaults to HIGH resolution and plotting just the land
  	  IMG = TVRD()
  	  ZWIN
  	  WRITE_PNG, PNGFILE, IMG, R,G,B 
    ENDIF
	  
	  PNGFILE = DIR + AMAP + '-LAND.PNG'
	  IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
  	  MAPS_SET, AMAP
  	  MAPS_COASTLINE, /ADD_LAND
  	  IMG = TVRD()
  	  ZWIN
  	  WRITE_PNG, PNGFILE, IMG, R,G,B
    ENDIF
    
    PNGFILE = DIR + AMAP + '-LAND_COAST.PNG'
    IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
      MAPS_SET, AMAP
      MAPS_COASTLINE, /ADD_LAND,/ADD_COAST
      IMG = TVRD()
      ZWIN
      WRITE_PNG, PNGFILE, IMG, R,G,B
    ENDIF
    
    PNGFILE = DIR + AMAP + '-LAND_COAST_ISLANDS.PNG'
    IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
      MAPS_SET, AMAP
      MAPS_COASTLINE, /ADD_LAND,/ADD_COAST,/ISLANDS
      IMG = TVRD()
      ZWIN
      WRITE_PNG, PNGFILE, IMG, R,G,B
    ENDIF
    
    PNGFILE = DIR + AMAP + '-LAND_COAST_LAKES.PNG'
    IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
      MAPS_SET, AMAP
      MAPS_COASTLINE,'FULL',/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_LAKE_SIDE  ; Add lakes and the lake side
      IMG = TVRD()
      ZWIN
      WRITE_PNG, PNGFILE, IMG, R,G,B
    ENDIF
    
    PNGFILE = DIR + AMAP + '-LAND_COAST_LAKES_SMALL_LAKES.PNG'
    IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
      MAPS_SET, AMAP
      MAPS_COASTLINE,'FULL',/ADD_LAND,/ADD_COAST,/ADD_LAKES,/ADD_LAKE_SIDE,/ADD_SMALL_LAKES,/ADD_SMALL_LAKE_SIDE  ; Add the small lake side, but don't fill in
      IMG = TVRD()
      ZWIN
      WRITE_PNG, PNGFILE, IMG, R,G,B
    ENDIF
    
    RESOLUTIONS = ['FULL','HIGH','INTERMEDIATE','LOW','CRUDE']
    FOR N=0, N_ELEMENTS(RESOLUTIONS)-1 DO BEGIN
      RES = RESOLUTIONS(N)
      PNGFILE = DIR + AMAP + '-LAND_COAST-RES_' + RES + '.PNG'
      IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
        MAPS_SET, AMAP
        MAPS_COASTLINE,RES,/ADD_LAND,/ADD_COAST
        IMG = TVRD()
        ZWIN
        WRITE_PNG, PNGFILE, IMG, R,G,B
      ENDIF
    ENDFOR  
    
    IF AMAP EQ 'GEQ' OR AMAP EQ 'ANTARCTICA_J' OR AMAP EQ 'SOUTH_BRAZIL_SHELF_J' THEN BEGIN
      PNGFILE = DIR + AMAP + '-LAND_COAST-ANTARCTICA_ICE.PNG'
      IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
        MAPS_SET, AMAP
        MAPS_COASTLINE,/ADD_LAND,/ADD_COAST,ANTARCTICA='ICE'
        IMG = TVRD()
        ZWIN
        WRITE_PNG, PNGFILE, IMG, R,G,B
      ENDIF
      PNGFILE = DIR + AMAP + '-LAND_COAST-ANTARCTICA_GROUND.PNG'
      IF EXISTS(PNGFILE) EQ 0 OR OVERWRITE EQ 1 THEN BEGIN
        MAPS_SET, AMAP
        MAPS_COASTLINE,/ADD_LAND,/ADD_COAST,ANTARCTICA='GROUND'
        IMG = TVRD()
        ZWIN
        WRITE_PNG, PNGFILE, IMG, R,G,B
      ENDIF
    ENDIF
    	  
	  IF VERBOSE THEN , SNAME
	ENDFOR
		


END; #####################  End of Routine ################################
