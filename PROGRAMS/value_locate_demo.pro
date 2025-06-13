; $ID:	VALUE_LOCATE_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

 PRO VALUE_LOCATE_DEMO, STRUCT
;+
; NAME:
; 	VALUE_LOCATE_DEMO

;		This Program Deomonstrates IDL's VALUE_LOCATE

; 	MODIFICATION HISTORY:
;			Written Nov 3, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='VALUE_LOCATE_DEMO'

;if j = -1           	Value [i] < Vector [0]
;if 0 LE j < N-1      Vector [j] LE Value [i] < Vector [j+1]
;if j = N-1          	Vector [N-1] LE Value [i]
;If Vector is monotonically decreasing
;if j = -1           	Vector [0] LE Value [i]
;if 0 LE j < N-1      Vector [j+1] LE Value [i] < Vector [j]
;if j = N-1          	Value [i] < Vector [N-1]

	ARRAY = [100,150]
	VALUES = [99,100,101,150,151]

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR ORDER = 0,1 DO BEGIN
		IF ORDER EQ 0 THEN PRINT,'ASCENDING ARRAY'
		IF ORDER EQ 1 THEN BEGIN
			ARRAY=REVERSE(ARRAY)
			PRINT,'DESCENDING ARRAY'
		ENDIF

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH = 0,N_ELEMENTS(VALUES)-1 DO BEGIN
			VALUE = VALUES[NTH]
	 		PRINT, 'ARRAY: ',ARRAY
	 		PRINT, 'VALUE: ',VALUE
	 		PRINT, 'SUB: ',VALUE_LOCATE(ARRAY,VALUE)

			OK=WHERE_NEAREST(ARRAY,VALUE,NEAR=150)
			PRINT, 'WHERE_NEAREST: ',OK
			PRINT
		ENDFOR
	ENDFOR




END; #####################  End of Routine ################################



