; $ID:	NUM2STR.PRO,	2020-06-30-17,	USER-KJWH	$
FUNCTION NUM2STR,DATA,FORMAT=format, COMMA=comma,TRIM=trim, DECIMALS=decimals, LEADING=leading, VERTICAL=vertical, DOWN=down
;+
;	This Function Converts a number or a numerical array into a String or String Array
; SYNTAX:
;	Result = NUM2STR(Data, [FORMAT=FORMAT],[COMMA=comma],TRIM=trim,[LEADING=leading] )
; OUTPUT:
;	String or String Array, depending in the input
; ARGUMENTS:
; 	Data:	Nuereic
; KEYWORDS:
;		FORMAT:	Standard IDL FORMAT STATEMENTS
;		COMMA:	Delimits large numbers with commas
;		TRIM:		TRIM ZEROS
;						1= Remove trailing zeros
;						2= Remove trailing zeros and the decimal if all zeros follow the decimal
;						3= Remove trailing zeros, trailing decimals, leading zeros
;		LEADING:Pads beginning of string with ZEROS
;		DOWN:   Keyword to not round up a number
;
; INPUTS:	NUMBER
;
; EXAMPLE:
;		PRINT, NUM2STR([1.0,2.2,3.3])
;   TXT= NUM2STR([1,-2,0,124],LEADING=3)
; CATEGORY:
;		STRING
; NOTES:
; VERSION:
;		Apr 10, 2001
; HISTORY:
;		April 9, 1997	Written by:	J.E. O'Reilly
;   April 14,1997	Remove last delimiter from string (JOR)
;   June 13,1998 	Convert input binary to integer
;   Dec 1,1998		added capability to output comma delmiited large numbers
;		April 10,2001 Added TRIM
;		April 1, 2007 JOR. Added Decimals
;   August 7, 2013 KJH Added keword DOWN to not round up a number

;-
; ***********************************************************


  ROUTINE_NAME='NUM2STR'
; MUST SEE IF NEGATIVE BEFORE CONVERTING TO ULONG TYPE
  TXT = ''
  N = N_ELEMENTS(DATA)
  NTH = N-1L

  IDL_CODE=IDLTYPE(data,/CODE)

;	===> If no format but leading then
 IF N_ELEMENTS(FORMAT) EQ 0 THEN BEGIN
  CASE IDL_CODE OF
  0:  FMT = 'UNDEFINED'
  1:  FMT = '(I)'
  2:  FMT = '(I)'
  3:  FMT = '(I)'
  4:  FMT = '(F)'
  5:  FMT = '(D)'
  6:  FMT = ''
  7:  FMT = '(A)'
  8:  FMT = '(A)' ; Structure tags converted to string
  9:  FMT = ''
  10: FMT = ''
  11: FMT = ''
  12:  FMT = '(I)'
  13:  FMT = '(I)'
  14:  FMT = '(I)'
  15:  FMT = '(I)'
  ENDCASE

 	IF N_ELEMENTS(LEADING) EQ 1 THEN FMT = '(I'+STRTRIM(LEADING)+')'

 ENDIF ELSE FMT = FORMAT



 IF IDL_CODE EQ 1 THEN BEGIN
 	TXT =  STRING(LONG(DATA),FORMAT=FMT)  ; (BINARY)
 ENDIF ELSE BEGIN
 	TXT =  STRING(DATA,FORMAT=FMT)
 ENDELSE

IF NOT KEYWORD_SET(LEADING) THEN BEGIN
	TXT=STRTRIM(TXT,2)
ENDIF ELSE BEGIN
	B=BYTE(TXT)
	OK_NEG = WHERE(STRPOS(TXT,'-') GE 0,COUNT_NEG)
  IF COUNT_NEG GE 1 THEN BEGIN
   	OK_BNEG = WHERE(B EQ 45,COUNT_BNEG)
   	B[OK_BNEG] = 48B
   	TXT = STRING(B)
 	ENDIF
 	OK=WHERE(B EQ 32,COUNT)
 	IF COUNT GE 1 THEN BEGIN
 		B[OK] = 48B
 		TXT = STRING(B)
 	ENDIF
