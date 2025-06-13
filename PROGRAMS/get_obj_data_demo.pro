; $ID:	GET_OBJ_DATA_DEMO.PRO,	2014-04-29	$
PRO GET_OBJ_DATA_DEMO
X = INDGEN(9)
Y = INDGEN(11)
P = PLOT(X,Y,/BUFFER)
S =GET_OBJ_DATA(P)
PSTRUCT,S
ENTER
I = IMAGE(BYTARR([9,11]),/BUFFER)
S =GET_OBJ_DATA(I)
PSTRUCT,S

 STOP



;|||||||||||||||||||||||||||||||||||||||||||||
END; #####################  END OF ROUTINE ################################
