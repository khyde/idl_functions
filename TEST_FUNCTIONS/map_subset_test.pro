; $ID:	MAP_SUBSET_TEST.PRO,	2024-03-18-11,	USER-KJWH	$
  PRO MAP_SUBSET_TEST

;+
; NAME:
;   MAP_SUBSET_TEST
;
; PURPOSE:
;   Program to compare the output from MAPS_L3B_SUBSET and the subset section of MAPS_L3BGS_SWAP
;
; CATEGORY:
;   TEST_FUNCTIONS
;
; CALLING SEQUENCE:
;   MAP_SUBSET_TEST,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
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
; Copyright (C) 2024, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 18, 2024 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 18, 2024 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'MAP_SUBSET_TEST'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  L3BMAP = 'L3B4'
  SUBMAP = 'NWA'
  
  
  SWP = MAPS_L3BGS_SWAP(READ_LANDMASK(L3BMAP), L3BGS_MAP='L3B4',MAP_SUBSET='NWA',GSSUBS=GSSUBS, L3SUBS=L3SUBS, SUBSET_STRUCT=SWP_STRUCT,L3OCEAN_SUBS=OCEAN_SUBS,/INIT)
  SUB = MAPS_L3B_SUBSET(READ_LANDMASK(L3BMAP), INPUT_MAP='L3B4',SUBSET_MAP='NWA',SUBSET_BINS=SUBBINS,OCEAN_BINS=OCEBINS,/INIT)
  
  STOP


END ; ***************** End of MAP_SUBSET_TEST *****************
