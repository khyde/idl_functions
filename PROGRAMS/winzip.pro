; $ID:	WINZIP.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program Runs Winzip 8.0 batch command line AND UNZIPS (DEFAULT) a source zip file
;                   or will make a zip file from an input file
; SYNTAX:
;   WINZIP, Files=FILES;
; OUTPUT:
;   A compressed zip file ... or uncompressed files from a zip file
; ARGUMENTS:
;
; KEYWORDS:
;    FILES : NAMES OF FILES (WITH WILDCARDS if needed)
;    ZIP   : COMPRESSES EACH FILE
;		 OUTFILE: Name for the output zip file to write all the input files

;   TEST:   Shows what the command will look like without actually executing the winzip command:
;   NO_OVERWRITE:  Prevents Re-making the zip file if it already exists
;   KEEP_EXT:  Keeps the original extension and appends a '.zip'
;   EXT_ZIP:  Allows making a zip file with an extension other than the default '.zip'
; KEY3:
; EXAMPLE:
;       winzip
;       winzip,files=' ...*.z'
;       WINZIP,FILES='H:\SEAWIFS\NEC\*.Z',   DIR_OUT='G:\SEAWIFS\NEC\' , /NO_OVERWRITE
;       FILES = FILELIST('E:\BLEND\EPS\OA*_ED.DAT.GZ') & WINZIP,FILES=FILES,DIR_OUT='E:\BLEND\EPS\DAT\',/no_overwrite
;       FILES = FILELIST('F:\SEAWIFS\REPRO4_GLOBAL_Z\S*SWREP4*.*') & WINZIP,FILES=FILES,/GZIP,/KEEP_EXT,EXT_ZIP='GZ'
; CATEGORY:
;   FILES
; NOTES:
;     RESTRICTIONS: THOSE OF WINZIP 8.0.
; VERSION:
;   May 8,2001
; HISTORY:
;   Jan 1,2001  Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Jul 29,2002 jor,td  continue if target is null when compressing using winzip
;   Oct 2, 2002 td, add keyword HIDE
;-
; *************************************************************************

PRO WINZIP,files=files, DIR_OUT=dir_out , ZIP=ZIP,GZIP=gzip, TEST=test,$
												OUTFILE=outfile,$
                        DELETE_SOURCE=delete_source,NO_OVERWRITE=no_overwrite,$
                        EXT_ZIP=EXT_ZIP,EXT_GZIP=ext_gzip,KEEP_EXT=keep_ext,HIDE=hide
  ROUTINE_NAME='WINZIP'

; ================> LOCATION OF WINZIP.EXE
  dir_zip  = 'c:\winzip\'
  dir_gzip  = 'c:\gzip\'
  dir_temp  = 'c:\temp\'

  IF N_ELEMENTS(EXT_ZIP) NE 1 THEN EXT_ZIP = '.zip' ELSE EXT_ZIP = '.'+EXT_ZIP
  IF N_ELEMENTS(EXT_GZIP) NE 1 THEN EXT_GZIP = '.gz' ELSE EXT_GZIP = '.'+EXT_GZIP

  IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE(TITLE='Select compressed files',$
                                         filter='*.z*',/fix_filter,/MULTIPLE_FILES)

  FILES = FILELIST(FILES)

  IF N_ELEMENTS(DIR_OUT) EQ 0 THEN BEGIN
    FN = PARSE_IT(FILES[0])
    DIR_OUT = FN.DIR
  ENDIF



;	*********************************************
;	***** Combine files into one zipfile  ? *****
;	*********************************************
	IF N_ELEMENTS(OUTFILE) EQ 1 THEN BEGIN
		LISTFILE=DIR_OUT+'LISTFILE.TXT'
		WRITE_TXT,LISTFILE,FILES
	 	cmd = DIR_ZIP + 'winzip32.exe -min -a ' + DIR_OUT + OUTFILE + ' @' + LISTFILE[0]
	 	SPAWN,cmd,/HIDE
;		===> Now Update (Freshen files)
;	 	cmd = DIR_ZIP + 'winzip32.exe -min -u ' + DIR_OUT + OUTFILE + ' @' + LISTFILE[0]
;	 	SPAWN,cmd,/HIDE

		GOTO, DONE
	ENDIF


