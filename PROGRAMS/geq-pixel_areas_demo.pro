; $ID:	GEQ-PIXEL_AREAS_DEMO.PRO,	2020-06-03-17,	USER-KJWH	$
PRO GEQ_PIXEL_AREAS_DEMO
FILE = !S.IDL_TEMP +'GEQ_PIXEL_AREAS.SAVE'
D = IDL_RESTORE(FILE)
AREAS = D.MEAN
PRINT,MINMAX(AREAS)
;===> ALL 10X10 PIXEL BOXES :
AREA1 = AREAS(2048:2057,1020:1029) & P,MEAN(AREA1)
AREA2 = AREAS(2048:2057,1060:1069) & P,MEAN(AREA2)
AREA3 = AREAS(2048:2057,1090:1099) & P,MEAN(AREA3)
AREA4 = AREAS(2048:2057,2000:2009) & P,MEAN(AREA4)
AREA5 = AREAS(2048:2057,2030:2039) & P,MEAN(AREA5)
AREA5 = AREAS(2048:2057,2038:2047) & P,MEAN(AREA5)
STOP



;|||||||||||||||||||||||||||||||||||||||||||||
END; #####################  END OF ROUTINE ################################
