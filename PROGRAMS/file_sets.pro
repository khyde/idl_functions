; $ID:	FILE_SETS.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Function Program
; SYNTAX:
;	FILE_SETS, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = FILE_SETS(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1: PATHS  is an array of paths
;	KEY2: TARGET is a selection criteria
;	KEY3: LEN  use LEN portion of file names for sorting
;             full name is sorted if LEN = ''
; KEY4: EXEMPT  strings specified are removed from file names for sorting
; EXAMPLE: SETS = FILE_SETS(PATHS =['E:\SEAWIFS_NEC\REPRO3\SAVE\','I:\SEAWIFS_NEC\REPRO3\SAVE\'],$
;                 TARGET='*_S_*_MEAN_*.PNG',LEN='',EXEMPT=['REPRO3','REPRO4A']
; CATEGORY:
;	DT
; NOTES:
; VERSION:
;	Jan 01,2001
; HISTORY:
;	Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION FILE_SETS, PATHS=paths, target=target , LEN=len, EXEMPT=exempt
  ROUTINE_NAME='FILE_SETS'

  FILES = ''
  FOR N=0L,N_ELEMENTS(PATHS)-1L DO BEGIN
   APATH = PATHS(N)
   ATARGET = APATH+TARGET
   FILES = [FILES,FILELIST(ATARGET)]
  ENDFOR
  OK = WHERE(STRLEN(FILES) GE 3,COUNT)
  IF COUNT GE 1 THEN FILES = FILES[OK]


      ;  parse file names into a structure
  	fn = parse_it(files)

  	IF N_ELEMENTS(LEN) NE 1 THEN BEGIN
  	  IF STRLEN(LEN[0]) GE 1 THEN  names = fn.name+FN.EXT
  	ENDIF ELSE BEGIN
  	  names = STRMID(fn.name,0,LEN)+EXT
  	ENDELSE


    IF N_ELEMENTS(EXEMPT) GE 1 THEN BEGIN
      IF STRLEN(EXEMPT[0]) GE 1 THEN BEGIN
      	FOR N=0,N_ELEMENTS(EXEMPT)-1L DO BEGIN
        	names = REPLACE(NAMES,EXEMPT(N),'')
      	ENDFOR
       ENDIF
    ENDIF


    srt = SORT(names)
    names = names(srt)
    files = files(srt)
    fn    = fn(srt)
    u = UNIQ(names)
    ;  process methods pages for each iname

    FOR nu = 0, N_ELEMENTS(u)-1L DO BEGIN
      OK = WHERE(names EQ names(u(nu)),count)
      set = files(OK)
      fn_set = fn(ok)
      NAME = 'S_'+NUM2STR(NU)
      IF N_ELEMENTS(ARR) EQ 0 THEN BEGIN
          ARR=CREATE_STRUCT(NAME,SET)
        ENDIF ELSE BEGIN
          ARR=CREATE_STRUCT(ARR,NAME,SET)
      ENDELSE
    ENDFOR


   RETURN, ARR




END; #####################  End of Routine ################################
