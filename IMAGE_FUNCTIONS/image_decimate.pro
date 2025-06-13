; $Id: IMAGE_DECIMATE.pro    March 26,2002
;+
;	This Function Decimates an Image and shrinks the file size  (usually so that It fits into a smaller file size but retains most of the pattern)

; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO IMAGE_DECIMATE,FILES, DIR_OUT=dir_out, TARGET_SIZE=target_size , PAL=pal
  ROUTINE_NAME='IMAGE_DECIMATE'
  IF N_ELEMENTS(TARGET_SIZE) NE 1 THEN TARGET_SIZE = 50000L
  IF N_ELEMENTS(PAL) NE 1 THEN PAL = 'PAL_SW3'
  CALL_PROCEDURE,PAL,R,G,B

  IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE(/MULTIPLE_FILES,TITLE='Select Image Files ')

  FOR _file=0L,N_ELEMENTS(files)-1L DO BEGIN
    afile = files(_file)
    FI=FILE_INFO(AFILE)
		SZ = FI.SIZE
  	FN=PARSE_IT(afile)
  	im=readall(afile)
  	PRINT, 'Reading '+afile
  	PRINT, 'Image Size: '+ SZ
  	II = image_2true(IM,R,G,B)

    IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FN.DIR ELSE _DIR_OUT = DIR_OUT
		JPGFILE = _DIR_OUT + FN.NAME + '_edit.JPG'

  	Q = 85
  	IF SZ GT target_size THEN BEGIN


;		WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
		WHILE SZ GT target_size DO BEGIN
			Q=Q-2
			I=II
			WRITE_JPEG,JPGFILE,I, QUALITY= Q ,TRUE=1
			FI=FILE_INFO(JPGFILE)
			SZ = FI.SIZE
			PRINT,'Size of jpeg file is now: '+ NUM2STR(SZ)
		ENDWHILE
;		|||||||||||||||||||||||||||||||||||||||||||||||
  ENDIF ELSE BEGIN
  		I=II
  		WRITE_JPEG,JPGFILE,I, QUALITY= Q ,TRUE=1
  ENDELSE


  PRINT, 'Final Size of jpeg file is: ' + NUM2STR(SZ) +' and Final JPEG Quality Factor is: '+NUM2STR(Q)+' OF 100)
 ENDFOR


END; #####################  End of Routine ################################
