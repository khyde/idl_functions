; $ID:	JUNK_STATS_COMPARE.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO JUNK_STATS_COMPARE

;+
; NAME:
;   JUNK_STATS_COMPARE
;
; PURPOSE:
;   JUNK program to compare the new and old image stats methods
;
; CATEGORY:
;   JUNK_FUNCTIONS
;
; CALLING SEQUENCE:
;   JUNK_STATS_COMPARE,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
; Copyright (C) 2022, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 14, 2022 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Mar 14, 2022 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'JUNK_STATS_COMPARE'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  DIR_OUT = !S.PROJECTS + ROUTINE_NAME + SL 
  DATASETS = ['AVHRR','OCCCI']
  PRODS = ['SST','CHLOR_A-CCI']
  PERIODS = ['M']
  DATERANGE = '2000'
  STATS_COMPARE = ['MEAN','MIN','MAX','STD','GMEAN','SPAN','CV']
  
  FOR N=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
    
    FOR I=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
      OFILES = GET_FILES(DATASETS[N],PRODS=PRODS[N],PERIODS=PERIODS[I],DATERANGE=DATERANGE)
      NFILES = GET_FILES(DATASETS[N],PRODS=PRODS[N],PERIODS=PERIODS[I],DATERANGE=DATERANGE,FILETYPE='STACKED_STATS')
    ENDFOR
  ENDFOR


END ; ***************** End of JUNK_STATS_COMPARE *****************
