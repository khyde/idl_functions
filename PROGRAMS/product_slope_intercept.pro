; print out slope , intercept and scaling for each product

PRO PRODUCT_SLOPE_INTERCEPT



METHOD = 'repro3'
AFILE = 'I:\seawifs_nec\repro3\save\S2001217180927.all.nec.save'
;AFILE = 'E:\czcs_nec\gehs\save\C1978310163820_GEHS_ALL_NEC.save'
SD=READALL(AFILE)
NAMES = STRUPCASE(TAG_NAMES(SD))

stop
PRINT, 'METHOD:  ', METHOD
PRINT, ''
FOR N=0L,N_ELEMENTS(NAMES)-1L DO BEGIN
      NAME = NAMES(N)
      CMD = 'PROD=SD.'+ NAME & A=EXECUTE(CMD)
      PRINT, ''
      PRINT, ''
      PRINT, 'PRODUCT:     ',NAME
      PRINT, '  SLOPE:     ',PROD.SLOPE
      PRINT, '  INTERCEPT: ',PROD.INTERCEPT
      PRINT, '  SCALING:   ',PROD.SCALING
ENDFOR
END
