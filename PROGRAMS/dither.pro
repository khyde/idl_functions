; $ID:	DITHER.PRO,	2020-07-08-15,	USER-KJWH	$
;+
; NAME:
;       dither
;
; PURPOSE:
;       Transform a 256-color image into a dithered (shaded) image
;
; CATEGORY:
;       Image
;
; CALLING SEQUENCE:
;       dither
;       dither,/help  ; generates a help file : dither.hlp which shows how to make the
;                       command_file required by the program
;       dither, FILES='d:\*.PNG', COMMAND_FILE='d:\commands.txt'
;
;       dither, FILES='d:\*.PNG', COMMAND_FILE='d:\commands.txt' , INPUT_TYPE='PCX'
;
;       dither, /no_bw  ; does not change all pixels on output to black (0b) or white(255b)
;       (can dither in color when use your own PATT commands in the COMMAND_FILE)
; INPUTS:
;       One or more PNG, BMP, or PCX graphics 256-color image files
;       AND a single command file (REQUIRED) which informs the program how to substitute the
;       various dither patterns for the original colors in the input image.
;
; KEYWORD PARAMETERS:
;       HELP:  Generates an example of commands in the required command file as well
;              as the codes (0's,1's) used to make the dither patterns.
;       SAMPLE:    Creates an output PNG file (dither.PNG) showing sample dither patterns.
;       FILES: The name(s) of the input image files.
;       COMMAND_FILE: The name of the command file containing COLR, or PATT commands
;       INPUT_TYPE: The type (PCX,PNG,or BMP) of input image file
;                   (The program reads the input file extension (bmp,PNG,pcx)
;                    to determine which idl program
;                    (READ_BMP,READ_PNG,READ_PCX) will be used to read
;                    the image.  If the input image file is a PNG but the extension
;                    is not 'PNG' e.g. test.256, then INPUT_TYPE='PNG' instructs the dither
;                    program to use the READ_PNG for all file names provided with
;                    the keyword FILES=   .
;       RESOLUTION:  The resolution of the dither pattern (fine,medium,coarse)
;                    RESOLUTION=8   means the 8by8 patterns are used as is;
;                    RESOLUTION=4   means the 8by8 patterns are reduced to  4by4  using rebin
;                    RESOLUTION=12 means the 8by8 patterns are enlarged to 12by12 using rebin
;                    RESOLUTION=16 means the 8by8 patterns are enlarged to 16by16 using rebin
;                    RESOLUTION=32 means the 8by8 patterns are enlarged to 32by32 using rebin
;
; OUTPUTS:
;       A dithered PNG Image file
;       Default is to set all colors  to 0 (black) or 255 (white) unless /NO_BW.
;
;       NOTE: The DEFAULT NAME of the output file will be the same name as the
;       input file name, but with a '.dither' or '.dit' extension.
;       NOTE: Program skips over any input files with '.dit' or '.dither' extension
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, February 23, 1996.
;				Jan 25, 2003 jor changed output to  png and added _dither.png to input name
;-
; ====================>
; Program patt12
; Makes a 12 by 12 array, fills in around 16 equidistant points
  PRO patt12,patt
  patt = BYTARR(256,12,12)
  patt(*,*,*) = 1b
  patt(0,*,*) = 0b

  patt(1,0,0) = 0b
  patt(2,*,*) = patt(1,*,*)
  patt(2,6,6) = 0b
  patt(3,*,*) = patt(2,*,*)
  patt(3,6,0) = 0b
  patt(4,*,*) = patt(3,*,*)
  patt(4,0,6) = 0b
  patt(5,*,*) = patt(4,*,*)
  patt(5,3,3) = 0b
  patt(6,*,*) = patt(5,*,*)
  patt(6,9,9) = 0b
  patt(7,*,*) = patt(6,*,*)
  patt(7,3,9) = 0b
  patt(8,*,*) = patt(7,*,*)
  patt(8,9,3) = 0b

  patt(9,*,*) = patt(8,*,*)
  patt(9,3,0) = 0b
  patt(10,*,*) = patt(9,*,*)
  patt(10,9,6) = 0b
  patt(11,*,*) = patt(10,*,*)
  patt(11,3,6) = 0b
  patt(12,*,*) = patt(11,*,*)
  patt(12,9,0) = 0b
  patt(13,*,*) = patt(12,*,*)
  patt(13,0,3) = 0b
  patt(14,*,*) = patt(13,*,*)
  patt(14,6,9) = 0b
  patt(15,*,*) = patt(14,*,*)
  patt(15,6,3) = 0b
  patt(16,*,*) = patt(15,*,*)
  patt(16,0,9) = 0b


; ====================>
  FOR i = 17,32 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-16,*,*),1)
  ENDFOR

  FOR i = 33,48 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-32,*,*),156)
  ENDFOR

  FOR i = 49,64 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-48,*,*),157)
  ENDFOR

  FOR i = 65,80 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-64,*,*),2)
  ENDFOR

  FOR i = 81,96 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-80,*,*),158)
  ENDFOR

  FOR i = 97,112 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-96,*,*),168)
  ENDFOR

  FOR i = 113,128 DO BEGIN
    patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-112,*,*),169)
  ENDFOR

FOR i = 129,144 DO BEGIN
  patt(i,*,*) = patt(i-16,*,*) EQ 0 + shift(patt(i-128,*,*),170)
ENDFOR


ok = WHERE(PATT EQ 1)
PATT(ok) = 255b
END

  PRO PATT1,PATT
; ====================>
; Initilize default patterns used by program
  PATT  = BYTARR(256,8,8)  ; initially all set to zero then some of the patterns replaced below:
; DITHER PATTERNS USED FOR SHADED B&W OUTPUT  in FORTRAN PROGRAM PCXSHADE AND PCXMAP (JOR)
; NOTE had to rearrange subscripts for patt arrays , old fortran had patt, row, column ; idl has patt,column,row order

;pro junk
;openr,1,'dither.pro'
;openW,2,'dither.dat';
;ATEXT = ' '
;WHILE NOT EOF[1] DO BEGIN
;  READF,1,ATEXT
;  ATEXT = STRTRIM(ATEXT,2)
;  OK = STRPOS(ATEXT,'PATT')
 ; IF OK GE 0 THEN BEGIN
 ;   BTEXT = STR_SEP(ATEXT,',')
 ;   IF N_ELEMENTS(BTEXT) EQ 10 THEN BEGIN
 ;     ctext = '  '+btext(0)+',*,'+btext(1)+')='+strmid(atext,strpos(atext,'['),22)
 ;     PRINTF,2,ctext,format='(A33)'
