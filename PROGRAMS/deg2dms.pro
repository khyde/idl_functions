; $Id: deg2dms.pro, v 1.0 1996/01/14 12:00:00 J.E.O'Reilly Exp $
;
  FUNCTION DEG2DMS, DEG, MINUTES=minutes
;+
; NAME:
;       deg2dms
;
; PURPOSE:
;       Converts lat or long coordinates from decimal degrees
;       into DEGREES,MINUTES,SECONDS,decimal seconds
;       or   DEGREES,MINUTES,decimal minutes 
;
; CATEGORY:
;      	Maps
;
; CALLING SEQUENCE:
;         result = deg2dms(deg)
;
;
; INPUTS:
;
;        latitude or longitude coordinates
;        (units of decimal degrees)
;
;
; KEYWORD PARAMETERS:
;
;
;       MINUTES :  Output will be DDMM.  instead of the DEFAULT DDMMSS.
;
; OUTPUTS:
;
;         Units of DEGREES,MINUTES OR DEGREES,MINUTES,SECONDS
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 14,1996
;		           NOAA, NMFS, Narragansett Laboratory,
;                    28 Tarzwell Drive,
;                    Narragansett, RI 02882-1199
;                    oreilly@fish1.gso.uri.edu
;        March 18,1996, Changed to a function
;
;-

; ====================>
;  Convert latitude or longitude decimal degrees to units of DDMM. or DDMMSS.

  dd = LONG(DEG)              ; Degrees
  dfra = DEG-DD               ; Degree fraction
  mm = LONG(DFRA*60D)         ; Minutes
  ss = (dfra*3600d)-(mm*60d)  ; Seconds
  IF KEYWORD_SET(MINUTES) EQ 0 THEN BEGIN
    dms= DOUBLE(DD*10000L + LONG(dfra)*100L + ss)
  ENDIF ELSE BEGIN
    dms= DOUBLE(DD*100L   + dfra*60d)
  ENDELSE

  RETURN, dms
  END ; END of Program









