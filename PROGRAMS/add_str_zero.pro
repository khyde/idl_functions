; $ID:	ADD_STR_ZERO.PRO,	2015-08-06	$

FUNCTION ADD_STR_ZERO, NUM, DIGITS
;+
; NAME:ADD_STR_ZERO
;
;
; PURPOSE:
;				Add a 0 in front of a single digit number (9 to 09)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;   Result = ADD_STR_ZERO('9')
;
; INPUTS:
;   DIGITS: Total number of digits in the string (default is 2)
;	NOTES:
;
; MODIFICATION HISTORY:
;       Written by:  Kimberly J.W. Hyde - Sept 5, 2007
;       AUG 6, 2015 - KJWH: Added DIGITS keyword so you can add multiple zeros at the beginning of the string
;-

		_NUM = STRTRIM(STRING(NUM),2)

  IF NONE(DIGITS) THEN DIGITS = 2
  
  DIF = DIGITS - STRLEN(_NUM)
  ZEROS = _NUM & ZEROS(*) = ''
  FOR N=0, N_ELEMENTS(DIF)-1 DO IF DIF(N) GT 0 THEN ZEROS(N) = STRJOIN(REPLICATE('0',DIF(N)))
  _NUM = ZEROS + _NUM

   RETURN, _NUM

END ; END OF PROGRAM
