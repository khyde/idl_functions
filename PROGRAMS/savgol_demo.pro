; $ID:	SAVGOL_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
PRO Savgol_DEMO
ROUTINE_NAME = 'SAVGOL_DEMO'

DO_SAVGOL_DOC = 0
DO_SAVGOL_LOW = 0
DO_SHOW_FILTER =  0

;**********************************
IF DO_SHOW_FILTER GE 1 THEN BEGIN
;**********************************
PAL = 'PAL_36'
RESOLVE_ROUTINE,'PLOT',/IS_FUNCTION
COLORS = ['MEDIUM_VIOLET_RED','MIDNIGHT_BLUE','MISTY_ROSE','RED','GREEN','BROWN','GOLD','GREEN']
DEGREES = [1,2,3]

;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR NTH = 0,N_ELEMENTS(DEGREES)-1 DO BEGIN
  DEGREE = DEGREES[NTH]

TITLE = 'SAVGOL FILTER VS. NUM [DEGREE = ' + ROUNDS(DEGREE) + ']'

;FFFFFFFFFFFFFFFFFFFFF
FOR NUM = 1,5 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFF 
COLOR = COLORS(NUM)
IF DEGREE EQ 3 THEN NLEFT = NUM+ 1 ELSE NLEFT = NUM
NRIGHT = NLEFT & ORDER = 0  & DEGREE = DEGREE & DOUBLE = 1

FILTER = SAVGOL( NLEFT, NRIGHT, ORDER, DEGREE,DOUBLE=DOUBLE )


X = REPLICATE(NUM,N_ELEMENTS(FILTER))
;SMO = CONVOL(DATA, FILTER, /EDGE_TRUNCATE,/CENTER)
P = PLOT(FILTER,COLOR= COLOR,THICK = 9,/CURRENT,/OVERPLOT,$
TITLE = TITLE,XTITLE = 'FILTER-POSITION',YTITLE = 'WEIGHTING')
TXT =  ROUNDS(NUM)
T = TEXT(NUM,MAX(FILTER),/DATA,TXT,COLOR= COLOR,FONT_SIZE = 21,ALIGNMENT = 1.0)

ENDFOR;FOR NUM = 1,5 DO BEGIN
;||||||||||||||||||||||||||||
PNGFILE = !S.IDL_TEMP + ROUTINE_NAME +'-DEGREE-'+ROUNDS(DEGREE)+ '.PNG'
P.SAVE,PNGFILE
P.CLOSE
PFILE,PNGFILE
IF NONE(ALL) THEN ALL = PNGFILE ELSE ALL = [ALL,PNGFILE]
ENDFOR;FOR NTH = 0,N_ELEMENTS(DEGREES)-1 DO BEGIN
IMG_MERGE,ALL,MARGIN = 0.05
ENDIF;IF DO_SHOW_FILTER GE 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||


;*****************************************
IF DO_SAVGOL_DOC GE 1 THEN BEGIN
;*****************************************
; FROM          .EDIT savgol_doc.pro.

  n = 401 ; number of points
  np = 4  ; number of peaks
  
  ; Form the baseline:
  y = REPLICATE(0.5, n)
  
  ; Sampling interval:
  dt = 0.1
  
  ; Index the array:
  x = dt*FINDGEN(n)
  
  ; Add each Gaussian peak:
  FOR i=0, np-1 DO BEGIN
    c = dt*(i + 0.5) * FLOAT(n)/np; Center of peak
    peak = 3 * (x-c) / (dt*(75. / 1.5 ^ i))
    ; Add Gaussian. Cutoff of -50 avoids underflow errors for
    ; tiny exponentials:
    y = y + EXP((-peak^2)>(-50))
  ENDFOR
  
  ; Add noise:
  y1 = y + 0.10 * RANDOMN(-121147, n)
  
  ; Display first plot
  iPlot, x, y1, NAME='Signal+Noise', VIEW_GRID=[1,2], $
   DIMENSIONS=[500,800]
  
  
  ; Get an object reference to the iTool and insert legend.
  void = ITGETCURRENT(TOOL=oTool)
  void = oTool->DoAction('Operations/Insert/Legend')
  
  iPlot, x, SMOOTH(y1, 33, /EDGE_TRUNCATE), /OVERPLOT, $
    COLOR=[255, 0, 0], $
    NAME='Smooth (width 33)'
  void = oTool->DoAction('Operations/Insert/LegendItem')
  
  ; Savitzky-Golay with 33, 4th degree polynomial:
  savgolFilter = SAVGOL(16, 16, 0, 4)
  iPlot, x, CONVOL(y1, savgolFilter, /EDGE_TRUNCATE), /OVERPLOT, $
    COLOR=[0, 0, 255], THICK=2, $
    NAME='Savitzky-Golay (width 33, 4th degree)'
  void = oTool->DoAction('Operations/Insert/LegendItem')
  
  iPlot, x, DERIV(x, DERIV(x, y)), YRANGE=[-4, 2], /VIEW_NEXT, $
    NAME='Second derivative'
    
  void = oTool->DoAction('Operations/Insert/Legend')
  
  order = 2
  ; Don't forget to normalize the coefficients.
  savgolFilter = SAVGOL(16, 16, order, 4)*(FACTORIAL(order)/ $
    (dt^order))
  iPlot, x, CONVOL(y1, savgolFilter, /EDGE_TRUNCATE), /OVERPLOT, $
    COLOR=[0, 0, 255], THICK=2, $
    NAME='Savitzky-Golay(width 33, 4th degree, order 2)'
  void = oTool->DoAction('Operations/Insert/LegendItem')
  
  ; Reposition the legends
  ITRANSLATE, 'legend*', X=-100, /DEVICE
  
  ENDIF; IF DO_SAVGOL_DOC GE 1
  ;|||||||||||||||||||||||||||||||||
  ;
  ;
  ;
  ;
;*****************************************
IF DO_SAVGOL_LOW GE 1 THEN BEGIN
;*****************************************

  Plot, x, CONVOL(y1, savgolFilter, /EDGE_TRUNCATE), /OVERPLOT, $
    COLOR=[0, 0, 255], THICK=2, $
    NAME='Savitzky-Golay(width 33, 4th degree, order 2)'
  void = oTool->DoAction('Operations/Insert/LegendItem')
  
  ; Reposition the legends
  ITRANSLATE, 'legend*', X=-100, /DEVICE
  
  ENDIF; IF DO_SAVGOL_LOW GE 1
  ;|||||||||||||||||||||||||||||||||
  
  
  
END
