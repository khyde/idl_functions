; $Id: ROBUST_REG.pro $  Jan 13,2003
;+
;	This Function Iteratively Discards xy pairs that are farthest (perpendicular distance) from a functional regression line
; SYNTAX:
;
;	Result = ROBUST_REG, xarray,yarray, [TRIM=trim],[ITER=iter], [PERCENT=percent],$
;                     	[RSQ=rsq],$
;                     	[REJECTS=rejects],$
;                     	[STATISTICS=statistics],$
;                     	[SHOW=show])
; OUTPUT:
; ARGUMENTS:
; 	Xarray:		X array
; 	Yarray:		Y array
; KEYWORDS:
;	TRIM:				Number of points to trim
;	ITER:				Number of times to trim by the TRIM Percent
;	PERCENT:		Translates TRIM as a Percentage of Points to TRIM
;	MAX_TRIM:		Limits the total number of rejects to MAX_TRIM (PREEMPTS RSQ)
;	RSQ:				Final R-square to be reached (to terminate iteration)
;	REJECTS:		Subscripts of resulting statistical outliers
;	STATISTICS:	Bivariate Statistics
;	SHOW:				Show (plot) scatter plot and regression after each iteration
; EXAMPLE:
;	Make an x and y array:
;	x= [findgen(200)+randomn(seed,200)*10,   152,162,172,192]
;	y= [findgen(200)+randomn(seed,200)*10,   51,  52, 54, 55]
;	Trim 4 outliers (TRIM=4), Plot points and stats before and after trim (SHOW=1),
;		Return Subscripts of remaining xy pairs (Result) and subscripts of Rejected data (REJECTS),
;		Result=robust_reg(X,Y,TRIM=4,/SHOW, statistics=STATISTICS, REJECTS=rejects)
;
;	Trim 1 outlier (TRIM=1) 4 times (ITER=4), Plot points and stats before and after trim (SHOW=1),
;		Result=robust_reg(X,Y,TRIM=1,ITER=4,/SHOW, statistics=STATISTICS, REJECTS=rejects)
;
;	Trim 1.5 Percent (TRIM=1.5,/PERCENT) of the outliers, Plot points and stats before and after trim (SHOW=1),
;		Result=robust_reg(X,Y, TRIM=1.5,/PERCENT,/SHOW, statistics=STATISTICS, REJECTS=rejects)
;
;
;	Trim 0.4 Percent four times (TRIM=0.4,/PERCENT,ITER=4), Plot points and stats before and after trim (SHOW=1),
;		Result=robust_reg(X,Y, TRIM=0.4,ITER=4,/PERCENT,/SHOW, statistics=STATISTICS, REJECTS=rejects)
;
;	Trim one point at a time until an R-square of 0.95 is achieve
;	Result=robust_reg(X,Y, TRIM=1, RSQ=.95,/SHOW, statistics=STATISTICS, REJECTS=rejects)
;
;	Trim one percent of points each time until an R-square of 0.95 is achieved
;	Result=robust_reg(X,Y, TRIM=1,/PERCENT, RSQ=.95,/SHOW, statistics=STATISTICS, REJECTS=rejects)

; CATEGORY:
;	STATISTICS
; NOTES:
;		It is generally better to trim a few points with many interations than
;   trim many points few iterations.
;
; VERSION:
;		June 11, 2001
; HISTORY:
;		June 11, 2001 JOR: If initial RSQ exceeds percent then all subscripts are valid and returned
;		Jun 22, 1999	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Aug 13, 2001 added STATS_FIRST
;		Jan 13,2003; moved IMPROVED = 0  to top
;-
; *************************************************************************

FUNCTION ROBUST_REG,xarray,yarray, TRIM=trim,ITER=ITER, PERCENT=percent,MAX_TRIM=max_trim,$
                     RSQ=rsq,$
                     REJECTS=rejects,$
                     STATS_FIRST=stats_first,$
                     STATISTICS=statistics,$
                     SHOW=show

  ROUTINE_NAME='ROBUST_REG'


  IF N_ELEMENTS(TRIM) EQ 0 THEN TRIM = 1
  IF KEYWORD_SET(PERCENT) THEN TRIM = (TRIM/100.0) * N_ELEMENTS(XARRAY)
  IF N_ELEMENTS(ITER) NE 1 THEN ITER = 1
  IF ITER LT 1 THEN ITER = 1
  IF N_ELEMENTS(MAX_TRIM) NE 1 THEN MAX_TRIM = N_ELEMENTS(XARRAY)

  XX = XARRAY
  YY = YARRAY
  N_OBS = N_ELEMENTS(XX)

  SUBS = LINDGEN(N_OBS)
  ALL  = SUBS

	IMPROVED = 0

