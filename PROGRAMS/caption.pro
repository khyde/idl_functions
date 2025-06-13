; $ID:	CAPTION.PRO,	2020-07-08-15,	USER-KJWH	$
  PRO CAPTION, TEXT, X=x, Y=y,DATE=DATE,ROUTINE=ROUTINE, PLOT=PLOT, REGION=REGION,_EXTRA=_extra

;+
; NAME:
;       CAPTION
;
; PURPOSE:
;       Program Writes Caption at bottom of figures
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       CAPTION
;
; INPUTS:
;       IDL Vector font # but None Required
;   Allowed range of selected fonts 3-20 and -1
;
; KEYWORDS:
;    None
;
; OUTPUTS:
;    NONE:
;
; SIDE EFFECTS:
;
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, May 21, 1997
;   NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;   oreilly@fish1.gso.uri.edu
;       August 12,1997 added date-time and DATE keyword to prevent date_time
;
;-

; ====================>

  IF N_ELEMENTS(TEXT) EQ 0 THEN TEXT = ''

  IF KEYWORD_SeT(DATE) THEN BEGIN
;   Get the current date-time
    DT=DATE_NOW()
    YEAR=STRMID(DT,0,4)
    MONTH=STRMID(DT,4,2)
    DAY  =STRMID(DT,6,2)

    date = NUM2STR(year)+' '+NUM2STR(month)+' '+NUM2STR(day)
    TEXT = TEXT +' '+ DATE
  ENDIF

	IF KEYWORD_SET(ROUTINE) THEN BEGIN
	   HELP,CALLS=CALLS & FN=FILE_PARSE(CALLS[1]) & CALLING_ROUTINE = FN.FIRST_NAME
	   TEXT = CALLING_ROUTINE + ' ' + TEXT
	ENDIF
; ================>
; Default position
  IF N_ELEMENTS(X) EQ 0 THEN X = !X.WINDOW[1]
  IF N_ELEMENTS(Y) EQ 0 THEN Y =  0.001
  IF KEYWORD_SET(PLOT) THEN Y = !Y.WINDOW[0]+0.02
  IF KEYWORD_SET(REGION) THEN Y= !Y.REGION[0] - 0.07

  XYOUTS,X,Y,TEXT,/NORMAL,ALIGN= 1.01,CHARSIZE= 0.4, _EXTRA=_extra

  END
; END OF PROGRAM
