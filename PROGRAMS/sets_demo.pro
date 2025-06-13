; $ID:	SETS_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO SETS_DEMO, DATA, MATRIX=matrix, ERROR=error
;+
; NAME:
;       WHERESETS_DEMO
;
; PURPOSE:
;       Demo for SETS.PRO
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 27,2002
;				March 15, 2004 jor streamlined, now not using where
;-

	ROUTINE_NAME='WHERESETS_DEMO'
	values=['A','B','C','A','B','C','D','A','E','E','E','F']
  DATA=		 [1,	2,	3,	1,	2,	3,	4,	1,	5,	5,	5,	6]




;	===> MATRIX (Row Column Format)
	PRINT,'MATRIX (Row Column Format)'
	S=SETS(VALUES)

	FOR NTH=0,N_ELEMENTS(S)-1 DO BEGIN
		HELP,S,/STRUCT
	ENDFOR


; ===> This shows how to extract and use the subscripts in the Subs Tag
  SS= REPLICATE(CREATE_STRUCT('MEAN',0.0),N_ELEMENTS(S))
  SS=STRUCT_MERGE(S,SS)
;	===> Show how to
	FOR NTH=0,N_ELEMENTS(SS)-1L DO BEGIN
  	SUBS=LONARR(SS[NTH].N)
  	READS,SS[NTH].SUBS, SUBS
		SS[NTH].MEAN = MEAN(DATA(SUBS))
	ENDFOR

SPREAD,SS



;	===> Nested Structure
	PRINT, 'Nested Structure'

	S=SETS(VALUES,/NESTED)
	FOR NTH=0,N_TAGS(S)-1 DO BEGIN
		 HELP,S.(NTH),/STRUCT
	ENDFOR

	PRINT

	DONE:

  END; #####################  End of Routine ################################
