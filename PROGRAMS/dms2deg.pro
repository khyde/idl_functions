; $Id: dms2deg.pro, v 1.0 1996/01/14 12:00:00 J.E.O'Reilly Exp $
;
  FUNCTION DMS2DEG, DMS
;+
; NAME:
;       dms2deg
;
; PURPOSE:
;       Function Converts lat, long coordinates
;       from degrees,minutes,seconds into decimal degrees
;
; CATEGORY:
;      	Maps
;
; CALLING SEQUENCE:
;         call function twice, to convert a lat,lon coordinate pair
;         result=dms2deg(lat)
;         result=dms2deg(lon)
;
; INPUTS:
;        latitude or longitude coordinates
;        (units of DDMMSS or DDMM.hh)
;
; KEYWORD PARAMETERS:
;      	NONE
; OUTPUTS:
;
;         (units of Decimal Degrees)
;
; SIDE EFFECTS:
;        None.
;
; RESTRICTIONS:
;       Only works if  input lat, lon  data are ddmm.   or ddmmss. 
;       
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 14,1996
;	                NOAA, NMFS, Narragansett Laboratory,
;                          28 Tarzwell Drive,
;                          Narragansett, RI 02882-1199
;                          oreilly@fish1.gso.uri.edu
;       March 18,1996, Changed to a function
;                      Input only one parameter
;-

; =====================>
; Convert to double precision
  dms = DOUBLE(TEMPORARY(dms))

; ====================>
; Determine biggest value (number of integer digits)

  biggest = ABS(MAX(dms)) > ABS(MIN(dms))

 
; ====================>
; If data are already in units of degrees then return dms
  IF biggest LE 180 THEN RETURN, dms  ; NO CONVERSION

; ====================>
; Input lat,lon in units of DDMMSS
  IF biggest GT 9999.0d AND biggest LE 999999.0d THEN  BEGIN  ; ddmmss
    DD =  DOUBLE(LONG(dms/10000.0d))
    MM =  DOUBLE(LONG( (dms - (DD*10000.0d))/100.  ))
    SS =  DOUBLE(LONG( (dms - (DD*10000.0d) - MM*100.) ))
    deg = DOUBLE(dd  + mm/60.d + ss/3600.d)
   RETURN, deg
 ENDIF

; ====================>
; Input lat,lon in units of DDMM.hh
  IF  biggest GT 99.0d AND biggest LE 9999.0d THEN BEGIN      ; ddmm
    DD = DOUBLE(LONG(dms/100.0d))
    MM =  (DOUBLE(dms - DD*100.0d))/60.0d
    deg  = DOUBLE(DD + MM)
    RETURN,deg
  ENDIF


  END ; END of Program






