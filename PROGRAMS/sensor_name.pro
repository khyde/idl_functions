; $ID:	SENSOR_NAME.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Returns the Sensor NAME based on the allowable NAME
; SYNTAX:
;
;	Result = SENSOR_NAME(Files)
; OUTPUT:
; ARGUMENTS:
; 	Files:
;
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;	DT
; NOTES:
; VERSION:
;	  Feb 22,2001
; HISTORY:
;		Feb 22,2001	Written by:	J.E. O'Reilly, T. Ducas, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SENSOR_NAME,FILES
  ROUTINE_NAME='SENSOR_NAME'

;   ALLOWABLE SENSOR NAME
    SENSORS = ['AVHRR','CZCS','OCTS','SEAWIFS','MODIS']
    LETTERS = ['A',    'C',   'O',   'S',      'M']
;			Method $$$ needs work
    IF N_ELEMENTS(FILES) EQ 0 THEN RETURN, SENSORS

    TEXT = STRARR(N_ELEMENTS(FILES))

    FOR nth=0L,N_ELEMENTS(FILES)-1L DO BEGIN

      afile = FILES(nth)
      fn=PARSE_IT(afile)
      first_name = fn.first_name

      letter = STRUPCASE(STRMID(first_name,0,1))
      OK_letter = WHERE(LETTERS EQ letter,count)
      IF count GE 1 THEN BEGIN
        txt = STRSPLIT(first_name,'_',/EXTRACT,/PRESERVE_NULL)
        IF STRLEN(txt[0]) GE 8 AND STRLEN(txt[0]) LE 14 THEN BEGIN
          t = STRSPLIT(txt[0],'[0-9]',/EXTRACT,/REGEX)
          IF N_ELEMENTS(T) EQ 1 AND STRLEN(T[0]) EQ 1 THEN TEXT(nth) = SENSORS(ok_letter)

        ENDIF
      ENDIF
    ENDFOR


      IF N_ELEMENTS(TEXT) EQ 1 THEN RETURN,TEXT[0] ELSE RETURN, TEXT


END; #####################  End of Routine ################################
