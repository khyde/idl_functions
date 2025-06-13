; $Id: TS_BISQUARE.pro $  VERSION: March 26,2002
;+
;	This Function Extracts a specified TS_BISQUARE from an array within a moving window (width)

; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION SMO_BISQUARE,Arr,WIDTH=width,Percent=percent
  ROUTINE_NAME='TS_BISQUARE'

    LAST=N_ELEMENTS(Arr)-1L
    _width = WIDTH/2
    BISQ = Arr
    STOP
    FOR nth = 0L, LAST DO BEGIN
      IBEG = 0L > (nth - _WIDTH)   < LAST
      IEND = 0L > (nth + _WIDTH) 	< LAST

      SET = ARR(IBEG:IEND)
      BISQ(nth) = WEIGHT_BISQUARE(SET)

		ENDFOR
			RETURN, BISQ
    END; #####################  End of Routine ################################
