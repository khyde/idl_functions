; $ID:	IMAGE_HISTOGRAM.PRO,	2020-06-30-17,	USER-KJWH	$

 PRO IMAGE_HISTOGRAM, FILES , OUTFILE = OUTFILE, QUIET=quiet, STRUCT=struct
; NAME:
;       IMAGE_HISTOGRAM
;
; PURPOSE:
;				Compute histograms for a series of binary image files
;

;
; INPUTS:
;       FILES : Image Files (png,gif, save)
;
; KEYWORD PARAMETERS:

;       OUTFILE			The name of an output file (default is IMAGE_HISTOGRAMs1.lon
;       QUIET				Prevents printing of program progress
;				STRUCT			Output structure with file_name and histogram results
;
;
; OUTPUTS:
;      A CSV file containing the FIRST_NAME of the file and and histogram frequency statistics for each image
;      and for each subarea (color) if a mask_file is provided.

; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, September 12, 1997
;       Modified (from IMAGE_STATS) J.O'R December 14, 2005
;				Revamped, jor Feb 6, 2006; csv output
;-

; ===> Define counters for the number of valid images processed
  images_processed = 0L


	N_FILES = N_ELEMENTS(FILES)
  IF N_FILES EQ 0 THEN BEGIN
    files = PICKFILE(TITLE='Pick an Image File')
  ENDIF ELSE BEGIN
    files = FILELIST(files,/sort)
    IF KEYWORD_SET(START) THEN files = files(start:*)
  ENDELSE

; ===> If no output file name provided then output ='IMAGE_HISTOGRAM.CSV'
  IF N_ELEMENTS(OUTFILE) LT 1 THEN OUTFILE ='IMAGE_HISTOGRAM.CSV'

; ===> Define a structure to hold histogram resuslts
	STRUCT= REPLICATE(CREATE_STRUCT('NAME','',ARR_2STRUCT(LINDGEN(256),TAGNAMES=SINDGEN(256))),N_FILES)


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR nth = 0L, N_FILES -1L DO BEGIN
    afile = files(nth)
;   ===> Parse file name to extract image name
    FN = PARSE_IT(afile)
    STRUCT[NTH].NAME = FN.FIRST_NAME
    IF NOT KEYWORD_SET(QUIET) THEN PRINT, FN.FIRST_NAME
    image = READALL(afile,/quiet,TYPE=type)
;
;   ===> If READALL CAN NOT READ THE FILE THEN SKIP IT
    IF image(0,0) EQ -1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>

    images_processed = images_processed +1L

    H = HISTOGRAM(image,MIN=0,MAX=255)
    FOR BIN=0,255 DO STRUCT[NTH].(BIN+1) = H(BIN)

  ENDFOR ; FOR nth = 0, N_ELEMENTS(files) -1 DO BEGIN

	STRUCT_2CSV,OUTFILE,STRUCT

; ====================>
; Print program statistics
  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    PRINT, ''
    PRINT, ' IMAGE_HISTOGRAM IS DONE >>>>>>>>>>>>>>>>>>>>'
    PRINT, ' IMAGES PROCESSED: ', images_processed
    PRINT, ' WRITTEN TO FILE : ',  OUTFILE
  ENDIF

; ************************************************************
  END  ; END OF PROGRAAM
; ************************************************************
