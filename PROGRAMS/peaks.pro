; $ID:	PEAKS.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns the local areas of peaks and valleys in a 1d data series

; HISTORY:
;		April 16,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION PEAKS,arr,LABEL=label
  ROUTINE_NAME='PEAKS'


  MAXS = -1L
  MINS = -1L
  sz=SIZE(arr,/STRUCT)
  if sz.n_dimensionS ne 1 then RETURN, -1

  IF N_ELEMENTS(LABEL) NE 1 THEN LABEL=''

	S=CREATE_STRUCT('LABEL',LABEL,'SUB',-1L,'VALUE',ARR[0],'MINMAX','','N_MAX',0L,'N_MIN',0L,'MAX',ARR[0],'MIN',ARR[0])
	S=STRUCT_2MISSINGS(S)

	S=REPLICATE(S,N_ELEMENTS(ARR))
	S.SUB = LINDGEN(N_ELEMENTS(ARR))

	MAX = MISSINGS(ARR[0])
	MIN = MISSINGS(ARR[0])


	FOR N=1L,N_ELEMENTS(arr)-2L DO BEGIN
       		  _1 = arr(N-1)
       		  _2 = arr(N)
       		  _3 = arr(N+1)
       		  IF (_2 GT _1 AND _2 GT _3) THEN BEGIN
							S(N).SUB = N
							S(N).VALUE = ARR(N)
       		  	S(N).MINMAX = 'MAX'
       		  ENDIF
       		  IF (_2 LT _1 AND _2 LT _3) THEN BEGIN
       		  	S(N).SUB = N
       		  	S(N).VALUE = ARR(N)
       		  	S(N).MINMAX = 'MIN'
       		  ENDIF

  ENDFOR


OK = WHERE(S.VALUE NE MISSINGS(S.VALUE),COUNT)
IF COUNT GE 1 THEN BEGIN
	S=S[OK]
	OK_MIN=WHERE(S.MINMAX EQ 'MIN',N_MIN)
	IF N_MIN GE 1 THEN MIN = MIN(S(OK_MIN).VALUE)
	OK_MAX=WHERE(S.MINMAX EQ 'MAX',N_MAX)
	IF N_MAX GE 1 THEN MAX = MAX(S(OK_MAX).VALUE)
ENDIF ELSE BEGIN
 S = S[0]
 S.SUB = -1L
 N_MIN = 0
 N_MAX = 0
 MIN = -1
 MAX = -1
ENDELSE

S.N_MAX = N_MAX
S.N_MIN = N_MIN
S.MAX = MAX
S.MIN = MIN

S.LABEL=LABEL
RETURN,S
END; #####################  End of Routine ################################
