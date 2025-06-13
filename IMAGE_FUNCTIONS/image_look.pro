; $ID:	IMAGE_LOOK.PRO,	2020-06-30-17,	USER-KJWH	$
	PRO IMAGE_LOOK,Image,Colors, BACKGROUND=background

;+
; NAME:
;		IMAGE_LOOK
;
; PURPOSE:;

;		This procedure Displays one or more colors present in a BINARY IMAGE
;
; CATEGORY:
;		IMAGE
;
; CALLING SEQUENCE:
;
;		IMAGE_LOOK, Image

; INPUTS:
;		Image:	A 2d-image array
;		Colors: The colors present in the image to be displayed (default is all colors)
;

; KEYWORD PARAMETERS:
;		BACKGROUND:	Background color to use in the display
;
; OUTPUTS:
;		This Routine Displays an image showing where each color is found
;
;	PROCEDURE:
;		A blank image (255b) is made from the Image and
;   the target color(s) are found using WHERE and copied to the blank image
; EXAMPLE:
;

; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'IMAGE_LOOK'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''



  IF N_ELEMENTS(BACKGROUND) NE 1 THEN background=255b

  SZ=SIZE(IMAGE,/STRUCT)

  SLIDEW,Image,XVISIBLE=1024,YVISIBLE=800,TITLE='Image'

	H=HISTOGRAM(Image,MIN=0,MAX=255)

	IF N_ELEMENTS(COLORS) EQ 0 THEN BEGIN
	 COLORS=WHERE(H GE 1)
  ENDIF ELSE COLORS = COLORS

  STRUCT= REPLICATE(CREATE_STRUCT('COLOR',0,'COUNT',0L),N_ELEMENTS(COLORS))
  STRUCT.COLOR=COLORS
  STRUCT.COUNT = H(COLORS)
  SPREAD,STRUCT

	YN = ''
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR NTH=0L,N_ELEMENTS(COLORS)-1L DO BEGIN
    	ACOLOR = COLORS[NTH]
;;	 	YN = DIALOG_MESSAGE( 'Next color',  /CENTER,/QUESTION)
			READ,'NEXT COLOR: ',YN
        IF STRMID(STRUPCASE(YN),0,1) NE 'N' THEN BEGIN
        COPY=Image
        COPY(*,*)=background
        OK = WHERE(IMAGE EQ ACOLOR,COUNT)
        IF COUNT GE 1 THEN BEGIN
          COPY[OK] = ACOLOR
        ENDIF
        TV,COPY
        XYOUTS,0.5,0.85,/NORMAL,'Color: '+NUM2STR(ACOLOR) +' '+ NUM2STR(COUNT) + ' Pixels',COLOR=128
      ENDIF ELSE BREAK
    ENDFOR
;		||||||


END; #####################  End of Routine ################################
