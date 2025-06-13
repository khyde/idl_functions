; $Id: stats_variance.pro $  VERSION: March 26,2002
;+
;	This Function returns supplied data that belong to the MARMAP cruise series
; SYNTAX:
;	stats_variance,
;	Result  = stats_variance
; OUTPUT:
; ARGUMENTS:
; KEYWORDS:;
; EXAMPLE:
; CATEGORY:
; NOTES:
; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO stats_variance,FILE
  ROUTINE_NAME='stats_variance'
	vaR = (sum of the squares)/n + (square of the sums)/n*n

END; #####################  End of Routine ################################
