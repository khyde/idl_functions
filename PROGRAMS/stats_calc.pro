; $ID:	STATS_CALC.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION STATS_CALC, ERROR=error,NAME = NAME

;+
; NAME:
;       STATS_CALC
;
; PURPOSE:
;				Compute Statistics (Min,Max,Mean,Standard Deviation) for each pixil from a series of of 2-d Image Arrays
;
;
; INPUTS:
;       Image_array
;
; KEYWORD PARAMETERS:
;       NONE
; OUTPUTS:
;

; RESTRICTIONS:
;       None.
;
 ;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly (NOAA, NEFSC), August 6, 2004

;-

	ROUTINE_NAME='STATS_CALC'

;	*****************
;	*** CONSTANTS ***
;	*****************
	NEG_INF = 	-MISSINGS(0.0)	;
	POS_INF =    MISSINGS(0.0)

; *********************************************************************************************************
   COMMON COMMON_STATS_SUM,_DO_ASSOC,_NAME, _DATA,_SZ, _TRANSFORM, _MISSING, _RANGE,_N_SETS, $
  														A_NUM,A_MIN,A_MAX,A_NEG,A_SUM,A_SSQ,A_WTS,A_MEAN,A_STD,$
  												  	_NUM,_MIN,_MAX,_NEG,_SUM,_SSQ,_WTS,_MEAN,_STD
; *********************************************************************************************************
;	===> Check if STATS_SUM has been used to accumulate statistics (before STATS_CALC may be called)
	IF N_ELEMENTS(_N_SETS) LT 1 THEN BEGIN
  	ERROR = 1
	  PRINT,'ERROR: Must first use STATS_SUM before using STATS_CALC'
	  RESULT = -1L
	  GOTO, DONE
	ENDIF ELSE ERROR = 0



;	****************************
  IF _DO_ASSOC EQ 0 THEN BEGIN
; ****************************

;		===> Dimension _mean,_std to match dimensions of _sum and set arrays to missing
		_MEAN    = _SUM
		_MEAN(*) = MISSINGS(_MEAN)
		_STD     = _SUM
		_STD(*)  = MISSINGS(_STD)

; 	===> Calculate MEAN
; 	===> Find the pixels with at least 1 value
  	ok = WHERE(_NUM GE 1,COUNT)
  	IF count GE 1 THEN BEGIN
; 		===> Calculate average (raw _DATA units ug/l)
    	_MEAN[OK]= _SUM[OK]/FLOAT(_NUM[OK])
;   	===> Compute gmean if _TRANSFORM = 'ALOG'
			IF _TRANSFORM EQ 'ALOG' 	THEN _MEAN[OK] = EXP(_MEAN[OK])
    	IF _TRANSFORM EQ 'ALOG10' THEN _MEAN[OK] = 10.0^_MEAN[OK]

;   	===> Calculate Standard deviation
    	OK2 = WHERE(_NUM GE 2,COUNT_2) ; can not calculate a std for n = 1
    	IF count_2 GE 1 THEN BEGIN
;			===> Do STD in DOUBLE then store in the FLOAT STD
      	 _STD(OK2)= (((_SSQ(OK2)-((_SUM(OK2)*_SUM(OK2))/_NUM(OK2)))^0.5)/((_NUM(OK2)-1)^0.5)) ;;

;			===> Check for values of NAN which should be set to zero because of imprecision and rounding errors in the above equation
			OK_NAN = WHERE(FINITE(_STD(OK2)) EQ 0,COUNT_NAN)
			IF COUNT_NAN GE 1 THEN _STD(OK2(OK_NAN)) = 0
    	ENDIF ; ; IF count GE 2 THEN BEGIN
  	ENDIF ; IF count GE 1 THEN BEGIN

; 	===> Construct a  STRUCTURE to hold statistical results
 		RESULT =  CREATE_STRUCT('PROD','','RANGE',_RANGE, 'TRANSFORM',_TRANSFORM, 'N_SETS',_N_sets,$
            'NUM',_NUM, 'MIN', _MIN, 'MAX',_MAX,'NEG',_NEG,$
            'SUM',_SUM, 'SSQ',_SSQ,$
            'WTS',_WTS,$
           	'MEAN',_MEAN,$
           	'STD',_STD)

