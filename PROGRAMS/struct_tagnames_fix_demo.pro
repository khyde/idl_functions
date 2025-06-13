; $ID:	STRUCT_TAGNAMES_FIX_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

 PRO STRUCT_TAGNAMES_FIX_DEMO
;+
; NAME:
;       STRUCT_TAGNAMES_FIX_DEMO
;
; PURPOSE:
;				Fix IDL Structure Tag Names containing illegal characters
;
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 27, 2004

;-

ROUTINE_NAME='STRUCT_TAGNAMES_FIX_DEMO'

QUIET = 0
BAD = 0B

GOTO, SKIP

FOR N =0B,255B DO BEGIN
	TAGNAME= STRING(N)
	IF NOT QUIET THEN PRINT,N, TAGNAME

ENDFOR

STOP

FOR N =0B,255B DO BEGIN
	TAGNAME= STRING(N)
	IF NOT QUIET THEN PRINT,N, TAGNAME
	;		===> Avoid Loop if possible (If can not convert whole array then catch the io error and then  Do Loop)

		CATCH, Error_status
   ;This statement begins the error handler:
   IF Error_status NE 0 THEN BEGIN
      IF NOT QUIET THEN BEGIN
      	PRINT, 'Error index: ', Error_status
      	PRINT, 'Error message: ', !ERROR_STATE.MSG
      ENDIF
      ; Handle the error by extending A:
      CATCH, /CANCEL
      Error_status = 0
      BAD=[BAD,N]
      CONTINUE
   ENDIF

	S=CREATE_STRUCT(TAGNAME,'')

ENDFOR
BAD=BAD(1:*)
PRINT,BAD

STOP

OK = WHERE_IN(INDGEN(256),BAD,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=GOOD)

PRINT, 'GOOD VALUES'
FOR N=0,NCOMPLEMENT-1 DO BEGIN
	PRINT, LONG(GOOD(N)),STRING(BYTE(GOOD(N)))
ENDFOR


SKIP:


NAMES = ['$',			'%',		 '&',		'*',			'+',		',',		'-',			'.',		'/']
VALID=STRUCT_TAGNAMES_FIX(NAMES)
LIST, VALID



NAMES = ['$',			'%',		 '&',		'*',			'+',		',',		'-',			'.',		'/']
VALID=NAMES
FOR NTH=0,N_ELEMENTS(NAMES)-1 DO BEGIN
	VALID[NTH] = IDL_VALIDNAME(NAMES[NTH],/CONVERT_ALL, /CONVERT_SPACES)
ENDFOR
LIST,VALID


NAMES = ['$',			'%',		 '&',		'*',			'+',		',',		'-',			'.',		'/']
NAMES = '_'+NAMES
VALID=NAMES
FOR NTH=0,N_ELEMENTS(NAMES)-1 DO BEGIN
	VALID[NTH] = IDL_VALIDNAME(NAMES[NTH],/CONVERT_ALL, /CONVERT_SPACES)
ENDFOR
LIST,VALID

	DONE:
END; #####################  End of Routine ################################



