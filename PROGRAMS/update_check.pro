; $ID:	UPDATE_CHECK.PRO,	2014-12-09	$

  FUNCTION UPDATE_CHECK, INFILES=INFILES, OUTFILES=OUTFILES, OVERWRITE=OVERWRITE

;+
; NAME:
;   UPDATE_CHECK
;
; PURPOSE:
;   This function will determine if the output file(s) is newer than the input file(s)
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;
;   Result = UPDATE_CHECK(INFILES,OUTFILE)
;
; INPUTS:
;   INFILES:  Array of all input files
;   OUTFILES: Array of all output files
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns 0 if the output files are newer than then input files and it is not necessary to reprocess
;   This function returns 1 if the output files do not exist or are older than then input files and the output files need to be recreated
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;   UPDATE = FILE_UPDATE(INFILES,OUTFILES,OVERWRITE=OVERWRITE)
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;			Written:  Dec 16, 2013 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Dec 9,  2014 by KJWH: Added OVERWRITE keyword 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'UPDATE_CHECK'
	
  IF N_ELEMENTS(INFILES) EQ 0 THEN RETURN, 0      ; No input files given so UPDATE = 0 
  IF N_ELEMENTS(OUTFILES) EQ 0 THEN RETURN, 1     ; No output files given so UPDATE = 1 
  IF KEY(OVERWRITE) THEN RETURN, 1                ; Overwrite file so UPDATE = 1
  IF MIN(FILE_TEST(OUTFILES)) EQ 0 THEN RETURN, 1 ; At least one of the output files is missing so UPDATE = 1
  IF MIN(GET_MTIME(OUTFILES)) GT MAX(GET_MTIME(INFILES)) THEN RETURN, 0 ELSE RETURN, 1
   
END; #####################  End of Routine ################################
