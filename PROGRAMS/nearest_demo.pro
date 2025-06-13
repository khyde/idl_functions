PRO WHERENEAREST_DEMO
ROUTINE_NAME= 'WHERENEAREST_DEMO'


; ***
ARRAY= FINDGEN(10)
VALUES = [ 1.910]
NEAR=0.1
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
PRINT,'NEAR:',NEAR
OK=NEAREST(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement,NEAR=NEAR)
PRINT,'FOUND '+NUM2STR(COUNT)
IF COUNT GE 1 THEN PRINT, Array(ok)
PRINT,'NOT FOUND '+NUM2STR(ncomplement)
IF ncomplement GE 1 THEN PRINT,array(complement)
PRINT

STOP
; ***
ARRAY= FINDGEN(10)
VALUES = [ 1.89, 1.91, 2.0,2.0,2.0,2.09, 3.0,4.5, 4.91,7.0]
NEAR= 0.5
PRINT,'Array:', ARRAY
PRINT,'Values:',VALUES
PRINT,'NEAR:',NEAR
OK=WHERENEAREST(ARRAY,VALUES,count,ncomplement=ncomplement,complement=complement,NEAR=NEAR)
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