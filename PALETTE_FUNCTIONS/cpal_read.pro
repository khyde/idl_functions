; $ID:	CPAL_READ.PRO,	2023-09-21-13,	USER-KJWH	$
;######################################################################################
	FUNCTION CPAL_READ, PAL, PALLIST=PALLIST, R=R, G=G, B=B

;+
; NAME:
;		CPAL_READ
;
; PURPOSE:;
;		This function reads a color palette and returns a 3 x 256 array of R,G,B values
;
; CATEGORY:
;		PALETTE_FUNCTIONS
;
; CALLING SEQUENCE:
;   PAL_ARRAY = CPAL_READ(PAL)
;
; REQUIRED INPUTS:
;		PAL.......... The name of color palette program (e.g. pal_br or pal_36)
;		
;	OPTIONAL INPUTS:
;	  None
;	
;	KEYWORD PARAMETERS:
;   None	       	
;
; OUTPUTS:
;		THIS FUNCTION RETURNS THE PALETTE AS A 256 BY 3 ARRAY
;
; OPTIONAL OUTPUTS
;  PALLIST....... Contains a concatenated list of 256 R,G,B values   
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
; EXAMPLES:
;   PRINT,CPAL_READ('PAL_BR')
;   A = CPAL_READ('PAL_BR',PALLIST= PALLIST) & PRINT, N_ELEMENTS(A) & PRINT, N_ELEMENTS(PALLIST)  
;
;	NOTES:
;
; COPYRIGHT:
; Copyright (C) 2011, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on May 16, 2011 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
;
; MODIFICATION HISTORY:
;	  May 16, 2011 - KJWH: Initial code written
;		Mar 15, 2015 - JEOR: Removed ERROR [not used]
;		                     Added examples
;		                     Updated documentation and formatting
;		                     Added check for the PAL input
;   Apr 14, 2021 - KJWH: Updated documentation and formatting
;                        Added COMPILE_OPT IDL
;                        Changed subscript () to []
;                        Changed directory to !S.PALETTE_FUNCTIONS
;                        Changed name from CPAL_READ to CPAL_READ to be consistent with the PALS_ programs
;                        Moved to PALETTE_FUNCTION
;
;######################################################################################################
;-
  ROUTINE_NAME = 'CPAL_READ'
  COMPILE_OPT IDL2
  SL = GET_PATH()

  IF N_ELEMENTS(PAL) NE 1 THEN MESSAGE,'ERROR: Must provide a PALETTE name'
  PAL = STRLOWCASE(PAL)
  IF ~FILE_TEST(!S.PALETTE_FUNCTIONS + PAL + '.pro') THEN MESSAGE ,'ERROR: ' + !S.PALETTE_FUNCTIONS + PAL + '.pro does not exist'
	
	CALL_PROCEDURE,PAL,R,G,B
	
	ARR = BYTARR(3,N_ELEMENTS(R))
	ARR[0,*] = R
	ARR[1,*] = G
	ARR[2,*] = B
	
	PALLIST = LIST()
	FOR I = 0, N_ELEMENTS(R)-1 DO BEGIN
	PALLIST.ADD,REFORM(ARR[*,I])
	ENDFOR
	
	RETURN, ARR
  





	END; #####################  END OF ROUTINE ################################
