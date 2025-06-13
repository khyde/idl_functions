; $ID:	WEIGHT_BISQUARE_DEMO.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program Demonstrates the WEIGHT_BISQUARE_DEMO function


; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO WEIGHT_BISQUARE_DEMO
  ROUTINE_NAME='WEIGHT_BISQUARE_DEMO'
  PAL_36
  ARR=RANDOMN(seed,400000)

  !P.MULTI=[0,1,3]
  W=WEIGHT_BISQUARE(ARR-MEAN(ARR))
  HISTPLOT,ARR,BINSIZE=0.1,BAR_COLOR=21
  HISTPLOT,W, BINSIZE=0.005,BAR_COLOR=21
  PLOT, ARR,W,PSYM=1
  OK = WHERE(W EQ 0,COUNT)
  IF COUNT GE 1 THEN OPLOT, ARR[OK],W[OK],COLOR=21,THICK=4,PSYM=1
  !P.MULTI=0


END; #####################  End of Routine ################################
