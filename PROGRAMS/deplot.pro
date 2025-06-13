; $Id: DEPLOT.pro,v 1.0 1996/01/28 12:00:00 J.E.O'Reilly Exp $
  PRO DEPLOT

;+
; NAME:
;       DEPLOT
;
; PURPOSE:
;       Program establishes default values for Plot Environment
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       DEPLOT
;
; INPUTS:
;       IDL Vector font # but None Required
;		Allowed range of selected fonts 3-20 and -1
;
; KEYWORDS:
;    None
;
; OUTPUTS:
;    NONE:
;
; SIDE EFFECTS:
;       Changes !P.multi to 0; default palette to pal36.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, Jan 28, 1996.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;
;-

; ====================>
  SET_PLOT,'WIN'
  IDL_SYSTEM
  SETCOLOR,255



  END
; END OF PROGRAM