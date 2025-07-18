; $ID:	MEDIAN_FILL_DEMO.PRO,	2020-06-26-15,	USER-KJWH	$

  PRO MEDIAN_FILL_DEMO, FILES = FILES,DIR_OUT=DIR_OUT



;+
; NAME:
;       MEDIAN_FILL_DEMO
;
; PURPOSE:
;        DEMO FOR MEDIAN_FILL
;

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 5,2006
;-

;	*** SWITCHES ***

	DO_SST_TEST = 2


  DIR = 'D:\MEDIAN_FILL\'
  DIR = 'D:\SST_GEQ-NEC-N4ATG\SAVE_MERGE\'
	DIR_OUT = 'D:\SST_GEQ-NEC-N4ATG\BROWSE\'
;	******************************
	IF DO_SST_TEST GE 1 THEN BEGIN
;	******************************

  	FILES = FILE_SEARCH(DIR,'!D_*-SST*.SAVE')

;		FILES = SUBSAMPLE(FILES,100)
;OK=WHERE(STRPOS(FILES,'20050308') GE 0)
;FILES=FILES[OK]

 OK=WHERE(STRPOS(FILES,'PF_4') GE 0)
 FILES=FILES[OK]
 STOP

		OVERWRITE= DO_SST_TEST GE 2
		BOX=[3,7]
		LANDMASK=READ_LANDMASK('D:\IDL\IMAGES\MASK_LAND-NEC-PXY_1024_1024.PNG',/land)


;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR _FILE=0L,N_ELEMENTS(FILES)-1 DO BEGIN
	  	AFILE=FILES(_FILE)
	  	FN=FILE_PARSE(AFILE)

;	  	STRUCT_SD_2PNG,AFILE,PAL='PETES24J',OVERWRITE=OVERWRITE,DIR_OUT=DIR_OUT
	  	DATA = STRUCT_SD_READ(AFILE)
	  	OK=WHERE(LANDMASK NE 1 AND DATA EQ MISSINGS(DATA),COUNT)
	  	PRINT,COUNT

	  	MF= MEDIAN_FILL(DATA,BOX=BOX,MASK=LANDMASK)
	  	OK=WHERE(LANDMASK NE 1 AND MF EQ MISSINGS(MF),COUNT)

	  	PRINT,COUNT
	  	FILL_FILE = DIR_OUT+FN.FIRST_NAME+STRJOIN('-'+STRTRIM(BOX,2))+'-MASK.PNG'
		  MF = SD_SCALES(MF,PROD='SST',/DATA2BIN,SPECIAL_SCALE='NEC')
		  PAL_PETES24J,R,G,B
		  WRITE_PNG,FILL_FILE,MF,R,G,B

	  	IMAGE = SD_SCALES(DATA,PROD='SST',/DATA2BIN,SPECIAL_SCALE='NEC')
			PAL_PETES24J,R,G,B
			IMAGE_FILE = DIR_OUT+FN.FIRST_NAME+'-IMAGE.PNG'
	  	WRITE_PNG,IMAGE_FILE,IMAGE,R,G,B
			FILL_FILE = DIR_OUT+FN.FIRST_NAME+STRJOIN('-'+STRTRIM(BOX,2))+'NO_MASK.PNG'
		  FILL = SD_SCALES(MEDIAN_FILL(DATA,BOX=BOX),PROD='SST',/DATA2BIN,SPECIAL_SCALE='NEC')
		  PAL_PETES24J,R,G,B
		  WRITE_PNG,FILL_FILE,FILL,R,G,B


		ENDFOR
	ENDIF
;	|||||||||||||||||||||||||||||||

STOP




	ARR=DIST(11)
	ARR = FIX(ARR)
	ARR(4:6,4:6) = MISSINGS(ARR)
	PAL_36
	SLIDEW,  (CONGRID(ARR,220,220)), TITLE='ORIG'
	PRINT,ARR
	PRINT
  NEW = MEDIAN_FILL(ARR,BOX=[3,5])
  PRINT,NEW
	SLIDEW,  (CONGRID(NEW,220,220))

		STOP


	ARR = FLOAT([1,2,3,4,5,MISSINGS(6.),7,8,9,10,11])
  LIST, MEDIAN_FILL(ARR,BOX=[3,5])
  STOP

  ARR = [1,2,3,4,5,MISSINGS(6),7,8,9,10,11]
  LIST, MEDIAN_FILL(ARR,/EVEN)
  STOP




  END; END OF PROGRAM

