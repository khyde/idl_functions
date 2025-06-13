; $ID:	CONTOUR_DEMO.PRO,	2016-01-05,	USER-JOR	$
; 
PRO CONTOUR_DEMO
; #########################################################################; 
;+
; PURPOSE:  THIS PROGRAM  IS A DEMO FOR IDL'S CONTOUR FUNCTION

;
; CATEGORY: CONTOUR;
;
; CALLING SEQUENCE: 
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE

; OUTPUTS:  DISPLAY
;
;; EXAMPLES: COPIED FROM IDL'S HELP
;
; MODIFICATION HISTORY:
;     JAN 05, 2016  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;*********************************
ROUTINE_NAME  = 'CONTOUR_DEMO'
;*********************************

; RESTORE WIND DATA. VARIABLES: U, V, X, Y.

FILE = FILE_WHICH('GLOBALWINDS.DAT')

RESTORE, FILE, /VERBOSE



; CALCULATE WIND SPEED FROM THE COMPONENT VECTORS.

S = SQRT(U^2 + V^2)



; THE WIND SPEEDS ARE GIVEN IN MILES PER HOUR. CONVERT THEM TO METERS PER

; SECOND WITH IDLUNIT.

CONVERSION = IDLUNIT('1 MILE / HOUR') / IDLUNIT('METER / SECOND')

S *= CONVERSION.QUANTITY



; SET UP A MAP PROJECTION. DISPLAY CONTOURS OF WIND SPEED AND A COLORBAR.

M = MAP('ROBINSON')

CT = COLORTABLE(72, /REVERSE)

C = CONTOUR(S, X, Y, $

  /FILL, $

  OVERPLOT=M, $

  GRID_UNITS='DEGREES', $

  RGB_TABLE=CT, $

  TITLE='GLOBAL SURFACE WIND SPEEDS')

MC = MAPCONTINENTS()

CB = COLORBAR(TITLE='SPEED ($M S^{-1}$)')
WAIT,11
M.CLOSE

END; #####################  END OF ROUTINE ################################
