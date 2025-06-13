; $Id:	nice_range.pro,	March 05 2007	$

FUNCTION NICE_RANGE, Values

;+
; NAME:
;		NICE_RANGE;
; PURPOSE:
;		This FUNCTION generates a nice range encompassing all the input Values values (1,2,or more elements)
; CATEGORY:
;		MATH
;	CALLING SEQUENCE:
;		Result = NICE_RANGE(Values)
; INPUTS:
;		Numeric e.g. [0.23, 4]
; OUTPUTS:
;   A NICE Range [#,#],with the same IDL data type as the input Values
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;	RESTRICTION:
;		Values MUST BE WITHIN THE RANGE OF 10D^-309 TO 10D^308
;
;	EXAMPLES:
;
;	 	Values = 1.1 							 	& RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;  	Values = [0.0022, 0.0083D] 	& RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;  	Values = [0.011, 3122] 			& RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;  	Values = [1E8, 3122] 				& RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;  	Values = [1, 3,4,8,12] 			& RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;
;  	Negatives
;	 	Values = [-1.5 , -12]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;   Values = [1.5 ,  -12]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;		Values = [-1.5 ,  12]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;
;		Zeros
;		Values = [0 ,  12]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;		Values = [12 , 	0]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;		Values = [0 ,  	0]  & RANGE = NICE_RANGE(Values) & PRINT,Values,RANGE
;
; MODIFICATION HISTORY:
;		Written Jan 21,2004 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;		Nov 4, 2006 J.O'Reilly & Kim Hyde Now handles negative values
;		March 5, 2007 J.O'R  Checks for very small values and sets them to zero
;
;-
;	***********************************************************************************
	ROUTINE_NAME = 'NICE_RANGE'
	ERROR = ''

;	===> Get machine arithmetic floating-point precision
	M=MACHAR()

;	===> Find good data
	OK=WHERE(FINITE(VALUES) AND VALUES NE MISSINGS(VALUES),COUNT)
	IF COUNT EQ 0 THEN BEGIN
		ERROR='No valid values'
		RETURN, ''
	ENDIF

	_VALUES = FLOAT(VALUES(OK))

;	===> Compute Min, Max of Values
	MIN_Values = MIN(_Values,MAX=MAX_Values)


;	===> See if MIN_Values is essentially zero
	IF ABS(MIN_Values) LT ABS(2*M.EPS) THEN MIN_Values(*) = 0
	IF ABS(MAX_Values) LT ABS(2*M.EPS) THEN MAX_Values(*) = 0


;	===> Call DECADES to get an array encompassing the MIN_Values and MAX_Values, resolved in tenths for each decades;
 	D=DECADES()

;	===> Initialize RANGE to same data type as Values
	RANGE = [Values(0),Values(0)]

;	===> Positive MIN_Values
	IF MIN_Values GT 0 THEN BEGIN
		SUBS_MIN = VALUE_LOCATE(D,MIN_Values)
	  RANGE(0) = D(SUBS_MIN)
	ENDIF

;	===> Positive MAX_Values
	IF MAX_Values GT 0 THEN BEGIN
		SUBS_MAX = VALUE_LOCATE(D,MAX_Values)
		RANGE(1) = D(SUBS_MAX)
	 	IF RANGE(1) LT MAX_Values THEN RANGE(1) = D(SUBS_MAX +1L)
	ENDIF

;	===> Negative MIN_Values
 	IF MIN_Values LT 0 THEN BEGIN
 		_D =  REVERSE(-D)
		SUBS_MIN = VALUE_LOCATE(_D,MIN_Values)
	  RANGE(0) = _D(SUBS_MIN)
	ENDIF

;	===> Negative MAX_Values
	IF MAX_Values LT 0 THEN BEGIN
 		_D =  -D
		SUBS_MAX = VALUE_LOCATE(_D,MAX_Values)
	  RANGE(1) = _D(SUBS_MAX)
	  IF RANGE(1) LT MAX_Values THEN RANGE(1) = _D(SUBS_MAX+1L)
	ENDIF


;	===> Zero MIN_Values
	IF MIN_Values EQ 0 THEN RANGE(0) = MIN_Values

;	===> Zero MAX_Values
	IF MAX_Values EQ 0 THEN RANGE(1) = MAX_Values

 RETURN, RANGE

END; #####################  End of Routine ################################

