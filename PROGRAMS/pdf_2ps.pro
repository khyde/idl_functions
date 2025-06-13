; $ID:	PDF_2PS.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO PDF_2PS, FILES, DIR_OUT=dir_out, DPI=dpi
;+
; NAME:
;       PDF_2PS
;
; PURPOSE:
;				Create a PNG image file from a PostScript file
;
; KEYWORD PARAMETERS:
;       DIR_OUT: Directory for output
;				DPI:		 Dots Per Inch Resolution (default is [300,300]
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
; the output file's size in pixels. The default resolution is normally 72×72dpi.
; gs -sDEVICE=jpeg -sOutputFile=foo.jpg foo.ps


;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, August 17, 2004
;-

ROUTINE_NAME='PDF_2PS'

; ===> Change the Location of the direcory containing gs executable program
;			 and change the name of the executable to that appropriate for operating system

	PATH_GS_PDF  = 'C:\GSTOOLS\'



;	===> Set default output graphics device to PNG 256 COLORS
	PS_DEVICE = 'png256'

;	===> File name suffix
	SUFFIX = '-PS_'

;	===> File extension
	EXT =  'PNG'

	SP = ' '

;	===> Default resolution (300 dots per inch)
	IF N_ELEMENTS(DPI) 	EQ 0 THEN _DPI = 300 ELSE _DPI = DPI
	IF N_ELEMENTS(_DPI) EQ 1 THEN _DPI= [_DPI,_DPI]

;	===> Commands for Ghostscipt
	CMD_GS_exe  = PATH_GS_PDF+ 'PDF2PS.BAT' ; This is the command line version for Windows Operating Systems
	CD,PATH_GS_PDF
	CMD_DEVICE    = '-sDEVICE=' + PS_DEVICE
	CMD_RES       = '-r'+STRTRIM(_DPI[0],2)+'x'+STRTRIM(_DPI[1],2)
	CMD_OUTFILE 	= '-sOutputFile='
	CMD_PAGES			=	'%d'
	CMD_QUIET     = '-q'
	CMD_BATCH			= '-dBATCH'
	CMD_QUIT      = '-dNOPAUSE'

	IF N_ELEMENTS(FILES) NE 1 THEN BEGIN & CD,CURR=DIR &	FILES=DIR+DELIMITER(/PATH)+'IDL.PS' & ENDIF


; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _file=0L,N_ELEMENTS(FILES)-1L DO BEGIN
		FILE=FILES(_file)
  	FN=PARSE_IT(FILE)

		IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FN.DIR ELSE _DIR_OUT = DIR_OUT
		outfile = _DIR_OUT+FN.NAME+ SUFFIX + '.'+ EXT
;	 	CMD = CMD_GS_exe+SP+ CMD_DEVICE+SP+ CMD_RES+SP+ CMD_OUTFILE+OUTFILE+SP+ CMD_QUIET+SP+ CMD_BATCH+SP+ CMD_QUIT+SP+FILE
		CMD= CMD_GS_exe+SP +OUTFILE+SP+   FILE



  	PRINT, CMD
		SPAWN, CMD,/HIDE,/LOG_OUTPUT
	ENDFOR

END; #####################  End of Routine ################################