;	****************
	ENDIF ELSE BEGIN
; ****************

; 	 NUM,MIN,MAX,NEG,WTS,SUM,SSQ
 		A_NUM  = ASSOC(1,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
		A_MIN  = ASSOC(2,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
    A_MAX  = ASSOC(3,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
    A_NEG  = ASSOC(4,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
    A_WTS  = ASSOC(5,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
    A_SUM  = ASSOC(6,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))
   	A_SSQ  = ASSOC(7,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))

;		********************************************************************************
;		===> Open a new file for the MEAN, set to MISSINGS, and associate
;					_MEAN and _STD to match dimensions of statistical arrays
  	OPENW, 8, _NAME+'_MEAN.dat' & WRITEU,8, REPLICATE(POS_INF,_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1])
	  A_MEAN  = ASSOC(8,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))

;		===> Open a new file for the STD, set to MISSINGS, and associate it
 		OPENW, 9, _NAME+'_STD.dat' & WRITEU,9, REPLICATE(POS_INF,_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1])
	  A_STD  = ASSOC(9,FLTARR(_SZ.DIMENSIONS[0],_SZ.DIMENSIONS[1]))

; 	===> Calculate MEAN
; 	===> Find the pixels with at least 1 value
		_NUM = A_NUM(*,*,0)
  	ok = WHERE(_NUM GE 1,COUNT)

  	IF count GE 1 THEN BEGIN
; 		===> Calculate average (raw _DATA units ug/l)
			_MEAN = A_MEAN(*,*,0)
			_SUM  = A_SUM(*,*,0)
    	_MEAN[OK]= _SUM[OK]/FLOAT(_NUM[OK])

;   	===> Compute gmean if _TRANSFORM = 'ALOG'
			IF _TRANSFORM EQ 'ALOG' 	THEN _MEAN[OK] = EXP(_MEAN[OK])
    	IF _TRANSFORM EQ 'ALOG10' THEN _MEAN[OK] = 10.0^_MEAN[OK]
    	A_MEAN(*,*,0) = _MEAN
    	_MEAN = ''

			_SSQ = A_SSQ(*,*,0)
			_STD = A_STD(*,*,0)
;   	===> Calculate Standard deviation
    	OK2 = WHERE(_NUM GE 2,COUNT_2) ; can not calculate a std for n = 1
    	IF count_2 GE 1 THEN BEGIN
;			===> Do STD in DOUBLE then store in the FLOAT STD
      	 _STD(OK2)= (((_SSQ(OK2)-((_SUM(OK2)*_SUM(OK2))/_NUM(OK2)))^0.5)/((_NUM(OK2)-1)^0.5)) ;;

;			===> Check for values of NAN which should be set to zero because of imprecision and rounding errors in the above equation
			OK_NAN = WHERE(FINITE(_STD(OK2)) EQ 0,COUNT_NAN)
			IF COUNT_NAN GE 1 THEN _STD(OK2(OK_NAN)) = 0
			A_STD = _STD(*,*,0)

    	ENDIF ; ; IF count GE 2 THEN BEGIN
  	ENDIF ; IF count GE 1 THEN BEGIN



; 	===> Construct a  STRUCTURE to hold statistical results
 		RESULT =  CREATE_STRUCT('PROD','','RANGE',_RANGE, 'TRANSFORM',_TRANSFORM, 'N_SETS',_N_sets,$
            'NUM',A_NUM(*,*,0), 'MIN', A_MIN(*,*,0), 'MAX',A_MAX(*,*,0),'NEG',A_NEG(*,*,0),$
            'SUM',A_SUM(*,*,0), 'SSQ',A_SSQ(*,*,0),$
            'WTS',A_WTS(*,*,0),$
           	'MEAN',A_MEAN(*,*,0),$
           	'STD',A_STD(*,*,0))
;	*******
	ENDELSE
;	*******

;  STAT TYPES ['NUM','MIN','MAX','SUM','SSQ','NEG','WTS','FREQ']

  DONE:
  RETURN, RESULT
END; #####################  End of Routine ################################
