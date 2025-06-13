; $Id: DEMO_ON_IOERROR.pro $
;+
;	This Program Demonstrates the use of ON_IOERROR
; SYNTAX:
;		DEMO_IO_ERROR
;
; OUTPUT:
;		SCREEN
; ARGUMENTS:
;
; KEYWORDS:

; EXAMPLE:
;		DEMO_IO_ERROR
; CATEGORY:
;		FILES
; NOTES:
; VERSION:
;		May 7,2001
; HISTORY:
;		May 7,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO DEMO_ON_IOERROR
  ROUTINE_NAME='DEMO_ON_IOERROR'
 DIR='D:\IDL\PROGRAMS\'
   OPENW,LUN,DIR+'JUNK1.TXT',/GET_LUN
   PRINTF,LUN,'GOOD FILE'
   CLOSE,LUN & FREE_LUN,LUN

	 OPENW,LUN,DIR+'JUNK2.TXT',/GET_LUN
   CLOSE,LUN & FREE_LUN,LUN

   FILES = [DIR+'junk1.txt',DIR+'junk2.txt',DIR+'junk2.txt',DIR+'junk1.txt',DIR+'junk1.txt']
  TXT = ''

  IO_ERROR_CODE = 0
  ON_IOERROR, IO_ERROR
  FOR N=0,N_ELEMENTS(FILES)-1L DO BEGIN
    openr,lun,FILES(N),/GET_LUN
    READF,LUN,TXT

    GOTO, IO_GOOD
    IO_ERROR:

      IO_ERROR_CODE = 1
      PRINT, FILES(N) , '    ','ERROR: '+NUM2STR(IO_ERROR_CODE)
      CONTINUE
    IO_GOOD:
      IO_ERROR_CODE = 0
       PRINT, FILES(N) , '    ','ERROR: '+NUM2STR(IO_ERROR_CODE)
  ENDFOR



END; #####################  End of Routine ################################

