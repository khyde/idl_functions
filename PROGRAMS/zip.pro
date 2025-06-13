; $ID:	ZIP.PRO,	2020-06-30-17,	USER-KJWH	$
;#####################################################################################
PRO ZIP,FILES=FILES,    DIR_OUT=DIR_OUT, ZIP=ZIP, GZIP=GZIP, BZIP=BZIP, TEST=TEST,$
                        OUTFILE=OUTFILE,ERROR=ERROR,ERR_MSG=ERR_MSG,$
                        DELETE_SOURCE=DELETE_SOURCE,NO_OVERWRITE=NO_OVERWRITE,$
                        KEEP_TEMP=KEEP_TEMP,TEMPFILES=TEMPFILES,$
                        EXT_ZIP=EXT_ZIP,EXT_GZIP=EXT_GZIP,EXT_BZIP2=EXT_BZIP2,KEEP_EXT=KEEP_EXT,HIDE=HIDE,$
                         SIZE_ZIP = SIZE_ZIP, REZIP=REZIP
;+
; This Program Runs Winzip 8.0 batch command line AND UNZIPS (DEFAULT) a source zip file
;                   or will make a zip file from an input file
; SYNTAX:
;   ZIP, Files=FILES;
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
;   ZIP_SIZE: When compressing, this program will make several output zip files each less than file_size
;   REZIP : Allow files that are already compressed to be zipped
; KEY3:
; EXAMPLE:
;       ZIP
;       ZIP,files=' ...*.z'
;       ZIP,FILES='H:\SEAWIFS\NEC\*.Z',   DIR_OUT='G:\SEAWIFS\NEC\' , /NO_OVERWRITE
;       FILES = FILELIST('E:\BLEND\EPS\OA*_ED.DAT.GZ') & ZIP,FILES=FILES,DIR_OUT='E:\BLEND\EPS\DAT\',/no_overwrite
;       FILES = FILELIST('F:\SEAWIFS\REPRO4_GLOBAL_Z\S*SWREP4*.*') & ZIP,FILES=FILES,/GZIP,/KEEP_EXT,EXT_ZIP='GZ'
;       ZIP,FILES=FILES[0],DIR_OUT='H:\ANCILLARY_METOZ\',EXT_ZIP='Z',/ZIP,/KEEP_EXT
; CATEGORY:
;   FILES
; NOTES:
;     RESTRICTIONS: THOSE OF WINZIP 8.0.

; MODIFICATION HISTORY:
;   Jan 1,2001  Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Jul 29,2002 jor,td  continue if target is null when compressing using winzip
;   Oct 2, 2002 td, add keyword HIDE
;   Mar 22, 2010 KH, added ERROR output
;   Apr 12, 2011 DWM, modified to work under unix/linux, some logistical fixes, added REZIP keyword
;   Nov 22, 2011 KH, added KEEP_TEMP and OUTFILE keywords to prevent copying file back to the original directory
;   DEC 31,2014,JOR, REVISED TO USE THE NEW IDL ROUTINES:FILE_ZIP,FILE_UNZIP,FILE_GZIP,FILE_GUNZIP,
;   JAN 2,2015,JOR: EXIST = FILE_TEST(FIX_PATH(TARGET))

;#####################################################################################
;-
;*****************
ROUTINE_NAME='ZIP'
;*****************
;IF NONE(GZIP) AND NONE(ZIP) AND NONE(BZIP) THEN ZIP = 1 
VERBOSE = 1
case !version.OS_FAMILY of
  'unix' : BEGIN
    WINZIP_CMD = 'zip '
    GZIP_CMD   = 'gzip -d -f '
    GZIP_NOARG = 'gzip '
    BZIP2_CMD  = 'bzip2 -d '
    BZIP2_COM  = 'bzip2 '
    DIR_TEMP   = '/tmp/'
  END
  'Windows': BEGIN
    WINZIP_CMD   = 'c:\winzip\winzip32.exe -min -a '
    WINZIP_NOARG = 'c:\winzip\winzip32.exe '
    GZIP_CMD     = 'c:\gzip\gzip -d '
    GZIP_NOARG   = 'c:\gzip\gzip '
    BZIP2_CMD    = 'c:\bzip2\bzip2 -d '
    DIR_TEMP     = 'c:\temp\'
  END
  else: BEGIN
   ERROR = 'ZIP.PRO: unkown !version.os_family : ' + !version.os_family  
   print, ERROR
   return
  END
