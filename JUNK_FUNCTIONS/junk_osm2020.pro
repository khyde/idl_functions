; $ID:	JUNK_OSM2020.PRO,	2020-07-08-15,	USER-KJWH	$
pro junk_osm2020

  SL = PATH_SEP()
  LOGLUN = []
  DATERANGE=['1998','2018']
  YRS = YEAR_RANGE(DATERANGE[0],DATERANGE[1])
  
  DIR_PRO = !S.PROJECTS + 'PHYTO' + SL
  DIR_STATS = DIR_PRO + 'STATS' + SL
  DIR_PNGS  = DIR_PRO + 'PNGS' + SL 
  DIR_FINAL = DIR_PRO + 'FINAL_PNGS' + SL
  DIR_TEST,[DIR_STATS,DIR_PNGS,DIR_FINAL]

  OVERWRITE = 0
  INMAP = 'L3B2'
  MAPOUT = 'NEC'
  
  
  SUBAREA = 'NES_EPU_NOESTUARIES';'NES_STATISTICAL_AREAS_NAMES'; 'NES_EPU_NOESTUARIES'
  NAMES = ['GOM','GB','MAB']
  EPU_OUTLINE = GET_SHPFILE_OUTLINE(SUBAREA, MAPP=MAPOUT, NAMES=NAMES)
  
  DATASETS = ['SAV']
  PRODS = ['CHLOR_A-PAN','PPD-VGPM2','SST','PAR']
  
  FOR DTH=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DATASET = DATASETS(DTH)
    PERIODS = ['A','M','M3']
    FOR RTH=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      PROD = PRODS(RTH)
      MAPIN = INMAP
      SPROD = 'NUM_-.1_.1' & STICKS = [-.1,-.05,0,.05,.1] & SNAMES=['-0.1','-0.05','0.0','0.05','0.1'] &
      CASE VALIDS('PRODS',PROD) OF
        'CHLOR_A': BEGIN & LOG=1 & DIR = !S.OC + DATASET + SL + MAPIN + '/STATS/' + PROD + SL & APROD = 'CHLOR_A_0.1_30'  & END
        'PAR':     BEGIN & LOG=0 & DIR = !S.OC + DATASET + SL + MAPIN + '/STATS/' + PROD + SL & APROD = 'PAR' & SPROD = 'NUM_-1_1' & STICKS = [-1,-.5,0,.5,1] & SNAMES=['-1','-0.5','0.0','0.5','1'] & END
        'PPD':     BEGIN & LOG=1 & DIR = !S.PP + DATASET + SL + MAPIN +'/STATS/' + PROD + SL & APROD = 'PPD_0.2_7' & END
        'SST':     BEGIN & LOG=0 & MAPIN='L3B4' & DIR = !S.SST + 'AVHRR' + SL + MAPIN +'/STATS/' + PROD + SL & APROD = 'SST_0_30' & SPROD = 'NUM_-2_2' & STICKS = [-2,-1,0,1,2] & SNAMES=['-1','-2','0','1','2'] & END
      ENDCASE
      
      MOBINS = MAPS_L3B_OCEAN_2BINS(MAPIN,MAPOUT)
      MOSUBS = MOBINS-1
      N_BINS = N_ELEMENTS(MOBINS)
      
      FOR PTH=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        PER = PERIODS(PTH)
        F = FLS(DIR  + PER + '_*',DATERANGE=DATERANGE,COUNT=COUNT)
        IF COUNT EQ 0 THEN CONTINUE
        FP = PARSE_IT(F)
        CASE PER OF 
          'A': BEGIN 
            B = WHERE_SETS(FP.MONTH_START) 
            IF N_ELEMENTS(B) NE 1 THEN STOP 
            LABEL = 'ANNUAL_' + STRJOIN(DATERANGE,'_')
            PERIOD = 'ANNUAL'
            FF = FLS(DIR  + 'ANNUAL' + '_*',COUNT=COUNT)
            IF COUNT EQ 1 THEN PRODS_2PNG, FF, ADD_CB=0, DIR_OUT=DIR_FINAL, SPROD=APROD, MAPP=MAPOUT,PAL='PAL_DEFAULT', IMG_POS=[0,0,1,1],OUTLINE=EPU_OUTLINE,OUT_COLOR=0,BUFFER=BUFFER
          END
          'M': BEGIN
            B = WHERE_SETS(FP.MONTH_START)
            LABEL = 'MONTH_' + B.VALUE + '_' + STRJOIN(DATERANGE,'_')
            PERIOD = 'MONTH_' + B.VALUE
          END  
          'M3': BEGIN
            MS = FP.MONTH_START
            OK = WHERE(MS EQ '01' OR MS EQ '04' OR MS EQ '07' OR MS EQ '10',/NULL)
            F = F[OK] & FP = PARSE_IT(F)
            B = WHERE_SETS(FP.MONTH_START) 
            LABEL = 'MONTH3_' + B.VALUE + '_' + FP(B.FIRST).MONTH_END + '_' + STRJOIN(DATERANGE,'_')
            PERIOD = 'MONTH3_' + B.VALUE + '_' + FP(B.FIRST).MONTH_END
           END 
        ENDCASE
    
        FOR BTH=0, N_ELEMENTS(B)-1 DO BEGIN
          SET = F[WHERE_SETS_SUBS(B(BTH))]
          SAVFILE = DIR_PRO + 'STATS/' + LABEL(BTH) + '-' + DATASETS + '-' + MAPIN + '-' + PROD + '-MANN_KENDALL.SAV'
          PNGFILE = DIR_PRO + 'PNGS/' + LABEL(BTH) + '-' + DATASETS + '-' + MAPIN + '-' + PROD + '-MANN_KENDALL.PNG'
          FNLPNG  = DIR_PRO + 'FINAL_PNGS/' + LABEL(BTH) + '-' + DATASETS + '-' + MAPIN + '-' + PROD + '-MANN_KENDALL.PNG'
          PER = PERIOD(BTH)
          IF FILE_MAKE(SET,SAVFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            
            ARRFILE = !S.PROJECTS + 'PHYTO/DATA/' + LABEL(BTH) + '-' + DATASETS + '-' + MAPIN + '-' + PROD + '-MERGED.SAV'
            IF FILE_MAKE(SET,ARRFILE) EQ 1 THEN BEGIN
              A = FLTARR(N_BINS,N_ELEMENTS(SET)) & A(*) = MISSINGS(A)
              FOR N=0, N_ELEMENTS(SET)-1 DO BEGIN
                PFILE, SET(N), /R
                D = STRUCT_READ(SET(N),BINS=BINS)
                M = MAPS_L3B_2ARR(D,MP=MAPIN,BINS=BINS)
                A(*,N) = M(MOSUBS)
              ENDFOR
              SAVE, A, FILENAME=ARRFILE
            ENDIF ELSE A = IDL_RESTORE(ARRFILE) 
            
            SLP  = FLTARR(N_BINS) & SLP(*) = MISSINGS(A)
            PVAL = SLP
            SLPL = SLP
            PVALL = PVAL
            SN  = FIX(SLP)
            
            TIC
            SLP = FLTARR(N_BINS) & SLP(*)=MISSINGS(SLP)
            TAU = SLP
            TVL = SLP
            PVL = SLP
            SNB = FIX(SLP)
            TRD = STRING(SLP)
            SIG = TRD
            
            FOR I=0, N_BINS-1 DO BEGIN
              IF I MOD 49999 EQ 0 THEN BEGIN
                POF, I, MOSUBS,OUTTXT=POFTXT,/QUIET, /NOPRO
                PLUN, LOGLUN, 'Running Mann-Kendall test on array ' + POFTXT, 0
              ENDIF
              OK = WHERE(A(I,*) NE MISSINGS(A),COUNT)
              SNB(I) = COUNT
              IF COUNT LT N_ELEMENTS(YRS) THEN CONTINUE  ; Need a minimum of 5 years to calculate the stats
         ;     IF KEY(LOG) THEN ADAT = REFORM(ALOG(A(I,*))) ELSE 
              ADAT = REFORM(A(I,*))
              MK = MANN_KENDALL(ADAT,ALPHA=0.05) 
              SLP(I) = MK.SLOPE
              TAU(I) = MK.TAU
              TVL(I) = MK.TAU_PVALUE
              PVL(I) = MK.PVALUE
              TRD(I) = MK.TREND
              SIG(I) = MK.SIGNIFICANT
            ENDFOR
            TOC
            
            STR = CREATE_STRUCT('FILE',SAVFILE,'PERIOD',PER,'PROD',VALIDS('PRODS',PROD),'ALG',VALIDS('ALGS',PROD),'LOG',LOG,'BINS',MOBINS,'INFILES',F,$
                                'SLOPE',SLP, 'PVALUE',PVL, 'TAU',TAU, 'TAU_PVALUE',TVL, 'TREND',TRD, 'SIGNIFICANT',SIG)
            STRUCT_WRITE, STR, FILE=SAVFILE
            PFILE, SAVFILE,/W
          ENDIF  
         ; WHERE_SETS
        
          IF FILE_MAKE(SAVFILE,[PNGFILE,FNLPNG],OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
          D = STRUCT_READ(SAVFILE,STRUCT=S,MAP_OUT=MAPOUT)
          
         
          CASE VALIDS('PRODS',PROD) OF
            'CHLOR_A': BEGIN & SPROD = 'NUM_-.1_.1' & STICKS = [-.1,-.05,0,.05,.1] & SNAMES=['-0.1','-0.05','0.0','0.05','0.1'] & CTITLE='CHL Slope (' + UNITS('CHLOR_A',/NO_NAME,/NO_PAREN)+'yr!U-1!N)' & END
            'PAR':     BEGIN & SPROD = 'NUM_-1_1' & STICKS = [-1,-.5,0,.5,1] & SNAMES=['-1','-0.5','0.0','0.5','1'] & CTITLE='PAR Slope (' + UNITS('PAR',/NO_NAME,/NO_PAREN)+'yr!U-1!N)'& END
            'PPD':     BEGIN & SPROD = 'NUM_-.1_.1' & STICKS = [-.1,-.05,0,.05,.1] & SNAMES=['-0.1','-0.05','0.0','0.05','0.1'] & CTITLE='PP Slope (' + UNITS('PPD',/NO_NAME,/NO_PAREN)+'yr!U-1!N)'& END
            'SST':     BEGIN & SPROD = 'NUM_-2_2' & STICKS = [-2,-1,0,1,2] & SNAMES=['-1','-2','0','1','2'] & CTITLE='SST Slope (' + UNITS('SST',/NO_NAME,/NO_PAREN)+'yr!U-1!N)'& END
          ENDCASE
          
          SPAL = 'PAL_ANOM_BGR'
          VPAL = 'PAL_DEFAULT_REV'
          
          VPROD = 'NUM_0_0.05' & VTICKS = [0,.01,.02,.03,.04,.05] & VNAMES=['0','.01','.02','.03','.04','.05']
          TITLE = S.PERIOD + ' - ' + S.SENSOR + ' - ' + S.PROD
          
          OK = WHERE(S.SIGNIFICANT EQ 0 OR S.SIGNIFICANT EQ MISSINGS(S.SIGNIFICANT), COUNT,COMPLEMENT=COMP)
          S.SLOPE[OK] = MISSINGS(S.SLOPE)
          S.PVALUE[OK] = MISSINGS(S.PVALUE)
          
          IF FILE_MAKE(SAVFILE,[PNGFILE],OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
            W = WINDOW(DIMENSIONS=[1024,563],BUFFER=BUFFER)
            PRODS_2PNG,STRUCT=S,TAG='SLOPE', PROD=SPROD,PAL=SPAL,IMG_POS=[0,0,0.5,.9],OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,/CURRENT,/ADD_CB,CB_TICKNAMES=SNAMES,CB_TICKVALUES=STICKS,CB_TITLE='Slope'
            PRODS_2PNG,STRUCT=S,TAG='PVALUE',PROD=VPROD,PAL=VPAL,IMG_POS=[0.5,0,1,.9],OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,/CURRENT,/ADD_CB,CB_TICKNAMES=VNAMES,CB_TICKVALUES=VTICKS,CB_TITLE='P Value (p<0.05)'
            T  = TEXT(0.5,0.93, TITLE, FONT_SIZE=16, FONT_STYLE='BOLD', FONT_COLOR=DCOLOR, ALIGNMENT=0.5)
            W.SAVE, PNGFILE
            W.CLOSE
          ENDIF
          
         
          PRODS_2PNG,STRUCT=S,TAG='SLOPE',PNGFILE=FNLPNG,PROD=SPROD,PAL=SPAL,OUTLINE=EPU_OUTLINE,OUT_COLOR=0,OUT_THICK=4,/ADD_CB,CB_TICKNAMES=SNAMES,CB_TICKVALUES=STICKS,CB_TITLE=CTITLE

            
          
          
        ENDFOR ; WHERE_SETS
      ENDFOR ; PERIODS
    ENDFOR ; PRODS
  ENDFOR ; DATASETS        
        
     
    
    ;  
    
   
  STOP
  
  
  
  
  ; Monthly data plot
  ; Convert YYYYMM to MMYYYY
  ; XTICKRANGE = 011998 to 122018
  ; May want to add a spacer between the months, e.g. 0102019 point in the X range
  ; First nodata plot Xvalues with xticks etc and y range
  ; 
  ; XDATA = WHERE(D.PROD EQ 'CHLOR_A-PAN' AND PERIOD_CODE = 'A')
  ; DP = DATE_PARSE(PERIOD_2DATE(XDATA.PERIOD))
  ; B = WHERE_SETS(DP.MONTH)
  ; 
  ; 
  ; YRS = YEAR_RANGE('1998','2020',/STRING)
  ; MTH = MONTH_RANGE(/STRING)
  ; XDATES = []
  ; FOR M=0, N_ELEMENTS(MTH)-1 DO XDATES = [XDATES,MTH(M)+YRS]
  ; XTICKV = WHERE(STRMID(XDATE,2,4) EQ '2009')
  ; XTICKNAME = ['J','F','M','A','M','J','J','A','S','O','N','D']
  ; YRANGE = [0.0,15.0]
  ; PLOT, XDATES,REPLICATE(0.0,N_ELEMENTS(XDATES)),/NO_DATA, XTICKVALUE=XTICKV, XTICKNAME=XTICKNAME, YRANGE=YRANGE, YTITLE=UNITS('CHLOROPHYLL')
  ; FOR M=0, N_ELEMENTS(B)-1 DO BEGIN
  ;   XDAT = XDATA[WHERE_SETS_SUBS(B(M))]
  ;   X = STRMID(XDAT.PERIOD,6,2)+STRMID(XDAT.PERIOD,2,4)
  ;   PLOT, X, XDAT.MEDIAN, /OVERPLOT, 
  ;   PLOT, [X(0),X(-1)],REPLICATE(MEDIAN(XDAT.MEDIAN),2),/OVERPLOT
  ; ENDFOR
  
  
  
  HELP, A
  
  STOP

















end
