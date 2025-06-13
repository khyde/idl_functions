; $ID:	WHERE_IN_DEMO.PRO,	DECEMBER 13 2004, 10:12	$
PRO WHERE_IN_DEMO
ROUTINE_NAME= 'WHERE_IN_DEMO'

; When only one in the array
ARRAY=[3]
VALUES = [3,5,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement )
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT
STOP

; When only one in the array
ARRAY=[3,3]
VALUES = [3,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement )
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT
stop

; When only one in the array
ARRAY=[3,2,3]
VALUES = [3,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement )
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT
STOP


ARRAY=[1,2,3.05,3,3,9,10,11,5,4,6,7]
VALUES = [3,5,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement )
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

stop
; ***
ARRAY=[ 'BIRD' ]
VALUES = ['AA']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

stop
; ***
ARRAY=[ 'AA' ]
VALUES = ['BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT
stop
; ***
ARRAY=[ 'BIRD' ]
VALUES = ['BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=[ 'BIRD' ]
VALUES = ['BIRD','CAT']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=['CAT', 'BIRD' ]
VALUES = ['BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=['CAT', 'BIRD' ]
VALUES = ['CAT','BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=[ 'BIRD' ,'CAT']
VALUES = ['CAT','BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP


; ***
ARRAY=['ZEBRA','CAT','BIRD','CAT','BIR','CAT','BIRD','CAT','BIRD','DOG','CAT']
VALUES = ['DOG','BIRD']
PRINT, ARRAY,VALUES
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=['ZZ','DOG','CAT','BRD','BIR','ZEBRA','BIRD','BIR','ZEBRA']
VALUES = ['BIRD']
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=[1,2,3,9,10,11,5,4,6,7]
VALUES = [3]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY=[1,2,3,9,10,11,5,4,6,7]
VALUES = [3,5,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

; ***
ARRAY= FINDGEN(21)
VALUES = [3,5,7]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP

ARRAY= FINDGEN(21)
VALUES = [3,5,7.0001]
OK=WHERE_IN(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT, ARRAY,VALUES
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT & STOP



END; #####################  End of Routine ################################
