; $ID:	CPAL_2CSV.PRO,	2023-09-21-13,	USER-KJWH	$
;###############################################################################
	PRO CPAL_2CSV, PAL, DIR_OUT=DIR_OUT, OVERWRITE=OVERWRITE

;+
; NAME:
;		CPAL_2CSV
;
; PURPOSE: 
;   Writes out the R,G,B info of a color palette from pal_*.pro file to a .csv 
;
; CATEGORY:
;		PALETTE FUNCTION
;
; CALLING SEQUENCE:
;		CPAL_2CSV, PAL
;
; REQUIRED INPUTS:
;		PAL......... A standard pal_*.pro name (e.g. PAL_DEFAULT)
;
; OPTIONAL INPUTS:
;   DIR_OUT..... Output directory (default is !S.PALETTES/CSV/)
;
; KEYWORD PARAMETERS
;   OVERWRITE... Overwrite the .csv file if it exists
;   
; OUTPUTS:
;		A csv file with the R,G,B values for a specified color palette 
;
; OPTIONAL OUTPUTS:
;		None
;
; ; COMMON BLOCKS:
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
; Copyright (C) 2006, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written March 30, 2006 by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;
;
; MODIFICATION HISTORY:
;		Mar 30, 2006 - JEOR: Initial code written
;		Jul 07, 2014 - JEOR: Renamed from PAL_2CSV to PALS_2CSV to avoid conflics with pal_*.pros
;		Apr 15, 2021 - KJWH: Renamed from PALS_2CSV to CPAL_2CSV
;		                     Moved to PALETTE_FUNCTIONS
;		                     Added DIR_OUT keyword and changed default to !S.PALETTES + 'CSV' + SL
;		                     Now looping through PAL(s) if more than one provided
;		                     Added FILE_MAKE to check if the file is already there
;		                     Added OVERWRITE keyword
;		                     Added COMPILE_OPT IDL2
;		                     Updated documetation and formatting
;		                     
;-
;**************************************************************************************************************************
  
  ROUTINE_NAME = 'CPAL_2CSV'
  COMPILE_OPT IDL2 
  SL = PATH_SEP()
  
  IF N_ELEMENTS(PAL) EQ 0 THEN MESSAGE, 'ERROR: Must input at least one pal_*.pro'
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = !S.IDL_PALETTES + 'CSV' + SL
  
  
  FOR N=0, N_ELEMENTS(PAL)-1 DO BEGIN
    APAL = PAL[N]
    CSVFILE = DIR_OUT + APAL+'.csv'
    PALFILE = GET_PROGRAMS(APAL)
    IF ~FILE_TEST(PALFILE) THEN BEGIN
      PRINT, 'ERROR: ' + PALFILE + ' does not exist.'
      CONTINUE
    ENDIF
    IF FILE_MAKE(PALFILE,CSVFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
    CALL_PROCEDURE,APAL,R,G,B
    STRUCT= REPLICATE(CREATE_STRUCT('R','','G','','B',''),256)
    STRUCT.R = R
    STRUCT.G = G
    STRUCT.B = B
    
    CSV_WRITE,CSVFILE,STRUCT
  ENDFOR  

END; #####################  END OF ROUTINE ################################
