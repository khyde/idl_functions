; $ID:	BIN2LONLAT.PRO,	MARCH 11,2012 	$
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
; BIN2LONLAT COMPUTES THE LATITUDE/LONGITUDE VALUES FOR AN ARRAY OF BIN NUMBERS.
; CALLING SEQUENCE:
;
; INPUTS:
;   VALUES: INPUT DATA/VALUES
; DESCRIBE ANY OPTIONAL INPUTS NEXT 
; OPTIONAL INPUTS:
;   NONE: 
;   
; DESCRIBE ANY KEYWORDS USED NEXT
; KEYWORD PARAMETERS:
;   DEMO: MAKES A MULTI-PANEL PLOT OF THE LATBIN,NUMBIN,BASEBIN,LAT,LON VALUES
; OUTPUTS:
;   
; EXAMPLES: 
;         BIN2LONLAT,2160,INDGEN(2160),/DEMO
; 
; MODIFICATION HISTORY:
;    WRITTEN BY J. GALES, FUTURETECH CORP.. AND B. A. FRANZ, SAIC GENERAL SCIENCES CORP..
;     DEC 21,2011  J.O'REILLY &	T. DUCAS [DOCUMENTATION]
;     MAR 11,2012,JOR, ADDED SLIDEW,GRIDS, UPPER CASE, INDENTS, AND DOCUMENTATION

PRO BIN2LONLAT, NROWS,INBIN,OUTLAT,OUTLON, TOTBINS=TOTBINS, DEMO=DEMO
;**********************************************************
ROUTINE_NAME = 'BIN2LONLAT'
;**********************************************************
IF (N_PARAMS() EQ 0) THEN BEGIN
	PRINT, 'BIN2LONLAT, NROWS,BINS,LATITUDE,LONGITUDE'
	PRINT, ' '
	PRINT, 'WHERE NROWS IS THE NUMBER OF RECORDS IN THE BININDEX VDATA'
	PRINT, '      BINS IS THE INPUT ARRAY OF BIN NUMBERS'
	PRINT, '      LATITUDE IS THE OUTPUT ARRAY OF LATITUDE VALUES'
	PRINT, '      LONGITUDE IS THE OUTPUT ARRAY OF LONGITUDE VALUES'
	RETURN
ENDIF

I=INDGEN(NROWS)
LATBIN=FLOAT((I + 0.5) * (180.0D0 / NROWS) - 90.0)
NUMBIN=LONG(COS(LATBIN *!DPI/180.0) * (2.0*NROWS) +0.5)
BASEBIN=LINDGEN(NROWS) & BASEBIN[0]=1
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR I=1,NROWS-1 DO BASEBIN[I]=BASEBIN[I-1] + NUMBIN[I-1]

  TOTBINS = BASEBIN[NROWS-1] + NUMBIN[NROWS-1] - 1
  BASEBIN = [BASEBIN, TOTBINS+1]
  
  N_INBIN = N_ELEMENTS(INBIN)
  
  OUTLAT = FLTARR(N_INBIN)
  OUTLON = FLTARR(N_INBIN)
  
  OLDROW = 1
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR I=0L,N_ELEMENTS(INBIN)-1 DO BEGIN

BIN=LONG(INBIN[I])

IF (BIN GE BASEBIN[OLDROW-1] AND BIN LT BASEBIN[OLDROW]) THEN BEGIN
    ROW = OLDROW
ENDIF ELSE BEGIN
;PRINT,'IN BISECT'
    RLOW = 1
    RHI = NROWS
	ROW = -1
	;WWWWWWWWWWWWWWWWWWWWWWWWWWWWW
    WHILE (ROW NE RLOW) DO BEGIN
      RMID = (RLOW + RHI - 1) / 2
      IF (BASEBIN[RMID] GT BIN)  THEN RHI = RMID ELSE RLOW = RMID + 1

      IF (RLOW EQ RHI) THEN  BEGIN
	ROW = RLOW
	OLDROW = ROW
      ENDIF

ENDWHILE;WHILE (ROW NE RLOW) DO BEGIN
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

ENDELSE;IF (BIN GE BASEBIN[OLDROW-1] AND BIN LT BASEBIN[OLDROW]) THEN BEGIN



  LAT = LATBIN[ROW-1]
  LON = 360.0 * (BIN - BASEBIN[ROW-1] + 0.5) / NUMBIN[ROW-1]

  LON = LON - 180
;  *LON = *LON + SEAM_LON;  /* NOTE, *LON RETURNED HERE MAY BE IN 0 TO 360 */

	OUTLAT[I] = LAT
	OUTLON[I] = LON

;PRINT,BIN,ROW,LAT,LON




ENDFOR;FOR I=0L,N_ELEMENTS(INBIN)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
LAT = OUTLAT
LON = OUTLON


;IIIIIIIIIIIIIIIIIIIIIIIIIIIIII
IF KEYWORD_SET(DEMO) THEN BEGIN
  SLIDEW,[3600, 3000]
  
 !P.MULTI=[0,2,3]
 PLOT, LATBIN,TITLE='LATBIN',PSYM=3,CHARSIZE=5.0
 GRIDS
 R= COORD_2PLOT(0,0) 
 XYOUTS,R.X,R.Y,'N='+ROUNDS(N_ELEMENTS(LATBIN)),CHARSIZE=4
 PLOT, NUMBIN,TITLE='NUMBIN',PSYM=3,CHARSIZE=5.0
 GRIDS
 R= COORD_2PLOT(0,0) 
 XYOUTS,R.X,R.Y,'N='+ROUNDS(N_ELEMENTS(NUMBIN)),CHARSIZE=4
 PLOT, BASEBIN,TITLE='BASEBIN',PSYM=3,CHARSIZE=5.0
 GRIDS
 R= COORD_2PLOT(0,0) 
 XYOUTS,R.X,R.Y,'N='+ROUNDS(N_ELEMENTS(BASEBIN)),CHARSIZE=4
 PLOT, OUTLAT,TITLE='LAT',PSYM=3,CHARSIZE=5.0
 GRIDS
 GRIDS
 R= COORD_2PLOT(0,0) 
 XYOUTS,R.X,R.Y,'N='+ROUNDS(N_ELEMENTS(LAT)),CHARSIZE=4

 PLOT, OUTLON,TITLE='LON',PSYM=3,CHARSIZE=5.0
 R= COORD_2PLOT(0,0) 
 XYOUTS,R.X,R.Y,'N='+ROUNDS(N_ELEMENTS(LON)),CHARSIZE=4
ENDIF;IF KEYWORD_SET(DEMO) THEN BEGIN
;IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII


RETURN
END; #####################  END OF ROUTINE ################################



