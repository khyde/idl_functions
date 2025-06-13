; $ID:	SEABASS_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program is a MAIN for Exploring NASA's SEABAM Pigment database


; HISTORY: Updated 25 October 2012 by K. Hyde
;
 ;-
; *************************************************************************

PRO SEABASS_MAIN
  ROUTINE_NAME='SEABASS_MAIN'
; *******************************************
; DEFAULTS
  SP = DELIMITER(/SPACE)
  SL = DELIMITER(/PATH)
  UL = DELIMITER(/UL)
  PX=1024 & PY=1024
 	PAL = 'PAL_SW3'
  ABACKGROUND=252 & ALAND_COLOR=252 & AMISS_COLOR=253 & AOUR_MISS_COLOR=251 & AFLAG_COLOR=254 & AHI_LO_COLOR=255
  
  DO_EDIT_SEABASS                  = 0  ; Make save from txt input file
  DO_ADD_MAPS_INFO                  = 1  ; Add MAP information to the ship file - Added 1/3/2014
  DO_SATSHIP_HDF                   = 0  ; Extract satellite match-up data from HDF files
  
  DO_STRUCT_PLOT_RAW						   = 0  ; Plot struct information
  DO_SEABASS_PIGMENT_EDIT				   = 0	; Regress hplc versus fluor chl_a vs chl
  DO_OC_NOMAD_INTERP_VS_MEASURED 	 = 0


  DIR = !S.PROJECTS + 'SEABASS' + SL     
  DIR_DATA  = DIR+'DATA'  + SL
  DIR_SAVE  = DIR+'SAVE'  + SL  
  DIR_PLOTS = DIR+'PLOTS' + SL
  DIR_TEST,[DIR,DIR_DATA,DIR_SAVE,DIR_PLOTS]

; *****************************************************
  IF DO_EDIT_SEABASS GE 1 THEN BEGIN