;    ENDIF
;  ENDIF
;ENDWHILE
;CLOSE,1
;CLOSE,2
;end

 PATT( 0,*,0)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,1)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,2)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,3)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,4)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,5)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,6)=[0,0,0,0,0,0,0,0]
  PATT( 0,*,7)=[0,0,0,0,0,0,0,0]
  PATT(15,*,0)=[1,1,1,1,1,1,1,1]
  PATT(15,*,0)=[1,1,1,1,1,1,1,1]
  PATT(15,*,1)=[1,1,1,1,1,1,1,1]
  PATT(15,*,2)=[1,1,1,1,1,1,1,1]
  PATT(15,*,3)=[1,1,1,1,1,1,1,1]
  PATT(15,*,4)=[1,1,1,1,1,1,1,1]
  PATT(15,*,5)=[1,1,1,1,1,1,1,1]
  PATT(15,*,6)=[1,1,1,1,1,1,1,1]
  PATT(15,*,7)=[1,1,1,1,1,1,1,1]
  PATT(255,*,0)=[1,1,1,1,1,1,1,1]
  PATT(255,*,1)=[1,1,1,1,1,1,1,1]
  PATT(255,*,2)=[1,1,1,1,1,1,1,1]
  PATT(255,*,3)=[1,1,1,1,1,1,1,1]
  PATT(255,*,4)=[1,1,1,1,1,1,1,1]
  PATT(255,*,5)=[1,1,1,1,1,1,1,1]
  PATT(255,*,6)=[1,1,1,1,1,1,1,1]
  PATT(255,*,7)=[1,1,1,1,1,1,1,1]
   PATT(1,*,0)=[1,1,1,1,1,1,1,1]
   PATT(1,*,1)=[1,1,1,1,1,1,1,1]
   PATT(1,*,2)=[1,1,1,1,1,1,1,1]
   PATT(1,*,3)=[1,1,1,1,1,1,1,1]
   PATT(1,*,4)=[1,1,1,1,1,1,1,1]
   PATT(1,*,5)=[1,1,1,1,1,1,1,1]
   PATT(1,*,6)=[1,1,1,1,1,1,1,1]
   PATT(1,*,7)=[0,1,1,1,1,1,1,1]
   PATT(2,*,0)=[1,1,1,1,1,1,1,1]
   PATT(2,*,1)=[1,1,1,1,1,1,1,1]
   PATT(2,*,2)=[1,1,1,1,1,1,1,1]
   PATT(2,*,3)=[1,1,1,1,0,1,1,1]
   PATT(2,*,4)=[1,1,1,1,1,1,1,1]
   PATT(2,*,5)=[1,1,1,1,1,1,1,1]
   PATT(2,*,6)=[1,1,1,1,1,1,1,1]
   PATT(2,*,7)=[0,1,1,1,1,1,1,1]
   PATT(3,*,0)=[1,1,1,1,1,1,1,1]
   PATT(3,*,1)=[1,1,1,1,1,1,1,1]
   PATT(3,*,2)=[1,1,1,1,1,1,1,1]
   PATT(3,*,3)=[0,1,1,1,1,1,1,1]
   PATT(3,*,4)=[1,1,1,1,1,1,1,1]
   PATT(3,*,5)=[1,1,1,1,1,1,1,1]
   PATT(3,*,6)=[1,1,1,1,1,1,1,1]
   PATT(3,*,7)=[0,1,1,1,0,1,1,1]
   PATT(4,*,0)=[1,1,1,1,1,1,1,1]
   PATT(4,*,1)=[1,1,1,1,1,1,1,1]
   PATT(4,*,2)=[1,1,1,1,1,1,1,1]
   PATT(4,*,3)=[0,1,1,1,0,1,1,1]
   PATT(4,*,4)=[1,1,1,1,1,1,1,1]
   PATT(4,*,5)=[1,1,1,1,1,1,1,1]
   PATT(4,*,6)=[1,1,1,1,1,1,1,1]
   PATT(4,*,7)=[0,1,1,1,0,1,1,1]
   PATT(5,*,0)=[1,1,1,1,1,1,1,1]
   PATT(5,*,1)=[1,1,1,1,1,0,1,1]
   PATT(5,*,2)=[1,1,1,1,1,1,1,1]
   PATT(5,*,3)=[1,0,1,1,1,1,1,1]
   PATT(5,*,4)=[1,1,1,1,1,1,1,1]
   PATT(5,*,5)=[1,1,1,1,1,0,1,1]
   PATT(5,*,6)=[1,1,1,1,1,1,1,1]
   PATT(5,*,7)=[1,0,1,1,1,1,1,1]
   PATT(6,*,0)=[1,1,1,1,1,1,1,1]
   PATT(6,*,1)=[1,1,1,1,1,1,0,1]
   PATT(6,*,2)=[1,1,1,1,1,1,1,1]
   PATT(6,*,3)=[1,1,1,1,0,1,1,1]
   PATT(6,*,4)=[1,1,1,1,1,1,1,1]
   PATT(6,*,5)=[1,1,0,1,1,1,1,1]
   PATT(6,*,6)=[1,1,1,1,1,1,1,1]
   PATT(6,*,7)=[0,1,1,1,1,1,1,1]
   PATT(7,*,0)=[1,1,1,1,1,1,1,1]
   PATT(7,*,1)=[1,1,1,1,1,1,1,1]
   PATT(7,*,2)=[1,1,1,1,1,1,1,1]
   PATT(7,*,3)=[0,1,1,1,0,1,1,1]
   PATT(7,*,4)=[1,1,1,1,1,1,1,1]
   PATT(7,*,5)=[1,1,0,1,1,1,1,1]
   PATT(7,*,6)=[1,1,1,1,1,1,1,1]
   PATT(7,*,7)=[0,1,1,1,0,1,1,1]
   PATT(8,*,0)=[1,1,1,1,1,1,1,1]
   PATT(8,*,1)=[1,1,1,1,1,1,0,1]
   PATT(8,*,2)=[1,1,1,1,1,1,1,1]
   PATT(8,*,3)=[0,1,1,1,0,1,1,1]
   PATT(8,*,4)=[1,1,1,1,1,1,1,1]
   PATT(8,*,5)=[1,1,0,1,1,1,1,1]
   PATT(8,*,6)=[1,1,1,1,1,1,1,1]
   PATT(8,*,7)=[0,1,1,1,0,1,1,1]
   PATT(9,*,0)=[1,1,1,1,1,1,1,1]
   PATT(9,*,1)=[1,1,0,1,1,1,1,1]
   PATT(9,*,2)=[1,1,1,1,1,1,1,1]
   PATT(9,*,3)=[0,1,1,1,0,1,1,1]
   PATT(9,*,4)=[1,1,1,1,1,1,1,1]
   PATT(9,*,5)=[1,1,0,1,1,1,0,1]
   PATT(9,*,6)=[1,1,1,1,1,1,1,1]
   PATT(9,*,7)=[0,1,1,1,0,1,1,1]
  PATT(10,*,0)=[1,1,1,1,1,1,1,1]
  PATT(10,*,1)=[1,1,0,1,1,1,0,1]
  PATT(10,*,2)=[1,1,1,1,1,1,1,1]
  PATT(10,*,3)=[0,1,1,1,0,1,1,1]
  PATT(10,*,4)=[1,1,1,1,1,1,1,1]
  PATT(10,*,5)=[1,1,0,1,1,1,0,1]
  PATT(10,*,6)=[1,1,1,1,1,1,1,1]
  PATT(10,*,7)=[0,1,1,1,0,1,1,1]
  PATT(11,*,0)=[1,1,1,1,1,1,1,1]
  PATT(11,*,1)=[1,1,1,1,1,1,1,1]
  PATT(11,*,2)=[1,1,1,1,1,1,1,1]
  PATT(11,*,3)=[1,1,1,1,1,1,1,1]
  PATT(11,*,4)=[1,1,1,1,1,1,1,1]
  PATT(11,*,5)=[1,1,1,1,1,1,1,1]
  PATT(11,*,6)=[1,1,1,1,1,1,1,1]
  PATT(11,*,7)=[0,0,0,0,0,0,0,0]
  PATT(12,*,0)=[0,1,1,1,1,1,1,1]
  PATT(12,*,1)=[0,1,1,1,1,1,1,1]
  PATT(12,*,2)=[0,1,1,1,1,1,1,1]
  PATT(12,*,3)=[0,1,1,1,1,1,1,1]
  PATT(12,*,4)=[0,1,1,1,1,1,1,1]
  PATT(12,*,5)=[0,1,1,1,1,1,1,1]
  PATT(12,*,6)=[0,1,1,1,1,1,1,1]
  PATT(12,*,7)=[0,1,1,1,1,1,1,1]
  PATT(13,*,0)=[1,1,1,1,1,1,1,0]
  PATT(13,*,1)=[1,1,1,1,1,1,0,1]
  PATT(13,*,2)=[1,1,1,1,1,0,1,1]
  PATT(13,*,3)=[1,1,1,1,0,1,1,1]
  PATT(13,*,4)=[1,1,1,0,1,1,1,1]
  PATT(13,*,5)=[1,1,0,1,1,1,1,1]
  PATT(13,*,6)=[1,0,1,1,1,1,1,1]
  PATT(13,*,7)=[0,1,1,1,1,1,1,1]
  PATT(14,*,0)=[1,1,1,1,1,1,1,1]
  PATT(14,*,1)=[1,1,0,1,1,1,0,1]
  PATT(14,*,2)=[1,1,1,1,1,1,1,1]
  PATT(14,*,3)=[0,1,1,1,0,1,1,1]
  PATT(14,*,4)=[1,1,1,1,1,1,1,1]
  PATT(14,*,5)=[1,1,0,1,1,1,0,1]
  PATT(14,*,6)=[1,1,1,1,1,1,1,1]
  PATT(14,*,7)=[0,1,0,1,0,1,1,1]
  PATT(16,*,0)=[1,1,1,1,1,1,1,1]
  PATT(16,*,1)=[1,1,0,1,1,1,0,1]
  PATT(16,*,2)=[1,1,1,1,1,1,1,1]
  PATT(16,*,3)=[0,1,1,1,0,1,1,1]
  PATT(16,*,4)=[1,1,1,1,1,1,1,1]
  PATT(16,*,5)=[1,1,0,1,1,1,0,1]
  PATT(16,*,6)=[1,0,1,1,1,1,1,1]
  PATT(16,*,7)=[0,1,1,1,0,1,1,1]
  PATT(17,*,0)=[1,1,1,1,1,1,1,1]
  PATT(17,*,1)=[1,1,1,1,1,1,1,1]
  PATT(17,*,2)=[1,1,1,1,1,1,1,1]
  PATT(17,*,3)=[1,1,1,1,1,1,1,1]
  PATT(17,*,4)=[1,1,1,0,0,0,1,1]
  PATT(17,*,5)=[1,1,0,1,0,1,1,1]
  PATT(17,*,6)=[1,0,1,1,1,0,1,1]
  PATT(17,*,7)=[0,1,1,1,1,1,0,0]
  PATT(18,*,0)=[1,1,1,1,1,1,1,1]
  PATT(18,*,1)=[1,1,0,1,1,1,0,1]
  PATT(18,*,2)=[1,1,1,1,1,0,1,1]
  PATT(18,*,3)=[0,1,1,1,0,1,1,1]
  PATT(18,*,4)=[1,1,1,1,1,1,1,1]
  PATT(18,*,5)=[1,1,0,1,1,1,0,1]
  PATT(18,*,6)=[1,0,1,1,1,1,1,1]
  PATT(18,*,7)=[0,1,1,1,0,1,1,1]
  PATT(19,*,0)=[1,1,1,1,1,1,1,1]
  PATT(19,*,1)=[1,1,0,1,1,1,0,1]
  PATT(19,*,2)=[1,1,1,1,1,1,1,1]
  PATT(19,*,3)=[0,1,1,1,0,1,0,1]
  PATT(19,*,4)=[1,1,1,1,1,1,1,1]
  PATT(19,*,5)=[1,1,0,1,1,1,0,1]
  PATT(19,*,6)=[1,1,1,1,1,1,1,1]
  PATT(19,*,7)=[0,1,0,1,0,1,1,1]
  PATT(20,*,0)=[1,1,1,1,1,1,1,1]
  PATT(20,*,1)=[1,1,0,1,1,1,0,1]
  PATT(20,*,2)=[1,1,1,1,1,0,1,1]
  PATT(20,*,3)=[0,1,1,1,0,1,1,1]
  PATT(20,*,4)=[1,1,1,0,1,1,1,1]
  PATT(20,*,5)=[1,1,0,1,1,1,0,1]
  PATT(20,*,6)=[1,0,1,1,1,1,1,1]
  PATT(20,*,7)=[0,1,1,1,0,1,1,1]
  PATT(21,*,0)=[1,1,1,1,1,1,1,1]
  PATT(21,*,1)=[1,1,0,1,1,1,0,1]
  PATT(21,*,2)=[1,1,1,1,1,1,1,1]
  PATT(21,*,3)=[0,1,0,1,0,1,0,1]
  PATT(21,*,4)=[1,1,1,1,1,1,1,1]
  PATT(21,*,5)=[1,1,0,1,1,1,0,1]
  PATT(21,*,6)=[1,1,1,1,1,1,1,1]
  PATT(21,*,7)=[0,1,0,1,0,1,1,1]
  PATT(22,*,0)=[1,1,1,1,1,1,1,1]
  PATT(22,*,1)=[1,1,0,1,1,1,0,1]
  PATT(22,*,2)=[1,0,1,1,1,0,1,1]
  PATT(22,*,3)=[0,1,1,1,0,1,1,1]
  PATT(22,*,4)=[1,1,1,1,1,1,1,1]
  PATT(22,*,5)=[1,1,0,1,1,1,0,1]
  PATT(22,*,6)=[1,0,1,1,1,0,1,1]
  PATT(22,*,7)=[0,1,1,1,0,1,1,1]
  PATT(23,*,0)=[1,1,1,1,1,1,1,1]
  PATT(23,*,1)=[1,1,0,1,1,1,0,1]
  PATT(23,*,2)=[1,1,1,1,1,1,1,1]
  PATT(23,*,3)=[0,1,0,1,0,1,0,1]
  PATT(23,*,4)=[1,1,1,1,1,1,1,1]
  PATT(23,*,5)=[1,1,0,1,1,1,0,1]
  PATT(23,*,6)=[1,1,1,1,1,1,1,1]
  PATT(23,*,7)=[0,1,0,1,0,1,0,1]
  PATT(24,*,0)=[1,1,1,1,1,1,1,1]
  PATT(24,*,1)=[1,1,0,1,0,1,0,1]
  PATT(24,*,2)=[1,1,1,1,1,1,1,1]
  PATT(24,*,3)=[0,1,0,1,1,1,0,1]
  PATT(24,*,4)=[1,1,1,1,1,1,1,1]
  PATT(24,*,5)=[1,1,0,1,0,1,0,1]
  PATT(24,*,6)=[1,1,1,1,1,1,1,1]
  PATT(24,*,7)=[0,1,0,1,1,1,0,1]
  PATT(25,*,0)=[1,1,1,1,1,1,1,1]
  PATT(25,*,1)=[1,1,0,1,1,1,0,1]
  PATT(25,*,2)=[1,1,1,1,1,1,1,1]
  PATT(25,*,3)=[0,1,0,1,0,1,0,1]
  PATT(25,*,4)=[1,1,1,1,1,1,1,1]
  PATT(25,*,5)=[0,1,1,1,0,1,1,1]
  PATT(25,*,6)=[1,1,1,1,1,1,1,1]
  PATT(25,*,7)=[0,1,0,1,0,1,0,1]
  PATT(26,*,0)=[1,1,1,1,1,1,1,1]
  PATT(26,*,1)=[1,1,0,1,1,1,0,1]
  PATT(26,*,2)=[1,1,1,1,1,1,1,1]
  PATT(26,*,3)=[0,1,0,1,0,1,0,1]
  PATT(26,*,4)=[1,1,1,1,1,1,1,1]
  PATT(26,*,5)=[0,1,0,1,1,1,0,1]
  PATT(26,*,6)=[1,1,1,1,1,1,1,1]
  PATT(26,*,7)=[0,1,0,1,0,1,0,1]
  PATT(27,*,0)=[1,1,1,1,1,1,1,1]
  PATT(27,*,1)=[1,1,0,1,0,1,0,1]
  PATT(27,*,2)=[1,1,1,1,1,1,1,1]
  PATT(27,*,3)=[0,1,0,1,0,1,0,1]
  PATT(27,*,4)=[1,1,1,1,1,1,1,1]
  PATT(27,*,5)=[0,1,0,1,1,1,0,1]
  PATT(27,*,6)=[1,1,1,1,1,1,1,1]
  PATT(27,*,7)=[0,1,0,1,0,1,0,1]
  PATT(28,*,0)=[1,0,1,1,1,1,1,1]
  PATT(28,*,1)=[1,1,0,1,1,1,0,1]
  PATT(28,*,2)=[1,0,1,1,1,0,1,1]
  PATT(28,*,3)=[0,1,1,1,0,1,1,1]
  PATT(28,*,4)=[1,1,1,1,1,0,1,1]
  PATT(28,*,5)=[1,1,0,1,1,1,0,1]
  PATT(28,*,6)=[1,0,1,1,1,0,1,1]
  PATT(28,*,7)=[0,1,1,1,0,1,1,1]
  PATT(29,*,0)=[1,1,1,1,1,1,1,1]
  PATT(29,*,1)=[1,1,0,1,0,1,0,1]
  PATT(29,*,2)=[1,1,1,1,1,1,1,1]
  PATT(29,*,3)=[0,1,0,1,0,1,0,1]
  PATT(29,*,4)=[1,1,1,1,1,1,1,1]
  PATT(29,*,5)=[0,1,0,1,0,1,0,1]
  PATT(29,*,6)=[1,1,1,1,1,1,1,1]
  PATT(29,*,7)=[0,1,0,1,0,1,0,1]
  PATT(30,*,0)=[1,1,1,1,1,1,1,0]
  PATT(30,*,1)=[0,1,1,1,1,1,0,1]
  PATT(30,*,2)=[1,0,1,1,1,0,1,1]
  PATT(30,*,3)=[1,1,0,1,0,1,1,1]
  PATT(30,*,4)=[1,1,1,0,1,1,1,1]
  PATT(30,*,5)=[1,1,0,1,0,1,1,1]
  PATT(30,*,6)=[1,0,1,1,1,0,1,1]
  PATT(30,*,7)=[0,1,1,1,1,1,0,1]
  PATT(31,*,0)=[1,1,1,0,1,1,1,0]
  PATT(31,*,1)=[1,1,0,1,1,1,0,1]
  PATT(31,*,2)=[1,0,1,1,1,0,1,1]
  PATT(31,*,3)=[0,1,1,1,0,1,1,1]
  PATT(31,*,4)=[1,1,1,0,1,1,1,0]
  PATT(31,*,5)=[1,1,0,1,1,1,0,1]
  PATT(31,*,6)=[1,0,1,1,1,0,1,1]
  PATT(31,*,7)=[0,1,1,1,0,1,1,1]
  PATT(32,*,0)=[1,1,1,1,1,1,1,1]
  PATT(32,*,1)=[0,1,0,1,0,1,0,1]
  PATT(32,*,2)=[1,1,1,1,1,1,1,1]
  PATT(32,*,3)=[0,1,0,1,0,1,0,1]
  PATT(32,*,4)=[1,1,1,1,1,1,1,1]
  PATT(32,*,5)=[0,1,0,1,0,1,0,1]
  PATT(32,*,6)=[1,1,1,1,1,1,1,1]
  PATT(32,*,7)=[0,1,0,1,0,1,0,1]
  PATT(33,*,0)=[1,1,1,1,1,1,1,1]
  PATT(33,*,1)=[1,1,0,0,1,1,0,0]
  PATT(33,*,2)=[1,1,1,1,1,1,1,1]
  PATT(33,*,3)=[0,0,1,1,0,0,1,1]
  PATT(33,*,4)=[1,1,1,1,1,1,1,1]
  PATT(33,*,5)=[1,1,0,0,1,1,0,0]
  PATT(33,*,6)=[1,1,1,1,1,1,1,1]
  PATT(33,*,7)=[0,0,1,1,0,0,1,1]
  PATT(34,*,0)=[1,1,1,1,1,1,1,1]
  PATT(34,*,1)=[1,1,1,1,1,1,1,1]
  PATT(34,*,2)=[1,1,1,1,1,1,1,1]
  PATT(34,*,3)=[0,0,0,0,0,0,0,0]
  PATT(34,*,4)=[1,1,1,1,1,1,1,1]
  PATT(34,*,5)=[1,1,1,1,1,1,1,1]
  PATT(34,*,6)=[1,1,1,1,1,1,1,1]
  PATT(34,*,7)=[0,0,0,0,0,0,0,0]
  PATT(35,*,0)=[0,1,1,1,0,1,1,1]
  PATT(35,*,1)=[0,1,1,1,0,1,1,1]
  PATT(35,*,2)=[0,1,1,1,0,1,1,1]
  PATT(35,*,3)=[0,1,1,1,0,1,1,1]
  PATT(35,*,4)=[0,1,1,1,0,1,1,1]
  PATT(35,*,5)=[0,1,1,1,0,1,1,1]
  PATT(35,*,6)=[0,1,1,1,0,1,1,1]
  PATT(35,*,7)=[0,1,1,1,0,1,1,1]
  PATT(36,*,0)=[1,1,1,1,1,1,1,1]
  PATT(36,*,1)=[0,1,0,1,0,1,0,1]
  PATT(36,*,2)=[1,1,1,1,1,1,1,1]
  PATT(36,*,3)=[0,1,0,1,0,1,0,1]
  PATT(36,*,4)=[1,1,1,1,1,1,1,1]
  PATT(36,*,5)=[0,1,0,1,0,1,0,1]
  PATT(36,*,6)=[1,0,1,1,1,1,1,1]
  PATT(36,*,7)=[0,1,0,1,0,1,0,1]
  PATT(37,*,0)=[1,1,1,1,1,1,1,1]
  PATT(37,*,1)=[0,1,0,1,0,1,0,1]
  PATT(37,*,2)=[1,1,1,1,1,0,1,1]
  PATT(37,*,3)=[0,1,0,1,0,1,0,1]
  PATT(37,*,4)=[1,1,1,1,1,1,1,1]
  PATT(37,*,5)=[0,1,0,1,0,1,0,1]
  PATT(37,*,6)=[1,0,1,1,1,1,1,1]
  PATT(37,*,7)=[0,1,0,1,0,1,0,1]
  PATT(38,*,0)=[1,1,1,1,1,1,1,1]
  PATT(38,*,1)=[0,1,0,1,0,1,0,1]
  PATT(38,*,2)=[1,0,1,1,1,0,1,1]
  PATT(38,*,3)=[0,1,0,1,0,1,0,1]
  PATT(38,*,4)=[1,1,1,1,1,1,1,1]
  PATT(38,*,5)=[0,1,0,1,0,1,0,1]
  PATT(38,*,6)=[1,0,1,1,1,0,1,1]
  PATT(38,*,7)=[0,1,0,1,0,1,0,1]
  PATT(39,*,0)=[1,1,1,1,1,1,1,1]
  PATT(39,*,1)=[0,1,0,1,0,1,0,1]
  PATT(39,*,2)=[1,0,1,1,1,0,1,1]
  PATT(39,*,3)=[0,1,0,1,0,1,0,1]
  PATT(39,*,4)=[1,1,1,0,1,1,1,1]
  PATT(39,*,5)=[0,1,0,1,0,1,0,1]
  PATT(39,*,6)=[1,0,1,1,1,0,1,1]
  PATT(39,*,7)=[0,1,0,1,0,1,0,1]
  PATT(40,*,0)=[1,1,1,1,1,1,1,0]
  PATT(40,*,1)=[0,1,0,1,0,1,0,1]
  PATT(40,*,2)=[1,0,1,1,1,0,1,1]
  PATT(40,*,3)=[0,1,0,1,0,1,0,1]
  PATT(40,*,4)=[1,1,1,0,1,1,1,1]
  PATT(40,*,5)=[0,1,0,1,0,1,0,1]
  PATT(40,*,6)=[1,0,1,1,1,0,1,1]
  PATT(40,*,7)=[0,1,0,1,0,1,0,1]
  PATT(41,*,0)=[1,1,1,1,0,1,1,1]
  PATT(41,*,1)=[1,1,1,1,0,1,1,1]
  PATT(41,*,2)=[1,1,1,1,0,1,1,1]
  PATT(41,*,3)=[0,0,0,0,0,0,0,0]
  PATT(41,*,4)=[0,1,1,1,1,1,1,1]
  PATT(41,*,5)=[0,1,1,1,1,1,1,1]
  PATT(41,*,6)=[0,1,1,1,1,1,1,1]
  PATT(41,*,7)=[0,0,0,0,0,0,0,0]
  PATT(42,*,0)=[1,1,1,1,1,1,1,0]
  PATT(42,*,1)=[0,1,0,1,0,1,0,1]
  PATT(42,*,2)=[1,0,1,1,1,0,1,1]
  PATT(42,*,3)=[0,1,0,1,0,1,0,1]
  PATT(42,*,4)=[1,1,1,0,1,1,1,0]
  PATT(42,*,5)=[0,1,0,1,0,1,0,1]
  PATT(42,*,6)=[1,0,1,1,1,0,1,1]
  PATT(42,*,7)=[0,1,0,1,0,1,0,1]
  PATT(43,*,0)=[1,1,0,1,1,1,0,1]
  PATT(43,*,1)=[1,1,0,0,1,1,0,0]
  PATT(43,*,2)=[0,1,1,1,0,1,1,1]
  PATT(43,*,3)=[0,0,1,1,0,0,1,1]
  PATT(43,*,4)=[1,1,0,1,1,1,0,1]
  PATT(43,*,5)=[1,1,0,0,1,1,0,0]
  PATT(43,*,6)=[0,1,1,1,0,1,1,1]
  PATT(43,*,7)=[0,0,1,1,0,0,1,1]
  PATT(44,*,0)=[1,1,1,0,1,1,1,0]
  PATT(44,*,1)=[0,1,0,1,0,1,0,1]
  PATT(44,*,2)=[1,0,1,1,1,0,1,1]
  PATT(44,*,3)=[0,1,0,1,0,1,0,1]
  PATT(44,*,4)=[1,1,1,0,1,1,1,0]
  PATT(44,*,5)=[0,1,0,1,0,1,0,1]
  PATT(44,*,6)=[1,0,1,1,1,0,1,1]
  PATT(44,*,7)=[0,1,0,1,0,1,0,1]
  PATT(45,*,0)=[1,1,1,0,1,1,1,0]
  PATT(45,*,1)=[0,1,0,1,0,1,0,1]
  PATT(45,*,2)=[1,0,1,1,1,0,1,1]
  PATT(45,*,3)=[0,1,0,1,0,1,0,1]
  PATT(45,*,4)=[1,1,1,0,1,1,1,0]
  PATT(45,*,5)=[0,1,0,1,0,1,0,1]
  PATT(45,*,6)=[1,0,1,0,1,0,1,1]
  PATT(45,*,7)=[0,1,0,1,0,1,0,1]
  PATT(46,*,0)=[1,1,1,0,1,1,1,0]
  PATT(46,*,1)=[0,1,0,1,0,1,0,1]
  PATT(46,*,2)=[1,0,1,1,1,0,1,0]
  PATT(46,*,3)=[0,1,0,1,0,1,0,1]
  PATT(46,*,4)=[1,1,1,0,1,1,1,0]
  PATT(46,*,5)=[0,1,0,1,0,1,0,1]
  PATT(46,*,6)=[1,0,1,0,1,0,1,1]
  PATT(46,*,7)=[0,1,0,1,0,1,0,1]
  PATT(47,*,0)=[1,1,1,0,1,1,1,0]
  PATT(47,*,1)=[0,1,0,1,0,1,0,1]
  PATT(47,*,2)=[1,0,1,0,1,0,1,0]
  PATT(47,*,3)=[0,1,0,1,0,1,0,1]
  PATT(47,*,4)=[1,1,1,0,1,1,1,0]
  PATT(47,*,5)=[0,1,0,1,0,1,0,1]
  PATT(47,*,6)=[1,0,1,0,1,0,1,1]
  PATT(47,*,7)=[0,1,0,1,0,1,0,1]
  PATT(48,*,0)=[1,1,1,0,1,1,1,0]
  PATT(48,*,1)=[0,1,0,1,0,1,0,1]
  PATT(48,*,2)=[1,0,1,0,1,0,1,0]
  PATT(48,*,3)=[0,1,0,1,0,1,0,1]
  PATT(48,*,4)=[1,1,1,0,1,1,1,0]
  PATT(48,*,5)=[0,1,0,1,0,1,0,1]
  PATT(48,*,6)=[1,0,1,0,1,0,1,0]
  PATT(48,*,7)=[0,1,0,1,0,1,0,1]
  PATT(49,*,0)=[1,1,1,0,1,1,1,0]
  PATT(49,*,1)=[0,1,0,1,0,1,0,1]
  PATT(49,*,2)=[1,0,1,0,1,0,1,0]
  PATT(49,*,3)=[0,1,0,1,0,1,0,1]
  PATT(49,*,4)=[1,0,1,0,1,1,1,0]
  PATT(49,*,5)=[0,1,0,1,0,1,0,1]
  PATT(49,*,6)=[1,0,1,0,1,0,1,0]
  PATT(49,*,7)=[0,1,0,1,0,1,0,1]
