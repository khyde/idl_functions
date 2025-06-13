; $ID:	MISSINGS.PRO,	2020-07-09-08,	USER-KJWH	$

FUNCTION MISSINGS, DAT

;+
;	
; NAME:
;   MISSINGS
; 
; 
; PURPOSE:
;   This FUNCTION Returns an Operationally-Defined Missing Data Value/Code Appropriate for each IDL Data Type
;
;
; CALLING SEQUENCE
;		Result = MISSINGS(DAT)
;		
;	INTPUT(S):
;	  DAT..... A scalar value or an array (any IDL type)
;	  
;	  
;	OPTIONAL INPUT(S):
;	  None	
;	  	
; OUTPUT(S):
;		A Consistent IDL 'Missing' value of the same IDL TYPE as the input DAT
;
;		
; OPTIONAL OUTPUT(S):	
;   None	
;   
;   
; EXAMPLES:
;		HELP,MISSINGS(12b) 
;		HELP,MISSINGS[1]   
;		HELP,MISSINGS(3L)  
;		HELP,MISSINGS(3.2) 
;		HELP,MISSINGS(3.2d)
;		HELP,MISSINGS(3UL) 
;		HELP,MISSINGS(3ULL)
; 	HELP,MISSINGS(INTARR(10))
;
; PROGRAM NOTES:
;		In practice, data are imported into IDL, then MISSINGS.PRO is used to assign this set of
;		STANDARDIZED Missing Data codes to data the user defines as missing or bad.
;		During all subsequent data processing, missing data are found by calling MISSINGS.PRO
;   In the following example -9 is assigned the IDL Missing code.	
;		Try this:
;		  A = [1,2,3,-9,5,7] 
;		  BAD = WHERE(A EQ -9,COUNT) & IF COUNT GE 1 THEN A(BAD) = MISSINGS(A) & PRINT, A
;		  OK = WHERE(A NE MISSINGS(A),COUNT) & IF COUNT GE 1 THEN AVG = MEAN(A[OK]) & PRINT, AVG
;
;		Since Structures may have many different IDL data types there is no missing code for structures
;		but each tag in a structure may have a missing code:
;   	STRUCT = CREATE_STRUCT('aa','test','BB',0.0)
;			HELP,MISSINGS(Struct) 
;   	HELP,MISSINGS(Struct.(0)) 
;   	HELP,MISSINGS(Struct.(1)) 
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
;
; RESTRICTIONS:
;   Does not work for complex types, pointers, objects
;
;		
; NOTES:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.
;   For questions about the code, contact kimberly.hyde@noaa.gov
;
;
; MODIFICATION HISTORY:
;     Written:  Jan 14, 1996 by J.E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882
;     Modified: Jan 02, 2001 - JEOR: Added UINT,ULONG,LONG64,ULONG64 types
;               Aug 01, 2018 - KJWH: Updated the documentation and formatting
;                                    Changed the DATA keyword to DAT to avoid conflicts with IDL's DATA                                      
;                                    		
;-
; *************************************************************************

  ROUTINE_NAME='MISSINGS'

; =====> Determine dimensions and IDL data type
  SZ = SIZE(DAT,/STRUCT)

; =====> Make an array structure to hold the idl missing codes
  IDLMISSING={ $
       		UNDEFINED:'Undefined',$
          BYTE:0b,$
          INT:2^15 - 1,$
          LONG:2L^31 -1,$
          FLOAT: !VALUES.F_INFINITY,$
          DOUBLE: !VALUES.D_INFINITY,$
          COMPLEX_FLOATING:COMPLEX(!VALUES.F_INFINITY) ,$
          STRING:'',$
          STRUCT:'No missing code for structures',$
          DOUBLE_COMPLEX:COMPLEX(!VALUES.D_INFINITY) ,$
          POINT: 'No missing code for pointers',$
          OBJ: 'No missing code for objects',$
          UINT: 2U^16   - 1,$
          ULONG:2UL^32  - 1,$
          LONG64:2LL^63  - 1,$
          ULONG64:2ULL^64 - 1 }

; =====> Return the missing value for the idl data type
  RETURN, IDLMISSING.(SZ.TYPE)

END; #####################  End of Routine ################################
