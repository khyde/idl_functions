; $Id: IMAGE_SUBAREA.pro  May 29,2002
;+
;	This Program
; SYNTAX:
;	IMAGE_SUBAREA,
;	Result  = IMAGE_SUBAREA
; OUTPUT:
; ARGUMENTS:
; KEYWORDS:;
; EXAMPLE:
; CATEGORY:
; NOTES:
; HISTORY:
;		 May 29,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO IMAGE_SUBAREA,FILE, map=map, DIR_OUT=DIR_OUT
  ROUTINE_NAME='IMAGE_SUBAREA'

  IF N_ELEMENTS(MAP) NE 1 THEN MAP = 'NEC'

  IF MAP EQ 'NEC' THEN BEGIN
  	PX = 1024 & PY=1024
  ENDIF

FILE = 'H:\SEAWIFS\TS_IMAGES\TS_IMAGES_SEAWIFS_REPRO3_NARR_NEC_CHLOR_A_PSERIES_2232_LNP_MAX_PEAK_EDIT.PNG'

  IF N_ELEMENTS(FILE) NE 1 THEN FILE=DIALOG_PICKFILE()
  FN=PARSE_IT(FILE)
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FN.DIR ELSE _DIR_OUT = DIR_OUT
  PNGFILE = _DIR_OUT + FN.FIRST_NAME + '_SUBAREAS.PNG'

  IM=READALL(FILE)
  CMD = 'MAP_'+MAP
  SLIDEW,[PX,PY]
  A=EXECUTE(CMD)
  TV,IM

	X=DEFROI(1024,1024)


  STOP


END; #####################  End of Routine ################################