; *****************************************************
    OVERWRITE = DO_EDIT_SEABASS GE 2
    PRINT, 'S T E P:   DO_EDIT_SEABASS'

    FLUOR = DIR_DATA + 'seabass_FLUOR_EC_downloaded_20140102.csv'
    HPLC  = DIR_DATA + 'seabass_HPLC_EC_downloaded_20140102.csv'
    FOR NTH=0, N_ELEMENTS(HPLC)-1 DO BEGIN
      FFILE = FLUOR[NTH]
      HFILE = HPLC[NTH]      
      SAVEFILE = DIR_DATA+'SEABASS_FLUOR_HPLC_PIGMENTS_20140102.SAVE'

      UPDATE = UPDATE_CHECK(INFILE=[FFILE,HFILE],OUTFILE=SAVEFILE)
      IF UPDATE EQ 0 AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE  	    
	    DF=READALL(FFILE)	    
	    DD = REPLICATE(CREATE_STRUCT('YEAR','','MONTH','','DAY','','HOUR','','MINUTE','','SECOND','','DATE','','HHMM','','STATION',''),N_ELEMENTS(DF))
	    DT = STRSPLIT(DF.DATE_TIME,' ',/EXTRACT)
	    DT = DT.TOARRAY()
	    DY = STRSPLIT(DT(*,0),'/',/EXTRACT)
      DY = DY.TOARRAY()
      DD.YEAR = DY(*,2)
      DD.MONTH = ADD_STR_ZERO(DY(*,0))
      DD.DAY = ADD_STR_ZERO(DY(*,1))        
      DD.DATE = DD.YEAR+DD.MONTH+DD.DAY
	    TT = STRSPLIT(DT(*,1),':',/EXTRACT)
	    TT = TT.TOARRAY()
	    DD.HOUR = ADD_STR_ZERO(TT(*,0))
	    DD.MINUTE = ADD_STR_ZERO(TT(*,1))
	    DD.SECOND = '00'
	    DD.HHMM = DD.HOUR+DD.MINUTE  	                   
	    
	    DF = STRUCT_COPY(DF,'DATE_TIME',/REMOVE)
	    DF = STRUCT_RENAME(DF,['ID',        'INVESTIGATOR','LATITUDE','LONGITUDE','CHL'   ],$
                            ['SEABASS_ID','SOURCE',      'LAT',     'LON',      'CHLOR_A'])
	    DF=STRUCT_2NUM(DF,/FLT)
	    DF=REPLACE(DF,-999., MISSINGS(0.0),TAGNAMES=['LAT','LON','CHLOR_A','PHAEO'])  		   
	    BF = STRUCT_MERGE(DD,DF) 
	    BF = BF[WHERE(DATE_2JD(BF.DATE) GE DATE_2JD(19970908))] 
	    BF = BF[SORT(DATE_2JD(BF.DATE))]
	    
	    DH=READALL(HFILE)
	    DD = REPLICATE(CREATE_STRUCT('YEAR','','MONTH','','DAY','','HOUR','','MINUTE','','SECOND','','DATE','','HHMM','',$
	     'STATION','','NEC','','NEC_SUB','','NEC_CODE','','NAFO','','NAFO_SUB','','NAFO_CODE','','EC','','NENA_SUB','','NENA_CODE',''),N_ELEMENTS(DH))
	    DT = STRSPLIT(DH.DATE_TIME,' ',/EXTRACT)
	    DT = DT.TOARRAY()
	    DY = STRSPLIT(DT(*,0),'/',/EXTRACT)
	    DY = DY.TOARRAY()
	    DD.YEAR = DY(*,2)
	    DD.MONTH = ADD_STR_ZERO(DY(*,0))
	    DD.DAY = ADD_STR_ZERO(DY(*,1))
	    DD.DATE = DD.YEAR+DD.MONTH+DD.DAY
	    TT = STRSPLIT(DT(*,1),':',/EXTRACT)
	    TT = TT.TOARRAY()
	    DD.HOUR = ADD_STR_ZERO(TT(*,0))
	    DD.MINUTE = ADD_STR_ZERO(TT(*,1))
	    DD.SECOND = '00'
	    DD.HHMM = DD.HOUR+DD.MINUTE
	    
	    DH = STRUCT_COPY(DH,'DATE_TIME',/REMOVE)
	    DH = STRUCT_RENAME(DH,['ID',        'INVESTIGATOR','LATITUDE','LONGITUDE','ALPHA_MIN_BETA_MIN_CAR','CHL_A','CHL_B','CHL_C','DIADINO','TOT_CHL_A'   ],$
	                          ['SEABASS_ID','SOURCE',      'LAT',     'LON',      'CARO',                  'CHLA', 'CHLB', 'CHLC', 'DIA',    'TCHLA'  ])
	                          	   
	    DH=STRUCT_2NUM(DH,/FLT)
	    DH=REPLACE(DH,-999., MISSINGS(0.0))
	    BH = STRUCT_MERGE(DD,DH)
	    BH = BH[WHERE(DATE_2JD(BH.DATE) GE DATE_2JD(19970908))]
	    BH = BH[SORT(DATE_2JD(BH.DATE))]
	    
	    BB = STRUCT_JOIN(BF,BH,TAGNAMES=['SEABASS_ID','SOURCE','LAT','LON','YEAR','MONTH','DAY','HHMM','STATION','HOUR','MINUTE','SECOND','DATE','CRUISE_NAME','DEPTH']) 
	    SAVE,FILENAME=SAVEFILE,BB,/COMPRESS
    STOP
    ENDFOR  
   ENDIF ;
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; ********************************************
  IF DO_ADD_MAPS_INFO GE 1 THEN BEGIN