endcase

  IF FILE_TEST(DIR_TEMP,/DIR) EQ 0 THEN FILE_MKDIR,DIR_TEMP

  IF N_ELEMENTS(EXT_ZIP)   NE 1 THEN EXT_ZIP   = '.zip' ELSE EXT_ZIP   = '.'+EXT_ZIP
  IF N_ELEMENTS(EXT_GZIP)  NE 1 THEN EXT_GZIP  = '.gz'  ELSE EXT_GZIP  = '.'+EXT_GZIP
  IF N_ELEMENTS(EXT_BZIP2) NE 1 THEN EXT_BZIP2 = '.bz2' ELSE EXT_BZIP2 = '.'+EXT_BZIP2

  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
  	PRINT,'MUST PROVIDE FILE NAMES'
  	RETURN
  ENDIF


	IF MAX(STRPOS(FILES,'*')) GE 0 THEN FILES=FILE_SEARCH(FILES)

  IF N_ELEMENTS(DIR_OUT) EQ 0 THEN BEGIN
    FN = PARSE_IT(FILES[0])
    DIR_OUT = FN.DIR
  ENDIF



;	*********************************************
;	***** COMBINE FILES INTO ONE ZIPFILE    *****
;	*********************************************
	IF N_ELEMENTS(OUTFILE) EQ 1 THEN BEGIN
    
		LISTFILE = DIR_OUT + 'LISTFILE.TXT'
		FILE_DELETE, LISTFILE, /ALLOW_NONEXISTENT
		WRITE_TXT, LISTFILE, FILES

	 	IF !VERSION.OS_FAMILY EQ 'unix' THEN BEGIN
;	 	  CMD = WINZIP_CMD + DIR_OUT + OUTFILE + ' -@ < ' + LISTFILE[0]
;      SPAWN, CMD
STOP; FILE_GZIP CAN NOT ZIP MULTIPLE FILES INTO ONE OUTFILE
      FILE_GZIP, FILES , OUTFILE, VERBOSE= VERBOSE
	 	ENDIF ELSE BEGIN ; Hopefully Windows
;;	 	  CMD = WINZIP_CMD +  DIR_OUT + OUTFILE + ' @' + LISTFILE[0]
;;      SPAWN, CMD, /HIDE
      FILE_ZIP, FILES , OUTFILE, VERBOSE= VERBOSE

	 	ENDELSE
	 	FILE_DELETE, LISTFILE
		GOTO, DONE
	ENDIF
  