; *****************************************
  FOR nth = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    afile = files(nth)
    fn = PARSE_IT(afile)

   IF KEYWORD_SET(GZIP) THEN BEGIN
;     ====================>
;     Compress file using GZIP.EXE
      cmd = dir_GZIP + 'GZIP.exe   '
      IF NOT KEYWORD_SET(KEEP_EXT) THEN BEGIN

        cmd = cmd + FN.DIR+FN.NAME+ EXT_GZIP
      ENDIF ELSE BEGIN
        cmd = cmd + '-S  '+EXT_GZIP +' ' + FN.DIR+FN.NAME+ '.'+FN.EXT
      ENDELSE
      cmd = cmd + ' ' + afile
      IF KEYWORD_SET(HIDE) THEN SPAWN,cmd,/HIDE ELSE SPAWN, cmd
      IF KEYWORD_SET(DELETE_SOURCE) THEN BEGIN
        EXIST = FILE_TEST(afile)
        IF EXIST[0] EQ 1 THEN BEGIN
          FILE_DELETE,AFILE
        ENDIF
      ENDIF
      CONTINUE
    ENDIF


    IF KEYWORD_SET(ZIP) THEN BEGIN
;     ====================>
;     Compress file using WINZIP.EXE
      IF NOT KEYWORD_SET(KEEP_EXT) THEN BEGIN
        cmd = dir_zip + 'winzip32.exe -min  -a ' + FN.DIR+FN.NAME+ EXT_ZIP

      ENDIF ELSE BEGIN
        cmd = dir_zip + 'winzip32.exe -min  -a ' + FN.DIR+FN.NAME+'.'+FN.EXT+EXT_ZIP
      ENDELSE
      cmd = cmd + ' ' + afile
      SPAWN, cmd
      IF KEYWORD_SET(DELETE_SOURCE) THEN BEGIN
        EXIST = FILE_TEST(afile)
        IF EXIST[0] EQ 1 THEN BEGIN
          FILE_DELETE,AFILE
        ENDIF
      ENDIF
    ENDIF ELSE BEGIN


;     ====================>
;     Uncompress file using WINZIP.EXE
;     ====================>
;     Check if uncompressed file exists already
      TARGET = DIR_OUT+FN.NAME
      IF TARGET EQ '' THEN CONTINUE ;

      EXIST = FINDFILE(TARGET, COUNT=count)
      IF COUNT EQ 0 OR NOT KEYWORD_SET(NO_OVERWRITE) THEN BEGIN

      	IF STRUPCASE(FN.EXT) EQ 'GZ' THEN BEGIN
;					===> copy the gz file to a temporary directory, decompress it,
;					then copy the decompressed file to the orig directory
					IF FILE_TEST(DIR_TEMP,/DIRECTORY) EQ 0L THEN FILE_MKDIR,DIR_TEMP
					FILE_TEMP = DIR_TEMP+FN.NAME+FN.EXT_DELIM+FN.EXT
      		cmd = DIR_GZIP + 'GZIP.exe -d -f '  + FILE_TEMP

      		IF NOT KEYWORD_SET(TEST) THEN BEGIN
          	PRINT, CMD
          	FILE_COPY,AFILE,DIR_TEMP,/OVERWRITE,/REQUIRE_DIRECTORY
          	SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
          	FILE_COPY,DIR_TEMP + FN.NAME  ,DIR_OUT ,/OVERWRITE,/REQUIRE_DIRECTORY
          	FILE_DELETE,DIR_TEMP + FN.NAME ,/QUIET
					ENDIF ELSE BEGIN
          	PRINT, CMD
        	ENDELSE

      	ENDIF ELSE BEGIN
      		cmd = DIR_ZIP + 'winzip32.exe -min -e -o  ' + afile + '  ' + dir_out
      		IF NOT KEYWORD_SET(TEST) THEN BEGIN
      			PRINT, CMD
          	SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
      		ENDIF ELSE BEGIN
         	  	PRINT, CMD
          ENDELSE
        ENDELSE
      ENDIF

    ENDELSE ;  IF KEYWORD_SET(ZIP) THEN BEGIN


  ENDFOR

DONE:

END; #####################  End of Routine ################################

