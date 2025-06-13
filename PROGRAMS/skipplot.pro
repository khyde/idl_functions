; $ID:	SKIPPLOT.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO SKIPPLOT,skips
;+
; NAME:
;       skipplot
;
; PURPOSE:
;       When !p.multi in effect, skips over the next plot frame
;				Or skips backward to previous

;	SKIPPLOT,1  ; Skips over the next plot position on the page
;	SKIPPLOT,2  ; Skips over the next 2 plot positions
;	SKIPPLOT,0  ; Nothing
;	SKIPPLOT,-1 ; Stays on current plot
;	SKIPPLOT,-2 ; Goes to previous plot
;	SKIPPLOT,-3 ; Goes to previous previous plot
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 1997.
;			  JOR March 21,2003 added capability to stay on same plot (skips = -1)
;													 or go to previous plot (skips = -2)
;-
	ROUTINE_NAME='SKIPPLOT'
  IF N_ELEMENTS(SKIPS) EQ 0 THEN SKIPS = 1
  plots_per_page = !P.MULTI[1]*!P.MULTI(2)
  IF plots_per_page GT 1 THEN BEGIN
		I = REVERSE(INDGEN(plots_per_page)+1)
  	!P.MULTI[0] = FIRST( SHIFT(I,!P.MULTI[0]-SKIPS))
  ENDIF
END ; End of Program
