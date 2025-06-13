; $ID:	ARR_2STRUCT.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Generates a Structure Array from an array
; SYNTAX:
;		Result = ARR_2STRUCT(Arr)
; OUTPUT:
;		Structure Array (spreadsheet type)
; ARGUMENTS:
; 	Arr:	IDL Array which is a simple 1 or 2d (row x column array)
;
; KEYWORDS:
;		TAGNAMES: Names for the Structure (column names)
;							If TAGNAMES is not provided then tagnames will be _0,_1,_2,_3 ...n_cols-1
;
; EXAMPLES:
;		SEE ARR_2STRUCT_DEMO
;
; NOTES:
;		Input Arr and Tagnames are not altered.

; HISTORY:
;		Dec 12, 2004	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION ARR_2STRUCT, Arr, TAGNAMES=tagnames,ERROR=ERROR
  ROUTINE_NAME='ARR_2STRUCT'

  SZ=SIZE(ARR,/STRUCT)

  IF  SZ.N_ELEMENTS EQ 0 OR SZ.N_dimensions GT 2 THEN BEGIN
  	ERROR=1
  	PRINT,'ERROR: Arr must be 1 or 2 dimensions'
  	RETURN,-1
  ENDIF

;	===> Arr can not be a Structure
	IF SZ.TYPE EQ 8 THEN BEGIN
		ERROR = 1
  	PRINT,'ERROR: Arr can not be a Structure'
  	RETURN,-1
	ENDIF

	_ARR = ARR
 	NTAGS = N_ELEMENTS(TAGNAMES)


;	===> If scalar or 1-d Convert Arr to 2-d spreadsheet array
  IF SZ.N_DIMENSIONS LE 1 THEN BEGIN
  	IF NTAGS EQ 0 THEN BEGIN
  		NTAGS = 1
  		_ARR = REFORM(_ARR,NTAGS,N_ELEMENTS(_ARR))
  	ENDIF ELSE BEGIN
  		IF NTAGS EQ SZ.N_ELEMENTS THEN BEGIN
  			_ARR = REFORM(_ARR, N_ELEMENTS(_ARR),1)
			ENDIF ELSE BEGIN
 				NTAGS = 1 ; Force to 1
 				_ARR = REFORM(_ARR,NTAGS,N_ELEMENTS(_ARR))
			ENDELSE
  	ENDELSE
  		SZ = SIZE(_ARR,/STRUCT)
  ENDIF

  NTAGS 	= SZ.DIMENSIONS[0]
  N_ROWS 	= SZ.DIMENSIONS[1]

;	===> If TAGNAMES not provided then Generate them
	IF N_ELEMENTS(TAGNAMES) EQ 0 THEN BEGIN
		_TAGNAMES = '_'+ STRTRIM(SINDGEN(NTAGS),2)
	ENDIF ELSE _TAGNAMES= TAGNAMES


  IF NTAGS NE N_ELEMENTS(_TAGNAMES) THEN BEGIN
  	ERROR = 1
  	PRINT,'ERROR: Number of TAGNAMES must match Number of Columns in the Arr'
  	RETURN,-1
  ENDIF


;	===> Ensure valid tagnames
	_TAGNAMES= STRUCT_TAGNAMES_FIX(_TAGNAMES)

;	===> Make a structure of the same data type as Arr
	FOR NTH = 0L,NTAGS-1 DO BEGIN
		IF NTH EQ 0 THEN STRUCT=CREATE_STRUCT(_TAGNAMES[NTH],_ARR[0]) ELSE STRUCT=CREATE_STRUCT(STRUCT,_TAGNAMES[NTH],_ARR[0])
	ENDFOR


;	===> Replicate for number of Rows
	STRUCT=REPLICATE(STRUCT,N_ROWS)

;	===> Fill in the structure with Arr
	IF SZ.N_DIMENSIONS EQ 1 THEN BEGIN
		FOR NTH = 0L,NTAGS-1 DO BEGIN
			STRUCT.(NTH) = _ARR[NTH]
		ENDFOR
	ENDIF
	IF SZ.N_DIMENSIONS EQ 2 THEN BEGIN
		FOR NTH = 0L,NTAGS-1 DO BEGIN
			STRUCT.(NTH) = REFORM(_ARR(NTH,*))
		ENDFOR
	ENDIF

  RETURN,STRUCT

END; #####################  End of Routine ################################
