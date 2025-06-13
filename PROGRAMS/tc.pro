; $Id:	TC.PRO,	2003 Dec 02 15:41	$

 FUNCTION TC, COLORS
;+
; NAME:
;       TC
;
; PURPOSE:
;				Generate a True Color index from the current palette and input color_indices
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 2, 2005
;-

ROUTINE_NAME='TC'
	IF N_ELEMENTS(COLORS) EQ 0 THEN _COLORS = !P.COLOR ELSE _COLORS = COLORS

	_COLORS = 0  > _COLORS < 255

;	===> Get the current colors
	TVLCT,RED,GREEN,BLUE,/GET
	IF !D.N_COLORS EQ 16777216 THEN BEGIN
		RETURN, RED(_COLORS)+256L*(GREEN(_COLORS)+256L*BLUE(_COLORS))
	ENDIF ELSE RETURN,_COLORS


END; #####################  End of Routine ################################



