; $ID:	JUNK_OISST.PRO,	2020-07-08-15,	USER-KJWH	$
PRO JUNK_OISST
  SL = PATH_SEP()
  DIR = !S.OISST + 'V2' + SL + 'SOURCE' + SL + 'NC' + SL 
  
  MP = 'NWA'
  APER = '1991_2020'
  ALABEL = 'OISST-'+MP+'-SST-ANOM.SAV'
  MLABEL = 'OISST-'+MP+'-SST.SAV'
  MONTHS = MONTH_RANGE(/STRING)
  ADIR = !S.OISST + 'V2' + SL + MP + SL + 'ANOMS_LTM' + SL & DIR_TEST, ADIR
  MDIR = !S.OISST + 'V2' + SL + MP + SL + 'STATS_MEAN' + SL & DIR_TEST, MDIR
  PADIR = !S.OISST + 'V2' + SL + MP + SL + 'ANOMS_LTM_PNGS' + SL & DIR_TEST, PADIR
  PMDIR = !S.OISST + 'V2' + SL + MP + SL + 'STATS_PNGS' + SL & DIR_TEST, PMDIR
  
  YEAR = '2024'
  FYR = DIR+'SST'+SL+'sst.day.mean.'+YEAR+'.nc'
  FLT = DIR+'SST_LTM'+SL+'sst.day.mean.ltm.1991-2020.nc'
  
  SAVES = ADIR + 'M_'+YEAR+MONTHS+'-'+'MONTH_'+MONTHS+'-'+APER+'-'+ALABEL
  
  SUBAREA = 'NES_EPU_NOESTUARIES'
  STRUCT = READ_SHPFILE(SUBAREA, MAPP=MP, ATT_TAG=ATT_TAG, COLOR=COLOR, VERBOSE=VERBOSE, NORMAL=NORMAL, AROUND=AROUND)
  SHPS=STRUCT
  EPU_OUTLINE = []
  NAMES = ['GOM','GB','MAB']
  FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
    POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
    EPU_OUTLINE = [EPU_OUTLINE,SHPS.(POS).OUTLINE]
  ENDFOR
  
  IF FILE_MAKE([FYR,FLT],SAVES,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN  
    S = READ_NC(FYR) 
    SST = S.SD.SST.IMAGE
    DATES = DAYS1800_2JD(S.SD.TIME.IMAGE)
    L = READ_NC(FLT) 
    LTM = L.SD.SST.IMAGE
    LDATES = JD_ADD(DAYS1800_2JD(L.SD.TIME.IMAGE),FIX(YEAR) - (DATE_PARSE(DAYS1800_2JD(L.SD.TIME.IMAGE[0]))).YEAR,/YEAR)
        
    FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
      AMON = MONTHS[M]
      ASAV = ADIR + 'M_'+YEAR+AMON + '-' + 'MONTH_'+AMON+'_'+APER + '-' + ALABEL
      MSAV = MDIR + 'M_'+YEAR+AMON + '-' + MLABEL
      IF ~FILE_MAKE([FYR,FLT],[ASAV,MSAV],OVERWRITE=OVERWRITE) THEN GOTO, PNG_MAKE
      DR = DATE_2JD([YEAR+AMON+'01',YEAR+AMON+DAYS_MONTH(AMON,/STRING)])
      OKS = WHERE(DATES GE DR[0] AND DATES LE DR[1],COUNTS)
      OKL = WHERE(LDATES GE DR[0] AND LDATES LE DR[1],COUNTL)
      IF COUNTS NE COUNTL THEN MESSAGE, 'ERROR: Unmatched number of days'
      IF COUNTS EQ 0 THEN MESSAGE, 'ERROR: Missing dates'
      
      DIF = MEAN(SST[*,*,OKS] - LTM[*,*,OKL],DIMENSION=3)
      MN = MEAN(SST[*,*,OKS],DIMENSION=3)
      STRUCT_WRITE, MAPS_REMAP(DIF,MAP_IN='OISST',MAP_OUT=MP), FILE=ASAV, DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP=MP,MATH='ANOMALY_DIF',SENSOR='OISST'
      STRUCT_WRITE, MAPS_REMAP(MN,MAP_IN='OISST',MAP_OUT=MP), FILE=MSAV, DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP=MP,SENSOR='OISST'

      
      PNG_MAKE:
      PRODS_2PNG, ASAV, DIR_OUT=PADIR, PAL='PAL_BLUE_WHITE_RED', PROD='Temperature_-5_5', /ADD_BATHY, DEPTH=-200, ADD_DATE=MONTH_NAMES(AMON)+' '+YEAR, OUT_COLOR=0,OUT_THICK=4, /ADD_CB
      PRODS_2PNG, MSAV, DIR_OUT=PMDIR, PAL='PAL_DEFAULT', PROD='Temperature_0_30', /ADD_BATHY, DEPTH=-200, ADD_DATE=MONTH_NAMES(AMON)+' '+YEAR, OUT_COLOR=0,OUT_THICK=4, /ADD_CB

    ENDFOR  
      
    
;    WNT = MAPS_REMAP(MEAN(SST(*,*,0:89)    - LTM(*,*,0:89),   DIMENSION=3),MAP_IN='OISST', MAP_OUT='NEC')
;    SPR = MAPS_REMAP(MEAN(SST(*,*,90:180)  - LTM(*,*,90:180), DIMENSION=3),MAP_IN='OISST', MAP_OUT='NEC')
;    SUM = MAPS_REMAP(MEAN(SST(*,*,181:272) - LTM(*,*,181:272),DIMENSION=3),MAP_IN='OISST', MAP_OUT='NEC')
;    FAL = MAPS_REMAP(MEAN(SST(*,*,273:364) - LTM(*,*,273:364),DIMENSION=3),MAP_IN='OISST', MAP_OUT='NEC')
;    
;    STRUCT_WRITE, WNT, FILE=SAVES[0], DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP='NEC'
;    STRUCT_WRITE, SPR, FILE=SAVES[1], DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP='NEC'
;    STRUCT_WRITE, SUM, FILE=SAVES(2), DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP='NEC'
;     STRUCT_WRITE, FAL, FILE=SAVES(3), DATA_UNITS=UNITS('SST',/SI), PROD='SST', MAP='NEC'
  ENDIF  

stop

  

  EPU_OUTLINE = []
  NAMES = ['GOM','GB','MAB']
  FOR F=0, N_ELEMENTS(NAMES)-1 DO BEGIN
    POS = WHERE(TAG_NAMES(SHPS) EQ STRUPCASE(NAMES(F)),/NULL)
    EPU_OUTLINE = [EPU_OUTLINE,SHPS.(POS).OUTLINE]
  ENDFOR
  
  PRODS_2PNG, SAVES, DIR_OUT=DIR, PAL='PAL_ANOM_BWR', PROD='SST_-6_6', OUTLINE=EPU_OUTLINE, OUT_COLOR=0,OUT_THICK=4, /ADD_CB
  
  PNG = DIR + 'M3_2019-OISST-SST-DIF-SEASONAL_COMPOSITE.PNG'
  IF FILE_MAKE(SAVES,PNG,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
    W = WINDOW(DIMENSIONS=[512,512],BUFFER=BUFFER)
    OPROD = 'SST_-6_6'
    MAPOUT='NEC'
    OCOLOR='BLACK'
    PAL='PAL_ANOM_BWR'
    PRODS_2PNG,SAVES[0],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=EPU_OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0.5,0.5,1.0],  PAL=PAL, CB_SIZE=6, CB_POS=[0.05,0.9,0.48,0.92], /ADD_CB, CB_TYPE=3, CB_TITLE=CB_TITLE
    PRODS_2PNG,SAVES[1],SPROD=OPROD,MAPP=MAPOUT,OUTLINE=EPU_OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0.5,1.0,1.0],PAL=PAL
    PRODS_2PNG,SAVES(2),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=EPU_OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0,0,0.5,0.5],    PAL=PAL
    PRODS_2PNG,SAVES(3),SPROD=OPROD,MAPP=MAPOUT,OUTLINE=EPU_OUTLINE,OUT_COLOR=OCOLOR,/CURRENT,IMG_POS=[0.5,0,1.0,0.5],  PAL=PAL
  
    T  = TEXT(0.98,0.02, '2019',        FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=1.0)
    S1 = TEXT(0.01,0.97, 'WINTER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
    S2 = TEXT(0.51,0.97, 'SPRING', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
    S3 = TEXT(0.01,0.47, 'SUMMER', FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
    S4 = TEXT(0.51,0.47, 'FALL',   FONT_SIZE=10, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0)
    
    W.SAVE, PNG
    W.CLOSE
  ENDIF  
  
  SUBAREAS_EXTRACT, SAVES, SHP_NAME=SUBAREA, INIT=INIT, VERBOSE=VERBOSE, DIR_OUT=DIR, STRUCT=STR
  
stop

END
