; $ID:	SAVE_2CSV.PRO,	2023-09-21-13,	USER-KJWH	$

PRO SAVE_2CSV, Files

;+
;	This Program Writes a Comma-Delimited CSV file from an IDL Simple (Spreadsheet) Structure in a SAVE File
; SYNTAX:
;		SAVE_2CSV, Files
; ARGUMENTS:
; 	Files:	IDL Save Files Containing one Structure that was Saved using SAVE
; EXAMPLE:
;  	Struct = CREATE_STRUCT('AA',0B,'BB',1,'CC',2L,'DD',3.0,'EE',4.0D)
;  	Struct = Replicate(Struct,10)
;  	SAVE,Filename='TEST.SAVE', Struct ,/compress
;   SAVE_2CSV,'TEST.SAVE'
;
; 	Open file with Excel or Word Processor ... it should look like this ...
;		AA,BB,CC,DD,EE
;		0,1,2,3.000000,4.000000000000000
; VERSION:
;		Jan 22,2001
; HISTORY:
;		Oct 12,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Jun 30, 2020 - KJWH: Added COMPILE_OPT IDL2
;		                     Changed subscripts from () to []
;-
; *************************************************************************

  ROUTINE_NAME='SAVE_2CSV'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(FILES) LT 1 THEN $
  FILES = DIALOG_PICKFILE(FILTER='*.SAVE',TITLE='Pick  SAVE Files',/MULTIPLE_FILE)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _FILE=0L,N_ELEMENTS(FILES)-1L DO BEGIN
   	AFILE = FILES[_FILE]
   	S			=	IDL_RESTORE(AFILE)
   	TXT 	=	STRUCT_2STRING(S,/HEADING)
   	FN		=	FILE_PARSE(AFILE)

   	OUTFILE=FN.DIR+FN.NAME+'.CSV'
   	OPENW,LUN,OUTFILE,/GET_LUN

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
   	FOR N=0L,N_ELEMENTS(TXT)-1L DO BEGIN
     	PRINTF,LUN,TXT[N]
   	ENDFOR
   	CLOSE,LUN
   	FREE_LUN,LUN
  ENDFOR
 END; #####################  End of Routine ################################
