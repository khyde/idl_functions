; $Id: WRITE_ARR.pro,v 1.0 DEC 29,1998 J.E.O'Reilly Exp $

PRO WRITE_ARR,file,arr
;+
; NAME:
;       WRITE_ARR
;
; PURPOSE:
;       Write an idl array where the dimensions from a SIZE command
;       preceed the actual array data
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       WRITE_ARR,'D:\IDL\JAY\DATA.ARR',ARR
;
; INPUTS:
;       AN IDL ARRAY
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       AN 'ARR' TYPE FILE
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Nov 27,1998
;       Dec 29,1998 now write a -1 (pc) or -2(irix) long in first position
;-



; ====================>
; ARR (IDL ARRAY TYPES WHERE A LONG ARRAY FROM IDL SIZE COMMAND PRECEEDS DATA
;      AND IS USED TO INSTRUCT HOW TO READ AND BUILD THE ARRAY FROM THE ARR FILE)

  IF N_ELEMENTS(FILE) NE 1 THEN STOP
  IF N_ELEMENTS(ARR) LT 1 THEN STOP

    OPENW,lun,file,/GET_LUN
    IF !VERSION.OS EQ 'Win32' THEN SYS = -1L
    IF !VERSION.OS EQ 'IRIX'  THEN SYS = -2L
    IF !VERSION.OS EQ 'OSF'   THEN SYS = -2L
    WRITEU,lun,SYS
    WRITEU,lun,SIZE(ARR)
    WRITEU,lun, arr
    CLOSE,LUN
    FREE_LUN,LUN
  END ; OF PROGRAM
