; $Id: IMAGE_WELD_3X4.pro $
;+
;	This Program Generates a formatted request list for daac of the hrpt target files
; SYNTAX:
;	IMAGE_WELD_3X4, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = IMAGE_WELD_3X4(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;
; NOTES:

; VERSION:
;	Jan 01,2001
; HISTORY:
;	Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO IMAGE_WELD_3X4,FILES
  ROUTINE_NAME='IMAGE_WELD_3X4'

  COMPOSITE = PAGE(*,*,0)
   ROWS = 4
   COLS = 3
   NTH = -1
   FOR _ROW = 0,ROWS-1
 	 	FOR _COL = 0,COLS-1 DO BEGIN
 	 	  NTH = NTH+1
      IMAGE = REFORM(PAGE(*,*,NTH))
      IF NTH EQ 0 THEN IMAGE_ROW = IMAGE ELSE IMAGE_ROW = IMAGE_WELD(IMAGE_ROW,,

   ENDFOR


END; #####################  End of Routine ################################
