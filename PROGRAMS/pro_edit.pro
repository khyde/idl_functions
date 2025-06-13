; $Id: PRO_EDIT.pro $
;+
;	This Program Edits idl program files
; SYNTAX:
;	PRO_EDIT, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = PRO_EDIT(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
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
;	DT
; NOTES:
; VERSION:
;	Jan 01,2001
; HISTORY:
;	Jan 1,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO PRO_EDIT, files, ADD_TABS=add_tabs
  ROUTINE_NAME='PRO_EDIT'
  FOR _file = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
    afile = files(_file)
    FN=PARSE_IT(afile)
    bfile = FN.DIR + FN.NAME + '_#.PRO'
    LINES = READALL(AFILE,TYPE='TXT')
    TEXT  = STRARR(N_ELEMENTS(LINES))

    IF N_ELEMENTS(ADD_TABS) EQ 0 THEN _ADD_TABS = 0 ELSE _ADD_TABS = FIX(ADD_TABS)
    PRINT, _ADD_TABS



;   ===================> Substitute a tab for 2 spaces (but only spaces leading the line)
    FOR _lines = 0L,N_ELEMENTS(lines)-1L DO BEGIN

      ALINE = LINES(_lines)
      bline = STRTRIM(ALINE,1)
      LEN_A=STRLEN(ALINE)
      LEN_B=STRLEN(BLINE)
      TXT_START = STRMID(ALINE,0,LEN_A-LEN_B)
      TXT_END   = STRMID(ALINE,LEN_A-LEN_B)
      OK = WHERE(BYTE(txt_start) EQ 9,OLD_TABS)
      NEW_TABS = ( STRLEN(TXT_START)- (OLD_TABS))    /2
      ALL_TABS = NEW_TABS+OLD_TABS+ _ADD_TABS
      IF ALL_TABS GE 1 THEN TAB_STRING= STRJOIN(REPLICATE(STRING(9B),ALL_TABS)) ELSE TAB_STRING = ''

      TEXT(_lines) = TAB_STRING + TXT_END
      ;HELP, ALINE,BLINE,TXT_START,TXT_END,OLD_TABS,NEW_TABS,TAB_STRING, TEXT(_lines)


    ENDFOR


;
    WRITE_TXT,BFILE,TEXT
  ENDFOR
END; #####################  End of Routine ################################
