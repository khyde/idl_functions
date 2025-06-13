; $Id:	READ_DELIMITED_DEMO.PRO,	2003 Dec 02 15:41	$

 PRO READ_DELIMITED_DEMO, COLORS
;+
; NAME:
; 	READ_DELIMITED_DEMO

;		This Function/Program ...
;
; SYNTAX:
;		Result = STRUCT_JOIN(Struct1, Struct2)
;
; OUTPUT:
;
;
; ARGUMENTS:
;
;
; KEYWORDS:
;
;		TAGNAMES: The tagname(s) to use to join the Structures (REQUIRED INPUT)
;
;
; EXAMPLE:
;
;
;	NOTES:
;
; MODIFICATION HISTORY:
;		Written Dec 17, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

ROUTINE_NAME='READ_DELIMITED_DEMO'
N = 16
STRUCT=REPLICATE(CREATE_STRUCT('A',0L,'B',0L),N)
STRUCT.A = INDGEN(N)+1
STRUCT.B = INDGEN(N)+1
FILE = ROUTINE_NAME+'.CSV'
STRUCT_2CSV,FILE,STRUCT

PRINT, 'NORMAL: File has tagnames in the first column'
D=READ_DELIMITED(FILE,DELIM=',') &SPREAD,D
PRINT

PRINT, 'With the keyword set /NOHEAD program assumes the file has no tagnames '
PRINT, 'So it makes them up and mistakes the tagnames in the file for data'
D=READ_DELIMITED('JUNK.CSV',DELIM=',',/NOHEAD) & SPREAD,D
PRINT

PRINT, 'Skip the tagnames in the file and make up tagnames'
D=READ_DELIMITED('JUNK.CSV',DELIM=',',/NOHEAD,SKIP=1) & SPREAD,D
PRINT


END; #####################  End of Routine ################################



