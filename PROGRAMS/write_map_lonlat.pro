; $Id: WRITE_MAP_LONLAT Jan 31, 2003
;+
;	This Program Writes two files: one with all longitudes and one with all latitudes for a map

;		Jan 31, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO WRITE_MAP_LONLAT, MAP=map
  ROUTINE_NAME='WRITE_MAP_LONLAT'
  IF N_ELEMENTS(MAP) EQ 0 THEN MAP = 'NEC'

  IF MAP EQ 'NEC' THEN BEGIN
  	PX = 1024 & PY = 1024
  ENDIF
  ZWIN,[PX,PY]


; ================>
;	Establish the NEC Map Projection
	MAP_TXT = 'MAP_'+MAP
  A=EXECUTE(MAP_TXT)
  XX = FINDGEN(PX)
  YY = FINDGEN(PY)

;	===============> ADD .5 PIXELS FOR CENTER OF PIXEL
  XX = XX + 0.5
  YY = YY + 0.5

  x = (XX  ) # REPLICATE(1.,N_ELEMENTS(YY))
  y = REPLICATE(1.,N_ELEMENTS(XX)) #  (YY)


  xyz = convert_coord(x,Y, /DEVICE, /TO_DATA)
  PXX = REFORM(XYZ(0,*,*))
  PYY = REFORM(XYZ(1,*,*))

	ZWIN


  FILE = MAP_TXT + '_LONS.TXT'
  OPENW,LUN,FILE,/GET_LUN
  FOR N=0L,N_ELEMENTS(PXX)-1L DO BEGIN
  	PRINTF,LUN,PXX(N),FORMAT='(F11.6)'
  ENDFOR
  FREE_LUN,LUN
  CLOSE,LUN
	FILE = MAP_TXT + '_LATS.TXT'
 	OPENW,LUN,FILE,/GET_LUN
  FOR N=0L,N_ELEMENTS(PYY)-1L DO BEGIN
  	PRINTF,LUN,PYY(N),FORMAT='(F11.6)'
  ENDFOR
  FREE_LUN,LUN
  CLOSE,LUN

END; #####################  End of Routine ################################
