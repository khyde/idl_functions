; $ID:	READ_TXT.PRO,	2016-07-07,	USER-KJWH	$
;+
;	This Function Reads a TXT (ascii text) file and returns a string array

;	Result = READ_TXT(File)
;
; ARGUMENTS:
; 	File:	Full path and name of ascii file
;
; EXAMPLE:
;	Result = READ_TXT('D:\IDL\TEST.TXT')
;
; HISTORY:
;	  Jan 10, 2001	Written by:	J.E. O'Reilly
;	  Mar 08, 2016 - KJWH: Added an ERROR message if there are 0 lines in the file
;	  Jul 07, 2-16 - KJWH: Added an ERROR message if the file does not exist 
;-
; *************************************************************************

FUNCTION READ_TXT,FILE
  ROUTINE_NAME='READ_TXT'
  IF N_ELEMENTS(FILE) EQ 0 THEN FILE = DIALOG_PICKFILE()

  IF FILE_TEST(FILE) EQ 0 THEN BEGIN
    PRINT, 'ERROR: ' + FILE + ' does not exist'
    RETURN, []
  ENDIF

; ===> Determine number of lines in the file
  N_LINES= FILE_LINES(FILE)
  
  IF N_LINES EQ 0 THEN BEGIN
    PRINT, 'ERROR: There are 0 lines in ' + FILE
    RETURN, [] 
  ENDIF

; ===> Read the TEXT file
  OPENR,LUN,FILE,/GET_LUN
    txt = ''
    all = REPLICATE(txt,N_LINES)
    LINE = -1L

;   WWWWWWWWWWWWWWWWWWWWWWWWWWW
    WHILE NOT EOF(LUN) DO BEGIN
      READF,LUN,txt
      LINE = LINE + 1L
      all(line) = txt
    ENDWHILE

    CLOSE,LUN & FREE_LUN,LUN

  RETURN,ALL

END; #####################  End of Routine ################################
