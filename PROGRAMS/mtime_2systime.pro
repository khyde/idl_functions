; $ID:	MTIME_2SYSTIME.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function returns

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION MTIME_2SYSTIME,MTIME
  ROUTINE_NAME='MTIME_2SYSTIME'
  FILE = ROUTINE_NAME+'.TXT'
  OPENW,LUN,FILE,/GET_LUN
  PRINTF,LUN,''
  CLOSE,LUN
  FREE_LUN,LUN
  FI=FILE_INFO(FILE)

  ADJUST=FI.MTIME - SYSTIME[1]
  RETURN, MTIME + ADJUST


END; #####################  End of Routine ################################
