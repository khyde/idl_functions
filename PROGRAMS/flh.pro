; $ID:	FLH.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Program Computes Fluorescent Line Height (After Abbot and Letellier)
; SYNTAX:
;
;	Result = FLH(Wl,Data)
; OUTPUT:
; ARGUMENTS:
; 	Wl:  Wavelengths (nm)
; 	Data:  Measurements at same wavelengths
; KEYWORDS:
;
; EXAMPLE:
; CATEGORY:
;		Optics
; NOTES:
; 		Program assumes wl and data are arranged by increasing wavelength
;			Calculation Follows:
;					M.R. Abbott and R.M. Letelier, 2001.
;					Algorithm Theoretical Basis Document Chlorophyll Fluorescence (MODIS Product Number 21)
;   			page8-9
; VERSION:
;		August 16, 2001
; HISTORY:
;		August 16, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION FLH, WL,DATA
  ROUTINE_NAME='FLH'
; ====================>
; Must provide LW, AND DATA
  IF N_PARAMS() LT 2 THEN STOP
  N_WL = N_ELEMENTS(WL)
  IF N_WL NE 3 THEN STOP

; ===================>
; Number of rows in DATA must equal number of elements in WL
  ARRAY=DATA
  S=SIZE(ARRAY)
  IF S[0] EQ 2 THEN BEGIN
    N_BANDS = S[1]
    N_ROWS  = S(2)
  ENDIF
  IF S[0] EQ 1 THEN BEGIN
    N_BANDS = S[1]
    N_ROWS  = 1
  ENDIF

  IF N_BANDS NE N_WL THEN STOP
  Lc = data(1,*)
  x= wl[1]-wl[0]
  y= wl(2)-wl[1]

  RETURN,DATA(1,*) - ( data(2,*)+ ((data(0,*)-data(2,*))*y/(x+y)))



END; #####################  End of Routine ################################
