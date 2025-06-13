; $ID:	IDLZIP.PRO,	2020-06-30-17,	USER-KJWH	$

 PRO IDLZIP,QUIET=quiet
;+
; NAME:
;       IDLZIP
;
; PURPOSE:
;       Automatically zip all relevant idl programs
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       IDLZIP
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-

  IDL_PATH='C:\IDL\'
  COPY_DIR = 'C:\IDL\ZIP\'

  zipdir  = 'c:\winzip\'
  winzip_txt = 'WINZIP32.EXE -min -a '

  path = STR_SEP(!path,';')
  fn = PARSE_IT(PATH)
  OK = WHERE(STRPOS(STRUPCASE(PATH),IDL_PATH) GE 0)
  IF OK[0] EQ -1 THEN STOP
  DIRS = PATH[OK]+'\'

  OK = WHERE(STRPOS(STRUPCASE(DIRS),'TEMP') LT 0)
  IF OK[0] EQ -1 THEN STOP
  DIRS = DIRS[OK]

STOP
  FOR _DIR = 0,N_ELEMENTS(DIRS)-1L DO BEGIN
    ADIR = DIRS(_DIR)
    TXT = ADIR + '*.PRO'
    FILES = FILELIST(TXT)
    IF N_ELEMENTS(FILES) GE 1 THEN BEGIN
     FOR _FILE = 0,N_ELEMENTS(FILES)-1L DO BEGIN
       AFILE = FILES(_FILE)
       FN =PARSE_IT(AFILE)
      zfile = ADIR + 'IDL_'+ FN.SUB +  '.zip '
      cmd= zipdir+ winzip_txt + zfile + AFILE
      IF NOT KEYWORD_SET(QUIET) THEN PRINT,CMD
      SPAWN, CMD
      ENDFOR
    ENDIF

  ENDFOR







  END
