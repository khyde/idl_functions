; $ID:	IMAGE_SUBAREA_LABEL.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program Takes an Image (with subarea colors) and returns same but with numbers in center of mass for each subarea
;
; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO image_subarea_label,FILE,DIR_OUT=dir_out,_EXTRA=_extra
  ROUTINE_NAME='image_subarea_label'

FILE = 'D:\IDL\IMAGES\TS_IMAGES_SEAWIFS_REPRO3_NARR_NEC_CHLOR_A_PSERIES_2232_LNP_MAX_PEAK_EDIT_SUBS.png'

  FN=PARSE_IT(FILE)

  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = FN.DIR

  PNGFILE = DIR_OUT + FN.FIRST_NAME + '_LAB.PNG'

  IMAGE=READALL(FILE,RED=R,GREEN=G,BLUE=B)
  H=HISTOGRAM(IMAGE) & OK = WHERE(H GE 1)  & U=UNIQ[OK] & OK = WHERE(U NE 0) & CODES = U[OK] & N_CODES=N_ELEMENTS(CODES)
	SETCOLOR,0
  ZWIN,IMAGE

  TV,IMAGE
	FOR N=0,N_CODES-1L DO BEGIN
		ACODE = CODES(N)
		OK = WHERE(IMAGE EQ ACODE)
		MIDDLE=MEDIAN[OK]
		ONE2TWO,MIDDLE,IMAGE,X,Y
		XYOUTS,X,Y,/DEVICE,NUM2STR(ACODE),ALIGN=0.5,CHARSIZE=1.5,COLOR=252
	ENDFOR

  COPY = TVRD()
  ZWIN
  WRITE_PNG,PNGFILE,COPY,R,G,B

END; #####################  End of Routine ################################
