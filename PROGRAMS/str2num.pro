; $ID:	STR2NUM.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	STR2NUM:	This Function converts strings to double precision numbers
;						Strings which can not be converted are set to missing code (!VALUES.D_INFINITY)
;
;	EXAMPLES:
;  	PRINT, STR2NUM(['1','cat','0','dog','1.234','','1e4'])
;		PRINT, STR2NUM(-1L)

; HISTORY:	May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION STR2NUM,NUM
  ROUTINE_NAME='STR2NUM'

	IS_NUM = NUMBER(NUM)
	ARRAY=REPLICATE(!VALUES.D_INFINITY,N_ELEMENTS(NUM))
	OK=WHERE(IS_NUM EQ 1,COUNT)
	IF COUNT GE 1 THEN ARRAY[OK] = DOUBLE(NUM[OK])
	RETURN,ARRAY
END; #####################  End of Routine ################################