ok = WHERE(PATT EQ 1)
PATT(ok) = 255b

END

PRO PATT2,PATT
 PATT(50,*,0)=[1,1,1,0,1,0,1,0]
  PATT(50,*,1)=[0,1,0,1,0,1,0,1]
  PATT(50,*,2)=[1,0,1,0,1,0,1,0]
  PATT(50,*,3)=[0,1,0,1,0,1,0,1]
  PATT(50,*,4)=[1,0,1,0,1,0,1,0]
  PATT(50,*,5)=[0,1,0,1,0,1,0,1]
  PATT(50,*,6)=[1,0,1,0,1,0,1,0]
  PATT(50,*,7)=[0,1,0,1,0,1,0,1]
  PATT(51,*,0)=[1,0,1,0,1,0,1,0]
  PATT(51,*,1)=[0,1,0,1,0,1,0,1]
  PATT(51,*,2)=[1,0,1,0,1,0,1,0]
  PATT(51,*,3)=[0,1,0,1,0,1,0,1]
  PATT(51,*,4)=[1,0,1,0,1,0,1,0]
  PATT(51,*,5)=[0,1,0,1,0,1,0,1]
  PATT(51,*,6)=[1,0,1,0,1,0,1,0]
  PATT(51,*,7)=[0,1,0,1,0,1,0,1]
  PATT(52,*,0)=[1,1,1,0,1,1,1,0]
  PATT(52,*,1)=[0,1,0,0,0,1,0,0]
  PATT(52,*,2)=[1,0,1,1,1,0,1,1]
  PATT(52,*,3)=[0,0,0,1,0,0,0,1]
  PATT(52,*,4)=[1,1,1,0,1,1,1,0]
  PATT(52,*,5)=[0,1,0,0,0,1,0,0]
  PATT(52,*,6)=[1,0,1,1,1,0,1,1]
  PATT(52,*,7)=[0,0,0,1,0,0,0,1]
  PATT(53,*,0)=[1,1,0,0,1,1,0,0]
  PATT(53,*,1)=[1,1,0,0,1,1,0,0]
  PATT(53,*,2)=[0,0,1,1,0,0,1,1]
  PATT(53,*,3)=[0,0,1,1,0,0,1,1]
  PATT(53,*,4)=[1,1,0,0,1,1,0,0]
  PATT(53,*,5)=[1,1,0,0,1,1,0,0]
  PATT(53,*,6)=[0,0,1,1,0,0,1,1]
  PATT(53,*,7)=[0,0,1,1,0,0,1,1]
  PATT(54,*,0)=[1,0,1,0,1,0,1,0]
  PATT(54,*,1)=[0,1,0,0,0,1,0,0]
  PATT(54,*,2)=[1,0,1,1,1,0,1,1]
  PATT(54,*,3)=[0,0,0,1,0,0,0,1]
  PATT(54,*,4)=[1,0,1,0,1,0,1,0]
  PATT(54,*,5)=[0,1,0,0,0,1,0,0]
  PATT(54,*,6)=[1,0,1,1,1,0,1,1]
  PATT(54,*,7)=[0,0,0,1,0,0,0,1]
  PATT(55,*,0)=[1,1,1,1,1,1,1,1]
  PATT(55,*,1)=[0,0,0,0,0,0,0,0]
  PATT(55,*,2)=[1,0,1,1,1,0,1,1]
  PATT(55,*,3)=[0,0,0,0,0,0,0,0]
  PATT(55,*,4)=[1,1,1,1,1,1,1,1]
  PATT(55,*,5)=[0,0,0,0,0,0,0,0]
  PATT(55,*,6)=[1,0,1,1,1,0,1,1]
  PATT(55,*,7)=[0,0,0,0,0,0,0,0]
  PATT(56,*,0)=[1,1,1,1,1,1,0,1]
  PATT(56,*,1)=[0,0,0,0,0,0,0,0]
  PATT(56,*,2)=[0,1,1,1,0,1,1,1]
  PATT(56,*,3)=[0,0,0,0,0,0,0,0]
  PATT(56,*,4)=[1,1,0,1,1,1,1,1]
  PATT(56,*,5)=[0,0,0,0,0,0,0,0]
  PATT(56,*,6)=[0,1,1,1,0,1,1,1]
  PATT(56,*,7)=[0,0,0,0,0,0,0,0]
  PATT(57,*,0)=[1,1,0,0,1,1,0,0]
  PATT(57,*,1)=[0,1,0,0,0,1,0,0]
  PATT(57,*,2)=[0,0,1,1,0,0,1,1]
  PATT(57,*,3)=[0,0,0,1,0,0,0,1]
  PATT(57,*,4)=[1,1,0,0,1,1,0,0]
  PATT(57,*,5)=[0,1,0,0,0,1,0,0]
  PATT(57,*,6)=[0,0,1,1,0,0,1,1]
  PATT(57,*,7)=[0,0,0,1,0,0,0,1]
  PATT(58,*,0)=[1,0,1,0,1,0,1,0]
  PATT(58,*,1)=[0,1,0,0,0,1,0,0]
  PATT(58,*,2)=[1,0,1,0,1,0,1,0]
  PATT(58,*,3)=[0,0,0,1,0,0,0,1]
  PATT(58,*,4)=[1,0,1,0,1,0,1,0]
  PATT(58,*,5)=[0,1,0,0,0,1,0,0]
  PATT(58,*,6)=[1,0,1,0,1,0,1,0]
  PATT(58,*,7)=[0,0,0,1,0,0,0,1]
  PATT(59,*,0)=[1,1,1,0,1,1,1,0]
  PATT(59,*,1)=[0,0,0,0,0,0,0,0]
  PATT(59,*,2)=[1,0,1,1,1,0,1,1]
  PATT(59,*,3)=[0,0,0,0,0,0,0,0]
  PATT(59,*,4)=[1,1,1,0,1,1,1,0]
  PATT(59,*,5)=[0,0,0,0,0,0,0,0]
  PATT(59,*,6)=[1,0,1,1,1,0,1,1]
  PATT(59,*,7)=[0,0,0,0,0,0,0,0]
  PATT(60,*,0)=[1,0,1,0,1,0,1,0]
  PATT(60,*,1)=[0,1,0,0,0,0,0,0]
  PATT(60,*,2)=[1,0,1,0,1,0,1,0]
  PATT(60,*,3)=[0,0,0,1,0,0,0,1]
  PATT(60,*,4)=[1,0,1,0,1,0,1,0]
  PATT(60,*,5)=[0,0,0,0,0,1,0,0]
  PATT(60,*,6)=[1,0,1,0,1,0,1,0]
  PATT(60,*,7)=[0,0,0,1,0,0,0,1]
  PATT(61,*,0)=[1,1,0,1,1,1,0,1]
  PATT(61,*,1)=[0,0,0,0,0,0,0,0]
  PATT(61,*,2)=[0,0,1,1,0,0,1,1]
  PATT(61,*,3)=[0,0,0,0,0,0,0,0]
  PATT(61,*,4)=[1,1,0,1,1,1,0,1]
  PATT(61,*,5)=[0,0,0,0,0,0,0,0]
  PATT(61,*,6)=[0,0,1,1,0,0,1,1]
  PATT(61,*,7)=[0,0,0,0,0,0,0,0]
  PATT(62,*,0)=[1,0,1,0,1,0,1,0]
  PATT(62,*,1)=[0,0,0,0,0,0,0,0]
  PATT(62,*,2)=[1,0,1,0,1,0,1,0]
  PATT(62,*,3)=[0,0,0,0,0,0,0,0]
  PATT(62,*,4)=[1,0,1,0,1,0,1,0]
  PATT(62,*,5)=[0,0,0,0,0,0,0,0]
  PATT(62,*,6)=[1,0,1,0,1,0,1,0]
  PATT(62,*,7)=[0,0,0,0,0,0,0,0]
  PATT(63,*,0)=[1,1,0,0,1,1,0,0]
  PATT(63,*,1)=[0,0,0,0,0,0,0,0]
  PATT(63,*,2)=[0,0,1,1,0,0,1,1]
  PATT(63,*,3)=[0,0,0,0,0,0,0,0]
  PATT(63,*,4)=[1,1,0,0,1,1,0,0]
  PATT(63,*,5)=[0,0,0,0,0,0,0,0]
  PATT(63,*,6)=[0,0,1,1,0,0,1,1]
  PATT(63,*,7)=[0,0,0,0,0,0,0,0]
  PATT(64,*,0)=[1,1,0,0,1,1,0,0]
  PATT(64,*,1)=[1,1,0,0,1,1,0,0]
  PATT(64,*,2)=[0,0,0,0,0,0,0,0]
  PATT(64,*,3)=[0,0,0,0,0,0,0,0]
  PATT(64,*,4)=[1,1,0,0,1,1,0,0]
  PATT(64,*,5)=[1,1,0,0,1,1,0,0]
  PATT(64,*,6)=[0,0,0,0,0,0,0,0]
  PATT(64,*,7)=[0,0,0,0,0,0,0,0]
  PATT(65,*,0)=[1,1,0,0,1,1,0,0]
  PATT(65,*,1)=[0,0,0,0,0,0,0,0]
  PATT(65,*,2)=[0,0,1,1,0,0,0,0]
  PATT(65,*,3)=[0,0,0,0,0,0,0,0]
  PATT(65,*,4)=[1,1,0,0,1,1,0,0]
  PATT(65,*,5)=[0,0,0,0,0,0,0,0]
  PATT(65,*,6)=[0,0,0,0,0,0,1,1]
  PATT(65,*,7)=[0,0,0,0,0,0,0,0]
  PATT(66,*,0)=[0,0,1,0,0,0,1,0]
  PATT(66,*,1)=[0,0,0,0,0,0,0,0]
  PATT(66,*,2)=[1,0,0,0,1,0,0,0]
  PATT(66,*,3)=[0,0,0,0,0,0,0,0]
  PATT(66,*,4)=[0,0,1,0,0,0,1,0]
  PATT(66,*,5)=[0,0,0,0,0,0,0,0]
  PATT(66,*,6)=[1,0,0,0,1,0,0,0]
  PATT(66,*,7)=[0,0,0,0,0,0,0,0]
  PATT(67,*,0)=[1,1,0,0,1,1,0,0]
  PATT(67,*,1)=[0,0,0,0,0,0,0,0]
  PATT(67,*,2)=[0,0,0,0,0,0,0,0]
  PATT(67,*,3)=[0,0,0,0,0,0,0,0]
  PATT(67,*,4)=[1,1,0,0,1,1,0,0]
  PATT(67,*,5)=[0,0,0,0,0,0,0,0]
  PATT(67,*,6)=[0,0,0,0,0,0,0,0]
  PATT(67,*,7)=[0,0,0,0,0,0,0,0]
  PATT(68,*,0)=[0,0,0,0,1,1,0,0]
  PATT(68,*,1)=[0,0,0,0,1,1,0,0]
  PATT(68,*,2)=[0,0,0,0,0,0,0,0]
  PATT(68,*,3)=[0,0,0,0,0,0,0,0]
  PATT(68,*,4)=[1,1,0,0,0,0,0,0]
  PATT(68,*,5)=[1,1,0,0,0,0,0,0]
  PATT(68,*,6)=[0,0,0,0,0,0,0,0]
  PATT(68,*,7)=[0,0,0,0,0,0,0,0]
  PATT(69,*,0)=[0,0,0,0,1,1,0,0]
  PATT(69,*,1)=[0,0,0,0,0,0,0,0]
  PATT(69,*,2)=[0,0,0,0,0,0,0,0]
  PATT(69,*,3)=[0,0,0,0,0,0,0,0]
  PATT(69,*,4)=[1,1,0,0,0,0,0,0]
  PATT(69,*,5)=[0,0,0,0,0,0,0,0]
  PATT(69,*,6)=[0,0,0,0,0,0,0,0]
  PATT(69,*,7)=[0,0,0,0,0,0,0,0]
  PATT(70,*,0)=[0,0,0,0,0,0,0,0]
  PATT(70,*,1)=[0,0,0,0,0,0,0,0]
  PATT(70,*,2)=[1,0,0,0,1,0,0,0]
  PATT(70,*,3)=[0,0,0,0,0,0,0,0]
  PATT(70,*,4)=[0,0,0,0,0,0,0,0]
  PATT(70,*,5)=[0,0,0,0,0,0,0,0]
  PATT(70,*,6)=[1,0,0,0,1,0,0,0]
  PATT(70,*,7)=[0,0,0,0,0,0,0,0]
  PATT(71,*,0)=[0,0,0,0,0,0,0,0]
  PATT(71,*,1)=[0,0,0,0,0,0,0,0]
  PATT(71,*,2)=[0,0,0,0,1,0,0,0]
  PATT(71,*,3)=[0,0,0,0,0,0,0,0]
  PATT(71,*,4)=[0,0,0,0,0,0,0,0]
  PATT(71,*,5)=[0,0,0,0,0,0,0,0]
  PATT(71,*,6)=[1,0,0,0,0,0,0,0]
  PATT(71,*,7)=[0,0,0,0,0,0,0,0]
  PATT(72,*,0)=[1,1,1,0,1,1,1,0]
  PATT(72,*,1)=[0,1,0,0,0,1,0,0]
  PATT(72,*,2)=[1,0,1,1,1,0,1,0]
  PATT(72,*,3)=[0,0,0,1,0,0,0,1]
  PATT(72,*,4)=[1,1,1,0,1,1,1,0]
  PATT(72,*,5)=[0,1,0,0,0,1,0,0]
  PATT(72,*,6)=[1,0,1,0,1,0,1,1]
  PATT(72,*,7)=[0,0,0,1,0,0,0,1]
  PATT(73,*,0)=[1,1,0,0,1,1,0,0]
  PATT(73,*,1)=[0,0,0,0,0,0,0,0]
  PATT(73,*,2)=[0,0,1,1,0,0,1,1]
  PATT(73,*,3)=[0,0,0,0,0,0,0,0]
  PATT(73,*,4)=[1,1,0,0,1,1,0,0]
  PATT(73,*,5)=[0,0,0,0,0,0,0,0]
  PATT(73,*,6)=[0,0,0,0,0,0,1,1]
  PATT(73,*,7)=[0,0,0,0,0,0,0,0]
  PATT(74,*,0)=[1,1,1,0,1,1,1,0]
  PATT(74,*,1)=[0,1,0,1,0,1,0,1]
  PATT(74,*,2)=[1,0,1,1,1,0,1,1]
  PATT(74,*,3)=[0,1,0,1,0,0,0,1]
  PATT(74,*,4)=[1,1,1,0,1,1,1,0]
  PATT(74,*,5)=[0,1,0,1,0,1,0,1]
  PATT(74,*,6)=[1,0,1,1,1,0,1,1]
  PATT(74,*,7)=[0,0,0,1,0,1,0,1]
  PATT(75,*,0)=[1,1,1,0,1,1,1,0]
  PATT(75,*,1)=[0,0,0,0,0,0,0,0]
  PATT(75,*,2)=[1,0,1,1,0,0,1,1]
  PATT(75,*,3)=[0,0,0,0,0,0,0,0]
  PATT(75,*,4)=[1,1,1,0,1,1,1,0]
  PATT(75,*,5)=[0,0,0,0,0,0,0,0]
  PATT(75,*,6)=[0,0,1,1,1,0,1,1]
  PATT(75,*,7)=[0,0,0,0,0,0,0,0]
  PATT(76,*,0)=[1,1,1,0,1,1,1,0]
  PATT(76,*,1)=[0,1,0,1,0,1,0,0]
  PATT(76,*,2)=[1,0,1,1,1,0,1,1]
  PATT(76,*,3)=[0,0,0,1,0,0,0,1]
  PATT(76,*,4)=[1,1,1,0,1,1,1,0]
  PATT(76,*,5)=[0,1,0,0,0,1,0,0]
  PATT(76,*,6)=[1,0,1,1,1,0,1,1]
  PATT(76,*,7)=[0,0,0,1,0,0,0,1]
  PATT(77,*,0)=[1,1,1,0,1,1,1,0]
  PATT(77,*,1)=[0,1,0,0,0,1,0,0]
  PATT(77,*,2)=[1,0,1,1,1,0,1,1]
  PATT(77,*,3)=[0,0,0,1,0,0,0,0]
  PATT(77,*,4)=[1,1,1,0,1,1,1,0]
  PATT(77,*,5)=[0,1,0,0,0,1,0,0]
  PATT(77,*,6)=[1,0,1,1,1,0,1,1]
  PATT(77,*,7)=[0,0,0,0,0,0,0,1]
  PATT(78,*,0)=[1,1,1,0,1,1,1,0]
  PATT(78,*,1)=[0,0,0,0,0,0,0,0]
  PATT(78,*,2)=[1,0,1,1,0,0,1,1]
  PATT(78,*,3)=[0,0,0,0,0,0,0,0]
  PATT(78,*,4)=[1,1,1,0,1,1,1,0]
  PATT(78,*,5)=[0,0,0,0,0,0,0,0]
  PATT(78,*,6)=[0,0,1,1,1,0,1,1]
  PATT(78,*,7)=[0,0,0,0,0,0,0,0]
  PATT(79,*,0)=[1,1,0,0,1,1,0,0]
  PATT(79,*,1)=[0,0,0,0,0,0,0,0]
  PATT(79,*,2)=[0,0,1,1,0,0,0,1]
  PATT(79,*,3)=[0,0,0,0,0,0,0,0]
  PATT(79,*,4)=[1,1,0,0,1,1,0,0]
  PATT(79,*,5)=[0,0,0,0,0,0,0,0]
  PATT(79,*,6)=[0,0,0,1,0,0,1,1]
  PATT(79,*,7)=[0,0,0,0,0,0,0,0]

