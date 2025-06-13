; $Id:	file_parse.pro,	June 22 2011	$
	FUNCTION FILE_PARSE,files, WITH_PERIOD=with_period
;+
;	PURPOSE:
;		This Function Parses the path and file name into its components and returns a structure
;
;	EXAMPLES:
;		Result = FILE_PARSE(Files)
;
;	PARAMETERS:
;		FILES:	The file names (usually with path)
;
;	KEYWORDS
;		WITH_PERIOD:	Keeps a period '.' in the extension, e.g. '.png' instead of the default extension 'png'
;
; OUTPUT:
;		An IDL Structure containing the parsed components of the file name
;
; NOTES:
;

; HISTORY:
;		Nov 14,1994	Written by:	J.E. O'Reilly (was called parse_it.pro)
;		March 12,1995       (input multiple files)
;		June 13,1995        (files with no extension)
;		December 15,1995    Fixed problem with multiple files parse
;                       Must initialize variables for each file
;		December 19,1995    Included keyword:  with_period
;		March 21, 1995      Determines Different directory delimiters
;                       used by WIN, MAX, AND X DEVICES
;		July 7,1997         Added delimiter for PRINTER device
;		Sept. 25,2000       Now the delimiter is determined
;                       according to the operating system (!version.os)
;		Sept. 28,2000				Added FIRST_NAME to structure
;                       (This is useful when there are several extensions to the name
;                       as in:  SAMPLE.DAT.Z   OR SAMPLE.DAT.ZIP
;		Jan 03,2001					Added tag 'EXT_DELIM'
;		July 25,2002 	JOR 	Changed so Files Parameter is not corrupted
;		Sept 20, 2006 JOR		Now using IDL PATH_SEP routine to obtaine the path delimiter
;		Dec 1, 2006  JOR 		Added Drive information to structure
;		Dec 12, 2006 JOR    Drive now includes the path_sep()


  ROUTINE_NAME='FILE_PARSE'

;  *************************************************************
;  Create a structure to hold the details of the file name(s):
;  Directory, Last Sub Directory, Name, Extension,
;  and the beginning and ending character positions of the
;  directory,name,period,and extension.
   filename = {FULLNAME:'',DRIVE:'',DIR:'',SUB:'',NAME:'',NAME_EXT:'',FIRST_NAME:'',EXT_DELIM:'',EXT:''}
   STRUCT = REPLICATE(filename,N_ELEMENTS(files))

;  ===> Get the operating system
   os = STRUPCASE(!VERSION.OS)


;	===> Eliminate all leading and trailing blanks from file name
	file_arr = files
 	file_arr = STRTRIM(file_arr,2)

; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _files = 0L, (N_ELEMENTS(file_arr) -1L) DO BEGIN
; 	===> Initialize variables
	  i = 0
	  name_beg = -1
	  subdirs = INTARR(50)
	  subdirs(*) = -1
	  afile = file_arr(_files)
	  filename.fullname = afile

;		===> Assume the Drive Delimiter is ':'
		delim = ':'
		txt = STRSPLIT(afile,delim,/extract)
		IF N_ELEMENTS(txt) EQ 2 THEN BEGIN
			filename.drive = txt(0)+delim+PATH_SEP()
		ENDIF


;   ===> Get the path delimiter used for this operating system
		delim = PATH_SEP()

;   ===> Determine starting point of file name and fill
;		subdirs array with character locations of the delimiter
    n = -1
;		WWWWWWWWWWWWWWWWWWWWWWWWW
  	WHILE (i NE -1) DO BEGIN
    	i =  STRPOS(afile,delim,I)
      IF i ne -1 then begin
        n = n + 1
        subdirs(n) = i+1
        i = i + 1
        name_beg = I
    	ENDIF
  	ENDWHILE


;   ===> If no delimiters for path present then assume name begins at first
;   non-blank character
    IF name_beg EQ -1 THEN     name_beg = strpos(afile,' ',0 ) +1

;   ===> Determine if there is more than one delimiter
;   (If so then there is at least one subdirectory)
    ok_last_sub = WHERE(subdirs NE -1,count)

   	IF count GE 2 THEN BEGIN ; if not filename.sub remains empty
     	subdirs = subdirs(ok_last_sub)
     	width = subdirs(count-1) - subdirs(count-2)-1
     	filename.sub = STRMID(afile,subdirs(count-2),width)
   	ENDIF

;   ===> Determine beginning and ending positions of directory path
   	dir_end = name_beg -1
   	dir_beg = 0
   	IF dir_end LT dir_beg THEN dir_end = 0
   	width = dir_end - dir_beg + 1

    IF width EQ 1 THEN BEGIN
  		filename.DIR = ''
    ENDIF ELSE BEGIN
    	filename.DIR = STRMID(afile,dir_beg,width)
   	ENDELSE

;   ===> Determine ending position of file name(s)
   	I = 0
   	delim = '.'
   	period = -1

;		WWWWWWWWWWWWWWWWWWWWWWWWW
    WHILE (I NE -1) DO BEGIN
    	i = STRPOS(afile,delim,i)
    	IF i ne -1 THEN begin
      	i = i + 1
        name_end = i -2
        period   = i -1
        ext_beg  = i
        IF KEYWORD_SET(WITH_PERIOD) THEN _ext_beg  = i-1 ELSE _ext_beg = i
     	ENDIF
   	ENDWHILE

   	IF period EQ -1 THEN BEGIN
	   	name_end = STRLEN(afile)-1
	   	ext_beg  = name_end +1
	   	_ext_beg = ext_beg
    ENDIF


    IF EXT_BEG-NAME_END EQ 2 THEN filename.EXT_DELIM='.' ELSE filename.EXT_DELIM = ''

;  	===> Now determine ending position of file extension(s)
    ext_end = strlen(strcompress(afile))-1
   	filename.name =STRMID(afile,name_beg,name_end - name_beg + 1)
   	filename.ext  =STRMID(afile, _ext_beg, ext_end - _ext_beg + 1)


;   ===> Determine First Name in NAME
    I = 0
    delim = '.'
    period = -1
    i = STRPOS(filename.name,delim,i)
    IF i ne -1 THEN begin
      i = i + 1
      name_end = i -2
      period   = i -1
      ext_beg  = i
      i= -1
   	ENDIF
    IF period EQ -1 THEN BEGIN
      name_end = STRLEN(filename.name)-1
      ext_beg  = name_end +1
    ENDIF
    filename.first_name =STRMID(filename.name,0,name_end + 1)
    filename.name_ext = filename.name+filename.ext_delim+filename.ext

;   ===>
    STRUCT(_files) = filename

	ENDFOR ; (FOR _file_arr = 0, (N_ELEMENTS(file_arr) -1) DO BEGIN)

	RETURN, STRUCT


END; #####################  End of Routine ################################
