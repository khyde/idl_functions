; $ID:	GET_SATTYPE.PRO,	2020-06-26-15,	USER-KJWH	$
	FUNCTION GET_SATTYPE, NAME
;+
; NAME
;   GET_SATTYPE
;   
; PURPOSE: 
;   This function determines the type of non-traditional (e.g. L1A, L2, L3B, MUR, AVHRR) satdata type file
; 
; CATEGORY:	
;   FILE
;
; CALLING SEQUENCE: 
;   RESULT = GET_SATTYPE(NAME)
;
; REQUIRED INPUTS: 
;   NAME........... A text array with the file name
;
; OPTIONAL INPUTS:
;   None
;   
; KEYWORDS:
;   None
;     
; OUTPUTS: 
;   The type of satellite file 
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
; EXAMPLES:
;   PRINT, GET_SATTYPE('A2017050.L3b_DAY_CHL.nc'); = 'L3B'
;   PRINT, GET_SATTYPE('Z2002003.L3B2_DAY_CHL.nc'); = 'L3B'
;   PRINT, GET_SATTYPE('S1997264155040.L1A_MLAC.x.hdf'); = 'L1A'
;   PRINT, GET_SATTYPE('A2017002174500.L1A_LAC'); = 'L1A'
;   PRINT, GET_SATTYPE('S1997264155040.L2_MLAC_OC'); = 'L2'
;   PRINT, GET_SATTYPE('19810831024637-NCEI-L3C_GHRSST-SSTskin-AVHRR_Pathfinder-PFV5.3_NOAA07_G_1981243_night-v02.0-fv01.0.nc') ; = 'AVHRR'
;   PRINT, GET_SATTYPE('20170302090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc'); = 'MUR'
;   PRINT, GET_SATTYPE('D_20020606-MUR-V04.1-1KM-L3B2-SST.SAV'); = ''
;   PRINT, GET_SATTYPE('D_19970921-SEAWIFS-R2015-2KM-L3B2-PPD-VGPM2.SAV'); = ''
;   PRINT, GET_SATTYPE('SEAWIFS-R2015-L3B2-CHLOR_A-PAN-SUBAREAS.SAV'); = ''
;   
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 8, 2017 by Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;		Mar 08, 2017 - KJWH: Wrote initial code
;   Aug 13, 2018 - KJWH: Added ESA_OCCCI info
;   Mar 21, 2019 - KJWH: BUG FIX - HAS(NAME,'xxxx') was returning incorrect results when multiple files with different SATNAMES were entered. 
;                        Now looping through the SATNAMES and using WHERE_STRING to find the string
;                        Added COPYRIGHT information
;   Oct 15, 2020 - KJHW: Updated documentation
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Added a check for IS_NASADATE to work with new NASA files 
;
;-                        
; ******************************************************************************************************************************
  ROUTINE_NAME  = 'GET_SATTYPE'
;************************
  
  IF NONE(NAME) THEN MESSAGE,'ERROR: NAME IS REQUIRED'
  NAME = STRUPCASE(NAME)
  
  SATFILE = REPLICATE('',N_ELEMENTS(NAME))

  OK = WHERE(IS_SATDATE(NAME) EQ 1 OR IS_NASADATE(NAME) EQ 1, COUNT)
  IF COUNT GE 1 THEN BEGIN    
    SATNAMES = ['L3B','L2','L1A','MUR','AVHRR','ESACCI']
    FOR S=0, N_ELEMENTS(SATNAMES)-1 DO BEGIN 
      K = WHERE_STRING(NAME[OK],SATNAMES(S),COUNT)
      IF COUNT GE 1 THEN SATFILE(OK(K)) = SATNAMES(S)
    ENDFOR
  ENDIF
  OK = WHERE_STRING(SATFILE,'ESACCI',COUNT)
  IF COUNT GE 1 THEN SATFILE[OK] = 'ESA_OCCCI'


  RETURN, SATFILE

END; #####################  END OF ROUTINE ################################
