  PRO PROJECT_MAKE_PNG, VERSTR, PRODS=PRODS, TYPES=TYPES, MAPP=MAPP, $
  YEARS=YEARS, MONTHS=MONTHS, WEEKS=WEEKS, DAYS=DAYS, YEAR_COMBO=YEAR_COMBO, DATERANGE=DATERANGE, $
  BUFFER=BUFFER, CURRENT=CURRENT, DIR_OUT=DIR_OUT, $
  SPACE=SPACE, LEFT=LEFT, RIGHT=RIGHT, TOP=TOP, BOTTOM=BOTTOM, NCOLS=NCOLS, NROWS=NROWS, XDIM=XDIM, YDIM=YDIM, $
  TITLE_TXT=TITLE_TXT, RESIZE=RESIZE, _REF_EXTRA=EXTRA

;+
; NAME:
;   PROJECT_MAKE_PNG
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   PROJECT_FUNCTIONS
;
; CALLING SEQUENCE:
;   PROJECT_MAKE_PNG,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 27, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Sep 27, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'PROJECT_MAKE_PNG'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  IF ~N_ELEMENTS(DIR_OUT) THEN DIROUT = VERSTR.DIRS.DIR_PNGS ELSE DIROUT = DIR_OUT

  IF ~N_ELEMENTS(MAPP) THEN MPS = VERSTR.INFO.MAP_OUT ELSE MPS = MAPP

  FOR M=0, N_ELEMENTS(MPS)-1 DO BEGIN
    MP = MPS[M]
    IF N_ELEMENTS(MPS) GT 1 THEN ODIR = DIROUT + MP + SL ELSE ODIR =DIROUT & DIR_TEST, ODIR
    MR = MAPS_READ(MP)
    MR_DIMS  = FLOAT(STRSPLIT(MR.IMG_DIMS,';',/EXTRACT))
    XX = MR_DIMS[0]/MR.PX & YY = MR_DIMS[1]/MR.PY
    IF ~N_ELEMENTS(RESIZE) THEN RESZ = 0.85 ELSE RESZ = RESIZE

    IF ~N_ELEMENTS(DATERANGE) THEN DTR = GET_DATERANGE(VERSTR.INFO.YEAR) ELSE DTR = GET_DATERANGE(DATERANGE)
    YRS = DATE_2YEAR(DTR)
    YRS = YRS[UNIQ(YRS)]
    IF N_ELEMENTS(YEARS) GT 0 THEN BEGIN
      YRS = YEARS
    ENDIF
    
    PERS = []
    CASE 1 OF
      KEYWORD_SET(WEEKS): BEGIN
        IF N_ELEMENTS(WEEKS) EQ 1 AND WEEKS[0] EQ 1 THEN WKS = ADD_STR_ZERO(INDGEN(51)+2) ELSE WKS = WEEKS
        FOR Y=0, N_ELEMENTS(YRS)-1 DO PERS = [PERS,'W_' + YRS[Y] + WKS]
      END
      KEYWORD_SET(DAYS): BEGIN
        IF N_ELEMENTS(DAYS) EQ 1 AND DAYS[0] EQ 1 THEN DYS = CREATE_DATE(DTR[0],DTR[1]) ELSE DYS = DAYS
        PERS = [PERS,'D_' + STRMID(DYS,0,8)]
      END
      KEYWORD_SET(MONTHS): BEGIN
        IF N_ELEMENTS(MONTHS) EQ 1 AND MONTHS[0] EQ 1 THEN MTHS = MONTH_RANGE(DATE_2MONTH(DTR[0]),DATE_2MONTH(DTR[1]),/STRING) ELSE MTHS = MONTHS
        FOR Y=0, N_ELEMENTS(YRS)-1 DO PERS = [PERS,'M_' + YRS[Y] + MTHS]
      END
    ENDCASE
    PERS = DATE_SELECT(PERS,DTR)
    
    IF ~N_ELEMENTS(PRODS) THEN PRDS = VERSTR.INFO.PNG_PRODS ELSE PRDS = PRODS
    IF KEYWORD_SET(COMBO_YEARS) AND N_ELEMENTS(PRDS) EQ 1 THEN PRDS = [PRDS,PRDS]
    IF ~N_ELEMENTS(TYPES) THEN TYPS = ['STACKED_STATS','STACKED_ANOMS']     ELSE TYPS = TYPES
    NFILES = N_ELEMENTS(PRDS)*N_ELEMENTS(TYPS)

    FOR K=0, N_ELEMENTS(PERS)-1 DO BEGIN
      PER = PERIOD_2STRUCT(PERS[K])
      IF DATE_2JD(PER.DATE_START) GT DATE_NOW(/JD) THEN CONTINUE

      DR = [PER.DATE_START,PER.DATE_END]
      TPS = TYPS
      CASE PER.PERIOD_CODE OF
        'M': TXT = MONTH_NAMES(PER.MONTH_START)
        'W': TXT = 'Week ' + STRMID(PER.PERIOD,6,2) + ': ' + STRMID(PER.DATE_START,0,8) + ' - ' + STRMID(PER.DATE_END,0,8)
        'D': BEGIN & TXT = (DATE_PARSE(PER.DATE_START)).DASH_DATE & TPS = 'STACKED_SAVE' & END
      ENDCASE
      IF ~N_ELEMENTS(TITLE_TXT) THEN TITLETXT = TXT ELSE TITLETXT = TITLE_TXT
      
      FILES = []
      FOR N=0, N_ELEMENTS(PRDS)-1 DO BEGIN
        PR = PRODS_READ(PRDS[N])
        PSTR = VERSTR.PROD_INFO.(WHERE(TAG_NAMES(VERSTR.PROD_INFO) EQ PR.PROD))
        DSET = PSTR.DATASET
        FOR T=0, N_ELEMENTS(TPS)-1 DO BEGIN
          ATYPE = TPS[T]
          FILE = GET_FILES(DSET,PRODS=PSTR.PROD,PERIOD=PER.PERIOD_CODE,FILE_TYPE=ATYPE, DATERANGE=DTR)
          IF FILE EQ [] THEN FILE = ''
          FILES = [FILES,FILE]
        ENDFOR ; PRODS
      ENDFOR ; TYPES
      
      PNGFILE = ODIR + PER.PERIOD + '-' + MP + '-' + STRJOIN(PRDS,'_') + '-' + STRJOIN(TPS,'_') + '-COMPOSITE' +'.PNG'
      PNGFILE = REPLACE(PNGFILE,'STACKED_','')
      IF ~FILE_MAKE(FILES,PNGFILE,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE) THEN CONTINUE
      OK = WHERE(FILES NE '', COUNT_FILES)
      IF COUNT_FILES EQ 0 THEN CONTINUE

      COUNTER = 0
      FOR N=0, N_ELEMENTS(TPS)-1 DO BEGIN
        ATYPE = TPS[N]
        FOR T=0, N_ELEMENTS(PRDS)-1 DO BEGIN
          PR = PRODS_READ(PRDS[T])
          PSTR = VERSTR.PROD_INFO.(WHERE(TAG_NAMES(VERSTR.PROD_INFO) EQ PR.PROD))
          DSET = PSTR.DATASET
          IF PR.IN_PROD NE PR.PROD THEN PROD_SCALE = PR.IN_PROD ELSE PROD_SCALE = [];PSTR.PROD_SCALE
          ;     IF ATYPE EQ 'ANOMS' THEN PROD_SCALE = PSTR.ANOM_SCALE
          FILE = GET_FILES(DSET,PRODS=PSTR.PROD,PERIOD=PER.PERIOD_CODE,FILE_TYPE=ATYPE, DATERANGE=VERSTR.INFO.YEAR)
          IF FILE EQ [] THEN CONTINUE
          IF N_ELEMENTS(FILE) GT 1 THEN MESSAGE,'ERROR: More that one file found for ' + PSTR.PROD + ' - ' + ATYPE
          FP = PARSE_IT(FILE,/ALL)
          DIR_PNG = VERSTR.DIRS.DIR_PNGS + PR.PROD + SL + ATYPE + SL & DIR_TEST, DIR_PNG
          IPNG = DIR_PNG + REPLACE(FP.NAME +'.PNG',[FP.PERIOD,FP.MAP],[PER.PERIOD,MP])
          IF ~FILE_MAKE(FILE,IPNG,OVERWRITE=OVERWRITE) THEN CONTINUE
          IMG = PROJECT_MAKE_IMAGE(VERSTR, FILE=FILE, DATERANGE=DR,BUFFER=BUFFER, RESIZE=RESZ, MAPP=MP, PROD_SCALE=PROD_SCALE, _EXTRA=EXTRA)

          IF IDLTYPE(IMG) NE 'OBJREF' THEN CONTINUE
          IMG.SAVE, IPNG, RESOLUTION=RESOLUTION
          IMG.CLOSE
        ENDFOR ; PRODS
      ENDFOR ; TYPES    
    ENDFOR ; PERIODS  
  ENDFOR ; MAPS
 
 
 END ; ***************** End of PROJECT_MAKE_PNG *****************
