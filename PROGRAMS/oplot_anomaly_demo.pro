; $Id:	OPLOT_ANOMALY_DEMO.PRO,	2003 Dec 02 15:41	$

 PRO OPLOT_ANOMALY_DEMO, X,Y
;+
; NAME:
;       OPLOT_ANOMALY_DEMO
;
; PURPOSE:
;				PLOT POSITIVE AND NEGATIVE ANOMALIES AS A POLYGON-FILLED
;

;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, July 15, 2004
;-

ROUTINE_NAME='OPLOT_ANOMALY_DEMO'

 ABOVE = 0
 BELOW = 0


X=[1.5,	2,	3,	4,	5.2,	6,	7,	8,	9]

FOR YTYPE = 0,5 DO BEGIN
	IF YTYPE EQ 0 THEN  Y=[10,	10,	20,	20,	-30,	20,	-10, -40,  50]
	IF YTYPE EQ 1 THEN  Y=[10,	10,	20,	20,	 30,	20,	 10,  40,  50]
	IF YTYPE EQ 1 THEN  Y=[10,	10,	20,	20,	 30,	20,	 10,  40,  -50]
	IF YTYPE EQ 2 THEN  Y=[-10,	10,	20,	20,	 30,	20,	 10,  40,  50]
	IF YTYPE EQ 3 THEN  Y=[ 10,	-10,	-20,	-20,	 -30,	-20,	 -10,  -40,  -50]
	IF YTYPE EQ 4 THEN  Y=[-10,	-10,	-20,	-20,	 -30,	-20,	 -10,  -40,  -50]

 OPLOT_ANOMALY,X,Y

STOP

ENDFOR


END; #####################  End of Routine ################################



