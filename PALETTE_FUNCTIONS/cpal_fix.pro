; $ID:	CPAL_FIX.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO CPAL_FIX, PAL, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_FIX
;
; PURPOSE:
;   Program to change the subscripts in pal_*.pro files from () to [] and add default documentation
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   CPAL_FIX
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   PAL.......... The name of the pal_*.pro file
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   OUTPUT.......... Updated pal_*.pro files
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
; 
;
; NOTES:
;   $Citations or any other useful notes$
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
;   Apr 14, 2021 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'CPAL_FIX'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  FILES = GET_PROGRAMS('pal_*',DIR_PRO=!S.IDL_PALETTES+'PALS'+SL)
  
  FOR F=0, N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES[F]
    OFILE = REPLACE(AFILE,!S.IDL_PALETTES+'PALS'+SL,!S.PALETTE_FUNCTIONS)
    IF FILE_MAKE(AFILE,OFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
    TXT = READ_TXT(AFILE)
    IF MAX(STRPOS(TXT,'R=BYTARR(256)')) EQ -1 THEN MESSAGE, 'ERROR: Check ' + AFILE
    IF MAX(STRPOS(TXT,'R(')) EQ -1 THEN MESSAGE, 'ERROR: Check ' + AFILE
    IF MAX(STRPOS(TXT,'G(')) EQ -1 THEN MESSAGE, 'ERROR: Check ' + AFILE
    IF MAX(STRPOS(TXT,'B(')) EQ -1 THEN MESSAGE, 'ERROR: Check ' + AFILE
    
    TXT = REPLACE(TXT,['R(','G(','B(',')='],['R[','G[','B[',']='])
    TXT = REPLACE(TXT,['BYTARR['],['BYTARR('])
    
    OK = WHERE_STRING(TXT,'(',COUNT)
    IF COUNT GT 3 THEN MESSAGE, 'ERROR: Check ' + AFILE, /INFORMATIONAL
    
    WRITE_TXT,OFILE,TXT
    FILE_DOC, OFILE  
    
    
  ENDFOR


STOP

END ; ***************** End of PALS_FIX *****************
