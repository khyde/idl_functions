; $Id: SET_PMULTI.pro, December 22,1999  J.O'Reilly

  PRO SET_PMULTI, N, LIMIT=LIMIT, LANDSCAPE=landscape
;+
; NAME:
;       SET_PMULTI
;
; PURPOSE:
;       Set up !P.MULTI to Optimize Size of individual Plots in a Multi Panel Plot.
;
; CATEGORY:
;       Plotting
;
; CALLING SEQUENCE:
;       SET_PMULTI
;       SET_PMULTI, /landscape
;       SET_PMULTI, /landscape, limit = 160
;
; INPUTS:
;       N : NUMBER OF PLOTS PER PAGE
;       (If N has more elements than 1 then program will base panels on N_ELEMENTS(n) )
;
; KEYWORD PARAMETERS:
;       LANDSCAPE:  Make landscape !P.MULTI
;       LIMIT:      Maximum Number of Plots per page (Default = 80)
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       Changes !P.MULTI SYSTEM VARIABLE.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, December 23,1999
;-



; ===> IF NUMis not provided then Set !P.MULTI TO 0
  IF N_ELEMENTS(N) LT 1 THEN NUM= 0 ELSE NUM = N

; ===> IF no limit provided then use the default of 80 plots per panel plot
  IF N_ELEMENTS(LIMIT) EQ 1 THEN LIMIT = LIMIT ELSE LIMIT = 80

; ===> If an array is passed as N then determine the number of plots from
; the size of the array
  IF N_ELEMENTS(NUM) EQ 2 THEN BEGIN
    !P.MULTI = 0
    !P.MULTI = [0,NUM]
  ENDIF ELSE BEGIN

; ===> Determine columns and rows for !P.MULTI
  COLS = FLOOR( SQRT(NUM+ SQRT(NUM)))
  ROWS = CEIL(SQRT(NUM))

  IF KEYWORD_SET(LANDSCAPE) THEN BEGIN
    _COLS = ROWS &  ROWS = COLS &  COLS  = _COLS
  ENDIF
  !P.MULTI = [0,COLS,ROWS]

  ENDELSE
  END ; End of Program
