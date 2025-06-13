; $Id:	read_txt.pro,	November 09 2006	$
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
;	Jan 10,2001	Written by:	J.E. O'Reilly
;-
; *************************************************************************

FUNCTION READ_TXT,FILE
  ROUTINE_NAME='READ_TXT'
  IF N_ELEMENTS(FILE) EQ 0 THEN FILE = DIALOG_PICKFILE()

; ===> Determine number of lines in the file
  N_LINES= FILE_LINES(FILE)

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
