; $Id:	STRUCT_CONCAT_DEMO.PRO,	2003 Dec 02 15:41	$

 PRO STRUCT_CONCAT_DEMO
;+
; NAME:
;       STRUCT_CONCAT_DEMO
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 16, 2004
;-

ROUTINE_NAME='STRUCT_CONCAT_DEMO'


A=REPLICATE(CREATE_STRUCT('A','1','B','1'),2)
B=REPLICATE(CREATE_STRUCT('A','2','B','2'),3)

C = STRUCT_CONCAT(A,B)
SPREAD,C


A=REPLICATE(CREATE_STRUCT('A','1','AA','AA'),2)
B=REPLICATE(CREATE_STRUCT('A','2','B','B','C','C'),3)

C = STRUCT_CONCAT(A,B)
SPREAD,C
STOP


END; #####################  End of Routine ################################



