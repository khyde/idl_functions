; $ID:	NDECIMAL.PRO,	2004 07 01 02:05	$

	FUNCTION NDECIMAL, Values

;+
;	NAME:
;		NDECIMAL
;	PURPOSE:
; 	This Function Returns the number of decimal places (excluding trailing zeros)
;
;	CATEGORY:
;		NUMERIC
; CALLING SEQUENCE:
;   Result = NDECIMAL(Values)
;	INPUTS:
;		Values: Numeric or String types
; OUTPUT:
;   Number of decimal places
; EXAMPLE:
;   Result = NDECIMAL(Values)
;   Result = NDECIMAL([1.100,2.020,3.0030,4.0004,5.00005,6.123456D])
;		Result = NDECIMAL('6.123456')
;	RESTRICTIONS:
;		This routine returns the 'approximate' number of decimal places because
;		it uses IDL's STRING which roundthe input Values to floating-point precision
;		This routine is not very useful for double-precision Values
;
;	MODIFICATION HISTORY:
;   Sep 8, 1995 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   June 2, 2003 td replace strtrim(string with strtrim if format not specific
;-
; *************************************************************************
  ROUTINE_NAME='NDECIMAL'

; ===> Make a string Values from the imput Values
  txt = STRTRIM(STRING(Values),2)

  len = STRLEN(txt)
  decimal=LONG(STRPOS(txt,'.',0))
  n_decimal=decimal
  nonzero = len
  WORD =''

; ===> Find trailing zeros and number of decimals in each element of txt Values
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _num = 0, N_ELEMENTS(Values)-1 DO BEGIN
    WORD =''
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR i = (len(_num)-1),0,-1 DO BEGIN
      word = word + '0'
      IF STRPOS(txt(_num),word,i) EQ i THEN nonzero(_num) = i
    ENDFOR
;		||||||
    IF decimal(_num) NE -1 THEN BEGIN
      n_decimal(_num) = nonzero(_num) - decimal(_num) -1
    ENDIF ELSE BEGIN
      n_decimal(_num)=0
    ENDELSE
  ENDFOR
;	||||||

  RETURN, n_decimal

END; #####################  End of Routine ################################
