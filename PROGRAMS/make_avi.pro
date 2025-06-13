; $ID:	MAKE_AVI.PRO,	2020-07-08-15,	USER-KJWH	$
; Makes a AVI Movie from a series of images
; **************** AVI Compressor  ***************************************
;VideoCompressorList
;                 Writes a description of all AVI VideoCompressorList available
;                 and the parameter code associated with each compressor.
;ShowCompressors
;                 Does the same as above and runs the program associated with 'TXT' files.
;Compressor=?
;                 Ask for compression.
;Compressor=<CODE>
;                 Use the compressor associated with <code>.
;                 To get a list of the VideoCompressorList available see "VideoCompressorList" above.
;Description = Microsoft Video 1
;Four Character Code = msvc
;Four Character Code = cvid
;Four Character Code = mrle
;Four Character Code = iv31
;Four Character Code = iv32
;Quality=X
;                 Tells AVI Constructor to set the VideoCompressorList quality to X.
;                 X can equal any number between 0 and 10000.
;Width=X
;                 Tells AVI Constructor to make the AVI with a width of X.
;Height=X
;                 Tells AVI Constructor to make the AVI with a height of X.
;Bits=X
;                 Make the AVI using X bits per pixel
;                 X can equal one of the following:
;                 0: Use the format of the first image.
;                 1: Make a monochrome AVI
;                 4: Make a 16 color AVI
;                 8: Make a 256 color AVI
;                 16: Make a High Color AVI
;                 24: Make a True Color AVI
;                 32: Make a 32 bit True Color AVI
;                The default format is high color (16 bit).
;DIR=
;                 Change to <directory>.
;                 Useful if the images file names
;                 in the list file do not contain the path location.;
;          (For example, from the dos prompt type
;                 "dir /B *.TGA" or "dir /B *.TGA > Test.lst".
;Help
;                 Write the params.txt file.
;
;ShowHelp or ? or /?
;                 Does the same as above and runs the program associated with 'TXT' files.
;
; NOTES:
;   PAL = ['PAL_SW3','PAL_PETES24J']   IF THE INPUT FILES HAVE BOTH SEAWIFS AND AVHRR
; EXAMPLE:
;
;
; EXAMPLE FOR MAKING AN AVI FROM IMAGES THAT HAVE BOTH SEAWIFS AND AVHRR COMBINED INTO ONE PNG:
;FILES = FILELIST('G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY_*.PNG')  & MAKE_AVI,FILES=FILES,PAL=['PAL_SW3','PAL_PETES24J'],$
;AVI_FILE='G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY.AVI'
;; FILES = FILELIST('G:\METHODS\TS_IMAGES_SEAWIFS_AVHRR_REPRO3_CD_NEC_CHLOR_A_SST_ISERIES_1745_INTERP_DAY_*.PNG')  & MAKE_AVI,FILES=FILES(0:5),PAL=['PAL_SW3','PAL_PETES24J'],AVI_FILE='G:\METHODS\JUNK_BATCH.AVI
; HISTORY:
;   July 8,2002 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   July 22,2002 td, work with sd_analyses_main.pro
;   Aug 15, 2003 td, add TITLE_SLIDE_FILE keyword
;   Feb 10, 2004 td do not pass TITLE_SLIDE_FILE ,make it if TITLE_SLIDE is set

PRO MAKE_AVI,   FILES=files,            PAL=pal, $                           ; REQUIRED INPUT
                DIR_OUT=dir_out,        AVI_FILE=avi_file, $                 ; USUAL INPUT

                TITLE_SLIDE=title_slide, TITLE_FILE_PNG=TITLE_FILE_PNG, $
                N_TITLE=N_TITLE, TYPE=TYPE, MAP=MAP,$        ; USUAL INPUT

                FPS=fps, BITS=bits,       QUALITY=quality ,$                    ; OPTIONAL INPUT
                YOFFSET=YOFFSET,TITLE_COLOR=title_color,$
                AUTHORS=authors,ADDRESS=address,SENSORS=sensors

	ROUTINE_NAME = 'MAKE_AVI'

	UL='_'

	IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE()
	IF N_ELEMENTS(N_TITLE) EQ 0 THEN N_TITLE=10


; ===> Get Width and Height of Image from the first image file (assumes all files are dimensioned as the first file)
  IMAGE = READALL(FILES[0])
  SZ=SIZE(IMAGE,/STRUCT)
  IF SZ.N_DIMENSIONS EQ 3 THEN N = 1 ELSE N = 0
  WIDTH   = SZ.DIMENSIONS(N)
  HEIGHT  = SZ.DIMENSIONS(N+1)

		FN=PARSE_IT(FILES,/ALL)

		DATE_START=FN.DATE_START & S=SORT(DATE_START) & _DATE_START=DATE_START(S)
		DATE_START=STRMID(FIRST(_DATE_START),0,8)
		DATE_END  =STRMID(LAST(_DATE_START),0,8)

	IF N_ELEMENTS(AVI_FILE) NE 1 THEN BEGIN
  	DIR_OUT = FN[0].DIR
  	AVI_FILE        = DIR_OUT + ROUTINE_NAME  + '.AVI'
	ENDIF ELSE BEGIN
    FN_AVI=PARSE_IT(AVI_FILE,/ALL)
	  DIR_OUT = FN_AVI[0].DIR
	ENDELSE
	TITLE_SLIDE_DIR=DIR_OUT
	TITLE_SLIDE_FILE=	TITLE_SLIDE_DIR +'Title_Slide-'+FN_AVI[0].PROD+'.PNG'

; ********************  Output Files   *********
  IMAGE_TRUE_FILE = DIR_OUT + ROUTINE_NAME  + '_CALIBRATION.PNG'
  TXT_FILE        = DIR_OUT + FN_AVI.NAME  + '.TXT'
  AVI_CMD_FILE        = DIR_OUT + ROUTINE_NAME  + '-AVI_CMD.TXT'

;	********************* Make Title Slide ******************
	IF KEYWORD_SET(TITLE_SLIDE) THEN BEGIN
 		IF FILE_TEST(TITLE_FILE_PNG) EQ 0 THEN BEGIN
 		  TITLE_FILE_PNG=FN[1].FULLNAME
 		  TITLE_SLIDE_FILE=MAKE_AVI_TITLE(IMAGE_FILE=TITLE_FILE_PNG,TYPE=TYPE,PAL=PAL,DIR_OUT=TITLE_SLIDE_DIR,MAP=MAP,$
			                                DATE_START=DATE_START, DATE_END=DATE_END,YOFFSET=YOFFSET,TITLE_COLOR=title_color,$
		  	                              AUTHORS=authors,ADDRESS=address,SENSORS=sensors)
		ENDIF ELSE TITLE_SLIDE_FILE = TITLE_FILE_PNG 	                              
    _FILES=[REPLICATE(TITLE_SLIDE_FILE,N_TITLE),FILES]
  ENDIF ELSE _FILES=FILES

  WRITE_TXT,TXT_FILE,[_FILES]

; ****************************************************************
; *** Make a first frame to properly initialize the avi colors ***
; ****************************************************************
  IF N_ELEMENTS(PAL) GE 1 THEN BEGIN
      N=N_ELEMENTS(PAL)
      RR = BYTARR(N,256)
      GG = BYTARR(N,256)
      BB = BYTARR(N,256)
    FOR _PAL =0,N_ELEMENTS(PAL)-1 DO BEGIN
      CALL_PROCEDURE,PAL(_PAL),R,G,B
      RR(_PAL,*)=R & GG(_PAL,*)=G & BB(_PAL,*)=B
    ENDFOR

    RR = CONGRID(RR,WIDTH,HEIGHT)
    GG = CONGRID(GG,WIDTH,HEIGHT)
    BB = CONGRID(BB,WIDTH,HEIGHT)

    IMAGE_TRUE = BYTARR(3,WIDTH,HEIGHT)
    IMAGE_TRUE(0,*,*) = RR
    IMAGE_TRUE(1,*,*) = GG
    IMAGE_TRUE(2,*,*) = BB
    WRITE_PNG,IMAGE_TRUE_FILE,IMAGE_TRUE
ENDIF  ELSE BEGIN
  PRINT, 'ERROR: Must provide pal or array of pal '
  RETURN
ENDELSE

IF N_ELEMENTS(QUALITY) NE 1 THEN QUALITY = 100
IF N_ELEMENTS(COMPRESSOR) NE 1 THEN COMPRESSOR = 'msvc'
IF N_ELEMENTS(BITS) NE 1 THEN BITS = 8
IF N_ELEMENTS(FPS) NE 1 THEN BEGIN
  rate = 30
  scale = 10
ENDIF ELSE BEGIN
  rate = FIX(ROUND(FPS*100))
  scale = 100
ENDELSE


; ********************************
; ********* Commands for AviConstructor
  CMD = '"C:\AVI_CONSTRUCTOR\AVI Constructor.exe "'
  CMD = CMD + ' ' + 'width='  + NUM2STR(width)
  CMD = CMD + ' ' + 'height='   + NUM2STR(height)
  CMD = CMD + ' ' + 'quality=' + NUM2STR(QUALITY*100)
  CMD = CMD + ' ' + 'compressor='+compressor
  CMD = CMD + ' ' + 'bits='     + NUM2STR(bits)
  CMD = CMD + ' ' + 'rate='   + NUM2STR(rate)
  CMD = CMD + ' ' + 'scale='    + NUM2STR(scale)
  CMD = CMD + ' ' + 'ImageForPalette=' + IMAGE_TRUE_FILE
  CMD = CMD + ' '+ TXT_FILE
  CMD = CMD + ' '+ AVI_FILE
  PRINT, CMD
  WRITE_TXT,AVI_CMD_FILE,CMD

  SPAWN, CMD


; ************************* Delete Junk Calibration Image
;  FILE_DELETE,IMAGE_TRUE_FILE,/QUIET


END
