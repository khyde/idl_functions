; $ID:	LME_MASK_SUBAREA_MAKE.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Program Generates a SUBAREA MASK FOR THE LMES
;	The Resulting image is 2d and has color values representing the LME codes (1-64)

; HISTORY:
;		Feb 6, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Sep 11, 2003 after LME_L3B_BIN_2LME.PRO
;-
; *************************************************************************

PRO LME_MASK_SUBAREA_MAKE, DEMO=demo
  ROUTINE_NAME='LME_MASK_SUBAREA_MAKE'

; Get LME Mask showing LME areas as codes from 1 to 64
  DIR_IMAGES='D:\IDL\IMAGES\'
  dir_mask = 'd:\idl\LME\' ; NOTE
  file_mask = dir_mask + 'MASK_SUBAREA-GEQ-PXY_17280_8640-LME.png'
  file_mask = dir_mask + 'LME_MASK_17280_8640.png'
  FILE_CSV = DIR_mask+'LME_NAMES.CSV'
  MASK  = READALL(file_mask)

;'Notes on input png image used to make the mask'
; THERE IS A COLOR BAR ATOP ANTARTIC
; COLOR 0 	= LINES OUTLINING INTERIOR LAKES ETC'
; COLOR 254	= GREY LANDMASS'
; COLOR 255 = YELLOW WATER'
; COLORS  1:64 LME CODES'

stop

  SAVEFILE= DIR_IMAGES +'MASK_SUBAREA-L3B-PXY_1_5940423-LME.SAVE'

	DATA_TYPE = 'BYTE'
	PROD='SUBAREA'

;	===> Get the bins and equivalent lon, lats
  SD_L3BDAY_LONLAT,BINS,LON,LAT
  ZWIN,MASK
  MAP_GLOBAL_EQUIDISTANT
;	===> Determine for each lon,lat the x,y pixel map coordinate and D, the color code from the input mask
  DATA=MAP_DEG2IMAGE(MASK,LON,LAT,  X=x, Y=y,AROUND=0)
  ZWIN


; ==> COLOR BAR IS AT BOTTOM 100 PIXELS (ANTARTIC AREA) SO CHANGE LME TO LAND (254):
  OK = WHERE(Y LE 100,COUNT)
  IF COUNT GE 1 THEN DATA[OK] = 254; LAND; ANTARTICA


; ===> LAND IS 254 AND LAND OUTLINE IS 0, CHANGE BOTH TO 0
  OK = WHERE(DATA EQ 254,COUNT)
  IF COUNT GE 1 THEN DATA[OK] = 0; LAND; ANTARTICA


;	===> Make data byte, TO economize since max value is 64
	DATA = BYTE(DATA)

;	===> REFORM SO IT IS 2-D
 	DATA = REFORM(DATA,1,N_ELEMENTS(DATA))

; *********************************
  IF KEYWORD_SET(DEMO) THEN BEGIN
    SZ=SIZE(MASK,/STRUCT)
  	PX = SZ.DIMENSIONS[0] & PY = SZ.DIMENSIONS[1]
  	_PX = PX /16
  	_PY = PY / 16
  	PAL_SW3,R,G,B
  	SLIDEW,[_PX,_PY]
  	FOR LME = 1,64 DO BEGIN
			MAP_GLOBAL_EQUIDISTANT
    	ERASE,253
    	OK = WHERE(D EQ LME,COUNT)
    	IF COUNT GE 1 THEN BEGIN
      	PRINT, LME
      	PLOTS,LON[OK],LAT[OK], PSYM=1,COLOR= 0
      	STOP
    	ENDIF
  	ENDFOR
  ENDIF


; ===> SETUP THE ANCILLARY STRUCTURE INFO
; MISSING CODES WILL BE THE CODE FOR LAND AND WATER (0,255)
 	MISSING_CODES=[0,255]
 	SCALING='LINEAR' & INTERCEPT=0.0 & SLOPE=1.0
 	MAP='L3B'
 	INFILE=FILE_MASK
 	NOTES='MASK_SUBAREA'

;	===> csv file with codes and names
  csv = READALL(FILE_CSV)
; *************************************
; *****  Make Mask for STRUCT_SD  *****
; *************************************
  MASK = DATA ; COPY OF DATA

; ===> LAND
  CODE_NAME = 'LAND'
  ACODE = 0
  CODE_MASK     =[ACODE]
  CODE_NAME_MASK=[CODE_NAME]

; ===> WATER
  CODE_NAME = 'WATER'
  ACODE = 255
  CODE_MASK     =[CODE_MASK,ACODE]
  CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]

; ===> LME CODES AND NAMES
  FOR LME_CODE = 1,64 DO BEGIN
  	OK=WHERE(FIX(CSV.CODE) EQ LME_CODE,COUNT)
  	IF COUNT NE 1 THEN STOP
  	CODE_NAME = CSV[OK].NAME
  	CODE_MASK     =[CODE_MASK,LME_CODE]
  	CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
  ENDFOR


        STRUCT_SD_WRITE,SAVEFILE,PROD=PROD, $
                  IMAGE=DATA,      MISSING_CODE=missing_codes, $
                  MASK=MASK,          CODE_MASK=CODE_MASK, CODE_NAME_MASK=CODE_NAME_MASK, $
                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
                  DATA_UNITS='',PERIOD=PERIOD, $
                  SENSOR='',	    SATELLITE='',  SAT_EXTRA='',$
                  METHOD='',    SUITE='',          MAP=MAP, $
                  INFILE=INFILE,$
                  NOTES=NOTES,      ERROR=ERROR

END; #####################  End of Routine ################################
