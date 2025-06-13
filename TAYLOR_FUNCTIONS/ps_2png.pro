; $Id:	ps_2png.pro,	May 13 2011	$

 PRO PS_2PNG, FILES, IMAGEOUT=IMAGEOUT, DIR_OUT=dir_out, DPI=dpi,PAL=PAL, $
              PATH_GS_PS=PATH_GS_PS, PATH_GS_PDF=PATH_GS_PDF, IMAGEONLY=IMAGEONLY, $
              ERROR=ERROR, ERR_MSG=ERR_MSG
;+
; NAME:
;       PS_2PNG
;
; PURPOSE:
;				Create a PNG image file from a PostScript file
;
;INPUTS :
;
;   FILES     := input PS files may be array)
;   IMAGEDATA := variable to store image data
;   
; KEYWORD PARAMETERS:
;       DIR_OUT: Directory for output
;				DPI:		 Dots Per Inch Resolution (default is [300,300]
;				IMAGEONLY : Don't save the PNG files
; OUTPUTS:
;				A PNG (portable networks graphics) image file
;				with the filename same as input but with the added suffix '-PS_#' and file extension of '.png'
;				and where # will be 1 ... number of pages contained in the input postscript file
;
;
; NOTES: from gs
; -sOutputFile=ABC%03d.xyz     ABC001.xyz ... ABC010.xyz ...
; @filename  (Causes gs to read long file names as is
; gs -sDEVICE=pcxmono -sOutputFile=xyz.pcx
;	-g1000x700
; Once you invoke Ghostscript you can also find out what devices are available by
;	"devicenames ==" at its command prompt.
; You can also use the -r switch to specify the imaging resolution and thus
; the output file's size in pixels. The default resolution is normally 72�72dpi.
; gs -sDEVICE=jpeg -sOutputFile=foo.jpg foo.ps
;
; EXAMPLES:
;   PS_2PNG, MYPSFILES, IMAGE_DATA=MYIMGARRAY, /IMAGE_ONLY
;   PS_2PNG, MYPSFILES, DIR_OUT='/home/user/pngfiles',
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 17, 2004
;       05/09/2011 : D.W.Moonan Modified to run w/Linux or Windows
;                      Allow for up to 999 pages per batch & format # to 000-999
;                      to allow sorting correctly if > 9 files. (CMD_PAGES = '%03d' param)
;       05/12/2011 : D.W.Moonan added (array of) image returned in IMAGEDATA, w/temporary PNG.
;                     /IMAGEONLY KEYWORD, added examples and other header info.
;                     Added error message/status, DEBUG_PRINT statements
;-

  ROUTINE_NAME='PS_2PNG'

  ERROR = 0
  ERR_MSG = ''
  
  CREATE_IMAGE_DATA = 0
  DELETE_PNG = 0
  
  IF KEYWORD_SET(IMAGEONLY) THEN BEGIN
    CREATE_IMAGE_DATA = 1
    DELETE_PNG = 1
    IF N_ELEMENTS(FILES) GT 1 THEN BEGIN
      ERR_MSG = ROUTINE_NAME + ' cannot accept more than one input file when creating an image.'
      DEBUG_PRINT,1,ERR_MSG
      ERROR = 1
      RETURN
    ENDIF
    ; TODO: first attempt or concept of multi-page output.  Trouble with struct/array logic.    
    ;IMAGE_STRUCT = CREATE_STRUCT('PSFILE','', 'IMAGE', 0)
    ;IM_STRUCT = CREATE_STRUCT('IMAGE',[0,0])
  ENDIF
      
; ===> Change the Location of the direcory containing gs executable program
;			 and change the name of the executable to that appropriate for operating system
	
   	
;	IF N_ELEMENTS(PATH_GS_PDF) EQ 0 THEN PATH_GS_PDF  = 'C:\GSTOOLS\'
  IF !VERSION.OS_FAMILY EQ 'unix' THEN BEGIN
    CMD_GS_EXE = 'gs '
  ENDIF
  IF !VERSION.OS_FAMILY EQ 'Windows' THEN BEGIN
    IF N_ELEMENTS(PATH_GS_PS) EQ 0 THEN BEGIN 
    COMPUTER = GET_COMPUTER()
    PATH_GS_PS = 'C:\gstools\gs5.50\'
    IF COMPUTER EQ 'HALIBUT' THEN PATH_GS_PS = 'C:\GSTOOLS\gs8.71\gs8.71\bin\'    
    IF FILE_TEST(PATH_GS_PS,/DIR) EQ 0 THEN BEGIN
      ERROR = 1
      ERR_MSG = 'GSTools directory does not exist.  Must supply appropriate path for gswin32c.exe'
      PRINT, ERR_MSG
      GOTO, DONE
    ENDIF  
   ENDIF;  PATH_GS_PS = '' 
    CMD_GS_EXE = PATH_GS_PS + 'gswin32c.exe '
  endif
   

;	===> Set default output graphics device to PNG 256 COLORS
	PS_DEVICE = 'png256'

;	===> File name suffix
	SUFFIX = '_PS_'

;	===> File extension
	EXT =  'PNG'

	SP = ' '

;	===> Default resolution (300 dots per inch)
	IF N_ELEMENTS(DPI) 	EQ 0 THEN _DPI = 300 ELSE _DPI = DPI
	IF N_ELEMENTS(_DPI) EQ 1 THEN _DPI= [_DPI,_DPI]
	IF N_ELEMENTS(PAL)  EQ 0 THEN _PAL = 'PAL_SW3' ELSE _PAL=PAL

;	===> Commands for Ghostscipt

	CMD_DEVICE    = '-sDEVICE=' + PS_DEVICE
	CMD_RES       = '-r'+STRTRIM(_DPI(0),2)+'x'+STRTRIM(_DPI(1),2)
	CMD_OUTFILE 	= '-sOutputFile='
	CMD_PAGES			=	'%03d'
	CMD_QUIET     = '-q'
	CMD_BATCH			= '-dBATCH'
	CMD_QUIT      = '-dNOPAUSE'

	DELIM = PATH_SEP()
	; -dCOLORSCREEN=false ?


	IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN & CD,CURR=DIR &	FILES=DIR+DELIM+'IDL.PS' & ENDIF

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _file=0L,N_ELEMENTS(FILES)-1L DO BEGIN
		FILE=FILES(_file)
  	FN=FILE_PARSE(FILE)

		IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FN.DIR ELSE _DIR_OUT = DIR_OUT
		outfile = _DIR_OUT+FN.NAME+ SUFFIX +cmd_pages+ '.'+ EXT
	 	CMD = +CMD_GS_exe+SP+ CMD_DEVICE+SP+ CMD_RES+SP+ CMD_OUTFILE+OUTFILE+SP+ CMD_QUIET+SP+ CMD_BATCH+SP+ CMD_QUIT+SP+FILE

  	PRINT, CMD

		;SPAWN, CMD,/HIDE,/LOG_OUTPUT
    SPAWN, CMD, result
    ;IF _FILE EQ 0 THEN IM_STRUCT.IMAGE = []
    PNGOUTS = FILE_SEARCH(_DIR_OUT + FN.NAME + SUFFIX + '*.PNG')
    NPNGS = N_ELEMENTS(PNGOUTS)

    IF NPNGS LT 1 THEN BEGIN
      ERR_MSG = ROUTINE_NAME + ' unable to generate PNG file.'
      DEBUG_PRINT,1,ERR_MSG
      ERROR = 1
      RETURN
    ENDIF

    IF CREATE_IMAGE_DATA EQ 1 THEN BEGIN
      ; read back the png files, find out how many were created, too.
      CALL_PROCEDURE,_PAL,R,G,B
      PNGOUTS = FILE_SEARCH(_DIR_OUT + FN.NAME + SUFFIX + '*.PNG')
      NPNGS = N_ELEMENTS(PNGOUTS)      
      IMAGEOUT = IMAGE_2TRUE(READ_PNG(PNGOUTS(0),R,G,B),R,G,B)
      IF NPNGS GT 1 THEN BEGIN
        ERR_MSG = ROUTINE_NAME + ' unable to handle multiple page input PS files; returning first page image only.'
        DEBUG_PRINT,1,ERR_MSG
        ERROR = 1
      ENDIF
      IF DELETE_PNG EQ 1 THEN FILE_DELETE, pngouts, /ALLOW_NONEXISTENT
 
; TODO: first attempt or concept of multi-page output.  Trouble with struct/array logic.     
;      ;IMAGE_STRUCT(_FILE).FILENAME = FILE
;      for I = 0, npngs - 1 do begin 
;        IDAT = READ_PNG(pngouts(i))
;        ;IMAGE_STRUCT(_FILE).IMAGE = [IMAGE_STRUCT(_FILE).IMAGE, IDAT]
;        IM_STRUCT = CREATE_STRUCT('IMAGE',IDAT)
;        ;IM_STRUCT.IMAGE = IDAT
;        IMAGEDATA = [IMAGEDATA, IM_STRUCT]
;        IF DELETE_PNG EQ 1 THEN FILE_DELETE, pngouts(i), /ALLOW_NONEXISTENT
;      ENDFOR
    ENDIF 

	ENDFOR
	DONE:

END; #####################  End of Routine ################################
