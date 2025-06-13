; $ID:	STRUCT_FILL_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO STRUCT_FILL_DEMO, TIME
;+
; NAME:
;       STRUCT_FILL_DEMO
;

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, MARCH 4,1999
;       June 2, 2003 td replace strtrim(string with strtrim if format not specific
;-

ROUTINE_NAME='STRUCT_FILL_DEMO'
		STRUCT = CREATE_STRUCT('AA',0B,'BB','1','CC','2.1','DD',0.0D,'EE',0L,'FF',' ','GG','CAT','HH',' ','II',MISSINGS(0UL))
		STRUCT = STRUCT_2MISSINGS(STRUCT)
		STRUCT = REPLICATE(STRUCT,10)
		STRUCT[0].AA = 255
		STRUCT[0].BB = 'BAT'
		STRUCT[0].CC = 'CAT'
		STRUCT[0].DD = 1.21
		STRUCT[0].EE = -2
		STRUCT[0].FF = 'F'
		STRUCT[0].GG = 'G'
		STRUCT[0].HH ='1E-3'
		STRUCT[0].HH ='-1E3'

		STRUCT(2).AA = 25
		STRUCT(2).BB = 'BbAT'
		STRUCT(2).CC = 'CcAT'
		STRUCT(2).DD = 2.41
		STRUCT(2).EE = -2
		STRUCT(2).FF = 'FF'
		STRUCT(2).GG = 'GG'
		STRUCT(2).HH ='1E-3'
		STRUCT(2).HH ='-1E3'

		STRUCT(4).AA = 25
		STRUCT(4).BB = 'BBbAT'
		STRUCT(4).CC = 'CCcAT'
		STRUCT(4).DD = 2.41
		STRUCT(4).EE = -2
		STRUCT(4).FF = 'FFF'
		STRUCT(4).GG = 'GGG'
		STRUCT(4).HH ='1E-3'
		STRUCT(4).HH ='-1E3'


		STRUCT(7).AA = 35
		STRUCT(7).BB = 'BBBbbAT'
		STRUCT(7).CC = 'CCCccAT'
		STRUCT(7).DD = 2.71
		STRUCT(7).EE = -2
		STRUCT(7).FF = 'FFFFF'
		STRUCT(7).GG = 'GGGGG'
		STRUCT(7).HH ='1E-3'
		STRUCT(7).HH ='-1E3'

		SPREAD,STRUCT

		D=STRUCT_FILL(STRUCT,TAGS=[0,1,2])
		HELP,/STRUCT,D
 		SPREAD,D


;		===> Now place a missing record first
		COPY=STRUCT[0] & copy=struct_2missings(copy)
		STRUCT=[COPY,STRUCT]
		SPREAD,STRUCT
		D=STRUCT_FILL(STRUCT,TAGS=[0,1,2])
		HELP,/STRUCT,D
 		SPREAD,D

;		===> Now place a complete record at the end
		COPY=STRUCT[1]
		STRUCT=[STRUCT,copy]
		SPREAD,STRUCT
		D=STRUCT_FILL(STRUCT,TAGS=[0,1,2])
		HELP,/STRUCT,D
 		SPREAD,D

;		===> Now make the target tags all missing

		DD=STRUCT_FILL(STRUCT,TAGS=[0,1,2])
		SPREAD,DD
		D=STRUCT_FILL(DD,TAGS=[8])
		HELP,/STRUCT,D
 		SPREAD,D

;		===> Now make the target tags all non-missing
		DD=STRUCT_FILL(STRUCT,TAGS=[0,1,2])
		DD=DD(1:*)
		SPREAD,DD
		D=STRUCT_FILL(DD,TAGS=[0,1,2])
		HELP,/STRUCT,D
 		SPREAD,D


STOP
END; #####################  End of Routine ################################



