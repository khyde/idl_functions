; $Id: IINDGEN.pro, May 6,1999 J.E.O'Reilly

function IINDGEN
;+
; NAME:
;       IINDGEN
;
; PURPOSE:
;       Returns an Integer array with values ranging
;       from -32768 to 32767
;
; CATEGORY:
;       Array
;
; CALLING SEQUENCE:
;       Result = IINDGEN()
;
; INPUTS:
;       none
;
; KEYWORD PARAMETERS:
;       none
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
;       Written by:  J.E.O'Reilly, May 6,1999
;-


 RETURN, FIX(LINDGEN(2L^16) - 32768L) ;;

 END ; END OF PROGRAM
