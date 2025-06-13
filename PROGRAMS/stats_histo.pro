; $Id: STATS_HISTO.pro $  Sept 30, 2003
;+
;	This Function returns DATE FROM A VALID PERIOD

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STATS_HISTO, DATA, MIN=MIN,MAX=MAX,BINSIZE=BINSIZE,MEAN=MEAN,MEDIAN=MEDIAN
  ROUTINE_NAME='STATS_HISTO'
  IF N_ELEMENTS(MIN) NE 1 THEN MIN = MIN(DATA)
  IF N_ELEMENTS(MAX) NE 1 THEN MAX = MAX(DATA)
  IF N_ELEMENTS(BINSIZE) NE 1 THEN BINSIZE = 1 ;

  NUM=HISTOGRAM(DATA,MIN= MIN,MAX=MAX,BINSIZE=1, REVERSE_INDICES=R)
  IND=WHERE(NUM GE 0,COUNT_IND)     ; GET ALL THE BINS EVEN IF EMPTY

  _AVG = REPLICATE(MISSINGS(DATA),COUNT_IND)
  FOR _IND = 0L,COUNT_IND-1L DO BEGIN
  	J=IND(_IND)
    ;_AVG(J) = TOTAL( data(R(R[J]:R[J+1]-1)) ) / NUM(J)  ; Compute mean For each day
		_AVG(J) = MEDIAN( data(R(R[J]:R[J+1]-1)),/EVEN )  ; Compute median For each day
  ENDFOR

RETURN, _AVG

END; #####################  End of Routine ################################
