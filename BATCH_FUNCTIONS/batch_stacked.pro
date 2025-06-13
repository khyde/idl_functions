; $ID:	BATCH_STACKED.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO BATCH_STACKED

;+
; NAME:
;   BATCH_STACKED
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   BATCH_FUNCTIONS
;
; CALLING SEQUENCE:
;   BATCH_STACKED,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
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
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 08, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 08, 2021 - KJWH: Initial code written
;   Nov 14, 2022 - KJWH: Changed D3HASH_MAKE to SAVE_2STACKED and D3HASH_2NETCDF to STACKED_2NETCDF
;   Dec 01, 2022 - KJWH: Changed SAVE_2STACKED to FILES_2STACKED
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'BATCH_STACKED'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  OSETS = ['MUR','AVHRR','OCCCI','GLOBCOLOUR']
  PERIODS = ['W','M','A']
  TYPES=['ANOMS','STATS']

  FOR O=0, N_ELEMENTS(OSETS)-1 DO BEGIN
    SET = OSETS[O]
    VER = []
    NC_MAP = 'NESGRID4'
    CASE SET OF
      'OCCCI': BEGIN & PRODS=['CHLOR_A-CCI'] & VER='6.0' & END
      'AVHRR': BEGIN & PRODS=['SST'] & END
      'MUR':   BEGIN & PRODS=['SST'] & NC_MAP='NESGRID' & END
    ENDCASE

    FOR R=0, N_ELEMENTS(PRODS)-1 DO BEGIN
      APROD = PRODS[R]
      FOR D=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
        APER = PERIODS[D]
        CASE APER OF
          'W': SPER = 'WW'
          'M': SPER = 'MM'
          'A': SPER = 'AA'
        ENDCASE
        FOR T=0, N_ELEMENTS(TYPES)-1 DO BEGIN
          ATYPE = TYPES[T]
          CASE ATYPE OF
            'STATS': STAT_TYPES=['MEAN','STD','NUM']
            'ANOMS': STAT_TYPES=['ANOMALY']
          ENDCASE

          FILES = GET_FILES(SET,PRODS=APROD,PERIODS=APER,FILE_TYPE=ATYPE,VERSION=VER)
          FILES_2STACKED, FILES, L3BMAP=D3MAP, OUTFILE=OUTFILE, STAT_TYPES=STAT_TYPES

          DFILES = GET_FILES(SET,PRODS=APROD,PERIODS=SPER,FILE_TYPE='STACKED',VERSION=VER)
          STACKED_2NETCDF, DFILES, MAP_OUT=NC_MAP, PERIOD_OUT=SPER

        ENDFOR ; TYPES
      ENDFOR ; PERIODS
    ENDFOR ; PRODS
  ENDFOR ; DATASETS



END ; ***************** End of BATCH_STACKED *****************
