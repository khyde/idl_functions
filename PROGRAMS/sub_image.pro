PRO  SUB_IMAGE

; ===> Determine the pixel coordinates you want to extract from
	;e.g. FOR UPPER RIGHT PORTION OF NEC IMAGE
	START_X = 512
	END_X   = 1023
	START_Y=  512
	END_Y  =  1023


	PX = 1024
	PY = 1024

; ===> Get the
	STRUCT=IMAGE_PXPY(IMAGE,PX,PY)
	X = STRUCT.X
	Y = STRUCT.Y

	ZWIN,[PX,PY]
	MAP_NEC
	XYZ=CONVERT_COORD(X,Y,/DEVICE,/TO_DATA)
	ZWIN


;	===> Get lon and lat from x and y
	LONS = REFORM(XYZ(0,*))
	LATS = REFORM(XYZ(1,*))

; ===> Reform into 2d arrays
	LONS= REFORM(LONS,PY,PY)
	LATS= REFORM(LATS,PY,PY)

STOP

; ===> Now get all the images you want to extract
 ; FILES = FILELIST (' ...')   ... OR FILES =FILE_SEARCH( )


	FOR NTH = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
		afile = FILES(nth)
		; read afile
;			IMAGE = READALL(AFILE)

;			MAKE A NAME FOR THE OUTPUT FILE
;			OUTFILE = ' '
;			OPENW,LUN,OUTFILE,/GET_LUN
		FOR _Y = START_Y,END_Y DO BEGIN
			FOR _X = START_X,END_X DO BEGIN
				PRINTF, LUN	, LONS(_X,_Y),LATS(_X,_Y),IMAGE(_X,_Y)	,FORMAT='(F10.5)'
			ENDFOR
		ENDFOR



	ENDFOR

STOP


END