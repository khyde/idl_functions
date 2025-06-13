; $ID:	STRUCT_THIN_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns DATE FROM A VALID PERIOD

; HISTORY:
;		May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO STRUCT_THIN_DEMO
  ROUTINE_NAME='STRUCT_THIN_DEMO'
  STRUCT=CREATE_STRUCT('A','','B','0','C','1','D',0L)
  STRUCT=REPLICATE(STRUCT,10)

;	===> Make the first record all missing
  FOR NTH=0,N_TAGS(STRUCT)-1 DO BEGIN
  	STRUCT[0].(NTH) =  MISSINGS(STRUCT[0].(NTH))
  ENDFOR
  NEW   = STRUCT_THIN(STRUCT)

STOP



END; #####################  End of Routine ################################
