; $ID:	JD_ADD.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION JD_ADD ,JD, ADD, YEAR=year,MONTH=month,DAY=day,HOUR=hour,MINUTE=minute,SECOND=second

;+
; NAME:
;       JD_ADD
; INPUTS:
;       Julian day
;	NOTES:
;				ADD may be a decimal fraction
;				E.G.:   jd=JD_ADD(jd, 1.5 /HOUR)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 30, 2004
;				Feb 21, 2005  REMOVED FIX: IF N_ELEMENTS(ADD) NE 1 THEN ADDTO = 0 ELSE ADDTO = FIX(ADD)


;-
; ===================>
  IF N_ELEMENTS(JD) EQ 0 THEN RETURN,-1
  IF N_ELEMENTS(ADD) NE 1 THEN ADDTO = 0 ELSE ADDTO = ADD

 	IF ADDTO EQ 0 THEN RETURN, JD

  ;	===> Extract date components from Julian Day
	YY		= LONG(STRING(JD,FORMAT='(C(CYi4.4))'))
	MM		= LONG(STRING(JD,FORMAT='(C(CMoi2.2))'))
	DD		= LONG(STRING(JD,FORMAT='(C(CDi2.2))'))
	HH		= LONG(STRING(JD,FORMAT='(C(CHi2.2))'))
	MI		= LONG(STRING(JD,FORMAT='(C(CMi2.2))'))
	SS		= LONG(STRING(JD,FORMAT='(C(CSi2.2))'))

	IF KEYWORD_SET(YEAR) 		THEN JULIAN	=	JULDAY(MM,				DD,				YY+ADDTO,	HH,				MI,				SS)
	IF KEYWORD_SET(MONTH) 	THEN JULIAN	=	JULDAY(MM+ADDTO,	DD,				YY,				HH,				MI,				SS)
	IF KEYWORD_SET(DAY) 		THEN JULIAN	=	JULDAY(MM,				DD+ADDTO,	YY,				HH,				MI,				SS)
  IF KEYWORD_SET(HOUR) 		THEN JULIAN	=	JULDAY(MM,				DD,				YY,				HH+ADDTO,	MI,				SS)
  IF KEYWORD_SET(MINUTE) 	THEN JULIAN	=	JULDAY(MM,				DD,				YY,				HH,				MI+ADDTO,	SS)
  IF KEYWORD_SET(SECOND) 	THEN JULIAN	=	JULDAY(MM,				DD,				YY,				HH,				MI,				SS+ADDTO)


  IF N_ELEMENTS(JULIAN) EQ 1 THEN RETURN,JULIAN[0] ELSE RETURN, JULIAN




END; #####################  End of Routine ################################

