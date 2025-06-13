; $ID:	CPAL_WRITE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CPAL_WRITE, PAL, R, G, B

;+
; NAME:
;   CPAL_WRITE
;
; PURPOSE:
;   Program Writes palette rgb's to a palette file which may be subsequently used as a palette program. 
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   PALS_WRITE, PAL, R, G, B
;
; REQUIRED INPUTS:
;   PAL.......... The name of the color palette
;   R............ The RED color values in the palette
;   G............ The GREEN color values in the palette
;   B............ The BLUE color values in the palette
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   OVERWRITE..... Overwrite the file if it already exists
;
; OUTPUTS:
;   OUTPUT........ A pal_*.pro file contains a 3x256 array of RGB values
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
;   PALS_WRITE, PAL, R, G, B
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 14, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 14, 2021 - KJWH: Initial code written - adapted from WRITEPAL
;   Apr 15, 2021 - KJWH: Changed name to CPAL_WRITE
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_WRITE'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(R) NE 256 OR N_ELEMENTS(G) NE 256 OR N_ELEMENTS(B) NE 256 THEN MESSAGE, 'ERROR: Must provide 256 element arrays for R, G, and B'
  IF N_ELEMENTS(PAL) NE 1 THEN MESSAGE, 'ERROR: Must input palette name'
  
  FP = FILE_PARSE(PAL)
  FILE = !S.PALETTE_FUNCTIONS + STRLOWCASE(PAL) + '.pro'
 
  PRINT, 'Making Palette Program: ', file
  
  OPENW,LUN,FILE,/GET_LUN

  PRINTF, LUN, 'PRO ' + PAL + ' , R, G, B'
  PRINTF, LUN, 'R=BYTARR(256) & G=BYTARR(256) & B=BYTARR(256) '

  FOR I = 0, N_ELEMENTS(R)-1 DO PRINTF, LUN, 'R[',i,']=', r[i],' & ','G[',i,']=', g[i],' & ','B[',i,']=', b[i],' & ', FORMAT='(3(A2,I3,A2,I3,A3))'
  
  PRINTF, LUN, 'TVLCT,R,G,B'
  PRINTF, LUN, 'END'
  FREE_LUN, LUN
  CLOSE, LUN
  
END ; ***************** End of CPAL_WRITE *****************
