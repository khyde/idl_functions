; $Id:	idltype.pro,	October 12 2006	$

  FUNCTION IDLTYPE, Variable, CODE=code, NBYTES=nbytes, NAME=name, NUMERIC=numeric, INTEGER=integer
;+
; NAME:
; IDLTYPE
;
; PURPOSE:
;
; Return the data type of an IDL Variable as a String
;   or the idl code for the data type as an a long integer
;
;   See Page 121, Table 9.1, Building IDL Applications,
;   IDL Version 5.0, March, 1997 Edition
;
;
; EXAMPLES::
; 	PRINT,IDLTYPE(0B)
;		PRINT,IDLTYPE(0L,/CODE)
;		PRINT,IDLTYPE(0L,/NAME)
;		PRINT,IDLTYPE(0L,/NBYTES)
;		PRINT,IDLTYPE(0L,/NUMERIC)
; or:
; 	result = IDLTYPE(Variable, /CODE )

; INPUTS:
; 	Variable = anything.
;
; KEYWORDS:
; /CODE : 	Returns the IDL type code
; /NAME :		Returns the IDL type NAME
; /NBYTES : Returns the Number of bytes for the data type
; /NUMERIC: Returns 1 if the IDL type is Numeric, 0 if not
;	/INTEGER: Returns 1 if the IDL type is integer, 0 if not
;
; HISTORY:
;   Written, Frank Varosi NASA/GSFC 1989.
;   Modified June 30,1997 J.O'Reilly, NMFS,NOAA:
;            Changed name of program from vartype to idltype;
;            Changed names of idl types to agree with idl functions (e.g. LONG, DOUBLE, INTEGER,BYTE);
;            Added idl code 0 for UNDEFINED and 9 for double-complex.
;            July 3,1997 Added object type
;            Dec 29,1998 Added types 12,13,14
;						 April 9,2002  Changed the type name to agree with idl size output structure 'type_name'
;						 July 9, 2003 strlen(Variable) if type = 7
;					 	 July 21,2004 jor, Added NUMERIC Keyword
;-

	ROUTINE_NAME = 'IDLTYPE'

;Type   Type   	Data
;Code 	Name		Type
;0  UNDEFINED  	Undefined
;1  BYTE  			Byte
;2  INT  				Integer
;3  LONG  			Longword integer
;4  FLOAT  			Floating point
;5  DOUBLE  		Double-precision floating
;6  COMPLEX  		Complex floating
;7  STRING  		String
;8  STRUCT  		Structure
;9  DCOMPLEX  	Double-precision complex
;10 POINTER  		Pointer
;11 OBJREF  		Object reference
;12	UINT  			Unsigned Integer
;13 ULONG  			Unsigned Longword Integer
;14 LONG64  		64-bit Integer
;15 ULONG64  		Unsigned 64-bit Integer


  sz = SIZE( Variable,/STRUCT )
	IF  KEYWORD_SET(CODE) THEN RETURN, SZ.TYPE
	IF  KEYWORD_SET(NAME) THEN RETURN, SZ.TYPE_NAME

	IF KEYWORD_SET(NBYTES) THEN BEGIN
 	CASE SZ.type OF
  	0:  NBYTES = 0
  	1:  NBYTES = 1
  	2:  NBYTES = 2
  	3:  NBYTES = 4
  	4:  NBYTES = 4
  	5:  NBYTES = 8
  	6:  NBYTES = 8
  	7:  NBYTES = STRLEN(Variable)
  	8:  NBYTES = 0
  	9:  NBYTES = 16
  	10: NBYTES = 0
  	11: NBYTES = 0
  	12: NBYTES = 2
  	13: NBYTES = 4
  	14: NBYTES = 8
  	15: NBYTES = 8
  ELSE: NBYTES = ""
  ENDCASE
  RETURN, NBYTES
 ENDIF

	IF KEYWORD_SET(NUMERIC) THEN BEGIN
	 	TYPE_NUMERIC = [1,2,3,4,5,6,9, 12,13,14,15]
  	OK = WHERE(TYPE_NUMERIC EQ sz.type,Count)
  	RETURN,Count
	ENDIF

	IF KEYWORD_SET(INTEGER) THEN BEGIN
	 	TYPE_NUMERIC = [1,2,3, 				12,13,14,15]
  	OK = WHERE(TYPE_NUMERIC EQ sz.type,Count)
  	RETURN,Count
	ENDIF

 RETURN,SZ.TYPE_NAME

END; #####################  End of Routine ################################
