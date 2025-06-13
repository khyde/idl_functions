; $ID:	PRO_DOC.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO PRO_DOC, Files,  DIR_BACKUP=dir_backup, ADD_PARAMS=ADD_PARAMS,ERROR = error
;+
; NAME:
;		PRO_DOC
;
; PURPOSE:
;		This procedure READS an IDL pro, WRITES it with a time stamp in the name to the backup directory,
;		ADDS the current time stamp to the first line in the documentation section of the idl program, and
;	  REWRITES the Program and renames it to LOWER CASE
;
; CATEGORY:
;		UTILITY
;
; CALLING SEQUENCE:
;
;		PRO_DOC, Files
;
; INPUTS:
;		Files:	Names of the IDL Routines (pro)
;
;	KEYWORD_PARAMETERS:
;		DIR_BACKUP: The directory to use when writing a copy (backup) of the IDL PRO
;								The default is the drive letter from the current drive + '\IDL\BACKUP\'
;
;		ADD_PARAMS:	Identifies parameters and keywords and places them in order at the beginning of the idl program file
;
;		ERROR:      Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; OUTPUTS:
;		This program :
;		1) WRITES a copy of the IDL PRO with a time stamp in the name to the backup directory;
;		2) REWRITES the IDL PRO to its directory in LOWER CASE.
;
;	SIDE EFFECTS:
;		If DIR_BACKUP is not provided then this routine makes a folder for the backup copy of the idl routine
;		(e.g. 'D:\IDL\BACKUP\', OR 'C:\IDL\BACKUP\' , depending on the drive letter of the directory obtained from CD, CURR=CURR)
;
; EXAMPLE:
;		PRO_DOC,'TEST.PRO'
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jun 21, 2003 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PRO_DOC'

  TAB=STRING(BYTE(9))

;	===> Initialize ERROR to a null string.
	ERROR = ''

;	===> If DIR_BACKUP not provided then the backups will be placed in a folder
;				with the drive letter from the current drive + '\IDL\BACKUP\'

	IF N_ELEMENTS(DIR_BACKUP) NE 1 THEN BEGIN
		CD,CURR=CURR
		FN=FILE_PARSE(CURR)
		DIR_IDL_BACKUP = FN.DRIVE+'\IDL\BACKUP\'
	ENDIF ELSE DIR_IDL_BACKUP = DIR_BACKUP

;	===> Make the backup directory if it does not already exist
  IF FILE_TEST(DIR_IDL_BACKUP,/DIRECTORY) EQ 0L THEN FILE_MKDIR,DIR_IDL_BACKUP

;	===> Get the computer name (to use in the backup copy of the IDL PRO)
  COMPUTER=GET_COMPUTER()

  IF N_ELEMENTS(FILES) EQ 0 THEN GOTO, DONE  ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;	===> PARSE the file name components
	fn=FILE_PARSE(FILES)
	FILES = FN.DIR+FN.NAME
  FILES=FILELIST(FILES+'.pro')


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _file= 0L,N_ELEMENTS(FILES)-1L DO BEGIN
    afile=FILES(_file)

    fn=FILE_PARSE(afile)
    IF STRUPCASE(fn.ext) NE 'PRO' THEN CONTINUE ; >>>>>>>>>>>>>>>>>>
    PRINT, 'ADDING DOCUMENTATION DATE TO: '+afile
    TXT= READ_TXT(afile)


;		===> Make a backup with the date time stamp AS IS
		BACKUP_FILE = DIR_IDL_BACKUP+ COMPUTER +'-' + STRLOWCASE(FN.NAME) + '-' + DATE_NOW() + STRLOWCASE('.pro')
		PRINT,BACKUP_FILE
		WRITE_TXT,BACKUP_FILE,TXT


;		===> Find the ID and Date stamp usually on the first line
		ID = '; $Id:'+TAB+STRLOWCASE(FN.NAME+FN.EXT_DELIM)+STRLOWCASE(FN.EXT) +','+TAB+ DATE_FORMAT(DATE_NOW(),/MDY,/MINUTE,/NAME)+TAB + '$'

		POS = STRPOS(STRUPCASE(TXT),'$ID:')
		OK=WHERE(POS GE 0 AND POS LE 3,COUNT)

;		===> Remove the old time stamp
    IF COUNT GE 1 THEN BEGIN
    	OK=OK[0]
;			===> Add program name
    	TXT = REMOVE(TXT, OK )
		ENDIF

;		===> Add the new time stamp
		TXT=[ID,TXT]

		IF KEYWORD_SET(ADD_PARAMS) THEN BEGIN
		  T = PRO_PARAMS(afile)
	    TXT=[T,TXT]
		ENDIF


;		*****************
;		*** E D I T   ***
;		*****************
;		===> Write the new file UPPERCASE NAME, LOWERCASE pro
		WRITE_TXT,FN.DIR+ STRLOWCASE(FN.NAME)+FN.EXT_DELIM+STRLOWCASE(FN.EXT),TXT

;		===> Rename
		FILE_RENAME,FN.FULLNAME,/LOWER

	ENDFOR

DONE:

END; #####################  End of Routine ################################