; ********************************************
  OVERWRITE = DO_ADD_MAPS_INFO GT 1
  
  SAVEFILE = DIR_DATA+'SEABASS_FLUOR_HPLC_PIGMENTS_20140102.SAVE'
  SDATA = IDL_RESTORE(SAVEFILE)
  BLL=WHERE_SETS(SDATA.LAT+SDATA.LON)
  SUBAREAS = LIST(['ECOREGIONS_FULL_NO_ESTUARIES'],['NAFO_1_2J3K','NAFO_2_2J3KL','NAFO_3_2J3KLNO','NAFO_4_3LNO','NAFO_5_3M','NAFO_6_NS'],['ECOS-SUBAREAS_LARGE'])
  MAPS     = ['NEC','NAFO','EC']
  SUBCODES = LIST([5,6,7,8],[5],[2,3,4,5,6,7])
  
  FOR M = 0, N_ELEMENTS(MAPS)-1 DO BEGIN
    AMAP = MAPS(M)
    SUBS = SUBAREAS(M)
    CODES = SUBCODES(M)
    FOR S = 0, N_ELEMENTS(SUBS)-1 DO BEGIN
      SUBAREA  = SUBS(S)
      AREAFILE = !S.IMAGES + 'MASK_SUBAREA-'+AMAP+'-PXY_1024_1024-'+SUBAREA+'.SAVE'
      IF FILE_TEST(AREAFILE) EQ 0 THEN STOP
      
      ZWIN, [1024,1024]
      CALL_PROCEDURE, 'MAP_'+AMAP
      PAL_36, R,G,B
      AREAS = STRUCT_SD_READ(AREAFILE,STRUCT=ASTRUCT)
      CODE = MAP_DEG2IMAGE(AREAS,SDATA.LON,SDATA.LAT,AROUND=0)
      TV,AREAS
      FOR LL=0, N_ELEMENTS(BLL)-1 DO BEGIN
        LSUBS = WHERE_SETS_SUBS(BLL(LL))
        PLOTS,SDATA(LSUBS).LON,SDATA(LSUBS).LAT,PSYM=7,COLOR=36,/NOCLIP,SYMSIZE=0.5, THICK=1.5
      ENDFOR
      PNG = TVRD()
      ZWIN
      PNGFILE = DIR_PLOTS + 'SEABASS-'+SUBAREA+'-STATIONS.PNG'
      WRITE_PNG,PNGFILE,PNG,R,G,B
            
      FOR NTH = 0L, N_ELEMENTS(CODES)-1 DO BEGIN
        OKN = WHERE(CODES[NTH] EQ ASTRUCT.SUBAREA_CODE,COUNT)
        IF COUNT EQ 1 THEN NAME = ASTRUCT.SUBAREA_NAME(OKN[0]) ELSE STOP
        OK = WHERE(CODE EQ CODES[NTH],COUNT)        
        IF COUNT EQ 0 THEN CONTINUE
        CASE AMAP OF
          'NEC': BEGIN
            SDATA[OK].NEC_SUB = NAME
            SDATA[OK].NEC_CODE = NUM2STR(CODES[NTH])
            SDATA[OK].NEC = 'ECOREGIONS_FULL_NO_ESTUARIES'
          END
          'NAFO': BEGIN
            OKN = WHERE(SDATA[OK].NAFO_SUB  NE MISSINGS(SDATA.NAFO_SUB),COUNT,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT)
            IF COUNT GE 1 THEN BEGIN
              FOR N=0, COUNT-1 DO SDATA(OK(OKN(N))).NAFO_SUB  = STRJOIN([SDATA(OK(OKN(N))).NAFO_SUB,NAME],';')
              FOR N=0, COUNT-1 DO SDATA(OK(OKN(N))).NAFO_CODE = STRJOIN([SDATA(OK(OKN(N))).NAFO_CODE,NUM2STR(CODES[NTH])],';')
            ENDIF ELSE BEGIN
              SDATA(OK(COMPLEMENT)).NAFO_SUB  = NAME
              SDATA(OK(COMPLEMENT)).NAFO_CODE = NUM2STR(CODES[NTH])
            ENDELSE             
            SDATA[OK].NAFO = 'NAFO'
          END
          'EC': BEGIN
            SDATA[OK].NENA_SUB = NAME
            SDATA[OK].NENA_CODE = NUM2STR(CODES[NTH])
            SDATA[OK].EC = 'NENA'
          END
        ENDCASE
      ENDFOR
    ENDFOR
  ENDFOR

  ENDIF ; DO_ADD_MAP_INFO

; ********************************************
  IF DO_SATSHIP_HDF GE 1 THEN BEGIN
