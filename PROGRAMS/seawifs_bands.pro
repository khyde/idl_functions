; $Id: SEAWIFS_BANDS.pro $
;+
;	This Function Returns the SeaWiFS BandS
; SYNTAX:
;	Result = SEAWIFS_BANDS()
; OUTPUT:
; ARGUMENTS:

; KEYWORDS:

; EXAMPLE:
; CATEGORY:
;	SEAWIFS
; NOTES:
; VERSION:
;	Apr 9,2001
; HISTORY:
;	Jan 10,1999	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SEAWIFS_BANDS
  ROUTINE_NAME='SEAWIFS_BANDS'

  IF N_ELEMENTS(BANDS) EQ 0 THEN BANDS = INDGEN(8)

   BAND_NAMES=[$
   412,$
   443,$
   490,$
   510,$
   555,$
   670,$
   765,$
   865]
    RETURN,BAND_NAMES(BANDS)


   END; #####################  End of Routine ################################