ok = WHERE(PATT EQ 1)
PATT(ok) = 255b

END

; ===================>

PRO dither, FILES=files, COMMAND_FILE=command_file,$
            INPUT_TYPE=input_type,no_bw=NO_BW,$
            resolution=RESOLUTION,$
            HELP_FILE=help_file,QUIET=quiet,SAMPLE=sample


  IF KEYWORD_SET(QUIET) EQ 0 THEN BEGIN
    PRINT, ' PROGRAM DITHER:  Reads a 256-COLOR PCX, BMP or PNG image file'
    PRINT, ' and Outputs a Shaded (Dithered)'
    PRINT, ' PNG Image File'
    PRINT, ' Version:  February 23,1996 '
  ENDIF

; ====================>
; Check keyword RESOLUTION

  IF KEYWORD_SET(RESOLUTION) THEN BEGIN
    IF resolution GE 8 AND resolution LE 24 THEN res = resolution
  ENDIF ELSE BEGIN
    res = 16
  ENDELSE

  IF res EQ 8 OR RES EQ 16 THEN BEGIN
    patt1,patt
    patt2,patt
    patt = REBIN(PATT,256,res,res,/SAMPLE)
  ENDIF

  IF res EQ 12 OR RES EQ 24 THEN BEGIN
    patt12,patt
    patt = REBIN(PATT,256,res,res,/SAMPLE)
  ENDIF

