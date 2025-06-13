; $ID:	SATSHIP_MATCHUP_2CSV.PRO,	2016-03-18,	USER-KJWH	$

PRO SATSHIP_MATCHUP_2CSV, FILES, DIR_OUT=DIR_OUT, STRUCT_TAGS=STRUCT_TAGS, OUTFILES=OUTFILES

;+
;	NAME:
;	  SATSHIP_MATCHUP_2CSV
;	
;	PURPOSE:
;	  This program converts a SATSHIP structure with arrays to a .csv file 
;
; SYNTAX:
;		SATSHIP_2CSV, FILES
;		
; REQUIRED_INPUTS:
; 	Files:	IDL save files containing a SATSHIP structure 
; 	
; EXAMPLE:
;  	SATSHIP = SATSHIP_HDF()
;  	SAVE, FILENAME='SATSHIP.SAV', SATSHIP, /COMPRESS
;   SATSHIP_2CSV,'SATSHIP.SAV'
;
; VERSION:
;		May 8, 2015
;		
; HISTORY:
;		May 8, 2015	Written by:	K.J.W. Hyde, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Jul 29, 2015 - KJWH: Added DIR_OUT keyword
;	  Mar 18, 2016 - KJWH: Changed DATATYPE to IDLTYPE
;-
; *************************************************************************


  ROUTINE_NAME='SATSHIP_MATCHUP_2CSV'

  IF N_ELEMENTS(FILES) LT 1 THEN $
  FILES = DIALOG_PICKFILE(FILTER='*.SAV*',TITLE='Pick  SAVE Files',/MULTIPLE_FILE)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _FILE=0L,N_ELEMENTS(FILES)-1L DO BEGIN
   	AFILE = FILES[_FILE]
   	FN    = FILE_PARSE(AFILE)
   	IF NONE(DIR_OUT) OR DIR_OUT EQ '' THEN DIR = FN.DIR ELSE DIR = DIR_OUT & DIR_TEST, DIR     ; Check for output directory
   	STRUCT =	IDL_RESTORE(AFILE)
   	IF NONE(STRUCT_TAGS) THEN TAGS = TAG_NAMES(STRUCT) ELSE TAGS = STRUCT_TAGS                 ; Get tag names
   	IF N_ELEMENTS(OUTFILES) NE N_ELEMENTS(TAGS) THEN OUTFILES = []
   	FOR N=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                                       ; Loop on tags
   	  POS = WHERE(TAG_NAMES(STRUCT) EQ TAGS[N],COUNT)
   	  IF COUNT EQ 0 THEN CONTINUE
   	  IF IDLTYPE(STRUCT.(POS)) NE 'STRUCT' THEN CONTINUE                                         ; If data are not a structure then skip
   	  IF NONE(OUTFILES) THEN OUTFILE=DIR+FN.NAME+'-'+TAGS[N]+'.csv' ELSE OUTFILE = OUTFILES[N]   ; Create output csv name
      CSV_WRITE,OUTFILE,STRUCT.(POS)                                                             ; Write out data structure
    ENDFOR
  ENDFOR
 END; #####################  End of Routine ################################
