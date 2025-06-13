; $ID:	RADTRAN_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;
	PRO RADTRAN_DEMO, ERROR = error

;+
; NAME:
;		RADTRAN_DEMO
;
; PURPOSE:
;		This IS A DEMO FOR RADTRAN.PRO
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   A PLOT
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:	 If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
;	PROCEDURE:
;			This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written AUGUST 3, 2010,J.O'Reilly,, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'RADTRAN_DEMO'
  DOYS= [DATE_2DOY('20000101'),DATE_2DOY('20000321'),DATE_2DOY('20000621'),DATE_2DOY('20000921'),DATE_2DOY('20001221'),DATE_2DOY('20001231')]
;  SWITCHES

  DO_LONLATS    = 1
  DO_DAILY_PAR  = 0
  DO_DAILY_ED   = 0
  
  IF DO_LONLATS GE 1 THEN BEGIN
    LAT  = [ 40.0, 40.5, 41.0, 41.5, 42.0]
    LON  = [-70.0,-69.5,-69.0,-68.5,-68.0]    
    DOY  = 172
    HR   = 17    
    WAVELENGTHS   = NUM2STR([362,386,412,421,443,435,490,468,510,547,555,670])        
    RADTRAN,LON=LON,LAT=LAT,DOY=DOY,HR=HR,STRUCT=STRUCT,WAVELENGTHS=WAVELENGTHS,/QUIET    
    ST, STRUCT
    ST, STRUCT.(0)
    PRINT, STRUCT.(0).ED
  ENDIF


IF DO_DAILY_PAR GE 1 THEN BEGIN
;  DOYS= [172]
  SLIDEW,[1024,800]
  SET_PMULTI, N_ELEMENTS(DOYS)
  
  HRS= INTERVAL([0,24.],0.25)
  YS=FLTARR(N_ELEMENTS(HRS))
  FOR MTH=0,N_ELEMENTS(DOYS)-1 DO BEGIN
  
  ADOY= DOYS(MTH)
  YY = FLTARR(N_ELEMENTS(HRS))
    FOR NTH=0,  N_ELEMENTS(HRS)-1 DO BEGIN
    
    AHR = HRS[NTH]
  ;  RADTRAN,LON=LON,LAT=LAT,DOY=DOY,HR=HR,SUNZEN=SUNZEN,ED= ED,PAR=PAR
       RADTRAN, LON= -70,LAT=44.0,DOY=ADOY,HR =AHR, SUNZEN= -99,PAR = PAR
       YY[NTH]=PAR
    
    ENDFOR
;  TITLE= 'DOY= '+ STRING(ADOY)+ '   ' + ROUNDS(TOTAL(Y)*SECONDS_DAY()*1E-8)+ '  ' +UNITS('EMD')
;  TITLE= 'DOY= '+ ROUNDS(ADOY)+ '   ' + ROUNDS(PAR)+ '  ' +UNITS('EMD')
  TITLE= 'DOY= '+ ROUNDS(ADOY)+ '  DAILY PAR:' + ROUNDS(TOTAL(YY)*1E-3)+ '' + UNITS('EMD')
  
  
;    TITLE= 'DOY='+NUM2STR(ADOY)+ ROUNDS(TOTAL(Y)*SECONDS_DAY()*1E-8)+UNITS('EMD')
  
  PLOT,HRS,YY,XTITLE = 'HOUR',YTITLE= 'PAR'+UNITS('EMS'),TITLE=TITLE,CHARSIZE=2
  GRIDS
  
  GRIDS
  
 ENDFOR; FOR MTH=0,N_ELEMENTS(DOYS)-1 DO BEGIN
ENDIF ;IF DO_DAILY_PAR GE 1 THEN BEGIN


IF DO_DAILY_ED GE 1 THEN BEGIN
;  DOYS= [172]
  SLIDEW,[1024,800]
  SET_PMULTI, N_ELEMENTS(DOYS)
  
  HRS= INTERVAL([0,24.],0.25)
  YS=FLTARR(N_ELEMENTS(HRS))
  FOR MTH=0,N_ELEMENTS(DOYS)-1 DO BEGIN
  
  ADOY= DOYS(MTH)
  YY = FLTARR(N_ELEMENTS(HRS))
    FOR NTH=0,  N_ELEMENTS(HRS)-1 DO BEGIN
    
    AHR = HRS[NTH]
  ;  RADTRAN,LON=LON,LAT=LAT,DOY=DOY,HR=HR,SUNZEN=SUNZEN,ED= ED,ED=ED
       RADTRAN, LON= -70,LAT=44.0,DOY=ADOY,HR =AHR, SUNZEN= -99,ED = ED
       YY[NTH]=ED
    
    ENDFOR
;  TITLE= 'DOY= '+ STRING(ADOY)+ '   ' + ROUNDS(TOTAL(Y)*SECONDS_DAY()*1E-8)+ '  ' +UNITS('EMD')
;  TITLE= 'DOY= '+ ROUNDS(ADOY)+ '   ' + ROUNDS(ED)+ '  ' +UNITS('EMD')
  TITLE= 'DOY= '+ ROUNDS(ADOY)+ '   '+ 'ED: ' + ROUNDS(TOTAL(YY)*1E-2) + UNITS('WATTSM2',/NO_NAME)
  
  
;    TITLE= 'DOY='+NUM2STR(ADOY)+ ROUNDS(TOTAL(Y)*SECONDS_DAY()*1E-8)+UNITS('EMD')
  
  PLOT,HRS,YY,XTITLE = 'HOUR',YTITLE= 'ED'+UNITS('WATTSM2'),TITLE=TITLE,CHARSIZE=2
  GRIDS
  
  GRIDS
  
 ENDFOR; FOR MTH=0,N_ELEMENTS(DOYS)-1 DO BEGIN
ENDIF ;IF DO_DAILY_ED GE 1 THEN BEGIN


END ; #####################  End of Routine ################################
