; $ID:	SOLAR_CONSTANTS.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function returns Solar constants
; SYNTAX:
;	SOLAR_CONSTANTS,
;	Result  = SOLAR_CONSTANTS
; OUTPUT:
; ARGUMENTS:
; KEYWORDS:;
; EXAMPLE:
; CATEGORY:
; NOTES:
;From Bryan Franz March 6, 2003
;I got them from the data directories of the standard MODIS processing
;code.  Here's what I'm using in MSL12.  Note that I've changed the
;units.
;
;# MODIS/Terra
;# Extraterrestrial Solar Irradiance (mW/cm^2/um/sr)
;# MODIS Mean Solar Constants  12-Apr-01 from HRG.
;#
;F0[1] = 170.3675
;F0(2) = 186.5027
;F0(3) = 191.8198
;F0(4) = 188.5673
;F0(5) = 187.1590
;F0(6) = 154.1508
;F0(7) = 128.0746
;F0(8) = 97.29724
;
;# MODIS/Aqua
;# Extraterrestrial Solar Irradiance (mW/cm^2/um/sr)
;# MODIS Mean Solar Constants  12-Apr-01 from HRG.
;#
;F0[1] = 171.2286
;F0(2) = 186.6938
;F0(3) = 191.5044
;F0(4) = 188.7149
;F0(5) = 187.2373
;F0(6) = 154.5693
;F0(7) = 128.2055
;F0(8) = 97.34374

; HISTORY:
;		July 24,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO SOLAR_CONSTANTS,FILE, TIME=time
  ROUTINE_NAME='SOLAR_CONSTANTS'



END; #####################  End of Routine ################################