; ********************************************
    OVERWRITE = DO_SATSHIP_HDF GT 1
 
    FLAG_BITS     = [0,1,2,3,4,5,8,9,12,14,15,16,25]
    DATASETS      = ['OC-SEAWIFS-MLAC','OC-MODIS-LAC'];'OC-SEAWIFS-MLAC'
    DO_DATASET    = [0,1]
    L2_DIR        = ['L2A','L2A']
    GET_FILES_L2  = [0,1]
    GET_L1A       = [0,1]
    L1_DIR        = ['L1A_SUB','L1A_SUB']    
    SHIP_TYPES    = 'HPLC'; ['HPLC','FLUOR','RRS']        
    REVERSE_PRODS = 0    
    CRUISE_NAME   = 'SEABASS_PIGMENTS_20120525'
    SAVE_LABEL    = 'HPLC' ;'HPLC'
    SHIP_FILE     = !S.PROJECTS + 'SEABASS' + SL + 'DATA' + SL + CRUISE_NAME + '.SAVE'     
    DIR_OUT       = !S.PROJECTS + 'SEABASS' + SL + 'SAT_SHIP' + SL & DIR_TEST,DIR_OUT          
    
    FOR STH=0, N_ELEMENTS(SHIP_TYPES)-1 DO BEGIN
      SHIP_TYPE = SHIP_TYPES(STH)    
      FOR DTH=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
        IF DO_DATASET(DTH) EQ 0 THEN CONTINUE
        IF GET_L1A(DTH) EQ 1 THEN BEGIN
          D=READ_SHIP_FILE(SHIP_FILE,ERROR=ERROR,ERR_MSG=ERR_MSG)
          L1A = FILE_SEARCH(!S.SEADAS + DATASETS(DTH) + SL + L1_DIR(DTH) + SL + '*')
          FP = PARSE_IT(L1A)
          JULIAN_SAT= DATE_2JD(SATDATE_2DATE(FP.FIRST_NAME))
          JDDIFF = 1.0          
          OK = WHERE_NEAREST(D.JULIAN,JULIAN_SAT,NEAR=JDDIFF,COUNT,VALID=VALID)             
          FILES = L1A(VALID)    
          WRITE_TXT,!S.DATASETS + DATASETS(DTH) + SL + 'SEABASS_L1A_FILES.txt',FILES
          STOP
        ENDIF
        SENSOR = VALID_SENSORS(DATASETS(DTH))
        SUITE  = VALID_SUITES(SENSOR+'_FULL',/PRODUCTS)      
        QAA    = WHERE(STRPOS(STRUPCASE(SUITE.SUITE_PRODS),'QAA') GE 0)
        QAA_PRODS = SUITE(QAA).SUITE_PRODS
        POS = STRPOS(QAA_PRODS,'_',/REVERSE_SEARCH)
        FOR P=0,N_ELEMENTS(QAA_PRODS)-1 DO BEGIN
          QAA = QAA_PRODS(P)
          STRPUT, QAA, '-', POS(P)
          QAA_PRODS(P) = QAA
        ENDFOR
        PIGMENTS = 'PIGMENTS_'+['ALLO','CARO','CHLA','CHLB','CHLC','DIA','FUCO','LUT','NEO','PERID','VIOLA']+'_PAN'
        SENSOR_PROD = SENSOR + '_' + SHIP_TYPE
        CASE SENSOR_PROD OF
          'SEAWIFS_RRS':   PRODUCTS = ['CHLOR_A','RRS_412','RRS_443','RRS_490','RRS_510','RRS_555','RRS_670',QAA_PRODS] 
          'MODIS_RRS':     PRODUCTS = ['CHLOR_A','RRS_412','RRS_443','RRS_469','RRS_488','RRS_531','RRS_547','RRS_555','RRS_645','RRS_667','RRS_678',QAA_PRODS]
          'SEAWIFS_HPLC':  PRODUCTS = ['CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS] 
          'MODIS_HPLC':    PRODUCTS = ['CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS]
          'SEAWIFS_FLUOR': PRODUCTS = ['CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS] 
          'MODIS_FLUOR':   PRODUCTS = ['CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS]
          'SEAWIFS_ALL':   PRODUCTS = ['CHLOR_A','RRS_412','RRS_443','RRS_490','RRS_510','RRS_555','RRS_670',QAA_PRODS,'CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS]
          'MODIS_ALL':     PRODUCTS = ['CHLOR_A','RRS_412','RRS_443','RRS_469','RRS_488','RRS_531','RRS_547','RRS_555','RRS_645','RRS_667','RRS_678',QAA_PRODS,'CHLOR_A','CHLOR_A-PAN','CHL_GSM',PIGMENTS]
        ENDCASE  
        CASE SHIP_TYPE OF          
          'RRS'  : SHIP_PRODS = REPLICATE('',N_ELEMENTS(PRODUCTS))
          'HPLC' : SHIP_PRODS = ['CHLA',   'CHLA',   'CHLA',   'ALLO','CARO','CHLA','CHLB','CHLC','DIA','FUCO','LUT','NEO','PERID','VIOLA'] ; No ZEA in HDF files
          'FLUOR': SHIP_PRODS = ['CHLOR_A','CHLOR_A','CHLOR_A','ALLO','CARO','CHLA','CHLB','CHLC','DIA','FUCO','LUT','NEO','PERID','VIOLA'] ; No ZEA in HDF files
          'ALL'  : SHIP_PRODS = REPLICATE('',N_ELEMENTS(PRODUCTS))
        ENDCASE 
        PRODUCTS = ['L2_FLAGS',PRODUCTS]         
        SHIP_PRODS = ['L2_FLAGS',SHIP_PRODS]
        
        OUTNAME = SENSOR+'-'+SHIP_TYPE+'-'+CRUISE_NAME
        DIR_DATASETS = !S.DATASETS + DATASETS(DTH) + SL + L2_DIR(DTH) + SL
        DIR_BROWSE   = !S.DATASETS + DATASETS(DTH) + SL + 'NEC' + SL + 'BROWSE' + SL
        FILES = FILE_SEARCH(DIR_DATASETS+'S_*'+['.hdf','.hdf.bz2'])
        IF N_ELEMENTS(FILES)  EQ 1 AND FILES[0] EQ '' THEN CONTINUE
;        SATSHIP= SD_HDF_SAT_SHIP(SHIP_FILE=SHIP_FILE,SAT_FILES=FILES,GET_FILES=1,AROUND=AROUND,PROD='L2_FLAGS',$
;                 HOURS=24,OUTNAME=OUTNAME,RANGE=RANGE,DIR_OUT=DIR_OUT,CSV=CSV,OVERWRITE=OVERWRITE)
;   
;        FP = PARSE_IT(SATSHIP) 
;        OK = WHERE(FP.EXT NE 'par',COUNT)
;        IF COUNT GE 1 THEN BEGIN & SATSHIP = SATSHIP[OK] & FP = FP[OK] & ENDIF     
;        OK = WHERE(FP.EXT EQ 'bz2',COUNT)      
;        IF COUNT GE 1 THEN stop ; ZIP, FILES = SATSHIP[OK]
        
        CSV = 1
        GET_FILES = 0 
        AROUND = 1
        HOURS = [3,24]
        RECHECK_L2FILES:
        L2_FILES = []        
        IF GET_FILES_L2(DTH) EQ 1 THEN BEGIN
          L2_FILE = FILE_SEARCH(DIR_OUT + 'SD_HDF_SAT_SHIP*'+'HOURS_'+NUM2STR(MAX(HOURS))+'-L2_FLAGS-'+OUTNAME+'.SAVE')
          IF L2_FILE[0] NE '' THEN L2 = IDL_RESTORE(L2_FILE[0]) ELSE L2 = []
          IF N_ELEMENTS(L2) GE 1 THEN L2_FILES = DIR_DATASETS+L2.FIRST_NAME + '.hdf'
          IF L2_FILES NE [] THEN BEGIN
            L2_FILES = L2_FILES[WHERE(FILE_TEST(L2_FILES) EQ 1)]
            L2_FILES = L2_FILES[SORT(L2_FILES)]
            UN = UNIQ(L2_FILES)
            L2_FILES = L2_FILES(UN)
          ENDIF            
        ENDIF 
        IF L2_FILES EQ [] OR N_ELEMENTS(L2_FILES) EQ 0 THEN FILES = FILE_SEARCH(DIR_DATASETS+'S_*.hdf') ELSE FILES = L2_FILES
  
        IF REVERSE_PRODS EQ 1 THEN PRODUCTS = REVERSE(PRODUCTS)
      ;  FOR NTH = 0, N_ELEMENTS(PRODUCTS)-1 DO BEGIN                          
          IF N_ELEMENTS(FILES[0]) EQ '' THEN STOP
          LI, 'Finding data for ' + PRODUCTS          
          SATSHIP= SD_HDF_SAT_SHIP(SHIP_FILE=SHIP_FILE,SAT_FILES=FILES,GET_FILES=GET_FILES,AROUND=AROUND,HOURS=MAX(HOURS),FLAG_BITS=FLAG_BITS,$
            SHIP_PROD=SHIP_PRODS,PRODS=PRODUCTS,OUTNAME=OUTNAME,RANGE=RANGE,DIR_OUT=DIR_OUT,CSV=CSV,OVERWRITE=OVERWRITE)
          IF L2_FILES EQ [] AND GET_FILES_L2(DTH) EQ 1 THEN GOTO, RECHECK_L2FILES
      ;  ENDFOR   
     STOP   
        FOR NTH = 0, N_ELEMENTS(PRODUCTS)-1 DO BEGIN
          FILE = FILE_SEARCH(DIR_OUT + 'SD_HDF_SAT_SHIP*'+'HOURS_'+NUM2STR(MAX(HOURS))+'-'+STRUPCASE(PRODUCTS[NTH])+'-'+OUTNAME+'.SAVE')
          IF N_ELEMENTS(FILE) GT 1 THEN STOP
          IF FILE EQ '' THEN STOP          
          STRUCT = IDL_RESTORE(FILE)
          STRUCT = STRUCT_MERGE(REPLICATE(CREATE_STRUCT('SENSOR',SENSOR),N_ELEMENTS(STRUCT)),STRUCT)
          PRINT, NUM2STR[NTH] + ') Merging data from ' + products(nth)         
          IF NTH EQ 0 THEN OUTSTRUCT = STRUCT ELSE $
            OUTSTRUCT=STRUCT_JOIN(OUTSTRUCT,STRUCT,TAGNAMES=['SENSOR','FIRST_NAME','PERIOD','SOURCE','CRUISE','STATION','DATE_SHIP','TIME_DIF_HOURS','DEPTH','LON','LAT','SAT_LAT_0','SAT_LAT','SAT_LON_0','SAT_LON'])
          GONE, STRUCT          
        ENDFOR
         IF DTH EQ 0 THEN SAVESTRUCT = OUTSTRUCT ELSE SAVESTRUCT = STRUCT_CONCAT(SAVESTRUCT,OUTSTRUCT)
        GONE, OUTSTRUCT
        GONE, STRUCT
      ENDFOR ; FOR DTH = 0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    ENDFOR  
    
    FOR HTH =0L, N_ELEMENTS(HOURS)-1 DO BEGIN
      OK = WHERE(ABS(SAVESTRUCT.TIME_DIF_HOURS) LE HOURS(HTH),COUNT)
      IF COUNT GE 1 THEN HSTRUCT = SAVESTRUCT[OK] ELSE CONTINUE   
      SAVE_FILE=REPLACE(FILE,[VALID_SENSORS(FILE),'HOURS_'+NUM2STR(MAX(HOURS)),STRUPCASE(PRODUCTS(NTH-1))],['SEAWIFS_MODIS','HOURS_'+NUM2STR(HOURS(HTH)),SAVE_LABEL])
      SAVE,FILENAME=SAVE_FILE,HSTRUCT,/COMPRESS  
      SAVE_2CSV,SAVE_FILE 
    ENDFOR       
    GONE, HSTRUCT
    GONE, SAVESTRUCT
            
  ENDIF  ; DO_SATSHIP_HDF

stop
;********************************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************************
;********************************************************************************************************************************************************************************************

; *****************************************************
  IF DO_STRUCT_PLOT_RAW GE 1 THEN BEGIN
; *****************************************************
  	PRINT, 'S T E P:   DO_STRUCT_PLOT_RAW'
  	FILE = FILE_SEARCH(DIR_DATA+'SEABASS_PIGMENT*.SAVE')
  	PS_FILE = DIR_PLOTS + 'SEABASS_PIGMENT.PS'
  	;IF DO_STRUCT_PLOT_RAW GE 2 OR FILE_TEST(PS_FILE) EQ 0 THEN BEGIN
  	  DB=READALL(FILE)
  		PSPRINT,FILENAME=PS_FILE,/COLOR,/FULL & !P.MULTI=0
  		STRUCT_PLOT,DB
  		PSPRINT
		;ENDIF
  ENDIF ;IF DO_STRUCT_PLOT
; ||||||||||||||||||||||||




; *****************************************************
  IF DO_SEABASS_PIGMENT_EDIT GE 1 THEN BEGIN
; *****************************************************
  	PRINT, 'S T E P:   DO_SEABASS_PIGMENT_EDIT'
  	FILE = DIR_SAVE+'SEABASS_PIGMENT.SAVE'
  	SAVE_FILE = DIR_SAVE+'SEABASS_PIGMENT-EDIT.SAVE'
  	PS_FILE = DIR_PLOTS+'SEABASS_PIGMENT_LT_01.PS'

  	IF DO_SEABASS_PIGMENT_EDIT GE 2 OR FILE_TEST(SAVE_FILE) EQ 0 THEN BEGIN


  		DB=READALL(FILE)

;			===> Find low chl
			OK=WHERE(DB.CHL NE MISSINGS(DB.CHL) AND DB.DEPTH LT 30 AND DB.CHL LT 0.05 AND DB.CHL GT 0.0)
			d=DB[OK]
			SET_PMULTI,2
			PSPRINT,FILENAME=PS_FILE,/FULL,/COLOR
			PAL_SW3

			HISTPLOT, ALOG10(D.CHL),MIN=-4,MAX=3,BINSIZE=0.075 ,DECIMALS=3

			MAP_GEQ
			MAP_CONTINENTS
			MAP_GRID,LATDEL=10,LONDEL=10
			PLOTS,D.LONGITUDE,D.LATITUDE,PSYM=1,COLOR=TC(BYTSCL(D.CHL)),THICK=3
			PSPRINT

			S=SORT(D.CHL)
			D=D(S)

			SPREAD,D


STOP

			OK=WHERE(DB.CHL_A NE MISSINGS(DB.CHL_A) AND DB.MV_CHL_A NE MISSINGS(DB.MV_CHL_A))
			D=DB[OK]
			CHL_A_ALLOM = REPLACE(D.CHL_A_ALLOM, MISSINGS(0.0), 0)
			CHL_A_PRIME = REPLACE(D. CHL_A_PRIME, MISSINGS(0.0), 0)
			CHLIDE_A 		= REPLACE(D.CHLIDE_A, MISSINGS(0.0), 0)
			DV_CHL_A 		= REPLACE(D.DV_CHL_A, MISSINGS(0.0), 0)
			MV_CHL_A 		= REPLACE(D.MV_CHL_A, MISSINGS(0.0), 0)
			CHL_A_SUM 		= CHL_A_ALLOM+CHL_A_PRIME+CHLIDE_A+DV_CHL_A+MV_CHL_A


		OK=WHERE(DB.CHL NE MISSINGS(DB.CHL) AND DB.DEPTH LT 20)

			SAVE,FILENAME=SAVE_FILE,DB,/COMPRESS
		ENDIF ; IF DO_SEABASS_PIGMENT_EDIT GE 2 OR FILE_TEST(SAVE_FILE) EQ 0 THEN BEGIN

  ENDIF ;IF DO_STRUCT_PLOT
; ||||||||||||||||||||||||




; *****************************************************
  IF DO_STRUCT_PLOT_EDIT GE 1 THEN BEGIN
; *****************************************************
  	PRINT, 'S T E P:   DO_STRUCT_PLOT_EDIT'
  	PS_FILE = DIR_PLOTS + 'SEABASS_PIGMENT-EDIT.PS'
  	IF DO_STRUCT_PLOT_EDIT GE 2 OR FILE_TEST(PS_FILE) EQ 0 THEN BEGIN
  	 	FILE = DIR_SAVE+'SEABASS_PIGMENT-EDIT.SAVE' & 	DB=READALL(FILE)
  		PSPRINT,FILENAME=PS_FILE,/COLOR,/FULL & !P.MULTI=0 & STRUCT_PLOT,DB & PSPRINT
		ENDIF
  ENDIF ;IF DO_STRUCT_PLOT
; ||||||||||||||||||||||||



; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||






  DONE:

  PRINT,'END
  END; #####################  End of Routine ################################


