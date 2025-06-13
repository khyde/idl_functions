; $ID:	NUMBER.PRO,	NOVEMBER 05 2004, 08:17	$
;+
;	NUMBER:	This Function returns  1 (True) if the input is a number (or a string number), 0 (False) if it is not
;
;	EXAMPLES:
;  	PRINT, NUMBER(['1','cat','0','dog','1.234','','1e4'])
;		PRINT, NUMBER(-1L)

; HISTORY:	May 28, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION NUMBER,NUM
  ROUTINE_NAME='NUMBER'


  IF IDLTYPE(NUM,/NUMERIC) THEN BEGIN
  	IF N_ELEMENTS(NUM) EQ 1 THEN RETURN, 1 ELSE RETURN, REPLICATE(1,N_ELEMENTS(NUM))
	ENDIF

	ARRAY=REPLICATE(!VALUES.F_INFINITY,N_ELEMENTS(NUM))


;	===> Process STRING TYPE
	IF IDLTYPE(NUM,/CODE) EQ 7 THEN BEGIN
;		===> Convert any blanks into null strings
		_NUM = STRCOMPRESS(NUM,/REMOVE_ALL)

;		===> Avoid Loop if possible (If can not convert whole array then catch the io error and then  Do Loop)
		ON_IOERROR, DO_LOOP
		ARRAY= DOUBLE(_NUM)
		GOTO,DONE

		DO_LOOP:
		ON_IOERROR, BAD_NUM

 		FOR NTH=0L,N_ELEMENTS(_NUM)-1L DO BEGIN
  		ARRAY(NTH)= DOUBLE(_NUM(nth))
   		BAD_NUM: CONTINUE
		ENDFOR

	DONE:

;	===> Null Strings are not allowed to be zero
  IS_NUM = (FINITE(ARRAY)) < (_NUM NE '')
  IF N_ELEMENTS(NUM) EQ 1 THEN RETURN, IS_NUM(0) ELSE RETURN, IS_NUM
	ENDIF

; ===> If not numeric and not string then return 0
	RETURN,0

END; #####################  End of Routine ################################
