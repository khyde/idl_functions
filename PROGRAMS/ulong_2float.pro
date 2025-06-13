; $Id: ULONG_2FLOAT.pro $
;+
;	This Function Converts Coded Unsigned LONG (32bit) into FLOAT data
; The assumption is that the most significant bit is the sign.
;
; SYNTAX:
;	Result = ULONG_2FLOAT(Data,Pos)
; OUTPUT:
;		FLOAT
; ARGUMENTS:
; 	Data:	Input
;		Pos:	Position of the implied decimal point.
;					e.g. pos of 24 means the 24 least significant bits form the decimal fraction
;							 and the next 7 significant bits form the decimal whole
;              and the most significan bit represents the sign (neg,pos).
; KEYWORDS:
; EXAMPLE:
; CATEGORY:
;		CONVERT
; NOTES:
; VERSION:
;		Apr 13, 2001
; HISTORY:
;		Apr 13, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO ULONG_2FLOAT,DATA,POS
  ROUTINE_NAME='ULONG_2FLOAT'


 SLOPE=[753091UL,526410UL,442351UL,192716UL,1594165UL,0UL]
 INT=[305702UL,675615UL,399888UL,116299UL,4293655261UL]

; THIS ALSO SEEMS TO WORK (FOR POS = 24) BUT CHECK IT FOR ALL NUMBERS
; PRINT, 1.0*( 1L* SLOPE)/2L^24
; PRINT, 1.0*( 1L* INT)/2L^24

DATA = [SLOPE,INT]
DATA = INT(4)

DATA =  134217728L

LEN = 32
POS = 24
POS = 22

SIGN_MASK = (2UL^(LEN-1))
FRA_MASK	= (2UL^POS)-1UL
WHOLE_MASK = (SIGN_MASK - FRA_MASK)-1UL

DATA_FRA  	= DATA AND FRA_MASK
DATA_WHOLE  = DATA AND WHOLE_MASK
DATA_SIGN   = 1.0*(1-2*((DATA AND SIGN_MASK) EQ SIGN_MASK))


WHOLE= 1.0*DATA_WHOLE/2L^31
FRA  = 1.0* DATA_FRA/2L^POS
FDATA = FRA + WHOLE*DATA_SIGN

PRINT, FDATA

STOP
PRINT,'DATA' & PRINT, BITS(DATA)
PRINT,'FRA_MASK' & PRINT, BITS(FRA_MASK)
PRINT,'WHOLE_MASK' & PRINT, BITS(WHOLE_MASK)
PRINT,'SIGN_MASK' & PRINT, BITS(SIGN_MASK)

PRINT,'DATA&FRA_MASK' & PRINT, BITS(DATA AND FRA_MASK)
PRINT,'DATA&WHOLE_MASK' & PRINT, BITS(DATA AND WHOLE_MASK)
PRINT,'DATA&SIGN_MASK' & PRINT, BITS(DATA AND SIGN_MASK)

PRINT,'DEC_FRA' & PRINT, 1.0*(DATA AND FRA_MASK)/2UL^24

DEC_FRA = 1.0*DATA_FRA/2UL^24
DATA_WHOLE =1.0*DATA_WHOLE/2L^8
;DEC_FRA = 1.0*DATA_FRA/(FRA_MASK-1)
;PRINT,DEC_FRA

;PRINT, BITS(DATA AND SIGN_MASK)
STOP
SIGN_VAL = 2UL^(LEN-1)

PRINT, BITS(DATA) & PRINT & PRINT, BITS(SIGN_VAL) & PRINT, BITS(FRA_VAL)
PRINT
PRINT, BITS(DATA AND SIGN_VAL)
PRINT, BITS(DATA AND FRA_VAL)
STOP
BIT_EXP = LEN-1

PRINT, BITS(INT) & PRINT &PRINT,  BITS(INT AND IO) & PRINT & PRINT, BITS(INT AND 2L^31)

NEG = 1UL*(( INT AND IH) NE 0)

PRINT, 1.0*(NEG*INT)^INT/24
STOP

NUM=753091L & PRINT
NUM= 4293655251UL



END; #####################  End of Routine ################################