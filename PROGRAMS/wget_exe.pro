; $ID:	WGET_EXE.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO WGET_EXE, HTML=html, FILES=files, DIR_HTML=dir_html, DIR_LOCAL=dir_local, GET_N_FILES=get_n_files, $
						ACCOUNT=account, PASSWORD=password, SORT_REVERSE=sort_reverse, MIN_SIZE=min_size, OVERWRITE=overwrite

;+
; NAME:
;		WGET
;
; PURPOSE:;
;		This function will run GNU Wget...
;		"GNU Wget is a free software package for retrieving files using HTTP, HTTPS and FTP,
;		the most widely-used Internet protocols. It is a non-interactive commandline tool,
;		so it may easily be called from scripts, cron jobs, terminals without Xsupport, etc."
;		http://wget.dotsrc.org/index.shtml
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;		WGET, HTML='http://oceancolor.gsfc.nasa.gov/cgi/getfile/',FILES='A200506018*'
;		WGET, HTML='http://oceancolor.gsfc.nasa.gov/cgi/getfile/',FILES='A2005060185500.L0_LAC.bz2'
;
;
; INPUTS:
;		HTML 	- The HTML site the files are to be retreived from
;		FILES - The filenames (can include wildcards '*') of the files to be retreived
;
; KEYWORD PARAMETERS:
;		DIR_LOCAL - Output directory
;		INVENTORY - Inventory file
;		GET_N_FILES - Number of files to get before exiting
;		ACCOUNT - Account name
;		PASSWORD - Passowrd
;		SORT_REVERSE - Loop through files in reverse
;		OVERWRITE - Overwrite exisiting files
;
;	NOTES:
;		****** The WGET.EXE program MUST be in the C:/WINDOWS folder *******
;
; MODIFICATION HISTORY:
;			Written May 16, 2007 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			        Nov 25, 2015 - KJWH: Changed name to WGET_EXE to avoid conflicts with IDL's WGET released in version 8.5 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'WGET_EXE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''
	COMPUTER=GET_COMPUTER()

	IF N_ELEMENTS(HTML) EQ 0 OR N_ELEMENTS(FILES) EQ 0 THEN STOP
	IF N_ELEMENTS(DIR_HTML) EQ 0 THEN DIR_HTML=''
	_FILES = HTML+DIR_HTML+FILES

	IF N_ELEMENTS(MIN_SIZE) NE 1 THEN _MIN_SIZE = 1 ELSE _MIN_SIZE = MIN_SIZE
	IF N_ELEMENTS(DIR_LOCAL) EQ 0 THEN _DIR_LOCAL = !S.DATASETS ELSE _DIR_LOCAL = DIR_LOCAL
	IF N_ELEMENTS(ACCOUNT) EQ 0 THEN ACCOUNT = ''
	IF N_ELEMENTS(PASSWORD) EQ 0 THEN PASSWORD = ''
	IF KEYWORD_SET(OVERWRITE) THEN _OVERWRITE = 1 ELSE _OVERWRITE = 0
	
	GET_FILES = []

	
	IF N_ELEMENTS(GET_N_FILES) EQ 0 THEN N_FILES = N_ELEMENTS(_FILES) ELSE N_FILES = GET_N_FILES
	IF N_FILES GT N_ELEMENTS(_FILES) THEN N_FILES = N_ELEMENTS(_FILES)
	IF KEYWORD_SET(SORT_REVERSE) THEN _FILES = REVERSE(_FILES)
;	PRINT & PRINT, 'Getting ' + NUM2STR(N_FILES) + ' files from remote system' & PRINT

	CD, CURRENT=OLD_DIR

	FOR NTH=0L, N_FILES-1 DO BEGIN

		AFILE = _FILES[NTH]
		IF NTH EQ 0 THEN GET_FILES = AFILE ELSE GET_FILES = [GET_FILES,AFILE]
	;	PRINT & PRINT, 'DOWNLOADING ' + AFILE + ' ON ' + SYSTIME() + ' (Number ' + NUM2STR(NTH+1) + ' of ' + NUM2STR(N_FILES) + ' files)' & PRINT
		NEW_DIR = _DIR_LOCAL
		CD, NEW_DIR
		IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN
			CMD = 'wget -c -N ' + AFILE + ' --user=' + ACCOUNT + ' --password=' + PASSWORD
			IF _OVERWRITE EQ 1 THEN CMD = 'wget -c -N -r' + AFILE + ' --user=' + ACCOUNT + ' --password=' + PASSWORD
      PRINT, CMD			
			SPAWN, CMD, RESULT
		ENDIF
		CD, OLD_DIR
	ENDFOR


	DONE:

END; #####################  End of Routine ################################