; *****************************************
  FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FIX_PATH(FILES[NTH])
    FN = PARSE_IT(AFILE)
    ERROR = 0
    ERR_MSG = ''
    TEMPFILES = []
    
   ; ****************** COMPRESS FILES ********************
   ; Check if trying to compress already compressed files:
   IF KEYWORD_SET(GZIP) OR KEYWORD_SET(ZIP) OR KEYWORD_SET(BZIP) THEN BEGIN
      IF STRUPCASE(FN.EXT) EQ 'GZ' THEN BEGIN
        PRINT, 'Trying to compress a file that already has a .gz extension...'
        KEEP_EXT=1
        IF NOT KEYWORD_SET(REZIP) THEN GOTO, DONE
      ENDIF
      IF STRUPCASE(FN.EXT) EQ 'BZ2' THEN BEGIN
        PRINT, 'Trying to compress a file that already has a .bz2 extension...'
        KEEP_EXT=1
        IF NOT KEYWORD_SET(REZIP) THEN GOTO, DONE
      ENDIF
      IF STRUPCASE(FN.EXT) EQ 'ZIP' THEN BEGIN
        PRINT, 'Trying to compress a file that already has a .zip extension...'
        KEEP_EXT=1
        IF NOT KEYWORD_SET(REZIP) THEN GOTO, DONE
      ENDIF
   ENDIF

   IF KEYWORD_SET(GZIP) THEN BEGIN
   ; Compress file using GZIP
      cmd = GZIP_NOARG
      IF NOT KEYWORD_SET(KEEP_EXT) OR FN.EXT EQ '' THEN BEGIN
        cmd = cmd + ' -c ' + afile + ' > ' + DIR_OUT + FN.NAME + EXT_GZIP
        FILEOUT = DIR_OUT + FN.NAME + EXT_GZIP
      ENDIF ELSE BEGIN
        cmd = cmd + ' -c ' + afile + ' > ' + DIR_OUT + FN.NAME + '.' + FN.EXT + EXT_GZIP
        FILEOUT =  DIR_OUT + FN.NAME + '.' + FN.EXT + EXT_GZIP
      ENDELSE
      print, cmd
      ;IF KEYWORD_SET(HIDE) THEN SPAWN,cmd,/HIDE ELSE SPAWN, cmd
      DIR_TEST,DIR_OUT
      FILE_GZIP, AFILE,FILEOUT, VERBOSE= VERBOSE
      IF KEYWORD_SET(DELETE_SOURCE) THEN BEGIN
        IF FILE_TEST(AFILE) EQ 1 THEN FILE_DELETE, AFILE        
      ENDIF
      CONTINUE
    ENDIF
    
    IF KEYWORD_SET(BZIP) THEN BEGIN
   ; Compress file using BZIP
      cmd = BZIP2_COM
      IF NOT KEYWORD_SET(KEEP_EXT) OR FN.EXT EQ '' THEN BEGIN
        cmd = cmd + ' -c ' + afile + ' > ' + DIR_OUT + FN.NAME + EXT_BZIP2
      ENDIF ELSE BEGIN
        cmd = cmd + ' -c ' + afile + ' > ' + DIR_OUT + FN.NAME + '.' + FN.EXT + EXT_BZIP2 
      ENDELSE
      print, cmd
      IF KEYWORD_SET(HIDE) THEN SPAWN,cmd,/HIDE ELSE SPAWN, cmd
      IF KEYWORD_SET(DELETE_SOURCE) THEN BEGIN
        IF FILE_TEST(AFILE) EQ 1 THEN FILE_DELETE, AFILE        
      ENDIF
      CONTINUE
    ENDIF

    IF KEYWORD_SET(ZIP) THEN BEGIN
    ; Compress file using WINZIP
      IF NOT KEYWORD_SET(KEEP_EXT) THEN BEGIN
        cmd = WINZIP_CMD + DIR_OUT + FN.NAME + EXT_ZIP
        FILEOUT= DIR_OUT + (FILE_PARSE(AFILE)).NAME + EXT_ZIP

      ENDIF ELSE BEGIN
        cmd = WINZIP_CMD + DIR_OUT + FN.NAME + '.' + FN.EXT + EXT_ZIP
        FILEOUT= DIR_OUT + (FILE_PARSE(AFILE)).NAME + '.' + FN.EXT + EXT_ZIP

      ENDELSE
     ; cmd = cmd + ' ' + afile
      ;SPAWN, cmd
      FILEOUT= DIR_OUT + (FILE_PARSE(AFILE)).NAME + EXT_ZIP
      DIR_TEST,DIR_OUT
      FILE_ZIP, AFILE,FILEOUT,VERBOSE= VERBOSE

      IF KEYWORD_SET(DELETE_SOURCE) THEN BEGIN
        EXIST = FILE_TEST(afile)
        IF EXIST[0] EQ 1 THEN BEGIN
          FILE_DELETE,AFILE
        ENDIF
      ENDIF
      CONTINUE
    ENDIF
   ; ****************** END COMPRESS FILES ********************

