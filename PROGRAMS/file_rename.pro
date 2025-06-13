; $ID:	FILE_RENAME.PRO,	2020-07-08-15,	USER-KJWH	$
PRO FILE_RENAME, FILES, $
                 NAME_CHANGE=name_change,$
                 NAME_PREFIX=name_prefix, NAME_ADD = name_add,$
                 EXT_ADD = ext_add, $
                 EXT_REMOVE=ext_remove,$
                 EXT_NEW = ext_new, $
                 LOWER=lower, UPPER=upper,$
                 LOW_EXT = LOW_EXT,UP_EXT=up_ext,$
                 QUIET=quiet,TEST=test
;+
; NAME:
;       FILE_RENAME
;
; PURPOSE:
;       Rename A FILE TO ANOTHER NAME (Works under Windows using the SPAWN and RENAME command
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       files = filelist('e:\avhrr\ts_images\browse\*SST*.PNG')
;       file_rename,files[0],name_change=['-4avi.PNG','-AVHRR-CW_CD-NEC-SST-INTERP-TS_IMAGES-4avi.PNG'],/TEST
;       FILES=FILELIST('I:\SEAWIFS_L3B9\TS_IMAGES\PSTATS\!DD_*')
;       file_rename,files,name_change=['19970921000000_20050725000000-','19970921_20050725-']
;       files = filelist('e:\avhrr\ts_images\browse\*SST*.PNG')
;				file_rename,files[0],name_change=['TS_IMAGES-AVHRR-CW_CD-NEC-SST-INTERP-!D','!D'],/TEST
;
; INPUTS:
;       FILES
;
; OUTPUTS:
;       Renames Files
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Oct, 1995.
;				Nov 13, 2005 Rewrote JOR
;				Apr 15, 2011 D.W. Moonan Modified to be working on Linux or Windows.
;-

; ====================>
; Check if file names were provided.
; If not, then program prompts for file names.
  IF N_ELEMENTS(FILES) LT 1 THEN BEGIN
    files = ''
    READ,FILES,PROMPT='Enter Names of files'
  ENDIF

; ===> Check the path separator
	FILES = FIX_PATH(FILES) 

  OK=WHERE(FILE_TEST(FILES) EQ 1,COUNT)
  IF COUNT GE 1 THEN BEGIN
  	FILES = FILES[OK]
  ENDIF ELSE BEGIN
  	PRINT,'ERROR: NO FILES FOUND'
  	GOTO, DONE
  ENDELSE

  F_IN = FILE_PARSE(FILES)

	IF N_ELEMENTS(name_prefix) LT 1 	THEN  _NAME_prefix='' 				ELSE 	_NAME_prefix = NAME_prefix
  IF N_ELEMENTS(name_add) LT 1 			THEN  _NAME_ADD=''						ELSE	_NAME_ADD = NAME_ADD
  IF N_ELEMENTS(ext_add) LT 1 			THEN	_ext_add=''							ELSE	_ext_add = ext_add
  IF N_ELEMENTS(NAME_CHANGE) NE 2 	THEN	_NAME_CHANGE = ['','']	ELSE  _NAME_CHANGE = NAME_CHANGE

;	===> Make a new name equal to old
	NEW = F_IN.DIR + F_IN.name+F_IN.ext_delim+F_IN.ext

;	===> Reparse NEW
	F_OUT = FILE_PARSE(NEW)

	IF KEYWORD_SET(NAME_CHANGE) 		THEN F_OUT.name = REPLACE(F_OUT.name,_name_change[0],_name_change[1])
	IF KEYWORD_SET(NAME_PREFIX) 		THEN F_OUT.name = _name_prefix+ F_OUT.name
	IF KEYWORD_SET(NAME_ADD) 				THEN F_OUT.name = F_OUT.name+REPLICATE(_name_add,N_ELEMENTS(F_OUT))
	IF KEYWORD_SET(EXT_ADD) 				THEN F_OUT.ext  = F_OUT.ext + _ext_add
	IF N_ELEMENTS(EXT_NEW) EQ 1 		THEN F_OUT.ext  = ext_new
	IF N_ELEMENTS(EXT_REMOVE) EQ 1 	THEN F_OUT.ext  = ''


	IF N_ELEMENTS(LOWER) 		EQ 1 THEN 	BEGIN
		F_OUT.name 	= STRLOWCASE(F_OUT.name)
		F_OUT.ext 	= STRLOWCASE(F_OUT.ext)
	ENDIF

	IF N_ELEMENTS(UPPER) 		EQ 1 THEN 	BEGIN
		F_OUT.name 	= STRUPCASE(F_OUT.name)
		F_OUT.ext 	= STRUPCASE(F_OUT.ext)
	ENDIF

;	===> Change extension after upper and lower changes to name
	IF N_ELEMENTS(LOW_EXT) 	EQ 1 THEN 	F_OUT.ext = STRLOWCASE(F_OUT.ext)
	IF N_ELEMENTS(UP_EXT) 	EQ 1 THEN 	F_OUT.ext = STRUPCASE(F_OUT.ext)

 	NEW_FILE = F_IN[0].DIR + F_OUT.NAME+F_OUT.EXT_DELIM+F_OUT.EXT
 	NEW_NAME = F_OUT.NAME+F_OUT.EXT_DELIM+F_OUT.EXT
  ;NEW = F_IN[0].DIR + SLASH + F_OUT
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
	  CMD = 'echo ' + F_IN[NTH].FULLNAME + ' Unkown OS...'
	  IF !VERSION.OS_FAMILY eq 'unix' THEN BEGIN
       CMD = 'mv -f ' + F_IN[NTH].FULLNAME + ' ' + NEW_FILE[NTH]
    ENDIF
    IF !VERSION.OS_FAMILY eq 'Windows' THEN BEGIN
       CMD='RENAME '+ F_IN[NTH].FULLNAME + ' ' + NEW_NAME[NTH]
    ENDIF

		IF NOT KEYWORD_SET(TEST) THEN BEGIN
		; NOTE THAT /OVERWRITE IS SLOW
	;    FILE_MOVE, FN.FULLNAME, NEW, /ALLOW_SAME,/VERBOSE,/NOEXPAND_PATH,/OVERWRITE

	     IF NOT KEYWORD_SET(QUIET) THEN PRINT,CMD
	     SPAWN,CMD,RESULT,ERROR
	     IF N_ELEMENTS(ERROR) GE 1 THEN IF ERROR[0] NE '' THEN PRINT,'ERROR: '+ ERROR

	  ENDIF ELSE BEGIN
	     TXT = F_IN[NTH].FULLNAME + ' TO: ' + NEW[NTH]
	     PRINT, TXT
	     PRINT, 'Command would be : '
	     PRINT, CMD
	  ENDELSE
	ENDFOR

	DONE:
END; #####################  End of Routine ################################
