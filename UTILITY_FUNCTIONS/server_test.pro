; $ID:	TEMPLATE_KH.PRO,	2015-12-29,	USER-KJWH	$

  PRO SERVER_TEST

;+
; NAME:
;   SERVER_TEST
;
; PURPOSE:
;   This procedure tests the speed of the server by opening several files in a loop
;
; CATEGORY:
;   UTILITIES
;
; CALLING SEQUENCE:
;   SERVER_TEST
;   idl -e "SERVER_TEST" (from the terminal window command line)
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;  None
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   This function prints the amount of time it takes to read 10 files
;
; OPTIONAL OUTPUTS:
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
;   SERVER_TEST
;
; NOTES:
;   
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 21, 2017 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 21, 2017 - KJWH: Initial code developed 
;   Sep 24, 2020 - KJWH: Changed FILES=FILE_SEARCH(!S.FILES) to FILES=GET_FILES('OCCCI',PROD='CHLOR_A-CCC',PERIOD='M')
;                        Updated documentation
;                        Changed subscript () to []
;                        Added COMPILE_OPT IDL2
;   
; ****************************************************************************************************
  ROUTINE_NAME = 'SERVER_TEST'
  COMPILE_OPT IDL2
	
	TIC
	
	FILES = GET_FILES('OCCCI',PROD='CHLOR_A-CCI',PERIOD='M')
	IF N_ELEMENTS(FILES) GT 10 THEN FILES = FILES[0:9]
	
	FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
	  PFILE, FILES[N], /R
	  D = STRUCT_READ(FILES[N])
	  GONE, D
	ENDFOR
	
	PRINT, 'TIME ELASPED FOR SERVER ' + !S.COMPUTER 
	TOC
	
END; #####################  End of Routine ################################