ENDELSE

IF N_ELEMENTS(TXT) EQ 1 THEN TXT  = TXT[0]


; **********************************************************
; *******  Check if comma delimited desired  ***************
; **********************************************************

  IF KEYWORD_SET(COMMA) THEN BEGIN
		TXT_WHOLE=TXT
    TXT_PART  = REPLICATE('',N)

    POS = STRPOS(TXT,'.')
    OK = WHERE(POS NE -1,COUNT)
    IF COUNT GE 1 THEN BEGIN
      FOR _OK = 0L,COUNT-1L DO BEGIN
      	TXT_WHOLE(OK(_OK)) 	= STRMID(TXT(OK(_OK)),0,(POS(ok(_ok)) > 1))
      	TXT_PART(OK(_OK)) 	= STRMID(TXT(OK(_OK)),POS(ok(_ok)),100)
      ENDFOR
    ENDIF

;   LLLLLLLLLLLLLLLLLLLLLLLL
    FOR I = 0L,NTH DO BEGIN
      ATXT = STRTRIM(STRING(TXT_WHOLE(I)),2)
      LEN = STRLEN(ATXT)
      NEG = STRPOS(ATXT,'-',0) EQ 0
      LEN = LEN - NEG
      ATXT = STRMID(ATXT,NEG)
      LEN_MOD_3 = LEN MOD 3
      TRIPLETS = LEN/3 & PART = LEN - (TRIPLETS*3)
      BTXT=STRMID(atxt,	0							,LEN_MOD_3)
      IF BTXT EQ '' AND TRIPLETS GE 1 THEN BEGIN
      	BTXT = STRMID(atxt,0,3)
      	JJ=1
      ENDIF ELSE JJ = 0

;			J=1 (only add comma if more than one triplet
      FOR J = JJ,TRIPLETS-1 DO BEGIN
      	BTXT=BTXT+','+STRMID(atxt, (J*3+LEN_MOD_3)	,	3)
			ENDFOR
;     Clean up cases of '-,'
      IF NEG THEN BTXT = '-'+BTXT
      TXT[I] = BTXT+TXT_PART(I)
    ENDFOR

  ENDIF ;   IF KEYWORD_SET(COMMA) THEN BEGIN






; ********************
; ***  T  R I  M   ***
; ********************
  IF KEYWORD_SET(TRIM) THEN BEGIN
;   ===> BYTES, INTEGERS, LONG, UL LL CAN NOT HAVE DECIMALS ... SO RETURN
    IF IDLTYPE(DATA,/INTEGER) EQ 1 THEN RETURN, TXT
    TXT = STR_ZERO_TRIM(TXT, TRIM=TRIM)
  ENDIF


;	*************************
;	*** D E C I M A L S   ***
;	*************************
	IF N_ELEMENTS(DECIMALS) EQ 1 THEN BEGIN
		TXT = ROUNDS(TXT, DECIMALS, DOWN=DOWN)
	ENDIF

;	*************************
;	*** V E R T I C A L   ***
;	*************************
  IF N_ELEMENTS(VERTICAL) EQ 1 THEN BEGIN
    BTXT = REPLICATE('',N_ELEMENTS(TXT))
    FOR NTH=0L,N_ELEMENTS(TXT)-1L DO BEGIN
      LEN = STRLEN(TXT[NTH])
      FOR POS = 0,LEN-1 DO BEGIN
        BTXT[NTH] = BTXT[NTH] + STRMID(TXT[NTH],POS,1) + '!S!B'
      ENDFOR
    ENDFOR
    TXT=BTXT
  ENDIF

  IF N EQ 1 THEN TXT = TXT[0]
  RETURN, TXT

  END; #####################  End of Routine ################################
