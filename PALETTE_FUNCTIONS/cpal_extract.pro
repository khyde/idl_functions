; $ID:	CPAL_EXTRACT.PRO,	2021-04-15-10,	USER-KJWH	$

	PRO CPAL_EXTRACT, FILE, NAME=NAME, RGB_PAL=RGB_PAL, OVERWRITE=OVERWRITE

;+
; NAME:
;   CPAL_EXTRACT, FILE=FILE, NAME=NAME, RGP_PAL=RGB_PAL
; 
; PURPOSE: 
;   Extract the R,G,B values from an image and return or create a new color palette
;
; CATEGORY:	
;   PALETTE_FUNCTIONS
;
; CALLING SEQUENCE: 
;   PALS_EXTRACT
;
; REQUIRED INPUTS: 
;   None
;		
; OPTIONAL INPUTS:
;		FILE.......... The fullname of the 8-bit image file
;		NAME.......... The name for the output palette file
;		
; KEYWORD PARAMETERS:
;		OVEWRITE...... Overwrite the PAL file if it exists
;		FILE: INPUT 8-BIT IMAGE FILE
;   RGB_PAL: OUTPUT RBGS EXTRACTED FROM INPUT IMAGE FILE

; OUTPUTS:
;   A new color palette (pal_*.pro) file
;   
; OPTIONAL OUTPUTS:
;   RGB_PAL ...... A 3x256 array of the R, G, B values   
;		
; EXAMPLES: 
;     
;     
; NOTES:
;
;
; COPYRIGHT:
; Copyright (C) 2014, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written April 11, 2014 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     Inquires about this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;	  APR 11, 2014 - JEOR: Initial code written
;		APR 30, 2014 - JEOR: Added keyword NAME
;		JUL 04, 2014 - JEOR: Added IMG = READ_IMAGE(FILE,RED,GREEN,BLUE)
;		JUL 06, 2014 - JEOR: Added and test example
;		APR 15, 2021 - KJWH: Updated documentation
;		                     Changed name to CPALS_EXTRACT
;		                     Added COMPILE_OPT IDL2
;		                     Changed subscript () to []
;		                     Added OVERWRITE keyword
;-		
; ****************************************************************************************************

  ROUTINE_NAME  = 'CPAL_EXTRACT'
  FILTERS = ['*.JPG', '*.TIF', '*.PNG']
  
  IF ~KEYWORD_SET(FILE) THEN FILE = DIALOG_PICKFILE(/READ, FILTER = FILTERS)
  IF N_ELEMENTS(FILE) NE 1 THEN MESSAGE,'ERROR: FILE IS REQUIRED'
  IF N_ELEMENTS(NAME) NE 1 THEN BEGIN
    FN = FILE_PARSE(FILE)
    NAME = FN.NAME
    NAME = REPLACE(NAME,'-','_')
  ENDIF

  IMG = READ_IMAGE(FILE,RED,GREEN,BLUE)
  SZ = SIZEXYZ(IMG)
  IF SZ.N_DIMENSIONS NE 2 THEN MESSAGE,'ERROR: IMAGE MUST BE ONLY 2 DIMENSIONS'
  I = IMAGE(IMG,/BUFFER)
  T = I.RGB_TABLE
  I.CLOSE
  R = REFORM(T[0,*])
  G = REFORM(T[1,*])
  B = REFORM(T[2,*])
  RGB_PAL = BYTARR(3,256)
  RGB_PAL[0,*] = R  
  RGB_PAL[1,*] = G 
  RGB_PAL[2,*] = B

  CPAL_WRITE, NAME, R,G,B, OVERWRITE=OVERWRITE
 
END; #####################  END OF ROUTINE ################################