; =====================>
  ccolor= INDGEN(256)

; ====================>
; Generate help file of example commands (colr and patt)
  IF KEYWORD_SET(help_file) THEN BEGIN
    IF STRMID(help_file,0,1) EQ ' ' THEN hlpfile = 'dither.hlp' $
       ELSE hlpfile = help_file

    OPENW,_helpfile,hlpfile,/GET_LUN
    PRINT,  ' Program is Creating a Help File : ', hlpfile

    printf,_helpfile, ' DITHER PROGRAM IGNORES ALL INPUT LINES WHICH'
    printf,_helpfile, ' DO NOT BEGIN WITH THE COMMANDS:  PATT  OR  COLR '
    printf,_helpfile, ' THESE TWO COMMANDS MUST BEGIN IN COLUMN 1'
    printf,_helpfile, ' AND THE PARAMETERS MUST BEGIN AT OR AFTER COLUMN 5'
    printf,_helpfile, ' AND MUST ALWAYS BE FOLLOWED BY  COMMAS '
    printf,_helpfile
    printf,_helpfile, ' EXAMPLES OF APPROPRIATE INPUT COLR COMMANDS : '
    printf,_helpfile, 'COLR 12,12,40,'
    printf,_helpfile, ' THIS WOULD TRANSFORM ANY PIXELS WITH COLOR# 12'
    printf,_helpfile, ' INTO SHADE PATTERN# 40'
    printf,_helpfile
    printf,_helpfile, 'COLR 12,16,42,'
    printf,_helpfile, ' THIS WOULD TRANSFORM ANY PIXELS WITH COLORS FROM '
    printf,_helpfile, ' 12 THROUGH 16 INTO SHADE PATTERN# 42'
    printf,_helpfile
    printf,_helpfile, ' THE FOLLOWING GIVES APPROPRIATE INPUT PATT COMMANDS'
    printf,_helpfile, ' AND THE PARAMETER CODE FOR AVAILABLE SHADE PATTERNS:'
    printf,_helpfile, ' YOU CAN EDIT THIS FILE AND CREATE YOUR OWN PATTERNS'
    printf,_helpfile, ' AND SUBMIT THE NEW FILE AS INPUT TO DITHER'

    FOR _pattern = 0,255 DO BEGIN
      FOR _row = 0,7 DO BEGIN
        PRINTF,_helpfile,_pattern,_row,PATT(_pattern,_row,*) ,FORMAT=' ("PATT(",I3,",",I3,",*)=[",8I3,"]")
      ENDFOR
    ENDFOR
    CLOSE,_helpfile
    FREE_LUN,_helpfile
  GOTO, DONE
  ENDIF ; IF KEYWORD_SET(help_file) THEN BEGIN

