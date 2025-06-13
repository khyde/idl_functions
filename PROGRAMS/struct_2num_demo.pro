; $ID:	STRUCT_2NUM_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO STRUCT_2NUM_DEMO, TIME
;+
; NAME:
;       STRUCT_2NUM_DEMO
;

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 4,1999
;       June 2, 2003 td replace strtrim(string with strtrim if format not specific
;-

ROUTINE_NAME='STRUCT_2NUM_DEMO'
		STRUCT = CREATE_STRUCT('AA',0B,'BB','1','CC','2.1','DD',0.0D,'EE',0L,'FF',' ','GG','CAT','HH',' ','II',MISSINGS(0UL))
		STRUCT = REPLICATE(STRUCT,3)
		STRUCT[0].AA = 255
		STRUCT(2).AA = 127
		STRUCT[0].BB = 'CAT'
		STRUCT[1].BB = ''
		STRUCT[1].FF = '0'
		STRUCT[1].EE = -2
		STRUCT[1].HH ='1E-3'
		STRUCT(2).HH ='-1E3'


	;	HELP,/STRUCT,STRUCT
;	SPREAD,STRUCT
		D=STRUCT_2NUM(STRUCT,/FLT)
		HELP,/STRUCT,D
 		SPREAD,D

	D=STRUCT_2DBL(STRUCT)
	SPREAD,D
	ST,D

  A = STRUCT_2ARR(D)
  SPREAD,A
STOP
END; #####################  End of Routine ################################



