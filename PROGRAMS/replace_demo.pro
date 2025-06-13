; $ID:	REPLACE_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO REPLACE_DEMO, STRUCT
;+
; NAME:
;       REPLACE_DEMO
;
;	PURPOSE:
;				Demo program for making a nested structure
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, April 24, 2004

;-

ROUTINE_NAME='REPLACE_DEMO'

; UNDEFINED
;R=REPLACE(CAT,0,-2) & STOP

;  GOTO, TEST_STRUCT
; GOTO, DO_STRING_STRUCT

NAMES=['$',			'%',		 '&',		'*',			'+',		',',		'-',			'.',		'/']& NAMES = REPLACE(NAMES,['$',			'%',		 '&',		'*',			'+',		',',		'-',			'.',		'/'], $
												['_DOL_','_PCT_','_AMP_','_MULT_','_PLUS_','_COMMA_','_MINUS_','_DEC_','_DIV_'],count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=0B & PRINT, REPLACE(NUM,0, 2,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=0B & PRINT, REPLACE(NUM,0,-2,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=0  & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=0L & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=0.0& PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=0D & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP



NUM=UINT[0] & PRINT, REPLACE(NUM,0, 9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=UINT[0] & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=ULONG[0] & PRINT, REPLACE(NUM,0, 9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=ULONG[0] & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=LONG64[0] & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=ULONG64[0] & PRINT, REPLACE(NUM,0, 9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=ULONG64[0] & PRINT, REPLACE(NUM,0,-9,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

PRINT,'Count should be 3'
NUM= INDGEN(10) & NUM(0:1) = MISSINGS(NUM) & PRINT, REPLACE(NUM, [MISSINGS(NUM),8],[-999,-888],count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=FINDGEN(10) & PRINT, REPLACE(NUM,3,-99,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=DINDGEN(10) & PRINT, REPLACE(NUM,3,-99,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=FINDGEN(10) & PRINT, REPLACE(NUM,3,MISSINGS(0.0),count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=DINDGEN(10) & PRINT, REPLACE(NUM,3,MISSINGS(0.0D),count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=FINDGEN(10) & NUM[0] = MISSINGS(NUM) & PRINT, REPLACE(NUM,3,MISSINGS(0.0),count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=DINDGEN(10) & NUM[0] = MISSINGS(NUM)& PRINT, REPLACE(NUM,3,MISSINGS(0.0D),count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

NUM=FINDGEN(10) & NUM(0:1) = MISSINGS(NUM) & PRINT, REPLACE(NUM, MISSINGS(0.0),-999,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP
NUM=DINDGEN(10) & NUM(0:1) = MISSINGS(NUM)& PRINT, REPLACE(NUM, MISSINGS(0.0D),-999,count=count,subs=subs) & PRINT,'Count: ',count & PRINT,'SUBS: ',SUBS & STOP

DO_STRING_STRUCT:

  STRUCT= REPLICATE(CREATE_STRUCT('FIRST','FIRST','SECOND','SECOND'),3)
  STRUCT[1].FIRST='HELLO'
  NEW = REPLACE(STRUCT,'FIRST','GOODBY',COUNT=COUNT)
  PRINT,NEW
  PRINT, 'COUNT: ',COUNT
  STOP

TEST_STRUCT:
 ;	===> Make a nested structure
	PROD = 'FIRST'  ; 5 bytes
  INFO = 'INFO 1'  ; 6 bytes
	ARRAY= FINDGEN(2,3) ;2*3*4 (24 bytes)
	ARRAY(0,0) = -999

	FIRST=CREATE_STRUCT(PROD,CREATE_STRUCT('PROD',PROD,'INFO',INFO,'ARRAY',ARRAY))
	FIRST=CREATE_STRUCT('FIRST',FIRST)
	PROD = 'SECOND' ; 6 bytes
  INFO = 'INFO 2' ; 6 bytes
	ARRAY= DINDGEN(5,2); 5*2*8 (80 bytes)
	ARRAY(1,0:1) = -9

	SECOND=CREATE_STRUCT(PROD,CREATE_STRUCT('PROD',PROD,'INFO',INFO,'ARRAY',ARRAY))
	SECOND=CREATE_STRUCT('SECOND',SECOND)
;	===> COMBINE INTO A NESTED STRUCTURE
  NESTED=CREATE_STRUCT( FIRST,SECOND)

;GOTO, SKIP
  HELP,/STRUCT,NESTED

	NEW=REPLACE(NESTED,[-999,-9],[MISSINGS(0.0),MISSINGS(0.0D)],count=count,subs=subs)
	PRINT, NEW
	LIST,NEW.FIRST.FIRST.ARRAY
	LIST,NEW.SECOND.SECOND.ARRAY
	PRINT, 'COUNT: ',COUNT
	STOP

SKIP:
  NEW=REPLACE(NESTED,['FIRST','INFO 2'],['REPLACED_FIRST','REPLACED_INFO_2'],COUNT=COUNT,SUBS=SUBS)
  PRINT,NEW
  PRINT, 'COUNT: ',COUNT
  PRINT,'COUNT SHOULD BE 2'
  STOP



END; #####################  End of Routine ################################
