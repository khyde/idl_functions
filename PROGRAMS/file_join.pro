; $ID:	FILE_JOIN.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program JOINS several files Previously SPLIT using FILE_SPLIT.PRO

; HISTORY:
;		Sept 24, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO FILE_JOIN,FILES,DIR_OUT=dir_out,QUIET=quiet
  ROUTINE_NAME='FILE_JOIN'

	FILES = FILELIST(FILES)
	FN = PARSE_IT(FILES)
  IF N_ELEMENTS(DIR_OUT) EQ 1 THEN _DIR_OUT = DIR_OUT ELSE _DIR_OUT = FN[0].DIR

	NAMES = FN.NAME+FN.EXT_DELIM+FN.EXT
	NAMES = STRTRIM(NAMES,2)
	N=N_ELEMENTS(NAMES)

	START = LONARR(1,N)
	WIDTH = LONARR(1,N)

; ===> Find the positions of $
  POS_DOLLAR = STRPOS(NAMES,'$')
  OK_DOLLAR 	= WHERE(POS_DOLLAR GE 0,COUNT_DOLLAR)
  IF COUNT_DOLLAR NE N THEN GOTO, DONE ; >>>>>>>>>>>>>>>>>>>>>>>

; ===>
  START(0,*) = 0
  WIDTH(0,*) = POS_DOLLAR
  NAMES_ORIGINAL = STRMID(NAMES,START,WIDTH)
  N_OF_N   = STRMID(NAMES,WIDTH+1)
  PRINT, NAMES_ORIGINAL
  PRINT, N_OF_N
  OK = WHERE(NAMES_ORIGINAL EQ NAMES_ORIGINAL[0],COUNT)
  IF COUNT NE N THEN GOTO, DONE  ; >>>>>>>>>>>>>>>>>>



  FILE_ORIGINAL = _DIR_OUT+ NAMES_ORIGINAL[0]
  PRINT, FILE_ORIGINAL

; ===> Find the positions of '_'
  POS_UL = STRPOS(N_OF_N,'_')
  OK_UL 	= WHERE(POS_UL GE 0,COUNT_UL)
  IF COUNT_UL NE N THEN GOTO, DONE ; >>>>>>>>>>>>>>>>>>>>>>>

  START(0,*) = 0
  WIDTH(0,*) = POS_UL
  SEQUENCE = STRMID(N_OF_N,START,WIDTH)
  NUM_OF   = STRMID(N_OF_N,WIDTH+1)
  PRINT, SEQUENCE
  PRINT, NUM_OF

	OK = WHERE(NUM_OF EQ NUM_OF[0],COUNT)
  IF COUNT NE N THEN GOTO, DONE  ; >>>>>>>>>>>>>>>>>>


  SRT=SORT(LONG(SEQUENCE))
  FILES = FILES(SRT)


; ===> Check if file_original exists (IF so then add 'COPY_' TO NAME
  FI = FILE_INFO(FILE_ORIGINAL)
  IF FI.EXISTS EQ 1 THEN SUFFIX = '-COPY' ELSE SUFFIX = ''

  OUTNAME =  FILE_ORIGINAL + SUFFIX



	OPENW,LUN_OUT,OUTNAME,/GET_LUN
  COUNT = 0UL

;	===> Concatenate files into original
  FOR _FILE = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
  	AFILE = FILES(_FILE)
    OPENR,LUN_IN,AFILE,/GET_LUN
    COPY_LUN, LUN_IN, LUN_OUT, /EOF, TRANSFER_COUNT=TRANSFER_COUNT
    COUNT = COUNT + TRANSFER_COUNT

		IF NOT KEYWORD_SET(QUIET) THEN PRINT, 'Copying '+afile+' into '+outname
		CLOSE,LUN_IN
		FREE_LUN,LUN_IN

  ENDFOR
  CLOSE,LUN_OUT
	FREE_LUN,LUN_OUT



	DONE:
END; #####################  End of Routine ################################
