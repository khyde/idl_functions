; $ID:	PLOT_GULF_STREAM.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program Plots the Mean Position of the Gulf Stream using Data provided by P. Cornillon (URI).
; Notes (email from P.Cornillon
; 'I have attached the mean position determined from data for the period 1979-1990 (at least
;	I think that that is the period that was used). The first few years only had data for the
;	western part of the stream. From 1982-1990 the entire length was well sampled. This does
;	not affect the stats much.'
; Hope that this helps. Peter
;  We plotted a 93 month mean GS position in
; T. Lee and P. Cornillon. Propagation and growth of Gulf Stream meanders
; between 75 and 45 degrees West. {\em J.~Phys.\ Oceanogr.}, 26, 1996.

;;
; OLDER FILE:
; following is file from S. Schollaert (the Latest position from P.Cornillon is very close (nearly congruent to this)
; FILE_GULF_STREAM='D:\IDL\DATA\GSPATH.ASC' ; USED IN OUR L&O MS
;    TXT = READ_TXT(FILE_GULF_STREAM)
;    TXT = STRCOMPRESS(TXT)
;    LON = FLTARR(N_ELEMENTS(TXT))
;    LAT = FLTARR(N_ELEMENTS(TXT))
;    ALON = 0.0
;    ALAT = 0.0
;    FOR NTH=0L,N_ELEMENTS(TXT)-1L DO BEGIN
;    	READS,TXT[NTH],ALON,ALAT
;    	LON[NTH]=ALON
;    	LAT[NTH]=ALAT
;    ENDFOR
;    PLOTS,LON,LAT,COLOR=0,THICK=1,LINESTYLE=1,_EXTRA=_EXTRA
;		April 23,2002	Written by:	J.E. O'Reilly   NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO PLOT_GULF_STREAM, NORTH=north, MIDDLE=middle, SOUTH=south,_EXTRA=_EXTRA
  ROUTINE_NAME='PLOT_GULF_STREAM'
  FILE_NORTH_GULF_STREAM = 'D:\IDL\bathy\dim\GULF_STREAM_12yrmean.dim'
  PLOTDEG,FILE=FILE_NORTH_GULF_STREAM,_EXTRA=_extra


END; #####################  End of Routine ################################
