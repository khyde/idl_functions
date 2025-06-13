; $ID:	PLOT_NORTH_GULF_STREAM.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function returns supplied data that belong to the MARMAP cruise series
; SYNTAX:
;	PLOT_NORTH_GULF_STREAM,
;	Result  = PLOT_NORTH_GULF_STREAM
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

PRO PLOT_NORTH_GULF_STREAM,_EXTRA=_EXTRA
  ROUTINE_NAME='PLOT_NORTH_GULF_STREAM'
  PATH = 'D:\'
  FILE_GULF_STREAM=PATH+'IDL\DATA\GSPATH.ASC'




    TXT = READ_TXT(FILE_GULF_STREAM)
    TXT = STRCOMPRESS(TXT)
    LON = FLTARR(N_ELEMENTS(TXT))
    LAT = FLTARR(N_ELEMENTS(TXT))
    ALON = 0.0
    ALAT = 0.0
    FOR NTH=0L,N_ELEMENTS(TXT)-1L DO BEGIN
    	READS,TXT[NTH],ALON,ALAT
    	LON[NTH]=ALON
    	LAT[NTH]=ALAT
    ENDFOR

    PLOTS,LON,LAT,COLOR=0,THICK=1,LINESTYLE=1,_EXTRA=_EXTRA


END; #####################  End of Routine ################################