; ====================>
  IF KEYWORD_SET(sample) THEN BEGIN
    IF STRMID(sample,0,1) EQ ' ' THEN PNG_file = 'dither.PNG' ELSE PNG_file = sample
  ; colorbox,box=[64,128],PNG_file=PNG_file
    colorbox,box=[32,32],PNG_file=PNG_file


    files = PNG_file
    PRINT, 'Generating file : ' , PNG_file
    GOTO,DITHERIT

  ENDIF
; ====================>
; Get names of image files and the name of the command file

; Check if user supplied an image file name or file names with wildcard (*)
  IF N_ELEMENTS(files) GE 1 THEN BEGIN
    IF n_ELEMENTS(FILES) NE 1 THEN $
    files = filelist(files,/sort)
   ENDIF ELSE BEGIN
    files = PICKFILE(/READ, TITLE='Select a PCX, BMP, or PNG Image',/MUST_EXIST)
   ENDELSE


; ====================>
; Check if user supplied a command file name
  IF KEYWORD_SET(command_file)NE 0 THEN BEGIN
    cmdfile = command_file
   ENDIF ELSE BEGIN
    cmdfile = PICKFILE(/READ, TITLE='Select a Command File (containing COLR or PATT commands)',/MUST_EXIST)
   ENDELSE

