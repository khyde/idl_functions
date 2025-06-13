; $ID:	WRITE_TXT.PRO,	2023-09-19-17,	USER-KJWH	$
;+
PRO WRITE_TXT, FILE, TXT

;+
; NAME:
;   WRITE_TXT
;
; PURPOSE:
;   This Program Writes a String Array to a txt file
;
; CATEGORY:
;   FILE
;
; CALLING SEQUENCE:
;   WRITE_TXT, FILE, TXT
;
; INPUTS:
;   FILE...... The complete name of the output file
;   TXT....... The text to written out in the file
;
; OPTIONAL INPUTS:
;   None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   An ascii text file
;
; EXAMPLE:
;  WRITE_TXT, !S.IDL_TEMP + 'write_text_example.txt', 'This is a example file for WRITE_TXT'
;
; NOTES:
;  Works with simple String Arrays   
;
; COPYRIGHT:
; Copyright (C) 2001, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 12, 2001 by J.E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;   Inquiries on this code should be directed to: kimberly.hyde@noaa.gov
;   
; MODIFICATION HISTORY:
;   Mar 12, 2001 - JEOR: Wrote initial code 
;   Nov 07, 2013 - JEOR: Changed TEXT to TXT
;   Jun 26, 2020 - KJWH: Updated documentation
;   Jul 01, 2020 - KJWH: Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;-
; ****************************************************************************************************

  ROUTINE_NAME = 'WRITE_TXT'
  COMPILE_OPT IDL2

  IF N_ELEMENTS(FILE) NE 1 THEN MESSAGE, 'ERROR: Must provide complete file name'
  IF N_ELEMENTS(TXT) EQ 0 THEN MESSAGE, 'ERROR: MUst provide txt array to write'
     
  OPENW,LUN,File,/GET_LUN

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  FOR N=0L,N_ELEMENTS(TXT)-1L DO BEGIN
    PRINTF,LUN,TXT[N]
  ENDFOR
  CLOSE,LUN & FREE_LUN,LUN
  
END; #####################  End of Routine ################################
