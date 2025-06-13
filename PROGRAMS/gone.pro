; $Id:	gone.pro,	April 17 2006, 10:28	$

FUNCTION MEMORY_GONE, V
	RETURN,TEMPORARY( V )
END

 PRO GONE, V
;+
; NAME:
; 	GONE

;		This Program Removes a variable from Memory

;	EXAMPLE:
;			A=FINDGEN(1000) & HELP, A & GONE,A & HELP,A
;
;		NOTES:
;			Can not yet delete assoc files from memory

; 	MODIFICATION HISTORY:
;			After program/concept by Dave Chevrier, NOAA, NMFS, Woods Hole, MA
;			Written March 13, 2006 by J.O'Reilly
;-

	ROUTINE_NAME='GONE'

;	===> Check If the variable V is an associated file
	SZ=SIZE(V,/STRUCT)

	IF SZ.N_ELEMENTS GE 1 AND SZ.FILE_LUN EQ 0 THEN BEGIN
		M=MEMORY_GONE(TEMPORARY(V))
	ENDIF

END; #####################  End of Routine ################################



