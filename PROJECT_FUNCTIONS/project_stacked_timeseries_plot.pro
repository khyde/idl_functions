; $ID:	PROJECT_STACKED_TIMESERIES_PLOT.PRO,	2023-09-19-09,	USER-KJWH	$
  PRO PROJECT_STACKED_TIMESERIES_PLOT, VERSION_STRUCT, BUFFER=BUFFER, OVERWRITE=OVERWRITE

;+
; NAME:
;   PROJECT_STACKED_TIMESERIES_PLOT
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   PROJECT_FUNCTIONS
;
; CALLING SEQUENCE:
;   PROJECT_STACKED_TIMESERIES_PLOT,VERSTR
;
; REQUIRED INPUTS:
;   VERSION_STRUCT.......... The version structure for the SOE
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 21, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 21, 2023 - KJWH: Initial code written - adapted from SOE_STACKED_TIMESERIES_PLOT
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PROJECT_STACKED_TIMESERIES_PLOT'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(VERSION_STRUCT) THEN MESSAGE, 'ERROR: Must provide the SOE VERSION structure'
  IF ~N_ELEMENTS(BUFFER) THEN BUFFER=0

  VERSTR = VERSION_STRUCT

  MINDATE = '21000101000000'
  MAXDATE = '21010101000000'
  AX = DATE_AXIS([MINDATE,MAXDATE], /FYEAR)
  X2TICKNAME = REPLICATE(' ',N_ELEMENTS(AX.TICKNAME))
  YTICKNAMES=[' ',' ',' ']
  CHARSIZE = 11
  MARGIN = [0.03,0.0,0.11,0.0]
   
  IPRODS = TAG_NAMES(VERSTR.PROD_INFO)
  PERIOD = 'W'
  
  IF ~N_ELEMENTS(DATFILE) THEN DATFILE = VERSTR.INFO.DATAFILE 
  FULLSTRUCT = IDL_RESTORE(DATFILE) 
  FULLSTRUCT[WHERE(FULLSTRUCT.MATH EQ 'STACKED_STATS')].MATH = 'STATS'
  FULLSTRUCT[WHERE(FULLSTRUCT.MATH EQ 'STACKED_ANOMS')].MATH = 'ANOM'
  STRUCT = FULLSTRUCT[WHERE(FULLSTRUCT.PERIOD_CODE EQ PERIOD AND FULLSTRUCT.MATH EQ 'STATS',/NULL)]
  ASTRUCT = FULLSTRUCT[WHERE(FULLSTRUCT.PERIOD_CODE EQ PERIOD AND FULLSTRUCT.MATH EQ 'ANOM',/NULL)]
  
  DP = PERIOD_2STRUCT(STRUCT.PERIOD)
  
  IF ~N_ELEMENTS(PRODS) THEN SPRODS = VERSTR.INFO.STACKED_PRODS
  IF ~N_ELEMENTS(DIR_PLOTS) THEN DIR_PLT = VERSTR.DIRS.DIR_PLOTS+'STACKED_TIMESERIES'+SL ELSE DIR_PLT = DIR_PLOTS & DIR_TEST, DIR_PLT
  SHAPES = VERSTR.SHAPEFILES
  MP = VERSTR.INFO.MAP_OUT
  DR = VERSTR.INFO.DATERANGE
  YEARS = YEAR_RANGE(DR,/STRING)
  NYEARS = N_ELEMENTS(YEARS)
 
  FOR S=0, N_ELEMENTS(SPRODS)-1 DO BEGIN
    PRODS = SPRODS[S]
    NPRODS = N_ELEMENTS(PRODS)
    
    FOR H=0, N_ELEMENTS(SHAPES)-1 DO BEGIN ; Shapefile loop
      SHAPE = VERSTR.SHAPEFILES.(H)
      NAMES = SHAPE.SUBAREA_NAMES
      TITLES = SHAPE.SUBAREA_TITLES
      
      FOR N=0, N_ELEMENTS(NAMES)-1 DO BEGIN
        ANAME = NAMES[N]
        TITLE = TITLES[N]
        
        IF N_ELEMENTS(PRODS) GT 1 THEN N_PLOTS = NYEARS*NPRODS + NPRODS*3 ELSE N_PLOTS = N_ELEMENTS(YEARS) + 3
        YDIM = 20
        DIMENSIONS = [800,N_PLOTS*YDIM]
        WHILE DIMENSIONS[1] GT 1000 DO DIMENSIONS = [800,N_PLOTS*YDIM--]
         
        LAYOUT=[1,N_PLOTS,1]
  
        PNGFILE = DIR_PLT + PERIOD + '_' + MIN(YEARS) + '_' + MAX(YEARS) + '-' + ANAME + '-' + STRJOIN(PRODS,'_') +'-STACKED_TIMESERIES.PNG'
        IF ~FILE_MAKE(DATFILE,PNGFILE,OVERWRITE=OVERWRITE) THEN CONTINUE
        
        W = WINDOW(DIMENSIONS=DIMENSIONS,LAYOUT=LAYOUT,BUFFER=BUFFER)
        TXT = TEXT(0.5,0.98,TITLE,ALIGNMENT=0.5,FONT_SIZE=FONT_SIZE,FONT_STYLE='BOLD')      
        
        COUNTER = 3
        FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
          APROD = PRODS[R]
          ATAG = []
          IF STRPOS(APROD,'ANOM') GE 0 THEN BEGIN
            STR = ASTRUCT
            APROD = VALIDS('PRODS',APROD)
            PSTR = VERSTR.PROD_INFO.(WHERE(IPRODS EQ APROD))
            SPROD = PSTR.ANOM_GRID_SCALE
            PAL = PSTR.ANOM_PAL
            PTAG = 'AMEAN'
            PROD_TITLE=PSTR.ANOM_TITLE
          ENDIF ELSE BEGIN
            STR = STRUCT
            PSTR = VERSTR.PROD_INFO.(WHERE(IPRODS EQ APROD))
            SPROD = PSTR.GRID_SCALE
            PAL = PSTR.GRID_PAL
            PTAG = PSTR.PLOT_TAG & IF ATAG NE [] THEN PTAG = ATAG
            PROD_TITLE=UNITS(APROD)
          ENDELSE
          
          NSTR = STR[WHERE(STR.PROD EQ APROD AND STR.SUBAREA EQ NAMES[N],/NULL)]
    
          MARGIN = [0.06,0.0,0.15,0.0]
          LAYOUT[2] = COUNTER
          STACKED_GRIDDED_TIMESERIES, NSTR, PTAG, YEARS=YEARS, OBJ=W, LAYOUT=LAYOUT,PROD=SPROD, PAL=PAL, MARGIN=MARGIN, /CURRENT,/ADD_CB, CB_POS=CB_POS, CB_TYPE=5, CB_TITLE=PROD_TITLE
    
          COUNTER = COUNTER + NYEARS+2
   
        ENDFOR ; PRODS
       
        W.SAVE, PNGFILE, BIT_DEPTH=2
        W.CLOSE     
        PFILE, PNGFILE
      ENDFOR ; NAMES
    ENDFOR ; SHAPES
  ENDFOR ; SPRODS  
        
      
  
  
  
  
  


END ; ***************** End of PROJECT_STACKED_TIMESERIES_PLOT *****************
