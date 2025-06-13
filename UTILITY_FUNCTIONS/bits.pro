; $ID:	BITS.PRO,	2021-04-29-17,	USER-KJWH	$
  FUNCTION BITS, DAT, BIT, STRUCT=STRUCT, BIT_POSITION=BIT_POSITION, DIMENSION=DIMENSION

;+
; NAME:
;   BITS
;
; PURPOSE:
;   This function returns a binary array of zeros and ones representing the bits in the data which are on [1] or off [0].
;   The first element of the returned array is the lowest bit.  
;   If parameter BIT is provided then a 0 or 1 is returned for each element of the input DATA.
;	  If keyword /STRUCT then a structure is returned with the bit, subscripts where the bit is found and the count for that bit.
;
; REQUIRED INPUTS:
;  DATA.......... A data array of values to be converted to bits (BYTE, INTEGER, LONG, UINT, ULONG, LONG64 OR ULONG64)
;       
;							ALSO: BIT may be more than one (e.g. bit=[0,2,4]
; OPTIONAL INPUTS
;   BIT.......... Use to return the value at a specific bit number in the datum (between 0 and NTH)
;                 BIT will tell you if a particular bit is ON [1] or OFF[0] for each element of DATA
;   DIMENSION.... Used to indicate if the inputs are multiple arrays             
; 
; KEYWORD PARAMETERS:
;   STRUCT....... Returns a Structure Identifying the bit, the subscripts and count within the DATA where each bit is on  ***
;									IF BIT has values and STRUCT is set then the returned structure will only include info on the bits asked for
;		BIT_POSITION. Return a number equivalent to the bit positions (0,1,2,3 ...) being set ON (see examples)
;
; OUTPUTS:
;   Bit related outputs depending on which keywords were set (see examples)
;
; OPTIONAL OUTPUTS:
;   (See examples)
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   Presently only works on BYTE, INTEGER, LONG, UINT, ULONG, LONG64 OR ULONG64, NOT FLOAT,DOUBLE ETC.
;   
;   IDL "thinks", without any coaching, that -32786 (the smallest value an INTEGER may be) is LONG
;	    See for yourself:
;				HELP, -32768
;				HELP, FIX(-32768)
;			Consequently, this routine examines the lowest value of the input DATA and if the lowest number in DATA is -32768 then this program assumes data
;       type are INTEGER (not LONG).
;				
;
; EXAMPLES:
;		PRINT, BITS(BINDGEN(256))
;		PRINT, BITS(INDGEN(256))
;		PRINT, BITS(UINDGEN(256))
;		PRINT, BITS(LINDGEN(256))
;		PRINT, BITS(ULINDGEN(256))
;		PRINT, BITS(UL64INDGEN(256))
;		PRINT, BITS(L64INDGEN(256))
;

;		ST, BITS(BINDGEN(256),/STRUCT)
;		ST, BITS(INDGEN(256),/STRUCT)
;		ST, BITS(UINDGEN(256),/STRUCT)
;		ST, BITS(LINDGEN(256),/STRUCT)
;		ST, BITS(ULINDGEN(256),/STRUCT)
;		ST, BITS(UL64INDGEN(256),/STRUCT)
;		ST, BITS(L64INDGEN(256),/STRUCT)
;		
;		PRINT, BITS(INDGEN(2,3,4) )
;		ST, BITS(INDGEN(2,3,4),/STRUCT)
;		
;		PRINT, BITS(INDGEN(2,3,4), 2, /STRUCT)
;		PRINT, BITS(INDGEN(2,3,4), [0,2,4], /STRUCT)
;		
;   PRINT, BITS(120B)
;   PRINT, BITS(30)
;   PRINT, BITS(10L)
;   PRINT, BITS([11, 10L])
;   PRINT, BITS([11, 2UL])
;
;	  PRINT, BITS(INDGEN(256), 0) ; Returns an array of 256 elements indicating where the ZEROTH bit is on [1] or off[0]
;		PRINT, BITS(INDGEN(256), 6) ; Returns an array of 256 elements indicating where the SIXTH bit is on [1] or off[0]
;
; 	PRINT, BITS(BYTE([0,1,2,3]),0)
;
;		===> Generate a number based on the bit positions (0,1,2,3 ...) being set ON
;		RESULT = BITS([0,1,2,3],/BIT_POSITION) & PRINT,RESULT & PRINT, BITS(RESULT)
;
; COPYRIGHT:
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written September 11, 1997 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   Sep 11, 1997 - JEOR: Initial code written
;   Sep 22, 1998 - JEOR: Fixed logic in program
;   Feb 15, 1999 - JEOR: Eliminated do loop, added parameter bit
;   Mar 11, 1999 - JEOR: Added keyword BIT_POSITION
;		Oct 12, 2006 - JEOR: Added Struct keyword, streamlined routine
;		Apr 23, 2021 - KJWH: Updated documentation and formatting
;		                     Added COMPILE_OPT IDL2
;		                     Changed subscript () to []
;		                     Removed ERROR and ERR_MSG outputs
;		                     Now returning [] and printing the error message if the incorrect data type is provided
;   Apr 29, 2021 - KJWH: Fixed the bug in the BIT_POSITION block
;                          Changed TOTAL(2^DAT,DIM) to TOTAL(DAT*2^ARR,DIM)
;                          Where the ARR is an array with the same dimensions of DAT and each row is an integer based on the length on the input bit array
;-
;	*************************************************************************************************************************
	ROUTINE_NAME = 'BITS'
	COMPILE_OPT IDL2

; ===> Determine the IDL type for DATA
  TYPE 		= IDLTYPE(DAT,/CODE)
  NBYTES 	=	IDLTYPE(DAT,/NBYTES)

; ===> If not BYTE, INTEGER, LONG, UINT, ULONG, LONG64 OR ULONG64  then return -1
  IF TYPE NE 1 AND TYPE NE 2 AND TYPE NE 3 AND TYPE NE 12 AND TYPE NE 13 AND TYPE NE 14 AND TYPE NE 15 THEN BEGIN
  	PRINT, 'ERROR: Data must be BYTE, INTEGER, LONG, UINT, ULONG, LONG64 or ULONG64'
  	RETURN, []
  ENDIF

; ===> Fix the IDL LONG/INTEGER bug   
  IF TYPE EQ 3 THEN BEGIN                                           ; If the data type is LONG, check to see if it really should be INTEGER
  	MIN_DATA = MIN(DAT,MAX=MAX_DATA)                                ; Find the minimum value
  	IF MIN_DATA EQ -32768 AND MAX_DATA LE 32767 THEN BEGIN          ; If the MIN value is -32768 and the max is lt 32767, convert the LONG to INTEGER
  		TYPE = 2
  		NBYTES = 2
  	ENDIF
  ENDIF

;	===> The number of bits in an element of data
	NBITS = 8*NBYTES

;	===> Return a Structure Identifying the bit, the subscripts and count within the DATA where each bit is on
	IF KEYWORD_SET(STRUCT) THEN BEGIN
		IF N_ELEMENTS(BIT) GE 1 THEN BEGIN
			TARGET_BITS = 0 > BIT < (NBITS-1)
			S=SORT(TARGET_BITS) & TARGET_BITS=TARGET_BITS(S) & U=UNIQ(TARGET_BITS) & TARGET_BITS=TARGET_BITS(U) ; Ensure no duplicate requests
		ENDIF ELSE BEGIN
			TARGET_BITS = INDGEN(NBITS)
		ENDELSE

		TAGNAMES = 'BIT_'+ STRTRIM(TARGET_BITS,2)                       ; Construct Tagnames with an underscore prefix '_' followed by number from 0 ...

		FOR NTH = 0,N_ELEMENTS(TARGET_BITS)-1 DO BEGIN                  ; Loop through the target bits
			ANAME=TAGNAMES[NTH]
			TARGET = TARGET_BITS[NTH]
			TARGET = TARGET[0]
			BIT_IS_SET = BYTE(ABS(ISHFT(DAT, -1*(TARGET))) MOD 2)
			OK=WHERE(BIT_IS_SET EQ 1,COUNT)
			S= CREATE_STRUCT(ANAME,CREATE_STRUCT( 'SUBS',OK,'COUNT',COUNT))
			IF NTH EQ 0 THEN SS = S ELSE SS = CREATE_STRUCT(SS,S)
	  ENDFOR
  	RETURN, SS
	ENDIF

;	||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;	===> Convert the BIT_POSITION back to a value 
  IF KEYWORD_SET(BIT_POSITION) THEN BEGIN
    IF N_ELEMENTS(DIMENSION) NE 1 THEN DIM=0 ELSE DIM=DIMENSION
    DSZ = SIZEXYZ(DAT,PX=DX,PY=DY,PZ=DZ)
    ARR = DAT & ARR[*] = 0 & SZ = SIZEXYZ(ARR,PX=PX,PY=PY,PZ=PZ)
    CASE DIM OF
      0: ARR[*] = INDGEN(N_ELEMENTS(DAT))
      1: MESSAGE, 'Need to determine the correct "ARR" values to calculate the bit values'
      2: MESSAGE, 'Need to determine the correct "ARR" values to calculate the bit values'
      3: FOR R=0, DZ-1 DO ARR[0,*,R] = R
    ENDCASE
   
    CASE TYPE OF 
      1: RETURN,BYTE(TOTAL(DAT*2^ARR,DIM))  ; Old version TOTAL(2^DAT,DIM)
      2: RETURN,FIX(TOTAL(DAT*2^ARR,DIM))
      3: RETURN,LONG(TOTAL(DAT*2^ARR,DIM))
    ENDCASE  
  ENDIF

; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; ===> Determine if particular bit is set for each element of DATA 
  IF N_ELEMENTS(BIT) EQ 1 THEN BEGIN
    BIT = BIT[0]
    IF BIT GE 0 AND BIT LE NBITS THEN BEGIN
      RETURN, BYTE(ABS(ISHFT(DAT, -1*(bit))) MOD 2)
    ENDIF
  ENDIF

  ARRAY = BYTARR(NBITS,N_ELEMENTS(DAT))                                                         ; Make an INTEGER array to hold output ones and zeros
  FOR NTH=0, N_ELEMENTS(DAT)-1L DO ARRAY[*,NTH] = ABS(ISHFT(DAT[NTH], -1*INDGEN(NBITS))) MOD 2  ; Determine which bits are ON [1]

  RETURN, ARRAY

END ; end of program
