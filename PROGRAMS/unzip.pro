; $ID:	UNZIP.PRO,	2020-06-30-17,	USER-KJWH	$
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
; VERSION:
;   May 8,2001
; HISTORY:
;   Jan 1,2001  Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Jul 29,2002 jor,td  continue if target is null when compressing using winzip
;   Oct 2, 2002 td, add keyword HIDE
;   Mar 22, 2010 KH, added ERROR output
;   Nov 22, 2011 KH, added KEEP_TEMP and OUTFILE keywords to prevent copying file back to the original directory
;   Dec 18, 2014 KH, changed name to UNZIP and removed code to compress files
;-
; *************************************************************************

PRO UNZIP,FILES=files,  DIR_OUT=dir_out, ZIP=zip, GZIP=gzip, BZIP=bzip, TEST=test,$
												OUTFILE=outfile,ERROR=error,ERR_MSG=err_msg,VERBOSE=verbose,$
                        DELETE_SOURCE=delete_source,OVERWRITE=overwrite,$
                        KEEP_TEMP=keep_temp,TEMPFILES=tempfiles,$
                        KEEP_EXT=keep_ext,HIDE=hide,$
                        SIZE_ZIP = SIZE_ZIP, REZIP=REZIP
  ROUTINE_NAME='ZIP'

  CASE !S.OS OF
    'UNIX' : BEGIN
      WINZIP_CMD = 'zip '
      GZIP_CMD   = 'gzip -d -f '
      GZIP_NOARG = 'gzip '
      BZIP2_CMD  = 'bzip2 -d '
      BZIP2_COM  = 'bzip2 '
    END
    'WINDOWS': BEGIN                                    ; !!!!!! JAY - YOU WILL NEED TO UPDATE THIS FOR WINDOWS !!!!!
      WINZIP_CMD   = 'c:\winzip\winzip32.exe -min -a '
      WINZIP_NOARG = 'c:\winzip\winzip32.exe '
      GZIP_CMD     = 'c:\gzip\gzip -d '
      GZIP_NOARG   = 'c:\gzip\gzip '
      BZIP2_CMD    = 'c:\bzip2\bzip2 -d '
    END
    ELSE: BEGIN
     ERROR = 1 
     ERR_MSG = 'ZIP.PRO: UNKOWN !VERSION.OS_FAMILY : ' + !S.OS  
     IF KEY(VERBOSE) THEN PRINT, ERR_MSG
     RETURN
    END
  ENDCASE

  DIR_TEMP = !S.IDL_TEMP & DIR_TEST,DIR_TEMP
 
  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
  	PRINT,'MUST PROVIDE FILE NAMES'
  	RETURN
  ENDIF

	IF MAX(STRPOS(FILES,'*')) GE 0 THEN FILES=FILE_SEARCH(FILES)

  IF N_ELEMENTS(DIR_OUT) EQ 0 THEN BEGIN
    FN = PARSE_IT(FILES[0])
    DIR_OUT = FN.DIR
  ENDIF


; *****************************************
  FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[NTH]
    FN = PARSE_IT(AFILE)
    ERROR = 0
    ERR_MSG = ''
    TEMPFILE = []

    OUTFILE = DIR_OUT+FN.NAME
    IF OUTFILE EQ '' THEN CONTINUE ;

    IF FILE_TEST(OUTFILE) EQ 1 AND NONE(OVERWRITE) THEN CONTINUE

      CASE STRUPCASE(FN.EXT) OF
    	'GZ' :  BEGIN
				FILE_TEMP = DIR_TEMP+FN.NAME+FN.EXT_DELIM+FN.EXT
    		CMD = GZIP_CMD + FILE_TEMP
    		IF KEYWORD_SET(TEST) THEN BEGIN
    		  PRINT, CMD
    		  BREAK
    		ENDIF
        IF KEY(VERBOSE) THEN PRINT, CMD
        FILE_COPY,AFILE,DIR_TEMP,/OVERWRITE,/REQUIRE_DIRECTORY
        
        IF !S.OS EQ 'UNIX' THEN CMD = STRSPLIT(CMD, /EXTRACT)  ; this is needed due to the NOSHELL keyword on linux
        SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
       
        IF FILE_TEST(DIR_TEMP+FN.NAME) EQ 0 THEN BEGIN
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
				CMD = BZIP2_CMD  + FILE_TEMP
    		IF KEYWORD_SET(TEST) THEN BEGIN
    		  PRINT, CMD
    		  BREAK
    		ENDIF
        PRINT, CMD
        FILE_COPY,AFILE,DIR_TEMP,/OVERWRITE,/REQUIRE_DIRECTORY
       
        IF !S.OS EQ 'UNIX' THEN CMD = STRSPLIT(CMD, /EXTRACT)   ; this is needed due to the NOSHELL keyword on linux
        SPAWN, CMD, RESULT, ERR_RESULT, PID=PID, /NOSHELL

        IF FILE_TEST(DIR_TEMP+FN.NAME) EQ 0 THEN BEGIN
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
			
      'ZIP': BEGIN ; winzip default
        
        CMD = WINZIP_NOARG + ' -min -e -o ' + AFILE + '  ' + DIR_OUT
        IF KEYWORD_SET(TEST) THEN BEGIN
          PRINT, CMD
          BREAK
        ENDIF
        SPAWN, CMD ,RESULT,ERR_RESULT,PID=PID,/NOSHELL
      END ; zip
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

