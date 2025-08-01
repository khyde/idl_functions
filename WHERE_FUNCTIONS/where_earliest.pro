; $ID:	WHERE_EARLIEST.PRO,	2020-06-26-15,	USER-KJWH	$
;###############################################################################
FUNCTION WHERE_EARLIEST, ARRAY, DATE,COUNT, NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT;+

;	THIS FUNCTION FINDS ELEMENTS IN THE ARRAY WHICH HAVE THE EARLIEST DATES
; OK = WHERE_EARLIEST(ARRAY,DATE,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
;
; OUTPUT:		SUBSCRIPTS OF THE INPUT ARRAY HAVING THE EARLIEST DATES
;
; ARGUMENTS:
; 	ARRAY:	REQUIRED INPUT: A SCALAR OR ARRAY
; 	VALUES: REQUIRED INPUT: A SCALAR OR ARRAY OF VALUES TO FIND IN THE ARRAY
;   COUNT:  OUTPUT: THE NUMBER OF ARRAY ELEMENTS HAVING THE EARLIEST DATE
;		(COUNT WILL BE THE NUMBER OF UNIQUE (ARRAY+DATE) ELEMENTS)
;
;
; KEYWORDS:
;   NCOMPLEMENT:  OUTPUT: THE NUMBER OF ARRAY ELEMENTS NOT MATCHING ANY ELEMENT IN VALUES
;    COMPLEMENT:  OUTPUT: THE SUBSCRIPTS OF ARRAY NOT MATCHING ANY VALUE IN VALUES ARRAY
;
; EXAMPLE:
;		ARRAY = ['EE',			'AA',				'BB',				'CC',				'BB',				'DD',				'AA']
;		DATE  = ['20030401','20030502',	'20030501',	'20030504',	'20030503',	'20030505',	'20030504']
;		OK = WHERE_EARLIEST(ARRAY,DATE,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
;
;		PRINT,COUNT
;		PRINT,ARRAY[OK]
;
;		PRINT,'OLDER DUPLICATES= ',+NUM2STR(NCOMPLEMENT)
;		IF NCOMPLEMENT GE 1 THEN PRINT,ARRAY(COMPLEMENT)
;
;		EXAMPLE (WHERE NO DUPLICATES):
;		ARRAY = ['EE',			'AA',				 						'CC',				'BB',				'DD' 				     ]
;		DATE  = ['20030401','20030502',							'20030504',	'20030503',	'20030505'       ]
;		OK = WHERE_EARLIEST(ARRAY,DATE,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
;
;		PRINT,COUNT
;		PRINT,ARRAY[OK];
;		PRINT,'OLDER DUPLICATES= ',+NUM2STR(NCOMPLEMENT)
;		IF NCOMPLEMENT GE 1 THEN PRINT,ARRAY(COMPLEMENT)
;

; NOTES:
;  THE ORIGINAL ORDER OF ELEMENTS IN ARRAY AND VALUES IS NOT CHANGED BY THIS PROGRAM
;	 THE SUBSCRIPTS RETURNED REFER TO THE ORIGINAL INPUT ARRAY ORDER

;
; HISTORY:
;	 MAY 5, 2003	WRITTEN BY:	J.E. O'REILLY, NOAA, 28 TARZWELL DRIVE, NARRAGANSETT, RI 02882
;-
; *************************************************************************

 
  ROUTINE_NAME='WHERE_EARLIEST'


; =====> DETERMINE SIZE,AND IDLTYPES OF ARRAY AND VALUES
  SZ_ARRAY 	= SIZE(ARRAY,/STRUCT)
  SZ_DATE 	= SIZE(DATE,/STRUCT)

;	===> MAKE A SUBSCRIPT INDEX FOR THE ARRAY
  INDEX 		= LINDGEN(N_ELEMENTS(ARRAY))

; ===> SORT THE CONCONCATENATED (_ARRAY + DATE)
  SRT 			= SORT(STRTRIM(ARRAY,2)+STRTRIM(DATE,2))
  SRT       = REVERSE(SRT)

;	===> REARRANGE _ARRAY AND INDEX
  _ARRAY 		= ARRAY(SRT)
  _INDEX 		= INDEX(SRT)
;	===> DETERMINE UNIQ OF SORTED _ARRAY (WITHOUT DATE APPENDED)
  U    			=	UNIQ(_ARRAY)

;	===> SORT SO SUBS RETURNED ARE IN THE ORDER OF THE INPUT ARRAY
  S=SORT(_INDEX(U))
  SUBS = _INDEX(U(S))
  COUNT = N_ELEMENTS(SUBS)


  TEST =REPLICATE(0,N_ELEMENTS(ARRAY))
  TEST(SUBS) = 1
;	===> NOW DETERMINE THE COMPLEMENT (EARLIEST OF ANY DUPLICATES)
  COMPLEMENT = WHERE(TEST EQ 0,NCOMPLEMENT)

  RETURN, SUBS



END; #####################  END OF ROUTINE ################################
