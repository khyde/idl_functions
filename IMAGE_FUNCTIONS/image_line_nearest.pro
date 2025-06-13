; $ID:	IMAGE_LINE_NEAREST.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION IMAGE_LINE_NEAREST, IMAGE, TARGET=TARGET, BOX=BOX, IGNORE=IGNORE, MASK=MASK, ERROR=ERROR
;+
; NAME:
; 	IMAGE_LINE_NEAREST

;		This Program changes target values in an image to the value that is closest to the target

; 	MODIFICATION HISTORY:
;			Written July 8, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-

	ROUTINE_NAME='IMAGE_LINE_NEAREST'

	SZ=SIZE(IMAGE,/STRUCT)
	IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
		PRINT, 'ERROR: Image must be 2 dimensions'
	 	ERROR = 1 & RETURN, -1
	ENDIF

	PX=SZ.DIMENSIONS[0]
	PY=SZ.DIMENSIONS[1]
	LAST_PX = PX - 1
	LAST_PY = PY -1


	IF N_ELEMENTS(MASK) NE N_ELEMENTS(IMAGE) THEN BEGIN
		MASK = BYTE(IMAGE)
		MASK(*) = 0
	ENDIF

;	===> Ensure image is NUMERIC
	IF NUMERIC(IMAGE) NE 1 THEN BEGIN
		PRINT, 'ERROR: Image must be Numeric'
		ERROR = 1 & RETURN, -1
	ENDIF

	IF N_ELEMENTS(TARGET) NE 1 THEN BEGIN
		PRINT, 'ERROR: Must provide a Target value'
		ERROR = 1 & RETURN, -1
	ENDIF



;  ===> Evaluate Keyword BOX and generate default parameters for BOX
   IF KEYWORD_SET(box) THEN BEGIN
     IF N_ELEMENTS(BOX) EQ 1 THEN box = FIX([box,box])
     IF N_ELEMENTS(BOX) GE 3 THEN BEGIN
     	PRINT,"ERROR: box must have 1,or 2 dimensions"
     ENDIF
   ENDIF ELSE BEGIN
     box = [3,3]
   ENDELSE

 	AROUND_X = BOX[0]/2
 	AROUND_Y = BOX[1]/2

STOP

;	===> Find target pixels
	OK_TARGET=WHERE(IMAGE EQ TARGET,COUNT_TARGET)
	IF COUNT_TARGET EQ 0 THEN BEGIN
		PRINT, 'ERROR: Target not found in the image'
		ERROR = 1 & RETURN, -1
	ENDIF


;	===> Make an image index array
  pxpy = IMAGE_PXPY(IMAGE,/center)

;	===> Make a copy of the input image
	COPY = IMAGE


;	WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
	FOR NTH = 0L,COUNT_TARGET-1L DO BEGIN
		SUB =  OK_TARGET[NTH]

;		===> Get x,y coordinates for this sub
		xy = ARRAY_INDICES(COPY, SUB)
		X=XY[0]
		Y=XY[1]

;		===> Get pixels surrounding sub within the dimensions of the box and within the image dimensions
    boxL = (X - AROUND_X) > 0
    boxR = (X + AROUND_X) < last_px
    boxB = (Y - AROUND_Y) > 0
    boxT = (Y + AROUND_Y) < last_py

		SUBS_X		= PXPY.X(boxL:boxR, boxB:boxT)
		SUBS_Y		= PXPY.Y(boxL:boxR, boxB:boxT)

    BOX_SET 	= COPY(boxL:boxR, boxB:boxT)
    BOX_MASK 	= MASK( boxL:boxR, boxB:boxT)


   	OK_BOX_SET = WHERE(BOX_SET NE TARGET AND BOX_MASK EQ 0,COUNT_BOX_SET)


;		===> If count_box_set then
    IF COUNT_BOX_SET GE 1 THEN BEGIN
     	BOX_SET=BOX_SET(OK_BOX_SET)
     	SUBS_X = SUBS_X(OK_BOX_SET)
     	SUBS_Y = SUBS_Y(OK_BOX_SET)
			X_MID = X + 0.5
			Y_MID = Y + 0.5

;			===> Compute distance from center of sub to each of the valid neighbors in box_set
			DIST = (SUBS_X-X_MID)^2 + (SUBS_Y-Y_MID)^2 ;

;			===> Sort DIST and take the val from the pixel with the smallest distance from sub
			S=SORT(DIST)
			VAL = FIRST(BOX_SET(S))

;			===> Replace COPY with val at the sub location
			COPY(SUB) = VAL

;			===> Include the sub in the mask to remove it from further consideration
			MASK(SUB) = 1

    ENDIF
	ENDFOR

	RETURN,COPY





END; #####################  End of Routine ################################