; ===>COMPUTE INITIAL STATS
  _STATS = STATS2(XX,YY,/QUIET,/FAST)
  STATS_FIRST=_STATS(4)


  IF N_ELEMENTS(SHOW) EQ 1 THEN BEGIN
    PLOTXY, XX,YY,PSYM=1,DECIMALS=3,PARAMS=[1,2,3,4,8,10],/QUIET,/FAST
    WAIT,SHOW
  ENDIF


; ***************************************
  IF N_ELEMENTS(RSQ) NE 1 THEN BEGIN
    FOR N=0,ITER-1 DO BEGIN
      STAT=STATS2(XX,YY,/QUIET,/FAST)
      STAT=STAT(4)
      _RSQ = STAT.RSQ
      dist=DISTPERP(XX,YY,STAT.INT,STAT.SLOPE)
      S = SORT(ABS(DIST))
      XX = XX(S)
      YY = YY(S)
      SUBS = SUBS(S)
      _FIRST= N_ELEMENTS(SUBS)-TRIM
      _LAST = N_ELEMENTS(SUBS)-1L
      IF N_ELEMENTS(BAD) EQ 0 THEN BAD = SUBS(_FIRST:_LAST) ELSE BAD = [BAD, SUBS(_FIRST:_LAST)]
      NUM = N_ELEMENTS(XX) -TRIM -1L
      XX = XX(0:NUM)
      YY = YY(0:NUM)
      SUBS = SUBS(0:NUM)
      IF KEYWORD_SET(SHOW) THEN BEGIN
        PLOTXY, XX,YY,PSYM=1,DECIMALS=3,PARAMS=[1,2,3,4,8],/QUIET,/FAST
        WAIT,SHOW
      ENDIF
    ENDFOR
    IF N_ELEMENTS(BAD) GE 1 THEN IMPROVED = 1
  ENDIF ELSE BEGIN

    _RSQ = 0.0

    WHILE _RSQ LT RSQ DO BEGIN
      STAT=STATS2(XX,YY,/QUIET,/FAST)
      STAT=STAT(4)
      _RSQ = STAT.RSQ
      NUM_DISCARDED = (N_OBS - STAT.N)
      IF _RSQ GE RSQ OR NUM_DISCARDED GE MAX_TRIM THEN GOTO, DONE
      dist=DISTPERP(XX,YY,STAT.INT,STAT.SLOPE)
      S = SORT(ABS(DIST))
      XX = XX(S)
      YY = YY(S)
      SUBS = SUBS(S)
      _FIRST= N_ELEMENTS(SUBS)-TRIM
      _LAST = N_ELEMENTS(SUBS)-1L
      IF N_ELEMENTS(BAD) EQ 0 THEN BAD = SUBS(_FIRST:_LAST) ELSE BAD = [BAD, SUBS(_FIRST:_LAST)]
      NUM = N_ELEMENTS(XX) -TRIM -1L
      XX = XX(0:NUM)
      YY = YY(0:NUM)
      SUBS = SUBS(0:NUM)
      IF KEYWORD_SET(SHOW) THEN BEGIN
        PLOTXY, XX,YY,PSYM=1,DECIMALS=3,PARAMS=[1,2,3,4,8],/QUIET,/FAST
        WAIT,show
      ENDIF
      IMPROVED = 1
    ENDWHILE
  ENDELSE ; RSQ


  DONE:
  statistics=stat

; ====================>
; Now get subscripts of rejects
  IF IMPROVED EQ 0 THEN BEGIN
    SUBS = LINDGEN(N_ELEMENTS(XARRAY))
    REJECTS = -1
  ENDIF ELSE BEGIN
    I=LONARR(N_ELEMENTS(XARRAY))
  	I(BAD) = 1
  	OK = WHERE(I EQ 1,COUNT)
  	IF COUNT GE 1 THEN REJECTS = OK ELSE REJECTS = -1
  ENDELSE

  RETURN, SUBS


END; #####################  End of Routine ################################