;     ====================>

      ;TARGET = DIR_OUT+FN.NAME
      TARGET = AFILE
      IF TARGET EQ '' THEN CONTINUE ;

      ;EXIST = FINDFILE(TARGET, COUNT=count) [OBSOLETE]
      EXIST = FILE_TEST(FIX_PATH(TARGET))

      
      IF EXIST NE 0 AND KEYWORD_SET(NO_OVERWRITE) THEN CONTINUE
      IF FILE_TEST(DIR_OUT+FN.NAME) EQ 1 THEN CONTINUE

        CASE STRUPCASE(FN.EXT) OF
      	'GZ' :  BEGIN
					FILE_TEMP = DIR_TEMP+FN.NAME+FN.EXT_DELIM+FN.EXT
      		cmd = GZIP_CMD + FILE_TEMP
      		IF KEYWORD_SET(TEST) THEN BEGIN
      		  PRINT, CMD
      		  BREAK
      		ENDIF
          PRINT, CMD
          FILE_COPY,AFILE,DIR_TEMP,/OVERWRITE,/REQUIRE_DIRECTORY
          ; this is needed due to the NOSHELL keyword on linux
          if !VERSION.OS_FAMILY eq 'unix' then begin
            CMD = STRSPLIT(CMD, /EXTRACT)

          END;'GZ'
          ;SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
          FILE_GUNZIP,AFILE

          EXIST=FILE_TEST(DIR_TEMP+FN.NAME)
          IF EXIST EQ 0 THEN BEGIN
            REPORT,AFILE + ': gzip failed to decompress', dir = dir_out
            FILE_DELETE,FILE_TEMP ,/QUIET
            PRINT, AFILE + ': gzip failed to decompress' 
            ERROR=1
            ERR_MSG = 'GZIP_DECOMPRESS_FAILED'
          ENDIF ELSE BEGIN
          	IF KEYWORD_SET(KEEP_TEMP) THEN TEMPFILES = [TEMPFILES,DIR_TEMP+FN.NAME] ELSE BEGIN
         	  FILE_COPY,DIR_TEMP + FN.NAME  ,DIR_OUT ,/OVERWRITE,/REQUIRE_DIRECTORY
              FILE_DELETE,DIR_TEMP + FN.NAME ,/QUIET
            ENDELSE  
          ENDELSE
					BREAK
      	END ; 'GZ'

      	'BZ2' : BEGIN					
					FILE_TEMP = DIR_TEMP+FN.NAME+FN.EXT_DELIM+FN.EXT
 					cmd = BZIP2_CMD  + FILE_TEMP
      		IF KEYWORD_SET(TEST) THEN BEGIN
      		  PRINT, CMD
      		  BREAK
      		ENDIF
      		
          PRINT, CMD
          FILE_COPY,AFILE,DIR_TEMP,/OVERWRITE,/REQUIRE_DIRECTORY
          ; this is needed due to the NOSHELL keyword on linux
          IF !VERSION.OS_FAMILY EQ 'unix' THEN BEGIN
            CMD = STRSPLIT(CMD, /EXTRACT)
          END
          SPAWN, CMD, RESULT, ERR_RESULT, PID=PID, /NOSHELL

          EXIST=FILE_TEST(DIR_TEMP+FN.NAME)
  
          IF EXIST EQ 0 THEN BEGIN
          	REPORT,AFILE + ': bzip2 failed to decompress', dir = dir_out
          	FILE_DELETE,FILE_TEMP ,/QUIET
          	PRINT, AFILE + ': bzip2 failed to decompress' 
          	ERROR=1
          	ERR_MSG = 'BZIP2_DECOMPRESS_FAILED'
          ENDIF ELSE BEGIN
            IF KEYWORD_SET(KEEP_TEMP) THEN TEMPFILES = [TEMPFILES,DIR_TEMP+FN.NAME] ELSE BEGIN
              FILE_COPY,DIR_TEMP + FN.NAME  ,DIR_OUT ,/OVERWRITE,/REQUIRE_DIRECTORY
              FILE_DELETE,DIR_TEMP + FN.NAME ,/QUIET
            ENDELSE
          ENDELSE
				END ; BZ2
        'ZIP': BEGIN
          ; winzip default
          IF KEYWORD_SET(TEST) THEN BEGIN
            PRINT, CMD
            BREAK
          ENDIF
          ;CMD = WINZIP_NOARG + ' -min -e -o ' + AFILE + '  ' + DIR_OUT
;          PRINT, CMD
;          SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
           FILE_UNZIP,AFILE,DIR_OUT,VERBOSE=VERBOSE
        END ; ZIP
				ELSE : BEGIN ; DEFAULT
				  REPORT,AFILE, 'Unknown compression scheme/extension, unable to decompress'
          FILE_DELETE, FILE_TEMP ,/QUIET
          PRINT, AFILE + ': Unknown compression scheme/extension, unable to decompress'
          ERROR=1
          ERR_MSG = 'UNKNOWN_TYPE_DECOMPRESS_FAILED'
				END

      ENDCASE

  ENDFOR

DONE:

END; #####################  End of Routine ################################

