; $ID:	SIZE_BYTES_DEMO.PRO,	2020-07-09-08,	USER-KJWH	$
;+
;	This Program Demonstrates SIZE_BYTES.PRO

; HISTORY:
;		July 9, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO SIZE_BYTES_DEMO
  ROUTINE_NAME='SIZE_BYTES_DEMO'


	PRINT
	PRINT, 'Byte sizes of the IDL data types (Except Undefined and Structures)'

	TYPES = [ 1,2,3,4,5,6,7,9,10,11,12,13,14,15] ; SKIP 0 (UNDEFINED); SKIP 8 (STRUCTURE)
	FOR _TYPES = 0,N_ELEMENTS(TYPES)-1  DO BEGIN
		DATA = MAKE_ARRAY(1,TYPE=TYPES(_TYPES))
		NAME=IDLTYPE(DATA,/NAME)
		PRINT,NAME, SIZE_BYTES(DATA)
	ENDFOR
	PRINT
STOP

;	===> Simple Spreadsheet Row,Column structure
	Struct= REPLICATE(CREATE_STRUCT('PET',''),3)
	STRUCT[0].PET='CAT'
	STRUCT[1].PET='DOG'
	STRUCT(2).PET='HORSE'
	PRINT
	HELP,/STRUCT,STRUCT
	PRINT,Struct
  PRINT,'This Simple Spreadsheet Structure should be 11 bytes (', SIZE_BYTES(struct) ,' )'
STOP


;	===> Structure with two tags with different array sizes
	Struct=CREATE_STRUCT('PETS',['CAT','DOG','HORSE'],'ZOO', ['RHINO','MONKEY','ELEPHANT','SNAKE'])
	PRINT
	HELP,/STRUCT,STRUCT
	PRINT,Struct.(0)
	PRINT,Struct.(1)
  PRINT,'This Structure with two tags with different array sizes should be 35 bytes (', SIZE_BYTES(struct) ,' )'
STOP

;	===> Make a nested structure
	PRINT
	PRINT,'AN EXAMPLE OF A NESTED STRUCTURE'
	PROD = 'FIRST'  ; 5 bytes
  INFO = 'INFO 1'  ; 6 bytes
	ARRAY= FINDGEN(2,3) ;2*3*4 (24 bytes)

	FIRST=CREATE_STRUCT(PROD,CREATE_STRUCT('PROD',PROD,'INFO',INFO,'ARRAY',ARRAY))
	FIRST=CREATE_STRUCT('FIRST',FIRST)

	HELP,/STRUCT,FIRST.(0).(0)
	PRINT,'First Should be 35 bytes (', SIZE_BYTES(first) ,' )'
 	PRINT

	PROD = 'SECOND' ; 6 bytes
  INFO = 'INFO 2' ; 6 bytes
	ARRAY= DINDGEN(5,2); 5*2*8 (80 bytes)

	SECOND=CREATE_STRUCT(PROD,CREATE_STRUCT('PROD',PROD,'INFO',INFO,'ARRAY',ARRAY))
	SECOND=CREATE_STRUCT('SECOND',SECOND)

	HELP,/STRUCT,SECOND.(0).(0)
 	PRINT,'Second Should be 92 bytes (', SIZE_BYTES(SECOND) ,' )'
 	PRINT

;	===> COMBINE INTO A NESTED STRUCTURE
  NESTED=CREATE_STRUCT( FIRST,SECOND)

  PRINT,'This NESTED Structure should be 127 bytes (', SIZE_BYTES(NESTED) ,' )'



END; #####################  End of Routine ################################
