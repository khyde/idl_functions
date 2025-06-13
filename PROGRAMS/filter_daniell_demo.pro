; $ID:	FILTER_DANIELL_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO FILTER_DANIELL_DEMO
;+
; NAME:
;       FILTER_DANIELL_DEMO
;
; PURPOSE:
;				Smooth a 1-d data series using a Trapezoidal Danielle Filter

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Feb 7, 2004
;-

	ROUTINE_NAME='FILTER_DANIELL_DEMO'
	PAL_36




	PSPRINT,/FULL,/COLOR
	!P.MULTI=[0,2,2]
	PRINT,'**** FILTER DANIELL ****'



;	===> Demonstrate the differences between SMOOTH and Daniell Filters
	DATA=[1.,0,1.5,0,1,0,1,0.,1,0,1,0,1,0,1.5,0,1]
	PRINT, 'DATA:'
	PRINT,DATA
	PRINT, 'SMOOTH width=5: '
 	PRINT, SMOOTH(DATA,5)
 	PRINT, 'SMOOTH EDGE_TRUNCATE, width=5: '
	PRINT, smooth(DATA,5,/EDGE_TRUNCATE)
  d= FILTER_DANIELL(DATA,5,FILT=FILT)
  PRINT, 'SMOOTH DANIELL Width=5'
  PRINT,D
  PRINT
  PRINT,'Effect of EDGE_TRUNCATE is to reuse the available end points'
  PRINT,'DATA[0]*0.125 + DATA[0]*0.25+DATA[0]*0.25 + DATA[1]*0.25 +DATA(2)*0.125'
  PRINT,DATA[0]*0.125 + DATA[0]*0.25+DATA[0]*0.25 + DATA[1]*0.25 +DATA(2)*0.125
  PRINT,'DATA[0]*0.125 + DATA[0]*0.25+DATA[1]*0.25 + DATA(2)*0.25 +DATA(3)*0.125'
  PRINT,DATA[0]*0.125	+ DATA[0]*0.25+DATA[1]*0.25 + DATA(2)*0.25 +DATA(3)*0.125
  PRINT,'DATA[0]*0.125 + DATA[1]*0.25+DATA(2)*0.25 + DATA(3)*0.25 +DATA(4)*0.125'
  PRINT,DATA[0]*0.125	+	DATA[1]*0.25+DATA(2)*0.25 + DATA(3)*0.25 +DATA(4)*0.125




;	***************************************
;	***** Compare Smooth with Daniell *****
;	***************************************
	PSPRINT,/FULL,/COLOR
	!P.MULTI=[0,6,6]
	PRINT,'**** FILTER DANIELL ****'
	FOR NTH=0,4 DO BEGIN
    IF NTH EQ 0 THEN DATA=replicate(1.5,21)
    IF NTH EQ 1 THEN DATA=FINDGEN(21)
		IF NTH EQ 2 THEN DATA=[1.0, 0,	1,	0,	1,	0,	1,	0.,	1,	0,	1,	0,	1,	0,	1,	0,	1,	0,	1,	0,	1]
		IF NTH EQ 3 THEN DATA=[1.,	1,	0,	0,	1,	1,	0,	0,	1,	1,	0,	0,	1,	1,	0,	0,	1,	1,	0,	0,	1]
		IF NTH EQ 4 THEN DATA=[1.,	1,	1,	0,	0,	0,	1,	1,	1,	0,	0,	0,	1,	1,	1,	0,	0,	0,	1,	1,	1]

		DD=DATA
		SS=DATA
		FOR WIDTH=3,13,2 DO BEGIN
			PLOT, DD,TITLE='WIDTH: '+NUM2STR(WIDTH)
			DD=FILTER_DANIELL(DD,WIDTH,FILT=FILT)
			SS=SMOOTH(SS,WIDTH,/EDGE_TRUNCATE)

  		OPLOT, DD,COLOR=8,THICK=3
  		OPLOT, SS,COLOR=21,THICK=2
		ENDFOR
	ENDFOR


		DD=DATA
		WIDTH=3
		FOR NTH=0,5 DO BEGIN
			DD=FILTER_DANIELL(DD,WIDTH,FILT=FILT)
	 		PLOT, DATA,TITLE='WIDTH: '+NUM2STR(WIDTH)
  		OPLOT, DD,COLOR=8,THICK=2
		ENDFOR
	PSPRINT






END; #####################  End of Routine ################################



