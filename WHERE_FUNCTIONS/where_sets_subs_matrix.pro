; $ID:	WHERE_SETS_SUBS_MATRIX.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION WHERE_SETS_SUBS_MATRIX, STRUCT,   DELIM=delim
;+
; NAME:
;       WHERE_SETS_SUBS_MATRIX
;
; PURPOSE:
;		Extract subscripts for sets obtained with WHERE_SETS.PRO and place (left align) into a matrix
;
;		If the SETS STRUCTURE has more than one record then the subs from all records are returned
;
;				DELIM: 		The delimiter to use when joining all subscripts for a set (default is ; )

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 22, 2004
;-

ROUTINE_NAME='WHERE_SETS_SUBS_MATRIX'

IF N_ELEMENTS(DELIM) NE 1 THEN DELIM = ';'

;	===>  SUBSCRIPTS AS A SINGLE ARRAY
 		ALL_SUBS = LONG(WORDS(STRCOMPRESS(STRJOIN(STRUCT.SUBS)),DELIM=delim))
 		ALL_SUBS=ALL_SUBS(0:N_ELEMENTS(ALL_SUBS)-2L)

		N_SETS = N_ELEMENTS(STRUCT)
		MAX_N = MAX(STRUCT.N)

		SUBS_MATRIX= REPLICATE(!VALUES.F_INFINITY,MAX_N,N_SETS)
		FOR NTH=0L,N_SETS-1L DO BEGIN
			SUBS_MATRIX(0:STRUCT[NTH].N-1,NTH) = WHERE_SETS_SUBS(STRUCT[NTH])
		ENDFOR

 RETURN,SUBS_MATRIX


END; #####################  End of Routine ################################



