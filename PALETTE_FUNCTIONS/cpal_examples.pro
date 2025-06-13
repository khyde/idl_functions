; $ID:	CPAL_EXAMPLES.PRO,	2023-09-21-13,	USER-KJWH	$

	PRO CPAL_EXAMPLES, EXT=EXT, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE
;+
;
; NAME:
;   CPAL_EXAMPLES
;
; PURPOSE: 
;   Generate a pdf of all the color palette programs
;
; CATEGORY:	
;   PALETTE FUNCTIONS
;
; CALLING SEQUENCE: 
;   PALS_EXAMPLES
;
; REQUIRED INPUTS: 
;   None
;		
; OPTIONAL INPUTS:
;		DIR_OUT........ Output directory	
;		
; KEYWORD PARAMETERS:
;		EXT............ Extension for the output file (pdf or gif are allowed)
;   
; OUTPUTS: 
;   A multi-page pdf or gif file
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
;   
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 6, 2010 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 06, 2010 - KJWH: Initial code written
;	  Jul 03, 2014 - JEOR: Modified to use new graphics programs
;		Jul 07, 2014 - JEOR: Makes one pdf of all our palette programs, skips if pal name incorrect
;		Apr 15, 2021 - KJWH: Updated documentation and formatting
;		                     Changed name to CPAL_EXAMPLES and moved to PALETTE FUNCTIONS
;		                     Added COMPILE_OPT IDL2
;		                     Changed subscript () to []
;		Jul 26, 2021 - KJWH: Now using CPAL_COLORBOX to view the color palette
;		                     Updated the output directory
;		                     Removed old code that is no longer in use
;		                     Added OVERWRITE keyword
;
;-
;********************************************************************************************************************************
  ROUTINE_NAME  = 'CPAL_EXAMPLES'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
;
; ===> Constants and defaults
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = !S.PALETTE_FUNCTIONS + 'PLOTS' + SL & DIR_TEST, DIR_OUT

;===> Get all the palette programs
  PALS = GET_PROGRAMS('pal_*')
  
  FOR NTH = 0,N_ELEMENTS(PALS)-1 DO BEGIN
    PAL = PALS[NTH]
    FP = FILE_PARSE(PAL)
    PALNAME = FP.FIRST_NAME
    OUTFILE = DIR_OUT + PALNAME + '.png'
    IF FILE_TEST(OUTFILE) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
    POF,NTH,PALS
    PFILE,PALNAME,/M  
    CPAL_COLORBOX, PALNAME, /PNG, BUFFER=1
  ENDFOR;FOR NTH = 0,N_ELEMENTS(PALS) DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  PFILE,FILE



END; #####################  END OF ROUTINE ################################
