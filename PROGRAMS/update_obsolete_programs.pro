; $ID:	UPDATE_OBSOLETE_PROGRAMS.PRO,	2020-06-26-15,	USER-KJWH	$

  PRO UPDATE_OBSOLETE_PROGRAMS,DIR_PROGRAMS=DIR_PROGRAMS,DIR_OBSOLETE=DIR_OBSOLETE

;+
; NAME:
;   UPDATE_OBSOLETE_PROGRAMS
;
; PURPOSE:
;   This procedure determines if there are programs in the IDL PROGRAMS directory that are present in the OBSOLETE directory copied from another computer 
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;
; INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   This function moves 'obsolete' programs from the main PROGRAMS directory to the OBSOLETE directory
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;			Written:  April 27, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 13, 2014   by K.J.W. Hyde - Changed DIR_OBSOLETE to !S.OBSOLETE 
;			Modified: Nov 20, 2014   by K.J.W. Hyde - Added logic to work with an obsolete text file
;			ModifiedL Nov 24, 2015   by K.J.W. Hyde - Added STRUPCASE to find matching program names
;			                                          Added capability to work with OBSOLETE files from different USERS
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'UPDATE_OBSOLETE_PROGRAMS'
	SL = DELIMITER(/PATH)
	USR = !S.USER
	 
	IF N_ELEMENTS(DIR_PROGRAMS) NE 1 THEN DIR_PROGRAMS = !S.PROGRAMS
	IF N_ELEMENTS(DIR_OBSOLETE) NE 1 THEN DIR_OBSOLETE = !S.IDL_OBSOLETE
	DIR_OBSOLETE_PROGRAMS = DIR_OBSOLETE + 'PROGRAMS_OBSOLETE' + SL

; ===> LOOK AT LOCAL-USER FILE FIRST	
	OPROS = FILE_PARSE(FILE_SEARCH(DIR_OBSOLETE_PROGRAMS +'*.pro*'))       ; Parse programs in the programs obsolete directory
	OBS   = OPROS.NAME_EXT 
	OFILE = DIR_OBSOLETE+'OBSOLETE_' + USR + '.txt'                                          ; File name for local user         
	IF FILE_TEST(OFILE) EQ 0 THEN WRITE_TXT, OFILE, OBS ELSE	OBS = READ_TXT(OFILE)          ; If there is no OBSOLETE_.txt, then write text file
	IF N_ELEMENTS(OPROS) GT N_ELEMENTS(OBS) THEN WRITE_TXT, OFILE, OPROS.NAME                ; If there are more obsolete programs in the directory compared to the obsolete list, update the obsolete text file
	
	PROS = FILE_PARSE(FILE_SEARCH(DIR_PROGRAMS + '*.*'))                                     ; Find all files in the PROGRAMS directory	
	OK = WHERE_MATCH(STRUPCASE(PROS.NAME),STRUPCASE(OBS),COUNT,COMPLEMENT=COMPLEMENT)        ; See if there are any "obsolete" files still in the PROGRAMS directory
	IF COUNT GE 1 THEN FILE_MOVE,PROS[OK].FULLNAME,DIR_OBSOLETE,/OVERWRITE,/VERBOSE ELSE $   ; Move "obsolete" files to the OBSOLETE directory
	PRINT, 'All OBSOLETE files in ' + OFILE + ' are up to date'
	
		
; ===> THEN SEARCH THROUGH OTHER NON-LOCAL FILES	
	FILES = FILE_SEARCH(DIR_OBSOLETE + 'OBSOLETE_*.txt')                                     ; Find all OBSOLETE_*.txt files
	FILES = FILES(WHERE(FILES NE OFILE,/NULL,COUNT))	                                       ; Find all non-local user OBSOLETE files (e.g. OBSOLETE_JOR.txt)
	
	FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN                                                    ; Loop through all non-local user OBSOLETE files 
    OBS = READ_TXT(FILES(F))                                                               ; Read file
    FPO = FILE_PARSE(OBS)                                                                  ; Parse the file names
    OK = WHERE(FPO.EXT EQ '',COUNT)                                                        ; Find files that are missing the .pro extension
    IF COUNT GE 1 THEN OBS[OK] = OBS[OK] + '.pro'                                          ; Add .pro where needed
    PROS = FILE_PARSE(FILE_SEARCH(DIR_PROGRAMS + '*.*'))                                   ; Find all files in the PROGRAMS directory 
    OK = WHERE_MATCH(STRUPCASE(PROS.NAME_EXT),STRUPCASE(OBS),COUNT,COMPLEMENT=COMPLEMENT)  ; See if there are any "obsolete" files still in the PROGRAMS directory
    IF COUNT GE 1 THEN FILE_MOVE,PROS[OK].FULLNAME,DIR_OBSOLETE_PROGRAMS,/OVERWRITE,/VERBOSE ELSE $ ; Move "obsolete" files to the OBSOLETE directory
      PRINT, 'All OBSOLETE files in ' + OFILE + ' are up to date'
  ENDFOR

END; #####################  End of Routine ################################



