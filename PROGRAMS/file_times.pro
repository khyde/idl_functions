; $ID:	FILE_TIMES.PRO,	2017-02-21,	USER-KJWH	$
; #########################################################################; 
PRO FILE_TIMES, FILE
;+
; PURPOSE:  PRINTS, CTIME, MTIME, ATIME AND THEIR DATE VALUES
;
; CATEGORY: DATE TIME
;
;
; INPUTS: FILE
;
;
; KEYWORDS:  NONE

; OUTPUTS: PRINTS,NAME, CTIME,MTIME,ATIME AND THEIR DATE VALUES 
;
;; EXAMPLES:
;
; MODIFICATION HISTORY:
;     FEB 18, 2017  WRITTEN BY: J.E. O'REILLY
;     FEB 21, 2017 - KJWH: Formatting
;-
; #########################################################################

; **********************
  ROUTINE = 'FILE_TIMES'
; **********************
  IF NONE(FILE) THEN FILE = DIALOG_PICKFILE(TITLE = 'SELECT FILE TO EXAMINE')
  NAME = (FILE_PARSE(FILE)).NAME
  F = FILE_INFO(FILE)
  D_ATIME = DATE_FORMAT(MTIME_2DATE(F.ATIME),UNITS='SECOND')
  D_CTIME = DATE_FORMAT(MTIME_2DATE(F.CTIME),UNITS='SECOND')
  D_MTIME = DATE_FORMAT(MTIME_2DATE(F.MTIME),UNITS='SECOND')
  PRINT, NAME, '    MTIME: ', F.MTIME, '    MDATE:    ', D_MTIME
  PRINT, NAME, '    ATIME: ', F.ATIME, '    ADATE:    ', D_ATIME
  PRINT, NAME, '    CTIME: ', F.CTIME, '    CDATE:    ', D_CTIME

END; #####################  END OF ROUTINE ################################
