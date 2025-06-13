; $Id:	missings.pro,	September 11 2006, 08:27	$
;+
;	This FUNCTION Returns an Operationally-Defined Missing Data Value/Code Appropriate for each IDL Data Type
;
; SYNTAX:;
;		Result = MISSINGS(Data);
; OUTPUT:
;		A Consistent IDL 'Missing' value of the same IDL TYPE as Input
; ARGUMENTS:
; 	Data:	A scalar value or an array (any IDL TYPE)
; EXAMPLES:
;		Result = MISSINGS(12b) & HELP, Result
;		Result = MISSINGS(1)   & HELP, Result
;		Result = MISSINGS(3L)  & HELP, Result
;		Result = MISSINGS(3.2) & HELP, Result
;		Result = MISSINGS(3.2d)& HELP, Result
;		Result = MISSINGS(3UL) & HELP, Result
;		Result = MISSINGS(3ULL)& HELP, Result
;
; 	Result = MISSINGS(INTARR(10))& HELP, Result
;
; NOTES:
;		In practice, data are imported into IDL, then MISSINGS.PRO is used to assign this set of
;		STANDARDIZED Missing Data codes to data the user defines as missing or bad.
;		During all subsequent data processing, missing data are found by calling MISSINGS.PRO
;   In the following example -9 is assigned the IDL Missing code.
;		Try this:
;		a = [1,2,3, -9, 5,7] & bad = WHERE(A EQ -9,count)& IF count GE 1 THEN A(bad) = MISSINGS(A) & PRINT, A
;		OK = WHERE(A NE MISSINGS(A),COUNT) & IF count GE 1 THEN AVG = MEAN(A(OK)) & PRINT, AVG
;
;		Since Structures may have many different IDL data types there is no missing code for structures
;		but each tag in a structure may have a missing code:
;   	Struct = CREATE_STRUCT('aa','test','BB',0.0)
;			Result = MISSINGS(Struct) & HELP, Result
;   	Result = MISSINGS(Struct.(0)) & HELP, Result
;   	Result = MISSINGS(Struct.(1)) & HELP, Result
;
;	PROBLEMS:
; Not working for Complex Types, Pointers, Objects
;
; _____________________________________________________________________
;       M I S S I N G   D A T A   C O D E S
; IDL   IDL                 OPERATIONAL           EXPLANATION
; CODE  TYPE                MISSING CODE
;
; 0     Undefined           Ignored
; 1     Byte                0b
; 2     INT                 32767                 Largest: 2^15 - 1
; 3     LONG                2147483647L           Largest: 2L^31 -1
; 4     FLOAT               !VALUES.F_INFINITY    Infinity (not finite)
; 5     DOUBLE              !VALUES.D_INFINITY    Infinity (not finite)
; 6     Complex Floating    !VALUES.F_INFINITY		Infinity (not finite)
; 7     STRING              ''                    Empty String
; 8     STRUCT              Ignored
; 9     Double_complex      !VALUES.D_INFINITY  	Infinity (not finite)
; 10    Pointer             Ignored
; 11    Object              Ignored
; 12    UINT                65535                 Largest: 2U^16   - 1
; 13    ULONG               4294967295            Largest: 2UL^32  - 1
; 14    LONG64              9223372036854775807   Largest: 2LL^63  - 1
; 15    ULONG64             18446744073709551615  Largest: 2ULL^64 - 1
;
; VERSION:
;		Jan 22,2001
; HISTORY:
;		Jan 14,1996	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Jan 02,2001	Added  UINT,ULONG,LONG64,ULONG64 TYPES
;-
; *************************************************************************
FUNCTION MISSINGS, Data
  ROUTINE_NAME='MISSINGS'

; =====> Determine dimensions and IDL data type
  sz = SIZE( data,/STRUCT )

; =====> Make an array structure to hold the idl missing codes
  idlmissing={ $
       		Undefined:'Undefined',$
          Byte:0b,$
          INT:2^15 - 1,$
          LONG:2L^31 -1,$
          FLOAT: !VALUES.F_INFINITY,$
          DOUBLE: !VALUES.D_INFINITY,$
          COMPLEX_FLOATING:COMPLEX(!VALUES.F_INFINITY) ,$
          STRING:'',$
          STRUCT:'no missing code for structures',$
          DOUBLE_COMPLEX:COMPLEX(!VALUES.D_INFINITY) ,$
          POINT: 'no missing code for pointers',$
          OBJ: 'no missing code for objects',$
          UINT: 2U^16   - 1,$
          ULONG:2UL^32  - 1,$
          LONG64:2LL^63  - 1,$
          ULONG64:2ULL^64 - 1 }

; =====> Return the missing value for the idl data type
RETURN, idlmissing.(sz.type)

END; #####################  End of Routine ################################
