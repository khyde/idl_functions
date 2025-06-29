; $ID:	JUNK_INTERP.PRO,	2020-04-14-13,	USER-KJWH	$
PRO JUNK_INTERP

  SL = PATH_SEP()
  DIR = !S.DEMO + 'JUNK_INTERPX' + SL & DIR_TEST, DIR
  DIR_SAV = DIR + 'NEC' + SL + 'SAVE' + SL + 'PAR' + SL & DIR_TEST, DIR_SAV
  DIR_ISAV = DIR + 'INTPER_SAVE' + SL & DIR_TEST, DIR_ISAV
  DIR_PNG = DIR + 'PNG' + SL & DIR_TEST, DIR_PNG

  DATERANGE = ['20180101','20180630']
  F = FLS(!S.OC + 'MODISA/L3B2/NC/PAR/A2018*',DATERANGE=DATERANGE)
  LI, F
  
  SAVE_MAKE_L3, F, PRODS='PAR',DIR_OUT=DIR,MAP_OUT='NEC'
  
  FLS = FLS(DIR_SAV + 'D_*',DATERANGE=DATERANGE)
  FP = PARSE_IT(FLS)
  LI, FLS
  
  IFLS=DIR_ISAV+FP.NAME+'-INTERP.SAV'
  IF FILE_MAKE(FLS,IFLS,OVERWRITE=OVERWRITE) EQ 0 THEN GOTO, SKIP_D3
  
  D3_MAKE, FLS, D3_PROD='PAR', DIR_OUT=DIR, D3_FILE=D3_FILE, INIT=INIT, L3BMAP=L3BMAP, MED_FILL=MEDFILL, FIXNOISE=FIXNOISE, OVERWRITE=OVERWRITE
  D3_INTERP, D3_FILE, SPAN=SPAN, D3_INTERP_FILE=D3_INTERP_FILE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGFILE=LOGFILE
  D3_SAVES, D3_INTERP_FILE, DIR_SAV=DIR_ISAV, DATERANGE=DATERANGE, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE, LOGFILE=LOGFILE
  
  SKIP_D3:
  IP = PARSE_IT(IFLS,/ALL)
  
  FOR N=0, N_ELEMENTS(FLS)-1 DO BEGIN
    OFILE = FLS(N)
    FP = PARSE_IT(OFILE,/ALL)
    I = IP[WHERE(IP.PERIOD EQ FP.PERIOD,/NULL)]
    IFILE = I.FULLNAME

    PNGFILE = DIR_PNG+I.NAME+'_COMPARE.PNG'
    IF FILE_MAKE([OFILE,IFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
    W = WINDOW(DIMENSIONS=[1024,512],BUFFER=BUFFER)
    PRODS_2PNG, OFILE, PROD=APROD, /CURRENT, IMG_POS=[0,0,.5,1], MAPP=OMAP, /ADD_NAME, /ADD_CB, /CB_RELATIVE, CB_SIZE=TXT_SZ, TXT_SIZE=TXT_SZ
    PRODS_2PNG, IFILE, PROD=APROD, /CURRENT, IMG_POS=[.5,0,1,1], MAPP=OMAP, /ADD_NAME, /ADD_CB, /CB_RELATIVE, CB_SIZE=TXT_SZ, TXT_SIZE=TXT_SZ
    W.SAVE, PNGFILE
    W.CLOSE
    PFILE, PNGFILE
    
  ENDFOR
  
  
  
  
  STOP

END
