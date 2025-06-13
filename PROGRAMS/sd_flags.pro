; $Id:	sd_flags.pro,	May 02 2011	$

 FUNCTION sd_flags, DATA, FLAG=flag, NAMES=NAMES,QUIET=quiet,SENSOR=sensor
;+
; NAME:
;       sd_flags
;
; PURPOSE:
;       Generate a structure lisTing which of the 16 SEADAS flags are set
;       (0= NOT set; 1 = set)
;
;       If more than one integer is provided to this program then the output
;       structure will have the totals for occurances of each flag
;
; CATEGORY:
;       SEADAS
;
; CALLING SEQUENCE:
;       Result = sd_flags(333) ; provide a single integer value
;       Result = sd_flags([333,-555]) ; provide an integer array and get totals for each flag
;       Result = sd_flags(image) ; provide an integer image and get totals for each flag
;
; INPUTS:
;       An integer or integer array or integer image

;
; KEYWORD PARAMETERS:
;      QUIET: Prevents printing of flag structure
;
; OUTPUTS:
;      An IDL structure with the SEADAS Flags
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Calls BITS.PRO
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 11,1998
;       Oct 22,2001  Send in a flag name instead of INTEGERS, return flag subscript
;				Oct 12, 2006	K.J.W.Hyde	Changed the sensor option - if no sensor is provided then flag names are _0, _1 etc.
;																	Added a sensor option to include flags set by Rick Stumpf (either 'STUMPF' or 'AUX')
;																	Changed the flag input so that more than flag can be returned at a time
;																	Changed the output so that the name, count and subs are returned in a structure
;       Apr 6, 2010 T.Ducas REPRO6 L2_FLAG changes.
;-
; ===============>

	IF N_ELEMENTS(DATA) GE 1 THEN _DATA = DATA

	IF N_ELEMENTS(SENSOR) LT 1 THEN BEGIN
		_SENSOR = ''
    FLAG_NAMES = '_' + STRTRIM(SINDGEN(8*IDLTYPE(_DATA,/NBYTES)),2)
    FLAG_NUMBER = INDGEN(N_ELEMENTS(FLAG_NAMES))
    IF KEYWORD_SET(NAMES) AND NOT KEYWORD_SET(FLAG) THEN RETURN, FLAG_NAMES
  ENDIF ELSE BEGIN

		IF STRUPCASE(SENSOR) EQ 'SEAWIFS' OR STRUPCASE(SENSOR) EQ 'MODIS' OR STRUPCASE(SENSOR) EQ 'CZCS' THEN BEGIN
		  _SENSOR = STRUPCASE(SENSOR)


;				SEADAS 6.0 Level-2 Flag Names and Description Table
;
;																					Flag #		Bit #  		Flag Names
				FLAG_NAMES =[								$
										'ATMFAIL',			$   ;		0 				1 On
										'LAND',					$		; 	1 				2 On
										'PRODWARN',			$		; 	2 				3 Off
										'HIGLINT',			$		; 	3 				4 On for validation, maybe off for general processing
										'HILT',					$		; 	4 				5 On
										'HISATZEN',			$		; 	5 				6 On for validation, maybe off for general processing
										'COASTZ',				$		; 	6 				7 Bathymetry? Off
										'SPARE',				$		; 	7 				8 
										'STRAYLIGHT',		$		; 	8 				9 On for validation, maybe off for general processing
										'CLDICE',				$		; 	9 				10 ? Can probably leave off
										'COCCOLITH',		$		; 	10				11 Off
										'TURBIDW',			$		; 	11				12 Off
										'HISOLZEN',			$		; 	12				13 On for validation, maybe off for general processing
										'SPARE',				$		; 	13				14 Blank
										'LOWLW',				$		; 	14				15 ?
										'CHLFAIL',			$		; 	15				16 ?
										'NAVWARN',			$		; 	16				17 
										'ABSAER',				$		; 	17				18
				 						'SPARE',				$		; 	18				19
										'MAXAERITER',		$		; 	19				20
				 						'MODGLINT',			$		; 	20				21
				 						'CHLWARN',			$		; 	21				22
				 						'ATMWARN',			$		; 	22				23
				 						'SPARE',				$   ;		23				24
				 						'SEAICE',				$		; 	24				25
				 						'NAVFAIL',			$		; 	25				26
				 						'FILTER',				$		; 	26				27
				 						'SSTWARN',			$		; 	27				28
				 						'SSTFAIL',			$		; 	28				29
				 						'HIPOL',				$		; 	29				30
				 						'PRODFAIL',			$		; 	30				31
										'SPARE']		        ;		31				32





	  	FLAG_NUMBER = INDGEN(N_ELEMENTS(FLAG_NAMES))
 	  IF KEYWORD_SET(NAMES) AND N_ELEMENTS(FLAG) LT 1 THEN RETURN, FLAG_NAMES
	  ENDIF
	ENDELSE

	IF N_ELEMENTS(_SENSOR) LT 1 THEN RETURN,-1														; Invalid sensor name
	IF N_ELEMENTS(FLAG) LT 1 THEN _FLAG = FLAG_NUMBER ELSE BEGIN					; Get all available flags
		FLAG_TYPE = SIZE(FLAG,/TYPE)
		IF FLAG_TYPE NE 7 THEN _FLAG = FLAG ELSE BEGIN
			FOR FTH = 0L, N_ELEMENTS(FLAG)-1 DO BEGIN
				OK = WHERE(FLAG_NAMES EQ FLAG(FTH),COUNT)
				IF COUNT GE 1 THEN IF FTH EQ 0 THEN _FLAG = FLAG_NUMBER(OK) $
				ELSE _FLAG = [_FLAG,FLAG_NUMBER(OK)] $
				ELSE PRINT, '    ERROR:  ' + FLAG(FTH) + ' is an invalid flag name'
			ENDFOR
		ENDELSE
	ENDELSE

	IF KEYWORD_SET(NAMES) THEN RETURN, FLAG_NAMES(_FLAG)

  TYPE = SIZE(_DATA, /TYPE)											; see if DATA contains flags_names string array


;	===> If input data is STRING, then double check the following code for the desired output
	IF TYPE EQ 7 THEN BEGIN
  	FLAGS_SUBS = INDGEN(N_ELEMENTS(_DATA))
	  FLAGS_SUBS(*) = -1													; subscript will be -1 if flag name not found
  	NAMES = FLAG_NAMES
  	FOR N = 0L,N_ELEMENTS(_DATA) -1L DO BEGIN		; find subscripts in flags name array for flags_browse names
    	OK = WHERE(NAMES EQ _DATA(N), COUNT)
     	IF COUNT EQ 1 THEN FLAGS_SUBS(N) = OK
   	ENDFOR
   	RETURN,FLAGS_SUBS
 	ENDIF

; ===> RETURN THE NAME, SUBSCRIPTS AND COUNT FOR EACH GIVEN FLAG (IF NO FLAGS ARE GIVEN, RETURN A STRUCTURE WITH ALL FLAGS)
  IF N_ELEMENTS(_DATA) GE 1 AND NOT KEYWORD_SET(NAMES) THEN BEGIN
  	B = BITS(_DATA,_FLAG,/STRUCT)
  	BTAGS = TAG_NAMES(B)
  	B = STRUCT_RENAME(B,BTAGS,FLAG_NAMES(_FLAG))
  	RETURN,B
	ENDIF


	RETURN, -1
END ; end of program
