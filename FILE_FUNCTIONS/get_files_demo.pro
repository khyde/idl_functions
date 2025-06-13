; $ID:	GET_FILES_DEMO.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO GET_FILES_DEMO

;+
; NAME:
;   GET_FILES_DEMO
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   GET_FILES_DEMO,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on April 21, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Apr 21, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'GET_FILES_DEMO'
  COMPILE_OPT IDL2
  SL = PATH_SEP()

  ; Get dataset directories
  
  ; Loop through dataset directories
  
  ; Find "default" files
  
  ; Need to establish the default maps, products, algs, levels, etc. for each dataset
  
  ; Make version folders for all datasets
  
  ; Change download data file directories to SOURCE


END ; ***************** End of GET_FILES_DEMO *****************
