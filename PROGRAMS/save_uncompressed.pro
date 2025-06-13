; $ID:	SAVE_UNCOMPRESSED.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program  reads compressed save and writes an uncompressed save
; SYNTAX:

;   Feb 5, 2005  td , compressed save were taking up more disk space
;-
; *************************************************************************

PRO SAVE_UNCOMPRESSED,FILES,DIR_OUT=DIR_OUT


  ROUTINE_NAME='SAVE_UNCOMPRESSED'
  UL='_'
	dash=DELIMITER(/DASH)



STOP

FILES=FILE_SEARCH('I:\SST_GLOBAL\AVHRR\SAVE\!D_200407*GEQ-SST.SAVE')
DIR_OUT='I:\SST_GLOBAL\AVHRR\SAVE_UNCOMPRESSED\'


  IF N_ELEMENTS(FILES) LT 1 OR N_ELEMENTS(DIR_OUT) LT 1  THEN STOP
  FA_IN=FILE_ALL(FILES)
  IF FA_IN[0].FULLNAME EQ '' THEN GOTO, DONE

 	FOR _file = 0L , N_ELEMENTS(FA_IN)-1L DO BEGIN
        afile = FA_IN(_file).FULLNAME
				SAVEFILE=DIR_OUT+FA_IN(_FILE).NAME+FA_IN(_FILE).EXT_DELIM+FA_IN(_FILE).EXT
				EXIST_SAVE   = FILE_TEST(savefile)
				IF EXIST_SAVE EQ 1 THEN CONTINUE

        PRINT,_FILE, 'READING ', AFILE
        STRUCT = READALL(AFILE)


				PRINT, 'WRITING: '+savefile
        SAVE,FILENAME=SAVEFILE,struct
        struct=''
  ENDFOR; 	FOR _file = 0L , N_ELEMENTS(FA_IN)-1L DO BEGIN

DONE:
PRINT, 'FINISHED  WRITING UNCOMPRESSED SAVES'

END ; end of program
