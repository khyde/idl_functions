; $ID:	SPREAD.PRO,	SEPTEMBER 21 2005, 07:01	$

  PRO SPREAD,VAR,NAMES, _EXTRA=_extra
;+
; NAME:
;       SPREAD
;
; PURPOSE:
;       Run the IDL probram XVAREDIT
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;      SPREAD,a
;
; INPUTS:
;      A VARIABLE
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 26,2000
;-




	sz_VAR = SIZE(VAR,/STRUCT)
	IF sz_VAR.N_ELEMENTS LT 1 THEN GOTO, DONE

;	===> Following facillitates showing some tags from a structure
	sz_names = SIZE(Names,/STRUCT)
 	IF sz_VAR.type EQ 8 AND sz_names.n_elements GE 1 AND sz_names.type EQ 7 THEN BEGIN
    XVAREDIT,STRUCT_COPY(VAR,NAMES),X_SCROLL_SIZE=200,Y_SCROLL_SIZE=80, _EXTRA=_extra
  ENDIF ELSE BEGIN
		XVAREDIT,VAR,X_SCROLL_SIZE=200,Y_SCROLL_SIZE=80, _EXTRA=_extra
	ENDELSE


DONE:

END; OF PROGRAM
