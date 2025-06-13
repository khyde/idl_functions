; $ID:	MAT_PAL2IDL.PRO,	2020-06-30-17,	USER-KJWH	$

PRO mat_pal2idl,file
;+
; NAME:
;       mat_pal2idl
;
; PURPOSE:
;       convert a MATLAB pallete array into an idl palette program
;
; CATEGORY:
;       Palette
;
; CALLING SEQUENCE:
;       mat_pal2idl,file
;
; INPUTS:
;       a matlab palette file (256 rows of r,g,b triplets)
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       a *.PRO FILE FOR USE IN IDL
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
;       Written by:  J.E.O'Reilly, Feb 11,1999
;-
  FILE = 'D:\IDL\JAY\PALETTES\freqpal3.pal'

stop
 IF N_ELEMENTS(FILE) NE 1 THEN FILE = DIALOG_PICKFILE()

 PRINT, 'INPUT MATLAB PALETTE FILE: ',FILE
 _R = 0D
 _G = 0D
 _B = 0D

 R = FLTARR(256)
 G = FLTARR(256)
 B = FLTARR(256)
 TXT =''
 OPENR,LUN,FILE,/GET_LUN
 FOR NTH = 0,255 DO BEGIN
  READF,LUN,TXT
  READS,TXT,_R,_G,_B
  R[NTH]=_R
  G[NTH]=_G
  B[NTH]=_B
 ENDFOR
 CLOSE,LUN

; ==============>
; Convert the matlab values (0 to 1.0) to 0-255
  R = BYTE(ROUND(255.0*R))
  G = BYTE(ROUND(255.0*G))
  B = BYTE(ROUND(255.0*B))

; ==============>
; Write the pal file program
  WRITEPAL,R,G,B

; ===============>
  END ; END OF PROGRAM
