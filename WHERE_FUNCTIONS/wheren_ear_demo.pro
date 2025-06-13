PRO WHERENEAR_DEMO
ROUTINE_NAME= 'WHERENEAR_DEMO'

GOTO, SKIP
; ***
ARRAY=[ 2 ]
VALUES = [2]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

SKIP:
; ***
ARRAY=[ 2,2 ]
VALUES = [2]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

STOP
; ***
ARRAY=[ 2 ]
VALUES = [2,2,2]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

; ***
ARRAY=[ 2 ]
VALUES = [3]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

; ***
ARRAY=[ 2 ]
VALUES = [3,4]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

; ***
ARRAY= FINDGEN(10)
VALUES = [ 1.89, 1.91, 2.0,2.0,2.0,2.09, 3.0, 4.91,7.0]
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT



; ***
ARRAY= FINDGEN(10)
VALUES = [ 1.89, 1.91, 2.0,2.0,2.0,2.09, 3.0, 4.91,7.0]
NEAR=0.1
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
PRINT,'NEAR:',NEAR
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement,NEAR=NEAR)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT


; ***
ARRAY= FINDGEN(10)
VALUES = [ 1.89, 1.91, 2.0,2.0,2.0,2.09, 3.0,4.5, 4.91,7.0]
NEAR= 0.5
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
PRINT,'NEAR:',NEAR
OK=WHERENEAR(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement,NEAR=NEAR)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT


; ***


ARRAY = [ 0,1, 2,3,4,5,6.] &

array = 2
VALUES=2.6
TOL= 0.5


END