pro junk_rsync
  SL = PATH_SEP()
  SP = ' '

  DATASETS = !S.OC + ['MODIST','VIIRS','SEAWIFS','SA','SAV'] + SL
  
  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DIR    = DATASETS(D) 
    L2DIR  = DIR + 'L3B2' 
    IF FILE_TEST(L2DIR,/DIR) EQ 0 THEN CONTINUE
    OUTDIR = REPLACE(DIR, !S.OC, !S.MAIN + 'ARCHIVE/DATASETS_ARCHIVE/R2019/OC/')
    DIR_TEST, OUTDIR
    EXCLUDE = STRJOIN('--exclude ' + ['NC','FILLED_SAVE','PNGS','COMPOSITES','GLOBAL','SUBAREAS','SUSPECT','OLD_STATS','OLD_ANOMS','PROCESS','TEMP','THUMBNAILS','D3','*.*']+SL,SP)

    CMD = 'rsync -aviu ' + EXCLUDE + SP + L2DIR + SP + OUTDIR
    P, CMD
    SPAWN, CMD 
    
  ENDFOR

  DATASETS = !S.SST + ['MODIST','MODISA','AT'] + SL

  FOR D=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    DIR    = DATASETS(D)
    L2DIR  = DIR + 'L3B2'
    IF FILE_TEST(L2DIR,/DIR) EQ 0 THEN CONTINUE
    OUTDIR = REPLACE(DIR, !S.SST, !S.MAIN + 'ARCHIVE/DATASETS_ARCHIVE/R2019/SST/')
    DIR_TEST, OUTDIR
    EXCLUDE = STRJOIN('--exclude ' + ['SUSPECT','OLD_STATS','OLD_ANOMS','PROCESS','TEMP','THUMBNAILS','D3','*.*']+SL,SP)

    CMD = 'rsync -aviu ' + EXCLUDE + SP + L2DIR + SP + OUTDIR
    P, CMD
 ;   CMD = 'rsync -aviu --exclude {OLD_STATS,OLD_ANOMS,PROCESS,TMEP,THUMBNAILS,D3} --exclude *.* ' + L2DIR + SP + OUTDIR
  ;  P, CMD
    SPAWN, CMD

  ENDFOR






end