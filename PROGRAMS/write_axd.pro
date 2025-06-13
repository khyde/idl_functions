; $Id: WRITE_AXD.pro,v 1.0 DEC 29,1998 J.E.O'Reilly Exp $

PRO WRITE_AXD,file,arr
;+
; NAME:
;       WRITE_AXD
;
; PURPOSE:
;       Write an idl array where the dimensions from a SIZE command
;       preceed the actual array data
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       WRITE_AXD,'D:\IDL\JAY\DATA.ARR',ARR
;
; INPUTS:
;       AN IDL ARRAY
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       AN 'AXD' TYPE FILE
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
;
;-



; ====================>
; ARR (IDL ARRAY TYPES WHERE A LONG ARRAY FROM IDL SIZE COMMAND PRECEEDS DATA
;      AND IS USED TO INSTRUCT HOW TO READ AND BUILD THE ARRAY FROM THE ARR FILE)

  IF N_ELEMENTS(FILE) NE 1 THEN STOP
  IF N_ELEMENTS(ARR) LT 1 THEN STOP

    OPENW,lun,file,/GET_LUN,/XDR
    WRITEU,lun,SIZE(ARR)
    WRITEU,lun, arr
    CLOSE,LUN
    FREE_LUN,LUN
  END ; OF PROGRAM
