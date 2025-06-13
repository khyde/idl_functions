; $Id: file_look.pro,  Oct 1,2000 J.E.O'Reilly

 pro file_look,file, BLOCK=block
;+
; NAME:
;       file_look
;
; PURPOSE:
;       look at a file and display data using different data types
;       to determine the formating and parsing of the file
;       (exploration tool)
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       file_look,file
;
; INPUTS:
;       a file name
;
; KEYWORD PARAMETERS:
;       block: number of bytes to read
; OUTPUTS:
;       screen
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
;       Written by:  J.E.O'Reilly, Oct 1,2000
;-
;
;-

  IF N_ELEMENTS(BLOCK) NE 1 THEN BLOCK = 80

block=8
  ;file='d:\idl\jay\test.txt'
  IF N_ELEMENTS(FILE) NE 1 THEN FILE = DIALOG_PICKFILE(TITLE='PICK A FILE')
; ================>
; Dimension some idl variables of varying type
  b=BYTARR(BLOCK)
  I=INTARR(BLOCK/2)
  L=LONARR(BLOCK/4)
  F=FLTARR(BLOCK/4)
  D=DBLARR(BLOCK/8)

  OPENR,LUN,FILE,/GET_LUN
  READU,LUN,B
  POINT_LUN,LUN,0L
  READU,LUN,I
  POINT_LUN,LUN,0L
  READU,LUN,L
  POINT_LUN,LUN,0L
  READU,LUN,F
  POINT_LUN,LUN,0L
  READU,LUN,D


STOP
  FMTA = '(A12,'+ NUM2STR(BLOCK)+'I3,1X)'
  FMT = '(A12,'+ NUM2STR(BLOCK)+'I7)'
  print,'Str:______', STRING(B)
  print,'Byt:______',B,  FORMAT=FMTA

  print,'Int:______', i,FORMAT=FMT
   II=I& BYTEORDER,II,/SSWAP
  PRINT,'Int SSWAP:',ii,FORMAT=FMT


STOP
  print,'Lon:', l
  print,'Flt:', f
  print,'Dbl:', d

  print
  PRINT, 'After Application of BYTEORDER:'

; REGULAR BYTORDER

  LL=L& BYTEORDER,LL
  FF=F& BYTEORDER,FF
  DD=D& BYTEORDER,DD
  print,'Int:', ii
  print,'Lon:', ll
  print,'Flt:', ff
  print,'Dbl:', dd


; BYTORDER WITH SWAP

  LL=L& BYTEORDER,LL,/LSWAP
  FF=F& BYTEORDER,FF,/FTOXDR
  DD=D& BYTEORDER,DD,/DTOXDR


print,'Byt:', b
  print,'Str:',STRING(B)
  print,'Int:', i
  print,'Lon:', l
  print,'Flt:', f
  print,'Dbl:', d
  print,'Int SSWAP:', ii
  print,'Lon LSWAP:', LL
  print,'Flt FTOXDR:', ff
  print,'Dbl DTOXDR:', dd

  CLOSE,LUN
  FREE_LUN,LUN
  END ; OF PROGRAM
