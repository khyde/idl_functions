; $Id: defont.pro,v 1.0 1995/11/09 12:00:00 J.E.O'Reilly Exp $
  PRO defont,font

;+
; NAME:
;       defont
;
; PURPOSE:
;       Program establishes default vector font
;
; CATEGORY:
;       Graphics
;
; CALLING SEQUENCE:
;       defont
;		defont, 17    Gives Triplex Roman
;
; INPUTS:
;       IDL Vector font # but None Required
;		Allowed range of selected fonts 3-20 and -1
;
; KEYWORDS:
;    None
;
; OUTPUTS:
;    The default vector font is changed.
;	 IF defont,0  then the System Font is used.
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
;
; MODIFICATION HISTORY:
;       Written by:    J.O'Reilly, April 9, 1994.
;		NOAA, NMFS, Narragansett Laboratory, 28 Tarzwell Drive, Narragansett, RI 02882-1199
;		oreilly@fish1.gso.uri.edu
;
;-

; ====================>
; If font parameter not provided then set system default font to -1
  IF N_PARAMS() EQ 0 THEN font = -1       ; Default Vector Font

  IF font EQ 0 THEN !P.FONT = 0	          ; Device Font

  IF font EQ -1 OR (font GE 3 AND font LE 20) THEN BEGIN  ; Vector Font Range is OK.
    !P.FONT = -1
    IF font EQ -1 THEN font = 3          ; Default Vector Font
    vfont = '!'+ STRTRIM(font,2)
    XYOUTS,0,0,vfont,/normal
  ENDIF

  END
; END OF PROGRAM
