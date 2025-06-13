; $Id:	RULER.PRO.PRO,	2003 Dec 02 15:41	$

 PRO RULER, START, WIDTH=WIDTH
;+
; NAME:
; 	RULER

;		This Program Prints a 'RULER' of '01234567890123456789 ...' for alignment of text

; 	MODIFICATION HISTORY:
;			Written Dec 27, 2005 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='RULER'

	IF N_ELEMENTS(START) EQ 0 THEN _START = 0 ELSE _START = START

	IF N_ELEMENTS(WIDTH) EQ 0 THEN _WIDTH =80 ELSE _WIDTH = WIDTH


	PRINT, STRJOIN(STRTRIM( ( (INDGEN(_WIDTH)+_START) MOD 10) ,2))

END; #####################  End of Routine ################################



