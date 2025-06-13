; $ID:	DT_DT.PRO,	2004 FEB 01 07:28	$
;+
; This Program Prints Local and GMT DATE TIME based on current settings in the Computers SYSTIME
; 	DT_DT
; OUTPUT:
; 	String,   Formatted as: '20010102081717'
; ARGUMENTS:
; 	None:
; KEYWORDS:
;		NONE
; CATEGORY:
; 	DT
; NOTES:
; HISTORY:
; 		Sept 21, 2003 Written by: J.E. O'Reilly
;-

  PRO DT_DT,CALENDAR=CALENDAR
  PRO_NAME='DT_DT'
  JULIAN_LOCAL	=	SYSTIME(/JULIAN)
  JULIAN_GMT		=	SYSTIME(/JULIAN,/UTC)
  S=SIGN(0) ; SO IT COMPILES EARLY

  date_local= STRING(julian_local,FORMAT='(C(CMoA3))')+ ' ' +$
          		STRING(julian_local,FORMAT='(C(CDi2.2))')+','+$
          		STRING(julian_local,FORMAT='(C(CYi4.4))')+ ' '+$
          		STRING(julian_local,FORMAT='(C(CHi2.2))')+':'+$
          		STRING(julian_local,FORMAT='(C(CMi2.2))')+' '+$
          		STRING(julian_local,FORMAT='(C(CSi2.2))')

 date_GMT= STRING(julian_GMT,FORMAT='(C(CMoA3))')+ ' ' +$
          		STRING(julian_GMT,FORMAT='(C(CDi2.2))')+','+$
          		STRING(julian_GMT,FORMAT='(C(CYi4.4))')+ ' '+$
          		STRING(julian_GMT,FORMAT='(C(CHi2.2))')+':'+$
          		STRING(julian_GMT,FORMAT='(C(CMi2.2))')+' '+$
          		STRING(julian_GMT,FORMAT='(C(CSi2.2))')



  PRINT, DATE_LOCAL,JD_2DATE(JULIAN_LOCAL),	'LOCAL', FORMAT='(A20,5X,A14,2X, A)'
  PRINT, DATE_GMT, 	JD_2DATE(JULIAN_GMT), 	'GMT'	 , FORMAT='(A20,5X,A14,2X, A)'
  DIF_HOURS = ROUND((JULIAN_GMT - JULIAN_LOCAL)*24.0)

  IF SIGN(DIF_HOURS) GE 0 THEN BEGIN
 		PRINT,'GMT = LOCAL +',DIF_HOURS,' Hours', FORMAT='(A, I2,A)'
	ENDIF ELSE BEGIN
		PRINT,'GMT = LOCAL -',DIF_HOURS,' Hours', FORMAT='(A, I2,A)'
	ENDELSE
	PRINT
	IF KEYWORD_SET(CALENDAR) THEN DT_CALENDAR

END; End of Program