; ====================>
; Read commands from command file
  OPENR,_cmdfile,cmdfile,/GET_LUN
  intext = ' ' & txt = ' ' & par1 = 0 & par2 = 0 & par3 = 0

; Initialize ccolor(#)
; If the command colr is encountered in the program input parameter


  WHILE NOT EOF(_cmdfile) DO BEGIN
    READF,_cmdfile,intext

    intext = STRTRIM(STRUPCASE(intext),2)
    cmd = STRMID(intext,0,4)
    IF cmd EQ 'COLR' THEN BEGIN
      READS,intext,txt,par1,par2,par3,FORMAT='(A4,3i) '
      IF    PAR1 GE 0 AND PAR1 LE 255 $
        AND PAR2 GE 0 AND PAR2 LE 255 $
        AND PAR3 GE 0 AND PAR3 LE 255 THEN $
        ccolor(par1:par2) = par3
    ENDIF

    IF(cmd EQ 'PATT') THEN a = EXECUTE(intext)
  ENDWHILE
  CLOSE,_cmdfile
  FREE_LUN,_cmdfile


; ====================>
; ====================>
; Process each image file
  DITHERIT:
  FOR _files = 0,N_ELEMENTS(files)-1 DO BEGIN
    imgfile = files(_files)
    fname = PARSE_IT(imgfile)
    extension = STRUPCASE(fname.ext)
    IF extension EQ 'DIT' OR extension EQ 'DITHER' THEN GOTO, SKIP
    IF KEYWORD_SET(input_type) THEN extension = STRUPCASE(input_type)

		IF extension EQ 'PNG' THEN IMAGE=READ_PNG(imgfile,r,g,b)
    IF extension EQ 'PCX' THEN READ_PCX,imgfile,image,r,g,b
    IF extension EQ 'BMP' THEN READ_BMP,imgfile,image,r,g,b

;   ====================>
;   Determine width and height of image
    S = SIZE(image)
    PX = S[1]
    PY = S(2)

;   ====================>
;   Substitute 1's or 0's or new color # for original color in image

;  image(*,*)= patt( ccolor(image(*,*)), $
;              (replicate(1,px) # (indgen(py) MOD res)),$
;              ((indgen(px) MOD res) # replicate(1,py)) )


  _X= BYTE((indgen(px) MOD res) # replicate(1,py))
  _Y= BYTE(replicate(1,px) # (indgen(py) MOD res))
  image(*,*)= patt( ccolor(TEMPORARY(image(*,*))), _X,_Y)

; ====================>
; Write output PNG graphics file
    afile = fname.dir+fname.name+'_dither.png'
    IF KEYWORD_SET(QUIET) EQ 0 THEN  PRINT, 'Generating file : ' , afile
    WRITE_PNG,afile,IMAGE,R,G,B

  IMAGE=''
  SKIP:
  ENDFOR ; FOR EACH FILE

  DONE:
END


