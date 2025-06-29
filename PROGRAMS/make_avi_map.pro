; $ID:	MAKE_AVI_MAP.PRO,	2020-07-08-15,	USER-KJWH	$
; Makes a title image from image_file

PRO MAKE_AVI_MAP_SLIDE, MAP=MAP ,DIR_OUT=DIR_OUT,TARGET_COLOR=TARGET_COLOR, PAL=PAL,$
												NAME_COLOR=NAME_COLOR, LOCATION_PSYM=LOCATION_PSYM
											
	DIR_OUT		= 'D:\IDL\LME\'									
	;MAP = 'ARABIAN_SEA'
	;IF N_ELEMENTS(MAP) NE 1 THEN STOP
	 IF N_ELEMENTS(DIR_OUT) NE 1 THEN STOP
	

	IF N_ELEMENTS(NAME_COLOR) NE 1 THEN NAME_COLOR =0
  IF N_ELEMENTS(LOCATION_PSYM) NE 1 THEN LOCATION_PSYM =1
	IF N_ELEMENTS(MAP) NE 1 THEN MAP ='GEQ'
LME_IMAGE_GRID_FILE ='D:\IDL\IMAGES\LME_MASK_8640_4320.PNG'
GEQ= READ_PNG(LME_IMAGE_GRID_FILE,R,G,B)
GEQ(*,0:40)= 255

IM= MAP_REMAP(GEQ,MAP_IN='GEQ',PX_OUT= 1080,PY_OUT = 540,MAP_OUT='ROBINSON')
PAL_SW3,R,G,B
TVLCT,R,G,B
SLIDEW,IM
STOP
;	===> Read the sample image_file
 
	SZ=SIZEXYZ(IM)

	IF SZ.N_DIMENSIONS EQ 3 THEN BEGIN
	 N=1
	 N_PLANES=3
	ENDIF ELSE BEGIN
	 N=0
	 N_PLANES=1
	ENDELSE

	PX 	= SZ.PX
	PY 	= SZ.PY


    CHARSCALE = FLOAT(PY)/512




  Y_ADD=0.0


	IF PX GT 1024 THEN BEGIN
	  CHARSCALE = FLOAT(PY)/600
	  Y_ADD=0.1
	ENDIF
	IF PX LE 1024 THEN CHARSCALE = FLOAT(HEIGHT)/1200
	IF PX LT 512 THEN CHARSCALE = FLOAT(HEIGHT)/1800
OK = WHERE(IM EQ TARGET_COLOR,COUNT)
IF COUNT EQ 0 THEN BEGIN
ERROR ='TARGET_COLOR '+TARGET_COLOR +' IS NOT FOUND'
PRINT,ERROR
GOTO,DONE
ENDIF ELSE BEGIN
STOP
 XY = ARRAY_INDICES([PX,PY], OK,/DIMENSIONS  )
 XP=REFORM(XY(0,*))
 YP=REFORM(XY(1,*))
 MMX = MINMAX(XP)
 MMY = MINMAX(YP)
  
 BOX_L = 0 >(MMX[0]) < (PX-1)
 BOX_R = 0 >(MMX[1]) < (PX-1)
 BOX_B=  0 > (MMY[0]) < (PY-1)
 BOX_T = 0 >(MMY[1]) < (PY-1) 
 XX= (BOX_L+BOX_R)/2
 YY= (BOX_B+BOX_T)/2
 NORMAL = 0
 DATA=0
 DEVICE=1
ENDELSE; IF COUNT EQ 0 THEN BEGIN

	MAP_SLIDE_FILE=DIR_OUT+'MAP_SLIDE_FILE.PNG'
  IMAGE = MAP_ADD_TXT(IM,XPOS,YPOS,TXT,NORMAL=NORMAL,DEVICE=DEVICE,DATA=DATA,COLOR=color,CAPTION=caption, _EXTRA=_extra, FONT=font)
	  	;IMAGE = MAP_ADD_TXT(IMAGE,0.5,0.45,	MAP,COLOR=NAME_COLOR,charsize=8*charscale,CHARTHICK=3,ALIGN=0.5)
	  	
  	CALL_PROCEDURE,PAL,R,G,B
  	WRITE_PNG,MAP_SLIDE_FILE,IMAGE,R,G,B
 
  	FOR PLANE = 0,N_PLANES-1 DO BEGIN

  	ENDFOR
  WRITE_PNG,TITLE_SLIDE_FILE,IMAGE,R,G,B
 	
DONE:
END ; OF PROGRAM
