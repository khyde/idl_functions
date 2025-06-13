PRO JUNK_FILES_CHANGE_STRUCT_VARIABLE, DATERANGE, REV=REV

PRODS=['ADG','APH','ATOT','APH','BBP']
WAVES = ['412','443','490','510','555','670']

for i=0, n_elements(prods)-1 do begin
  dir_out = !S.OC + 'OCCCI/L3B4/SAVE/' + PRODS[i] + '-QAA/' & DIR_TEST, DIR_OUT
  f = fls(!S.oc + 'OCCCI/L3B4/SAVE/' + PRODS[i] + '/*.SAV',daterange=daterange) & help, f
  IF KEY(REV) THEN f = reverse(f)
  for n=0, N_elements(f)-1 do begin
    if exists(replace(F[N],prods[i],prods[i]+'-QAA')) then continue
    d = IDL_RESTORE(f[n]) 
    d.name = d.name + '-QAA'
    D.ALG = 'QAA'
    SAVE, FILENAME=replace(F[N],prods[i],prods[i]+'-QAA'), D
    PFILE, F[N]
  endfor
ENDFOR
stop

  IF NONE(DATERANGE) THEN DR = SENSOR_DATES('OCCCI') ELSE DR = DATERANGE
  F = GET_FILES('OCCCI',PROD='CHLOR_A-OCI',PERIODS=[],FILE_TYPE='STAT',DATERANGE=DR,COUNT=CT)
  IF CT GT 1 THEN BEGIN
    FP = FILE_PARSE(F[0])
    DIR_TEST, REPLACE(FP.DIR, 'CHLOR_A-OCI','CHLOR_A-CCI')
   
    IF KEY(REV) THEN F = REVERSE(F)
    FOR N=0, N_ELEMENTS(F)-1 DO BEGIN
      AFILE = REPLACE(F[N],'-OCI','-CCI')
      IF FILE_MAKE(F[N],AFILE) EQ 0 THEN CONTINUE
      D = IDL_RESTORE(F[N])
      IF IDLTYPE(D) EQ 'STRING' THEN BEGIN
        IF HAS(D[0],'RESTORE: Error') THEN BEGIN
          FILE_DELETE, F[N]
          CONTINUE
        ENDIF ELSE BEGIN
          PRINT, D[0]
          STOP
        ENDELSE
      ENDIF
      IF HAS(D,'ALG') THEN IF D.ALG EQ 'OCI' THEN D.ALG = 'CCI'
      D.PROD = 'CHLOR_A'
      IF HAS(D,'INFILES') THEN D.INFILES = REPLACE(D.INFILES,'-OCI','-CCI')
      SAVE, FILENAME=AFILE, D, /COMPRESS
      PFILE, AFILE, /W
    ENDFOR
  ENDIF  

  F = GET_FILES('OCCCI',PROD='PPD-VGPM2',PERIODS=[],FILE_TYPE='STATS',DATERANGE=DR,COUNT=CT)
  IF COUNT GT 1 THEN BEGIN
  
    FP = FILE_PARSE(F[0])
    
    JD_NOW = DATE_2JD('20200813120000')
    IF KEY(REV) THEN F = REVERSE(F)
    FOR N=0, N_ELEMENTS(F)-1 DO BEGIN
      
      IF GET_MTIME(F[N],/JD) GT JD_NOW THEN CONTINUE
      D = IDL_RESTORE(F[N])
      IF HAS(D,'INFILE') THEN D.INFILE = REPLACE(D.INFILE,'-OCI','-CCI')
      SAVE, FILENAME=F[N], D, /COMPRESS
      PFILE, AFILE, /W
    ENDFOR
  ENDIF


END