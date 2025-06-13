; $ID:	CROP_IMAGE.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO CROP_IMAGE,FILES,BACKGROUND = BACKGROUND

;+
; NAME:
;		CROP_IMAGE
;
; PURPOSE: ;    This PROGRAM USES CUTOUT.PRO TO CROP IMAGES (PNG,JPG ETC.)
;               IT IS USEFUL TO REMOVE WHITE SPACE AROUND A SCANNED IMAGE
;
; CATEGORY:
;		CATEGORY
;		 IMAGES
;
; CALLING SEQUENCE:
;
; INPUTS:
;		FILE:	COMPLETE FILE NAME
;		
; OPTIONAL INPUTS:
;		NONE:	
;
; KEYWORD PARAMETERS:
;   BACKGROUND- THE BYTE VALUE FOR THE BACKGROUND IN THE IMAGE
; OUTPUTS:
;

; EXAMPLE:
;  CROP_IMAGE,'D:\MISC\IMAGE.JPG',BACKGROUND = 255
;	NOTES:
;

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written SEP 15,2011  J.O'Reilly
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CROP_IMAGE'
	
	IF N_ELEMENTS(FILES) EQ 0 THEN STOP
	IF N_ELEMENTS(BACKGROUND) EQ 1 THEN _BACKGROUND = BACKGROUND ELSE _BACKGROUND = 255; DEFAULT
	FOR NTH = 0, N_ELEMENTS(FILES)-1 DO BEGIN
	 FILE = FILES[NTH]
;===>PARSE THE EXTENSION TO DETERMINE TYPE OF FILE
   FN = FILE_PARSE(FILE)	
   FORMAT = STRUPCASE(FN.EXT)
;===> READ THE IMAGE FILE	
;STOP
  IM = READ_IMAGE(FILE , Red, Green, Blue)
  HELP,IM
  
	CUT =CUTOUT(IM,BACKGROUND=_BACKGROUND,GRACE=GRACE, PX=PX,PY=PY)


  WRITE_IMAGE, Filename, Format, CUT , Red, Green, Blue
;Format
;A scalar string containing the name of the file format to write. The following are the supported formats:;
;
; •  BMP 
; •  GIF 
; •  JPEG 
; •  PNG 
; •  PPM 
; •  SRF 
; •  TIFF 
ENDFOR;FOR NTH = 0, N_ELEMENTS(FILES)-1 DO BEGIN
	END; #####################  End of Routine ################################
