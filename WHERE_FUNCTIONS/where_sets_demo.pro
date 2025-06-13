; $ID:	WHERE_SETS_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO WHERE_SETS_DEMO, DATA
;+
; NAME:
;       WHERE_SETS_DEMO
;
; PURPOSE:
;       Demo for WHERE_SETS.PRO
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 27,2002
;				March 15, 2004 jor streamlined, now not using where
;-

	ROUTINE_NAME='WHERE_SETS_DEMO'



	V1=['A','B','CAT', 'D']
	V2=['D','A','E', 'F']
	SETS=WHERE_SETS(V1,V2)
	SPREAD,SETS
	STOP

	V1=['A','B','CAT', 'D']
	V2 = REVERSE(V1)
	SETS=WHERE_SETS(V1,V2)
	SUBS=WHERE_SETS_SUBS(SETS,/SAME)
	SPREAD,SETS
	STOP


	V1=['A','B','CAT','A','B','CAT','D']
	V2=['D','A','E','E','E','F']
	SETS=WHERE_SETS(V1,V2)
	SPREAD,SETS

STOP


	values=['A','B','CAT','A','B','CAT','D','A','E','E','E','F']
  DATA=		 [1,	2,	3,	1,	2,	3,	4,	1,	5,	5,	5,	6]

  SPREAD,WHERE_SETS(VALUES)
  STOP

;	===> MATRIX (Row Column Format)
	PRINT,'MATRIX (Row Column Format)'
	SETS=WHERE_SETS(data)

	FOR NTH=0,N_ELEMENTS(SETS)-1 DO BEGIN
		HELP,SETS,/STRUCT
	ENDFOR

STOP
	S=SETS(VALUES)
; ===> This shows how to extract and use the subscripts in the Subs Tag
  SS= REPLICATE(CREATE_STRUCT('MEAN',0.0),N_ELEMENTS(S))
  SS=STRUCT_MERGE(S,SS)
;	===> Show how to
	FOR NTH=0,N_ELEMENTS(SS)-1L DO BEGIN
  	SUBS=WHERE_SETS_SUBS(SS[NTH])

		SS[NTH].MEAN = MEAN(DATA(SUBS))
	ENDFOR


STOP

	NESTED_STRUCTURE: ;	===> Nested Structure
	PRINT, 'Nested Structure'
	values=['A','B','CAT','A','B','CAT','D','A','E','E','E','F']
	S=WHERE_SETS(VALUES,/NESTED)

	FOR NTH=0,N_TAGS(S)-1 DO BEGIN
		 HELP,S.(NTH),/STRUCT
	ENDFOR

	PRINT
STOP

	N=10
	DATA = [LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N),LINDGEN(N)]
	TIMER
	S=WHERE_SETS(DATA)
	TIMER,/STOP

	TIMER
	S=WHERE_SETS(DATA,/NESTED,ALL_SUBS=ALL_SUBS)
	TIMER,/STOP
	;PRINT, ALL_SUBS


	 TIMER
	 S=WHERE_SETS(LONG(DIST(1024)))
	 TIMER,/STOP
	 STOP

	DONE:

  END; #####################  End of Routine ################################
