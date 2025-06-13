; $ID:	CPAL_REVERSE.PRO,	2021-07-27-16,	USER-KJWH	$

  PRO CPAL_REVERSE, PAL, OUTNAME=OUTNAME, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_REVERSE
;
; PURPOSE:
;   This procedure creates a new color palette by reversing the order of an existing palette
;
; CATEGORY:
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   PALS_REVERSE, PAL, OVERWRITE=OVERWRITE
;
; REQUIRED INPUTS:
;   PAL......... The name of an existing pal_.pro
;
; OPTIONAL INPUTS:
;   OUTNAME..... The name of the output file if different from the default
;
; KEYWORD PARAMETERS:
;   OVERWRITE.... Overwrite an existing pal if it exists
;
; OUTPUTS:
;   This function creates a new palete in the PALETTE_FUNCTIONS directory
;
; OPTIONAL OUTPUTS:
;   None
;   
; COMMON BLOCKS
;   None
;   
; RESTRICTIONS
;   Must use an existing pal_*.pro file as an input  
;
; EXAMPLE:
;   CPAL_REVERSE, 'PAL_DEFAULT'
;
; NOTES:
;      
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          
;AUTHOR:
;   This program was written on February 11, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;			Feb 11, 2020 - KJWH: Initial code written
;			Apr 14, 2021 - KJWH: Updated documentation
;			                     Added COMPILE_OPT IDL2
;			                     Changed subscript () to []
;			                     Changed file location to !S.PALETTE_FUNCTIONS
;			Apr 15, 2021 - KJWH: Changed name to CPAL_REVERSE         
;			Jul 27, 2021 - KJWH: Now using CPAL_COLORBOX to view the palette       
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CPAL_REVERSE'
	
  IF N_ELEMENTS(PAL) EQ 0 THEN MESSAGE, 'ERROR: Must provide input palette name.'
  IF FILE_TEST(!S.PALETTE_FUNCTIONS + STRLOWCASE(PAL) + '.pro') EQ 0 THEN MESSAGE, 'ERROR: ' + PAL + '.pro does not exist in ' + !S.PALETTE_FUNCTIONS
  IF N_ELEMENTS(OUTNAME) EQ 0 THEN OUTNAME = STRLOWCASE(PAL+'_rev')
  IF N_ELEMENTS(OUTNAME) NE N_ELEMENTS(PAL) THEN MESSAGE, 'ERROR: The number of output names must equal the number of input palettes.'
  
  FOR N=0, N_ELEMENTS(PAL)-1 DO BEGIN
    APAL = STRLOWCASE(PAL[N])
    NPAL = OUTNAME[N]
    IF FILE_MAKE(!S.PALETTE_FUNCTIONS+APAL+'.pro',!S.PALETTE_FUNCTIONS+NPAL+'.pro',OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    RGB = CPAL_READ(APAL)
    RR = RGB[0,*]
    GG = RGB[1,*]
    BB = RGB[2,*]
    
    RR[1:250] = REVERSE(RR[1:250])
    GG[1:250] = REVERSE(GG[1:250])
    BB[1:250] = REVERSE(BB[1:250])
    
    ; ===> View the new color palette
  ;  TVLCT, RR, GG, BB
  ;  CPAL_COLORBOX,DELAY=3
    
    CPAL_WRITE, NPAL, RR,GG,BB
    FILE_DOC, NPAL
    CPAL_COLORBOX, NPAL
    
  ENDFOR   
	


END; #####################  End of Routine ################################
