; $ID:	MTIME_2JD.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Converts MTIME to Julian Day
;	MTIME_2JD

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION MTIME_2JD,MTIME
  ROUTINE_NAME='MTIME_2JD'
  N=N_ELEMENTS(MTIME)
  IF N EQ 0 THEN RETURN,-1

	JD = REPLICATE(0D,N_ELEMENTS(MTIME))

	FOR NTH = 0L,N_ELEMENTS(MTIME)-1L DO BEGIN
		JD[NTH] =  SECONDS1970_2JD(SYSTIME(0, MTIME[NTH],/SECONDS))
  ENDFOR
  RETURN,JD

END; #####################  End of Routine ################################
