; $ID:	QUANTILE.PRO,	2020-06-30-17,	USER-KJWH	$

function quantile,array1, array2,  xx=xx, yy=yy, $
                  MISSING=missing  , $ ; missing value
                  LOG  = log ,$        ; for a log transformation
                  NTH  = nth, $        ; Only Plot every nth point (if too many points)
              NO_CURVE= no_curve, $
              NO_ONE2ONE=no_one2one, $  ; ONE2ONE line:
              ONE_COLOR=one_color,$
              ONE_THICK=one_thick,$
              ONE_LINESTYLE=one_linestyle,$
              GRIDS_LINESTYLE = GRIDS_LINESTYLE,$
              GRIDS_COLOR=GRIDS_COLOR,$
              GRIDS_THICK = GRIDS_THICK,$
              QUIET=quiet,$
              _EXTRA=_extra
;+
; NAME:
;       quantile
;
; PURPOSE:
;      Computes Quantiles of an array or
;               Quantiles for two arrays by interpolation of the
;                    largest array to match the number of elements
;                    in the smallest array.
;
;
;    Will remove array(s) values equal to missing code
;
;
;      This follows the approach and terminology used by:
;      Chambers, J.M., W.S. Cleveland, B. Kleiner, P.A. Tukey 1983.
;      Graphical Methods for Data Analysis
;      Wadsworth & Brooks/Cole Publishing Co.
;      Advanced Books & Software, Pacific Grove, CA.
;      (see pages 11-13; 55)
;
; CATEGORY:
;      MATH /STATISTICS
;
; CALLING SEQUENCE:
;       Result = quantile(a)
;       Result = quantile(a, missing = -9)
;       Result = quantile(a, b)    ; To output a matched quantile-quantile for ploting
;       q      = quantile(RANDOMU(SEED,222),RANDOMU(SEED,333))
;
; INPUTS:
;       Array1  (If you want to make a plot of the input array vs quantile(fraction)
;       Array2 (optional) (If you want to make a quantile vs quantile plot of a vs b
;
; KEYWORD PARAMETERS:
;
;       Missing:   value for missing data to be removed from input array(s).
;
; OUTPUTS:
;       If input only 1 array then output is
;          a structure array with the data sorted
;          in TAG X and the fraction value in TAG Y
;       If input 2 arrays then output is
;          a structure array with Quantiles for first array in TAG X
;          and Quantiles for second array in TAG Y
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Array(s) must have 3 or more elements, otherwise missing (infinity) is returned.
;
; PROCEDURE:
;    Example:
;    Try the following in sequence:
;    !P.MULTI=[0,3,3]
;    q=quantile(INDGEN(25)+1,TITLE='Quantile Plot, 25obs')
;    q=quantile(INDGEN(25)+1,INDGEN(25)+1, TITLE = 'Quantile-Quantile Plot, x=25obs,y=25obs')
;    q=quantile(INDGEN(25)+1,INDGEN(30)+1, TITLE = 'Quantile-Quantile Plot, x=25obs,y=30obs')
;    q=quantile(RANDOMN(SEED,25),RANDOMN(SEED,25), TITLE = 'Quantile-Quantile Plot, x=25obs,y=30obs', XTITLE='RANDOM X',YTITLE='RANDOM Y')
;    q=quantile(RANDOMN(SEED,100),RANDOMN(SEED,100), TITLE = 'Quantile-Quantile Plot, x=100obs,y=100obs', XTITLE='RANDOM X',YTITLE='RANDOM Y')
;    q=quantile(RANDOMN(SEED,100),RANDOMN(SEED,1000), TITLE = 'Quantile-Quantile Plot, x=100obs,y=1000obs', XTITLE='RANDOM X',YTITLE='RANDOM Y')
;    q=quantile(RANDOMN(SEED,1000),RANDOMN(SEED,1000), TITLE = 'Quantile-Quantile Plot, x=1000obs,y=1000obs', XTITLE='RANDOM X',YTITLE='RANDOM Y')
;    q=quantile(RANDOMN(SEED,1000),RANDOMN(SEED,1000), TITLE = 'Quantile-Quantile Plot,NTH= 5, x=1000obs,y=1000obs', XTITLE='RANDOM X',YTITLE='RANDOM Y',NTH=5,PSYM=0)
;    q=quantile(RANDOMN(SEED,1000),RANDOMN(SEED,1000), TITLE = 'Quantile-Quantile Plot,NTH=20, x=1000obs,y=1000obs', XTITLE='RANDOM X',YTITLE='RANDOM Y',NTH=20)
;
; ====================>
; Other Programs called:
;       ONE2ONE.PRO  (draws a one to one line)
;
; MODIFICATION HISTORY:
;       Written February 8,1997, J.E. O'Reilly,
;   NOAA, NMFS Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;   oreilly@fish1.gso.uri.edu
;       May 5,1997 Removed _extra keyword from oplot command
;-

; ====================>
; Copy array into data variable (This keeps original array unchanged)
; and remove data values equal to missing value

  IF NOT KEYWORD_SET(MISSING) THEN missing = MISSINGS(array1)
  IF NOT KEYWORD_SET(one_COLOR)     THEN one_COLOR     = !P.COLOR
  IF NOT KEYWORD_SET(one_THICK)     THEN one_THICK     = !P.THICK
  IF NOT KEYWORD_SET(one_LINESTYLE) THEN one_LINESTYLE = 0

  IF NOT KEYWORD_SET(GRIDS_COLOR) THEN GRIDS_COLOR=!P.COLOR
  IF NOT KEYWORD_SET(GRIDS_LINESTYLE) THEN GRIDS_LINESTYLE = !P.LINESTYLE
  IF NOT KEYWORD_SET(GRIDS_THICK) THEN GRIDS_THICK = !P.THICK
; ====================>
; Build a structure array
  q = CREATE_STRUCT('X',MISSINGS(0d),'Y',MISSINGS(0D))

; ====================>
; Remove missing values from array1
  ok = WHERE(array1 NE  missing AND array1 NE MISSINGS(array1), count)
  IF count GE 3 THEN BEGIN
    data1 = TEMPORARY(array1(ok))
    data1 = data1(SORT(data1))
;   Check if KEYWORD LOG
    IF KEYWORD_SET(LOG) THEN data1 = ALOG10(data1)
    n1 = count
    TYPE = 1
    XTITLE='Quantiles, Q(p) of Data' & YTITLE='Fraction of Data, p'
  ENDIF ELSE BEGIN
    PRINT, 'ERROR: Must have 3 or more non-missing elements in Input Array'
    RETURN, q
  ENDELSE

; ====================>
; See if array 2 is present, and remove missing values from array2
  IF N_PARAMS() EQ 2 THEN BEGIN
  ok = WHERE(array2 NE  missing AND array2 NE MISSINGS(array2), count)
  IF count GE 3 THEN BEGIN
    data2 = TEMPORARY(array2(ok))
    data2 = data2(SORT(data2))
;   Check if KEYWORD LOG PROVIDED
    IF KEYWORD_SET(LOG) THEN data2 = ALOG10(data2)
    n2 = count
    TYPE =2
    XTITLE='Quantiles (X)' & YTITLE='Quantiles (Y)'
  ENDIF ELSE BEGIN
    PRINT, 'ERROR: Must have 3 or more non-missing elements in Second Input Array'
    RETURN,q
  ENDELSE
  ENDIF

; ====================>
; If TYPE is 1 then Output sorted Quantiles (data) with their fractions
  IF TYPE EQ 1 THEN BEGIN
    q = REPLICATE(q,n1)
    q(*).X = data1
    q(*).Y = ((LINDGEN(n1)+1)-0.5)/n1
  ENDIF ELSE BEGIN ; If TYPE is not 1 then begin
;   If both arrays have same number of elements then
;   the quantile-quantile plot is just the sorted array values
    IF n1 EQ n2 THEN BEGIN
      q = REPLICATE(q,n1)
      q(*).X = data1
      q(*).Y = data2
    ENDIF
;   If array1 has fewer elements than array2 then
;   the X TAG is the sorted values for the smaller array1 and the
;       Y TAG is the interpolated quantiles for the larger array2
    IF n1 LT n2 THEN BEGIN
      q = REPLICATE(q,n1)
      q(*).X = data1
      v = (DOUBLE(n2)/DOUBLE(n1))*(LINDGEN(n1)+1 -0.5) + 0.5
      j=LONG(v) & theta = v - j
      q(*).Y = (1-theta)*data2(j-1) + theta*data2(j)
    ENDIF
;   If array1 has more elements than array2 then
;       X TAG is the interpolated quantiles for the larger array1 and the
;       Y TAG is the sorted values for the smaller array2
    IF n1 GT n2 THEN BEGIN
      q = REPLICATE(q,n2)
      q(*).Y = data2
      v = (DOUBLE(n1)/DOUBLE(n2))*(LINDGEN(n2)+1 -0.5) + 0.5
      j=LONG(v) & theta = v - j
      q(*).x = (1-theta)*data1(j-1) + theta*data1(j)
    ENDIF
  ENDELSE ; IF TYPE EQ 1

; ====================>
; For purpose of plotting, antilog if log keyword was provided
  IF KEYWORD_SET(LOG) THEN BEGIN
    IF TYPE EQ 2 THEN BEGIN
      _XLOG = 1 & _YLOG = 1
      XX = 10.0^q.x
      yy = 10.0^q.y
    ENDIF ELSE BEGIN
      _XLOG = 1 & _YLOG = 0
      XX = 10.0^q.x
      YY = q.y
    ENDELSE
  ENDIF ELSE BEGIN
    _XLOG = 0 & _YLOG = 0
    XX = q.x
    YY = q.y
  ENDELSE


; ====================>
; Plot every nth point if this keyword is set (E.G. NTH=2,3,4,5 ETC.)
  IF N_ELEMENTS[NTH] EQ 1 THEN BEGIN
    IF N_ELEMENTS(XX)/DOUBLE[NTH] GE 1.0 THEN BEGIN

      N_OBS = N_ELEMENTS(XX)
      subset = LINDGEN(N_OBS) MOD NTH ; AN array of 0,1's
      ok = WHERE(subset EQ 0,COUNT)
      IF SUBSET(N_OBS-1) EQ 0 THEN BEGIN
        XX = XX(ok) & YY = YY(ok)
      ENDIF ELSE BEGIN
        XX = [XX(ok), XX(N_OBS-1)] & YY = [YY(ok), YY(N_OBS-1)]
      ENDELSE
    ENDIF ELSE BEGIN
      PRINT, 'NTH is GREATER THAN SIZE OF DATA ARRAY'
    ENDELSE
  ENDIF

  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    IF KEYWORD_SET(NO_CURVE) THEN BEGIN
      PLOT,  xx,yy ,PSYM=1,/NODATA, XLOG=_XLOG, YLOG=_YLOG,$
             XTITLE=xtitle, YTITLE=ytitle,$
             XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET, _extra=_extra

     GRIDS,XTICK_GET,YTICK_GET,COLOR=GRIDS_COLOR,LINESTYLE=GRIDS_LINESTYLE,THICK=GRIDS_THICK
      IF TYPE EQ 2 AND NOT KEYWORD_SET(NO_ONE2ONE) THEN ONE2ONE, COLOR=one_COLOR , THICK=one_thick, LINESTYLE= one_linestyle

      OPLOT,  xx,yy ,PSYM=1, _EXTRA=_EXTRA
    ENDIF ELSE BEGIN
      PLOT,  xx,yy ,PSYM=1,/NODATA, XLOG=_XLOG, YLOG=_YLOG,$
             XTITLE=xtitle, YTITLE=ytitle,$
              XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET, _extra=_extra

      GRIDS,XX=XTICK_GET,YY=YTICK_GET,COLOR=GRIDS_COLOR,LINESTYLE=GRIDS_LINESTYLE,THICK=GRIDS_THICK
      IF TYPE EQ 2 AND NOT KEYWORD_SET(NO_ONE2ONE) THEN ONE2ONE, COLOR=one_COLOR , THICK=one_thick, LINESTYLE= one_linestyle
      OPLOT, xx,yy, PSYM=0, _EXTRA=_EXTRA
    ENDELSE

; ====================>
; OVERPLOT ONE2ONE line.


  ENDIF

 RETURN, q

END

