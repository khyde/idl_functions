; $ID:	TEXT_EDIT.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program Aids in the BATCH Editing (substitution) of idl programs
;	EXAMPLE:
;  TEXT_EDIT, 'D:\IDL\PROGRAMS\*.PRO', "DELIMITER('LABEL')", "DELIMITER('DASH')"
; HISTORY:
;		June 13, 2003	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO TEXT_EDIT,TARGET_FILES, OLD, NEW
  ROUTINE_NAME='TEXT_EDIT'
 ; TARGET_FILES = 'D:\IDL\PROGRAMS\*.PRO'

	FILES = FILELIST(TARGET_FILES)

  IF N_ELEMENTS(FILES) EQ 0 THEN GOTO, DONE
  IF N_ELEMENTS(OLD) NE 1   OR N_ELEMENTS(NEW) NE 1 THEN GOTO, DONE


  FOR _FILE = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
	  AFILE = FILES(_FILE)
	  TXT = READALL(AFILE,TYPE='TXT')
	  OK = WHERE(STRPOS(STRUPCASE(TXT),OLD) GE 0,COUNT)

	  IF COUNT GE 1 THEN BEGIN
	  	TRUE_EDIT = 0
	    PRINT, NUM2STR(COUNT) + ' FINDS OF  ' + OLD + ' IN: ' + AFILE
	    PRINT, TXT[OK]
	    FOR NTH = 0L, COUNT-1L DO BEGIN
	    	Q = 'Want to REPLACE '+old + '  With ' + new
	  		YN = DIALOG_MESSAGE(Q, /QUESTION)

	  		IF STRUPCASE(YN) EQ 'YES' THEN BEGIN
	  		  TRUE_EDIT = 1
	  			TXT(OK[NTH]) = REPLACE(TXT(OK[NTH]), OLD,NEW)
	  			PRINT,'After Editing'

	  			PRINT, TXT(OK[NTH])
	  		ENDIF
	  	ENDFOR

;			===> Write out new file
			IF TRUE_EDIT EQ 1 THEN WRITE_TXT,afile,TXT
	  ENDIF

	ENDFOR
DONE:
END; #####################  End of Routine ################################
