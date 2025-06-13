; $Id: FILE_LINE_COUNT.pro $
;+
;	This Function Counts the Number of Lines in an Ascii File with Carriage Returns/Line Feeds
; SYNTAX:
;	Result = FILE_LINE_COUNT(File)
; OUTPUT:
;	Number of Lines
; ARGUMENTS:
; 	File:	An ascii file
; KEYWORDS:
; EXAMPLE:
;				Result = FILE_LINE_COUNT('C:\TEST.TXT')
; CATEGORY:
;	FILES
; NOTES:
; VERSION:
;		June 21,2001
; HISTORY:
;	Mar 7, 2000	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION FILE_LINE_COUNT, File
  ROUTINE_NAME='FILE_LINE_COUNT'


  IF N_ELEMENTS(File) NE 1 THEN BEGIN
    PRINT,'ERROR: A Complete File Name is Required'
    RETURN, -1
  ENDIF

; ===================>
; Open file for reading
  ON_IOERROR, DONE
	OK_IO = 0

  OPENR, LUN, FILE,/GET_LUN
  TXT =''
  COUNT = 0L
  WHILE NOT EOF(LUN) DO BEGIN
    READF,LUN,TXT
    COUNT = COUNT + 1L
  ENDWHILE
  OK_IO = 1

  DONE:
  IF OK_IO EQ 1 THEN BEGIN
    CLOSE,LUN
    FREE_LUN,LUN
  ENDIF
  RETURN,COUNT
  END; #####################  End of Routine ################################
